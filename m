From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH wireless-next] ath: Rename ath_print to ath_debug
Date: Sun, 28 Nov 2010 15:53:11 -0800
Message-ID: <5febb0e1fba0ec2bb77f6ade8b251ba0edf4614c.1290988277.git.joe@perches.com>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make the function name match the function purpose.
ath_debug is a debug only facility.
ath_print seems too generic a name for a debug only use.

Removed an unnecessary trailing space in htc_drv_main.c

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath9k/ahb.c            |    2 +-
 drivers/net/wireless/ath/ath9k/ani.c            |   24 +++---
 drivers/net/wireless/ath/ath9k/ar5008_phy.c     |   46 ++++++------
 drivers/net/wireless/ath/ath9k/ar9002_calib.c   |   78 ++++++++++----------
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c     |   10 ++--
 drivers/net/wireless/ath/ath9k/ar9003_calib.c   |   76 ++++++++++----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c  |   68 +++++++++---------
 drivers/net/wireless/ath/ath9k/ar9003_mac.c     |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c     |   38 +++++-----
 drivers/net/wireless/ath/ath9k/beacon.c         |   36 +++++-----
 drivers/net/wireless/ath/ath9k/calib.c          |   18 +++---
 drivers/net/wireless/ath/ath9k/common.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |   24 +++---
 drivers/net/wireless/ath/ath9k/eeprom_9287.c    |   18 +++---
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |   24 +++---
 drivers/net/wireless/ath/ath9k/gpio.c           |   10 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |   10 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c   |    8 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |   28 ++++----
 drivers/net/wireless/ath/ath9k/htc_drv_main.c   |   82 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c   |   16 ++--
 drivers/net/wireless/ath/ath9k/hw.c             |   78 ++++++++++----------
 drivers/net/wireless/ath/ath9k/init.c           |   12 ++--
 drivers/net/wireless/ath/ath9k/mac.c            |   58 ++++++++--------
 drivers/net/wireless/ath/ath9k/main.c           |   88 +++++++++++-----------
 drivers/net/wireless/ath/ath9k/pci.c            |    2 +-
 drivers/net/wireless/ath/ath9k/rc.c             |    8 +-
 drivers/net/wireless/ath/ath9k/recv.c           |   24 +++---
 drivers/net/wireless/ath/ath9k/virtual.c        |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c            |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c           |   36 +++++-----
 drivers/net/wireless/ath/debug.c                |    4 +-
 drivers/net/wireless/ath/debug.h                |    4 +-
 drivers/net/wireless/ath/key.c                  |   16 ++--
 36 files changed, 483 insertions(+), 483 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ahb.c b/drivers/net/wireless/ath/ath9k/ahb.c
index 1a984b0..944a67c 100644
--- a/drivers/net/wireless/ath/ath9k/ahb.c
+++ b/drivers/net/wireless/ath/ath9k/ahb.c
@@ -35,7 +35,7 @@ static bool ath_ahb_eeprom_read(struct ath_common *common, u32 off, u16 *data)
 
 	pdata = (struct ath9k_platform_data *) pdev->dev.platform_data;
 	if (off >= (ARRAY_SIZE(pdata->eeprom_data))) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "%s: flash read failed, offset %08x "
 			  "is out of range\n",
 			  __func__, off);
diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index 29a045d..ad0cf35 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -135,7 +135,7 @@ static void ath9k_ani_restart(struct ath_hw *ah)
 		cck_base = AR_PHY_COUNTMAX - ah->config.cck_trig_high;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "Writing ofdmbase=%u   cckbase=%u\n", ofdm_base, cck_base);
 
 	ENABLE_REGWRITE_BUFFER(ah);
@@ -267,7 +267,7 @@ static void ath9k_hw_set_ofdm_nil(struct ath_hw *ah, u8 immunityLevel)
 
 	aniState->noiseFloor = BEACON_RSSI(ah);
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "**** ofdmlevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
 		  aniState->ofdmNoiseImmunityLevel,
 		  immunityLevel, aniState->noiseFloor,
@@ -334,7 +334,7 @@ static void ath9k_hw_set_cck_nil(struct ath_hw *ah, u_int8_t immunityLevel)
 	const struct ani_cck_level_entry *entry_cck;
 
 	aniState->noiseFloor = BEACON_RSSI(ah);
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "**** ccklevel %d=>%d, rssi=%d[lo=%d hi=%d]\n",
 		  aniState->cckNoiseImmunityLevel, immunityLevel,
 		  aniState->noiseFloor, aniState->rssiThrLow,
@@ -478,7 +478,7 @@ static void ath9k_ani_reset_old(struct ath_hw *ah, bool is_scanning)
 
 	if (ah->opmode != NL80211_IFTYPE_STATION
 	    && ah->opmode != NL80211_IFTYPE_ADHOC) {
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "Reset ANI state opmode %u\n", ah->opmode);
 		ah->stats.ast_ani_reset++;
 
@@ -584,7 +584,7 @@ void ath9k_ani_reset(struct ath_hw *ah, bool is_scanning)
 		    ATH9K_ANI_OFDM_DEF_LEVEL ||
 		    aniState->cckNoiseImmunityLevel !=
 		    ATH9K_ANI_CCK_DEF_LEVEL) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "Restore defaults: opmode %u "
 				  "chan %d Mhz/0x%x is_scanning=%d "
 				  "ofdm:%d cck:%d\n",
@@ -602,7 +602,7 @@ void ath9k_ani_reset(struct ath_hw *ah, bool is_scanning)
 		/*
 		 * restore historical levels for this channel
 		 */
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "Restore history: opmode %u "
 			  "chan %d Mhz/0x%x is_scanning=%d "
 			  "ofdm:%d cck:%d\n",
@@ -666,7 +666,7 @@ static bool ath9k_hw_ani_read_counters(struct ath_hw *ah)
 
 	if (!use_new_ani(ah) && (phyCnt1 < ofdm_base || phyCnt2 < cck_base)) {
 		if (phyCnt1 < ofdm_base) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "phyCnt1 0x%x, resetting "
 				  "counter value to 0x%x\n",
 				  phyCnt1, ofdm_base);
@@ -675,7 +675,7 @@ static bool ath9k_hw_ani_read_counters(struct ath_hw *ah)
 				  AR_PHY_ERR_OFDM_TIMING);
 		}
 		if (phyCnt2 < cck_base) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "phyCnt2 0x%x, resetting "
 				  "counter value to 0x%x\n",
 				  phyCnt2, cck_base);
@@ -719,7 +719,7 @@ void ath9k_hw_ani_monitor(struct ath_hw *ah, struct ath9k_channel *chan)
 	cckPhyErrRate =  aniState->cckPhyErrCount * 1000 /
 			 aniState->listenTime;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "listenTime=%d OFDM:%d errs=%d/s CCK:%d "
 		  "errs=%d/s ofdm_turn=%d\n",
 		  aniState->listenTime,
@@ -755,7 +755,7 @@ void ath9k_enable_mib_counters(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_ANI, "Enable MIB counters\n");
+	ath_debug(common, ATH_DBG_ANI, "Enable MIB counters\n");
 
 	ath9k_hw_update_mibstats(ah, &ah->ah_mibStats);
 
@@ -777,7 +777,7 @@ void ath9k_hw_disable_mib_counters(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_ANI, "Disable MIB counters\n");
+	ath_debug(common, ATH_DBG_ANI, "Disable MIB counters\n");
 
 	REG_WRITE(ah, AR_MIBC, AR_MIBC_FMC);
 	ath9k_hw_update_mibstats(ah, &ah->ah_mibStats);
@@ -852,7 +852,7 @@ void ath9k_hw_ani_init(struct ath_hw *ah)
 	struct ath_common *common = ath9k_hw_common(ah);
 	int i;
 
-	ath_print(common, ATH_DBG_ANI, "Initialize ANI\n");
+	ath_debug(common, ATH_DBG_ANI, "Initialize ANI\n");
 
 	if (use_new_ani(ah)) {
 		ah->config.ofdm_trig_high = ATH9K_ANI_OFDM_TRIG_HIGH_NEW;
diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
index 06e34d2..1863958 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -130,7 +130,7 @@ static void ar5008_hw_force_bias(struct ath_hw *ah, u16 synth_freq)
 	/* pre-reverse this field */
 	tmp_reg = ath9k_hw_reverse_bits(new_bias, 3);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Force rf_pwd_icsyndiv to %1d on %4d\n",
 		  new_bias, synth_freq);
 
@@ -173,7 +173,7 @@ static int ar5008_hw_set_channel(struct ath_hw *ah, struct ath9k_channel *chan)
 			channelSel = ((freq - 704) * 2 - 3040) / 10;
 			bModeSynth = 1;
 		} else {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Invalid channel %u MHz\n", freq);
 			return -EINVAL;
 		}
@@ -206,7 +206,7 @@ static int ar5008_hw_set_channel(struct ath_hw *ah, struct ath9k_channel *chan)
 		channelSel = ath9k_hw_reverse_bits((freq - 4800) / 5, 8);
 		aModeRefSel = ath9k_hw_reverse_bits(1, 2);
 	} else {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Invalid channel %u MHz\n", freq);
 		return -EINVAL;
 	}
@@ -448,7 +448,7 @@ static int ar5008_hw_rf_alloc_ext_banks(struct ath_hw *ah)
 #define ATH_ALLOC_BANK(bank, size) do { \
 		bank = kzalloc((sizeof(u32) * size), GFP_KERNEL); \
 		if (!bank) { \
-			ath_print(common, ATH_DBG_FATAL, \
+			ath_debug(common, ATH_DBG_FATAL, \
 				  "Cannot allocate RF banks\n"); \
 			return -ENOMEM; \
 		} \
@@ -879,7 +879,7 @@ static int ar5008_hw_process_ini(struct ath_hw *ah,
 
 	/* Write analog registers */
 	if (!ath9k_hw_set_rf_regs(ah, chan, freqIndex)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "ar5416SetRfRegs failed\n");
 		return -EIO;
 	}
@@ -1058,7 +1058,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(ah->totalSizeDesired)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "level out of range (%u > %u)\n",
 				  level,
 				  (unsigned)ARRAY_SIZE(ah->totalSizeDesired));
@@ -1163,7 +1163,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "level out of range (%u > %u)\n",
 				  level,
 				  (unsigned) ARRAY_SIZE(firstep));
@@ -1184,7 +1184,7 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "level out of range (%u > %u)\n",
 				  level,
 				  (unsigned) ARRAY_SIZE(cycpwrThr1));
@@ -1203,25 +1203,25 @@ static bool ar5008_hw_ani_control_old(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI, "ANI parameters:\n");
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI, "ANI parameters:\n");
+	ath_debug(common, ATH_DBG_ANI,
 		  "noiseImmunityLevel=%d, spurImmunityLevel=%d, "
 		  "ofdmWeakSigDetectOff=%d\n",
 		  aniState->noiseImmunityLevel,
 		  aniState->spurImmunityLevel,
 		  !aniState->ofdmWeakSigDetectOff);
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "cckWeakSigThreshold=%d, "
 		  "firstepLevel=%d, listenTime=%d\n",
 		  aniState->cckWeakSigThreshold,
 		  aniState->firstepLevel,
 		  aniState->listenTime);
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		"ofdmPhyErrCount=%d, cckPhyErrCount=%d\n\n",
 		aniState->ofdmPhyErrCount,
 		aniState->cckPhyErrCount);
@@ -1306,7 +1306,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 				    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);
 
 		if (!on != aniState->ofdmWeakSigDetectOff) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: ofdm weak signal: %s=>%s\n",
 				  chan->channel,
 				  !aniState->ofdmWeakSigDetectOff ?
@@ -1324,7 +1324,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep_table)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "ATH9K_ANI_FIRSTEP_LEVEL: level "
 				  "out of range (%u > %u)\n",
 				  level,
@@ -1363,7 +1363,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 			      AR_PHY_FIND_SIG_FIRSTEP_LOW, value2);
 
 		if (level != aniState->firstepLevel) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "firstep[level]=%d ini=%d\n",
 				  chan->channel,
@@ -1372,7 +1372,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 				  ATH9K_ANI_FIRSTEP_LVL_NEW,
 				  value,
 				  aniState->iniDef.firstep);
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "firstep_low[level]=%d ini=%d\n",
 				  chan->channel,
@@ -1393,7 +1393,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1_table)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level "
 				  "out of range (%u > %u)\n",
 				  level,
@@ -1431,7 +1431,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 			      AR_PHY_EXT_TIMING5_CYCPWR_THR1, value2);
 
 		if (level != aniState->spurImmunityLevel) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "cycpwrThr1[level]=%d ini=%d\n",
 				  chan->channel,
@@ -1440,7 +1440,7 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
 				  value,
 				  aniState->iniDef.cycpwrThr1);
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "cycpwrThr1Ext[level]=%d ini=%d\n",
 				  chan->channel,
@@ -1467,12 +1467,12 @@ static bool ar5008_hw_ani_control_new(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "ANI parameters: SI=%d, ofdmWS=%s FS=%d "
 		  "MRCcck=%s listenTime=%d "
 		  "ofdmErrs=%d cckErrs=%d\n",
@@ -1528,7 +1528,7 @@ static void ar5008_hw_ani_cache_ini_regs(struct ath_hw *ah)
 
 	iniDef = &aniState->iniDef;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "ver %d.%d opmode %u chan %d Mhz/0x%x\n",
 		  ah->hw_version.macVersion,
 		  ah->hw_version.macRev,
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_calib.c b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
index 15f62cd..1d48c0c 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
@@ -39,17 +39,17 @@ static void ar9002_hw_setup_calibration(struct ath_hw *ah,
 	switch (currCal->calData->calType) {
 	case IQ_MISMATCH_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_IQ);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "starting IQ Mismatch Calibration\n");
 		break;
 	case ADC_GAIN_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_ADC_GAIN);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "starting ADC Gain Calibration\n");
 		break;
 	case ADC_DC_CAL:
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_ADC_DC_PER);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "starting ADC DC Calibration\n");
 		break;
 	}
@@ -107,7 +107,7 @@ static void ar9002_hw_iqcal_collect(struct ath_hw *ah)
 			REG_READ(ah, AR_PHY_CAL_MEAS_1(i));
 		ah->totalIqCorrMeas[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_2(i));
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
 			  "%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
 			  ah->cal_samples, i, ah->totalPowerMeasI[i],
 			  ah->totalPowerMeasQ[i],
@@ -129,7 +129,7 @@ static void ar9002_hw_adc_gaincal_collect(struct ath_hw *ah)
 		ah->totalAdcQEvenPhase[i] +=
 			REG_READ(ah, AR_PHY_CAL_MEAS_3(i));
 
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
 			  "%d: Chn %d oddi=0x%08x; eveni=0x%08x; "
 			  "oddq=0x%08x; evenq=0x%08x;\n",
 			  ah->cal_samples, i,
@@ -154,7 +154,7 @@ static void ar9002_hw_adc_dccal_collect(struct ath_hw *ah)
 		ah->totalAdcDcOffsetQEvenPhase[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_3(i));
 
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
 			  "%d: Chn %d oddi=0x%08x; eveni=0x%08x; "
 			  "oddq=0x%08x; evenq=0x%08x;\n",
 			  ah->cal_samples, i,
@@ -178,11 +178,11 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		powerMeasQ = ah->totalPowerMeasQ[i];
 		iqCorrMeas = ah->totalIqCorrMeas[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Starting IQ Cal and Correction for Chain %d\n",
 			  i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Orignal: Chn %diq_corr_meas = 0x%08x\n",
 			  i, ah->totalIqCorrMeas[i]);
 
@@ -193,11 +193,11 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iqCorrNeg = 1;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
-		ath_print(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
+		ath_debug(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
 			  iqCorrNeg);
 
 		iCoffDenom = (powerMeasI / 2 + powerMeasQ / 2) / 128;
@@ -207,13 +207,13 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		    (qCoffDenom != 0)) {
 			iCoff = iqCorrMeas / iCoffDenom;
 			qCoff = powerMeasI / qCoffDenom - 64;
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d iCoff = 0x%08x\n", i, iCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d qCoff = 0x%08x\n", i, qCoff);
 
 			iCoff = iCoff & 0x3f;
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "New: Chn %d iCoff = 0x%08x\n", i, iCoff);
 			if (iqCorrNeg == 0x0)
 				iCoff = 0x40 - iCoff;
@@ -223,7 +223,7 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			else if (qCoff <= -16)
 				qCoff = -16;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
 				  i, iCoff, qCoff);
 
@@ -233,7 +233,7 @@ static void ar9002_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			REG_RMW_FIELD(ah, AR_PHY_TIMING_CTRL4(i),
 				      AR_PHY_TIMING_CTRL4_IQCORR_Q_Q_COFF,
 				      qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "IQ Cal and Correction done for Chain %d\n",
 				  i);
 		}
@@ -255,19 +255,19 @@ static void ar9002_hw_adc_gaincal_calibrate(struct ath_hw *ah, u8 numChains)
 		qOddMeasOffset = ah->totalAdcQOddPhase[i];
 		qEvenMeasOffset = ah->totalAdcQEvenPhase[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Starting ADC Gain Cal for Chain %d\n", i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_odd_i = 0x%08x\n", i,
 			  iOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_even_i = 0x%08x\n", i,
 			  iEvenMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_odd_q = 0x%08x\n", i,
 			  qOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_even_q = 0x%08x\n", i,
 			  qEvenMeasOffset);
 
@@ -279,10 +279,10 @@ static void ar9002_hw_adc_gaincal_calibrate(struct ath_hw *ah, u8 numChains)
 				((qOddMeasOffset * 32) /
 				 qEvenMeasOffset) & 0x3f;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d gain_mismatch_i = 0x%08x\n", i,
 				  iGainMismatch);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d gain_mismatch_q = 0x%08x\n", i,
 				  qGainMismatch);
 
@@ -291,7 +291,7 @@ static void ar9002_hw_adc_gaincal_calibrate(struct ath_hw *ah, u8 numChains)
 			val |= (qGainMismatch) | (iGainMismatch << 6);
 			REG_WRITE(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i), val);
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "ADC Gain Cal done for Chain %d\n", i);
 		}
 	}
@@ -317,19 +317,19 @@ static void ar9002_hw_adc_dccal_calibrate(struct ath_hw *ah, u8 numChains)
 		qOddMeasOffset = ah->totalAdcDcOffsetQOddPhase[i];
 		qEvenMeasOffset = ah->totalAdcDcOffsetQEvenPhase[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			   "Starting ADC DC Offset Cal for Chain %d\n", i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_odd_i = %d\n", i,
 			  iOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_even_i = %d\n", i,
 			  iEvenMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_odd_q = %d\n", i,
 			  qOddMeasOffset);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_even_q = %d\n", i,
 			  qEvenMeasOffset);
 
@@ -338,10 +338,10 @@ static void ar9002_hw_adc_dccal_calibrate(struct ath_hw *ah, u8 numChains)
 		qDcMismatch = (((qOddMeasOffset - qEvenMeasOffset) * 2) /
 			       numSamples) & 0x1ff;
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d dc_offset_mismatch_i = 0x%08x\n", i,
 			  iDcMismatch);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d dc_offset_mismatch_q = 0x%08x\n", i,
 			  qDcMismatch);
 
