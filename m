From: y@farmergreg.com
Subject: [PATCH 2/2 v2] iwlegacy: change IWL_ERR to IWL_DEBUG_HT in iwl4965_rs_tl_turn_on_agg_for_tid
Date: Sun, 28 Aug 2011 08:32:10 -0500
Message-ID: <RpYE1h00E3pHlLY05pYEzN@farmergreg.com>
References: <1314537977-20097-2-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
To: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1314537977-20097-2-git-send-email-Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>

This message should be a debug message and not an error. So
change it from IWL_ERR to IWL_DEBUG_HT.

Signed-off-by: Greg Dietsche <Gregory.Dietsche-5+R7UueiBCQ@public.gmane.org>
---
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
index 9b65153..a0b60ee 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
@@ -373,7 +373,7 @@ static int iwl4965_rs_tl_turn_on_agg_for_tid(struct iwl_priv *priv,
 			ieee80211_stop_tx_ba_session(sta, tid);
 		}
 	} else {
-		IWL_ERR(priv, "Aggregation not enabled for tid %d "
+		IWL_DEBUG_HT(priv, "Aggregation not enabled for tid %d "
 			"because load = %u\n", tid, load);
 	}
 	return ret;
-- 
1.7.5.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
