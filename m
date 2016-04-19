From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v3 18/18] wcn36xx: Fill in capability list
Date: Mon, 18 Apr 2016 22:00:56 -0700
Message-ID: <1461042056-10607-19-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fill in the capability list with more values from the downstream driver.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Changes since v2:
- Added this patch to the series

 drivers/net/wireless/ath/wcn36xx/hal.h  | 39 ++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wcn36xx/main.c | 40 ++++++++++++++++++++++++++++++++-
 2 files changed, 78 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index ec64c47f918b..658bfb8baabe 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -4389,6 +4389,45 @@ enum place_holder_in_cap_bitmap {
 	RTT = 20,
 	RATECTRL = 21,
 	WOW = 22,
+	WLAN_ROAM_SCAN_OFFLOAD = 23,
+	SPECULATIVE_PS_POLL = 24,
+	SCAN_SCH = 25,
+	IBSS_HEARTBEAT_OFFLOAD = 26,
+	WLAN_SCAN_OFFLOAD = 27,
+	WLAN_PERIODIC_TX_PTRN = 28,
+	ADVANCE_TDLS = 29,
+	BATCH_SCAN = 30,
+	FW_IN_TX_PATH = 31,
+	EXTENDED_NSOFFLOAD_SLOT = 32,
+	CH_SWITCH_V1 = 33,
+	HT40_OBSS_SCAN = 34,
+	UPDATE_CHANNEL_LIST = 35,
+	WLAN_MCADDR_FLT = 36,
+	WLAN_CH144 = 37,
+	NAN = 38,
+	TDLS_SCAN_COEXISTENCE = 39,
+	LINK_LAYER_STATS_MEAS = 40,
+	MU_MIMO = 41,
+	EXTENDED_SCAN = 42,
+	DYNAMIC_WMM_PS = 43,
+	MAC_SPOOFED_SCAN = 44,
+	BMU_ERROR_GENERIC_RECOVERY = 45,
+	DISA = 46,
+	FW_STATS = 47,
+	WPS_PRBRSP_TMPL = 48,
+	BCN_IE_FLT_DELTA = 49,
+	TDLS_OFF_CHANNEL = 51,
+	RTT3 = 52,
+	MGMT_FRAME_LOGGING = 53,
+	ENHANCED_TXBD_COMPLETION = 54,
+	LOGGING_ENHANCEMENT = 55,
+	EXT_SCAN_ENHANCED = 56,
+	MEMORY_DUMP_SUPPORTED = 57,
+	PER_PKT_STATS_SUPPORTED = 58,
+	EXT_LL_STAT = 60,
+	WIFI_CONFIG = 61,
+	ANTENNA_DIVERSITY_SELECTION = 62,
+
 	MAX_FEATURE_SUPPORTED = 128,
 };
 
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 680217506b3d..fe81b2a7c8d9 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -201,7 +201,45 @@ static const char * const wcn36xx_caps_names[] = {
 	"BCN_FILTER",			/* 19 */
 	"RTT",				/* 20 */
 	"RATECTRL",			/* 21 */
-	"WOW"				/* 22 */
+	"WOW",				/* 22 */
+	"WLAN_ROAM_SCAN_OFFLOAD",	/* 23 */
+	"SPECULATIVE_PS_POLL",		/* 24 */
+	"SCAN_SCH",			/* 25 */
+	"IBSS_HEARTBEAT_OFFLOAD",	/* 26 */
+	"WLAN_SCAN_OFFLOAD",		/* 27 */
+	"WLAN_PERIODIC_TX_PTRN",	/* 28 */
+	"ADVANCE_TDLS",			/* 29 */
+	"BATCH_SCAN",			/* 30 */
+	"FW_IN_TX_PATH",		/* 31 */
+	"EXTENDED_NSOFFLOAD_SLOT",	/* 32 */
+	"CH_SWITCH_V1",			/* 33 */
+	"HT40_OBSS_SCAN",		/* 34 */
+	"UPDATE_CHANNEL_LIST",		/* 35 */
+	"WLAN_MCADDR_FLT",		/* 36 */
+	"WLAN_CH144",			/* 37 */
+	"NAN",				/* 38 */
+	"TDLS_SCAN_COEXISTENCE",	/* 39 */
+	"LINK_LAYER_STATS_MEAS",	/* 40 */
+	"MU_MIMO",			/* 41 */
+	"EXTENDED_SCAN",		/* 42 */
+	"DYNAMIC_WMM_PS",		/* 43 */
+	"MAC_SPOOFED_SCAN",		/* 44 */
+	"BMU_ERROR_GENERIC_RECOVERY",	/* 45 */
+	"DISA",				/* 46 */
+	"FW_STATS",			/* 47 */
+	"WPS_PRBRSP_TMPL",		/* 48 */
+	"BCN_IE_FLT_DELTA",		/* 49 */
+	"TDLS_OFF_CHANNEL",		/* 51 */
+	"RTT3",				/* 52 */
+	"MGMT_FRAME_LOGGING",		/* 53 */
+	"ENHANCED_TXBD_COMPLETION",	/* 54 */
+	"LOGGING_ENHANCEMENT",		/* 55 */
+	"EXT_SCAN_ENHANCED",		/* 56 */
+	"MEMORY_DUMP_SUPPORTED",	/* 57 */
+	"PER_PKT_STATS_SUPPORTED",	/* 58 */
+	"EXT_LL_STAT",			/* 60 */
+	"WIFI_CONFIG",			/* 61 */
+	"ANTENNA_DIVERSITY_SELECTION",	/* 62 */
 };
 
 static const char *wcn36xx_get_cap_name(enum place_holder_in_cap_bitmap x)
-- 
2.5.0
