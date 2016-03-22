From: Ashwini Singh <Ashwini_Singh-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] ath9k: fix checkpatch.pl identation and sapce errors.
Date: Tue, 22 Mar 2016 12:23:48 +0530
Message-ID: <1458629628-6264-1-git-send-email-Ashwini_Singh@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<Rajeev_Kumar-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, Ashwini Singh <Ashwini_Singh-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
To: <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ashwini Singh <Ashwini_Singh-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/ath/ath9k/ani.c            |    2 +-
 drivers/net/wireless/ath/ath9k/antenna.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_aic.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c   |   20 ++++++++++----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c  |    8 ++++----
 drivers/net/wireless/ath/ath9k/ar9003_mci.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c     |    4 ++--
 drivers/net/wireless/ath/ath9k/ar9003_rtt.c     |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_wow.c     |   12 ++++++------
 drivers/net/wireless/ath/ath9k/ath9k.h          |    6 +++---
 drivers/net/wireless/ath/ath9k/beacon.c         |    6 +++---
 drivers/net/wireless/ath/ath9k/common-init.c    |    2 +-
 drivers/net/wireless/ath/ath9k/common.c         |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.c         |    4 ++--
 drivers/net/wireless/ath/ath9k/eeprom_4k.c      |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c     |    4 ++--
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c |    2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c   |    2 +-
 drivers/net/wireless/ath/ath9k/hw.c             |    9 ++++-----
 drivers/net/wireless/ath/ath9k/init.c           |    4 ++--
 drivers/net/wireless/ath/ath9k/reg_mci.h        |   14 +++++++-------
 drivers/net/wireless/ath/ath9k/reg_wow.h        |   14 +++++++-------
 drivers/net/wireless/ath/ath9k/xmit.c           |   12 ++++++------
 25 files changed, 70 insertions(+), 71 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index 815efe9..6bbf80b 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -432,7 +432,7 @@ void ath9k_hw_ani_monitor(struct ath_hw *ah, struct ath9k_channel *chan)
 			aniState->ofdmsTurn = true;
 		} else
 			return;
-			
+
 		ath9k_ani_restart(ah);
 	}
 }
