From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 08 Mar 2005 16:17:11 -0500
Message-ID: <1110316631.1084.57.camel@jzny.localdomain>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
	 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
	 <1110288879.1050.167.camel@jzny.localdomain>
	 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
	 <1110290300.1050.190.camel@jzny.localdomain>
	 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
	 <1110291470.1043.211.camel@jzny.localdomain>
	 <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 13:40, Henrik Nordstrom wrote:
[..]
> Not if the 127.X addresses never leaves the Zdenek's boxes, when thinking 
> in terms that each set of boxes communicating using 127.X addresses is a 
> single chassis, seen as a single box to the network admin.
> 

Henrik, so what is the difference between this and using any random
block of addresses?;-> If the packets never leave the box i can use
IBM's block of addresses if i wanted - no need to sweat this far (with
hacking the kernel). 
If Zdenek is going to put more than one box then theres nothing magical;
he will have to sit down and configure one of the boxes manually - no
escape there.
If he puts only a single box then he may likely get away with it.

> > Except this wont be practical for IPV4 since those addresses are scarce.
> > May make sense for V6 though (becomes like MAC addresses on NICS).
> 
> IPv6 already have link local addressing IIRC.
> 

indeed that is what is needed in this case if the problem is address
conflict resolution. An equivalent for v4 (called zeroconf) is at:
http://www.zeroconf.org/
It is unfortunate though because Apple has been claiming it has
patented this v4 linklocal scheme - and if i recall the person who wrote
the Linux code eventually took it off their web page (cant even seem to
find the web page anymore).

cheers,
jamal

