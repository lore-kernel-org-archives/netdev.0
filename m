From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 19:14:29 +0100
Message-ID: <20041205181429.GM647@xi.wantstofly.org>
References: <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <20041205151545.GC647@xi.wantstofly.org> <Pine.LNX.4.58.0412051616090.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051622380.29474@tux.rsn.bth.se> <20041205170006.GI647@xi.wantstofly.org> <Pine.LNX.4.58.0412051804370.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051836020.29474@tux.rsn.bth.se>
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
In-Reply-To: <Pine.LNX.4.58.0412051836020.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 06:38:05PM +0100, Martin Josefsson wrote:

> e1000: MMIO read took 481 clocks
> e1000: MMIO read took 369 clocks
> e1000: MMIO read took 481 clocks
> e1000: MMIO read took 11 clocks
> e1000: MMIO read took 477 clocks
> e1000: MMIO read took 316 clocks

Interesting.  On a 1667MHz CPU, this is around ~0.28us per MMIO read
in the worst case.  On my hardware (dual Xeon 2.4GHz), the best case
I've ever seen was ~0.83us.

This alone can make a hell of a difference, esp. for 60B packets.


--L
