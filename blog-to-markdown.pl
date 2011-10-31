use XML::XPath;
use Date::Formatter;
use Date::Manip;
 
my $xmlfile = shift @ARGV;              # the file to parse
 
my $xp = XML::XPath->new(filename=>$xmlfile);
 
# An XML::XPath nodeset is an object which contains the result of
# smacking an XML document with an XPath expression.
my $nodeset = $xp->find('//item');
 
my $topLevelDomain = "http://www.wesleyhales.com";        #use this later when parsing relative links
my @items;                   # Where we'll put our results               
foreach my $node ($nodeset->get_nodelist){
	my @lines;
	push(@lines,"---\n");
	push(@lines,"layout: blog\n");
	my @title = $node->find('./title');
	$parsedTitle = "@title";
	#replace colon in title with html character
	$parsedTitle =~ s/\:/\&\#58\;/g;
	
	$fileName = "@title";
	#replace whitespace with hyphen
	$fileName =~ s/[ ]/-/g;
	$fileName =~ s/\-\-\-/\-/g;
    #remove any non alphanumerics with hyphen exception
	$fileName =~ s/[^A-Za-z0-9^-]+//g;
	
	push(@lines,"title: $parsedTitle\n");
	
	
	push(@lines,"tags: [");
	
	my @categories = $node->findnodes('category');
	my $index = 1;
	my $catSize = scalar(@categories);
	foreach (@categories){
		
		push(@lines, $_->string_value);
		
		if(($catSize > 1) && ($catSize > $index)){
			push(@lines, ", ");	
		}
		$index++;
	}
	push(@lines,"]\n");
	
	
	push(@lines,"---\n\n");
	
	my @description = $node->find('./description');
	$parsedDescription = "@description";
	
	#--------------
	#my proprietary jroller helpers to replace old links and bad markup
	#--------------
	#find the blog (jroller) context root and replace with topLevelDomain
	#$parsedDescription =~ s/src\=\"\/wesleyhales/src\=\"$topLevelDomain\/jroller/g;
	#$parsedDescription =~ s/\/resources\/w\/wesleyhales/src\=\"$topLevelDomain\/jroller\/resource/g;
	#$parsedDescription =~ s/http\:\/\/www\.wesleyhales\.com\/resource/$topLevelDomain\/jroller\/resource/g;
	#$parsedDescription =~ s/http\:\/\/jroller\.com\/wesleyhales\/resource/$topLevelDomain\/jroller\/resource/g;
	#$parsedDescription =~ s/http\:\/\/www\.jroller\.com\/wesleyhales\/resource/$topLevelDomain\/jroller\/resource/g;
	
	#remove feedburner tracking images
	#$parsedDescription =~ s/\<img src\=\"http\:\/\/feeds\.feedburner\.com(.*)//g;
	
	#html charcter encode - based on my markup examples with java EL
	#$parsedDescription =~ s/\#\{/\&\#35\;\{/g;
		
	 
	push(@lines,$parsedDescription);
	push(@lines,"\n");
	
	#print XML::XPath::XMLParser::as_string('@title')
	my @pubDates = $node->find('./pubDate'); 
    my $nextDate;
	foreach (@pubDates) {
		my $td = substr($_,5);
		my $td2 = substr($td,0,11);
		my $date = &ParseDate($td2);
		$nextDate = &UnixDate($date,"%Y-%m-%d");
	}
	
	open(MY_FILE,">./$nextDate-$fileName.md") || die("cant do it");
	print MY_FILE (@lines);
	close(MY_FILE);
}
