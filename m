From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: export NET_ADDR_* values to user-space API
Date: Fri, 28 Mar 2014 14:25:58 -0700
Message-ID: <1396041958-2471-3-git-send-email-f.fainelli@gmail.com>
References: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:64859 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaC1V0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:26:16 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so5377745pdj.37
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 14:26:16 -0700 (PDT)
In-Reply-To: <1396041958-2471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NET_ADDR_* values are exported in the
/sys/class/net/<iface>/addr_assign_type sysfs attributes, and as such
constitutes an user-space ABI. Move the NET_ADDR_* definitions from
include/linux/netdevice.h to include/uapi/linux/netdevice.h

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/linux/netdevice.h      | 7 -------
 include/uapi/linux/netdevice.h | 6 ++++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 159c7e7945f8..95aab42c4562 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -63,13 +63,6 @@ struct wireless_dev;
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
 
-/* hardware address assignment types */
-#define NET_ADDR_PERM		0	/* address is permanent (default) */
-#define NET_ADDR_RANDOM		1	/* address is generated randomly */
-#define NET_ADDR_STOLEN		2	/* address is stolen from other device */
-#define NET_ADDR_SET		3	/* address is set using
-					 * dev_set_mac_address() */
-
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
 #define NET_RX_DROP		1	/* packet dropped */
diff --git a/include/uapi/linux/netdevice.h b/include/uapi/linux/netdevice.h
index 6b9500bc2d56..fdfbd1c17065 100644
--- a/include/uapi/linux/netdevice.h
+++ b/include/uapi/linux/netdevice.h
@@ -49,5 +49,11 @@ enum {
         IF_PORT_100BASEFX
 };
 
+/* hardware address assignment types */
+#define NET_ADDR_PERM		0	/* address is permanent (default) */
+#define NET_ADDR_RANDOM		1	/* address is generated randomly */
+#define NET_ADDR_STOLEN		2	/* address is stolen from other device */
+#define NET_ADDR_SET		3	/* address is set using
+					 * dev_set_mac_address() */
 
 #endif /* _UAPI_LINUX_NETDEVICE_H */
-- 
1.8.3.2
