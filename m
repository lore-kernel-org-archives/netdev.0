From: Martin Mares <mj@ucw.cz>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 15:03:01 +0100
Message-ID: <20050308140301.GC20607@atrey.karlin.mff.cuni.cz>
References: <E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net> <20050306173145.GQ31837@postel.suug.ch> <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com> <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> <1110288879.1050.167.camel@jzny.localdomain> <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110290300.1050.190.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> People tend to use private blocks in a chasis (unique IP for each blade)
> - which by default are not routed outside the chasis.
> 
> I have a feeling this is what you meant

No, since this tends to interfere with the outside network using the
same private (RFC 1918) addresses. People generally don't expect network
equipment to collide with their perfectly legal addressing plan.

On the other hand, if the manufacturer gets a small block of public
addresses and uses it in all his devices (the same block everywhere)
for internal purposes only (no packet ever escapes), everything is
perfectly correct and no collisions can arise.

				Have a nice fortnight
-- 
Martin `MJ' Mares   <mj@ucw.cz>   http://atrey.karlin.mff.cuni.cz/~mj/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
"Computers are useless.  They can only give you answers."  -- Pablo Picasso
