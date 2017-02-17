From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Fri, 17 Feb 2017 11:00:59 -0500 (EST)
Message-ID: <20170217.110059.790777908746477501.davem@davemloft.net>
References: <20170213195858.5215-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, kafai@fb.com,
        saeedm@mellanox.com, willemb@google.com, brouer@redhat.com,
        bblanco@plumgrid.com, ast@kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934037AbdBQQBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:01:11 -0500
In-Reply-To: <20170213195858.5215-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 13 Feb 2017 11:58:44 -0800

> As mentioned half a year ago, we better switch mlx4 driver to order-0
> allocations and page recycling.
> 
> This reduces vulnerability surface thanks to better skb->truesize
> tracking and provides better performance in most cases.
> 
> v2 provides an ethtool -S new counter (rx_alloc_pages) and
> code factorization, plus Tariq fix.
> 
> v3 includes various fixes based on Tariq tests and feedback
> from Saeed and Tariq.
> 
> Worth noting this patch series deletes ~250 lines of code ;)

I think this should get queued up for net-next soon, but I marked the
series as "deferred" in patchwork while the discussion continues.
