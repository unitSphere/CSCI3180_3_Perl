package Position;

sub new{
    my $class = shift;
    my $self = {
        r => 0,
        c => 0,
    };
    return bless $self, $class;
}

sub getC{
    my ( $self ) = @_;
    return $self->{c};
}

sub getR{
    my ( $self ) = @_;
    return $self->{r};
}

sub setC{
    my ( $self, $c ) = @_;
    $self->{c} = $c;
}

sub setR{
    my ( $self, $r ) = @_;
    $self->{r} = $r;
}

package Cell;

sub new{
    my $class = shift;
    my $self = {
        pos => new Position(),
        content => '*',
        explored => 0,
    };
    return bless $self, $class;
}

sub setExplored{
    my ( $self, $value ) = @_;
    $self->{explored} = $value;
}

sub getExplored{
    my ( $self ) = @_;
    return $self->{explored};
}

sub setContent{
    my ( $self, $content ) = @_;
    $self->{content} = $content;
}

sub getContent{
    my ( $self ) = @_;
    return $self->{content};
}

sub setPos{
    my ( $self, $pos ) = @_;
    $self->{pos} = $pos;
}

sub getPos{
    my ( $self ) = @_;
    return $self->{pos};
}

sub isAvailable{
    my ( $self ) = @_;
    if($self->{content} eq '*' | $self->{content} eq 'O'){
      return 1;
    }
    else{
      return 0;
    }
}

package Maze;

our @map;
sub new{
    my $class = shift;
    my $self = {
        height => 0,
        width => 0,
        destPos=> new Position(),
    };
    return bless $self, $class;
}

sub getHeight{
    my ( $self ) = @_;
    return $self->{height};
}

sub getWidth{
    my ( $self ) = @_;
    return $self->{width};
}

