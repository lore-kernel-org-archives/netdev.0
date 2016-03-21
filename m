From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] ipv6: remove unused in6_addr struct
Date: Mon, 21 Mar 2016 17:37:28 +0000
Message-ID: <1458581848-844-1-git-send-email-luisbg@osg.samsung.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	javier@osg.samsung.com,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct in6_addr isn't used anymore in inet6_connection_sock.h, removing
the forward declaration.

Fixes: 1b33bc3e9e90 ("ipv6: remove obsolete inet6 functions")
Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
 include/net/inet6_connection_sock.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 064cfbe..954ad6b 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -15,7 +15,6 @@
 
 #include <linux/types.h>
 
-struct in6_addr;
 struct inet_bind_bucket;
 struct request_sock;
 struct sk_buff;
-- 
2.6.4
