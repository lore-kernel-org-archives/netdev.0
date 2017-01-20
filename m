From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: support __GFP_MEMALLOC for rx
Date: Thu, 19 Jan 2017 23:36:34 -0500 (EST)
Message-ID: <20170119.233634.805237080507453193.davem@davemloft.net>
References: <1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khlebnikov@yandex-team.ru,
        tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdATEiS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 23:38:18 -0500
In-Reply-To: <1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2017 20:14:10 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 04aeb56a1732 ("net/mlx4_en: allocate non 0-order pages for RX
> ring with __GFP_NOMEMALLOC") added code that appears to be not needed at
> that time, since mlx4 never used __GFP_MEMALLOC allocations anyway.
> 
> As using memory reserves is a must in some situations (swap over NFS or
> iSCSI), this patch adds this flag.
> 
> Note that this driver does not reuse pages (yet) so we do not have to
> add anything else.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
