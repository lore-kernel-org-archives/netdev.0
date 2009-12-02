From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 3/3] atl1e: Remove non-implementation of ethtool
 set_msglevel() operation
Date: Wed, 02 Dec 2009 05:10:18 +0000
Message-ID: <1259730618.21651.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jie Yang <jie.yang@atheros.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52316 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbZLBFKP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 00:10:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unimplemented operations should not silently fail.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/atl1e/atl1e_ethtool.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index bb15c51..a76006c 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -140,10 +140,6 @@ static u32 atl1e_get_msglevel(struct net_device *netdev)
 #endif
 }
 
-static void atl1e_set_msglevel(struct net_device *netdev, u32 data)
-{
-}
-
 static int atl1e_get_regs_len(struct net_device *netdev)
 {
 	return AT_REGS_LEN * sizeof(u32);
@@ -382,7 +378,6 @@ static const struct ethtool_ops atl1e_ethtool_ops = {
 	.get_wol                = atl1e_get_wol,
 	.set_wol                = atl1e_set_wol,
 	.get_msglevel           = atl1e_get_msglevel,
-	.set_msglevel           = atl1e_set_msglevel,
 	.nway_reset             = atl1e_nway_reset,
 	.get_link               = ethtool_op_get_link,
 	.get_eeprom_len         = atl1e_get_eeprom_len,
-- 
1.6.5.3


