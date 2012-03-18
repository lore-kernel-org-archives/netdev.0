From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 5/9] bnx2x: changed initial dcb configuration
Date: Sun, 18 Mar 2012 16:33:41 -0400
Message-ID: <1332102825-7838-6-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1278 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822Ab2CRNsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:25 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

The changes were mostly made to enable back-to-back data flow with dcb.
Other changes were simply deemed as a better 'clean' initial configuration.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   45 ++++++++---------------
 1 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 87560f6..fafbc00 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -923,30 +923,30 @@ void bnx2x_dcbx_init_params(struct bnx2x *bp)
 	bp->dcbx_config_params.admin_application_priority_tx_enable = 1;
 	bp->dcbx_config_params.admin_ets_reco_valid = 1;
 	bp->dcbx_config_params.admin_app_priority_willing = 1;
-	bp->dcbx_config_params.admin_configuration_bw_precentage[0] = 00;
-	bp->dcbx_config_params.admin_configuration_bw_precentage[1] = 50;
-	bp->dcbx_config_params.admin_configuration_bw_precentage[2] = 50;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[0] = 100;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[1] = 0;
+	bp->dcbx_config_params.admin_configuration_bw_precentage[2] = 0;
 	bp->dcbx_config_params.admin_configuration_bw_precentage[3] = 0;
 	bp->dcbx_config_params.admin_configuration_bw_precentage[4] = 0;
 	bp->dcbx_config_params.admin_configuration_bw_precentage[5] = 0;
 	bp->dcbx_config_params.admin_configuration_bw_precentage[6] = 0;
 	bp->dcbx_config_params.admin_configuration_bw_precentage[7] = 0;
-	bp->dcbx_config_params.admin_configuration_ets_pg[0] = 1;
+	bp->dcbx_config_params.admin_configuration_ets_pg[0] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[1] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[2] = 0;
-	bp->dcbx_config_params.admin_configuration_ets_pg[3] = 2;
+	bp->dcbx_config_params.admin_configuration_ets_pg[3] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[4] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[5] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[6] = 0;
 	bp->dcbx_config_params.admin_configuration_ets_pg[7] = 0;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[0] = 0;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[1] = 1;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[2] = 2;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[0] = 100;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[1] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[2] = 0;
 	bp->dcbx_config_params.admin_recommendation_bw_precentage[3] = 0;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[4] = 7;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[5] = 5;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[6] = 6;
-	bp->dcbx_config_params.admin_recommendation_bw_precentage[7] = 7;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[4] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[5] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[6] = 0;
+	bp->dcbx_config_params.admin_recommendation_bw_precentage[7] = 0;
 	bp->dcbx_config_params.admin_recommendation_ets_pg[0] = 0;
 	bp->dcbx_config_params.admin_recommendation_ets_pg[1] = 1;
 	bp->dcbx_config_params.admin_recommendation_ets_pg[2] = 2;
@@ -955,25 +955,12 @@ void bnx2x_dcbx_init_params(struct bnx2x *bp)
 	bp->dcbx_config_params.admin_recommendation_ets_pg[5] = 5;
 	bp->dcbx_config_params.admin_recommendation_ets_pg[6] = 6;
 	bp->dcbx_config_params.admin_recommendation_ets_pg[7] = 7;
-	bp->dcbx_config_params.admin_pfc_bitmap = 0x8; /* FCoE(3) enable */
-	bp->dcbx_config_params.admin_priority_app_table[0].valid = 1;
-	bp->dcbx_config_params.admin_priority_app_table[1].valid = 1;
+	bp->dcbx_config_params.admin_pfc_bitmap = 0x0;
+	bp->dcbx_config_params.admin_priority_app_table[0].valid = 0;
+	bp->dcbx_config_params.admin_priority_app_table[1].valid = 0;
 	bp->dcbx_config_params.admin_priority_app_table[2].valid = 0;
 	bp->dcbx_config_params.admin_priority_app_table[3].valid = 0;
-	bp->dcbx_config_params.admin_priority_app_table[0].priority = 3;
-	bp->dcbx_config_params.admin_priority_app_table[1].priority = 0;
-	bp->dcbx_config_params.admin_priority_app_table[2].priority = 0;
-	bp->dcbx_config_params.admin_priority_app_table[3].priority = 0;
-	bp->dcbx_config_params.admin_priority_app_table[0].traffic_type = 0;
-	bp->dcbx_config_params.admin_priority_app_table[1].traffic_type = 1;
-	bp->dcbx_config_params.admin_priority_app_table[2].traffic_type = 0;
-	bp->dcbx_config_params.admin_priority_app_table[3].traffic_type = 0;
-	bp->dcbx_config_params.admin_priority_app_table[0].app_id = 0x8906;
-	bp->dcbx_config_params.admin_priority_app_table[1].app_id = 3260;
-	bp->dcbx_config_params.admin_priority_app_table[2].app_id = 0;
-	bp->dcbx_config_params.admin_priority_app_table[3].app_id = 0;
-	bp->dcbx_config_params.admin_default_priority =
-		bp->dcbx_config_params.admin_priority_app_table[1].priority;
+	bp->dcbx_config_params.admin_default_priority = 0;
 }
 
 void bnx2x_dcbx_init(struct bnx2x *bp)
-- 
1.7.9.rc2
