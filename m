From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/13] mlx4: order-0 allocations and page
 recycling
Date: Thu, 09 Mar 2017 09:59:55 -0800 (PST)
Message-ID: <20170309.095955.966397253795759795.davem@davemloft.net>
References: <20170308161718.2867-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com,
        willemb@google.com, brouer@redhat.com, ast@kernel.org,
        eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754890AbdCISAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 13:00:19 -0500
In-Reply-To: <20170308161718.2867-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  8 Mar 2017 08:17:05 -0800

> As mentioned half a year ago, we better switch mlx4 driver to order-0
> allocations and page recycling.
> 
> This reduces vulnerability surface thanks to better skb->truesize
> tracking and provides better performance in most cases.
> (33 Gbit for one TCP flow on my lab hosts)
> 
> I will provide for linux-4.13 a patch on top of this series,
> trying to improve data locality as described in
> https://www.spinics.net/lists/netdev/msg422258.html
> 
> v2 provides an ethtool -S new counter (rx_alloc_pages) and
> code factorization, plus Tariq fix.
> 
> v3 includes various fixes based on Tariq tests and feedback
> from Saeed and Tariq.
> 
> v4 rebased on net-next for inclusion in linux-4.12, as requested
> by Tariq.
> 
> Worth noting this patch series deletes ~250 lines of code ;)

Series applied, thanks everyone.
