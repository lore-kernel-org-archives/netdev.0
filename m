From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] net/mlx4_en: Fix TX moderation info
 loss after set_ringparam is called
Date: Sun, 02 Dec 2012 20:23:23 -0500 (EST)
Message-ID: <20121202.202323.1470060600296021767.davem@davemloft.net>
References: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
	<1354456163-10497-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, ogerlitz@mellanox.com,
	oren@mellanox.com, netdev@vger.kernel.org
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab2LCBXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 20:23:24 -0500
In-Reply-To: <1354456163-10497-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  2 Dec 2012 15:49:22 +0200

> We need to re-set tx moderation information after calling set_ringparam
> else default tx moderation will be used.
> Also avoid related code duplication, by putting it in a utility function.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied.
