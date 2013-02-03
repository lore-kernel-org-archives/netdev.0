From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_en: Fixed compilation error when CONFIG_INET
 isn't defined
Date: Sun, 03 Feb 2013 16:02:55 -0500 (EST)
Message-ID: <20130203.160255.277019348628513228.davem@davemloft.net>
References: <1359894819-18794-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadarh@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595Ab3BCVC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 16:02:57 -0500
In-Reply-To: <1359894819-18794-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  3 Feb 2013 14:33:39 +0200

> ip_eth_mc_map function can't be used when CONFIG_INET isn't defined.
> Fixed compilation error by adding CONFIG_INET define check before using the
> function.

That's not the only thing this patch is doing, in fact it isn't even
the majority of the patch.

The majority of the patch is the error propagation and memory freeing
fixes.

Don't submit changes like this, please.
