From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/3] atl1e: Remove redundant definitions of ethtool
 operations
Date: Wed, 02 Dec 2009 05:10:03 +0000
Message-ID: <1259730603.21651.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jie Yang <jie.yang@atheros.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52305 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbZLBFKA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 00:10:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions provide the default behaviour and do not need to be
set in struct ethtool_ops.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/atl1e/atl1e_ethtool.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index b0fb725..bb15c51 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -131,11 +131,6 @@ static int atl1e_set_settings(struct net_device *netdev,
 	return 0;
 }
 
-static u32 atl1e_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) != 0;
-}
-
 static u32 atl1e_get_msglevel(struct net_device *netdev)
 {
 #ifdef DBG
@@ -393,13 +388,8 @@ static const struct ethtool_ops atl1e_ethtool_ops = {
 	.get_eeprom_len         = atl1e_get_eeprom_len,
 	.get_eeprom             = atl1e_get_eeprom,
 	.set_eeprom             = atl1e_set_eeprom,
-	.get_tx_csum            = atl1e_get_tx_csum,
 	.set_tx_csum            = ethtool_op_set_tx_hw_csum,
-	.get_sg                 = ethtool_op_get_sg,
 	.set_sg                 = ethtool_op_set_sg,
-#ifdef NETIF_F_TSO
-	.get_tso                = ethtool_op_get_tso,
-#endif
 	.set_tso                = ethtool_op_set_tso,
 };
 
-- 
1.6.5.3



