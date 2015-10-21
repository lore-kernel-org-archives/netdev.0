From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH 14/15] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Wed, 21 Oct 2015 20:25:36 +0530
Message-ID: <1445439337-19055-15-git-send-email-punitvara@gmail.com>
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

-Unneeded variable: "ret". Return "0" on line 1733

Remove unneccesary variable ret created to return zero.

Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/ath5k/eeprom.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 94d34ee..673ab8d 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -1707,7 +1707,7 @@ ath5k_eeprom_read_spur_chans(struct ath5k_hw *ah)
 	struct ath5k_eeprom_info *ee = &ah->ah_capabilities.cap_eeprom;
 	u32 offset;
 	u16 val;
-	int ret = 0, i;
+	int i;
 
 	offset = AR5K_EEPROM_CTL(ee->ee_version) +
 				AR5K_EEPROM_N_CTLS(ee->ee_version);
@@ -1730,7 +1730,7 @@ ath5k_eeprom_read_spur_chans(struct ath5k_hw *ah)
 		}
 	}
 
-	return ret;
+	return 0;
 }
 
 
-- 
2.5.3
