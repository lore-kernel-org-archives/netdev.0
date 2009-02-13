From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/6] mv643xx_eth: allow enabling/disabling tx checksumming via ethtool
Date: Fri, 13 Feb 2009 01:08:07 +0100
Message-ID: <20090213000807.GO17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:43009 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904AbZBMAII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:08:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index c998a7c..26de19b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1606,6 +1606,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.set_ringparam		= mv643xx_eth_set_ringparam,
 	.get_rx_csum		= mv643xx_eth_get_rx_csum,
 	.set_rx_csum		= mv643xx_eth_set_rx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings		= mv643xx_eth_get_strings,
 	.get_ethtool_stats	= mv643xx_eth_get_ethtool_stats,
-- 
1.5.6.4
