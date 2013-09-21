From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/12] p8022.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:52 -0700
Message-ID: <5640248f05394a4460179df8f9f8cb5a1959eb6b.1379783996.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/p8022.h | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/net/p8022.h b/include/net/p8022.h
index 42e9fac..05e4138 100644
--- a/include/net/p8022.h
+++ b/include/net/p8022.h
@@ -1,13 +1,13 @@
 #ifndef _NET_P8022_H
 #define _NET_P8022_H
-extern struct datalink_proto *
-	register_8022_client(unsigned char type,
-			     int (*func)(struct sk_buff *skb,
-					 struct net_device *dev,
-					 struct packet_type *pt,
-					 struct net_device *orig_dev));
-extern void unregister_8022_client(struct datalink_proto *proto);
+struct datalink_proto *
+register_8022_client(unsigned char type,
+		     int (*func)(struct sk_buff *skb,
+				 struct net_device *dev,
+				 struct packet_type *pt,
+				 struct net_device *orig_dev));
+void unregister_8022_client(struct datalink_proto *proto);
 
-extern struct datalink_proto *make_8023_client(void);
-extern void destroy_8023_client(struct datalink_proto *dl);
+struct datalink_proto *make_8023_client(void);
+void destroy_8023_client(struct datalink_proto *dl);
 #endif
-- 
1.8.1.2.459.gbcd45b4.dirty
