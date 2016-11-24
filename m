From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Free netdev resources under state lock
Date: Wed, 23 Nov 2016 20:28:11 -0500 (EST)
Message-ID: <20161123.202811.693262110451124399.davem@davemloft.net>
References: <1479824439-27353-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com,
        sagi@grimberg.me, bblanco@plumgrid.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41958 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935138AbcKXB2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:28:14 -0500
In-Reply-To: <1479824439-27353-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Tue, 22 Nov 2016 16:20:39 +0200

> Make sure mlx4_en_free_resources is called under the netdev state lock.
> This is needed since RCU dereference of XDP prog should be protected.
> 
> Fixes: 326fe02d1ed6 ("net/mlx4_en: protect ring->xdp_prog with rcu_read_lock")
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Reported-by: Sagi Grimberg <sagi@grimberg.me>

Applied.
