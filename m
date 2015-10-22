From: Punit Vara <punitvara@gmail.com>
Subject: [PATCH v3 14/15] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Thu, 22 Oct 2015 23:56:03 +0530
Message-ID: <1445538363-2893-1-git-send-email-punitvara@gmail.com>
Cc: mickflemm@gmail.com, mcgrof@do-not-panic.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Punit Vara <punitvara@gmail.com>
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to the ath5k/eeprom.c that fixes up warning caught by
coccicheck:

-Unneeded variable: "ret". Return "0" on line 1733

Remove unneccesary variable ret created to return zero.

Also removed empty line suggested by Sergei
 
Signed-off-by: Punit Vara <punitvara@gmail.com>
---
 drivers/net/wireless/ath/ath5k/eeprom.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 94d34ee..0c82ea5 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -1707,8 +1707,7 @@ ath5k_eeprom_read_spur_chans(struct ath5k_hw *ah)
 	struct ath5k_eeprom_info *ee = &ah->ah_capabilities.cap_eeprom;
 	u32 offset;
 	u16 val;
-	int ret = 0, i;
-
+	int i;
 	offset = AR5K_EEPROM_CTL(ee->ee_version) +
 				AR5K_EEPROM_N_CTLS(ee->ee_version);
 
@@ -1730,7 +1729,7 @@ ath5k_eeprom_read_spur_chans(struct ath5k_hw *ah)
 		}
 	}
 
-	return ret;
+	return 0;
 }
 
 
-- 
2.5.3
