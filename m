From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/2] net/mlx4: Mellanox driver update
 01-01-2014
Date: Mon, 24 Feb 2014 18:38:50 -0500 (EST)
Message-ID: <20140224.183850.2079183585046204056.davem@davemloft.net>
References: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yevgenyp@mellanox.com,
	netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaBXXiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 18:38:52 -0500
In-Reply-To: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Fri, 21 Feb 2014 12:39:16 +0200

> This small patchset has a fix to a bogus usage of
> netif_get_num_default_rss_queues() in mlx4_en driver.
> 
> Changes from V1:
> - Removed affinity_hint patch, to make it a generic instead of mlx specific
> 
> Changes from V0:
> - Instead of reverting the netif_get_num_default_rss_queues() in mlx4_en,
>   fixing it to limit the actual number of receive queues instead of limiting
>   the number of IRQ's.
> 
> Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
> errors with assignment in if condition"

Series applied, thanks.
