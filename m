From: Joe Perches <joe@perches.com>
Subject: [PATCH 22/25] bridge: Use bool function return values of true/false not 1/0
Date: Mon, 30 Mar 2015 16:46:20 -0700
Message-ID: <d5bd569a2340afb7d820885fa40d4d0eeff6c59a.1427759010.git.joe@perches.com>
References: <cover.1427759009.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427759009.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the normal return values for bool functions

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/bridge/br_private.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b46fa0c..5aba35e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -574,7 +574,7 @@ static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
 }
 static inline bool br_multicast_is_router(struct net_bridge *br)
 {
-	return 0;
+	return false;
 }
 static inline bool br_multicast_querier_exists(struct net_bridge *br,
 					       struct ethhdr *eth)
-- 
2.1.2
