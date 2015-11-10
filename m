From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH] mac80211: Remove kerneldoc for beacon_loss_count
Date: Tue, 10 Nov 2015 17:58:52 +0100
Message-ID: <1447174732-28449-1-git-send-email-thierry.reding@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

The beacon_loss_count field was removed from the structure in commit
976bd9efdae6 ("mac80211: move beacon_loss_count into ifmgd"). This
updates the kerneldoc comment to match the structure definition.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
Applies on top of next-20151110.

 net/mac80211/sta_info.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 2cafb21b422f..fb77ece9a8c8 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -370,7 +370,6 @@ DECLARE_EWMA(signal, 1024, 8)
  * @uploaded: set to true when sta is uploaded to the driver
  * @sta: station information we share with the driver
  * @sta_state: duplicates information about station state (for debug)
- * @beacon_loss_count: number of times beacon loss has triggered
  * @rcu_head: RCU head used for freeing this station struct
  * @cur_max_bandwidth: maximum bandwidth to use for TX to the station,
  *	taken from HT/VHT capabilities or VHT operating mode notification
-- 
2.5.0
