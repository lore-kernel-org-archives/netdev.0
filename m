From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: Re: [ANNOUNCE] new iptables module match large amount of ip addresses
Date: Fri, 18 Sep 2009 01:01:22 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909180054410.21427@artax.karlin.mff.cuni.cz>
References: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
 <alpine.LSU.2.00.0909180046410.20781@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0909180046410.20781@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 18 Sep 2009, Jan Engelhardt wrote:

> On Thursday 2009-09-17 21:15, Mikulas Patocka wrote:
> >
> >Here I submit an iptables module that can match large amounts (millions) 
> >of ip addresses efficiently using binary search.
> 
> So you just reinvented xt_geoip...

I am wondering, if there are two approaches for matching large amounts of 
addresses (xt_geoip and ipset), why is none of them in the kernel?

I was saying how OpenBSD is better than Linux because OpenBSD has 
tree-based firewall tables --- hmm --- well --- Linux has them too, except 
that noone can really find them because they are not in the kernel.

> >- fast matching of large amount of ip addresses using binary search.
> >- an ability to match ranges of addresses or address/mask subnets.
> >- fast loading of the addresses (on Pentium 3 850, 2 million addresses 
> >load in 5.5s, if they are already sorted in the file, the load time is 
> >just 1.5s).
> >- memory efficient --- consumes only 8 bytes per address.
> 
> xt_geoip uses less than that -- 8 bytes per range. Of course it depends 
> on the data, but on the average, since large netblocks is used, it's 
> much better than 8 per address.

My code uses 8 bytes per range too, not really per address.

Mikulas
