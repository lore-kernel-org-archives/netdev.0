From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [rfc, netfilter-next] netfilter: nf_tables: fib warnings
Date: Fri, 28 Oct 2016 22:23:25 +0200
Message-ID: <2411822.e3j1Y723En@wuerfel>
References: <20161028153124.3773180-1-arnd@arndb.de> <18995804.9DSMHNUO14@wuerfel> <20161028162149.GA23891@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161028162149.GA23891@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 28, 2016 6:21:49 PM CEST Florian Westphal wrote:
> Good point.  In case oif is NULL we don't have to search the result
> list for a match anyway, so we could do this (not even build tested):
> 

It didn't apply cleanly, but I've integrated it with the change to
initialize oif to NULL and the added #ifdef I had in my first version
and got a clean build.

I sent out a v2 now, but didn't try hard to understand your changes.

	Arnd