@@ -350,7 +350,7 @@ static void ar9002_hw_adc_dccal_calibrate(struct ath_hw *ah, u8 numChains)
 		val |= (qDcMismatch << 12) | (iDcMismatch << 21);
 		REG_WRITE(ah, AR_PHY_NEW_ADC_DC_GAIN_CORR(i), val);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "ADC DC Offset Cal done for Chain %d\n", i);
 	}
 
@@ -540,7 +540,7 @@ static inline void ar9285_hw_pa_cal(struct ath_hw *ah, bool is_reset)
 		{ 0x7838, 0 },
 	};
 
-	ath_print(common, ATH_DBG_CALIBRATE, "Running PA Calibration\n");
+	ath_debug(common, ATH_DBG_CALIBRATE, "Running PA Calibration\n");
 
 	/* PA CAL is not needed for high power solution */
 	if (ah->eep_ops->get_eeprom(ah, EEP_TXGAIN_TYPE) ==
@@ -721,7 +721,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 		REG_SET_BIT(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL);
 		if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL,
 				  AR_PHY_AGC_CONTROL_CAL, 0, AH_WAIT_TIMEOUT)) {
-			ath_print(common, ATH_DBG_CALIBRATE, "offset "
+			ath_debug(common, ATH_DBG_CALIBRATE, "offset "
 				  "calibration failed to complete in "
 				  "1ms; noisy ??\n");
 			return false;
@@ -736,7 +736,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 	REG_SET_BIT(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL);
 	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
 			  0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE, "offset calibration "
+		ath_debug(common, ATH_DBG_CALIBRATE, "offset calibration "
 			  "failed to complete in 1ms; noisy ??\n");
 		return false;
 	}
@@ -829,7 +829,7 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 		if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL,
 				   AR_PHY_AGC_CONTROL_CAL,
 				   0, AH_WAIT_TIMEOUT)) {
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "offset calibration failed to "
 				  "complete in 1ms; noisy environment?\n");
 			return false;
@@ -866,18 +866,18 @@ static bool ar9002_hw_init_cal(struct ath_hw *ah, struct ath9k_channel *chan)
 
 			INIT_CAL(&ah->adcgain_caldata);
 			INSERT_CAL(ah, &ah->adcgain_caldata);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "enabling ADC Gain Calibration.\n");
 
 			INIT_CAL(&ah->adcdc_caldata);
 			INSERT_CAL(ah, &ah->adcdc_caldata);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "enabling ADC DC Calibration.\n");
 		}
 
 		INIT_CAL(&ah->iq_caldata);
 		INSERT_CAL(ah, &ah->iq_caldata);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "enabling IQ Calibration.\n");
 
 		ah->cal_list_curr = ah->cal_list;
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index 48261b7..550f8b4 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -494,7 +494,7 @@ int ar9002_hw_rf_claim(struct ath_hw *ah)
 	case AR_RAD2122_SREV_MAJOR:
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Radio Chip Rev 0x%02X not supported\n",
 			  val & AR_RADIO_SREV_MAJOR);
 		return -EOPNOTSUPP;
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_mac.c b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
index f0268e5..c6b6725 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_mac.c
@@ -111,7 +111,7 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		}
 
 		if (isr & AR_ISR_RXORN) {
-			ath_print(common, ATH_DBG_INTERRUPT,
+			ath_debug(common, ATH_DBG_INTERRUPT,
 				  "receive FIFO overrun interrupt\n");
 		}
 
@@ -147,24 +147,24 @@ static bool ar9002_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 
 		if (fatal_int) {
 			if (sync_cause & AR_INTR_SYNC_HOST1_FATAL) {
-				ath_print(common, ATH_DBG_ANY,
+				ath_debug(common, ATH_DBG_ANY,
 					  "received PCI FATAL interrupt\n");
 			}
 			if (sync_cause & AR_INTR_SYNC_HOST1_PERR) {
-				ath_print(common, ATH_DBG_ANY,
+				ath_debug(common, ATH_DBG_ANY,
 					  "received PCI PERR interrupt\n");
 			}
 			*masked |= ATH9K_INT_FATAL;
 		}
 		if (sync_cause & AR_INTR_SYNC_RADM_CPL_TIMEOUT) {
-			ath_print(common, ATH_DBG_INTERRUPT,
+			ath_debug(common, ATH_DBG_INTERRUPT,
 				  "AR_INTR_SYNC_RADM_CPL_TIMEOUT\n");
 			REG_WRITE(ah, AR_RC, AR_RC_HOSTIF);
 			REG_WRITE(ah, AR_RC, 0);
 			*masked |= ATH9K_INT_FATAL;
 		}
 		if (sync_cause & AR_INTR_SYNC_LOCAL_TIMEOUT) {
-			ath_print(common, ATH_DBG_INTERRUPT,
+			ath_debug(common, ATH_DBG_INTERRUPT,
 				  "AR_INTR_SYNC_LOCAL_TIMEOUT\n");
 		}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 4c94c9e..f3a3092 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -40,7 +40,7 @@ static void ar9003_hw_setup_calibration(struct ath_hw *ah,
 		currCal->calData->calCountMax);
 		REG_WRITE(ah, AR_PHY_CALMODE, AR_PHY_CALMODE_IQ);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "starting IQ Mismatch Calibration\n");
 
 		/* Kick-off cal */
@@ -52,7 +52,7 @@ static void ar9003_hw_setup_calibration(struct ath_hw *ah,
 		REG_RMW_FIELD(ah, AR_PHY_65NM_CH0_THERM,
 			      AR_PHY_65NM_CH0_THERM_START, 1);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "starting Temperature Compensation Calibration\n");
 		break;
 	}
@@ -181,7 +181,7 @@ static void ar9003_hw_iqcal_collect(struct ath_hw *ah)
 			REG_READ(ah, AR_PHY_CAL_MEAS_1(i));
 		ah->totalIqCorrMeas[i] +=
 			(int32_t) REG_READ(ah, AR_PHY_CAL_MEAS_2(i));
-		ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
 			  "%d: Chn %d pmi=0x%08x;pmq=0x%08x;iqcm=0x%08x;\n",
 			  ah->cal_samples, i, ah->totalPowerMeasI[i],
 			  ah->totalPowerMeasQ[i],
@@ -207,11 +207,11 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		powerMeasQ = ah->totalPowerMeasQ[i];
 		iqCorrMeas = ah->totalIqCorrMeas[i];
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Starting IQ Cal and Correction for Chain %d\n",
 			  i);
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Orignal: Chn %diq_corr_meas = 0x%08x\n",
 			  i, ah->totalIqCorrMeas[i]);
 
@@ -222,11 +222,11 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iqCorrNeg = 1;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_i = 0x%08x\n", i, powerMeasI);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Chn %d pwr_meas_q = 0x%08x\n", i, powerMeasQ);
-		ath_print(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
+		ath_debug(common, ATH_DBG_CALIBRATE, "iqCorrNeg is 0x%08x\n",
 			  iqCorrNeg);
 
 		iCoffDenom = (powerMeasI / 2 + powerMeasQ / 2) / 256;
@@ -235,9 +235,9 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 		if ((iCoffDenom != 0) && (qCoffDenom != 0)) {
 			iCoff = iqCorrMeas / iCoffDenom;
 			qCoff = powerMeasI / qCoffDenom - 64;
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d iCoff = 0x%08x\n", i, iCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d qCoff = 0x%08x\n", i, qCoff);
 
 			/* Force bounds on iCoff */
@@ -259,10 +259,10 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			iCoff = iCoff & 0x7f;
 			qCoff = qCoff & 0x7f;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Chn %d : iCoff = 0x%x  qCoff = 0x%x\n",
 				  i, iCoff, qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Register offset (0x%04x) "
 				  "before update = 0x%x\n",
 				  offset_array[i],
@@ -274,20 +274,20 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 			REG_RMW_FIELD(ah, offset_array[i],
 				      AR_PHY_RX_IQCAL_CORR_IQCORR_Q_Q_COFF,
 				      qCoff);
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Register offset (0x%04x) QI COFF "
 				  "(bitfields 0x%08x) after update = 0x%x\n",
 				  offset_array[i],
 				  AR_PHY_RX_IQCAL_CORR_IQCORR_Q_I_COFF,
 				  REG_READ(ah, offset_array[i]));
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Register offset (0x%04x) QQ COFF "
 				  "(bitfields 0x%08x) after update = 0x%x\n",
 				  offset_array[i],
 				  AR_PHY_RX_IQCAL_CORR_IQCORR_Q_Q_COFF,
 				  REG_READ(ah, offset_array[i]));
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "IQ Cal and Correction done for Chain %d\n",
 				  i);
 		}
@@ -295,7 +295,7 @@ static void ar9003_hw_iqcalibrate(struct ath_hw *ah, u8 numChains)
 
 	REG_SET_BIT(ah, AR_PHY_RX_IQCAL_CORR_B0,
 		    AR_PHY_RX_IQCAL_CORR_IQCORR_ENABLE);
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "IQ Cal and Correction (offset 0x%04x) enabled "
 		  "(bit position 0x%08x). New Value 0x%08x\n",
 		  (unsigned) (AR_PHY_RX_IQCAL_CORR_B0),
@@ -340,7 +340,7 @@ static bool ar9003_hw_solve_iq_cal(struct ath_hw *ah,
 	f2 = (f1 * f1 + f3 * f3) / result_shift;
 
 	if (!f2) {
-		ath_print(common, ATH_DBG_CALIBRATE, "Divide by 0\n");
+		ath_debug(common, ATH_DBG_CALIBRATE, "Divide by 0\n");
 		return false;
 	}
 
@@ -461,7 +461,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	if ((i2_p_q2_a0_d0 == 0) || (i2_p_q2_a0_d1 == 0) ||
 	    (i2_p_q2_a1_d0 == 0) || (i2_p_q2_a1_d1 == 0)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Divide by 0:\na0_d0=%d\n"
 			  "a0_d1=%d\na2_d0=%d\na1_d1=%d\n",
 			  i2_p_q2_a0_d0, i2_p_q2_a0_d1,
@@ -498,7 +498,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	mag2 = ar9003_hw_find_mag_approx(ah, cos_2phi_2, sin_2phi_2);
 
 	if ((mag1 == 0) || (mag2 == 0)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Divide by 0: mag1=%d, mag2=%d\n",
 			  mag1, mag2);
 		return false;
@@ -517,7 +517,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 			     mag_a0_d0, phs_a0_d0,
 			     mag_a1_d0,
 			     phs_a1_d0, solved_eq)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Call to ar9003_hw_solve_iq_cal() failed.\n");
 		return false;
 	}
@@ -527,12 +527,12 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	mag_rx = solved_eq[2];
 	phs_rx = solved_eq[3];
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "chain %d: mag mismatch=%d phase mismatch=%d\n",
 		  chain_idx, mag_tx/res_scale, phs_tx/res_scale);
 
 	if (res_scale == mag_tx) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Divide by 0: mag_tx=%d, res_scale=%d\n",
 			  mag_tx, res_scale);
 		return false;
@@ -545,7 +545,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	q_q_coff = (mag_corr_tx * 128 / res_scale);
 	q_i_coff = (phs_corr_tx * 256 / res_scale);
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "tx chain %d: mag corr=%d  phase corr=%d\n",
 		  chain_idx, q_q_coff, q_i_coff);
 
@@ -560,12 +560,12 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	iqc_coeff[0] = (q_q_coff * 128) + q_i_coff;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "tx chain %d: iq corr coeff=%x\n",
 		  chain_idx, iqc_coeff[0]);
 
 	if (-mag_rx == res_scale) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Divide by 0: mag_rx=%d, res_scale=%d\n",
 			  mag_rx, res_scale);
 		return false;
@@ -578,7 +578,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	q_q_coff = (mag_corr_rx * 128 / res_scale);
 	q_i_coff = (phs_corr_rx * 256 / res_scale);
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "rx chain %d: mag corr=%d  phase corr=%d\n",
 		  chain_idx, q_q_coff, q_i_coff);
 
@@ -593,7 +593,7 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 
 	iqc_coeff[1] = (q_q_coff * 128) + q_i_coff;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "rx chain %d: iq corr coeff=%x\n",
 		  chain_idx, iqc_coeff[1]);
 
@@ -643,18 +643,18 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 	if (!ath9k_hw_wait(ah, AR_PHY_TX_IQCAL_START,
 			   AR_PHY_TX_IQCAL_START_DO_CAL,
 			   0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Tx IQ Cal not complete.\n");
 		goto TX_IQ_CAL_FAILED;
 	}
 
 	for (i = 0; i < num_chains; i++) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Doing Tx IQ Cal for chain %d.\n", i);
 
 		if (REG_READ(ah, txiqcal_status[i]) &
 			     AR_PHY_TX_IQCAL_STATUS_FAILED) {
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Tx IQ Cal failed for chain %d.\n", i);
 			goto TX_IQ_CAL_FAILED;
 		}
@@ -677,18 +677,18 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 							  chan_info_tab[i] +
 							  offset);
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "IQ RES[%d]=0x%x IQ_RES[%d]=0x%x\n",
 				  idx, iq_res[idx], idx+1, iq_res[idx+1]);
 		}
 
 		if (!ar9003_hw_calc_iq_corr(ah, i, iq_res, iqc_coeff)) {
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "Failed in calculation of IQ correction.\n");
 			goto TX_IQ_CAL_FAILED;
 		}
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "IQ_COEFF[0] = 0x%x IQ_COEFF[1] = 0x%x\n",
 			  iqc_coeff[0], iqc_coeff[1]);
 
@@ -711,7 +711,7 @@ static void ar9003_hw_tx_iq_cal(struct ath_hw *ah)
 	return;
 
 TX_IQ_CAL_FAILED:
-	ath_print(common, ATH_DBG_CALIBRATE, "Tx IQ Cal failed\n");
+	ath_debug(common, ATH_DBG_CALIBRATE, "Tx IQ Cal failed\n");
 }
 
 static bool ar9003_hw_init_cal(struct ath_hw *ah,
@@ -721,7 +721,7 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	int val;
 
 	val = REG_READ(ah, AR_ENT_OTP);
-	ath_print(common, ATH_DBG_CALIBRATE, "ath9k: AR_ENT_OTP 0x%x\n", val);
+	ath_debug(common, ATH_DBG_CALIBRATE, "ath9k: AR_ENT_OTP 0x%x\n", val);
 
 	if (val & AR_ENT_OTP_CHAIN2_DISABLE)
 		ar9003_hw_set_chain_masks(ah, 0x3, 0x3);
@@ -746,7 +746,7 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	/* Poll for offset calibration complete */
 	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
 			   0, AH_WAIT_TIMEOUT)) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "offset calibration failed to "
 			  "complete in 1ms; noisy environment?\n");
 		return false;
@@ -764,14 +764,14 @@ static bool ar9003_hw_init_cal(struct ath_hw *ah,
 	if (ah->supp_cals & IQ_MISMATCH_CAL) {
 		INIT_CAL(&ah->iq_caldata);
 		INSERT_CAL(ah, &ah->iq_caldata);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "enabling IQ Calibration.\n");
 	}
 
 	if (ah->supp_cals & TEMP_COMP_CAL) {
 		INIT_CAL(&ah->tempCompCalData);
 		INSERT_CAL(ah, &ah->tempCompCalData);
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "enabling Temperature Compensation Calibration.\n");
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 3161a59..0926bec 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3067,7 +3067,7 @@ static bool ar9300_read_eeprom(struct ath_hw *ah, int address, u8 *buffer,
 	int i;
 
 	if ((address < 0) || ((address + count) / 2 > AR9300_EEPROM_SIZE - 1)) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "eeprom address not in range\n");
 		return false;
 	}
@@ -3099,7 +3099,7 @@ static bool ar9300_read_eeprom(struct ath_hw *ah, int address, u8 *buffer,
 	return true;
 
 error:
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		  "unable to read eeprom region at offset %d\n", address);
 	return false;
 }
@@ -3184,14 +3184,14 @@ static bool ar9300_uncompress_block(struct ath_hw *ah,
 		length &= 0xff;
 
 		if (length > 0 && spot >= 0 && spot+length <= mdataSize) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Restore at %d: spot=%d "
 				  "offset=%d length=%d\n",
 				   it, spot, offset, length);
 			memcpy(&mptr[spot], &block[it+2], length);
 			spot += length;
 		} else if (length > 0) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Bad restore at %d: spot=%d "
 				  "offset=%d length=%d\n",
 				  it, spot, offset, length);
@@ -3215,13 +3215,13 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 	switch (code) {
 	case _CompressNone:
 		if (length != mdata_size) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "EEPROM structure size mismatch"
 				  "memory=%d eeprom=%d\n", mdata_size, length);
 			return -1;
 		}
 		memcpy(mptr, (u8 *) (word + COMP_HDR_LEN), length);
-		ath_print(common, ATH_DBG_EEPROM, "restored eeprom %d:"
+		ath_debug(common, ATH_DBG_EEPROM, "restored eeprom %d:"
 			  " uncompressed, length %d\n", it, length);
 		break;
 	case _CompressBlock:
@@ -3230,21 +3230,21 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 		} else {
 			eep = ar9003_eeprom_struct_find_by_id(reference);
 			if (eep == NULL) {
-				ath_print(common, ATH_DBG_EEPROM,
+				ath_debug(common, ATH_DBG_EEPROM,
 					  "cant find reference eeprom"
 					  "struct %d\n", reference);
 				return -1;
 			}
 			memcpy(mptr, eep, mdata_size);
 		}
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "restore eeprom %d: block, reference %d,"
 			  " length %d\n", it, reference, length);
 		ar9300_uncompress_block(ah, mptr, mdata_size,
 					(u8 *) (word + COMP_HDR_LEN), length);
 		break;
 	default:
-		ath_print(common, ATH_DBG_EEPROM, "unknown compression"
+		ath_debug(common, ATH_DBG_EEPROM, "unknown compression"
 			  " code %d\n", code);
 		return -1;
 	}
@@ -3316,26 +3316,26 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
 
 	read = ar9300_read_eeprom;
 	cptr = AR9300_BASE_ADDR;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		"Trying EEPROM accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	cptr = AR9300_BASE_ADDR_512;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		"Trying EEPROM accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	read = ar9300_read_otp;
 	cptr = AR9300_BASE_ADDR;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		"Trying OTP accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
 
 	cptr = AR9300_BASE_ADDR_512;
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		"Trying OTP accesss at Address 0x%04x\n", cptr);
 	if (ar9300_check_eeprom_header(ah, read, cptr))
 		goto found;
