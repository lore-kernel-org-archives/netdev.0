From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1 v2] rtlwifi: remove superfluous condition
Date: Tue,  2 Aug 2016 21:26:21 +0200
Message-ID: <1470165981-6241-1-git-send-email-xypron.glpk@gmx.de>
References: <4e6de16f-b42c-920a-60a2-fcc88e282dc0@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63463 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755752AbcHBT0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 15:26:50 -0400
In-Reply-To: <4e6de16f-b42c-920a-60a2-fcc88e282dc0@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If sta == NULL, the changed line will not be reached.
So no need to check that sta != NULL here.

v2:
	fix typo

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
Acked-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/realtek/rtlwifi/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 41f77f8..7aee5ebb1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -1135,7 +1135,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 					mac->mode = WIRELESS_MODE_AC_24G;
 			}
 
-			if (vif->type == NL80211_IFTYPE_STATION && sta)
+			if (vif->type == NL80211_IFTYPE_STATION)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 			rcu_read_unlock();
 
-- 
2.1.4
