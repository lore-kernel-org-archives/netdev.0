From: xypron.glpk@gmx.de
Subject: [PATCH] Remove redundant if clause
Date: Thu, 27 Feb 2014 17:06:58 +0100
Message-ID: <1393517218-11043-1-git-send-email-xypron.glpk@gmx.de>
Cc: chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	felipensp@gmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heinrich Schuchardt <xypron.glpk@gmx.de>

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
index 92d38ab..78a81c1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -52,7 +52,7 @@ static void _rtl92s_get_powerbase(struct ieee80211_hw *hw, u8 *p_pwrlevel,
 	/* We only care about the path A for legacy. */
 	if (rtlefuse->eeprom_version < 2) {
 		pwrbase0 = pwrlevel[0] + (rtlefuse->legacy_httxpowerdiff & 0xf);
-	} else if (rtlefuse->eeprom_version >= 2) {
+	} else {
 		legacy_pwrdiff = rtlefuse->txpwr_legacyhtdiff
 						[RF90_PATH_A][chnl - 1];
 
-- 
1.7.10.4
