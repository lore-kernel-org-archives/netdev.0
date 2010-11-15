From: Joe Perches <joe@perches.com>
Subject: [PATCH 38/44] include/linux/if_macvlan.h: Remove unnecessary semicolons
Date: Sun, 14 Nov 2010 19:04:57 -0800
Message-ID: <186ca914f887b2354ea3178696edc81cacbb28c6.1289789605.git.joe@perches.com>
References: <cover.1289789604.git.joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289789604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/if_macvlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 8a2fd66..ac96a2d 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -69,7 +69,7 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 	rx_stats = this_cpu_ptr(vlan->rx_stats);
 	if (likely(success)) {
 		u64_stats_update_begin(&rx_stats->syncp);
-		rx_stats->rx_packets++;;
+		rx_stats->rx_packets++;
 		rx_stats->rx_bytes += len;
 		if (multicast)
 			rx_stats->rx_multicast++;
-- 
1.7.3.1.g432b3.dirty
