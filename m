From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 05 Dec 2004 13:12:22 -0800
Message-ID: <1102281141.3343.138.camel@sfeldma-mobl.dsl-verizon.net>
References: <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <20041201182943.GA14470@xi.wantstofly.org>
	 <20041201213550.GF14470@xi.wantstofly.org>
	 <1101967983.4782.9.camel@localhost.localdomain>
	 <20041205145051.GA647@xi.wantstofly.org>
	 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-12-05 at 07:03, Martin Josefsson wrote:
> BUT if I use the above + prefetching I get this:
> 
> 60      1483890

Ok, proof that we can get to 1.4Mpps!  

That's the good news.

The bad news is prefetching is potentially buggy as pointed out in the
freebsd note.  Buggy as in the controller may hang.  Sorry, I don't have
details on what conditions are necessary to cause a hang.

Would Martin or Lennert run these test for a longer duration so we can
get some data, maybe adding in Rx.  It could be that removing the Tx
interrupts and descriptor write-backs, prefetching may be ok.  I don't
know.  Intel?

Also, wouldn't it be great if someone wrote a document capturing all of
the accumulated knowledge for future generations?

-scott
