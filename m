From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v2 5/6] devlink: Adding num MSI-X vectors per VF NVRAM config param
Date: Thu, 19 Oct 2017 15:17:09 -0400
Message-ID: <1508440630-25830-6-git-send-email-steven.lin1@broadcom.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:42590 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751969AbdJSTR2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:17:28 -0400
In-Reply-To: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF permanent config
parameter.  Defines number of MSI-X vectors allocated per VF.
Value is permanent (stored in NVRAM), so becomes the new default
value for this device.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 8ad6c63..ef163b6 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -260,6 +260,7 @@ enum devlink_perm_config_param {
 	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
 	DEVLINK_PERM_CONFIG_NUM_VF_PER_PF,
 	DEVLINK_PERM_CONFIG_MAX_NUM_PF_MSIX_VECT,
+	DEVLINK_PERM_CONFIG_MSIX_VECTORS_PER_VF,
 };
 
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
-- 
2.7.4
