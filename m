From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: reorder struct netdev_hw_addr
Date: Sat, 18 Sep 2010 08:17:44 +0200
Message-ID: <1284790664.4373.610.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37752 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab0IRGRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 02:17:50 -0400
Received: by wyf22 with SMTP id 22so3001116wyf.19
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 23:17:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move 'synced' and 'global_use' fields before 'refcount', to shrinks
struct netdev_hw_addr by 8 bytes (on 64bit arches).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ec17887..f7f1302 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -228,9 +228,9 @@ struct netdev_hw_addr {
 #define NETDEV_HW_ADDR_T_SLAVE		3
 #define NETDEV_HW_ADDR_T_UNICAST	4
 #define NETDEV_HW_ADDR_T_MULTICAST	5
-	int			refcount;
 	bool			synced;
 	bool			global_use;
+	int			refcount;
 	struct rcu_head		rcu_head;
 };
 


