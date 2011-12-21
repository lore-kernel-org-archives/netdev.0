From: David Miller <davem@davemloft.net>
Subject: Re: Kernel-DOS error in arp mechanism
 =?iso-2022-jp-3?B?GyQoUSN8GyhC?= no delete off incomplete arp adresses
Date: Wed, 21 Dec 2011 15:47:34 -0500 (EST)
Message-ID: <20111221.154734.248295514779001007.davem@davemloft.net>
References: <1324453467.2610.20.camel@edumazet-laptop>
	<20111221.030727.1528369698756365464.davem@davemloft.net>
	<1324461072.2728.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, gladewitz@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324461072.2728.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 10:51:12 +0100

> [PATCH] ipv4: reintroduce route cache garbage collector
> 
> Commit 2c8cec5c10b (ipv4: Cache learned PMTU information in inetpeer)
> removed IP route cache garbage collector a bit too soon, as this gc was
> responsible for expired routes cleanup, releasing their neighbour
> reference.
> 
> As pointed out by Robert Gladewitz, recent kernels can fill and exhaust
> their neighbour cache.
> 
> Reintroduce the garbage collection, since we'll have to wait our
> neighbour lookups become refcount-less to not depend on this stuff.
> 
> Reported-by: Robert Gladewitz <gladewitz@gmx.de>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
