From: Benjamin Poirier <bpoirier@suse.de>
Subject: [PATCH] netdevice: Add missing parentheses in macro
Date: Wed, 14 Jan 2015 16:52:35 +0900
Message-ID: <1421221955-9505-1-git-send-email-bpoirier@suse.de>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59577 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932741AbbANHx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 02:53:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For example, one could conceivably call
	for_each_netdev_in_bond_rcu(condition ? bond1 : bond2, slave)
and get an unexpected result.

Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7f794db..52fd8e8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2085,7 +2085,7 @@ extern rwlock_t				dev_base_lock;		/* Device list lock */
 	list_for_each_entry_continue_rcu(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_in_bond_rcu(bond, slave)	\
 		for_each_netdev_rcu(&init_net, slave)	\
-			if (netdev_master_upper_dev_get_rcu(slave) == bond)
+			if (netdev_master_upper_dev_get_rcu(slave) == (bond))
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
 static inline struct net_device *next_net_device(struct net_device *dev)
-- 
2.2.0
