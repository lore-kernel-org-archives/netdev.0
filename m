From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] iwlwifi: rs: remove superfluous check
Date: Wed, 18 May 2016 01:31:08 +0200
Message-ID: <1463527868-12226-1-git-send-email-xypron.glpk@gmx.de>
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
	Eyal Shapira <eyal@wizery.com>,
	Gregory Greenman <gregory.greenman@intel.com>,
	Alexander Bondar <alexander.bondar@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Luca Coelho <luciano.coelho@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we dereference a variable anyway in other parts of the code,
there is no need to check against NULL in a single place.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
index 81dd2f6..bab01ea 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
@@ -2867,7 +2867,7 @@ static void rs_get_rate(void *mvm_r, struct ieee80211_sta *sta, void *mvm_sta,
 	/* TODO: handle rate_idx_mask and rate_idx_mcs_mask */
 
 	/* Treat uninitialized rate scaling data same as non-existing. */
-	if (lq_sta && !lq_sta->pers.drv) {
+	if (!lq_sta->pers.drv) {
 		IWL_DEBUG_RATE(mvm, "Rate scaling not initialized yet.\n");
 		mvm_sta = NULL;
 	}
-- 
2.1.4
