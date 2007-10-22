From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/5] Cut off macvlan_port from net_device
Date: Mon, 22 Oct 2007 16:34:35 +0400
Message-ID: <471C98DB.2060703@openvz.org>
References: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39004 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752477AbXJVMdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:33:53 -0400
In-Reply-To: <471C9830.5070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 469e04f..c41a5c4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -703,8 +703,10 @@ struct net_device
 	/* bridge stuff */
 	struct net_bridge_port	*br_port;
 #endif
+#if defined(CONFIG_MACVLAN) || defined(CONFIG_MACVLAN_MODULE)
 	/* macvlan */
 	struct macvlan_port	*macvlan_port;
+#endif
 
 	/* class/net/name entry */
 	struct device		dev;
-- 
1.5.3.4

