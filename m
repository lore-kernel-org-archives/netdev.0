From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] bcm63xx_enet: Use ARRAY_SIZE instead of open coding it
Date: Wed, 23 Apr 2014 19:42:50 +0200
Message-ID: <1398274970-8882-1-git-send-email-tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:42632 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219AbaDWRr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 13:47:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the ARRAY_SIZE macro to determine the number of entries in
bcm_enet_gstrings_stats.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a7d11f5..8db34d3 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1315,8 +1315,7 @@ static const struct bcm_enet_stats bcm_enet_gstrings_stats[] = {
 
 };
 
-#define BCM_ENET_STATS_LEN	\
-	(sizeof(bcm_enet_gstrings_stats) / sizeof(struct bcm_enet_stats))
+#define BCM_ENET_STATS_LEN	ARRAY_SIZE(bcm_enet_gstrings_stats)
 
 static const u32 unused_mib_regs[] = {
 	ETH_MIB_TX_ALL_OCTETS,
-- 
1.7.9.5
