From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 15/15] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Wed, 21 Oct 2015 20:25:37 +0530
Message-ID: <1445439337-19055-16-git-send-email-punitvara@gmail.com>
References: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Cc: stas.yakovlev@gmail.com, chaoming_li@realsil.com.cn,
	Larry.Finger@lwfinger.net, chunkeey@googlemail.com,
	sgruszka@redhat.com, brudley@broadcom.com, arend@broadcom.com,
	linville@tuxdriver.com, jirislaby@gmail.com, mickflemm@gmail.com,
	mcgrof@do-not-panic.com, k.eugene.e@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, wcn36xx@lists.infradead.org,
	johannes.berg@intel.com, meuleman@broadcom.com,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445439337-19055-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the ath5k/eeprom.c that fixes up warning caught by
coccicheck:

Unneeded variable: "ret". Return "0" on line 980

Remove unneeded variable ret created to return zero.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 7c169ab..82982d5 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -935,7 +935,6 @@ static const struct ieee80211_ops wcn36xx_ops = {
 
 static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 {
-	int ret = 0;
 
 	static const u32 cipher_suites[] = {
 		WLAN_CIPHER_SUITE_WEP40,
@@ -977,7 +976,7 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 	wcn->hw->sta_data_size = sizeof(struct wcn36xx_sta);
 	wcn->hw->vif_data_size = sizeof(struct wcn36xx_vif);
 
-	return ret;
+	return 0;
 }
 
 static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
-- 
2.5.3
