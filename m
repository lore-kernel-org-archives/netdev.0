From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 05/36] bnx2x: Advertize flow control normally in MF
 mode
Date: Wed, 12 Aug 2009 21:22:13 +0300
Message-ID: <1250101333.27379.156.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2422 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbZHLSXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 442ba61..47b687b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2148,9 +2148,7 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		/* Initialize link parameters structure variables */
 		/* It is recommended to turn off RX FC for jumbo frames
 		   for better performance */
-		if (IS_E1HMF(bp))
-			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
-		else if (bp->dev->mtu > 5000)
+		if (bp->dev->mtu > 5000)
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_TX;
 		else
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
-- 
1.5.4.3




