From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 10/10] bnxt: Adding num MSI-X vectors per VF perm config param
Date: Tue, 24 Oct 2017 16:12:42 -0400
Message-ID: <1508875962-39233-11-git-send-email-steven.lin1@broadcom.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58388 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751858AbdJXUNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:47 -0400
In-Reply-To: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding permanent config parameter for number MSI-X vectors
per VF, using devlink API for get/set operation.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index c6e670c..620a207 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -22,6 +22,8 @@
  *   # of VFs per PF in SR-IOV mode
  * DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT:
  *   Max # of MSI-X vectors per PF
+ * DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF:
+ *   # of MSI-X vectors per VF
  */
 struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
 	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
@@ -30,6 +32,8 @@ struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
 		BNXT_DRV_APPL_FUNCTION, 8, 404},
 	{DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT, BNXT_DRV_PF,
 		BNXT_DRV_APPL_SHARED, 10, 108},
+	{DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF, BNXT_DRV_PF,
+		BNXT_DRV_APPL_FUNCTION, 10, 406},
 };
 
 #define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
-- 
2.7.4
