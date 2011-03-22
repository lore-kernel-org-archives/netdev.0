From: David Miller <davem@davemloft.net>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 20:40:17 -0700 (PDT)
Message-ID: <20110321.204017.27801246.davem@davemloft.net>
References: <20110322000130.GC27019@verge.net.au>
	<20110322001706.GD27019@verge.net.au>
	<20110322011801.GE27019@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	a.p.zijlstra@chello.nl, tglx@linutronix.de, arnd@arndb.de,
	penberg@cs.helsinki.fi, ja@ssi.bg, hans@schillstrom.com
To: horms@verge.net.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110322011801.GE27019@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Tue, 22 Mar 2011 10:18:01 +0900

> IPVS: Use global mutex in ip_vs_app.c
> 
> As part of the work to make IPVS network namespace aware
> __ip_vs_app_mutex was replaced by a per-namespace lock,
> ipvs->app_mutex. ipvs->app_key is also supplied for debugging purposes.
> 
> Unfortunately this implementation results in ipvs->app_key residing
> in non-static storage which at the very least causes a lockdep warning.
> 
> This patch takes the rather heavy-handed approach of reinstating
> __ip_vs_app_mutex which will cover access to the ipvs->list_head
> of all network namespaces.
 ...
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks Simon.
