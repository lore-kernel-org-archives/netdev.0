From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net/mlx4_en: allow setting number of rx rings for
 RSS/TCP
Date: Tue, 15 Nov 2011 16:49:24 -0500 (EST)
Message-ID: <20111115.164924.433752545055710503.davem@davemloft.net>
References: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
	<1321348446-29605-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oren@mellanox.com, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, amirv@mellanox.co.il
To: amirv@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588Ab1KOVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:49:40 -0500
In-Reply-To: <1321348446-29605-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@dev.mellanox.co.il>
Date: Tue, 15 Nov 2011 11:14:04 +0200

> +	if (priv->mdev->profile.tcp_rss == -1 ||
> +			priv->mdev->profile.tcp_rss > priv->rx_ring_num)

Please format your code properly:

	if (priv->mdev->profile.tcp_rss == -1 ||
	    priv->mdev->profile.tcp_rss > priv->rx_ring_num)
