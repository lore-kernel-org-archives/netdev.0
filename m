From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: reduce OOM risk on arches with large pages
Date: Mon, 20 Feb 2017 10:32:02 -0500 (EST)
Message-ID: <20170220.103202.2232789170855833380.davem@davemloft.net>
References: <1487442858.1311.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753759AbdBTPcK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:32:10 -0500
In-Reply-To: <1487442858.1311.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 Feb 2017 10:34:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Since mlx4 NIC are used on PowerPC with 64K pages, we need to adapt
> MLX4_EN_ALLOC_PREFER_ORDER definition.
> 
> Otherwise, a fragment sitting in an out of order TCP queue can hold
> 0.5 Mbytes and it is a serious OOM risk.
> 
> Fixes: 51151a16a60f ("mlx4: allow order-0 memory allocations in RX path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
