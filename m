From: jamal <hadi@cyberus.ca>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: 08 Mar 2005 09:17:50 -0500
Message-ID: <1110291470.1043.211.camel@jzny.localdomain>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>
	 <20050306173145.GQ31837@postel.suug.ch>
	 <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de>
	 <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com>
	 <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net>
	 <1110288879.1050.167.camel@jzny.localdomain>
	 <20050308135134.GA20607@atrey.karlin.mff.cuni.cz>
	 <1110290300.1050.190.camel@jzny.localdomain>
	 <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: Martin Mares <mj@ucw.cz>
In-Reply-To: <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 09:03, Martin Mares wrote:

> No, since this tends to interfere with the outside network using the
> same private (RFC 1918) addresses. People generally don't expect network
> equipment to collide with their perfectly legal addressing plan.
> 

Aha! Thanks for clarifying this. So the problem domain is:  "IP address
conflict" detection and somehow this is seen as a resolution to that
problem. 
So what happens when you put tow or three of Zdenek's boxes in one
location? Back to square 1?

> On the other hand, if the manufacturer gets a small block of public
> addresses and uses it in all his devices (the same block everywhere)
> for internal purposes only (no packet ever escapes), everything is
> perfectly correct and no collisions can arise.

Yes, I see.
Except this wont be practical for IPV4 since those addresses are scarce.
May make sense for V6 though (becomes like MAC addresses on NICS).

cheers,
jamal

