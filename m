From: Priit Laes <plaes@plaes.org>
Subject: [PATCH v3 2/7] rtlwifi: Remove unused defines from driver-specific def.h
Date: Mon, 16 Feb 2015 14:59:55 +0200
Message-ID: <1424091600-13121-3-git-send-email-plaes@plaes.org>
References: <1424091600-13121-1-git-send-email-plaes@plaes.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Priit Laes <plaes@plaes.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424091600-13121-1-git-send-email-plaes@plaes.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HAL_RETRY_LIMIT_*
RESET_DELAY_8185
RT_IBSS_INT_MASKS
RT_AC_INT_MASKS
NUM_OF_*
BT_*,
MAX_{LINES,BYTES}_*,
*_THREE_WIRE
*_QUEUE related

Signed-off-by: Priit Laes <plaes@plaes.org>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h | 41 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h | 41 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8192de/def.h | 38 --------------------------
 drivers/net/wireless/rtlwifi/rtl8192se/def.h |  1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h | 41 ----------------------------
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h | 41 ----------------------------
 6 files changed, 203 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
index d9ea9d0..0532b98 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/def.h
@@ -26,53 +26,12 @@
 #ifndef __RTL92C_DEF_H__
 #define __RTL92C_DEF_H__
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
-#define RESET_DELAY_8185				20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
-#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
-
-#define NUM_OF_FIRMWARE_QUEUE				10
-#define NUM_OF_PAGES_IN_FW				0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM			0x00
-
-#define MAX_LINES_HWCONFIG_TXT				1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT			256
-
-#define SW_THREE_WIRE					0
-#define HW_THREE_WIRE					2
-
-#define BT_DEMO_BOARD					0
-#define BT_QA_BOARD					1
-#define BT_FPGA						2
-
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE			0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
 #define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define MAX_H2C_QUEUE_NUM				10
-
 #define RX_MPDU_QUEUE					0
 #define RX_CMD_QUEUE					1
-#define RX_MAX_QUEUE					2
-#define AC2QUEUEID(_AC)					(_AC)
 
 #define	C2H_RX_CMD_HDR_LEN				8
 #define	GET_C2H_CMD_CMD_LEN(__prxhdr)			\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
index 9b660df..690a7a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -30,59 +30,18 @@
 #ifndef __RTL92C_DEF_H__
 #define __RTL92C_DEF_H__
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
 #define	PHY_RSSI_SLID_WIN_MAX				100
 #define	PHY_LINKQUALITY_SLID_WIN_MAX			20
 #define	PHY_BEACON_RSSI_SLID_WIN_MAX			10
 
-#define RESET_DELAY_8185				20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
-#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
-
-#define NUM_OF_FIRMWARE_QUEUE				10
-#define NUM_OF_PAGES_IN_FW				0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM			0x00
-
-#define MAX_LINES_HWCONFIG_TXT				1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT			256
-
-#define SW_THREE_WIRE					0
-#define HW_THREE_WIRE					2
-
-#define BT_DEMO_BOARD					0
-#define BT_QA_BOARD					1
-#define BT_FPGA						2
-
 #define RX_SMOOTH_FACTOR				20
 
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE			0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
 #define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define MAX_H2C_QUEUE_NUM				10
-
 #define RX_MPDU_QUEUE					0
 #define RX_CMD_QUEUE					1
-#define RX_MAX_QUEUE					2
-#define AC2QUEUEID(_AC)					(_AC)
 
 #define	C2H_RX_CMD_HDR_LEN				8
 #define	GET_C2H_CMD_CMD_LEN(__prxhdr)		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/def.h b/drivers/net/wireless/rtlwifi/rtl8192de/def.h
index 939c905..4ca1fe1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/def.h
@@ -38,58 +38,20 @@
 #define RF6052_MAX_REG					0x3F
 #define RF6052_MAX_PATH					2
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
 #define	PHY_RSSI_SLID_WIN_MAX				100
 #define	PHY_LINKQUALITY_SLID_WIN_MAX			20
 #define	PHY_BEACON_RSSI_SLID_WIN_MAX			10
 
-#define RESET_DELAY_8185				20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
 #define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
 
