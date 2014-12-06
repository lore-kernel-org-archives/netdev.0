From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 1/4] netdevice: Add a function to check macvlan port
Date: Sat,  6 Dec 2014 15:53:04 -0800
Message-ID: <1417909984-13133-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:50545 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaLFXxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 18:53:08 -0500
Received: by mail-pd0-f202.google.com with SMTP id v10so342839pde.3
        for <netdev@vger.kernel.org>; Sat, 06 Dec 2014 15:53:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to a check for macvlan device, netif_is_macvlan(), add
another function to check if a device is used as macvlan port.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/netdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 29c92ee9ed56..1f49aac258f9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3641,6 +3641,11 @@ static inline bool netif_is_macvlan(struct net_device *dev)
 	return dev->priv_flags & IFF_MACVLAN;
 }
 
+static inline bool netif_is_macvlan_port(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_MACVLAN_PORT;
+}
+
 static inline bool netif_is_bond_master(struct net_device *dev)
 {
 	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_BONDING;
-- 
2.2.0.rc0.207.ga3a616c
