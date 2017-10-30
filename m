From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v5 09/10] bnxt: Adding max PF MSI-X vectors perm config param
Date: Mon, 30 Oct 2017 10:46:15 -0400
Message-ID: <1509374776-45869-10-git-send-email-steven.lin1@broadcom.com>
References: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:51679 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751962AbdJ3Oqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 10:46:30 -0400
In-Reply-To: <1509374776-45869-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding permanent config parameter for maximum number of PF
MSI-X vectors.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index 218d18d..ec0f57f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -20,12 +20,16 @@
  *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
  * DEVLINK_PERM_CONFIG_NUM_VF_PER_PF:
  *   # of VFs per PF in SR-IOV mode
+ * DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT:
+ *   Max # of MSI-X vectors per PF
  */
 struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
 	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
 		BNXT_DRV_APPL_SHARED, 1, 401},
 	{DEVLINK_PERM_CONFIG_NUM_VF_PER_PF, BNXT_DRV_PF,
 		BNXT_DRV_APPL_FUNCTION, 8, 404},
+	{DEVLINK_PERM_CONFIG_NUM_PF_MSIX_VECT, BNXT_DRV_PF,
+		BNXT_DRV_APPL_SHARED, 10, 108},
 };
 
 #define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
-- 
2.7.4