-#define NUM_OF_FIRMWARE_QUEUE				10
-#define NUM_OF_PAGES_IN_FW				0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH			0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM			0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM			0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM			0x00
-
-#define MAX_LINES_HWCONFIG_TXT				1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT			256
-
-#define SW_THREE_WIRE					0
-#define HW_THREE_WIRE					2
-
-#define BT_DEMO_BOARD					0
-#define BT_QA_BOARD					1
-#define BT_FPGA						2
-
 #define RX_SMOOTH_FACTOR				20
 
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE			0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
 #define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define MAX_H2C_QUEUE_NUM				10
-
 #define RX_MPDU_QUEUE					0
 #define RX_CMD_QUEUE					1
-#define RX_MAX_QUEUE					2
 
 #define	C2H_RX_CMD_HDR_LEN				8
 #define	GET_C2H_CMD_CMD_LEN(__prxhdr)			\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/def.h b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
index ef87c09..41466f9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
@@ -31,7 +31,6 @@
 
 #define RX_MPDU_QUEUE				0
 #define RX_CMD_QUEUE				1
-#define RX_MAX_QUEUE				2
 
 #define SHORT_SLOT_TIME				9
 #define NON_SHORT_SLOT_TIME			20
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/def.h b/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
index 94bdd4b..bcdf227 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
@@ -26,53 +26,12 @@
 #ifndef __RTL8723E_DEF_H__
 #define __RTL8723E_DEF_H__
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
-#define RESET_DELAY_8185					20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
-#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
-
-#define NUM_OF_FIRMWARE_QUEUE				10
-#define NUM_OF_PAGES_IN_FW					0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA		0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM		0x00
-
-#define MAX_LINES_HWCONFIG_TXT				1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT			256
-
-#define SW_THREE_WIRE						0
-#define HW_THREE_WIRE						2
-
-#define BT_DEMO_BOARD						0
-#define BT_QA_BOARD							1
-#define BT_FPGA								2
-
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE		0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
 #define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define MAX_H2C_QUEUE_NUM					10
-
 #define RX_MPDU_QUEUE						0
 #define RX_CMD_QUEUE						1
-#define RX_MAX_QUEUE						2
-#define AC2QUEUEID(_AC)						(_AC)
 
 #define	C2H_RX_CMD_HDR_LEN					8
 #define	GET_C2H_CMD_CMD_LEN(__prxhdr)		\
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/def.h b/drivers/net/wireless/rtlwifi/rtl8821ae/def.h
index ee7c208..dfbdf53 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/def.h
@@ -118,55 +118,14 @@
 #define	WIFI_NAV_UPPER_US				30000
 #define HAL_92C_NAV_UPPER_UNIT			128
 
-#define HAL_RETRY_LIMIT_INFRA				48
-#define HAL_RETRY_LIMIT_AP_ADHOC			7
-
-#define RESET_DELAY_8185					20
-
-#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
-#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
-
-#define NUM_OF_FIRMWARE_QUEUE				10
-#define NUM_OF_PAGES_IN_FW					0x100
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
-#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA		0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
-#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH		0x02
-#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
-
-#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM		0x048
-#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM		0x026
-#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM		0x00
-
 #define MAX_RX_DMA_BUFFER_SIZE				0x3E80
 
-#define MAX_LINES_HWCONFIG_TXT				1000
-#define MAX_BYTES_LINE_HWCONFIG_TXT			256
-
-#define SW_THREE_WIRE						0
-#define HW_THREE_WIRE						2
-
-#define BT_DEMO_BOARD						0
-#define BT_QA_BOARD							1
-#define BT_FPGA								2
-
 #define HAL_PRIME_CHNL_OFFSET_DONT_CARE		0
 #define HAL_PRIME_CHNL_OFFSET_LOWER			1
 #define HAL_PRIME_CHNL_OFFSET_UPPER			2
 
-#define MAX_H2C_QUEUE_NUM					10
-
 #define RX_MPDU_QUEUE						0
 #define RX_CMD_QUEUE						1
-#define RX_MAX_QUEUE						2
-#define AC2QUEUEID(_AC)						(_AC)
 
 #define MAX_RX_DMA_BUFFER_SIZE_8812	0x3E80
 
-- 
2.3.0
