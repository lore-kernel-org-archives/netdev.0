From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] net: update comment for netif_dormant() function
Date: Wed, 26 Apr 2017 11:05:12 +0800
Message-ID: <1493175912-3391-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:43479 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034919AbdDZDOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:14:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the comment for netif_dormant() function to reflect
the intended usage.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 include/linux/netdevice.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5d5267f..b8c8e5b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3400,10 +3400,10 @@ static inline void netif_dormant_off(struct net_device *dev)
 }
 
 /**
- *	netif_dormant - test if carrier present
+ *	netif_dormant - test if device is dormant
  *	@dev: network device
  *
- * Check if carrier is present on device
+ * Check if device is dormant.
  */
 static inline bool netif_dormant(const struct net_device *dev)
 {
-- 
1.8.3.1
