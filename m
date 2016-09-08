From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 6/9] net/mlx4_core: Use RCU to perform radix tree
 lookup for SRQ
Date: Thu, 08 Sep 2016 13:36:25 -0700 (PDT)
Message-ID: <20160908.133625.34803140270615515.davem@davemloft.net>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
        <1473324721-5206-7-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, leonro@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758786AbcIHUg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 16:36:26 -0400
In-Reply-To: <1473324721-5206-7-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu,  8 Sep 2016 11:51:58 +0300

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> Radix tree lookup can be performed without locking.
> 
> Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
> Suggested-by: Sagi Grimberg <sagi@grimberg.me>
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Unless this fixes a bug, it isn't appropriate for 'net'.

If it does fix a bug, you have to explain what that bug is and
how this fixes it.
