From: Martin Mares <mj@ucw.cz>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Tue, 8 Mar 2005 15:20:23 +0100
Message-ID: <20050308142022.GG20607@atrey.karlin.mff.cuni.cz>
References: <E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net> <422C0B50.20500@mrv.com> <3sp35g$7rsc1@smtp04.mrf.mail.rcn.net> <1110288879.1050.167.camel@jzny.localdomain> <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain> <20050308140301.GC20607@atrey.karlin.mff.cuni.cz> <1110291470.1043.211.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Radouch <zdenek@rcn.com>,
	Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
	Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
	Andi Kleen <ak@muc.de>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110291470.1043.211.camel@jzny.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> So what happens when you put tow or three of Zdenek's boxes in one
> location? Back to square 1?

No, if I understood Zdenek correctly, he wants to use the addresses
only internally inside the box, so multiple boxes should happily
co-exist. OTOH if the same address is used anywhere in the neighboring
network, it's going to break.

> Except this wont be practical for IPV4 since those addresses are scarce.

If the addresses are going to be used only internally, it suffices to
allocate only a small block of addresses and use this block for all
devices.

> May make sense for V6 though (becomes like MAC addresses on NICS).

Sure.

				Have a nice fortnight
-- 
Martin `MJ' Mares   <mj@ucw.cz>   http://atrey.karlin.mff.cuni.cz/~mj/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
Mr. Worf, scan that ship."  "Aye, Captain... 600 DPI?
