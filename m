From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx5e: Do not recycle pages from emergency
 reserve
Date: Fri, 20 Jan 2017 12:43:01 -0500 (EST)
Message-ID: <20170120.124301.1228899617504374421.davem@davemloft.net>
References: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34312 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751328AbdATRnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:43:03 -0500
In-Reply-To: <1484809388.16328.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jan 2017 23:03:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> A driver using dev_alloc_page() must not reuse a page allocated from
> emergency memory reserve.
> 
> Otherwise all packets using this page will be immediately dropped,
> unless for very specific sockets having SOCK_MEMALLOC bit set.
> 
> This issue might be hard to debug, because only a fraction of received
> packets would be dropped.
> 
> Fixes: 4415a0319f92 ("net/mlx5e: Implement RX mapped page cache for page recycle")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
