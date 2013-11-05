From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next trivial] udp: Remove unnecessary semicolon from
 do{}while (0) macro
Date: Tue, 05 Nov 2013 14:13:47 -0800
Message-ID: <1383689627.28624.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just an unnecessary semicolon that should be removed...

Whitespace neatening of macro too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/udp.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index fe4ba9f..a24f0f3 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -230,13 +230,13 @@ struct sock *__udp6_lib_lookup(struct net *net,
 } while(0)
 
 #if IS_ENABLED(CONFIG_IPV6)
-#define UDPX_INC_STATS_BH(sk, field) \
-	do { \
-		if ((sk)->sk_family == AF_INET) \
-			UDP_INC_STATS_BH(sock_net(sk), field, 0); \
-		else \
-			UDP6_INC_STATS_BH(sock_net(sk), field, 0); \
-	} while (0);
+#define UDPX_INC_STATS_BH(sk, field)					\
+do {									\
+	if ((sk)->sk_family == AF_INET)					\
+		UDP_INC_STATS_BH(sock_net(sk), field, 0);		\
+	else								\
+		UDP6_INC_STATS_BH(sock_net(sk), field, 0);		\
+} while (0)
 #else
 #define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(sock_net(sk), field, 0)
 #endif
