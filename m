From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4: Mellanox driver update
 01-01-2014
Date: Wed, 19 Feb 2014 16:50:49 -0500 (EST)
Message-ID: <20140219.165049.1684072721398326970.davem@davemloft.net>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbaBSVuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:50:51 -0500
In-Reply-To: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed, 19 Feb 2014 14:58:01 +0200

> V0 of this patch was sent before previous net-next got closed, and
> now we would like to resume it.
> 
> Yuval has reworked the affinity hint patch, according to Ben's comments. The
> patch was actually rewritten.
> After a discussion with Yuval Mintz, use of netif_get_num_default_rss_queues()
> is not reverted, but done in the right place. Instead of limiting the number of
> IRQ's for the driver it will limit the number of queues in RSS.
> 
> Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
> errors with assignment in if condition"

Influencing IRQs to be allocated on the same NUMA code as the one where
the card resides doesn't sound like an mlx4 specific desire to me.

Other devices, both networking and non-networking, probably might like
that as well.

Therefore doing this by hand in a specific driver doesn't seem
appropriate at all.
