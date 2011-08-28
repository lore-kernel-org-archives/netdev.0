From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH 2/2] iwlegacy: change IWL_WARN to IWL_DEBUG_HT in iwl4965_rs_tl_turn_on_agg_for_tid
Date: Sun, 28 Aug 2011 08:26:17 -0500
Message-ID: <1314537977-20097-2-git-send-email-Gregory.Dietsche@cuw.edu>
References: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: sgruszka@redhat.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314537977-20097-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message should be a debug message and not a warning. So
change it from IWL_WARN to IWL_DEBUG_HT.

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
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
