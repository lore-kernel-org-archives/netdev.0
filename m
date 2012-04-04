From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 07/10] bnx2x: Fix BCM84833 PHY FW version presentation
Date: Wed, 4 Apr 2012 14:29:00 +0300
Message-ID: <1333538942-9904-8-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2063 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756110Ab2DDJ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:39 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 732b4c8..b576a3a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9435,8 +9435,7 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD, 0x400f, &fw_ver1);
-		bnx2x_save_spirom_version(bp, port,
-				((fw_ver1 & 0xf000)>>5) | (fw_ver1 & 0x7f),
+		bnx2x_save_spirom_version(bp, port, fw_ver1 & 0xfff,
 				phy->ver_addr);
 	} else {
 		/* For 32-bit registers in 848xx, access via MDIO2ARM i/f. */
-- 
1.7.7.1
