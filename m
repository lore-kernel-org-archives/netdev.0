From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 18:51:33 +0100
Message-ID: <20041205175133.GK647@xi.wantstofly.org>
References: <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se> <20041205174401.GJ647@xi.wantstofly.org>
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
In-Reply-To: <20041205174401.GJ647@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Dec 05, 2004 at 06:44:01PM +0100, Lennert Buytenhek wrote:
> On Sun, Dec 05, 2004 at 04:42:34PM +0100, Martin Josefsson wrote:
> 
> > The delayed TDT updating was a test and currently it delays the first tx'd
> > packet after a timerrun 1ms.
> > 
> > Would be interesting to see what other people get with this thing.
> > Lennert?
> 
> I took Scott's notxints patch, added the prefetch bits and moved the
> TDT updating to e1000_clean_tx as you did.
> 
> Slightly better than before, but not much:

I've tested all packet sizes now, and delayed TDT updating once per jiffy
(instead of once per packet) indeed gives about 25kpps more on 60,61,62
byte packets, and is hardly worth it for bigger packets.


--L
