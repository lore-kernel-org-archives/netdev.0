From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Sun, 13 Jun 2010 14:43:05 +0300
Message-ID: <1276429385.13056.13.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4686 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242Ab0FMJme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jun 2010 05:42:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change 2wire transfer rate of SFP+ module EEPROM from 400Khz to 100Khz since some DACs(direct attached cables) do not work at 400Khz.

Reported-by: Krzysztof Oldzki <ole@ans.pl>
Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index a22a7e0..9b15b64 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4274,7 +4274,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_addr,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
-				       0xa001);
+				       0xa101);
 
 			/* Set TX PreEmphasis if needed */
 			if ((params->feature_config_flags &



