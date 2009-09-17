From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE] new iptables module match large amount of ip
 addresses
Date: Fri, 18 Sep 2009 01:33:39 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0909180130110.20781@obet.zrqbmnf.qr>
References: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz> <alpine.LSU.2.00.0909180046410.20781@obet.zrqbmnf.qr> <Pine.LNX.4.64.0909180054410.21427@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0909180054410.21427@artax.karlin.mff.cuni.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2009-09-18 01:01, Mikulas Patocka wrote:
>> On Thursday 2009-09-17 21:15, Mikulas Patocka wrote:
>> >
>> >Here I submit an iptables module that can match large amounts (millions) 
>> >of ip addresses efficiently using binary search.
>> 
>> So you just reinvented xt_geoip...
>
>I am wondering, if there are two approaches for matching large amounts of 
>addresses (xt_geoip and ipset), why is none of them in the kernel?

Because, so I would estimate, Patrick would decline patches with the 
reasoning of redundant code. Especially so "IPMARK".

>I was saying how OpenBSD is better than Linux because OpenBSD has 
>tree-based firewall tables --- hmm --- well --- Linux has them too, except 
>that noone can really find them because they are not in the kernel.

You can build trees of chains with iptables. (Which would be quite a 
fast thing if you do not have modules at hand.)

