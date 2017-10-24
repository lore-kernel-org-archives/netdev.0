From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v3 07/10] bnxt: Adding SR-IOV enablement permanent cfg param
Date: Tue, 24 Oct 2017 16:12:39 -0400
Message-ID: <1508875962-39233-8-git-send-email-steven.lin1@broadcom.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com, yuvalm@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:58380 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751833AbdJXUNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:13:47 -0400
In-Reply-To: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding permanent config parameter for SR-IOV enablement, using
devlink API for get/set operation.

0 = SR-IOV disabled
1 = SR-IOV enabled

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index 81ab77e..6eb80c1 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -14,7 +14,14 @@
 #include "bnxt_vfr.h"
 #include "bnxt_devlink.h"
 
+/* Permanent config parameters from devlink.h:
+ * DEVLINK_PERM_CONFIG_SRIOV_ENABLED:
+ *   0 = disable SR-IOV
+ *   1 = enable SR-IOV
+ */
 struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
+	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
+		BNXT_DRV_APPL_SHARED, 1, 401},
 };
 
 #define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
-- 
2.7.4
