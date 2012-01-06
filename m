From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/3] bcm63xx: make ethtool_ops const
Date: Thu, 05 Jan 2012 21:10:24 -0800
Message-ID: <20120106051051.050675760@vyatta.com>
References: <20120106051022.712047093@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:35080 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab2AFFQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jan 2012 00:16:40 -0500
Content-Disposition: inline; filename=broadcom-ethtool-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c	2011-12-07 10:54:18.688278133 -0800
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c	2012-01-04 14:19:01.945391195 -0800
@@ -1469,7 +1469,7 @@ static int bcm_enet_set_pauseparam(struc
 	return 0;
 }
 
-static struct ethtool_ops bcm_enet_ethtool_ops = {
+static const struct ethtool_ops bcm_enet_ethtool_ops = {
 	.get_strings		= bcm_enet_get_strings,
 	.get_sset_count		= bcm_enet_get_sset_count,
 	.get_ethtool_stats      = bcm_enet_get_ethtool_stats,
