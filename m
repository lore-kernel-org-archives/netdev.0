From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 1.03Mpps on e1000 (was: Re: [E1000-devel] Transmission limit)
Date: Sun, 5 Dec 2004 18:01:43 +0100 (CET)
Message-ID: <Pine.LNX.4.58.0412051755370.29474@tux.rsn.bth.se>
References: <1101499285.1079.45.camel@jzny.localdomain>
 <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain>
 <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain>
 <20041201001107.GE4203@xi.wantstofly.org> <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
 <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org>
 <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org>
 <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se>
 <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se>
 <Pine.LNX.4.58.0412051730010.29474@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Scott Feldman <sfeldma@pobox.com>, jamal <hadi@cyberus.ca>,
        Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <Pine.LNX.4.58.0412051730010.29474@tux.rsn.bth.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 5 Dec 2004, Martin Josefsson wrote:

> I removed the delayed TDT updating and gave it a go again (this is scott +
> prefetching):
>
> 60      1486193
> 64      1267639
> 68      1259682

Yet another mail, I hope you are using a NAPI-enabled MUA :)

This time I tried vanilla + prefetch and it gave pretty nice performance
as well:

60      1308047
64      1076044
68      1079377
72      1058993
76      1055708
80      1025659
84      1024692
88      1024236
92      1024510
96      1012853
100     1007925
104     976500
108     947061
112     919169
116     892804
120     868084
124     844609
128     822381

Large gap between 60 and 64byte, maybe the prefetching only prefetches
32bytes at a time?

As a reference: here's a completely vanilla e1000 driver:

60      860931
64      772949
68      754738
72      754200
76      756093
80      756398
84      742111
88      738120
92      740426
96      739720
100     722322
104     729287
108     719312
112     723171
116     705551
120     704843
124     704622
128     665863

/Martin
