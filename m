From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] netpoll: Neaten MAX_SKB_SIZE macro
Date: Sun, 29 Jan 2012 17:50:44 -0800
Message-ID: <c3a95a1d04d11f3741114ca206d37aea5609e504.1327888082.git.joe@perches.com>
References: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8a61df72a4eb6caaeaa8b5be644be227da61512b.1327888082.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the types in the packet layout order.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/netpoll.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b523274..4ce473e 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -47,9 +47,11 @@ static atomic_t trapped;
 #define NETPOLL_RX_ENABLED  1
 #define NETPOLL_RX_DROP     2
 
-#define MAX_SKB_SIZE \
-		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
-				sizeof(struct iphdr) + sizeof(struct ethhdr))
+#define MAX_SKB_SIZE							\
+	(sizeof(struct ethhdr) +					\
+	 sizeof(struct iphdr) +						\
+	 sizeof(struct udphdr) +					\
+	 MAX_UDP_CHUNK)
 
 static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
-- 
1.7.8.111.gad25c.dirty
