From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 08/10] bnxt: Adding num VFs per PF perm config param
Date: Tue, 24 Oct 2017 16:12:40 -0400
Message-ID: <1508875962-39233-9-git-send-email-steven.lin1@broadcom.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58387 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751857AbdJXUNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:47 -0400
In-Reply-To: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding permanent config parameter for number of VFs per PF,
using devlink API for get/set operation.

Value sets the number of VFs per PF in SR-IOV mode.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index 6eb80c1..55913c4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -18,10 +18,14 @@
  * DEVLINK_PERM_CONFIG_SRIOV_ENABLED:
  *   0 = disable SR-IOV
  *   1 = enable SR-IOV
+ * DEVLINK_PERM_CONFIG_NUM_VF_PER_PF:
+ *   # of VFs per PF in SR-IOV mode
  */
 struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
 	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
 		BNXT_DRV_APPL_SHARED, 1, 401},
+	{DEVLINK_PERM_CONFIG_NUM_VF_PER_PF, BNXT_DRV_PF,
+		BNXT_DRV_APPL_FUNCTION, 8, 404},
 };
 
 #define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
-- 
2.7.4
