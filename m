From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH V3] ath/ath9k/ar9003_eeprom.c: Remove semicolon after if
Date: Wed, 10 Oct 2012 18:38:17 +0200
Message-ID: <1349887097-24980-1-git-send-email-peter.senna@gmail.com>
References: <1349038599-22026-1-git-send-email-peter.senna@gmail.com>
Cc: jouni@qca.qualcomm.com, vthiagar@qca.qualcomm.com,
	senthilb@qca.qualcomm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: mcgrof@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349038599-22026-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove a semicolon after if(...) that is preventing the
error check to work correctly. Removing this semicolon will change the
code behavior, but this is intended.

The semantic patch that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r1@
position p;
@@
if (...);@p

@script:python@
p0 << r1.p;
@@
// Emacs org-mode output
cocci.print_main("", p0)
cocci.print_secs("", p0)
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
NOTE: This patch changes the semantics.

Changes from V1:
Commit message
Added a note about semantics change

Changes from V2:
Commit message

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 5bbe505..189aeb2 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -2989,7 +2989,7 @@ static u32 ath9k_hw_ar9300_get_eeprom(struct ath_hw *ah,
 	case EEP_PAPRD:
 		if (AR_SREV_9462(ah))
 			return false;
-		if (!ah->config.enable_paprd);
+		if (!ah->config.enable_paprd)
 			return false;
 		return !!(pBase->featureEnable & BIT(5));
 	case EEP_CHAIN_MASK_REDUCE:
-- 
1.7.11.4
