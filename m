From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/9] include/linux: Add private flags for IPoIB interfaces
Date: Tue, 10 Jul 2012 15:16:02 +0300
Message-ID: <1341922569-4118-3-git-send-email-ogerlitz@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, Erez Shitrit <erezsh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:50489 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755191Ab2GJMQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 08:16:22 -0400
In-Reply-To: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.co.il>

The new 2 bits indicates whenever a device is considered PIF interface,
which means the "main" interfaces (ib0, ib1 etc), or cloned interfaces
(ib0.1, ib1.2 etc.) that is now in use by the eIPoIB driver.

Signed-off-by: Erez Shitrit <erezsh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/if.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index 1ec407b..f50dbf2 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -84,6 +84,8 @@
 #define IFF_LIVE_ADDR_CHANGE 0x100000	/* device supports hardware address
 					 * change when it's running */
 
+#define IFF_EIPOIB_PIF  0x200000       /* IPoIB PIF intf (ib0, ib1 etc.) */
+#define IFF_EIPOIB_VIF  0x400000       /* IPoIB VIF intf (ib0.x, ib1.x etc.) */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
-- 
1.7.1
