From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 03/10] bnx2x: Miscellaneous debug print and tabs
Date: Thu, 5 Nov 2009 19:18:10 +0200
Message-ID: <1257441490.3390.50.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2641 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbZKEPSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index eabdd11..bf1021e 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1350,6 +1350,7 @@ static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
 
 static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u16 *ieee_fc)
 {
+	struct bnx2x *bp = params->bp;
 	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
 	/* resolve pause mode and advertisement
 	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
@@ -1379,6 +1380,7 @@ static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u16 *ieee_fc)
 		*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
 		break;
 	}
+	DP(NETIF_MSG_LINK, "ieee_fc = 0x%x\n", *ieee_fc);
 }
 
 static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
@@ -6143,7 +6145,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 			     offsetof(struct shmem_region, dev_info.
 				      port_feature_config[params->port].
 				      config));
-
+	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
 	/* disable attentions */
 	vars->link_status = 0;
 	bnx2x_update_mng(params, vars->link_status);
-- 
1.6.5.2




