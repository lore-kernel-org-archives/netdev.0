From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2 3/4] devlink: Update devlink UAPI file
Date: Thu,  7 Sep 2017 17:26:42 +0300
Message-ID: <1504794403-45690-4-git-send-email-arkadis@mellanox.com>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40356 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755305AbdIGOYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:24:07 -0400
In-Reply-To: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update devlink UAPI file.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/devlink.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/devlink.h b/include/linux/devlink.h
index 7644005..a62695e 100644
--- a/include/linux/devlink.h
+++ b/include/linux/devlink.h
@@ -226,4 +226,22 @@ enum devlink_dpipe_action_type {
 	DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY,
 };
 
+enum devlink_dpipe_field_ethernet_id {
+	DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
+};
+
+enum devlink_dpipe_field_ipv4_id {
+	DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
+};
+
+enum devlink_dpipe_field_ipv6_id {
+	DEVLINK_DPIPE_FIELD_IPV6_DST_IP,
+};
+
+enum devlink_dpipe_header_id {
+	DEVLINK_DPIPE_HEADER_ETHERNET,
+	DEVLINK_DPIPE_HEADER_IPV4,
+	DEVLINK_DPIPE_HEADER_IPV6,
+};
+
 #endif /* _LINUX_DEVLINK_H_ */
-- 
2.4.11
