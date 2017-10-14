From: Wenhua Shi <march511@gmail.com>
Subject: [PATCH] fix typo in skbuff.c
Date: Sat, 14 Oct 2017 18:51:36 +0200
Message-ID: <20171014165136.2041-1-march511@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 16982de6..e62476be 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1896,7 +1896,7 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
 	}
 
 	/* If we need update frag list, we are in troubles.
-	 * Certainly, it possible to add an offset to skb data,
+	 * Certainly, it is possible to add an offset to skb data,
 	 * but taking into account that pulling is expected to
 	 * be very rare operation, it is worth to fight against
 	 * further bloating skb head and crucify ourselves here instead.
-- 
2.11.0
