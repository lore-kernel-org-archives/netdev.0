From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] macvlan: convert to use IFF_NO_QUEUE
Date: Sun, 14 Feb 2016 14:10:39 +0000
Message-ID: <1455459039-12383-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:4114 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128AbcBNOJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 09:09:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use IFF_NO_QUEUE to indicate that a device can run without a qdisc.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/macvlan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 94e6888..426a2cc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1069,7 +1069,7 @@ EXPORT_SYMBOL_GPL(macvlan_common_setup);
 static void macvlan_setup(struct net_device *dev)
 {
 	macvlan_common_setup(dev);
-	dev->tx_queue_len	= 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 }
 
 static int macvlan_port_create(struct net_device *dev)
-- 
1.8.3.1