@@ -3343,7 +3343,7 @@ static int ar9300_eeprom_restore_internal(struct ath_hw *ah,
 	goto fail;
 
 found:
-	ath_print(common, ATH_DBG_EEPROM, "Found valid EEPROM data");
+	ath_debug(common, ATH_DBG_EEPROM, "Found valid EEPROM data");
 
 	for (it = 0; it < MSTATE; it++) {
 		if (!read(ah, cptr, word, COMP_HDR_LEN))
@@ -3354,12 +3354,12 @@ found:
 
 		ar9300_comp_hdr_unpack(word, &code, &reference,
 				       &length, &major, &minor);
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Found block at %x: code=%d ref=%d"
 			  "length=%d major=%d minor=%d\n", cptr, code,
 			  reference, length, major, minor);
 		if (length >= 1024) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Skipping bad header\n");
 			cptr -= COMP_HDR_LEN;
 			continue;
@@ -3370,13 +3370,13 @@ found:
 		checksum = ar9300_comp_cksum(&word[COMP_HDR_LEN], length);
 		mchecksum = word[COMP_HDR_LEN + osize] |
 		    (word[COMP_HDR_LEN + osize + 1] << 8);
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "checksum %x %x\n", checksum, mchecksum);
 		if (checksum == mchecksum) {
 			ar9300_compress_decision(ah, it, code, reference, mptr,
 						 word, length, mdata_size);
 		} else {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "skipping block with bad checksum\n");
 		}
 		cptr -= (COMP_HDR_LEN + osize + COMP_CKSUM_LEN);
@@ -4087,19 +4087,19 @@ static void ar9003_hw_set_target_power_eeprom(struct ath_hw *ah, u16 freq,
 					      is2GHz) + ht40PowerIncForPdadc;
 
 	while (i < ar9300RateSize) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x\n", i, targetPowerValT2[i]);
 		i++;
 	}
@@ -4120,7 +4120,7 @@ static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	if (ichain >= AR9300_MAX_CHAINS) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Invalid chain index, must be less than %d\n",
 			  AR9300_MAX_CHAINS);
 		return -1;
@@ -4128,7 +4128,7 @@ static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
 
 	if (mode) {		/* 5GHz */
 		if (ipier >= AR9300_NUM_5G_CAL_PIERS) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Invalid 5GHz cal pier index, must "
 				  "be less than %d\n",
 				  AR9300_NUM_5G_CAL_PIERS);
@@ -4139,7 +4139,7 @@ static int ar9003_hw_cal_pier_get(struct ath_hw *ah,
 		is2GHz = 0;
 	} else {
 		if (ipier >= AR9300_NUM_2G_CAL_PIERS) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Invalid 2GHz cal pier index, must "
 				  "be less than %d\n", AR9300_NUM_2G_CAL_PIERS);
 			return -1;
@@ -4291,7 +4291,7 @@ static int ar9003_hw_calibration_apply(struct ath_hw *ah, int frequency)
 
 	/* interpolate  */
 	for (ichain = 0; ichain < AR9300_MAX_CHAINS; ichain++) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "ch=%d f=%d low=%d %d h=%d %d\n",
 			  ichain, frequency, lfrequency[ichain],
 			  lcorrection[ichain], hfrequency[ichain],
@@ -4347,7 +4347,7 @@ static int ar9003_hw_calibration_apply(struct ath_hw *ah, int frequency)
 	ar9003_hw_power_control_override(ah, frequency, correction, voltage,
 					 temperature);
 
-	ath_print(common, ATH_DBG_EEPROM,
+	ath_debug(common, ATH_DBG_EEPROM,
 		  "for frequency=%d, calibration correction = %d %d %d\n",
 		  frequency, correction[0], correction[1], correction[2]);
 
@@ -4554,7 +4554,7 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 		else
 			freq = centers.ctl_center;
 
-		ath_print(common, ATH_DBG_REGULATORY,
+		ath_debug(common, ATH_DBG_REGULATORY,
 			  "LOOP-Mode ctlMode %d < %d, isHt40CtlMode %d, "
 			  "EXT_ADDITIVE %d\n",
 			  ctlMode, numCtlModes, isHt40CtlMode,
@@ -4570,7 +4570,7 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 		}
 
 		for (i = 0; (i < ctlNum) && ctlIndex[i]; i++) {
-			ath_print(common, ATH_DBG_REGULATORY,
+			ath_debug(common, ATH_DBG_REGULATORY,
 				  "LOOP-Ctlidx %d: cfgCtl 0x%2.2x "
 				  "pCtlMode 0x%2.2x ctlIndex 0x%2.2x "
 				  "chan %dn",
@@ -4614,7 +4614,7 @@ static void ar9003_hw_set_power_per_rate_table(struct ath_hw *ah,
 
 			minCtlPower = (u8)min(twiceMaxEdgePower, scaledPower);
 
-			ath_print(common, ATH_DBG_REGULATORY,
+			ath_debug(common, ATH_DBG_REGULATORY,
 				  "SEL-Min ctlMode %d pCtlMode %d 2xMaxEdge %d "
 				  "sP %d minCtlPwr %d\n",
 				  ctlMode, pCtlMode[ctlMode], twiceMaxEdgePower,
@@ -4693,16 +4693,16 @@ static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 		return;
 
 	for (i = 0; i < ar9300RateSize; i++) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x ", i, targetPowerValT2[i]);
 		i++;
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "TPC[%02d] 0x%08x\n\n", i, targetPowerValT2[i]);
 		i++;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index f5896aa..be9703a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -182,7 +182,7 @@ static bool ar9003_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 		}
 
 		if (sync_cause & AR_INTR_SYNC_LOCAL_TIMEOUT)
-			ath_print(common, ATH_DBG_INTERRUPT,
+			ath_debug(common, ATH_DBG_INTERRUPT,
 				  "AR_INTR_SYNC_LOCAL_TIMEOUT\n");
 
 		REG_WRITE(ah, AR_INTR_SYNC_CAUSE_CLR, sync_cause);
@@ -249,7 +249,7 @@ static int ar9003_hw_proc_txdesc(struct ath_hw *ah, void *ds,
 
 	if ((MS(ads->ds_info, AR_DescId) != ATHEROS_VENDOR_ID) ||
 	    (MS(ads->ds_info, AR_TxRxDesc) != 1)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_XMIT,
 			  "Tx Descriptor error %x\n", ads->ds_info);
 		memset(ads, 0, sizeof(*ads));
 		return -EIO;
@@ -658,7 +658,7 @@ void ath9k_hw_reset_txstatus_ring(struct ath_hw *ah)
 	memset((void *) ah->ts_ring, 0,
 		ah->ts_size * sizeof(struct ar9003_txs));
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_XMIT,
 		  "TS Start 0x%x End 0x%x Virt %p, Size %d\n",
 		   ah->ts_paddr_start, ah->ts_paddr_end,
 		   ah->ts_ring, ah->ts_size);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index 656d8ce..e523473 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -820,7 +820,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 				    AR_PHY_SFCORR_LOW_USE_SELF_CORR_LOW);
 
 		if (!on != aniState->ofdmWeakSigDetectOff) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: ofdm weak signal: %s=>%s\n",
 				  chan->channel,
 				  !aniState->ofdmWeakSigDetectOff ?
@@ -838,7 +838,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(firstep_table)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "ATH9K_ANI_FIRSTEP_LEVEL: level "
 				  "out of range (%u > %u)\n",
 				  level,
@@ -877,7 +877,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 			      AR_PHY_FIND_SIG_LOW_FIRSTEP_LOW, value2);
 
 		if (level != aniState->firstepLevel) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "firstep[level]=%d ini=%d\n",
 				  chan->channel,
@@ -886,7 +886,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 				  ATH9K_ANI_FIRSTEP_LVL_NEW,
 				  value,
 				  aniState->iniDef.firstep);
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "firstep_low[level]=%d ini=%d\n",
 				  chan->channel,
@@ -907,7 +907,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		u32 level = param;
 
 		if (level >= ARRAY_SIZE(cycpwrThr1_table)) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "ATH9K_ANI_SPUR_IMMUNITY_LEVEL: level "
 				  "out of range (%u > %u)\n",
 				  level,
@@ -945,7 +945,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 			      AR_PHY_EXT_CYCPWR_THR1, value2);
 
 		if (level != aniState->spurImmunityLevel) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "cycpwrThr1[level]=%d ini=%d\n",
 				  chan->channel,
@@ -954,7 +954,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 				  ATH9K_ANI_SPUR_IMMUNE_LVL_NEW,
 				  value,
 				  aniState->iniDef.cycpwrThr1);
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: level %d=>%d[def:%d] "
 				  "cycpwrThr1Ext[level]=%d ini=%d\n",
 				  chan->channel,
@@ -982,7 +982,7 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 		REG_RMW_FIELD(ah, AR_PHY_MRC_CCK_CTRL,
 			      AR_PHY_MRC_CCK_MUX_REG, is_on);
 		if (!is_on != aniState->mrcCCKOff) {
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "** ch %d: MRC CCK: %s=>%s\n",
 				  chan->channel,
 				  !aniState->mrcCCKOff ? "on" : "off",
@@ -998,12 +998,12 @@ static bool ar9003_hw_ani_control(struct ath_hw *ah,
 	case ATH9K_ANI_PRESENT:
 		break;
 	default:
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "invalid cmd %u\n", cmd);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "ANI parameters: SI=%d, ofdmWS=%s FS=%d "
 		  "MRCcck=%s listenTime=%d "
 		  "ofdmErrs=%d cckErrs=%d\n",
@@ -1070,7 +1070,7 @@ static void ar9003_hw_ani_cache_ini_regs(struct ath_hw *ah)
 	aniState = &ah->curchan->ani;
 	iniDef = &aniState->iniDef;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "ver %d.%d opmode %u chan %d Mhz/0x%x\n",
 		  ah->hw_version.macVersion,
 		  ah->hw_version.macRev,
@@ -1212,7 +1212,7 @@ void ar9003_hw_bb_watchdog_config(struct ath_hw *ah)
 			  ~(AR_PHY_WATCHDOG_NON_IDLE_ENABLE |
 			    AR_PHY_WATCHDOG_IDLE_ENABLE));
 
-		ath_print(common, ATH_DBG_RESET, "Disabled BB Watchdog\n");
+		ath_debug(common, ATH_DBG_RESET, "Disabled BB Watchdog\n");
 		return;
 	}
 
@@ -1248,7 +1248,7 @@ void ar9003_hw_bb_watchdog_config(struct ath_hw *ah)
 		  AR_PHY_WATCHDOG_IDLE_MASK |
 		  (AR_PHY_WATCHDOG_NON_IDLE_MASK & (idle_count << 2)));
 
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "Enabled BB Watchdog timeout (%u ms)\n",
 		  idle_tmo_ms);
 }
@@ -1278,9 +1278,9 @@ void ar9003_hw_bb_watchdog_dbg_info(struct ath_hw *ah)
 		return;
 
 	status = ah->bb_watchdog_last_status;
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "\n==== BB update: BB status=0x%08x ====\n", status);
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "** BB state: wd=%u det=%u rdar=%u rOFDM=%d "
 		  "rCCK=%u tOFDM=%u tCCK=%u agc=%u src=%u **\n",
 		  MS(status, AR_PHY_WATCHDOG_INFO),
@@ -1293,22 +1293,22 @@ void ar9003_hw_bb_watchdog_dbg_info(struct ath_hw *ah)
 		  MS(status, AR_PHY_WATCHDOG_AGC_SM),
 		  MS(status,AR_PHY_WATCHDOG_SRCH_SM));
 
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "** BB WD cntl: cntl1=0x%08x cntl2=0x%08x **\n",
 		  REG_READ(ah, AR_PHY_WATCHDOG_CTL_1),
 		  REG_READ(ah, AR_PHY_WATCHDOG_CTL_2));
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "** BB mode: BB_gen_controls=0x%08x **\n",
 		  REG_READ(ah, AR_PHY_GEN_CTRL));
 
 #define PCT(_field) (common->cc_survey._field * 100 / common->cc_survey.cycles)
 	if (common->cc_survey.cycles)
-		ath_print(common, ATH_DBG_RESET,
+		ath_debug(common, ATH_DBG_RESET,
 			  "** BB busy times: rx_clear=%d%%, "
 			  "rx_frame=%d%%, tx_frame=%d%% **\n",
 			  PCT(rx_busy), PCT(rx_frame), PCT(tx_frame));
 
-	ath_print(common, ATH_DBG_RESET,
+	ath_debug(common, ATH_DBG_RESET,
 		  "==== BB update: done ====\n\n");
 }
 EXPORT_SYMBOL(ar9003_hw_bb_watchdog_dbg_info);
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 30724a4..0e3678e 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -46,7 +46,7 @@ int ath_beaconq_config(struct ath_softc *sc)
 	}
 
 	if (!ath9k_hw_set_txq_props(ah, sc->beacon.beaconq, &qi)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to update h/w beacon queue parameters\n");
 		return 0;
 	} else {
@@ -119,11 +119,11 @@ static void ath_tx_cabq(struct ieee80211_hw *hw, struct sk_buff *skb)
 	memset(&txctl, 0, sizeof(struct ath_tx_control));
 	txctl.txq = sc->beacon.cabq;
 
-	ath_print(common, ATH_DBG_XMIT,
+	ath_debug(common, ATH_DBG_XMIT,
 		  "transmitting CABQ packet, skb: %p\n", skb);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
-		ath_print(common, ATH_DBG_XMIT, "CABQ TX failed\n");
+		ath_debug(common, ATH_DBG_XMIT, "CABQ TX failed\n");
 		dev_kfree_skb_any(skb);
 	}
 }
@@ -188,7 +188,7 @@ static struct ath_buf *ath_beacon_generate(struct ieee80211_hw *hw,
 		dev_kfree_skb_any(skb);
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "dma_mapping_error on beaconing\n");
 		return NULL;
 	}
