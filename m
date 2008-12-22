From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 24/27] drivers/net/wireless/ath9k: fix sparse warnings: make
	symbols static
Date: Mon, 22 Dec 2008 20:18:32 +0100
Message-ID: <20081222191832.11807.3277.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:33491 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566AbYLVTSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:18:39 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/wireless/ath9k/eeprom.c:195:6: warning: symbol 'ath9k_fill_eeprom' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:463:5: warning: symbol 'ath9k_check_eeprom' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:1219:6: warning: symbol 'ath9k_hw_set_def_power_per_rate_table' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:1510:6: warning: symbol 'ath9k_hw_set_4k_power_per_rate_table' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2007:5: warning: symbol 'ath9k_set_txpower' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2106:6: warning: symbol 'ath9k_set_addac' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2543:6: warning: symbol 'ath9k_eeprom_set_board_values' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2606:5: warning: symbol 'ath9k_get_eeprom_antenna_cfg' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2622:4: warning: symbol 'ath9k_hw_get_4k_num_ant_config' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2628:4: warning: symbol 'ath9k_hw_get_def_num_ant_config' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2647:4: warning: symbol 'ath9k_get_num_ant_config' was not declared. Should it be static?
  drivers/net/wireless/ath9k/eeprom.c:2790:5: warning: symbol 'ath9k_get_eeprom' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wireless/ath9k/eeprom.c |   62 ++++++++++++++++++-----------------
 1 files changed, 32 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/ath9k/eeprom.c b/drivers/net/wireless/ath9k/eeprom.c
index 14f8d40..acd6c53 100644
--- a/drivers/net/wireless/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath9k/eeprom.c
@@ -192,7 +192,7 @@ static bool ath9k_hw_fill_def_eeprom(struct ath_hal *ah)
 #undef SIZE_EEPROM_DEF
 }
 
-bool (*ath9k_fill_eeprom[]) (struct ath_hal *) = {
+static bool (*ath9k_fill_eeprom[]) (struct ath_hal *) = {
 	ath9k_hw_fill_def_eeprom,
 	ath9k_hw_fill_4k_eeprom
 };
@@ -460,7 +460,7 @@ static int ath9k_hw_check_4k_eeprom(struct ath_hal *ah)
 #undef EEPROM_4K_SIZE
 }
 