diff --git a/drivers/net/wireless/ath/ath9k/antenna.c b/drivers/net/wireless/ath/ath9k/antenna.c
index a366843..c6b4ec7 100644
--- a/drivers/net/wireless/ath/ath9k/antenna.c
+++ b/drivers/net/wireless/ath/ath9k/antenna.c
@@ -314,7 +314,7 @@ static void ath_select_ant_div_from_quick_scan(struct ath_ant_comb *antcomb,
 		antcomb->rssi_first = main_rssi_avg;
 		antcomb->rssi_third = alt_rssi_avg;
 
-		switch(antcomb->second_quick_scan_conf) {
+		switch (antcomb->second_quick_scan_conf) {
 		case ATH_ANT_DIV_COMB_LNA1:
 			antcomb->rssi_lna1 = alt_rssi_avg;
 			break;
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_hw.c b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
index d480d2f..b5db5f1 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_hw.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_hw.c
@@ -92,7 +92,7 @@ static int ar9002_hw_init_mode_regs(struct ath_hw *ah)
 
 		if (!AR_SREV_5416_22_OR_LATER(ah)) {
 			/* override CLKDRV value */
-			INI_RA(addac, 31,1) = 0;
+			INI_RA(addac, 31, 1) = 0;
 		}
 	}
 	if (AR_SREV_9287_11_OR_LATER(ah)) {
diff --git a/drivers/net/wireless/ath/ath9k/ar9002_phy.c b/drivers/net/wireless/ath/ath9k/ar9002_phy.c
index db66245..298e621 100644
--- a/drivers/net/wireless/ath/ath9k/ar9002_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9002_phy.c
@@ -458,7 +458,7 @@ static void ar9002_hw_set_bt_ant_diversity(struct ath_hw *ah, bool enable)
 
 	regval = REG_READ(ah, AR_PHY_MULTICHAIN_GAIN_CTL);
 	regval &= (~(AR_PHY_9285_ANT_DIV_CTL_ALL));
-        /*
+	/*
 	 * Clear ant_fast_div_bias [14:9] since for WB195,
 	 * the main LNA is always LNA1.
 	 */
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_aic.c b/drivers/net/wireless/ath/ath9k/ar9003_aic.c
index 547cd46..e12a712 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_aic.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_aic.c
@@ -363,7 +363,7 @@ static bool ar9003_aic_cal_post_process(struct ath_hw *ah)
 				(start_idx - end_idx) +
 				aic_sram[start_idx].quad_path_gain_lin;
 
-		} else if (start_idx >= 0){
+		} else if (start_idx >= 0) {
 			/* interpolation */
 			aic_sram[i].dir_path_gain_lin =
 				(((end_idx - i) * aic_sram[start_idx].dir_path_gain_lin) +
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_calib.c b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
index 0c39199..1ff5424 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_calib.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_calib.c
@@ -700,15 +700,15 @@ static bool ar9003_hw_calc_iq_corr(struct ath_hw *ah,
 	}
 
 	if ((i2_p_q2_a0_d0 < 1024) || (i2_p_q2_a0_d0 > 2047) ||
-            (i2_p_q2_a1_d0 < 0) || (i2_p_q2_a1_d1 < 0) ||
-            (i2_p_q2_a0_d0 <= i2_m_q2_a0_d0) ||
-            (i2_p_q2_a0_d0 <= iq_corr_a0_d0) ||
-            (i2_p_q2_a0_d1 <= i2_m_q2_a0_d1) ||
-            (i2_p_q2_a0_d1 <= iq_corr_a0_d1) ||
-            (i2_p_q2_a1_d0 <= i2_m_q2_a1_d0) ||
-            (i2_p_q2_a1_d0 <= iq_corr_a1_d0) ||
-            (i2_p_q2_a1_d1 <= i2_m_q2_a1_d1) ||
-            (i2_p_q2_a1_d1 <= iq_corr_a1_d1)) {
+	    (i2_p_q2_a1_d0 < 0) || (i2_p_q2_a1_d1 < 0) ||
+	    (i2_p_q2_a0_d0 <= i2_m_q2_a0_d0) ||
+	    (i2_p_q2_a0_d0 <= iq_corr_a0_d0) ||
+	    (i2_p_q2_a0_d1 <= i2_m_q2_a0_d1) ||
+	    (i2_p_q2_a0_d1 <= iq_corr_a0_d1) ||
+	    (i2_p_q2_a1_d0 <= i2_m_q2_a1_d0) ||
+	    (i2_p_q2_a1_d0 <= iq_corr_a1_d0) ||
+	    (i2_p_q2_a1_d1 <= i2_m_q2_a1_d1) ||
+	    (i2_p_q2_a1_d1 <= iq_corr_a1_d1)) {
 		return false;
 	}
 
@@ -1327,7 +1327,7 @@ static void ar9003_hw_do_pcoem_manual_peak_cal(struct ath_hw *ah,
 		set_bit(SW_PKDET_DONE, &caldata->cal_flags);
 
 	if ((ah->caps.hw_caps & ATH9K_HW_CAP_RTT) && caldata) {
-		if (IS_CHAN_2GHZ(chan)){
+		if (IS_CHAN_2GHZ(chan)) {
 			caldata->caldac[0] = REG_READ_FIELD(ah,
 						    AR_PHY_65NM_RXRF_AGC(0),
 						    AR_PHY_65NM_RXRF_AGC_AGC2G_CALDAC_OVR);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index 54ed2f7..18e17771 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -2080,7 +2080,7 @@ static const struct ar9300_eeprom ar9300_x112 = {
 		.tempSlopeLow = 72,
 		.tempSlopeHigh = 105,
 		.xatten1DBLow = {0x10, 0x14, 0x10},
-		.xatten1MarginLow = {0x19, 0x19 , 0x19},
+		.xatten1MarginLow = {0x19, 0x19, 0x19},
 		.xatten1DBHigh = {0x1d, 0x20, 0x24},
 		.xatten1MarginHigh = {0x10, 0x10, 0x10}
 	},
@@ -4441,9 +4441,9 @@ static int ar9003_hw_tx_power_regwrite(struct ath_hw *ah, u8 * pPwrArray)
 		  POW_SM(pPwrArray[ALL_TARGET_LEGACY_1L_5L], 0)
 	    );
 
-        /* Write the power for duplicated frames - HT40 */
+	/* Write the power for duplicated frames - HT40 */
 
-        /* dup40_cck (LSB), dup40_ofdm, ext20_cck, ext20_ofdm (MSB) */
+	/* dup40_cck (LSB), dup40_ofdm, ext20_cck, ext20_ofdm (MSB) */
 	REG_WRITE(ah, AR_PHY_POWER_TX_RATE(8),
 		  POW_SM(pPwrArray[ALL_TARGET_LEGACY_6_24], 24) |
 		  POW_SM(pPwrArray[ALL_TARGET_LEGACY_1L_5L], 16) |
@@ -5340,7 +5340,7 @@ static void ath9k_hw_ar9300_set_txpower(struct ath_hw *ah,
 	unsigned int i = 0, paprd_scale_factor = 0;
 	u8 pwr_idx, min_pwridx = 0;
 
-	memset(targetPowerValT2, 0 , sizeof(targetPowerValT2));
+	memset(targetPowerValT2, 0, sizeof(targetPowerValT2));
 
 	/*
 	 * Get target powers from EEPROM - our baseline for TX Power
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mci.c b/drivers/net/wireless/ath/ath9k/ar9003_mci.c
index af5ee41..99bc134 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mci.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mci.c
@@ -890,7 +890,7 @@ static void ar9003_mci_set_btcoex_ctrl_9462(struct ath_hw *ah)
 {
 	u32 regval;
 
-        regval = SM(1, AR_BTCOEX_CTRL_AR9462_MODE) |
+	regval = SM(1, AR_BTCOEX_CTRL_AR9462_MODE) |
 		 SM(1, AR_BTCOEX_CTRL_WBTIMER_EN) |
 		 SM(1, AR_BTCOEX_CTRL_PA_SHARED) |
 		 SM(1, AR_BTCOEX_CTRL_LNA_SHARED) |
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
index 06c1ca6..5495d0e 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -518,7 +518,7 @@ static void ar9003_hw_spur_ofdm_work(struct ath_hw *ah,
 
 	} else {
 		spur_subchannel_sd = 0;
-		spur_freq_sd = (freq_offset << 9) /11;
+		spur_freq_sd = (freq_offset << 9) / 11;
 		spur_delta_phase = (freq_offset << 18) / 5;
 	}
 
@@ -2087,7 +2087,7 @@ bool ar9003_hw_bb_watchdog_check(struct ath_hw *ah)
 {
 	u32 val;
 
-	switch(ah->bb_watchdog_last_status) {
+	switch (ah->bb_watchdog_last_status) {
 	case 0x04000539:
 		val = REG_READ(ah, AR_PHY_RADAR_0);
 		val &= (~AR_PHY_RADAR_0_FIRPWR);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_rtt.c b/drivers/net/wireless/ath/ath9k/ar9003_rtt.c
index e4d11fa..e07d20a 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_rtt.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_rtt.c
@@ -211,7 +211,7 @@ bool ar9003_hw_rtt_restore(struct ath_hw *ah, struct ath9k_channel *chan)
 		return false;
 
 	if (test_bit(SW_PKDET_DONE, &ah->caldata->cal_flags)) {
-		if (IS_CHAN_2GHZ(chan)){
+		if (IS_CHAN_2GHZ(chan)) {
 			REG_RMW_FIELD(ah, AR_PHY_65NM_RXRF_AGC(0),
 				      AR_PHY_65NM_RXRF_AGC_AGC2G_CALDAC_OVR,
 				      ah->caldata->caldac[0]);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_wow.c b/drivers/net/wireless/ath/ath9k/ar9003_wow.c
index bea41df9..44d65f5 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_wow.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_wow.c
@@ -52,7 +52,7 @@ static void ath9k_hw_set_powermode_wow_sleep(struct ath_hw *ah)
 	if (AR_SREV_9462(ah) || AR_SREV_9565(ah)) {
 		if (!REG_READ(ah, AR_MAC_PCU_GEN_TIMER_TSF_SEL))
 			REG_CLR_BIT(ah, AR_DIRECT_CONNECT, AR_DC_TSF2_ENABLE);
-	} else if (AR_SREV_9485(ah)){
+	} else if (AR_SREV_9485(ah)) {
 		if (!(REG_READ(ah, AR_NDP2_TIMER_MODE) &
 		      AR_GEN_TIMERS2_MODE_ENABLE_MASK))
 			REG_CLR_BIT(ah, AR_DIRECT_CONNECT, AR_DC_TSF2_ENABLE);
@@ -310,9 +310,9 @@ void ath9k_hw_wow_enable(struct ath_hw *ah, u32 pattern_enable)
 	 * to generate next wow signal.
 	 */
 	REG_SET_BIT(ah, AR_PCIE_PM_CTRL, AR_PMCTRL_HOST_PME_EN |
-		    			 AR_PMCTRL_PWR_PM_CTRL_ENA |
-		    			 AR_PMCTRL_AUX_PWR_DET |
-		    			 AR_PMCTRL_WOW_PME_CLR);
+					 AR_PMCTRL_PWR_PM_CTRL_ENA |
+					 AR_PMCTRL_AUX_PWR_DET |
+					 AR_PMCTRL_WOW_PME_CLR);
 	REG_CLR_BIT(ah, AR_PCIE_PM_CTRL, AR_PMCTRL_WOW_PME_CLR);
 
 	/*
@@ -330,8 +330,8 @@ void ath9k_hw_wow_enable(struct ath_hw *ah, u32 pattern_enable)
 	 * AIFS time, Slot time, Keep Alive count.
 	 */
 	REG_SET_BIT(ah, AR_WOW_COUNT, AR_WOW_AIFS_CNT(AR_WOW_CNT_AIFS_CNT) |
-		    		      AR_WOW_SLOT_CNT(AR_WOW_CNT_SLOT_CNT) |
-		    		      AR_WOW_KEEP_ALIVE_CNT(AR_WOW_CNT_KA_CNT));
+				      AR_WOW_SLOT_CNT(AR_WOW_CNT_SLOT_CNT) |
+				      AR_WOW_KEEP_ALIVE_CNT(AR_WOW_CNT_KA_CNT));
 	/*
 	 * Beacon timeout.
 	 */
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 5294595..9fef8b5 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -139,8 +139,8 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 
 /* returns delimiter padding required given the packet length */
 #define ATH_AGGR_GET_NDELIM(_len)					\
-       (((_len) >= ATH_AGGR_MINPLEN) ? 0 :                             \
-        DIV_ROUND_UP(ATH_AGGR_MINPLEN - (_len), ATH_AGGR_DELIM_SZ))
+	(((_len) >= ATH_AGGR_MINPLEN) ? 0 :                             \
+	DIV_ROUND_UP(ATH_AGGR_MINPLEN - (_len), ATH_AGGR_DELIM_SZ))
 
 #define BAW_WITHIN(_start, _bawsz, _seqno) \
 	((((_seqno) - (_start)) & 4095) < (_bawsz))
@@ -661,7 +661,7 @@ void ath9k_set_txpower(struct ath_softc *sc, struct ieee80211_vif *vif);
 #define ATH_DEFAULT_BINTVAL     	100 /* TU */
 #define ATH_DEFAULT_BMISS_LIMIT 	10
 
-#define TSF_TO_TU(_h,_l) \
+#define TSF_TO_TU(_h, _l) \
 	((((u32)(_h)) << 22) | (((u32)(_l)) >> 10))
 
 struct ath_beacon {
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless/ath/ath9k/beacon.c
index 5cf0cd7..8c066f7 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -265,7 +265,7 @@ static int ath9k_beacon_choose_slot(struct ath_softc *sc)
 	intval = cur_conf->beacon_interval ? : ATH_DEFAULT_BINTVAL;
 	tsf = ath9k_hw_gettsf64(sc->sc_ah);
 	tsf += TU_TO_USEC(sc->sc_ah->config.sw_beacon_response_time);
-	tsftu = TSF_TO_TU((tsf * ATH_BCBUF) >>32, tsf * ATH_BCBUF);
+	tsftu = TSF_TO_TU((tsf * ATH_BCBUF) >> 32, tsf * ATH_BCBUF);
 	slot = (tsftu % (intval * ATH_BCBUF)) / intval;
 
 	ath_dbg(common, BEACON, "slot: %d tsf: %llu tsftu: %u\n",
@@ -586,8 +586,8 @@ void ath9k_beacon_config(struct ath_softc *sc, struct ieee80211_vif *vif,
 			 u32 changed)
 {
 	struct ieee80211_bss_conf *bss_conf = &vif->bss_conf;
-        struct ath_hw *ah = sc->sc_ah;
-        struct ath_common *common = ath9k_hw_common(ah);
+	struct ath_hw *ah = sc->sc_ah;
+	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath_vif *avp = (void *)vif->drv_priv;
 	struct ath_chanctx *ctx = avp->chanctx;
 	struct ath_beacon_config *cur_conf;
diff --git a/drivers/net/wireless/ath/ath9k/common-init.c b/drivers/net/wireless/ath/ath9k/common-init.c
index a006c14..f010ab2 100644
--- a/drivers/net/wireless/ath/ath9k/common-init.c
+++ b/drivers/net/wireless/ath/ath9k/common-init.c
@@ -90,7 +90,7 @@ static const struct ieee80211_channel ath9k_5ghz_chantable[] = {
 
 /* Atheros hardware rate code addition for short premble */
 #define SHPCHECK(__hw_rate, __flags) \
-	((__flags & IEEE80211_RATE_SHORT_PREAMBLE) ? (__hw_rate | 0x04 ) : 0)
+	((__flags & IEEE80211_RATE_SHORT_PREAMBLE) ? (__hw_rate | 0x04) : 0)
 
 #define RATE(_bitrate, _hw_rate, _flags) {              \
 	.bitrate        = (_bitrate),                   \
diff --git a/drivers/net/wireless/ath/ath9k/common.c b/drivers/net/wireless/ath/ath9k/common.c
index e8c6994..15c4084 100644
--- a/drivers/net/wireless/ath/ath9k/common.c
+++ b/drivers/net/wireless/ath/ath9k/common.c
@@ -142,7 +142,7 @@ void ath9k_cmn_rx_skb_postprocess(struct ath_common *common,
 	 * not try to remove padding from short control frames that do
 	 * not have payload. */
 	padsize = padpos & 3;
-	if (padsize && skb->len>=padpos+padsize+FCS_LEN) {
+	if (padsize && skb->len >= padpos+padsize+FCS_LEN) {
 		memmove(skb->data + padsize, skb->data, padpos);
 		skb_pull(skb, padsize);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index a794157..5444fa5 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -18,9 +18,9 @@
 
 void ath9k_hw_analog_shift_regwrite(struct ath_hw *ah, u32 reg, u32 val)
 {
-        REG_WRITE(ah, reg, val);
+	REG_WRITE(ah, reg, val);
 
-        if (ah->config.analog_shiftreg)
+	if (ah->config.analog_shiftreg)
 		udelay(100);
 }
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index 5da0826..10d16f8 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -415,7 +415,7 @@ static void ath9k_hw_set_4k_power_per_rate_table(struct ath_hw *ah,
 						 u16 powerLimit)
 {
 #define CMP_TEST_GRP \
-	(((cfgCtl & ~CTL_MODE_M)| (pCtlMode[ctlMode] & CTL_MODE_M)) ==	\
+	(((cfgCtl & ~CTL_MODE_M) | (pCtlMode[ctlMode] & CTL_MODE_M)) ==	\
 	 pEepData->ctlIndex[i])						\
 	|| (((cfgCtl & ~CTL_MODE_M) | (pCtlMode[ctlMode] & CTL_MODE_M)) == \
 	    ((pEepData->ctlIndex[i] & CTL_MODE_M) | SD_NO_CTL))
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index 959682f..52d41cb 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -454,7 +454,7 @@ static void ath9k_hw_def_set_gain(struct ath_hw *ah,
 			      pModal->xatten2Db[i]);
 		} else {
 			REG_RMW(ah, AR_PHY_GAIN_2GHZ + regChainOffset,
-				SM(pModal-> bswMargin[i], AR_PHY_GAIN_2GHZ_BSW_MARGIN),
+				SM(pModal->bswMargin[i], AR_PHY_GAIN_2GHZ_BSW_MARGIN),
 				AR_PHY_GAIN_2GHZ_BSW_MARGIN);
 			REG_RMW(ah, AR_PHY_GAIN_2GHZ + regChainOffset,
 				SM(pModal->bswAtten[i], AR_PHY_GAIN_2GHZ_BSW_ATTEN),
@@ -759,7 +759,7 @@ static void ath9k_adjust_pdadc_values(struct ath_hw *ah,
 	if (AR_SREV_9280_20_OR_LATER(ah)) {
 		if (AR5416_PWR_TABLE_OFFSET_DB != pwr_table_offset) {
 			/* shift the table to start at the new offset */
-			for (k = 0; k < (u16)NUM_PDADC(diff); k++ ) {
+			for (k = 0; k < (u16)NUM_PDADC(diff); k++) {
 				pdadcValues[k] = pdadcValues[k + diff];
 			}
 
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
index e6bcb4c..df8efa7 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_beacon.c
@@ -149,7 +149,7 @@ static void ath9k_htc_send_buffered(struct ath9k_htc_priv *priv,
 
 	skb = ieee80211_get_buffered_bc(priv->hw, vif);
 
-	while(skb) {
+	while (skb) {
 		hdr = (struct ieee80211_hdr *) skb->data;
 
 		padpos = ieee80211_hdrlen(hdr->frame_control);
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index 8647ab7..833a7c4 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -267,7 +267,7 @@ static void ath9k_multi_regread(void *hw_priv, u32 *addr,
        }
 
        ret = ath9k_wmi_cmd(priv->wmi, WMI_REG_READ_CMDID,
-			   (u8 *)tmpaddr , sizeof(u32) * count,
+			   (u8 *)tmpaddr, sizeof(u32) * count,
 			   (u8 *)tmpval, sizeof(u32) * count,
 			   100);
 	if (unlikely(ret)) {
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index e7a3101..7698478 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2909,7 +2909,7 @@ u64 ath9k_hw_gettsf64(struct ath_hw *ah)
 		tsf_upper1 = tsf_upper2;
 	}
 
-	WARN_ON( i == ATH9K_MAX_TSF_READ );
+	WARN_ON(i == ATH9K_MAX_TSF_READ);
 
 	return (((u64)tsf_upper1 << 32) | tsf_lower);
 }
@@ -2956,8 +2956,7 @@ void ath9k_hw_set11nmac2040(struct ath_hw *ah, struct ath9k_channel *chan)
 
 /* HW Generic timers configuration */
 
-static const struct ath_gen_timer_configuration gen_tmr_configuration[] =
-{
+static const struct ath_gen_timer_configuration gen_tmr_configuration[] = {
 	{AR_NEXT_NDP_TIMER, AR_NDP_PERIOD, AR_TIMER_MODE, 0x0080},
 	{AR_NEXT_NDP_TIMER, AR_NDP_PERIOD, AR_TIMER_MODE, 0x0080},
 	{AR_NEXT_NDP_TIMER, AR_NDP_PERIOD, AR_TIMER_MODE, 0x0080},
@@ -3216,7 +3215,7 @@ static const char *ath9k_hw_mac_bb_name(u32 mac_bb_version)
 {
 	int i;
 
-	for (i=0; i<ARRAY_SIZE(ath_mac_bb_names); i++) {
+	for (i = 0; i < ARRAY_SIZE(ath_mac_bb_names); i++) {
 		if (ath_mac_bb_names[i].version == mac_bb_version) {
 			return ath_mac_bb_names[i].name;
 		}
@@ -3233,7 +3232,7 @@ static const char *ath9k_hw_rf_name(u16 rf_version)
 {
 	int i;
 
-	for (i=0; i<ARRAY_SIZE(ath_rf_names); i++) {
+	for (i = 0; i < ARRAY_SIZE(ath_rf_names); i++) {
 		if (ath_rf_names[i].version == rf_version) {
 			return ath_rf_names[i].name;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 1c226d6..adce9c0 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -142,7 +142,7 @@ static unsigned int ath9k_ioread32(void *hw_priv, u32 reg_offset)
 }
 
 static void ath9k_multi_ioread32(void *hw_priv, u32 *addr,
-                                u32 *val, u16 count)
+				 u32 *val, u16 count)
 {
 	int i;
 
@@ -785,7 +785,7 @@ static void ath9k_set_mcc_capab(struct ath_softc *sc, struct ieee80211_hw *hw)
 	ieee80211_hw_set(hw, QUEUE_CONTROL);
 	hw->queues = ATH9K_NUM_TX_QUEUES;
 	hw->offchannel_tx_hw_queue = hw->queues - 1;
-	hw->wiphy->interface_modes &= ~ BIT(NL80211_IFTYPE_WDS);
+	hw->wiphy->interface_modes &= ~BIT(NL80211_IFTYPE_WDS);
 	hw->wiphy->iface_combinations = if_comb_multi;
 	hw->wiphy->n_iface_combinations = ARRAY_SIZE(if_comb_multi);
 	hw->wiphy->max_scan_ssids = 255;
diff --git a/drivers/net/wireless/ath/ath9k/reg_mci.h b/drivers/net/wireless/ath/ath9k/reg_mci.h
index 6251310..83c9a9c 100644
--- a/drivers/net/wireless/ath/ath9k/reg_mci.h
+++ b/drivers/net/wireless/ath/ath9k/reg_mci.h
@@ -290,9 +290,9 @@
 				  AR_MCI_INTERRUPT_CONT_INFO_TIMEOUT)
 
 #define AR_MCI_INTERRUPT_MSG_FAIL_MASK (AR_MCI_INTERRUPT_RX_HW_MSG_FAIL | \
-                                        AR_MCI_INTERRUPT_RX_SW_MSG_FAIL | \
-                                        AR_MCI_INTERRUPT_TX_HW_MSG_FAIL | \
-                                        AR_MCI_INTERRUPT_TX_SW_MSG_FAIL)
+					AR_MCI_INTERRUPT_RX_SW_MSG_FAIL | \
+					AR_MCI_INTERRUPT_TX_HW_MSG_FAIL | \
+					AR_MCI_INTERRUPT_TX_SW_MSG_FAIL)
 
 #define AR_MCI_INTERRUPT_RX_HW_MSG_MASK (AR_MCI_INTERRUPT_RX_MSG_SCHD_INFO   | \
 					 AR_MCI_INTERRUPT_RX_MSG_LNA_CONTROL | \
@@ -302,9 +302,9 @@
 					 AR_MCI_INTERRUPT_RX_MSG_CONT_RST)
 
 #define AR_MCI_INTERRUPT_RX_MSG_DEFAULT (AR_MCI_INTERRUPT_RX_MSG_GPM           | \
-                                         AR_MCI_INTERRUPT_RX_MSG_REMOTE_RESET  | \
-                                         AR_MCI_INTERRUPT_RX_MSG_SYS_WAKING    | \
-                                         AR_MCI_INTERRUPT_RX_MSG_SYS_SLEEPING  | \
-                                         AR_MCI_INTERRUPT_RX_MSG_REQ_WAKE)
+					 AR_MCI_INTERRUPT_RX_MSG_REMOTE_RESET  | \
+					 AR_MCI_INTERRUPT_RX_MSG_SYS_WAKING    | \
+					 AR_MCI_INTERRUPT_RX_MSG_SYS_SLEEPING  | \
+					 AR_MCI_INTERRUPT_RX_MSG_REQ_WAKE)
 
 #endif /* REG_MCI_H */
diff --git a/drivers/net/wireless/ath/ath9k/reg_wow.h b/drivers/net/wireless/ath/ath9k/reg_wow.h
index 4530540..58f7569 100644
--- a/drivers/net/wireless/ath/ath9k/reg_wow.h
+++ b/drivers/net/wireless/ath/ath9k/reg_wow.h
@@ -81,14 +81,14 @@
 #define AR_WOW_BEACON_FAIL              0x00200000
 
 #define AR_WOW_STATUS(x)                (x & (AR_WOW_PATTERN_FOUND_MASK | \
-                                              AR_WOW_MAGIC_PAT_FOUND    | \
-                                              AR_WOW_KEEP_ALIVE_FAIL    | \
-                                              AR_WOW_BEACON_FAIL))
+					      AR_WOW_MAGIC_PAT_FOUND    | \
+					      AR_WOW_KEEP_ALIVE_FAIL    | \
+					      AR_WOW_BEACON_FAIL))
 #define AR_WOW_CLEAR_EVENTS(x)          (x & ~(AR_WOW_PATTERN_EN(0xff) | \
-                                               AR_WOW_MAGIC_EN |	\
-                                               AR_WOW_MAC_INTR_EN |	\
-                                               AR_WOW_BEACON_FAIL |	\
-                                               AR_WOW_KEEP_ALIVE_FAIL))
+					       AR_WOW_MAGIC_EN |	\
+					       AR_WOW_MAC_INTR_EN |	\
+					       AR_WOW_BEACON_FAIL |	\
+					       AR_WOW_KEEP_ALIVE_FAIL))
 
 #define AR_WOW2_PATTERN_EN(x)           ((x & 0xff) << 0)
 #define AR_WOW2_PATTERN_FOUND_SHIFT     8
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index fe795fc..7efbdf0 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -393,8 +393,8 @@ static struct ath_buf* ath_clone_txbuf(struct ath_softc *sc, struct ath_buf *bf)
 }
 
 static void ath_tx_count_frames(struct ath_softc *sc, struct ath_buf *bf,
-			        struct ath_tx_status *ts, int txok,
-			        int *nframes, int *nbad)
+				struct ath_tx_status *ts, int txok,
+				int *nframes, int *nbad)
 {
 	struct ath_frame_info *fi;
 	u16 seq_st = 0;
@@ -2259,7 +2259,7 @@ static int ath_tx_prepare(struct ieee80211_hw *hw, struct sk_buff *skb,
 	ath_assign_seq(ath9k_hw_common(sc->sc_ah), skb);
 
 	if ((vif && vif->type != NL80211_IFTYPE_AP &&
-	            vif->type != NL80211_IFTYPE_AP_VLAN) ||
+		    vif->type != NL80211_IFTYPE_AP_VLAN) ||
 	    !ieee80211_is_data(hdr->frame_control))
 		info->flags |= IEEE80211_TX_CTL_CLEAR_PS_FILT;
 
@@ -2443,7 +2443,7 @@ void ath_tx_cabq(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 			break;
 
 		skb = ieee80211_get_buffered_bc(hw, vif);
-	} while(skb);
+	} while (skb);
 
 	if (skb)
 		ieee80211_free_txskb(hw, skb);
@@ -2494,7 +2494,7 @@ static void ath_tx_complete(struct ath_softc *sc, struct sk_buff *skb,
 
 	padpos = ieee80211_hdrlen(hdr->frame_control);
 	padsize = padpos & 3;
-	if (padsize && skb->len>padpos+padsize) {
+	if (padsize && skb->len > padpos+padsize) {
 		/*
 		 * Remove MAC header padding before giving the frame back to
 		 * mac80211.
@@ -2604,7 +2604,7 @@ static void ath_tx_rc_status(struct ath_softc *sc, struct ath_buf *bf,
 		 * This itself should also alleviate congestion on the bus.
 		 */
 		if (unlikely(ts->ts_flags & (ATH9K_TX_DATA_UNDERRUN |
-		                             ATH9K_TX_DELIM_UNDERRUN)) &&
+					     ATH9K_TX_DELIM_UNDERRUN)) &&
 		    ieee80211_is_data(hdr->frame_control) &&
 		    ah->tx_trig_level >= sc->sc_ah->config.max_txtrig_level)
 			tx_info->status.rates[tx_rateindex].count =
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