@@ -209,7 +209,7 @@ static struct ath_buf *ath_beacon_generate(struct ieee80211_hw *hw,
 
 	if (skb && cabq_depth) {
 		if (sc->nvifs > 1) {
-			ath_print(common, ATH_DBG_BEACON,
+			ath_debug(common, ATH_DBG_BEACON,
 				  "Flushing previous cabq traffic\n");
 			ath_draintxq(sc, cabq, false);
 		}
@@ -282,7 +282,7 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 	/* NB: the beacon data buffer must be 32-bit aligned. */
 	skb = ieee80211_beacon_get(sc->hw, vif);
 	if (skb == NULL) {
-		ath_print(common, ATH_DBG_BEACON, "cannot get skb\n");
+		ath_debug(common, ATH_DBG_BEACON, "cannot get skb\n");
 		return -ENOMEM;
 	}
 
@@ -306,7 +306,7 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 		tsfadjust = intval * avp->av_bslot / ATH_BCBUF;
 		avp->tsf_adjust = cpu_to_le64(TU_TO_USEC(tsfadjust));
 
-		ath_print(common, ATH_DBG_BEACON,
+		ath_debug(common, ATH_DBG_BEACON,
 			  "stagger beacons, bslot %d intval "
 			  "%u tsfadjust %llu\n",
 			  avp->av_bslot, intval, (unsigned long long)tsfadjust);
@@ -323,7 +323,7 @@ int ath_beacon_alloc(struct ath_wiphy *aphy, struct ieee80211_vif *vif)
 		dev_kfree_skb_any(skb);
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "dma_mapping_error on beacon alloc\n");
 		return -ENOMEM;
 	}
@@ -381,12 +381,12 @@ void ath_beacon_tasklet(unsigned long data)
 		sc->beacon.bmisscnt++;
 
 		if (sc->beacon.bmisscnt < BSTUCK_THRESH) {
-			ath_print(common, ATH_DBG_BSTUCK,
+			ath_debug(common, ATH_DBG_BSTUCK,
 				  "missed %u consecutive beacons\n",
 				  sc->beacon.bmisscnt);
 			ath9k_hw_bstuck_nfcal(ah);
 		} else if (sc->beacon.bmisscnt >= BSTUCK_THRESH) {
-			ath_print(common, ATH_DBG_BSTUCK,
+			ath_debug(common, ATH_DBG_BSTUCK,
 				  "beacon is officially stuck\n");
 			sc->sc_flags |= SC_OP_TSF_RESET;
 			ath_reset(sc, true);
@@ -396,7 +396,7 @@ void ath_beacon_tasklet(unsigned long data)
 	}
 
 	if (sc->beacon.bmisscnt != 0) {
-		ath_print(common, ATH_DBG_BSTUCK,
+		ath_debug(common, ATH_DBG_BSTUCK,
 			  "resume beacon xmit after %u misses\n",
 			  sc->beacon.bmisscnt);
 		sc->beacon.bmisscnt = 0;
@@ -424,7 +424,7 @@ void ath_beacon_tasklet(unsigned long data)
 	vif = sc->beacon.bslot[slot];
 	aphy = sc->beacon.bslot_aphy[slot];
 
-	ath_print(common, ATH_DBG_BEACON,
+	ath_debug(common, ATH_DBG_BEACON,
 		  "slot %d [tsf %llu tsftu %u intval %u] vif %p\n",
 		  slot, tsf, tsftu, intval, vif);
 
@@ -468,7 +468,7 @@ void ath_beacon_tasklet(unsigned long data)
 		 * are still pending on the queue.
 		 */
 		if (!ath9k_hw_stoptxdma(ah, sc->beacon.beaconq)) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				"beacon queue %u did not stop?\n", sc->beacon.beaconq);
 		}
 
@@ -555,7 +555,7 @@ static void ath_beacon_config_sta(struct ath_softc *sc,
 
 	/* No need to configure beacon if we are not associated */
 	if (!common->curaid) {
-		ath_print(common, ATH_DBG_BEACON,
+		ath_debug(common, ATH_DBG_BEACON,
 			 "STA is not yet associated..skipping beacon config\n");
 		return;
 	}
@@ -649,8 +649,8 @@ static void ath_beacon_config_sta(struct ath_softc *sc,
 	/* TSF out of range threshold fixed at 1 second */
 	bs.bs_tsfoor_threshold = ATH9K_TSFOOR_THRESHOLD;
 
-	ath_print(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
-	ath_print(common, ATH_DBG_BEACON,
+	ath_debug(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
+	ath_debug(common, ATH_DBG_BEACON,
 		  "bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
 		  bs.bs_bmissthreshold, bs.bs_sleepduration,
 		  bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
@@ -689,7 +689,7 @@ static void ath_beacon_config_adhoc(struct ath_softc *sc,
 		nexttbtt += intval;
 	} while (nexttbtt < tsftu);
 
-	ath_print(common, ATH_DBG_BEACON,
+	ath_debug(common, ATH_DBG_BEACON,
 		  "IBSS nexttbtt %u intval %u (%u)\n",
 		  nexttbtt, intval, conf->beacon_interval);
 
@@ -754,7 +754,7 @@ void ath_beacon_config(struct ath_softc *sc, struct ieee80211_vif *vif)
 		ath_beacon_config_sta(sc, cur_conf);
 		break;
 	default:
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Unsupported beaconing mode\n");
 		return;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/calib.c b/drivers/net/wireless/ath/ath9k/calib.c
index 6d50948..04cd2ce 100644
--- a/drivers/net/wireless/ath/ath9k/calib.c
+++ b/drivers/net/wireless/ath/ath9k/calib.c
@@ -97,7 +97,7 @@ static void ath9k_hw_update_nfcal_hist_buffer(struct ath_hw *ah,
 		if (h[i].privNF > limit->max) {
 			high_nf_mid = true;
 
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "NFmid[%d] (%d) > MAX (%d), %s\n",
 				  i, h[i].privNF, limit->max,
 				  (cal->nfcal_interference ?
@@ -180,7 +180,7 @@ bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 		return true;
 
 	if (currCal->calState != CAL_DONE) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "Calibration state incorrect, %d\n",
 			  currCal->calState);
 		return true;
@@ -189,7 +189,7 @@ bool ath9k_hw_reset_calvalid(struct ath_hw *ah)
 	if (!(ah->supp_cals & currCal->calData->calType))
 		return true;
 
-	ath_print(common, ATH_DBG_CALIBRATE,
+	ath_debug(common, ATH_DBG_CALIBRATE,
 		  "Resetting Cal %d state for channel %u\n",
 		  currCal->calData->calType, conf->channel->center_freq);
 
@@ -279,7 +279,7 @@ void ath9k_hw_loadnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	 * noisefloor until the next calibration timer.
 	 */
 	if (j == 1000) {
-		ath_print(common, ATH_DBG_ANY, "Timeout while waiting for nf "
+		ath_debug(common, ATH_DBG_ANY, "Timeout while waiting for nf "
 			  "to load: AR_PHY_AGC_CONTROL=0x%x\n",
 			  REG_READ(ah, AR_PHY_AGC_CONTROL));
 		return;
@@ -318,17 +318,17 @@ static void ath9k_hw_nf_sanitize(struct ath_hw *ah, s16 *nf)
 		if (!nf[i])
 			continue;
 
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "NF calibrated [%s] [chain %d] is %d\n",
 			  (i >= 3 ? "ext" : "ctl"), i % 3, nf[i]);
 
 		if (nf[i] > ATH9K_NF_TOO_HIGH) {
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "NF[%d] (%d) > MAX (%d), correcting to MAX",
 				  i, nf[i], ATH9K_NF_TOO_HIGH);
 			nf[i] = limit->max;
 		} else if (nf[i] < limit->min) {
-			ath_print(common, ATH_DBG_CALIBRATE,
+			ath_debug(common, ATH_DBG_CALIBRATE,
 				  "NF[%d] (%d) < MIN (%d), correcting to NOM",
 				  i, nf[i], limit->min);
 			nf[i] = limit->nominal;
@@ -347,7 +347,7 @@ bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan)
 
 	chan->channelFlags &= (~CHANNEL_CW_INT);
 	if (REG_READ(ah, AR_PHY_AGC_CONTROL) & AR_PHY_AGC_CONTROL_NF) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "NF did not complete in calibration window\n");
 		return false;
 	}
@@ -357,7 +357,7 @@ bool ath9k_hw_getnf(struct ath_hw *ah, struct ath9k_channel *chan)
 	nf = nfarray[0];
 	if (ath9k_hw_get_nf_thresh(ah, c->band, &nfThresh)
 	    && nf > nfThresh) {
-		ath_print(common, ATH_DBG_CALIBRATE,
+		ath_debug(common, ATH_DBG_CALIBRATE,
 			  "noise floor failed detected; "
 			  "detected %d, threshold %d\n",
 			  nf, nfThresh);
diff --git a/drivers/net/wireless/ath/ath9k/common.c b/drivers/net/wireless/ath/ath9k/common.c
index 48b07c3..86e267f 100644
--- a/drivers/net/wireless/ath/ath9k/common.c
+++ b/drivers/net/wireless/ath/ath9k/common.c
@@ -180,7 +180,7 @@ void ath9k_cmn_btcoex_bt_stomp(struct ath_common *common,
 					   AR_STOMP_NONE_WLAN_WGHT);
 		break;
 	default:
-		ath_print(common, ATH_DBG_BTCOEX,
+		ath_debug(common, ATH_DBG_BTCOEX,
 			  "Invalid Stomptype\n");
 		break;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index 1266333..c53215c 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -273,7 +273,7 @@ void ath9k_hw_update_regulatory_maxpower(struct ath_hw *ah)
 		regulatory->max_power_level += INCREASE_MAXPOW_BY_THREE_CHAIN;
 		break;
 	default:
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Invalid chainmask configuration\n");
 		break;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index c2481b3..9d002f1 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -37,13 +37,13 @@ static bool ath9k_hw_4k_fill_eeprom(struct ath_hw *ah)
 	eep_start_loc = 64;
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Reading from EEPROM, not flash\n");
 	}
 
 	for (addr = 0; addr < SIZE_EEPROM_4K; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + eep_start_loc, eep_data)) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Unable to read eeprom region\n");
 			return false;
 		}
@@ -69,12 +69,12 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 	if (!ath9k_hw_use_flash(ah)) {
 		if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET,
 					 &magic)) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Reading Magic # failed\n");
 			return false;
 		}
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
@@ -90,7 +90,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "Invalid EEPROM Magic. "
 					  "endianness mismatch.\n");
 				return -EINVAL;
@@ -98,7 +98,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+	ath_debug(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
 		  need_swap ? "True" : "False");
 
 	if (need_swap)
@@ -120,7 +120,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 		u32 integer;
 		u16 word;
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "EEPROM Endianness is not native.. Changing\n");
 
 		word = swab16(eep->baseEepHeader.length);
@@ -163,7 +163,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR5416_EEP_VER ||
 	    ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
 			  sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
@@ -488,11 +488,11 @@ static void ath9k_hw_set_4k_power_cal_table(struct ath_hw *ah,
 					((pdadcValues[4 * j + 3] & 0xFF) << 24);
 				REG_WRITE(ah, regOffset, reg32);
 
-				ath_print(common, ATH_DBG_EEPROM,
+				ath_debug(common, ATH_DBG_EEPROM,
 					  "PDADC (%d,%4x): %4.4x %8.8x\n",
 					  i, regChainOffset, regOffset,
 					  reg32);
-				ath_print(common, ATH_DBG_EEPROM,
+				ath_debug(common, ATH_DBG_EEPROM,
 					  "PDADC: Chain %d | "
 					  "PDADC %3d Value %3d | "
 					  "PDADC %3d Value %3d | "
@@ -1181,7 +1181,7 @@ static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "Getting spur idx %d is2Ghz. %d val %x\n",
 		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
@@ -1190,7 +1190,7 @@ static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_9287.c b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
index bcb9ed3..4a407ae 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_9287.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_9287.c
@@ -43,14 +43,14 @@ static bool ath9k_hw_ar9287_fill_eeprom(struct ath_hw *ah)
 		eep_start_loc = AR9287_HTC_EEP_START_LOC;
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Reading from EEPROM, not flash\n");
 	}
 
 	for (addr = 0; addr < NUM_EEP_WORDS; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + eep_start_loc,
 					 eep_data)) {
-			ath_print(common, ATH_DBG_EEPROM,
+			ath_debug(common, ATH_DBG_EEPROM,
 				  "Unable to read eeprom region\n");
 			return false;
 		}
@@ -72,12 +72,12 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 	if (!ath9k_hw_use_flash(ah)) {
 		if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET,
 					 &magic)) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Reading Magic # failed\n");
 			return false;
 		}
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
@@ -93,7 +93,7 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "Invalid EEPROM Magic. "
 					  "Endianness mismatch.\n");
 				return -EINVAL;
@@ -101,7 +101,7 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+	ath_debug(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
 		  need_swap ? "True" : "False");
 
 	if (need_swap)
@@ -160,7 +160,7 @@ static int ath9k_hw_ar9287_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR9287_EEP_VER
 	    || ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
 			   sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
@@ -1152,7 +1152,7 @@ static u16 ath9k_hw_ar9287_get_spur_channel(struct ath_hw *ah,
 	struct ath_common *common = ath9k_hw_common(ah);
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "Getting spur idx %d is2Ghz. %d val %x\n",
 		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
@@ -1161,7 +1161,7 @@ static u16 ath9k_hw_ar9287_get_spur_channel(struct ath_hw *ah,
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index e94216e..8f1f315 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -96,7 +96,7 @@ static bool ath9k_hw_def_fill_eeprom(struct ath_hw *ah)
 	for (addr = 0; addr < SIZE_EEPROM_DEF; addr++) {
 		if (!ath9k_hw_nvram_read(common, addr + ar5416_eep_start_loc,
 					 eep_data)) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 				  "Unable to read eeprom region\n");
 			return false;
 		}
@@ -117,12 +117,12 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 	int i, addr, size;
 
 	if (!ath9k_hw_nvram_read(common, AR5416_EEPROM_MAGIC_OFFSET, &magic)) {
-		ath_print(common, ATH_DBG_FATAL, "Reading Magic # failed\n");
+		ath_debug(common, ATH_DBG_FATAL, "Reading Magic # failed\n");
 		return false;
 	}
 
 	if (!ath9k_hw_use_flash(ah)) {
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "Read Magic = 0x%04X\n", magic);
 
 		if (magic != AR5416_EEPROM_MAGIC) {
@@ -139,7 +139,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 					eepdata++;
 				}
 			} else {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "Invalid EEPROM Magic. "
 					  "Endianness mismatch.\n");
 				return -EINVAL;
@@ -147,7 +147,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
+	ath_debug(common, ATH_DBG_EEPROM, "need_swap = %s.\n",
 		  need_swap ? "True" : "False");
 
 	if (need_swap)
@@ -169,7 +169,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 		u32 integer, j;
 		u16 word;
 
-		ath_print(common, ATH_DBG_EEPROM,
+		ath_debug(common, ATH_DBG_EEPROM,
 			  "EEPROM Endianness is not native.. Changing.\n");
 
 		word = swab16(eep->baseEepHeader.length);
@@ -216,7 +216,7 @@ static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 
 	if (sum != 0xffff || ah->eep_ops->get_eeprom_ver(ah) != AR5416_EEP_VER ||
 	    ah->eep_ops->get_eeprom_rev(ah) < AR5416_EEP_NO_BACK_VER) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Bad EEPROM checksum 0x%x or revision 0x%04x\n",
 			sum, ah->eep_ops->get_eeprom_ver(ah));
 		return -EINVAL;
@@ -965,11 +965,11 @@ static void ath9k_hw_set_def_power_cal_table(struct ath_hw *ah,
 					((pdadcValues[4 * j + 3] & 0xFF) << 24);
 				REG_WRITE(ah, regOffset, reg32);
 
-				ath_print(common, ATH_DBG_EEPROM,
+				ath_debug(common, ATH_DBG_EEPROM,
 					  "PDADC (%d,%4x): %4.4x %8.8x\n",
 					  i, regChainOffset, regOffset,
 					  reg32);
-				ath_print(common, ATH_DBG_EEPROM,
+				ath_debug(common, ATH_DBG_EEPROM,
 					  "PDADC: Chain %d | PDADC %3d "
 					  "Value %3d | PDADC %3d Value %3d | "
 					  "PDADC %3d Value %3d | PDADC %3d "
@@ -1318,7 +1318,7 @@ static void ath9k_hw_def_set_txpower(struct ath_hw *ah,
 		regulatory->max_power_level += INCREASE_MAXPOW_BY_THREE_CHAIN;
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_EEPROM,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_EEPROM,
 			  "Invalid chainmask configuration\n");
 		break;
 	}
@@ -1460,7 +1460,7 @@ static u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 
 	u16 spur_val = AR_NO_SPUR;
 
-	ath_print(common, ATH_DBG_ANI,
+	ath_debug(common, ATH_DBG_ANI,
 		  "Getting spur idx %d is2Ghz. %d val %x\n",
 		  i, is2GHz, ah->config.spurchans[i][is2GHz]);
 
@@ -1469,7 +1469,7 @@ static u16 ath9k_hw_def_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
 		break;
 	case SPUR_ENABLE_IOCTL:
 		spur_val = ah->config.spurchans[i][is2GHz];
-		ath_print(common, ATH_DBG_ANI,
+		ath_debug(common, ATH_DBG_ANI,
 			  "Getting spur val from new loc. %d\n", spur_val);
 		break;
 	case SPUR_ENABLE_EEPROM:
diff --git a/drivers/net/wireless/ath/ath9k/gpio.c b/drivers/net/wireless/ath/ath9k/gpio.c
index 6a1a482..7fb4e52 100644
--- a/drivers/net/wireless/ath/ath9k/gpio.c
+++ b/drivers/net/wireless/ath/ath9k/gpio.c
@@ -103,7 +103,7 @@ static int ath_register_led(struct ath_softc *sc, struct ath_led *led,
 
 	ret = led_classdev_register(wiphy_dev(sc->hw->wiphy), &led->led_cdev);
 	if (ret)
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Failed to register led:%s", led->name);
 	else
 		led->registered = 1;
@@ -236,12 +236,12 @@ static void ath_detect_bt_priority(struct ath_softc *sc)
 		sc->sc_flags &= ~(SC_OP_BT_PRIORITY_DETECTED | SC_OP_BT_SCAN);
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
+			ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
 				  "BT scan detected");
 			sc->sc_flags |= (SC_OP_BT_SCAN |
 					 SC_OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
+			ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_BTCOEX,
 				  "BT priority traffic detected");
 			sc->sc_flags |= SC_OP_BT_PRIORITY_DETECTED;
 		}
@@ -331,7 +331,7 @@ static void ath_btcoex_no_stomp_timer(void *arg)
 	struct ath_common *common = ath9k_hw_common(ah);
 	bool is_btscan = sc->sc_flags & SC_OP_BT_SCAN;
 
-	ath_print(common, ATH_DBG_BTCOEX,
+	ath_debug(common, ATH_DBG_BTCOEX,
 		  "no stomp timer running\n");
 
 	spin_lock_bh(&btcoex->btcoex_lock);
@@ -378,7 +378,7 @@ void ath9k_btcoex_timer_resume(struct ath_softc *sc)
 	struct ath_btcoex *btcoex = &sc->btcoex;
 	struct ath_hw *ah = sc->sc_ah;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
 		  "Starting btcoex timers");
 
 	/* make sure duty cycle timer is also stopped when resuming */
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
index 1b72aa4..2973c19 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
@@ -123,8 +123,8 @@ static void ath9k_htc_beacon_config_sta(struct ath9k_htc_priv *priv,
 	/* TSF out of range threshold fixed at 1 second */
 	bs.bs_tsfoor_threshold = ATH9K_TSFOOR_THRESHOLD;
 
-	ath_print(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
-	ath_print(common, ATH_DBG_BEACON,
+	ath_debug(common, ATH_DBG_BEACON, "tsf: %llu tsftu: %u\n", tsf, tsftu);
+	ath_debug(common, ATH_DBG_BEACON,
 		  "bmiss: %u sleep: %u cfp-period: %u maxdur: %u next: %u\n",
 		  bs.bs_bmissthreshold, bs.bs_sleepduration,
 		  bs.bs_cfpperiod, bs.bs_cfpmaxduration, bs.bs_cfpnext);
@@ -154,7 +154,7 @@ static void ath9k_htc_beacon_config_adhoc(struct ath9k_htc_priv *priv,
 	if (priv->op_flags & OP_ENABLE_BEACON)
 		imask |= ATH9K_INT_SWBA;
 
-	ath_print(common, ATH_DBG_BEACON,
+	ath_debug(common, ATH_DBG_BEACON,
 		  "IBSS Beacon config, intval: %d, imask: 0x%x\n",
 		  bss_conf->beacon_interval, imask);
 
@@ -246,7 +246,7 @@ void ath9k_htc_beaconq_config(struct ath9k_htc_priv *priv)
 	qi.tqi_cwmax = qi_be.tqi_cwmax;
 
 	if (!ath9k_hw_set_txq_props(ah, priv->beaconq, &qi)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Unable to update beacon queue %u!\n", qnum);
 	} else {
 		ath9k_hw_resettxqueue(ah, priv->beaconq);
@@ -278,7 +278,7 @@ void ath9k_htc_beacon_config(struct ath9k_htc_priv *priv,
 		ath9k_htc_beacon_config_adhoc(priv, cur_conf);
 		break;
 	default:
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Unsupported beaconing mode\n");
 		return;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
index 50eec9a..ec9a78a 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_gpio.c
@@ -20,12 +20,12 @@ static void ath_detect_bt_priority(struct ath9k_htc_priv *priv)
 		priv->op_flags &= ~(OP_BT_PRIORITY_DETECTED | OP_BT_SCAN);
 		/* Detect if colocated bt started scanning */
 		if (btcoex->bt_priority_cnt >= ATH_BT_CNT_SCAN_THRESHOLD) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
 				  "BT scan detected");
 			priv->op_flags |= (OP_BT_SCAN |
 					 OP_BT_PRIORITY_DETECTED);
 		} else if (btcoex->bt_priority_cnt >= ATH_BT_CNT_THRESHOLD) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
 				    "BT priority traffic detected");
 			priv->op_flags |= OP_BT_PRIORITY_DETECTED;
 		}
@@ -83,7 +83,7 @@ static void ath_btcoex_duty_cycle_work(struct work_struct *work)
 	struct ath_common *common = ath9k_hw_common(ah);
 	bool is_btscan = priv->op_flags & OP_BT_SCAN;
 
-	ath_print(common, ATH_DBG_BTCOEX,
+	ath_debug(common, ATH_DBG_BTCOEX,
 		  "time slice work for bt and wlan\n");
 
 	if (btcoex->bt_stomp_type == ATH_BTCOEX_STOMP_LOW || is_btscan)
@@ -114,7 +114,7 @@ void ath_htc_resume_btcoex_work(struct ath9k_htc_priv *priv)
 	struct ath_btcoex *btcoex = &priv->btcoex;
 	struct ath_hw *ah = priv->ah;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_BTCOEX,
 		  "Starting btcoex work");
 
 	btcoex->bt_priority_cnt = 0;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 071d0c9..62b3a50 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -288,7 +288,7 @@ static unsigned int ath9k_regread(void *hw_priv, u32 reg_offset)
 			  (u8 *) &val, sizeof(val),
 			  100);
 	if (unlikely(r)) {
-		ath_print(common, ATH_DBG_WMI,
+		ath_debug(common, ATH_DBG_WMI,
 			  "REGISTER READ FAILED: (0x%04x, %d)\n",
 			   reg_offset, r);
 		return -EIO;
@@ -313,7 +313,7 @@ static void ath9k_regwrite_single(void *hw_priv, u32 val, u32 reg_offset)
 			  (u8 *) &val, sizeof(val),
 			  100);
 	if (unlikely(r)) {
-		ath_print(common, ATH_DBG_WMI,
+		ath_debug(common, ATH_DBG_WMI,
 			  "REGISTER WRITE FAILED:(0x%04x, %d)\n",
 			  reg_offset, r);
 	}
@@ -345,7 +345,7 @@ static void ath9k_regwrite_buffer(void *hw_priv, u32 val, u32 reg_offset)
 			  (u8 *) &rsp_status, sizeof(rsp_status),
 			  100);
 		if (unlikely(r)) {
-			ath_print(common, ATH_DBG_WMI,
+			ath_debug(common, ATH_DBG_WMI,
 				  "REGISTER WRITE FAILED, multi len: %d\n",
 				  priv->wmi->multi_write_idx);
 		}
@@ -395,7 +395,7 @@ static void ath9k_regwrite_flush(void *hw_priv)
 			  (u8 *) &rsp_status, sizeof(rsp_status),
 			  100);
 		if (unlikely(r)) {
-			ath_print(common, ATH_DBG_WMI,
+			ath_debug(common, ATH_DBG_WMI,
 				  "REGISTER WRITE FAILED, multi len: %d\n",
 				  priv->wmi->multi_write_idx);
 		}
@@ -469,7 +469,7 @@ static void setup_ht_cap(struct ath9k_htc_priv *priv,
 	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, 2);
 	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, 2);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "TX streams %d, RX streams: %d\n",
 		  tx_streams, rx_streams);
 
@@ -495,36 +495,36 @@ static int ath9k_init_queues(struct ath9k_htc_priv *priv)
 
 	priv->beaconq = ath9k_hw_beaconq_setup(priv->ah);
 	if (priv->beaconq == -1) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup BEACON xmit queue\n");
 		goto err;
 	}
 
 	priv->cabq = ath9k_htc_cabq_setup(priv);
 	if (priv->cabq == -1) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup CAB xmit queue\n");
 		goto err;
 	}
 
 	if (!ath9k_htc_txq_setup(priv, WME_AC_BE)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup xmit queue for BE traffic\n");
 		goto err;
 	}
 
 	if (!ath9k_htc_txq_setup(priv, WME_AC_BK)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup xmit queue for BK traffic\n");
 		goto err;
 	}
 	if (!ath9k_htc_txq_setup(priv, WME_AC_VI)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup xmit queue for VI traffic\n");
 		goto err;
 	}
 	if (!ath9k_htc_txq_setup(priv, WME_AC_VO)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to setup xmit queue for VO traffic\n");
 		goto err;
 	}
@@ -543,7 +543,7 @@ static void ath9k_init_crypto(struct ath9k_htc_priv *priv)
 	/* Get the hardware key cache size. */
 	common->keymax = priv->ah->caps.keycache_size;
 	if (common->keymax > ATH_KEYMAX) {
-		ath_print(common, ATH_DBG_ANY,
+		ath_debug(common, ATH_DBG_ANY,
 			  "Warning, using only %u entries in %u key cache\n",
 			  ATH_KEYMAX, common->keymax);
 		common->keymax = ATH_KEYMAX;
@@ -670,7 +670,7 @@ static int ath9k_init_priv(struct ath9k_htc_priv *priv,
 
 	ret = ath9k_hw_init(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to initialize hardware; "
 			  "initialization status: %d\n", ret);
 		goto err_hw;
@@ -678,7 +678,7 @@ static int ath9k_init_priv(struct ath9k_htc_priv *priv,
 
 	ret = ath9k_htc_init_debug(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to create debugfs files\n");
 		goto err_debug;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index e9761c2..e404102 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -143,7 +143,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 	WMI_CMD(WMI_DRAIN_TXQ_ALL_CMDID);
 	WMI_CMD(WMI_STOP_RECV_CMDID);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "(%u MHz) -> (%u MHz), HT: %d, HT40: %d fastcc: %d\n",
 		  priv->ah->curchan->channel,
 		  channel->center_freq, conf_is_ht(conf), conf_is_ht40(conf),
@@ -152,7 +152,7 @@ static int ath9k_htc_set_channel(struct ath9k_htc_priv *priv,
 	caldata = &priv->caldata[channel->hw_value];
 	ret = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u Mhz) "
 			  "reset status %d\n", channel->center_freq, ret);
 		goto err;
@@ -222,13 +222,13 @@ static int ath9k_htc_add_station(struct ath9k_htc_priv *priv,
 	WMI_CMD_BUF(WMI_NODE_CREATE_CMDID, &tsta);
 	if (ret) {
 		if (sta)
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to add station entry for: %pM\n", sta->addr);
 		return ret;
 	}
 
 	if (sta)
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Added a station entry for: %pM (idx: %d)\n",
 			  sta->addr, tsta.sta_index);
 
@@ -255,14 +255,14 @@ static int ath9k_htc_remove_station(struct ath9k_htc_priv *priv,
 	WMI_CMD_BUF(WMI_NODE_REMOVE_CMDID, &sta_idx);
 	if (ret) {
 		if (sta)
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to remove station entry for: %pM\n",
 			  sta->addr);
 		return ret;
 	}
 
 	if (sta)
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Removed a station entry for: %pM (idx: %d)\n",
 			  sta->addr, sta_idx);
 
@@ -349,7 +349,7 @@ static int ath9k_htc_send_rate_cmd(struct ath9k_htc_priv *priv,
 
 	WMI_CMD_BUF(WMI_RC_RATE_UPDATE_CMDID, trate);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to initialize Rate information on target\n");
 	}
 
@@ -367,7 +367,7 @@ static void ath9k_htc_init_rate(struct ath9k_htc_priv *priv,
 	ath9k_htc_setup_rate(priv, sta, &trate);
 	ret = ath9k_htc_send_rate_cmd(priv, &trate);
 	if (!ret)
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Updated target sta: %pM, rate caps: 0x%X\n",
 			  sta->addr, be32_to_cpu(trate.capflags));
 }
@@ -394,7 +394,7 @@ static void ath9k_htc_update_rate(struct ath9k_htc_priv *priv,
 
 	ret = ath9k_htc_send_rate_cmd(priv, &trate);
 	if (!ret)
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Updated target sta: %pM, rate caps: 0x%X\n",
 			  bss_conf->bssid, be32_to_cpu(trate.capflags));
 }
@@ -423,11 +423,11 @@ static int ath9k_htc_tx_aggr_oper(struct ath9k_htc_priv *priv,
 
 	WMI_CMD_BUF(WMI_TX_AGGR_ENABLE_CMDID, &aggr);
 	if (ret)
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Unable to %s TX aggregation for (%pM, %d)\n",
 			  (aggr.aggr_enable) ? "start" : "stop", sta->addr, tid);
 	else
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "%s TX aggregation for (%pM, %d)\n",
 			  (aggr.aggr_enable) ? "Starting" : "Stopping",
 			  sta->addr, tid);
@@ -683,7 +683,7 @@ void ath9k_ani_work(struct work_struct *work)
 	/* Long calibration runs independently of short calibration. */
 	if ((timestamp - common->ani.longcal_timer) >= ATH_LONG_CALINTERVAL) {
 		longcal = true;
-		ath_print(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
+		ath_debug(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
 		common->ani.longcal_timer = timestamp;
 	}
 
@@ -692,7 +692,7 @@ void ath9k_ani_work(struct work_struct *work)
 		if ((timestamp - common->ani.shortcal_timer) >=
 		    short_cal_interval) {
 			shortcal = true;
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "shortcal @%lu\n", jiffies);
 			common->ani.shortcal_timer = timestamp;
 			common->ani.resetcal_timer = timestamp;
@@ -854,7 +854,7 @@ static int ath9k_register_led(struct ath9k_htc_priv *priv, struct ath_led *led,
 
 	ret = led_classdev_register(wiphy_dev(priv->hw->wiphy), &led->led_cdev);
 	if (ret)
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
 			  "Failed to register led:%s", led->name);
 	else
 		led->registered = 1;
@@ -983,7 +983,7 @@ static void ath9k_htc_radio_enable(struct ieee80211_hw *hw)
 	/* Reset the HW */
 	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
 			  "(freq %u MHz)\n", ret, ah->curchan->channel);
 	}
@@ -1046,7 +1046,7 @@ static void ath9k_htc_radio_disable(struct ieee80211_hw *hw)
 	/* Reset the HW */
 	ret = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
 			  "(freq %u MHz)\n", ret, ah->curchan->channel);
 	}
@@ -1083,14 +1083,14 @@ static int ath9k_htc_tx(struct ieee80211_hw *hw, struct sk_buff *skb)
 	ret = ath9k_htc_tx_start(priv, skb);
 	if (ret != 0) {
 		if (ret == -ENOMEM) {
-			ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+			ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
 				  "Stopping TX queues\n");
 			ieee80211_stop_queues(hw);
 			spin_lock_bh(&priv->tx_lock);
 			priv->tx_queues_stop = true;
 			spin_unlock_bh(&priv->tx_lock);
 		} else {
-			ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+			ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
 				  "Tx failed");
 		}
 		goto fail_tx;
@@ -1117,7 +1117,7 @@ static int ath9k_htc_start(struct ieee80211_hw *hw)
 
 	mutex_lock(&priv->mutex);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Starting driver with initial channel: %d MHz\n",
 		  curchan->center_freq);
 
@@ -1134,7 +1134,7 @@ static int ath9k_htc_start(struct ieee80211_hw *hw)
 	ath9k_hw_htc_resetinit(ah);
 	ret = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
 			  "(freq %u MHz)\n", ret, curchan->center_freq);
 		mutex_unlock(&priv->mutex);
@@ -1182,7 +1182,7 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 	mutex_lock(&priv->mutex);
 
 	if (priv->op_flags & OP_INVALID) {
-		ath_print(common, ATH_DBG_ANY, "Device not present\n");
+		ath_debug(common, ATH_DBG_ANY, "Device not present\n");
 		mutex_unlock(&priv->mutex);
 		return;
 	}
@@ -1213,7 +1213,7 @@ static void ath9k_htc_stop(struct ieee80211_hw *hw)
 
 	priv->op_flags |= OP_INVALID;
 
-	ath_print(common, ATH_DBG_CONFIG, "Driver halt\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Driver halt\n");
 	mutex_unlock(&priv->mutex);
 }
 
@@ -1247,13 +1247,13 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 		hvif.opmode = cpu_to_be32(HTC_M_IBSS);
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			"Interface type %d not yet supported\n", vif->type);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Attach a VIF of type: %d\n", vif->type);
 
 	priv->ah->opmode = vif->type;
@@ -1277,8 +1277,8 @@ static int ath9k_htc_add_interface(struct ieee80211_hw *hw,
 
 	ret = ath9k_htc_update_cap_target(priv);
 	if (ret)
-		ath_print(common, ATH_DBG_CONFIG, "Failed to update"
-			  " capability in target \n");
+		ath_debug(common, ATH_DBG_CONFIG, "Failed to update"
+			  " capability in target\n");
 
 	priv->vif = vif;
 out:
@@ -1298,7 +1298,7 @@ static void ath9k_htc_remove_interface(struct ieee80211_hw *hw,
 	int ret = 0;
 	u8 cmd_rsp;
 
-	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
 	mutex_lock(&priv->mutex);
 	ath9k_htc_ps_wakeup(priv);
@@ -1335,7 +1335,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		mutex_unlock(&priv->htc_pm_lock);
 
 		if (enable_radio) {
-			ath_print(common, ATH_DBG_CONFIG,
+			ath_debug(common, ATH_DBG_CONFIG,
 				  "not-idle: enabling radio\n");
 			ath9k_htc_setpower(priv, ATH9K_PM_AWAKE);
 			ath9k_htc_radio_enable(hw);
@@ -1346,7 +1346,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		struct ieee80211_channel *curchan = hw->conf.channel;
 		int pos = curchan->hw_value;
 
-		ath_print(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
+		ath_debug(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
 			  curchan->center_freq);
 
 		ath9k_cmn_update_ichannel(&priv->ah->channels[pos],
@@ -1354,7 +1354,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 					  hw->conf.channel_type);
 
 		if (ath9k_htc_set_channel(priv, hw, &priv->ah->channels[pos]) < 0) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Unable to set channel\n");
 			mutex_unlock(&priv->mutex);
 			return -EINVAL;
@@ -1374,7 +1374,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 
 	if (changed & IEEE80211_CONF_CHANGE_MONITOR)
 		if (conf->flags & IEEE80211_CONF_MONITOR) {
-			ath_print(common, ATH_DBG_CONFIG,
+			ath_debug(common, ATH_DBG_CONFIG,
 				  "HW opmode set to Monitor mode\n");
 			priv->ah->opmode = NL80211_IFTYPE_MONITOR;
 		}
@@ -1388,7 +1388,7 @@ static int ath9k_htc_config(struct ieee80211_hw *hw, u32 changed)
 		}
 		mutex_unlock(&priv->htc_pm_lock);
 
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "idle: disabling radio\n");
 		ath9k_htc_radio_disable(hw);
 	}
@@ -1426,7 +1426,7 @@ static void ath9k_htc_configure_filter(struct ieee80211_hw *hw,
 	rfilt = ath9k_htc_calcrxfilter(priv);
 	ath9k_hw_setrxfilter(priv->ah, rfilt);
 
-	ath_print(ath9k_hw_common(priv->ah), ATH_DBG_CONFIG,
+	ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_CONFIG,
 		  "Set HW RX filter: 0x%x\n", rfilt);
 
 	ath9k_htc_ps_restore(priv);
@@ -1490,7 +1490,7 @@ static int ath9k_htc_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	qnum = get_hw_qnum(queue, priv->hwq_map);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Configure tx [queue/hwq] [%d/%d],  "
 		  "aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
 		  queue, qnum, params->aifs, params->cw_min,
@@ -1498,7 +1498,7 @@ static int ath9k_htc_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	ret = ath_htc_txq_update(priv, qnum, &qi);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL, "TXQ Update failed\n");
+		ath_debug(common, ATH_DBG_FATAL, "TXQ Update failed\n");
 		goto out;
 	}
 
@@ -1526,7 +1526,7 @@ static int ath9k_htc_set_key(struct ieee80211_hw *hw,
 		return -ENOSPC;
 
 	mutex_lock(&priv->mutex);
-	ath_print(common, ATH_DBG_CONFIG, "Set HW Key\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Set HW Key\n");
 	ath9k_htc_ps_wakeup(priv);
 
 	switch (cmd) {
@@ -1572,7 +1572,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	if (changed & BSS_CHANGED_ASSOC) {
 		common->curaid = bss_conf->assoc ?
 				 bss_conf->aid : 0;
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
 			bss_conf->assoc);
 
 		if (bss_conf->assoc) {
@@ -1589,7 +1589,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 		memcpy(common->curbssid, bss_conf->bssid, ETH_ALEN);
 		ath9k_hw_write_associd(ah);
 
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "BSSID: %pM aid: 0x%x\n",
 			  common->curbssid, common->curaid);
 	}
@@ -1609,7 +1609,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
 			  bss_conf->use_short_preamble);
 		if (bss_conf->use_short_preamble)
 			priv->op_flags |= OP_PREAMBLE_SHORT;
@@ -1618,7 +1618,7 @@ static void ath9k_htc_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
 			  bss_conf->use_cts_prot);
 		if (bss_conf->use_cts_prot &&
 		    hw->conf.channel->band != IEEE80211_BAND_5GHZ)
@@ -1710,7 +1710,7 @@ static int ath9k_htc_ampdu_action(struct ieee80211_hw *hw,
 		spin_unlock_bh(&priv->tx_lock);
 		break;
 	default:
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_FATAL,
 			  "Unknown AMPDU action\n");
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index 7795867..d08e698 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -69,7 +69,7 @@ int ath_htc_txq_update(struct ath9k_htc_priv *priv, int qnum,
 	qi.tqi_readyTime = qinfo->tqi_readyTime;
 
 	if (!ath9k_hw_set_txq_props(ah, qnum, &qi)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Unable to update hardware queue %u!\n", qnum);
 		error = -EIO;
 	} else {
@@ -270,7 +270,7 @@ void ath9k_tx_tasklet(unsigned long data)
 	if (priv->tx_queues_stop) {
 		priv->tx_queues_stop = false;
 		spin_unlock_bh(&priv->tx_lock);
-		ath_print(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
+		ath_debug(ath9k_hw_common(priv->ah), ATH_DBG_XMIT,
 			  "Waking up TX queues\n");
 		ieee80211_wake_queues(priv->hw);
 		return;
@@ -296,7 +296,7 @@ void ath9k_htc_txep(void *drv_priv, struct sk_buff *skb,
 		   (ep_id == priv->data_vo_ep)) {
 		skb_pull(skb, sizeof(struct tx_frame_hdr));
 	} else {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unsupported TX EPID: %d\n", ep_id);
 		dev_kfree_skb_any(skb);
 		return;
@@ -337,7 +337,7 @@ bool ath9k_htc_txq_setup(struct ath9k_htc_priv *priv, int subtype)
 		return false;
 
 	if (qnum >= ARRAY_SIZE(priv->hwq_map)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "qnum %u out of range, max %u!\n",
 			  qnum, (unsigned int)ARRAY_SIZE(priv->hwq_map));
 		ath9k_hw_releasetxqueue(ah, qnum);
@@ -490,7 +490,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 	__le16 fc;
 
 	if (skb->len <= HTC_RX_FRAME_HEADER_SIZE) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Corrupted RX frame, dropping\n");
 		goto rx_next;
 	}
@@ -499,7 +499,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 
 	if (be16_to_cpu(rxstatus->rs_datalen) -
 	    (skb->len - HTC_RX_FRAME_HEADER_SIZE) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Corrupted RX data len, dropping "
 			  "(dlen: %d, skblen: %d)\n",
 			  rxstatus->rs_datalen, skb->len);
@@ -685,7 +685,7 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_buff *skb,
 	spin_unlock(&priv->rx.rxbuflock);
 
 	if (rxbuf == NULL) {
-		ath_print(common, ATH_DBG_ANY,
+		ath_debug(common, ATH_DBG_ANY,
 			  "No free RX buffer\n");
 		goto err;
 	}
@@ -728,7 +728,7 @@ int ath9k_rx_init(struct ath9k_htc_priv *priv)
 	for (i = 0; i < ATH9K_HTC_RXBUF; i++) {
 		rxbuf = kzalloc(sizeof(struct ath9k_htc_rxbuf), GFP_KERNEL);
 		if (rxbuf == NULL) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Unable to allocate RX buffers\n");
 			goto err;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index ce9e59f..d8d1584 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -129,7 +129,7 @@ bool ath9k_hw_wait(struct ath_hw *ah, u32 reg, u32 mask, u32 val, u32 timeout)
 		udelay(AH_TIME_QUANTUM);
 	}
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_ANY,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_ANY,
 		  "timeout (%d us) on reg 0x%x: 0x%08x & 0x%08x != 0x%08x\n",
 		  timeout, reg, REG_READ(ah, reg), mask, val);
 
@@ -211,7 +211,7 @@ u16 ath9k_hw_computetxtime(struct ath_hw *ah,
 		}
 		break;
 	default:
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Unknown phy %u (rate ix %u)\n", phy, rateix);
 		txTime = 0;
 		break;
@@ -331,7 +331,7 @@ static bool ath9k_hw_chip_test(struct ath_hw *ah)
 			REG_WRITE(ah, addr, wrData);
 			rdData = REG_READ(ah, addr);
 			if (rdData != wrData) {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "address test failed "
 					  "addr: 0x%08x - wr:0x%08x != "
 					  "rd:0x%08x\n",
@@ -344,7 +344,7 @@ static bool ath9k_hw_chip_test(struct ath_hw *ah)
 			REG_WRITE(ah, addr, wrData);
 			rdData = REG_READ(ah, addr);
 			if (wrData != rdData) {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "address test failed "
 					  "addr: 0x%08x - wr:0x%08x != "
 					  "rd:0x%08x\n",
@@ -469,14 +469,14 @@ static int ath9k_hw_post_init(struct ath_hw *ah)
 	if (ecode != 0)
 		return ecode;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_CONFIG,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_CONFIG,
 		  "Eeprom VER: %d, REV: %d\n",
 		  ah->eep_ops->get_eeprom_ver(ah),
 		  ah->eep_ops->get_eeprom_rev(ah));
 
 	ecode = ath9k_hw_rf_alloc_ext_banks(ah);
 	if (ecode) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Failed allocating banks for "
 			  "external radio\n");
 		ath9k_hw_rf_free_ext_banks(ah);
@@ -509,7 +509,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		ah->hw_version.macVersion = AR_SREV_VERSION_9100;
 
 	if (!ath9k_hw_set_reset_reg(ah, ATH9K_RESET_POWER_ON)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Couldn't reset chip\n");
 		return -EIO;
 	}
@@ -520,7 +520,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 	ath9k_hw_attach_ops(ah);
 
 	if (!ath9k_hw_setpower(ah, ATH9K_PM_AWAKE)) {
-		ath_print(common, ATH_DBG_FATAL, "Couldn't wakeup chip\n");
+		ath_debug(common, ATH_DBG_FATAL, "Couldn't wakeup chip\n");
 		return -EIO;
 	}
 
@@ -536,7 +536,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		}
 	}
 
-	ath_print(common, ATH_DBG_RESET, "serialize_regmode is %d\n",
+	ath_debug(common, ATH_DBG_RESET, "serialize_regmode is %d\n",
 		ah->config.serialize_regmode);
 
 	if (AR_SREV_9285(ah) || AR_SREV_9271(ah))
@@ -545,7 +545,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 		ah->config.max_txtrig_level = MAX_TX_FIFO_THRESHOLD;
 
 	if (!ath9k_hw_macversion_supported(ah)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Mac Chip Rev 0x%02x.%x is not supported by "
 			  "this driver\n", ah->hw_version.macVersion,
 			  ah->hw_version.macRev);
@@ -594,7 +594,7 @@ static int __ath9k_hw_init(struct ath_hw *ah)
 
 	r = ath9k_hw_init_macaddr(ah);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Failed to initialize MAC address\n");
 		return r;
 	}
@@ -633,7 +633,7 @@ int ath9k_hw_init(struct ath_hw *ah)
 	default:
 		if (common->bus_ops->ath_bus_type == ATH_USB)
 			break;
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Hardware device ID 0x%04x not supported\n",
 			  ah->hw_version.devid);
 		return -EOPNOTSUPP;
@@ -641,7 +641,7 @@ int ath9k_hw_init(struct ath_hw *ah)
 
 	ret = __ath9k_hw_init(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to initialize hardware; "
 			  "initialization status: %d\n", ret);
 		return ret;
@@ -767,7 +767,7 @@ static void ath9k_hw_set_cts_timeout(struct ath_hw *ah, u32 us)
 static bool ath9k_hw_set_global_txtimeout(struct ath_hw *ah, u32 tu)
 {
 	if (tu > 0xFFFF) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_XMIT,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_XMIT,
 			  "bad global tx timeout %u\n", tu);
 		ah->globaltxtimeout = (u32) -1;
 		return false;
@@ -785,7 +785,7 @@ void ath9k_hw_init_global_settings(struct ath_hw *ah)
 	int slottime;
 	int sifstime;
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_RESET, "ah->misc_mode 0x%x\n",
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_RESET, "ah->misc_mode 0x%x\n",
 		  ah->misc_mode);
 
 	if (ah->misc_mode != 0)
@@ -1029,7 +1029,7 @@ static bool ath9k_hw_set_reset(struct ath_hw *ah, int type)
 
 	REG_WRITE(ah, AR_RTC_RC, 0);
 	if (!ath9k_hw_wait(ah, AR_RTC_RC, AR_RTC_RC_M, 0, AH_WAIT_TIMEOUT)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_RESET,
 			  "RTC stuck in MAC reset\n");
 		return false;
 	}
@@ -1076,7 +1076,7 @@ static bool ath9k_hw_set_reset_power_on(struct ath_hw *ah)
 			   AR_RTC_STATUS_M,
 			   AR_RTC_STATUS_ON,
 			   AH_WAIT_TIMEOUT)) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_RESET,
 			  "RTC not waking up\n");
 		return false;
 	}
@@ -1137,7 +1137,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 
 	for (qnum = 0; qnum < AR_NUM_QCU; qnum++) {
 		if (ath9k_hw_numtxpending(ah, qnum)) {
-			ath_print(common, ATH_DBG_QUEUE,
+			ath_debug(common, ATH_DBG_QUEUE,
 				  "Transmit frames pending on "
 				  "queue %d\n", qnum);
 			return false;
@@ -1145,7 +1145,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 	}
 
 	if (!ath9k_hw_rfbus_req(ah)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Could not kill baseband RX\n");
 		return false;
 	}
@@ -1154,7 +1154,7 @@ static bool ath9k_hw_channel_change(struct ath_hw *ah,
 
 	r = ath9k_hw_rf_set_freq(ah, chan);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Failed to set channel\n");
 		return false;
 	}
@@ -1222,7 +1222,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	if (!ah->chip_fullsleep) {
 		ath9k_hw_abortpcurecv(ah);
 		if (!ath9k_hw_stopdmarecv(ah)) {
-			ath_print(common, ATH_DBG_XMIT,
+			ath_debug(common, ATH_DBG_XMIT,
 				"Failed to stop receive dma\n");
 			bChannelChange = false;
 		}
@@ -1287,7 +1287,7 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 	}
 
 	if (!ath9k_hw_chip_reset(ah, chan)) {
-		ath_print(common, ATH_DBG_FATAL, "Chip reset failed\n");
+		ath_debug(common, ATH_DBG_FATAL, "Chip reset failed\n");
 		return -EINVAL;
 	}
 
@@ -1434,13 +1434,13 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_channel *chan,
 		u32 mask;
 		mask = REG_READ(ah, AR_CFG);
 		if (mask & (AR_CFG_SWRB | AR_CFG_SWTB | AR_CFG_SWRG)) {
-			ath_print(common, ATH_DBG_RESET,
+			ath_debug(common, ATH_DBG_RESET,
 				"CFG Byte Swap Set 0x%x\n", mask);
 		} else {
 			mask =
 				INIT_CONFIG_STATUS | AR_CFG_SWRB | AR_CFG_SWTB;
 			REG_WRITE(ah, AR_CFG, mask);
-			ath_print(common, ATH_DBG_RESET,
+			ath_debug(common, ATH_DBG_RESET,
 				"Setting CFG 0x%x\n", REG_READ(ah, AR_CFG));
 		}
 	} else {
@@ -1568,7 +1568,7 @@ static bool ath9k_hw_set_power_awake(struct ath_hw *ah, int setChip)
 				    AR_RTC_FORCE_WAKE_EN);
 		}
 		if (i == 0) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 				  "Failed to wakeup in %uus\n",
 				  POWER_UP_TIME / 20);
 			return false;
@@ -1594,7 +1594,7 @@ bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode)
 	if (ah->power_mode == mode)
 		return status;
 
-	ath_print(common, ATH_DBG_RESET, "%s -> %s\n",
+	ath_debug(common, ATH_DBG_RESET, "%s -> %s\n",
 		  modes[ah->power_mode], modes[mode]);
 
 	switch (mode) {
@@ -1609,7 +1609,7 @@ bool ath9k_hw_setpower(struct ath_hw *ah, enum ath9k_power_mode mode)
 		ath9k_set_power_network_sleep(ah, setChip);
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unknown power mode %u\n", mode);
 		return false;
 	}
@@ -1669,7 +1669,7 @@ void ath9k_hw_beaconinit(struct ath_hw *ah, u32 next_beacon, u32 beacon_period)
 			flags |= AR_TBTT_TIMER_EN;
 			break;
 		}
-		ath_print(ath9k_hw_common(ah), ATH_DBG_BEACON,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_BEACON,
 			  "%s: unsupported opmode: %d\n",
 			  __func__, ah->opmode);
 		return;
@@ -1727,10 +1727,10 @@ void ath9k_hw_set_sta_beacon_timers(struct ath_hw *ah,
 	else
 		nextTbtt = bs->bs_nexttbtt;
 
-	ath_print(common, ATH_DBG_BEACON, "next DTIM %d\n", bs->bs_nextdtim);
-	ath_print(common, ATH_DBG_BEACON, "next beacon %d\n", nextTbtt);
-	ath_print(common, ATH_DBG_BEACON, "beacon period %d\n", beaconintval);
-	ath_print(common, ATH_DBG_BEACON, "DTIM period %d\n", dtimperiod);
+	ath_debug(common, ATH_DBG_BEACON, "next DTIM %d\n", bs->bs_nextdtim);
+	ath_debug(common, ATH_DBG_BEACON, "next beacon %d\n", nextTbtt);
+	ath_debug(common, ATH_DBG_BEACON, "beacon period %d\n", beaconintval);
+	ath_debug(common, ATH_DBG_BEACON, "DTIM period %d\n", dtimperiod);
 
 	ENABLE_REGWRITE_BUFFER(ah);
 
@@ -1795,13 +1795,13 @@ int ath9k_hw_fill_cap_info(struct ath_hw *ah)
 			regulatory->current_rd += 5;
 		else if (regulatory->current_rd == 0x41)
 			regulatory->current_rd = 0x43;
-		ath_print(common, ATH_DBG_REGULATORY,
+		ath_debug(common, ATH_DBG_REGULATORY,
 			  "regdomain mapped to 0x%x\n", regulatory->current_rd);
 	}
 
 	eeval = ah->eep_ops->get_eeprom(ah, EEP_OP_MODE);
 	if ((eeval & (AR5416_OPFLAGS_11G | AR5416_OPFLAGS_11A)) == 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "no band has been marked as supported in EEPROM.\n");
 		return -EINVAL;
 	}
@@ -2251,7 +2251,7 @@ void ath9k_hw_reset_tsf(struct ath_hw *ah)
 {
 	if (!ath9k_hw_wait(ah, AR_SLP32_MODE, AR_SLP32_TSF_WRITE_STATUS, 0,
 			   AH_TSF_WRITE_TIMEOUT))
-		ath_print(ath9k_hw_common(ah), ATH_DBG_RESET,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_RESET,
 			  "AR_SLP32_TSF_WRITE_STATUS limit exceeded\n");
 
 	REG_WRITE(ah, AR_RESET_TSF, AR_RESET_TSF_ONCE);
@@ -2342,7 +2342,7 @@ struct ath_gen_timer *ath_gen_timer_alloc(struct ath_hw *ah,
 	timer = kzalloc(sizeof(struct ath_gen_timer), GFP_KERNEL);
 
 	if (timer == NULL) {
-		ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 			  "Failed to allocate memory"
 			  "for hw timer[%d]\n", timer_index);
 		return NULL;
@@ -2373,7 +2373,7 @@ void ath9k_hw_gen_timer_start(struct ath_hw *ah,
 
 	tsf = ath9k_hw_gettsf32(ah);
 
-	ath_print(ath9k_hw_common(ah), ATH_DBG_HWTIMER,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_HWTIMER,
 		  "curent tsf %x period %x"
 		  "timer_next %x\n", tsf, timer_period, timer_next);
 
@@ -2455,7 +2455,7 @@ void ath_gen_timer_isr(struct ath_hw *ah)
 		index = rightmost_index(timer_table, &thresh_mask);
 		timer = timer_table->timers[index];
 		BUG_ON(!timer);
-		ath_print(common, ATH_DBG_HWTIMER,
+		ath_debug(common, ATH_DBG_HWTIMER,
 			  "TSF overflow for Gen timer %d\n", index);
 		timer->overflow(timer->arg);
 	}
@@ -2464,7 +2464,7 @@ void ath_gen_timer_isr(struct ath_hw *ah)
 		index = rightmost_index(timer_table, &trigger_mask);
 		timer = timer_table->timers[index];
 		BUG_ON(!timer);
-		ath_print(common, ATH_DBG_HWTIMER,
+		ath_debug(common, ATH_DBG_HWTIMER,
 			  "Gen timer[%d] trigger\n", index);
 		timer->trigger(timer->arg);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 7eef1fa..32a1465 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -225,7 +225,7 @@ static void setup_ht_cap(struct ath_softc *sc,
 	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, max_streams);
 	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, max_streams);
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "TX streams %d, RX streams: %d\n",
 		  tx_streams, rx_streams);
 
@@ -270,7 +270,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 	struct ath_buf *bf;
 	int i, bsize, error, desc_len;
 
-	ath_print(common, ATH_DBG_CONFIG, "%s DMA: %u buffers %u desc/buf\n",
+	ath_debug(common, ATH_DBG_CONFIG, "%s DMA: %u buffers %u desc/buf\n",
 		  name, nbuf, ndesc);
 
 	INIT_LIST_HEAD(head);
@@ -282,7 +282,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 
 	/* ath_desc must be a multiple of DWORDs */
 	if ((desc_len % 4) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "ath_desc not DWORD aligned\n");
 		BUG_ON((desc_len % 4) != 0);
 		error = -ENOMEM;
@@ -317,7 +317,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 		goto fail;
 	}
 	ds = (u8 *) dd->dd_desc;
-	ath_print(common, ATH_DBG_CONFIG, "%s DMA map: %p (%u) -> %llx (%u)\n",
+	ath_debug(common, ATH_DBG_CONFIG, "%s DMA map: %p (%u) -> %llx (%u)\n",
 		  name, ds, (u32) dd->dd_desc_len,
 		  ito64(dd->dd_desc_paddr), /*XXX*/(u32) dd->dd_desc_len);
 
@@ -373,7 +373,7 @@ static void ath9k_init_crypto(struct ath_softc *sc)
 	/* Get the hardware key cache size. */
 	common->keymax = sc->sc_ah->caps.keycache_size;
 	if (common->keymax > ATH_KEYMAX) {
-		ath_print(common, ATH_DBG_ANY,
+		ath_debug(common, ATH_DBG_ANY,
 			  "Warning, using only %u entries in %u key cache\n",
 			  ATH_KEYMAX, common->keymax);
 		common->keymax = ATH_KEYMAX;
@@ -567,7 +567,7 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc, u16 subsysid,
 
 	ret = ath9k_init_debug(ah);
 	if (ret) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to create debugfs files\n");
 		goto err_debug;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/ath/ath9k/mac.c
index b04b37b..374a995 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -20,7 +20,7 @@
 static void ath9k_hw_set_txq_interrupts(struct ath_hw *ah,
 					struct ath9k_tx_queue_info *qi)
 {
-	ath_print(ath9k_hw_common(ah), ATH_DBG_INTERRUPT,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_INTERRUPT,
 		  "tx ok 0x%x err 0x%x desc 0x%x eol 0x%x urn 0x%x\n",
 		  ah->txok_interrupt_mask, ah->txerr_interrupt_mask,
 		  ah->txdesc_interrupt_mask, ah->txeol_interrupt_mask,
@@ -56,7 +56,7 @@ EXPORT_SYMBOL(ath9k_hw_puttxbuf);
 
 void ath9k_hw_txstart(struct ath_hw *ah, u32 q)
 {
-	ath_print(ath9k_hw_common(ah), ATH_DBG_QUEUE,
+	ath_debug(ath9k_hw_common(ah), ATH_DBG_QUEUE,
 		  "Enable TXE on queue: %u\n", q);
 	REG_WRITE(ah, AR_Q_TXE, 1 << q);
 }
@@ -154,14 +154,14 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 	u32 wait_time = ATH9K_TX_STOP_DMA_TIMEOUT / ATH9K_TIME_QUANTUM;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
+		ath_debug(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
 			  "invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
+		ath_debug(common, ATH_DBG_QUEUE, "Stopping TX DMA, "
 			  "inactive queue: %u\n", q);
 		return false;
 	}
@@ -175,7 +175,7 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 	}
 
 	if (ath9k_hw_numtxpending(ah, q)) {
-		ath_print(common, ATH_DBG_QUEUE,
+		ath_debug(common, ATH_DBG_QUEUE,
 			  "%s: Num of pending TX Frames %d on Q %d\n",
 			  __func__, ath9k_hw_numtxpending(ah, q), q);
 
@@ -191,7 +191,7 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 			if ((REG_READ(ah, AR_TSF_L32) >> 10) == (tsfLow >> 10))
 				break;
 
-			ath_print(common, ATH_DBG_QUEUE,
+			ath_debug(common, ATH_DBG_QUEUE,
 				  "TSF has moved while trying to set "
 				  "quiet time TSF: 0x%08x\n", tsfLow);
 		}
@@ -204,7 +204,7 @@ bool ath9k_hw_stoptxdma(struct ath_hw *ah, u32 q)
 		wait = wait_time;
 		while (ath9k_hw_numtxpending(ah, q)) {
 			if ((--wait) == 0) {
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "Failed to stop TX DMA in 100 "
 					  "msec after killing last frame\n");
 				break;
@@ -239,19 +239,19 @@ bool ath9k_hw_set_txq_props(struct ath_hw *ah, int q,
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Set TXQ properties, "
+		ath_debug(common, ATH_DBG_QUEUE, "Set TXQ properties, "
 			  "invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Set TXQ properties, "
+		ath_debug(common, ATH_DBG_QUEUE, "Set TXQ properties, "
 			  "inactive queue: %u\n", q);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Set queue properties for: %u\n", q);
+	ath_debug(common, ATH_DBG_QUEUE, "Set queue properties for: %u\n", q);
 
 	qi->tqi_ver = qinfo->tqi_ver;
 	qi->tqi_subtype = qinfo->tqi_subtype;
@@ -310,14 +310,14 @@ bool ath9k_hw_get_txq_props(struct ath_hw *ah, int q,
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Get TXQ properties, "
+		ath_debug(common, ATH_DBG_QUEUE, "Get TXQ properties, "
 			  "invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Get TXQ properties, "
+		ath_debug(common, ATH_DBG_QUEUE, "Get TXQ properties, "
 			  "inactive queue: %u\n", q);
 		return false;
 	}
@@ -368,22 +368,22 @@ int ath9k_hw_setuptxqueue(struct ath_hw *ah, enum ath9k_tx_queue type,
 			    ATH9K_TX_QUEUE_INACTIVE)
 				break;
 		if (q == pCap->total_queues) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "No available TX queue\n");
 			return -1;
 		}
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Invalid TX queue type: %u\n", type);
 		return -1;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Setup TX queue: %u\n", q);
+	ath_debug(common, ATH_DBG_QUEUE, "Setup TX queue: %u\n", q);
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type != ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "TX queue: %u already active\n", q);
 		return -1;
 	}
@@ -416,18 +416,18 @@ bool ath9k_hw_releasetxqueue(struct ath_hw *ah, u32 q)
 	struct ath9k_tx_queue_info *qi;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Release TXQ, "
+		ath_debug(common, ATH_DBG_QUEUE, "Release TXQ, "
 			  "invalid queue: %u\n", q);
 		return false;
 	}
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Release TXQ, "
+		ath_debug(common, ATH_DBG_QUEUE, "Release TXQ, "
 			  "inactive queue: %u\n", q);
 		return false;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Release TX queue: %u\n", q);
+	ath_debug(common, ATH_DBG_QUEUE, "Release TX queue: %u\n", q);
 
 	qi->tqi_type = ATH9K_TX_QUEUE_INACTIVE;
 	ah->txok_interrupt_mask &= ~(1 << q);
@@ -450,19 +450,19 @@ bool ath9k_hw_resettxqueue(struct ath_hw *ah, u32 q)
 	u32 cwMin, chanCwMin, value;
 
 	if (q >= pCap->total_queues) {
-		ath_print(common, ATH_DBG_QUEUE, "Reset TXQ, "
+		ath_debug(common, ATH_DBG_QUEUE, "Reset TXQ, "
 			  "invalid queue: %u\n", q);
 		return false;
 	}
 
 	qi = &ah->txq[q];
 	if (qi->tqi_type == ATH9K_TX_QUEUE_INACTIVE) {
-		ath_print(common, ATH_DBG_QUEUE, "Reset TXQ, "
+		ath_debug(common, ATH_DBG_QUEUE, "Reset TXQ, "
 			  "inactive queue: %u\n", q);
 		return true;
 	}
 
-	ath_print(common, ATH_DBG_QUEUE, "Reset TX queue: %u\n", q);
+	ath_debug(common, ATH_DBG_QUEUE, "Reset TX queue: %u\n", q);
 
 	if (qi->tqi_cwmin == ATH9K_TXQ_USEDEFAULT) {
 		if (chan && IS_CHAN_B(chan))
@@ -735,7 +735,7 @@ bool ath9k_hw_setrxabort(struct ath_hw *ah, bool set)
 				     AR_DIAG_RX_ABORT));
 
 			reg = REG_READ(ah, AR_OBS_BUS_1);
-			ath_print(ath9k_hw_common(ah), ATH_DBG_FATAL,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_FATAL,
 				  "RX failed to go idle in 10 ms RXSM=0x%x\n",
 				  reg);
 
@@ -791,7 +791,7 @@ bool ath9k_hw_stopdmarecv(struct ath_hw *ah)
 	}
 
 	if (i == 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "DMA failed to stop in %d ms "
 			  "AR_CR=0x%08x AR_DIAG_SW=0x%08x\n",
 			  AH_RX_STOP_DMA_TIMEOUT / 1000,
@@ -844,7 +844,7 @@ void ath9k_hw_disable_interrupts(struct ath_hw *ah)
 {
 	struct ath_common *common = ath9k_hw_common(ah);
 
-	ath_print(common, ATH_DBG_INTERRUPT, "disable IER\n");
+	ath_debug(common, ATH_DBG_INTERRUPT, "disable IER\n");
 	REG_WRITE(ah, AR_IER, AR_IER_DISABLE);
 	(void) REG_READ(ah, AR_IER);
 	if (!AR_SREV_9100(ah)) {
@@ -864,7 +864,7 @@ void ath9k_hw_enable_interrupts(struct ath_hw *ah)
 	if (!(ah->imask & ATH9K_INT_GLOBAL))
 		return;
 
-	ath_print(common, ATH_DBG_INTERRUPT, "enable IER\n");
+	ath_debug(common, ATH_DBG_INTERRUPT, "enable IER\n");
 	REG_WRITE(ah, AR_IER, AR_IER_ENABLE);
 	if (!AR_SREV_9100(ah)) {
 		REG_WRITE(ah, AR_INTR_ASYNC_ENABLE,
@@ -877,7 +877,7 @@ void ath9k_hw_enable_interrupts(struct ath_hw *ah)
 		REG_WRITE(ah, AR_INTR_SYNC_MASK,
 			  AR_INTR_SYNC_DEFAULT);
 	}
-	ath_print(common, ATH_DBG_INTERRUPT, "AR_IMR 0x%x IER 0x%x\n",
+	ath_debug(common, ATH_DBG_INTERRUPT, "AR_IMR 0x%x IER 0x%x\n",
 		  REG_READ(ah, AR_IMR), REG_READ(ah, AR_IER));
 }
 EXPORT_SYMBOL(ath9k_hw_enable_interrupts);
@@ -892,7 +892,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 	if (!(ints & ATH9K_INT_GLOBAL))
 		ath9k_hw_enable_interrupts(ah);
 
-	ath_print(common, ATH_DBG_INTERRUPT, "0x%x => 0x%x\n", omask, ints);
+	ath_debug(common, ATH_DBG_INTERRUPT, "0x%x => 0x%x\n", omask, ints);
 
 	/* TODO: global int Ref count */
 	mask = ints & ATH9K_INT_COMMON;
@@ -953,7 +953,7 @@ void ath9k_hw_set_interrupts(struct ath_hw *ah, enum ath9k_int ints)
 			mask2 |= AR_IMR_S2_CST;
 	}
 
-	ath_print(common, ATH_DBG_INTERRUPT, "new IMR 0x%x\n", mask);
+	ath_debug(common, ATH_DBG_INTERRUPT, "new IMR 0x%x\n", mask);
 	REG_WRITE(ah, AR_IMR, mask);
 	ah->imrs2_reg &= ~(AR_IMR_S2_TIM | AR_IMR_S2_DTIM | AR_IMR_S2_DTIMSYNC |
 			   AR_IMR_S2_CABEND | AR_IMR_S2_CABTO |
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 50bdb5d..28cf439 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -261,7 +261,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	if (!(sc->sc_flags & SC_OP_OFFCHANNEL))
 		caldata = &aphy->caldata;
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "(%u MHz) -> (%u MHz), conf_is_ht40: %d fastcc: %d\n",
 		  sc->sc_ah->curchan->channel,
 		  channel->center_freq, conf_is_ht40(conf),
@@ -269,7 +269,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 
 	r = ath9k_hw_reset(ah, hchan, caldata, fastcc);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
 			  "reset status %d\n",
 			  channel->center_freq, r);
@@ -277,7 +277,7 @@ int ath_set_channel(struct ath_softc *sc, struct ieee80211_hw *hw,
 	}
 
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to restart recv logic\n");
 		r = -EIO;
 		goto ps_restore;
@@ -390,7 +390,7 @@ void ath_paprd_calibrate(struct work_struct *work)
 				msecs_to_jiffies(ATH_PAPRD_TIMEOUT));
 		sc->paprd_pending = false;
 		if (!time_left) {
-			ath_print(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
+			ath_debug(ath9k_hw_common(ah), ATH_DBG_CALIBRATE,
 				  "Timeout waiting for paprd training on "
 				  "TX chain %d\n",
 				  chain);
@@ -452,7 +452,7 @@ void ath_ani_calibrate(unsigned long data)
 	/* Long calibration runs independently of short calibration. */
 	if ((timestamp - common->ani.longcal_timer) >= long_cal_interval) {
 		longcal = true;
-		ath_print(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
+		ath_debug(common, ATH_DBG_ANI, "longcal @%lu\n", jiffies);
 		common->ani.longcal_timer = timestamp;
 	}
 
@@ -460,7 +460,7 @@ void ath_ani_calibrate(unsigned long data)
 	if (!common->ani.caldone) {
 		if ((timestamp - common->ani.shortcal_timer) >= short_cal_interval) {
 			shortcal = true;
-			ath_print(common, ATH_DBG_ANI,
+			ath_debug(common, ATH_DBG_ANI,
 				  "shortcal @%lu\n", jiffies);
 			common->ani.shortcal_timer = timestamp;
 			common->ani.resetcal_timer = timestamp;
@@ -545,7 +545,7 @@ void ath_update_chainmask(struct ath_softc *sc, int is_ht)
 		common->rx_chainmask = 1;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "tx chmask: %d, rx chmask: %d\n",
 		  common->tx_chainmask,
 		  common->rx_chainmask);
@@ -641,7 +641,7 @@ void ath9k_tasklet(unsigned long data)
 		 * TSF sync does not look correct; remain awake to sync with
 		 * the next Beacon.
 		 */
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "TSFOOR - Sync with next Beacon\n");
 		sc->ps_flags |= PS_WAIT_FOR_BEACON | PS_BEACON_SYNC;
 	}
@@ -840,7 +840,7 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 	struct ath_common *common = ath9k_hw_common(ah);
 
 	if (bss_conf->assoc) {
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "Bss Info ASSOC %d, bssid: %pM\n",
 			   bss_conf->aid, common->curbssid);
 
@@ -865,7 +865,7 @@ static void ath9k_bss_assoc_info(struct ath_softc *sc,
 		sc->sc_flags |= SC_OP_ANI_RUN;
 		ath_start_ani(common);
 	} else {
-		ath_print(common, ATH_DBG_CONFIG, "Bss Info DISASSOC\n");
+		ath_debug(common, ATH_DBG_CONFIG, "Bss Info DISASSOC\n");
 		common->curaid = 0;
 		/* Stop ANI */
 		sc->sc_flags &= ~SC_OP_ANI_RUN;
@@ -890,7 +890,7 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
 			  "reset status %d\n",
 			  channel->center_freq, r);
@@ -898,7 +898,7 @@ void ath_radio_enable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	ath_update_txpow(sc);
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to restart recv logic\n");
 		spin_unlock_bh(&sc->sc_pcu_lock);
 		return;
@@ -953,7 +953,7 @@ void ath_radio_disable(struct ath_softc *sc, struct ieee80211_hw *hw)
 
 	r = ath9k_hw_reset(ah, ah->curchan, ah->caldata, false);
 	if (r) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Unable to reset channel (%u MHz), "
 			  "reset status %d\n",
 			  channel->center_freq, r);
@@ -991,11 +991,11 @@ int ath_reset(struct ath_softc *sc, bool retry_tx)
 
 	r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 	if (r)
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d\n", r);
 
 	if (ath_startrecv(sc) != 0)
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to start recv logic\n");
 
 	/*
@@ -1068,7 +1068,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	struct ath9k_channel *init_channel;
 	int r;
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Starting driver with initial channel: %d MHz\n",
 		  curchan->center_freq);
 
@@ -1114,7 +1114,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	spin_lock_bh(&sc->sc_pcu_lock);
 	r = ath9k_hw_reset(ah, init_channel, ah->caldata, false);
 	if (r) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to reset hardware; reset status %d "
 			  "(freq %u MHz)\n", r,
 			  curchan->center_freq);
@@ -1136,7 +1136,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	 * here except setup the interrupt mask.
 	 */
 	if (ath_startrecv(sc) != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Unable to start recv logic\n");
 		r = -EIO;
 		spin_unlock_bh(&sc->sc_pcu_lock);
@@ -1202,7 +1202,7 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
 	if (aphy->state != ATH_WIPHY_ACTIVE && aphy->state != ATH_WIPHY_SCAN) {
-		ath_print(common, ATH_DBG_XMIT,
+		ath_debug(common, ATH_DBG_XMIT,
 			  "ath9k: %s: TX in unexpected wiphy state "
 			  "%d\n", wiphy_name(hw->wiphy), aphy->state);
 		goto exit;
@@ -1216,7 +1216,7 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 		if (ieee80211_is_data(hdr->frame_control) &&
 		    !ieee80211_is_nullfunc(hdr->frame_control) &&
 		    !ieee80211_has_pm(hdr->frame_control)) {
-			ath_print(common, ATH_DBG_PS, "Add PM=1 for a TX frame "
+			ath_debug(common, ATH_DBG_PS, "Add PM=1 for a TX frame "
 				  "while in PS mode\n");
 			hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PM);
 		}
@@ -1232,11 +1232,11 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 		if (!(sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_AUTOSLEEP))
 			ath9k_hw_setrxabort(sc->sc_ah, 0);
 		if (ieee80211_is_pspoll(hdr->frame_control)) {
-			ath_print(common, ATH_DBG_PS,
+			ath_debug(common, ATH_DBG_PS,
 				  "Sending PS-Poll to pick a buffered frame\n");
 			sc->ps_flags |= PS_WAIT_FOR_PSPOLL_DATA;
 		} else {
-			ath_print(common, ATH_DBG_PS,
+			ath_debug(common, ATH_DBG_PS,
 				  "Wake up to complete TX\n");
 			sc->ps_flags |= PS_WAIT_FOR_TX_ACK;
 		}
@@ -1251,10 +1251,10 @@ static int ath9k_tx(struct ieee80211_hw *hw,
 	memset(&txctl, 0, sizeof(struct ath_tx_control));
 	txctl.txq = sc->tx.txq_map[skb_get_queue_mapping(skb)];
 
-	ath_print(common, ATH_DBG_XMIT, "transmitting packet, skb: %p\n", skb);
+	ath_debug(common, ATH_DBG_XMIT, "transmitting packet, skb: %p\n", skb);
 
 	if (ath_tx_start(hw, skb, &txctl) != 0) {
-		ath_print(common, ATH_DBG_XMIT, "TX failed\n");
+		ath_debug(common, ATH_DBG_XMIT, "TX failed\n");
 		goto exit;
 	}
 
@@ -1294,7 +1294,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 	}
 
 	if (sc->sc_flags & SC_OP_INVALID) {
-		ath_print(common, ATH_DBG_ANY, "Device not present\n");
+		ath_debug(common, ATH_DBG_ANY, "Device not present\n");
 		mutex_unlock(&sc->mutex);
 		return;
 	}
@@ -1343,7 +1343,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	mutex_unlock(&sc->mutex);
 
-	ath_print(common, ATH_DBG_CONFIG, "Driver halt\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Driver halt\n");
 }
 
 static int ath9k_add_interface(struct ieee80211_hw *hw,
@@ -1376,13 +1376,13 @@ static int ath9k_add_interface(struct ieee80211_hw *hw,
 		ic_opmode = vif->type;
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			"Interface type %d not yet supported\n", vif->type);
 		ret = -EOPNOTSUPP;
 		goto out;
 	}
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Attach a VIF of type: %d\n", ic_opmode);
 
 	/* Set the VIF opmode */
@@ -1438,7 +1438,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	struct ath_vif *avp = (void *)vif->drv_priv;
 	int i;
 
-	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Detach Interface\n");
 
 	mutex_lock(&sc->mutex);
 
@@ -1545,7 +1545,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 		if (enable_radio) {
 			sc->ps_idle = false;
 			ath_radio_enable(sc, hw);
-			ath_print(common, ATH_DBG_CONFIG,
+			ath_debug(common, ATH_DBG_CONFIG,
 				  "not-idle: enabling radio\n");
 		}
 	}
@@ -1568,11 +1568,11 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 
 	if (changed & IEEE80211_CONF_CHANGE_MONITOR) {
 		if (conf->flags & IEEE80211_CONF_MONITOR) {
-			ath_print(common, ATH_DBG_CONFIG,
+			ath_debug(common, ATH_DBG_CONFIG,
 				  "Monitor mode is enabled\n");
 			sc->sc_ah->is_monitoring = true;
 		} else {
-			ath_print(common, ATH_DBG_CONFIG,
+			ath_debug(common, ATH_DBG_CONFIG,
 				  "Monitor mode is disabled\n");
 			sc->sc_ah->is_monitoring = false;
 		}
@@ -1605,7 +1605,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 			goto skip_chan_change;
 		}
 
-		ath_print(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
+		ath_debug(common, ATH_DBG_CONFIG, "Set channel: %d MHz\n",
 			  curchan->center_freq);
 
 		/* XXX: remove me eventualy */
@@ -1639,7 +1639,7 @@ static int ath9k_config(struct ieee80211_hw *hw, u32 changed)
 		}
 
 		if (ath_set_channel(sc, hw, &sc->sc_ah->channels[pos]) < 0) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Unable to set channel\n");
 			mutex_unlock(&sc->mutex);
 			return -EINVAL;
@@ -1665,7 +1665,7 @@ skip_chan_change:
 	spin_unlock_bh(&sc->wiphy_lock);
 
 	if (disable_radio) {
-		ath_print(common, ATH_DBG_CONFIG, "idle: disabling radio\n");
+		ath_debug(common, ATH_DBG_CONFIG, "idle: disabling radio\n");
 		sc->ps_idle = true;
 		ath_radio_disable(sc, hw);
 	}
@@ -1704,7 +1704,7 @@ static void ath9k_configure_filter(struct ieee80211_hw *hw,
 	ath9k_hw_setrxfilter(sc->sc_ah, rfilt);
 	ath9k_ps_restore(sc);
 
-	ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+	ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
 		  "Set HW RX filter: 0x%x\n", rfilt);
 }
 
@@ -1756,7 +1756,7 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 	qi.tqi_cwmax = params->cw_max;
 	qi.tqi_burstTime = params->txop;
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "Configure tx [queue/halq] [%d/%d],  "
 		  "aifs: %d, cw_min: %d, cw_max: %d, txop: %d\n",
 		  queue, txq->axq_qnum, params->aifs, params->cw_min,
@@ -1764,7 +1764,7 @@ static int ath9k_conf_tx(struct ieee80211_hw *hw, u16 queue,
 
 	ret = ath_txq_update(sc, txq->axq_qnum, &qi);
 	if (ret)
-		ath_print(common, ATH_DBG_FATAL, "TXQ Update failed\n");
+		ath_debug(common, ATH_DBG_FATAL, "TXQ Update failed\n");
 
 	if (sc->sc_ah->opmode == NL80211_IFTYPE_ADHOC)
 		if (queue == WME_AC_BE && !ret)
@@ -1791,7 +1791,7 @@ static int ath9k_set_key(struct ieee80211_hw *hw,
 
 	mutex_lock(&sc->mutex);
 	ath9k_ps_wakeup(sc);
-	ath_print(common, ATH_DBG_CONFIG, "Set HW Key\n");
+	ath_debug(common, ATH_DBG_CONFIG, "Set HW Key\n");
 
 	switch (cmd) {
 	case SET_KEY:
@@ -1850,7 +1850,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 		if (vif->type == NL80211_IFTYPE_ADHOC)
 			ath_update_chainmask(sc, 0);
 
-		ath_print(common, ATH_DBG_CONFIG,
+		ath_debug(common, ATH_DBG_CONFIG,
 			  "BSSID: %pM aid: 0x%x\n",
 			  common->curbssid, common->curaid);
 
@@ -1908,7 +1908,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed PREAMBLE %d\n",
 			  bss_conf->use_short_preamble);
 		if (bss_conf->use_short_preamble)
 			sc->sc_flags |= SC_OP_PREAMBLE_SHORT;
@@ -1917,7 +1917,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed CTS PROT %d\n",
 			  bss_conf->use_cts_prot);
 		if (bss_conf->use_cts_prot &&
 		    hw->conf.channel->band != IEEE80211_BAND_5GHZ)
@@ -1927,7 +1927,7 @@ static void ath9k_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ASSOC) {
-		ath_print(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
+		ath_debug(common, ATH_DBG_CONFIG, "BSS Changed ASSOC %d\n",
 			bss_conf->assoc);
 		ath9k_bss_assoc_info(sc, hw, vif, bss_conf);
 	}
@@ -2013,7 +2013,7 @@ static int ath9k_ampdu_action(struct ieee80211_hw *hw,
 		ath9k_ps_restore(sc);
 		break;
 	default:
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Unknown AMPDU action\n");
 	}
 
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index 09f69a9..d952a0e 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -59,7 +59,7 @@ static bool ath_pci_eeprom_read(struct ath_common *common, u32 off, u16 *data)
 
 	if (pdata) {
 		if (off >= (ARRAY_SIZE(pdata->eeprom_data))) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "%s: eeprom read failed, offset %08x "
 				  "is out of range\n",
 				  __func__, off);
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 3e6ea3b..92b6ade 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1184,7 +1184,7 @@ struct ath_rate_table *ath_choose_rate_table(struct ath_softc *sc,
 			return &ar5416_11na_ratetable;
 		return &ar5416_11a_ratetable;
 	default:
-		ath_print(common, ATH_DBG_CONFIG, "Invalid band\n");
+		ath_debug(common, ATH_DBG_CONFIG, "Invalid band\n");
 		return NULL;
 	}
 }
@@ -1259,7 +1259,7 @@ static void ath_rc_init(struct ath_softc *sc,
 	ath_rc_priv->rate_max_phy = ath_rc_priv->valid_rate_index[k-4];
 	ath_rc_priv->rate_table = rate_table;
 
-	ath_print(common, ATH_DBG_CONFIG,
+	ath_debug(common, ATH_DBG_CONFIG,
 		  "RC Initialized with capabilities: 0x%x\n",
 		  ath_rc_priv->ht_cap);
 }
@@ -1463,7 +1463,7 @@ static void ath_rate_update(void *priv, struct ieee80211_supported_band *sband,
 						   oper_cw40, oper_sgi);
 			ath_rc_init(sc, priv_sta, sband, sta, rate_table);
 
-			ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+			ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
 				  "Operating HT Bandwidth changed to: %d\n",
 				  sc->hw->conf.channel_type);
 		}
@@ -1576,7 +1576,7 @@ static void *ath_rate_alloc_sta(void *priv, struct ieee80211_sta *sta, gfp_t gfp
 
 	rate_priv = kzalloc(sizeof(struct ath_rate_priv), gfp);
 	if (!rate_priv) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Unable to allocate private rc structure\n");
 		return NULL;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 262c815..606e2bc 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -165,7 +165,7 @@ static void ath_rx_addbuffer_edma(struct ath_softc *sc,
 	u32 nbuf = 0;
 
 	if (list_empty(&sc->rx.rxbuf)) {
-		ath_print(common, ATH_DBG_QUEUE, "No free rx buf available\n");
+		ath_debug(common, ATH_DBG_QUEUE, "No free rx buf available\n");
 		return;
 	}
 
@@ -269,7 +269,7 @@ static int ath_rx_edma_init(struct ath_softc *sc, int nbufs)
 				dev_kfree_skb_any(skb);
 				bf->bf_mpdu = NULL;
 				bf->bf_buf_addr = 0;
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					"dma_mapping_error() on RX init\n");
 				error = -ENOMEM;
 				goto rx_init_fail;
@@ -327,7 +327,7 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 		common->rx_bufsize = roundup(IEEE80211_MAX_MPDU_LEN,
 				min(common->cachelsz, (u16)64));
 
-		ath_print(common, ATH_DBG_CONFIG, "cachelsz %u rxbufsize %u\n",
+		ath_debug(common, ATH_DBG_CONFIG, "cachelsz %u rxbufsize %u\n",
 				common->cachelsz, common->rx_bufsize);
 
 		/* Initialize rx descriptors */
@@ -335,7 +335,7 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 		error = ath_descdma_setup(sc, &sc->rx.rxdma, &sc->rx.rxbuf,
 				"rx", nbufs, 1, 0);
 		if (error != 0) {
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "failed to allocate rx descriptors: %d\n",
 				  error);
 			goto err;
@@ -358,7 +358,7 @@ int ath_rx_init(struct ath_softc *sc, int nbufs)
 				dev_kfree_skb_any(skb);
 				bf->bf_mpdu = NULL;
 				bf->bf_buf_addr = 0;
-				ath_print(common, ATH_DBG_FATAL,
+				ath_debug(common, ATH_DBG_FATAL,
 					  "dma_mapping_error() on RX init\n");
 				error = -ENOMEM;
 				goto err;
@@ -590,7 +590,7 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 
 	if (sc->ps_flags & PS_BEACON_SYNC) {
 		sc->ps_flags &= ~PS_BEACON_SYNC;
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "Reconfigure Beacon timers based on "
 			  "timestamp from the AP\n");
 		ath_beacon_config(sc, NULL);
@@ -604,7 +604,7 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 		 * a backup trigger for returning into NETWORK SLEEP state,
 		 * so we are waiting for it as well.
 		 */
-		ath_print(common, ATH_DBG_PS, "Received DTIM beacon indicating "
+		ath_debug(common, ATH_DBG_PS, "Received DTIM beacon indicating "
 			  "buffered broadcast/multicast frame(s)\n");
 		sc->ps_flags |= PS_WAIT_FOR_CAB | PS_WAIT_FOR_BEACON;
 		return;
@@ -617,7 +617,7 @@ static void ath_rx_ps_beacon(struct ath_softc *sc, struct sk_buff *skb)
 		 * been delivered.
 		 */
 		sc->ps_flags &= ~PS_WAIT_FOR_CAB;
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "PS wait for CAB frames timed out\n");
 	}
 }
@@ -643,13 +643,13 @@ static void ath_rx_ps(struct ath_softc *sc, struct sk_buff *skb)
 		 * point.
 		 */
 		sc->ps_flags &= ~(PS_WAIT_FOR_CAB | PS_WAIT_FOR_BEACON);
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "All PS CAB frames received, back to sleep\n");
 	} else if ((sc->ps_flags & PS_WAIT_FOR_PSPOLL_DATA) &&
 		   !is_multicast_ether_addr(hdr->addr1) &&
 		   !ieee80211_has_morefrags(hdr->frame_control)) {
 		sc->ps_flags &= ~PS_WAIT_FOR_PSPOLL_DATA;
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "Going back to sleep after having received "
 			  "PS-Poll data (0x%lx)\n",
 			sc->ps_flags & (PS_WAIT_FOR_BEACON |
@@ -953,7 +953,7 @@ static int ath9k_process_rate(struct ath_common *common,
 	 * No valid hardware bitrate found -- we should not get here
 	 * because hardware has already validated this frame as OK.
 	 */
-	ath_print(common, ATH_DBG_XMIT, "unsupported hw bitrate detected "
+	ath_debug(common, ATH_DBG_XMIT, "unsupported hw bitrate detected "
 		  "0x%02x using 1 Mbit\n", rx_stats->rs_rate);
 
 	return -EINVAL;
@@ -1725,7 +1725,7 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
 			dev_kfree_skb_any(requeue_skb);
 			bf->bf_mpdu = NULL;
 			bf->bf_buf_addr = 0;
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "dma_mapping_error() on RX\n");
 			ath_rx_send_to_mac80211(hw, sc, skb, rxs);
 			break;
diff --git a/drivers/net/wireless/ath/ath9k/virtual.c b/drivers/net/wireless/ath/ath9k/virtual.c
index d5442c3..dfb763a 100644
--- a/drivers/net/wireless/ath/ath9k/virtual.c
+++ b/drivers/net/wireless/ath/ath9k/virtual.c
@@ -656,7 +656,7 @@ void ath9k_set_wiphy_idle(struct ath_wiphy *aphy, bool idle)
 	struct ath_softc *sc = aphy->sc;
 
 	aphy->idle = idle;
-	ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
+	ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_CONFIG,
 		  "Marking %s as %s\n",
 		  wiphy_name(aphy->hw->wiphy),
 		  idle ? "idle" : "not-idle");
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 93a8bda..a295263 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -125,7 +125,7 @@ void ath9k_wmi_tasklet(unsigned long data)
 	struct ath9k_htc_priv *priv = (struct ath9k_htc_priv *)data;
 	struct ath_common *common = ath9k_hw_common(priv->ah);
 
-	ath_print(common, ATH_DBG_WMI, "SWBA Event received\n");
+	ath_debug(common, ATH_DBG_WMI, "SWBA Event received\n");
 
 	ath9k_htc_swba(priv, priv->wmi->beacon_pending);
 
@@ -286,7 +286,7 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 
 	time_left = wait_for_completion_timeout(&wmi->cmd_wait, timeout);
 	if (!time_left) {
-		ath_print(common, ATH_DBG_WMI,
+		ath_debug(common, ATH_DBG_WMI,
 			  "Timeout waiting for WMI command: %s\n",
 			  wmi_cmd_to_name(cmd_id));
 		mutex_unlock(&wmi->op_mutex);
@@ -298,7 +298,7 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 	return 0;
 
 out:
-	ath_print(common, ATH_DBG_WMI,
+	ath_debug(common, ATH_DBG_WMI,
 		  "WMI failure for: %s\n", wmi_cmd_to_name(cmd_id));
 	mutex_unlock(&wmi->op_mutex);
 	kfree_skb(skb);
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 495432e..c2bfda4 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -985,7 +985,7 @@ struct ath_txq *ath_txq_setup(struct ath_softc *sc, int qtype, int subtype)
 		return NULL;
 	}
 	if (qnum >= ARRAY_SIZE(sc->tx.txq)) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "qnum %u out of range, max %u!\n",
 			  qnum, (unsigned int)ARRAY_SIZE(sc->tx.txq));
 		ath9k_hw_releasetxqueue(ah, qnum);
@@ -1038,7 +1038,7 @@ int ath_txq_update(struct ath_softc *sc, int qnum,
 	qi.tqi_readyTime = qinfo->tqi_readyTime;
 
 	if (!ath9k_hw_set_txq_props(ah, qnum, &qi)) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "Unable to update hardware queue %u!\n", qnum);
 		error = -EIO;
 	} else {
@@ -1197,12 +1197,12 @@ void ath_drain_all_txq(struct ath_softc *sc, bool retry_tx)
 	if (npend) {
 		int r;
 
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Failed to stop TX DMA. Resetting hardware!\n");
 
 		r = ath9k_hw_reset(ah, sc->sc_ah->curchan, ah->caldata, false);
 		if (r)
-			ath_print(common, ATH_DBG_FATAL,
+			ath_debug(common, ATH_DBG_FATAL,
 				  "Unable to reset hardware; reset status %d\n",
 				  r);
 	}
@@ -1287,7 +1287,7 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 
 	bf = list_first_entry(head, struct ath_buf, list);
 
-	ath_print(common, ATH_DBG_QUEUE,
+	ath_debug(common, ATH_DBG_QUEUE,
 		  "qnum: %d, txq depth: %d\n", txq->axq_qnum, txq->axq_depth);
 
 	if (sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_EDMA) {
@@ -1296,7 +1296,7 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 			return;
 		}
 		if (!list_empty(&txq->txq_fifo[txq->txq_headidx]))
-			ath_print(common, ATH_DBG_XMIT,
+			ath_debug(common, ATH_DBG_XMIT,
 				  "Initializing tx fifo %d which "
 				  "is non-empty\n",
 				  txq->txq_headidx);
@@ -1304,7 +1304,7 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 		list_splice_init(head, &txq->txq_fifo[txq->txq_headidx]);
 		INCR(txq->txq_headidx, ATH_TXFIFO_DEPTH);
 		ath9k_hw_puttxbuf(ah, txq->axq_qnum, bf->bf_daddr);
-		ath_print(common, ATH_DBG_XMIT,
+		ath_debug(common, ATH_DBG_XMIT,
 			  "TXDP[%u] = %llx (%p)\n",
 			  txq->axq_qnum, ito64(bf->bf_daddr), bf->bf_desc);
 	} else {
@@ -1312,13 +1312,13 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, struct ath_txq *txq,
 
 		if (txq->axq_link == NULL) {
 			ath9k_hw_puttxbuf(ah, txq->axq_qnum, bf->bf_daddr);
-			ath_print(common, ATH_DBG_XMIT,
+			ath_debug(common, ATH_DBG_XMIT,
 					"TXDP[%u] = %llx (%p)\n",
 					txq->axq_qnum, ito64(bf->bf_daddr),
 					bf->bf_desc);
 		} else {
 			*txq->axq_link = bf->bf_daddr;
-			ath_print(common, ATH_DBG_XMIT,
+			ath_debug(common, ATH_DBG_XMIT,
 					"link[%u] (%p)=%llx (%p)\n",
 					txq->axq_qnum, txq->axq_link,
 					ito64(bf->bf_daddr), bf->bf_desc);
@@ -1629,7 +1629,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ieee80211_hw *hw,
 
 	bf = ath_tx_get_buffer(sc);
 	if (!bf) {
-		ath_print(common, ATH_DBG_XMIT, "TX buffers are full\n");
+		ath_debug(common, ATH_DBG_XMIT, "TX buffers are full\n");
 		return NULL;
 	}
 
@@ -1644,7 +1644,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ieee80211_hw *hw,
 	if (unlikely(dma_mapping_error(sc->dev, bf->bf_buf_addr))) {
 		bf->bf_mpdu = NULL;
 		bf->bf_buf_addr = 0;
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_FATAL,
 			  "dma_mapping_error() on TX\n");
 		ath_tx_return_buffer(sc, bf);
 		return NULL;
@@ -1792,7 +1792,7 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 	struct ieee80211_hdr * hdr = (struct ieee80211_hdr *)skb->data;
 	int q, padpos, padsize;
 
-	ath_print(common, ATH_DBG_XMIT, "TX complete: skb: %p\n", skb);
+	ath_debug(common, ATH_DBG_XMIT, "TX complete: skb: %p\n", skb);
 
 	if (aphy)
 		hw = aphy->hw;
@@ -1818,7 +1818,7 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 
 	if (sc->ps_flags & PS_WAIT_FOR_TX_ACK) {
 		sc->ps_flags &= ~PS_WAIT_FOR_TX_ACK;
-		ath_print(common, ATH_DBG_PS,
+		ath_debug(common, ATH_DBG_PS,
 			  "Going back to sleep after having "
 			  "received TX status (0x%lx)\n",
 			sc->ps_flags & (PS_WAIT_FOR_BEACON |
@@ -1969,7 +1969,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 	int status;
 	int qnum;
 
-	ath_print(common, ATH_DBG_QUEUE, "tx queue %d (%x), link %p\n",
+	ath_debug(common, ATH_DBG_QUEUE, "tx queue %d (%x), link %p\n",
 		  txq->axq_qnum, ath9k_hw_gettxbuf(sc->sc_ah, txq->axq_qnum),
 		  txq->axq_link);
 
@@ -2086,7 +2086,7 @@ static void ath_tx_complete_poll_work(struct work_struct *work)
 		}
 
 	if (needreset) {
-		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_RESET,
+		ath_debug(ath9k_hw_common(sc->sc_ah), ATH_DBG_RESET,
 			  "tx hung, resetting the chip\n");
 		ath9k_ps_wakeup(sc);
 		ath_reset(sc, true);
@@ -2129,7 +2129,7 @@ void ath_tx_edma_tasklet(struct ath_softc *sc)
 		if (status == -EINPROGRESS)
 			break;
 		if (status == -EIO) {
-			ath_print(common, ATH_DBG_XMIT,
+			ath_debug(common, ATH_DBG_XMIT,
 				  "Error processing tx status\n");
 			break;
 		}
@@ -2241,7 +2241,7 @@ int ath_tx_init(struct ath_softc *sc, int nbufs)
 	error = ath_descdma_setup(sc, &sc->tx.txdma, &sc->tx.txbuf,
 				  "tx", nbufs, 1, 1);
 	if (error != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Failed to allocate tx descriptors: %d\n", error);
 		goto err;
 	}
@@ -2249,7 +2249,7 @@ int ath_tx_init(struct ath_softc *sc, int nbufs)
 	error = ath_descdma_setup(sc, &sc->beacon.bdma, &sc->beacon.bbuf,
 				  "beacon", ATH_BCBUF, 1, 1);
 	if (error != 0) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Failed to allocate beacon descriptors: %d\n", error);
 		goto err;
 	}
diff --git a/drivers/net/wireless/ath/debug.c b/drivers/net/wireless/ath/debug.c
index a9600ba..2fc611d 100644
--- a/drivers/net/wireless/ath/debug.c
+++ b/drivers/net/wireless/ath/debug.c
@@ -17,7 +17,7 @@
 #include "ath.h"
 #include "debug.h"
 
-void ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
+void ath_debug(struct ath_common *common, int dbg_mask, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
@@ -34,7 +34,7 @@ void ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
 
 	va_end(args);
 }
-EXPORT_SYMBOL(ath_print);
+EXPORT_SYMBOL(ath_debug);
 
 const char *ath_opmode_to_string(enum nl80211_iftype opmode)
 {
diff --git a/drivers/net/wireless/ath/debug.h b/drivers/net/wireless/ath/debug.h
index f207007..dc0e5e3 100644
--- a/drivers/net/wireless/ath/debug.h
+++ b/drivers/net/wireless/ath/debug.h
@@ -68,12 +68,12 @@ enum ATH_DEBUG {
 #define ATH_DBG_DEFAULT (ATH_DBG_FATAL)
 
 #ifdef CONFIG_ATH_DEBUG
-void ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
+void ath_debug(struct ath_common *common, int dbg_mask, const char *fmt, ...)
 	__attribute__ ((format (printf, 3, 4)));
 #define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
 #else
 static inline void __attribute__ ((format (printf, 3, 4)))
-ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
+ath_debug(struct ath_common *common, int dbg_mask, const char *fmt, ...)
 {
 }
 #define ATH_DBG_WARN(foo, arg)
diff --git a/drivers/net/wireless/ath/key.c b/drivers/net/wireless/ath/key.c
index 62e3dac..12eaee4 100644
--- a/drivers/net/wireless/ath/key.c
+++ b/drivers/net/wireless/ath/key.c
@@ -37,7 +37,7 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry)
 	void *ah = common->ah;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "keychache entry %u out of range\n", entry);
 		return false;
 	}
@@ -75,7 +75,7 @@ static bool ath_hw_keysetmac(struct ath_common *common,
 	void *ah = common->ah;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "keychache entry %u out of range\n", entry);
 		return false;
 	}
@@ -117,7 +117,7 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 	u32 keyType;
 
 	if (entry >= common->keymax) {
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "keycache entry %u out of range\n", entry);
 		return false;
 	}
@@ -128,7 +128,7 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 		break;
 	case ATH_CIPHER_AES_CCM:
 		if (!(common->crypt_caps & ATH_CRYPT_CAP_CIPHER_AESCCM)) {
-			ath_print(common, ATH_DBG_ANY,
+			ath_debug(common, ATH_DBG_ANY,
 				  "AES-CCM not supported by this mac rev\n");
 			return false;
 		}
@@ -137,14 +137,14 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 	case ATH_CIPHER_TKIP:
 		keyType = AR_KEYTABLE_TYPE_TKIP;
 		if (entry + 64 >= common->keymax) {
-			ath_print(common, ATH_DBG_ANY,
+			ath_debug(common, ATH_DBG_ANY,
 				  "entry %u inappropriate for TKIP\n", entry);
 			return false;
 		}
 		break;
 	case ATH_CIPHER_WEP:
 		if (k->kv_len < WLAN_KEY_LEN_WEP40) {
-			ath_print(common, ATH_DBG_ANY,
+			ath_debug(common, ATH_DBG_ANY,
 				  "WEP key length %u too small\n", k->kv_len);
 			return false;
 		}
@@ -159,7 +159,7 @@ static bool ath_hw_set_keycache_entry(struct ath_common *common, u16 entry,
 		keyType = AR_KEYTABLE_TYPE_CLR;
 		break;
 	default:
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "cipher %u not supported\n", k->kv_type);
 		return false;
 	}
@@ -341,7 +341,7 @@ static int ath_setkey_tkip(struct ath_common *common, u16 keyix, const u8 *key,
 	memcpy(hk->kv_mic, key_txmic, sizeof(hk->kv_mic));
 	if (!ath_hw_set_keycache_entry(common, keyix, hk, NULL)) {
 		/* TX MIC entry failed. No need to proceed further */
-		ath_print(common, ATH_DBG_FATAL,
+		ath_debug(common, ATH_DBG_FATAL,
 			  "Setting TX MIC Key Failed\n");
 		return 0;
 	}
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
