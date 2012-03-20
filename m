From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 0/2] Adding new TI Common Platform ethernet SWitch
 driver
Date: Tue, 20 Mar 2012 00:34:32 -0400 (EDT)
Message-ID: <20120320.003432.1209101307544723187.davem@davemloft.net>
References: <1332137874-3247-1-git-send-email-mugunthanvnm@ti.com>
	<20120319.180659.2108026289616852615.davem@davemloft.net>
	<1332216396.22737.29.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab2CTEei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 00:34:38 -0400
In-Reply-To: <1332216396.22737.29.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Mar 2012 21:06:36 -0700

> For an ethernet driver, using eth_change_mtu seems the right thing.

I just tossed that into the tree, as follows:

--------------------
[PATCH] cpsw: Hook up default ndo_change_mtu.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/ti/cpsw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c68c9d9..6685bbb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -665,6 +665,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
 	.ndo_start_xmit		= cpsw_ndo_start_xmit,
 	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
 	.ndo_get_stats		= cpsw_ndo_get_stats,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-- 
1.7.7.6
