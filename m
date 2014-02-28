From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 5/9] net/mlx4: Replace mlx4_en_mac_to_u64()
 with mlx4_mac_to_u64()
Date: Fri, 28 Feb 2014 17:01:21 -0500 (EST)
Message-ID: <20140228.170121.2244386983838443557.davem@davemloft.net>
References: <1393567209-16358-1-git-send-email-amirv@mellanox.com>
	<1393567209-16358-6-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbaB1WBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 17:01:23 -0500
In-Reply-To: <1393567209-16358-6-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Fri, 28 Feb 2014 08:00:05 +0200

> +#ifndef ETH_ALEN
> +#define ETH_ALEN       6
> +#endif

There is no valid circumstance where this is necessary.

Please remove this.
