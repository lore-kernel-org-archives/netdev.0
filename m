From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 2/3] net: rsi: mac80211: constify ieee80211_ops
Date: Wed, 23 Aug 2017 15:29:34 +0530
Message-ID: <1503482375-19983-3-git-send-email-arvind.yadav.cs@gmail.com>
References: <1503482375-19983-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: davem@davemloft.net, Larry.Finger@lwfinger.net,
        chaoming_li@realsil.com.cn, kvalo@codeaurora.org,
        jon.maloy@ericsson.com, ying.xue@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503482375-19983-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_ops are not supposed to change at runtime. All functions
working with ieee80211_ops provided by <net/mac80211.h> work with
const ieee80211_ops. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/wireless/rsi/rsi_91x_mac80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_mac80211.c b/drivers/net/wireless/rsi/rsi_91x_mac80211.c
index 021e5ac..67532fb 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mac80211.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mac80211.c
@@ -1177,7 +1177,7 @@ static void rsi_reg_notify(struct wiphy *wiphy,
 	adapter->dfs_region = request->dfs_region;
 }
 
-static struct ieee80211_ops mac80211_ops = {
+static const struct ieee80211_ops mac80211_ops = {
 	.tx = rsi_mac80211_tx,
 	.start = rsi_mac80211_start,
 	.stop = rsi_mac80211_stop,
-- 
1.9.1
