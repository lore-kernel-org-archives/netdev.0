From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Wed, 8 Dec 2004 16:36:18 -0700
Message-ID: <20041208233617.GD8649@mail.com>
References: <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hello martin


On Sun, Dec 05, 2004 at 04:42:34PM +0100, Martin Josefsson wrote:
> 
> Here's the patch, not much more tested (it still gives some transmit
> timeouts since it's scotts patch + prefetching and delayed TDT updating).
> And it's not cleaned up, but hey, that's development :)
> 
> The delayed TDT updating was a test and currently it delays the first tx'd
> packet after a timerrun 1ms.
> 
> Would be interesting to see what other people get with this thing.
> Lennert?

well, i'm brand new to gig ethernet, but i have access to some nice
hardware right now, so i decided to give your patch a try.

this is the average tx pps of 10 pktgen runs for each packet size:
	
60	1187589.1
64	 601805.4
68	1115029.3
72	 593096.4
76	1097761.1
80	 587125.4
84	1098045.2
88	 588159.1
92	1072124.8
96	 582510.3
100	1008056.8
104	 577898.0
108	 946974.0
112	 573719.2
116	 892871.0
120	 573072.5
124	 844608.3
128	 563685.7


any idea why the packet rates are cut in half for every other line?

pktgen is running with eth0 bound to CPU0 on this box:

  NexGate NSA 2040G
  Dual Xeon 3.06 GHz, HT enabled
  1 GB PC3200 DDR SDRAM
  Dual 82544EI
  - on PCI-X 64 bit 133 MHz bus
  - behind P64H2 bridge
  - on hub channel D of E7501 chipset



thanks

-- 
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