sub explore{
    my ( $self, $pos ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    $map[$row][$col]->setExplored(1);
}

sub getCell{
    my ( $self, $pos ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    return $map[$row][$col];
}

sub setCell{
    my ( $self, $pos, $cell ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    $map[$row][$col] = $cell;
}

sub getCellContent{
    my ( $self, $pos ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    return $map[$row][$col]->getContent();
}

sub setCellContent{
    my ( $self, $pos, $value ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    $map[$row][$col]->setContent($value);
}

sub isAvailable{
    my ( $self, $pos ) = @_;
    my $col = $pos->getC();
    my $row = $pos->getR();
    if( $row < $self->getHeight() & $col < $self->getWidth()){
      if($map[$row][$col]->isAvailable() == 0){
        return -1;
      }
      else{
        return 1;
      }
    }
    else{
      return 0;
    }
}

sub reachDest{
    my ( $self, $pos ) = @_;
    if($pos->getC() == $self->{destPos}->getC() & $pos->getR() == $self->{destPos}->getR()){
      return 1;
    }
    return 0;
}

sub displayMaze{
  my $self = shift;
  my $h = $self->getHeight();
  my $w = $self->getWidth();

  print "Current Maze > \n\n";
  my $indent = "\t\t\t";
  print "$indent   |";
  for(my $j=0; $j < $w; $j++){
    print " $j |";
  }
  print "\n$indent";
  for(my $j=0; $j < $w+1; $j++){
    print "----";
  }
  print "\n";
  for(my $i=0; $i < $h; $i++){
    print "$indent $i |";
    for(my $j=0; $j < $w; $j++){
      my $cell = $map[$i][$j];
      my $ch = $cell->{content};
      if($cell->getExplored() == 1){
        if($ch ne "*"){
          print " $ch |";
        }
        else{
          print "   |";
        }
      }
      else{
        print " ? |";
      }
    }
    print "\n$indent";
    for(my $j=0; $j < $w+1; $j++){
      print "----";
    }
    print "\n";
  }
  print "\n--\n";
}

sub loadMaze{
  my ($self, $fh) = @_;

  my $row = <$fh>;
  chomp $row;
  my @maze_hw = split / /, $row;
  my ($h, $w) = (int($maze_hw[0]), int($maze_hw[1]));

  my ($end_h, $end_w) = (0, 0);
  my @coords = (0, 0, 0, 0);
  for(my $i=0; $i < $h; $i++){
    $row = <$fh>;
    chomp $row;
    for(my $j=0; $j < $w; $j++){
      my $ch = substr($row, $j, 1);
      my $cell = Cell->new();
      if($ch eq 'O'){
        ($end_h, $end_w) = ($i, $j);
      }
      else{
        if($ch eq '1'){
          ($coords[0], $coords[1]) = ($i, $j);
          $ch = 'E';
        }
        else{
          if($ch eq '2'){
            ($coords[2], $coords[3]) = ($i, $j);
            $ch = 'H';
          }
        }
      }

      $cell->setContent($ch);
      my $pos = Position->new();
      $pos->setR($i);
      $pos->setC($j);
      $cell->setPos($pos);
      $map[$i][$j] = $cell;
    }
  }

  $self->{height} = $h;
  $self->{width} = $w;
  $self->{destPos}->setR($end_h);
  $self->{destPos}->setC($end_w);
  $self->{map} = \@map;
  $self->{is_empty} = 0;

  $self->explore($self->{destPos});
  return @coords;
}

package Player;

our @rshift = (1, 0, -1, 0);
our @cshift = (0, 1, 0, -1);

sub new{
    my $class = shift;
    my $self = {
    	  name => "",
        curPos => new Position(),
        specialMovesLeft => 4,
    };
    return bless $self, $class;
}

sub setName{
    my ( $self, $name ) = @_;
    $self->{name} = $name;
}

sub getName{
    my ( $self ) = @_;
    return $self->{name};
}

sub getPos{
    my ( $self ) = @_;
    return $self->{curPos};
}

sub occupy{
    my ( $self, $maze ) = @_;
    $maze->setCellContent($self->getPos(), $self->getName());
    $maze->explore($self->getPos());
}

sub leave{
    my ( $self, $maze ) = @_;
    $maze->setCellContent($self->getPos(), '*');
    $maze->explore($self->getPos());
}

sub move{
  my ($self, $pointTo, $maze) = @_;
  my $p = $self->next($pointTo);
  if($maze->isAvailable($p) == 1){
    $self->leave($maze);
    my $cur_h = $self->{curPos}->getR();
    my $cur_w = $self->{curPos}->getC();
    $self->{curPos}->setR($cur_h+$rshift[$pointTo]);
    $self->{curPos}->setC($cur_w+$cshift[$pointTo]);
    $self->occupy($maze);
  }
  elsif($p->getR() < $maze->getHeight() & $p->getC() < $maze->getWidth() & $p->getR() >= 0 & $p->getC() >= 0){
    $maze->explore($p);
  }
}

sub next{
  my ($self, $pointTo) = @_;
  my $pos = Position->new();
  $pos->setR($self->getPos()->getR()+$rshift[$pointTo]);
  $pos->setC($self->getPos()->getC()+$cshift[$pointTo]);
  return $pos;
}

sub rush{
  my ( $self, $pointTo, $maze ) = @_;
  $self->move($pointTo, $maze);
  $pos = $self->next($pointTo);
  while($pos->getR() < $maze->getHeight() & $pos->getC() < $maze->getWidth() & $pos->getR() >= 0 & $pos->getC() >= 0){
    if($maze->isAvailable($pos) == 1){
      $self->move($pointTo, $maze);
      $pos = $self->next($pointTo);
    }
    else{
      last;
    }
  }
  if($pos->getR() < $maze->getHeight() & $pos->getC() < $maze->getWidth() & $pos->getR() >= 0 & $pos->getC() >= 0){
    $maze->explore($pos);
  }
}

sub throughBlocked{
  my ($self, $pointTo, $maze) = @_;
  my $pos = $self->getPos();
  my $target_pos = new Position();
  my $c = $pos->getC();
  my $r = $pos->getR();
  my $target_c = (2 * ($cshift[$pointTo])) + $c;
  my $target_r = (2 * ($rshift[$pointTo])) + $r;
  $target_pos->setR($target_r);
  $target_pos->setC($target_c);
  my $tmp_p = new Position();
  $tmp_p->setR($r + $rshift[$pointTo]);
  $tmp_p->setC($c + $cshift[$pointTo]);

  if($target_c < $maze->getWidth() & $target_r < $maze->getHeight() & $target_c >= 0 & $target_r >= 0){
    if($maze->getCellContent($target_pos) eq '*'){
      my $tmp_content = $maze->getCellContent($tmp_p);
      $maze->setCellContent($tmp_p, '*');
      $self->move($pointTo, $maze);
      $self->move($pointTo, $maze);
      $maze->setCellContent($tmp_p, $tmp_content);
    }
    else{
      $maze->explore($tmp_p);
      $maze->explore($target_pos);
    }
  }
}

sub teleport{
    my ($self, $maze) = @_;
    my $row = int(rand $maze->getHeight());
    my $col = int(rand $maze->getWidth());
    my $pos = new Position();
    $pos->setR($row);
    $pos->setC($col);
    if($maze->getCellContent($pos) eq '*'){
      $self->leave($maze);
      $self->{curPos}->setR($row);
      $self->{curPos}->setC($col);
      $self->occupy($maze);
    }
    else{
      $maze->explore($pos);
    }
}

sub makeMove{
  my ($self, $maze) = @_;
  my $p_name = $self->getName();

  if($self->{specialMovesLeft} le 0){
    print "Your (Player $p_name) moving type: normal move.\n";
    print "Your (Player $p_name) moving direction (0: S, 1: E, 2: N, 3: W) > ";
    my $d = <STDIN>;
    chomp $d;

    while($d ne "0" and $d ne "1" and $d ne "2" and $d ne "3"){
      print "The moving direction can only be 0, 1, 2, or 3, please re-input > ";
      $d = <STDIN>;
      chomp $d;
    }
    $d = int($d);
    $self->move($d, $maze);
  }
  else{
    my $scnt = $self->{specialMovesLeft};
    if($scnt > 1){
      print "You (Player $p_name) can make a normal move (unlimited) or a special move (only $scnt times left).\n";
    }
    else{
      print "You (Player $p_name) can make a normal move or a special move (only $scnt time left).\n";
    }
    print "Your (Player $p_name) moving type (0: rush, 1: through-blocked, 2: teleport, default: normal move) > ";
    my $op = <STDIN>;
    chomp $op;

    while($op ne "0" and $op ne "1" and $op ne "2" and $op ne ""){
      print "This moving type can only be 0, 1, or 2, please re-input > ";
      $op = <STDIN>;
      chomp $op;
    }

    if ($op eq ""){
      $op = "-1";
    }
    $op = int($op);

    if($op eq 2){
      $self->teleport($maze);
      $self->{specialMovesLeft}--;
    }
    else{
      print "Your (Player $p_name) moving direction (0: S, 1: E, 2: N, 3: W) > ";
      my $d = <STDIN>;
      chomp $d;

      while($d ne "0" and $d ne "1" and $d ne "2" and $d ne "3"){
        print "The moving direction can only be 0, 1, 2, or 3, please re-input > ";
        $d = <STDIN>;
        chomp $d;
      }
      $d = int($d);

      if($op eq -1){
        $self->move($d, $maze);
      }
      else{
        if($op eq 0){
          $self->rush($d, $maze);
        }
        else{
          $self->throughBlocked($d, $maze);
        }
        $self->{specialMovesLeft}--;
      }
    }
  }
}

1;
