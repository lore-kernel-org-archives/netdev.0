From: Joe Perches <joe@perches.com>
Subject: [PATCH 27/62] drivers/net/wireless/ath/ath9k: Remove unnecessary semicolons
Date: Sun, 28 Jun 2009 09:26:32 -0700
Message-ID: <eea2935af7c3b29549f21b6ed2c5482f84fe0d73.1246173681.git.joe@perches.com>
References: <cover.1246173664.git.joe@perches.com>
Cc: trivial@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	ath9k-devel@venema.h4ckr.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1123 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbZF1Q1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 12:27:42 -0400
In-Reply-To: <cover.1246173664.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/eeprom.c |    2 --
 drivers/net/wireless/ath/ath9k/hw.c     |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index a2fda70..d82a0f9 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -2516,10 +2516,8 @@ static void ath9k_hw_set_def_power_per_rate_table(struct ath_hw *ah,
 			targetPowerCck.tPow2x[1];
 		ratesArray[rate5_5s] = ratesArray[rate5_5l] =
 			targetPowerCck.tPow2x[2];
-		;
 		ratesArray[rate11s] = ratesArray[rate11l] =
 			targetPowerCck.tPow2x[3];
-		;
 	}
 	if (IS_CHAN_HT40(chan)) {
 		for (i = 0; i < ARRAY_SIZE(targetPowerHt40.tPow2x); i++) {
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 34935a8..cffb078 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2345,7 +2345,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	ath9k_hw_init_bb(ah, chan);
 
 	if (!ath9k_hw_init_cal(ah, chan))
-		return -EIO;;
+		return -EIO;
 
 	rx_chainmask = ah->rxchainmask;
 	if ((rx_chainmask == 0x5) || (rx_chainmask == 0x3)) {
-- 
1.6.3.1.10.g659a0.dirty

