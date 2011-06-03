From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH 3/5] iwlegacy: return -EINVAL instead of -1
Date: Thu,  2 Jun 2011 21:06:08 -0500
Message-ID: <1307066770-27309-3-git-send-email-Gregory.Dietsche@cuw.edu>
References: <1307066770-27309-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: kernel-janitors@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: sgruszka@redhat.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307066770-27309-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup the code to return -EINVAL instead of -1
Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/wireless/iwlegacy/iwl-4965.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/iwl-4965.c b/drivers/net/wireless/iwlegacy/iwl-4965.c
index ffda05c..06dcee5 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965.c
@@ -496,7 +496,7 @@ static s32 iwl4965_get_tx_atten_grp(u16 channel)
 	    channel <= CALIB_IWL_TX_ATTEN_GR4_LCH)
 		return CALIB_CH_GROUP_4;
 
-	return -1;
+	return -EINVAL;
 }
 
 static u32 iwl4965_get_sub_band(const struct iwl_priv *priv, u32 channel)
-- 
1.7.2.5
