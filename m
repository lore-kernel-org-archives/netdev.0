From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 19:40:03 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
 <20050306173145.GQ31837@postel.suug.ch>  <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net>
 <m1y8d0mss2.fsf@muc.de>  <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
 <422C0B50.20500@mrv.com>  <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
 <1110288879.1050.167.camel@jzny.localdomain>  <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
  <1110290300.1050.190.camel@jzny.localdomain>  <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
 <1110291470.1043.211.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Martin Mares <mj@ucw.cz>, Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1110291470.1043.211.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005, jamal wrote:

> Aha! Thanks for clarifying this. So the problem domain is:  "IP address
> conflict" detection and somehow this is seen as a resolution to that
> problem.
> So what happens when you put tow or three of Zdenek's boxes in one
> location? Back to square 1?

Not if the 127.X addresses never leaves the Zdenek's boxes, when thinking 
in terms that each set of boxes communicating using 127.X addresses is a 
single chassis, seen as a single box to the network admin.

> Except this wont be practical for IPV4 since those addresses are scarce.
> May make sense for V6 though (becomes like MAC addresses on NICS).

IPv6 already have link local addressing IIRC.

Regards
Henrik
