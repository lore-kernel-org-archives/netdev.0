From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 12/18] bnx2x: BCM8705 has no microcode
Date: Mon, 02 Mar 2009 20:00:10 +0200
Message-ID: <1236016810.7723.83.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4409 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755853AbZCBSBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 12/18] bnx2x: BCM8705 has no microcode

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 280f008..c72a964 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3033,10 +3033,9 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       MDIO_WIS_DEVAD,
 				       MDIO_WIS_REG_LASI_CNTL, 0x1);
 
-			bnx2x_save_bcm_spirom_ver(bp, params->port,
-						ext_phy_type,
-						ext_phy_addr,
-						params->shmem_base);
+			/* BCM8705 doesn't have microcode, hence the 0 */
+			bnx2x_save_spirom_version(bp, params->port,
+						params->shmem_base, 0);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-- 
1.5.4.3




