From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 07/11] net/mlx4_en: Add prints when TX timeout
 occurs
Date: Thu, 20 Jun 2013 12:55:05 -0700
Message-ID: <1371758105.2146.39.camel@joe-AO722>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
	 <1371757222-21412-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41035 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161110Ab3FTTzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:55:10 -0400
In-Reply-To: <1371757222-21412-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-20 at 22:40 +0300, Amir Vadai wrote:
> From: Yevgeny Petrilin <yevgenyp@mellanox.com>
> 
> Debug prints when a TX timeout is detected
[]
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
[]
> @@ -1236,10 +1236,21 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
[]
> +	for (i = 0; i < priv->tx_ring_num; i++) {
> +		if (!netif_tx_queue_stopped(netdev_get_tx_queue(dev, i)))
> +			continue;
> +		en_info(priv, "TX timeout detected on queue: %d,\n"
> +			"QP: 0x%x, CQ: 0x%x,\n"
> +			"Cons index: 0x%x, Prod index: 0x%x\n", i,

Not at dbg level and probably better on a single line.
