From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: compute a more reasonable default ip6_rt_max_size
Date: Sat, 26 May 2012 05:39:40 +0200
Message-ID: <1338003580.10135.6.camel@edumazet-glaptop>
References: <4FC0063E.8080209@fb.com>
	 <20120525.185131.2017517041016424794.davem@davemloft.net>
	 <4FC01F1B.1080009@fb.com>
	 <20120525.201150.1782581593120395710.davem@davemloft.net>
	 <4FC02777.5070003@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC02777.5070003@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-25 at 17:44 -0700, Arun Sharma wrote:
> On 5/25/12 5:11 PM, David Miller wrote:
> 
> >> These were not admin configured routes. They were discovered via ipv6
> >> neighbor discovery.
> >
> > Then such default routes should either be:
> >
> > 1) Passed over by GC
> >
> > 2) Trigger neighbour discovery when GC'd
> 
> It's possible that there is a bug somewhere - we didn't get a chance to 
> dig deeper. What we observed is that as we got close to the 4096 limit, 
> some hosts were becoming unreachable. A modest increase in the routing 
> table size made things better.
> 
>   -Arun

But your patch is not a  "modest increase", so whats the deal ?

A modest increase would be 8192 instead of 4096, regardless of RAM size.
