From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 16:15:45 +0100
Message-ID: <20041205151545.GC647@xi.wantstofly.org>
References: <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 04:03:36PM +0100, Martin Josefsson wrote:

> BUT if I use the above + prefetching I get this:
> 
> 60      1483890
> [snip]
> 
> Which is pretty nice :)

Not just that, it's also wire speed GigE.  Damn.  Now we all have to go
and upgrade to 10GbE cards, and I don't think my girlfriend would give me
one of those for christmas.


> This is on one port of a 82546GB
> 
> The hardware is a dual Athlon MP 2000+ in an Asus A7M266-D motherboard and
> the nic is located in a 64/66 slot.

Hmmm.  Funny you get this number even on 64/66.  How many PCI bridges
between the CPUs and the NIC?  Any idea how many cycles an MMIO read on
your hardware is?


cheers,
Lennert
