From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH] ath/ath9k/ar9003_eeprom.c: Remove unnecessary semicolon
Date: Sun, 30 Sep 2012 21:21:10 +0200
Message-ID: <1349032870-4780-1-git-send-email-peter.senna@gmail.com>
Cc: jouni@qca.qualcomm.com, vthiagar@qca.qualcomm.com,
	senthilb@qca.qualcomm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: mcgrof@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37226 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727Ab2I3TV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 15:21:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The semantic match that finds this problem is as follows:
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
