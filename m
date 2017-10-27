From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v4 07/10] bnxt: Adding SR-IOV enablement permanent cfg param
Date: Fri, 27 Oct 2017 16:54:11 -0400
Message-ID: <1509137654-1580-8-git-send-email-steven.lin1@broadcom.com>
References: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com, yuvalm@mellanox.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:38559 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932579AbdJ0Uyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:54:35 -0400
In-Reply-To: <1509137654-1580-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding permanent config parameter for SR-IOV enablement, using
devlink API for get/set operation.

DEVLINK_PERM_CONFIG_DISABLE = SR-IOV disabled
DEVLINK_PERM_CONFIG_ENABLE  = SR-IOV enabled

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
index 8a6037f..9f168a8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
@@ -14,7 +14,14 @@
 #include "bnxt_vfr.h"
 #include "bnxt_devlink.h"
 
+/* Permanent config parameters from devlink.h:
+ * DEVLINK_PERM_CONFIG_SRIOV_ENABLED:
+ *   DEVLINK_PERM_CONFIG_DISABLE = disable SR-IOV
+ *   DEVLINK_PERM_CONFIG_ENABLE  = enable SR-IOV
+ */
 struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
+	{DEVLINK_PERM_CONFIG_SRIOV_ENABLED, BNXT_DRV_PF,
+		BNXT_DRV_APPL_SHARED, 1, 401},
 };
 
 #define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
-- 
2.7.4
