From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 18:58:17 +0100
Message-ID: <20041205175817.GL647@xi.wantstofly.org>
References: <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051730010.29474@tux.rsn.bth.se>
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
In-Reply-To: <Pine.LNX.4.58.0412051730010.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 05:48:34PM +0100, Martin Josefsson wrote:

> I tried using both ports on the 82546GB nic.
> 
>         delay        nodelay
> 1CPU    1.95 Mpps    1.76 Mpps
> 2CPU    1.60 Mpps    1.44 Mpps

I get:

	delay		nodelay
1CPU	1837356		1837330
2CPU	2035060		1947424

So in your case using 2 CPUs degrades performance, in my case it
increases it.  And TDT delaying/coalescing only improves performance
when using 2 CPUs, and even then only slightly (and only for <= 62B
packets.)


--L
