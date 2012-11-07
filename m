From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: change TX coalescing defaults
Date: Wed, 07 Nov 2012 15:31:13 -0500 (EST)
Message-ID: <20121107.153113.716743500905191245.davem@davemloft.net>
References: <1352168442.3140.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, j.vimal@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab2KGUbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 15:31:17 -0500
In-Reply-To: <1352168442.3140.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Nov 2012 18:20:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4 currently uses a too high tx coalescing setting, deferring
> TX completion interrupts by up to 128 us.
> 
> With the recent skb_orphan() removal in commit 8112ec3b872,
> performance of a single TCP flow is capped to ~4 Gbps, unless
> we increase tcp_limit_output_bytes.
> 
> I suggest using 16 us instead of 128 us, allowing a finer control.
> 
> Performance of a single TCP flow is restored to previous levels,
> while keeping TCP small queues fully enabled with default sysctl.
> 
> This patch is also a BQL prereq.
> 
> Reported-by: Vimalkumar <j.vimal@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
