From: Steve Lin <steven.lin1@broadcom.com>
Subject: [PATCH net-next v2 2/6] devlink: Adding SR-IOV enablement NVRAM config param
Date: Thu, 19 Oct 2017 15:17:06 -0400
Message-ID: <1508440630-25830-3-git-send-email-steven.lin1@broadcom.com>
References: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Cc: jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linville@tuxdriver.com, gospo@broadcom.com,
        steven.lin1@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rnd-relay.smtp.broadcom.com ([192.19.229.170]:42565 "EHLO
        rnd-relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751632AbdJSTR1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:17:27 -0400
In-Reply-To: <1508440630-25830-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding DEVLINK_PERM_CONFIG_SRIOV_ENABLED permanent config
parameter.  If value is 1, SR-IOV is enabled.  If value is 0,
SR-IOV is disabled on this device.  Value is permanent (stored
in NVRAM), so becomes the new default value for this device.

Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
Acked-by: Andy Gospodarek <gospo@broadcom.com>
---
 include/uapi/linux/devlink.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 47cc584..2640203 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -255,4 +255,9 @@ enum devlink_dpipe_header_id {
 	DEVLINK_DPIPE_HEADER_IPV6,
 };
 
+/* Permanent (NVRAM) config parameters */
+enum devlink_perm_config_param {
+	DEVLINK_PERM_CONFIG_SRIOV_ENABLED,
+};
+
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
-- 
2.7.4
