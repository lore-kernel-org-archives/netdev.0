From: Sven Eckelmann <sven@open-mesh.com>
Subject: [PATCH] bridge: Add missing include for in6_addr
Date: Thu, 18 Apr 2013 11:17:38 +0200
Message-ID: <1366276658-11938-1-git-send-email-sven@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>,
	Sven Eckelmann <sven@open-mesh.com>
To: <bridge@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht2.myhostedexchange.com ([69.50.2.38]:17639 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965787Ab3DRJXC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 05:23:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ee07c6e7a6f8a25c18f0a6b18152fbd7499245f6 ("bridge: export multicast database
via netlink") added "struct br_mdb_entry" which includes an element using the
type "struct in6_addr". The file linux/if_bridge.h is part of the uapi and not
defining this type in this file or its includes causes build failures in
userspace applications.

Signed-off-by: Sven Eckelmann <sven@open-mesh.com>
---
 include/uapi/linux/if_bridge.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 2d70d79..8e3f287 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -14,6 +14,7 @@
 #define _UAPI_LINUX_IF_BRIDGE_H
 
 #include <linux/types.h>
+#include <linux/in6.h>
 
 #define SYSFS_BRIDGE_ATTR	"bridge"
 #define SYSFS_BRIDGE_FDB	"brforward"
-- 
1.8.2.1
