From: Punit Vara <punitvara@gmail.com>
Subject: [RESEND PATCH 10/10] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Wed, 28 Oct 2015 00:32:45 +0530
Message-ID: <1445972565-14963-10-git-send-email-punitvara@gmail.com>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Punit Vara <punitvara@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
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