-int (*ath9k_check_eeprom[]) (struct ath_hal *) = {
+static int (*ath9k_check_eeprom[]) (struct ath_hal *) = {
 	ath9k_hw_check_def_eeprom,
 	ath9k_hw_check_4k_eeprom
 };
@@ -1216,13 +1216,13 @@ static bool ath9k_hw_set_4k_power_cal_table(struct ath_hal *ah,
 	return true;
 }
 
-bool ath9k_hw_set_def_power_per_rate_table(struct ath_hal *ah,
-				       struct ath9k_channel *chan,
-				       int16_t *ratesArray,
-				       u16 cfgCtl,
-				       u16 AntennaReduction,
-				       u16 twiceMaxRegulatoryPower,
-				       u16 powerLimit)
+static bool ath9k_hw_set_def_power_per_rate_table(struct ath_hal *ah,
+						  struct ath9k_channel *chan,
+						  int16_t *ratesArray,
+						  u16 cfgCtl,
+						  u16 AntennaReduction,
+						  u16 twiceMaxRegulatoryPower,
+						  u16 powerLimit)
 {
 #define REDUCE_SCALED_POWER_BY_TWO_CHAIN     6  /* 10*log10(2)*2 */
 #define REDUCE_SCALED_POWER_BY_THREE_CHAIN   10 /* 10*log10(3)*2 */
@@ -1507,13 +1507,13 @@ bool ath9k_hw_set_def_power_per_rate_table(struct ath_hal *ah,
 	return true;
 }
 
-bool ath9k_hw_set_4k_power_per_rate_table(struct ath_hal *ah,
-				       struct ath9k_channel *chan,
-				       int16_t *ratesArray,
-				       u16 cfgCtl,
-				       u16 AntennaReduction,
-				       u16 twiceMaxRegulatoryPower,
-				       u16 powerLimit)
+static bool ath9k_hw_set_4k_power_per_rate_table(struct ath_hal *ah,
+						 struct ath9k_channel *chan,
+						 int16_t *ratesArray,
+						 u16 cfgCtl,
+						 u16 AntennaReduction,
+						 u16 twiceMaxRegulatoryPower,
+						 u16 powerLimit)
 {
 	struct ath_hal_5416 *ahp = AH5416(ah);
 	struct ar5416_eeprom_4k *pEepData = &ahp->ah_eeprom.map4k;
@@ -2004,9 +2004,9 @@ static int ath9k_hw_4k_set_txpower(struct ath_hal *ah,
 	return 0;
 }
 
-int (*ath9k_set_txpower[]) (struct ath_hal *,
-			    struct ath9k_channel *,
-			    u16, u8, u8, u8) = {
+static int (*ath9k_set_txpower[]) (struct ath_hal *,
+				   struct ath9k_channel *,
+				   u16, u8, u8, u8) = {
 	ath9k_hw_def_set_txpower,
 	ath9k_hw_4k_set_txpower
 };
@@ -2103,7 +2103,7 @@ static void ath9k_hw_set_4k_addac(struct ath_hal *ah,
 	}
 }
 
-void (*ath9k_set_addac[]) (struct ath_hal *, struct ath9k_channel *) = {
+static void (*ath9k_set_addac[]) (struct ath_hal *, struct ath9k_channel *) = {
 	ath9k_hw_set_def_addac,
 	ath9k_hw_set_4k_addac
 };
@@ -2540,8 +2540,8 @@ static bool ath9k_hw_eeprom_set_4k_board_values(struct ath_hal *ah,
 	return true;
 }
 
-bool (*ath9k_eeprom_set_board_values[])(struct ath_hal *,
-					struct ath9k_channel *) = {
+static bool (*ath9k_eeprom_set_board_values[])(struct ath_hal *,
+					       struct ath9k_channel *) = {
 	ath9k_hw_eeprom_set_def_board_values,
 	ath9k_hw_eeprom_set_4k_board_values
 };
@@ -2603,8 +2603,9 @@ static int ath9k_hw_get_4k_eeprom_antenna_cfg(struct ath_hal *ah,
 	return -EINVAL;
 }
 
-int (*ath9k_get_eeprom_antenna_cfg[])(struct ath_hal *, struct ath9k_channel *,
-				      u8, u16 *) = {
+static int (*ath9k_get_eeprom_antenna_cfg[])(struct ath_hal *,
+					     struct ath9k_channel *,
+					     u8, u16 *) = {
 	ath9k_hw_get_def_eeprom_antenna_cfg,
 	ath9k_hw_get_4k_eeprom_antenna_cfg
 };
@@ -2619,14 +2620,14 @@ int ath9k_hw_get_eeprom_antenna_cfg(struct ath_hal *ah,
 							     index, config);
 }
 
-u8 ath9k_hw_get_4k_num_ant_config(struct ath_hal *ah,
-			       enum ieee80211_band freq_band)
+static u8 ath9k_hw_get_4k_num_ant_config(struct ath_hal *ah,
+					 enum ieee80211_band freq_band)
 {
 	return 1;
 }
 
-u8 ath9k_hw_get_def_num_ant_config(struct ath_hal *ah,
-			       enum ieee80211_band freq_band)
+static u8 ath9k_hw_get_def_num_ant_config(struct ath_hal *ah,
+					  enum ieee80211_band freq_band)
 {
 	struct ath_hal_5416 *ahp = AH5416(ah);
 	struct ar5416_eeprom_def *eep = &ahp->ah_eeprom.def;
@@ -2644,7 +2645,8 @@ u8 ath9k_hw_get_def_num_ant_config(struct ath_hal *ah,
 	return num_ant_config;
 }
 
-u8 (*ath9k_get_num_ant_config[])(struct ath_hal *, enum ieee80211_band) = {
+static u8 (*ath9k_get_num_ant_config[])(struct ath_hal *,
+					enum ieee80211_band) = {
 	ath9k_hw_get_def_num_ant_config,
 	ath9k_hw_get_4k_num_ant_config
 };
@@ -2787,7 +2789,7 @@ static u32 ath9k_hw_get_eeprom_def(struct ath_hal *ah,
 	}
 }
 
-u32 (*ath9k_get_eeprom[])(struct ath_hal *, enum eeprom_param) = {
+static u32 (*ath9k_get_eeprom[])(struct ath_hal *, enum eeprom_param) = {
 	ath9k_hw_get_eeprom_def,
 	ath9k_hw_get_eeprom_4k
 };

