From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 10/11 V2 NEXT] rtlwifi: rtl8821ae: Move driver from staging to regular tree
Date: Sat, 27 Sep 2014 11:52:06 -0500
Message-ID: <1411836726-12699-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1411836726-12699-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, troy_tan-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411836726-12699-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This driver was entered into staging a few cycles ago because there was
not time to integrate the Realtek version into the support routines in
the kernel. Now that there is an effort to converg the code base from L=
inux
and the Realtek repo, it is time to move this driver. In addition, all =
the
updates included in the 06/28/2014 version of the Realtek drivers are
included here.

With this change, it will be necessary to delete the staging driver. Th=
at
will be handled in a separate patch. As it impacts the staging tree, su=
ch a
patch is sent to a different destination.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

This patch replaces patch 10/11 of the previous series. The duplicate
global problem reported by the zero-day kbuild test robot is fixed. Pat=
ch
11/11 in that series should be dropped.

Larry
---
 drivers/net/wireless/rtlwifi/Kconfig            |   13 +-
 drivers/net/wireless/rtlwifi/Makefile           |    1 +
 drivers/net/wireless/rtlwifi/debug.h            |    1 +
 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile |   19 +
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h    |  450 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c     | 3019 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h     |  356 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c     | 1889 +++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h     |  351 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c     | 4215 +++++++++++++++=
+++++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h     |   70 +
 drivers/net/wireless/rtlwifi/rtl8821ae/led.c    |  237 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/led.h    |   37 +
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c    | 4855 +++++++++++++++=
++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h    |  259 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c |  182 +
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h |  738 ++++
 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h    | 2464 ++++++++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c     |  465 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h     |   43 +
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c     |  484 +++
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h     |   34 +
 drivers/net/wireless/rtlwifi/rtl8821ae/table.c  | 4572 +++++++++++++++=
++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/table.h  |   60 +
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c    | 1243 ++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h    |  620 +++
 drivers/net/wireless/rtlwifi/wifi.h             |   93 +-
 27 files changed, 26764 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8821ae/trx.h

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireles=
s/rtlwifi/Kconfig
index bf3cf12..e88bc73 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -5,7 +5,7 @@ menuconfig RTL_CARDS
 	---help---
 	  This option will enable support for the Realtek mac80211-based
 	  wireless drivers. Drivers rtl8192ce, rtl8192cu, rtl8192se, rtl8192d=
e,
-	  rtl8723ae, rtl8723be, and rtl8188ae share some common code.
+	  rtl8723ae, rtl8723be, rtl8188ee, and rtl8821ae share some common co=
de.
=20
 if RTL_CARDS
=20
@@ -80,6 +80,17 @@ config RTL8188EE
=20
 	If you choose to build it as a module, it will be called rtl8188ee
=20
+config RTL8821AE
+	tristate "Realtek RTL8821AE/RTL8812AE Wireless Network Adapter"
+	depends on PCI
+	select RTLWIFI
+	select RTLWIFI_PCI
+	---help---
+	This is the driver for Realtek RTL8i821AE/RTL8812AE 802.11av PCIe
+	wireless network adapters.
+
+	If you choose to build it as a module, it will be called rtl8821ae
+
 config RTL8192CU
 	tristate "Realtek RTL8192CU/RTL8188CU USB Wireless Network Adapter"
 	depends on USB
diff --git a/drivers/net/wireless/rtlwifi/Makefile b/drivers/net/wirele=
ss/rtlwifi/Makefile
index bba36a0..9bfa9d5 100644
--- a/drivers/net/wireless/rtlwifi/Makefile
+++ b/drivers/net/wireless/rtlwifi/Makefile
@@ -28,5 +28,6 @@ obj-$(CONFIG_RTL8723BE)		+=3D rtl8723be/
 obj-$(CONFIG_RTL8188EE)		+=3D rtl8188ee/
 obj-$(CONFIG_RTLBTCOEXIST)	+=3D btcoexist/
 obj-$(CONFIG_RTL8723_COMMON)	+=3D rtl8723com/
+obj-$(CONFIG_RTL8821AE)		+=3D rtl8821ae/
=20
 ccflags-y +=3D -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireles=
s/rtlwifi/debug.h
index 534c224..fc794b3 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -104,6 +104,7 @@
 #define COMP_USB			BIT(29)
 #define COMP_EASY_CONCURRENT	COMP_USB /* reuse of this bit is OK */
 #define COMP_BT_COEXIST			BIT(30)
+#define COMP_IQK			BIT(31)
=20
 /*--------------------------------------------------------------
 		Define the rt_print components
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/Makefile b/drivers/=
net/wireless/rtlwifi/rtl8821ae/Makefile
new file mode 100644
index 0000000..87ad604
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/Makefile
@@ -0,0 +1,19 @@
+obj-m :=3D rtl8821ae.o
+
+
+rtl8821ae-objs :=3D		\
+		dm.o		\
+		fw.o		\
+		hw.o		\
+		led.o		\
+		phy.o		\
+		pwrseq.o	\
+		rf.o		\
+		sw.o		\
+		table.o		\
+		trx.o		\
+
+
+obj-$(CONFIG_RTL8821AE) +=3D rtl8821ae.o
+
+ccflags-y +=3D -D__CHECK_ENDIAN__
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/def.h b/drivers/net=
/wireless/rtlwifi/rtl8821ae/def.h
new file mode 100644
index 0000000..a730985
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/def.h
@@ -0,0 +1,450 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_DEF_H__
+#define __RTL8821AE_DEF_H__
+
+/*--------------------------Define -----------------------------------=
--------*/
+#define	USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN	1
+
+/* BIT 7 HT Rate*/
+/*TxHT =3D 0*/
+#define	MGN_1M				0x02
+#define	MGN_2M				0x04
+#define	MGN_5_5M			0x0b
+#define	MGN_11M				0x16
+
+#define	MGN_6M				0x0c
+#define	MGN_9M				0x12
+#define	MGN_12M				0x18
+#define	MGN_18M				0x24
+#define	MGN_24M				0x30
+#define	MGN_36M				0x48
+#define	MGN_48M				0x60
+#define	MGN_54M				0x6c
+
+/* TxHT =3D 1 */
+#define	MGN_MCS0			0x80
+#define	MGN_MCS1			0x81
+#define	MGN_MCS2			0x82
+#define	MGN_MCS3			0x83
+#define	MGN_MCS4			0x84
+#define	MGN_MCS5			0x85
+#define	MGN_MCS6			0x86
+#define	MGN_MCS7			0x87
+#define	MGN_MCS8			0x88
+#define	MGN_MCS9			0x89
+#define	MGN_MCS10			0x8a
+#define	MGN_MCS11			0x8b
+#define	MGN_MCS12			0x8c
+#define	MGN_MCS13			0x8d
+#define	MGN_MCS14			0x8e
+#define	MGN_MCS15			0x8f
+/* VHT rate */
+#define	MGN_VHT1SS_MCS0		0x90
+#define	MGN_VHT1SS_MCS1		0x91
+#define	MGN_VHT1SS_MCS2		0x92
+#define	MGN_VHT1SS_MCS3		0x93
+#define	MGN_VHT1SS_MCS4		0x94
+#define	MGN_VHT1SS_MCS5		0x95
+#define	MGN_VHT1SS_MCS6		0x96
+#define	MGN_VHT1SS_MCS7		0x97
+#define	MGN_VHT1SS_MCS8		0x98
+#define	MGN_VHT1SS_MCS9		0x99
+#define	MGN_VHT2SS_MCS0		0x9a
+#define	MGN_VHT2SS_MCS1		0x9b
+#define	MGN_VHT2SS_MCS2		0x9c
+#define	MGN_VHT2SS_MCS3		0x9d
+#define	MGN_VHT2SS_MCS4		0x9e
+#define	MGN_VHT2SS_MCS5		0x9f
+#define	MGN_VHT2SS_MCS6		0xa0
+#define	MGN_VHT2SS_MCS7		0xa1
+#define	MGN_VHT2SS_MCS8		0xa2
+#define	MGN_VHT2SS_MCS9		0xa3
+
+#define	MGN_VHT3SS_MCS0		0xa4
+#define	MGN_VHT3SS_MCS1		0xa5
+#define	MGN_VHT3SS_MCS2		0xa6
+#define	MGN_VHT3SS_MCS3		0xa7
+#define	MGN_VHT3SS_MCS4		0xa8
+#define	MGN_VHT3SS_MCS5		0xa9
+#define	MGN_VHT3SS_MCS6		0xaa
+#define	MGN_VHT3SS_MCS7		0xab
+#define	MGN_VHT3SS_MCS8		0xac
+#define	MGN_VHT3SS_MCS9		0xad
+
+#define	MGN_MCS0_SG			0xc0
+#define	MGN_MCS1_SG			0xc1
+#define	MGN_MCS2_SG			0xc2
+#define	MGN_MCS3_SG			0xc3
+#define	MGN_MCS4_SG			0xc4
+#define	MGN_MCS5_SG			0xc5
+#define	MGN_MCS6_SG			0xc6
+#define	MGN_MCS7_SG			0xc7
+#define	MGN_MCS8_SG			0xc8
+#define	MGN_MCS9_SG			0xc9
+#define	MGN_MCS10_SG		0xca
+#define	MGN_MCS11_SG		0xcb
+#define	MGN_MCS12_SG		0xcc
+#define	MGN_MCS13_SG		0xcd
+#define	MGN_MCS14_SG		0xce
+#define	MGN_MCS15_SG		0xcf
+
+#define	MGN_UNKNOWN			0xff
+
+/* 30 ms */
+#define	WIFI_NAV_UPPER_US				30000
+#define HAL_92C_NAV_UPPER_UNIT			128
+
+#define HAL_RETRY_LIMIT_INFRA				48
+#define HAL_RETRY_LIMIT_AP_ADHOC			7
+
+#define RESET_DELAY_8185					20
+
+#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
+#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
+
+#define NUM_OF_FIRMWARE_QUEUE				10
+#define NUM_OF_PAGES_IN_FW					0x100
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA		0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT		0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH		0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
+
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM		0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM		0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM		0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM		0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM		0x00
+
+#define MAX_RX_DMA_BUFFER_SIZE				0x3E80
+
+#define MAX_LINES_HWCONFIG_TXT				1000
+#define MAX_BYTES_LINE_HWCONFIG_TXT			256
+
+#define SW_THREE_WIRE						0
+#define HW_THREE_WIRE						2
+
+#define BT_DEMO_BOARD						0
+#define BT_QA_BOARD							1
+#define BT_FPGA								2
+
+#define HAL_PRIME_CHNL_OFFSET_DONT_CARE		0
+#define HAL_PRIME_CHNL_OFFSET_LOWER			1
+#define HAL_PRIME_CHNL_OFFSET_UPPER			2
+
+#define MAX_H2C_QUEUE_NUM					10
+
+#define RX_MPDU_QUEUE						0
+#define RX_CMD_QUEUE						1
+#define RX_MAX_QUEUE						2
+#define AC2QUEUEID(_AC)						(_AC)
+
+#define MAX_RX_DMA_BUFFER_SIZE_8812	0x3E80
+
+#define	C2H_RX_CMD_HDR_LEN					8
+#define	GET_C2H_CMD_CMD_LEN(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 0, 16)
+#define	GET_C2H_CMD_ELEMENT_ID(__prxhdr)	\
+	LE_BITS_TO_4BYTE((__prxhdr), 16, 8)
+#define	GET_C2H_CMD_CMD_SEQ(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 24, 7)
+#define	GET_C2H_CMD_CONTINUE(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 31, 1)
+#define	GET_C2H_CMD_CONTENT(__prxhdr)		\
+	((u8 *)(__prxhdr) + C2H_RX_CMD_HDR_LEN)
+
+#define	GET_C2H_CMD_FEEDBACK_ELEMENT_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 0, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_LEN(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 8, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_CMD_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 16, 16)
+#define	GET_C2H_CMD_FEEDBACK_CCX_MAC_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 0, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_VALID(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 7, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_RETRY_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 8, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_TOK(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 15, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_QSEL(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
+#define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)		\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
+
+#define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
+
+#define CHIP_8812				BIT(2)
+#define CHIP_8821				(BIT(0)|BIT(2))
+
+#define CHIP_8821A				(BIT(0)|BIT(2))
+#define NORMAL_CHIP				BIT(3)
+#define RF_TYPE_1T1R				(~(BIT(4)|BIT(5)|BIT(6)))
+#define RF_TYPE_1T2R				BIT(4)
+#define RF_TYPE_2T2R				BIT(5)
+#define CHIP_VENDOR_UMC				BIT(7)
+#define B_CUT_VERSION				BIT(12)
+#define C_CUT_VERSION				BIT(13)
+#define D_CUT_VERSION				((BIT(12)|BIT(13)))
+#define E_CUT_VERSION				BIT(14)
+#define	RF_RL_ID			(BIT(31)|BIT(30)|BIT(29)|BIT(28))
+
+enum version_8821ae {
+	VERSION_TEST_CHIP_1T1R_8812 =3D 0x0004,
+	VERSION_TEST_CHIP_2T2R_8812 =3D 0x0024,
+	VERSION_NORMAL_TSMC_CHIP_1T1R_8812 =3D 0x100c,
+	VERSION_NORMAL_TSMC_CHIP_2T2R_8812 =3D 0x102c,
+	VERSION_NORMAL_TSMC_CHIP_1T1R_8812_C_CUT =3D 0x200c,
+	VERSION_NORMAL_TSMC_CHIP_2T2R_8812_C_CUT =3D 0x202c,
+	VERSION_TEST_CHIP_8821 =3D 0x0005,
+	VERSION_NORMAL_TSMC_CHIP_8821 =3D 0x000d,
+	VERSION_NORMAL_TSMC_CHIP_8821_B_CUT =3D 0x100d,
+	VERSION_UNKNOWN =3D 0xFF,
+};
+
+enum vht_data_sc {
+	VHT_DATA_SC_DONOT_CARE =3D 0,
+	VHT_DATA_SC_20_UPPER_OF_80MHZ =3D 1,
+	VHT_DATA_SC_20_LOWER_OF_80MHZ =3D 2,
+	VHT_DATA_SC_20_UPPERST_OF_80MHZ =3D 3,
+	VHT_DATA_SC_20_LOWEST_OF_80MHZ =3D 4,
+	VHT_DATA_SC_20_RECV1 =3D 5,
+	VHT_DATA_SC_20_RECV2 =3D 6,
+	VHT_DATA_SC_20_RECV3 =3D 7,
+	VHT_DATA_SC_20_RECV4 =3D 8,
+	VHT_DATA_SC_40_UPPER_OF_80MHZ =3D 9,
+	VHT_DATA_SC_40_LOWER_OF_80MHZ =3D 10,
+};
+
+/* MASK */
+#define IC_TYPE_MASK			(BIT(0)|BIT(1)|BIT(2))
+#define CHIP_TYPE_MASK			BIT(3)
+#define RF_TYPE_MASK			(BIT(4)|BIT(5)|BIT(6))
+#define MANUFACTUER_MASK		BIT(7)
+#define ROM_VERSION_MASK		(BIT(11)|BIT(10)|BIT(9)|BIT(8))
+#define CUT_VERSION_MASK		(BIT(15)|BIT(14)|BIT(13)|BIT(12))
+
+/* Get element */
+#define GET_CVID_IC_TYPE(version)	((version) & IC_TYPE_MASK)
+#define GET_CVID_CHIP_TYPE(version)	((version) & CHIP_TYPE_MASK)
+#define GET_CVID_RF_TYPE(version)	((version) & RF_TYPE_MASK)
+#define GET_CVID_MANUFACTUER(version)	((version) & MANUFACTUER_MASK)
+#define GET_CVID_ROM_VERSION(version)	((version) & ROM_VERSION_MASK)
+#define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
+
+#define IS_1T1R(version)	((GET_CVID_RF_TYPE(version)) ? false : true)
+#define IS_1T2R(version)	((GET_CVID_RF_TYPE(version) =3D=3D RF_TYPE_1T=
2R)\
+							? true : false)
+#define IS_2T2R(version)	((GET_CVID_RF_TYPE(version) =3D=3D RF_TYPE_2T=
2R)\
+							? true : false)
+
+#define IS_8812_SERIES(version)	((GET_CVID_IC_TYPE(version) =3D=3D CHI=
P_8812) ? \
+								true : false)
+#define IS_8821_SERIES(version)	((GET_CVID_IC_TYPE(version) =3D=3D CHI=
P_8821) ? \
+								true : false)
+
+#define IS_VENDOR_8812A_TEST_CHIP(version)	((IS_8812_SERIES(version)) =
? \
+					((IS_NORMAL_CHIP(version)) ? \
+						false : true) : false)
+#define IS_VENDOR_8812A_MP_CHIP(version)	((IS_8812_SERIES(version)) ? =
\
+					((IS_NORMAL_CHIP(version)) ? \
+						true : false) : false)
+#define IS_VENDOR_8812A_C_CUT(version)		((IS_8812_SERIES(version)) ? \
+					((GET_CVID_CUT_VERSION(version) =3D=3D \
+					C_CUT_VERSION) ? \
+					true : false) : false)
+
+#define IS_VENDOR_8821A_TEST_CHIP(version)	((IS_8821_SERIES(version)) =
? \
+					((IS_NORMAL_CHIP(version)) ? \
+					false : true) : false)
+#define IS_VENDOR_8821A_MP_CHIP(version)	((IS_8821_SERIES(version)) ? =
\
+					((IS_NORMAL_CHIP(version)) ? \
+						true : false) : false)
+#define IS_VENDOR_8821A_B_CUT(version)		((IS_8821_SERIES(version)) ? \
+					((GET_CVID_CUT_VERSION(version) =3D=3D \
+					B_CUT_VERSION) ? \
+					true : false) : false)
+enum board_type {
+	ODM_BOARD_DEFAULT =3D 0,	  /* The DEFAULT case. */
+	ODM_BOARD_MINICARD =3D BIT(0), /* 0 =3D non-mini card, 1 =3D mini car=
d. */
+	ODM_BOARD_SLIM =3D BIT(1), /* 0 =3D non-slim card, 1 =3D slim card */
+	ODM_BOARD_BT =3D BIT(2), /* 0 =3D without BT card, 1 =3D with BT */
+	ODM_BOARD_EXT_PA =3D BIT(3), /* 1 =3D existing 2G ext-PA */
+	ODM_BOARD_EXT_LNA =3D BIT(4), /* 1 =3D existing 2G ext-LNA */
+	ODM_BOARD_EXT_TRSW =3D BIT(5), /* 1 =3D existing ext-TRSW */
+	ODM_BOARD_EXT_PA_5G =3D BIT(6), /* 1 =3D existing 5G ext-PA */
+	ODM_BOARD_EXT_LNA_5G =3D BIT(7), /* 1 =3D existing 5G ext-LNA */
+};
+
+enum rf_optype {
+	RF_OP_BY_SW_3WIRE =3D 0,
+	RF_OP_BY_FW,
+	RF_OP_MAX
+};
+
+enum rf_power_state {
+	RF_ON,
+	RF_OFF,
+	RF_SLEEP,
+	RF_SHUT_DOWN,
+};
+
+enum power_save_mode {
+	POWER_SAVE_MODE_ACTIVE,
+	POWER_SAVE_MODE_SAVE,
+};
+
+enum power_polocy_config {
+	POWERCFG_MAX_POWER_SAVINGS,
+	POWERCFG_GLOBAL_POWER_SAVINGS,
+	POWERCFG_LOCAL_POWER_SAVINGS,
+	POWERCFG_LENOVO,
+};
+
+enum interface_select_pci {
+	INTF_SEL1_MINICARD =3D 0,
+	INTF_SEL0_PCIE =3D 1,
+	INTF_SEL2_RSV =3D 2,
+	INTF_SEL3_RSV =3D 3,
+};
+
+enum hal_fw_c2h_cmd_id {
+	HAL_FW_C2H_CMD_READ_MACREG =3D 0,
+	HAL_FW_C2H_CMD_READ_BBREG =3D 1,
+	HAL_FW_C2H_CMD_READ_RFREG =3D 2,
+	HAL_FW_C2H_CMD_READ_EEPROM =3D 3,
+	HAL_FW_C2H_CMD_READ_EFUSE =3D 4,
+	HAL_FW_C2H_CMD_READ_CAM =3D 5,
+	HAL_FW_C2H_CMD_GET_BASICRATE =3D 6,
+	HAL_FW_C2H_CMD_GET_DATARATE =3D 7,
+	HAL_FW_C2H_CMD_SURVEY =3D 8,
+	HAL_FW_C2H_CMD_SURVEYDONE =3D 9,
+	HAL_FW_C2H_CMD_JOINBSS =3D 10,
+	HAL_FW_C2H_CMD_ADDSTA =3D 11,
+	HAL_FW_C2H_CMD_DELSTA =3D 12,
+	HAL_FW_C2H_CMD_ATIMDONE =3D 13,
+	HAL_FW_C2H_CMD_TX_REPORT =3D 14,
+	HAL_FW_C2H_CMD_CCX_REPORT =3D 15,
+	HAL_FW_C2H_CMD_DTM_REPORT =3D 16,
+	HAL_FW_C2H_CMD_TX_RATE_STATISTICS =3D 17,
+	HAL_FW_C2H_CMD_C2HLBK =3D 18,
+	HAL_FW_C2H_CMD_C2HDBG =3D 19,
+	HAL_FW_C2H_CMD_C2HFEEDBACK =3D 20,
+	HAL_FW_C2H_CMD_MAX
+};
+
+enum rtl_desc_qsel {
+	QSLT_BK =3D 0x2,
+	QSLT_BE =3D 0x0,
+	QSLT_VI =3D 0x5,
+	QSLT_VO =3D 0x7,
+	QSLT_BEACON =3D 0x10,
+	QSLT_HIGH =3D 0x11,
+	QSLT_MGNT =3D 0x12,
+	QSLT_CMD =3D 0x13,
+};
+
+enum rtl_desc8821ae_rate {
+	DESC_RATE1M =3D 0x00,
+	DESC_RATE2M =3D 0x01,
+	DESC_RATE5_5M =3D 0x02,
+	DESC_RATE11M =3D 0x03,
+
+	DESC_RATE6M =3D 0x04,
+	DESC_RATE9M =3D 0x05,
+	DESC_RATE12M =3D 0x06,
+	DESC_RATE18M =3D 0x07,
+	DESC_RATE24M =3D 0x08,
+	DESC_RATE36M =3D 0x09,
+	DESC_RATE48M =3D 0x0a,
+	DESC_RATE54M =3D 0x0b,
+
+	DESC_RATEMCS0 =3D 0x0c,
+	DESC_RATEMCS1 =3D 0x0d,
+	DESC_RATEMCS2 =3D 0x0e,
+	DESC_RATEMCS3 =3D 0x0f,
+	DESC_RATEMCS4 =3D 0x10,
+	DESC_RATEMCS5 =3D 0x11,
+	DESC_RATEMCS6 =3D 0x12,
+	DESC_RATEMCS7 =3D 0x13,
+	DESC_RATEMCS8 =3D 0x14,
+	DESC_RATEMCS9 =3D 0x15,
+	DESC_RATEMCS10 =3D 0x16,
+	DESC_RATEMCS11 =3D 0x17,
+	DESC_RATEMCS12 =3D 0x18,
+	DESC_RATEMCS13 =3D 0x19,
+	DESC_RATEMCS14 =3D 0x1a,
+	DESC_RATEMCS15 =3D 0x1b,
+
+	DESC_RATEVHT1SS_MCS0 =3D 0x2c,
+	DESC_RATEVHT1SS_MCS1 =3D 0x2d,
+	DESC_RATEVHT1SS_MCS2 =3D 0x2e,
+	DESC_RATEVHT1SS_MCS3 =3D 0x2f,
+	DESC_RATEVHT1SS_MCS4 =3D 0x30,
+	DESC_RATEVHT1SS_MCS5 =3D 0x31,
+	DESC_RATEVHT1SS_MCS6 =3D 0x32,
+	DESC_RATEVHT1SS_MCS7 =3D 0x33,
+	DESC_RATEVHT1SS_MCS8 =3D 0x34,
+	DESC_RATEVHT1SS_MCS9 =3D 0x35,
+	DESC_RATEVHT2SS_MCS0 =3D 0x36,
+	DESC_RATEVHT2SS_MCS1 =3D 0x37,
+	DESC_RATEVHT2SS_MCS2 =3D 0x38,
+	DESC_RATEVHT2SS_MCS3 =3D 0x39,
+	DESC_RATEVHT2SS_MCS4 =3D 0x3a,
+	DESC_RATEVHT2SS_MCS5 =3D 0x3b,
+	DESC_RATEVHT2SS_MCS6 =3D 0x3c,
+	DESC_RATEVHT2SS_MCS7 =3D 0x3d,
+	DESC_RATEVHT2SS_MCS8 =3D 0x3e,
+	DESC_RATEVHT2SS_MCS9 =3D 0x3f,
+};
+
+enum rx_packet_type {
+	NORMAL_RX,
+	TX_REPORT1,
+	TX_REPORT2,
+	HIS_REPORT,
+	C2H_PACKET,
+};
+
+struct phy_sts_cck_8821ae_t {
+	u8 adc_pwdb_X[4];
+	u8 sq_rpt;
+	u8 cck_agc_rpt;
+};
+
+struct h2c_cmd_8821ae {
+	u8 element_id;
+	u32 cmd_len;
+	u8 *p_cmdbuffer;
+};
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/=
wireless/rtlwifi/rtl8821ae/dm.c
new file mode 100644
index 0000000..9be1061
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -0,0 +1,3019 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../base.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "dm.h"
+#include "fw.h"
+#include "trx.h"
+#include "../btcoexist/rtl_btc.h"
+
+static const u32 txscaling_tbl[TXSCALE_TABLE_SIZE] =3D {
+	0x081, /* 0, -12.0dB */
+	0x088, /* 1, -11.5dB */
+	0x090, /* 2, -11.0dB */
+	0x099, /* 3, -10.5dB */
+	0x0A2, /* 4, -10.0dB */
+	0x0AC, /* 5, -9.5dB */
+	0x0B6, /* 6, -9.0dB */
+	0x0C0, /* 7, -8.5dB */
+	0x0CC, /* 8, -8.0dB */
+	0x0D8, /* 9, -7.5dB */
+	0x0E5, /* 10, -7.0dB */
+	0x0F2, /* 11, -6.5dB */
+	0x101, /* 12, -6.0dB */
+	0x110, /* 13, -5.5dB */
+	0x120, /* 14, -5.0dB */
+	0x131, /* 15, -4.5dB */
+	0x143, /* 16, -4.0dB */
+	0x156, /* 17, -3.5dB */
+	0x16A, /* 18, -3.0dB */
+	0x180, /* 19, -2.5dB */
+	0x197, /* 20, -2.0dB */
+	0x1AF, /* 21, -1.5dB */
+	0x1C8, /* 22, -1.0dB */
+	0x1E3, /* 23, -0.5dB */
+	0x200, /* 24, +0  dB */
+	0x21E, /* 25, +0.5dB */
+	0x23E, /* 26, +1.0dB */
+	0x261, /* 27, +1.5dB */
+	0x285, /* 28, +2.0dB */
+	0x2AB, /* 29, +2.5dB */
+	0x2D3, /* 30, +3.0dB */
+	0x2FE, /* 31, +3.5dB */
+	0x32B, /* 32, +4.0dB */
+	0x35C, /* 33, +4.5dB */
+	0x38E, /* 34, +5.0dB */
+	0x3C4, /* 35, +5.5dB */
+	0x3FE  /* 36, +6.0dB */
+};
+
+static const u32 rtl8821ae_txscaling_table[TXSCALE_TABLE_SIZE] =3D {
+	0x081, /* 0, -12.0dB */
+	0x088, /* 1, -11.5dB */
+	0x090, /* 2, -11.0dB */
+	0x099, /* 3, -10.5dB */
+	0x0A2, /* 4, -10.0dB */
+	0x0AC, /* 5, -9.5dB */
+	0x0B6, /* 6, -9.0dB */
+	0x0C0, /* 7, -8.5dB */
+	0x0CC, /* 8, -8.0dB */
+	0x0D8, /* 9, -7.5dB */
+	0x0E5, /* 10, -7.0dB */
+	0x0F2, /* 11, -6.5dB */
+	0x101, /* 12, -6.0dB */
+	0x110, /* 13, -5.5dB */
+	0x120, /* 14, -5.0dB */
+	0x131, /* 15, -4.5dB */
+	0x143, /* 16, -4.0dB */
+	0x156, /* 17, -3.5dB */
+	0x16A, /* 18, -3.0dB */
+	0x180, /* 19, -2.5dB */
+	0x197, /* 20, -2.0dB */
+	0x1AF, /* 21, -1.5dB */
+	0x1C8, /* 22, -1.0dB */
+	0x1E3, /* 23, -0.5dB */
+	0x200, /* 24, +0  dB */
+	0x21E, /* 25, +0.5dB */
+	0x23E, /* 26, +1.0dB */
+	0x261, /* 27, +1.5dB */
+	0x285, /* 28, +2.0dB */
+	0x2AB, /* 29, +2.5dB */
+	0x2D3, /* 30, +3.0dB */
+	0x2FE, /* 31, +3.5dB */
+	0x32B, /* 32, +4.0dB */
+	0x35C, /* 33, +4.5dB */
+	0x38E, /* 34, +5.0dB */
+	0x3C4, /* 35, +5.5dB */
+	0x3FE  /* 36, +6.0dB */
+};
+
+static const u32 ofdmswing_table[] =3D {
+	0x0b40002d, /* 0, -15.0dB */
+	0x0c000030, /* 1, -14.5dB */
+	0x0cc00033, /* 2, -14.0dB */
+	0x0d800036, /* 3, -13.5dB */
+	0x0e400039, /* 4, -13.0dB */
+	0x0f00003c, /* 5, -12.5dB */
+	0x10000040, /* 6, -12.0dB */
+	0x11000044, /* 7, -11.5dB */
+	0x12000048, /* 8, -11.0dB */
+	0x1300004c, /* 9, -10.5dB */
+	0x14400051, /* 10, -10.0dB */
+	0x15800056, /* 11, -9.5dB */
+	0x16c0005b, /* 12, -9.0dB */
+	0x18000060, /* 13, -8.5dB */
+	0x19800066, /* 14, -8.0dB */
+	0x1b00006c, /* 15, -7.5dB */
+	0x1c800072, /* 16, -7.0dB */
+	0x1e400079, /* 17, -6.5dB */
+	0x20000080, /* 18, -6.0dB */
+	0x22000088, /* 19, -5.5dB */
+	0x24000090, /* 20, -5.0dB */
+	0x26000098, /* 21, -4.5dB */
+	0x288000a2, /* 22, -4.0dB */
+	0x2ac000ab, /* 23, -3.5dB */
+	0x2d4000b5, /* 24, -3.0dB */
+	0x300000c0, /* 25, -2.5dB */
+	0x32c000cb, /* 26, -2.0dB */
+	0x35c000d7, /* 27, -1.5dB */
+	0x390000e4, /* 28, -1.0dB */
+	0x3c8000f2, /* 29, -0.5dB */
+	0x40000100, /* 30, +0dB */
+	0x43c0010f, /* 31, +0.5dB */
+	0x47c0011f, /* 32, +1.0dB */
+	0x4c000130, /* 33, +1.5dB */
+	0x50800142, /* 34, +2.0dB */
+	0x55400155, /* 35, +2.5dB */
+	0x5a400169, /* 36, +3.0dB */
+	0x5fc0017f, /* 37, +3.5dB */
+	0x65400195, /* 38, +4.0dB */
+	0x6b8001ae, /* 39, +4.5dB */
+	0x71c001c7, /* 40, +5.0dB */
+	0x788001e2, /* 41, +5.5dB */
+	0x7f8001fe  /* 42, +6.0dB */
+};
+
+static const u8 cckswing_table_ch1ch13[CCK_TABLE_SIZE][8] =3D {
+	{0x09, 0x08, 0x07, 0x06, 0x04, 0x03, 0x01, 0x01}, /* 0, -16.0dB */
+	{0x09, 0x09, 0x08, 0x06, 0x05, 0x03, 0x01, 0x01}, /* 1, -15.5dB */
+	{0x0a, 0x09, 0x08, 0x07, 0x05, 0x03, 0x02, 0x01}, /* 2, -15.0dB */
+	{0x0a, 0x0a, 0x09, 0x07, 0x05, 0x03, 0x02, 0x01}, /* 3, -14.5dB */
+	{0x0b, 0x0a, 0x09, 0x08, 0x06, 0x04, 0x02, 0x01}, /* 4, -14.0dB */
+	{0x0b, 0x0b, 0x0a, 0x08, 0x06, 0x04, 0x02, 0x01}, /* 5, -13.5dB */
+	{0x0c, 0x0c, 0x0a, 0x09, 0x06, 0x04, 0x02, 0x01}, /* 6, -13.0dB */
+	{0x0d, 0x0c, 0x0b, 0x09, 0x07, 0x04, 0x02, 0x01}, /* 7, -12.5dB */
+	{0x0d, 0x0d, 0x0c, 0x0a, 0x07, 0x05, 0x02, 0x01}, /* 8, -12.0dB */
+	{0x0e, 0x0e, 0x0c, 0x0a, 0x08, 0x05, 0x02, 0x01}, /* 9, -11.5dB */
+	{0x0f, 0x0f, 0x0d, 0x0b, 0x08, 0x05, 0x03, 0x01}, /* 10, -11.0dB */
+	{0x10, 0x10, 0x0e, 0x0b, 0x08, 0x05, 0x03, 0x01}, /* 11, -10.5dB */
+	{0x11, 0x11, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /* 12, -10.0dB */
+	{0x12, 0x12, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /* 13, -9.5dB */
+	{0x13, 0x13, 0x10, 0x0d, 0x0a, 0x06, 0x03, 0x01}, /* 14, -9.0dB */
+	{0x14, 0x14, 0x11, 0x0e, 0x0b, 0x07, 0x03, 0x02}, /* 15, -8.5dB */
+	{0x16, 0x15, 0x12, 0x0f, 0x0b, 0x07, 0x04, 0x01}, /* 16, -8.0dB */
+	{0x17, 0x16, 0x13, 0x10, 0x0c, 0x08, 0x04, 0x02}, /* 17, -7.5dB */
+	{0x18, 0x17, 0x15, 0x11, 0x0c, 0x08, 0x04, 0x02}, /* 18, -7.0dB */
+	{0x1a, 0x19, 0x16, 0x12, 0x0d, 0x09, 0x04, 0x02}, /* 19, -6.5dB */
+	{0x1b, 0x1a, 0x17, 0x13, 0x0e, 0x09, 0x04, 0x02}, /* 20, -6.0dB */
+	{0x1d, 0x1c, 0x18, 0x14, 0x0f, 0x0a, 0x05, 0x02}, /* 21, -5.5dB */
+	{0x1f, 0x1e, 0x1a, 0x15, 0x10, 0x0a, 0x05, 0x02}, /* 22, -5.0dB */
+	{0x20, 0x20, 0x1b, 0x16, 0x11, 0x08, 0x05, 0x02}, /* 23, -4.5dB */
+	{0x22, 0x21, 0x1d, 0x18, 0x11, 0x0b, 0x06, 0x02}, /* 24, -4.0dB */
+	{0x24, 0x23, 0x1f, 0x19, 0x13, 0x0c, 0x06, 0x03}, /* 25, -3.5dB */
+	{0x26, 0x25, 0x21, 0x1b, 0x14, 0x0d, 0x06, 0x03}, /* 26, -3.0dB */
+	{0x28, 0x28, 0x22, 0x1c, 0x15, 0x0d, 0x07, 0x03}, /* 27, -2.5dB */
+	{0x2b, 0x2a, 0x25, 0x1e, 0x16, 0x0e, 0x07, 0x03}, /* 28, -2.0dB */
+	{0x2d, 0x2d, 0x27, 0x1f, 0x18, 0x0f, 0x08, 0x03}, /* 29, -1.5dB */
+	{0x30, 0x2f, 0x29, 0x21, 0x19, 0x10, 0x08, 0x03}, /* 30, -1.0dB */
+	{0x33, 0x32, 0x2b, 0x23, 0x1a, 0x11, 0x08, 0x04}, /* 31, -0.5dB */
+	{0x36, 0x35, 0x2e, 0x25, 0x1c, 0x12, 0x09, 0x04} /* 32, +0dB */
+};
+
+static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] =3D {
+	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}, /* 0, -16.0dB */
+	{0x09, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 1, -15.5dB */
+	{0x0a, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 2, -15.0dB */
+	{0x0a, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 3, -14.5dB */
+	{0x0b, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 4, -14.0dB */
+	{0x0b, 0x0b, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 5, -13.5dB */
+	{0x0c, 0x0c, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 6, -13.0dB */
+	{0x0d, 0x0c, 0x0b, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 7, -12.5dB */
+	{0x0d, 0x0d, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /* 8, -12.0dB */
+	{0x0e, 0x0e, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /* 9, -11.5dB */
+	{0x0f, 0x0f, 0x0d, 0x08, 0x00, 0x00, 0x00, 0x00}, /* 10, -11.0dB */
+	{0x10, 0x10, 0x0e, 0x08, 0x00, 0x00, 0x00, 0x00}, /* 11, -10.5dB */
+	{0x11, 0x11, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /* 12, -10.0dB */
+	{0x12, 0x12, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /* 13, -9.5dB */
+	{0x13, 0x13, 0x10, 0x0a, 0x00, 0x00, 0x00, 0x00}, /* 14, -9.0dB */
+	{0x14, 0x14, 0x11, 0x0a, 0x00, 0x00, 0x00, 0x00}, /* 15, -8.5dB */
+	{0x16, 0x15, 0x12, 0x0b, 0x00, 0x00, 0x00, 0x00}, /* 16, -8.0dB */
+	{0x17, 0x16, 0x13, 0x0b, 0x00, 0x00, 0x00, 0x00}, /* 17, -7.5dB */
+	{0x18, 0x17, 0x15, 0x0c, 0x00, 0x00, 0x00, 0x00}, /* 18, -7.0dB */
+	{0x1a, 0x19, 0x16, 0x0d, 0x00, 0x00, 0x00, 0x00}, /* 19, -6.5dB */
+	{0x1b, 0x1a, 0x17, 0x0e, 0x00, 0x00, 0x00, 0x00}, /* 20, -6.0dB */
+	{0x1d, 0x1c, 0x18, 0x0e, 0x00, 0x00, 0x00, 0x00}, /* 21, -5.5dB */
+	{0x1f, 0x1e, 0x1a, 0x0f, 0x00, 0x00, 0x00, 0x00}, /* 22, -5.0dB */
+	{0x20, 0x20, 0x1b, 0x10, 0x00, 0x00, 0x00, 0x00}, /* 23, -4.5dB */
+	{0x22, 0x21, 0x1d, 0x11, 0x00, 0x00, 0x00, 0x00}, /* 24, -4.0dB */
+	{0x24, 0x23, 0x1f, 0x12, 0x00, 0x00, 0x00, 0x00}, /* 25, -3.5dB */
+	{0x26, 0x25, 0x21, 0x13, 0x00, 0x00, 0x00, 0x00}, /* 26, -3.0dB */
+	{0x28, 0x28, 0x24, 0x14, 0x00, 0x00, 0x00, 0x00}, /* 27, -2.5dB */
+	{0x2b, 0x2a, 0x25, 0x15, 0x00, 0x00, 0x00, 0x00}, /* 28, -2.0dB */
+	{0x2d, 0x2d, 0x17, 0x17, 0x00, 0x00, 0x00, 0x00}, /* 29, -1.5dB */
+	{0x30, 0x2f, 0x29, 0x18, 0x00, 0x00, 0x00, 0x00}, /* 30, -1.0dB */
+	{0x33, 0x32, 0x2b, 0x19, 0x00, 0x00, 0x00, 0x00}, /* 31, -0.5dB */
+	{0x36, 0x35, 0x2e, 0x1b, 0x00, 0x00, 0x00, 0x00} /* 32, +0dB */
+};
+
+static const u32 edca_setting_dl[PEER_MAX] =3D {
+	0xa44f,		/* 0 UNKNOWN */
+	0x5ea44f,	/* 1 REALTEK_90 */
+	0x5e4322,	/* 2 REALTEK_92SE */
+	0x5ea42b,		/* 3 BROAD	*/
+	0xa44f,		/* 4 RAL */
+	0xa630,		/* 5 ATH */
+	0x5ea630,		/* 6 CISCO */
+	0x5ea42b,		/* 7 MARVELL */
+};
+
+static const u32 edca_setting_ul[PEER_MAX] =3D {
+	0x5e4322,	/* 0 UNKNOWN */
+	0xa44f,		/* 1 REALTEK_90 */
+	0x5ea44f,	/* 2 REALTEK_92SE */
+	0x5ea32b,	/* 3 BROAD */
+	0x5ea422,	/* 4 RAL */
+	0x5ea322,	/* 5 ATH */
+	0x3ea430,	/* 6 CISCO */
+	0x5ea44f,	/* 7 MARV */
+};
+
+static u8 rtl8818e_delta_swing_table_idx_24gb_p[] =3D {
+	0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 4,
+	4, 4, 4, 5, 5, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9};
+
+static u8 rtl8818e_delta_swing_table_idx_24gb_n[] =3D {
+	0, 0, 0, 2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 6, 6,
+	7, 7, 7, 7, 8, 8, 9, 9, 10, 10, 10, 11, 11, 11, 11};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gb_n[]  =3D {
+	0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6,
+	6, 6, 7, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gb_p[] =3D {
+	0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6,
+	6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9, 9};
+
+static u8 rtl8812ae_delta_swing_table_idx_24ga_n[] =3D {
+	0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6,
+	6, 6, 7, 8, 8, 9, 9, 9, 10, 10, 10, 10, 11, 11};
+
+static u8 rtl8812ae_delta_swing_table_idx_24ga_p[] =3D {
+	0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6,
+	6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9, 9};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gcckb_n[] =3D {
+	0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6,
+	6, 6, 7, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gcckb_p[] =3D {
+	0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6,
+	6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9, 9};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gccka_n[] =3D {
+	0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6,
+	6, 6, 7, 8, 8, 9, 9, 9, 10, 10, 10, 10, 11, 11};
+
+static u8 rtl8812ae_delta_swing_table_idx_24gccka_p[] =3D {
+	0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6,
+	6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 9, 9};
+
+static u8 rtl8812ae_delta_swing_table_idx_5gb_n[][DEL_SW_IDX_SZ] =3D {
+	{0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 7, 7,
+	7, 8, 8, 9, 9, 9, 10, 10, 11, 11, 12, 12, 13},
+	{0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7,
+	7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 13, 13},
+	{0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8, 9, 10, 11,
+	12, 12, 13, 14, 14, 14, 15, 16, 17, 17, 17, 18, 18, 18},
+};
+
+static u8 rtl8812ae_delta_swing_table_idx_5gb_p[][DEL_SW_IDX_SZ] =3D {
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11},
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11},
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 7, 7, 8, 8, 9,
+	9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11},
+};
+
+static u8 rtl8812ae_delta_swing_table_idx_5ga_n[][DEL_SW_IDX_SZ] =3D {
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 13, 13, 13},
+	{0, 1, 1, 2, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 8, 9,
+	9, 10, 10, 11, 11, 11, 12, 12, 12, 12, 12, 13, 13},
+	{0, 1, 1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11,
+	12, 13, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 18, 18},
+};
+
+static u8 rtl8812ae_delta_swing_table_idx_5ga_p[][DEL_SW_IDX_SZ] =3D {
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11},
+	{0, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	9, 9, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11},
+	{0, 1, 1, 2, 3, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9, 9,
+	10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11},
+};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gb_n[] =3D {
+	0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6,
+	6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gb_p[]  =3D {
+	0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 12, 12, 12};
+
+static u8 rtl8821ae_delta_swing_table_idx_24ga_n[]  =3D {
+	0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6,
+	6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10};
+
+static u8 rtl8821ae_delta_swing_table_idx_24ga_p[] =3D {
+	0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 12, 12, 12};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gcckb_n[] =3D {
+	0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6,
+	6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gcckb_p[] =3D {
+	0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 12, 12, 12};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gccka_n[] =3D {
+	0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6,
+	6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10};
+
+static u8 rtl8821ae_delta_swing_table_idx_24gccka_p[] =3D {
+	0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8,
+	8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 12, 12, 12};
+
+static u8 rtl8821ae_delta_swing_table_idx_5gb_n[][DEL_SW_IDX_SZ] =3D {
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+};
+
+static u8 rtl8821ae_delta_swing_table_idx_5gb_p[][DEL_SW_IDX_SZ] =3D {
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+};
+
+static u8 rtl8821ae_delta_swing_table_idx_5ga_n[][DEL_SW_IDX_SZ] =3D {
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+};
+
+static u8 rtl8821ae_delta_swing_table_idx_5ga_p[][DEL_SW_IDX_SZ] =3D {
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+	{0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 9, 10, 11,
+	12, 12, 13, 14, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16},
+};
+
+void rtl8821ae_dm_txpower_track_adjust(struct ieee80211_hw *hw,
+				       u8 type, u8 *pdirection,
+				       u32 *poutwrite_val)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	u8 pwr_val =3D 0;
+
+	if (type =3D=3D 0) {
+		if (rtlpriv->dm.swing_idx_ofdm[RF90_PATH_A] <=3D
+			rtlpriv->dm.swing_idx_ofdm_base[RF90_PATH_A]) {
+			*pdirection =3D 1;
+			pwr_val =3D rtldm->swing_idx_ofdm_base[RF90_PATH_A] -
+					rtldm->swing_idx_ofdm[RF90_PATH_A];
+		} else {
+			*pdirection =3D 2;
+			pwr_val =3D rtldm->swing_idx_ofdm[RF90_PATH_A] -
+				rtldm->swing_idx_ofdm_base[RF90_PATH_A];
+		}
+	} else if (type =3D=3D 1) {
+		if (rtldm->swing_idx_cck <=3D rtldm->swing_idx_cck_base) {
+			*pdirection =3D 1;
+			pwr_val =3D rtldm->swing_idx_cck_base -
+					rtldm->swing_idx_cck;
+		} else {
+			*pdirection =3D 2;
+			pwr_val =3D rtldm->swing_idx_cck -
+				rtldm->swing_idx_cck_base;
+		}
+	}
+
+	if (pwr_val >=3D TXPWRTRACK_MAX_IDX && (*pdirection =3D=3D 1))
+		pwr_val =3D TXPWRTRACK_MAX_IDX;
+
+	*poutwrite_val =3D pwr_val | (pwr_val << 8)|
+				(pwr_val << 16)|
+				(pwr_val << 24);
+}
+
+void rtl8821ae_dm_clear_txpower_tracking_state(struct ieee80211_hw *hw=
)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm *rtldm =3D rtl_dm(rtlpriv);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtlpriv);
+	u8 p =3D 0;
+
+	rtldm->swing_idx_cck_base =3D rtldm->default_cck_index;
+	rtldm->swing_idx_cck =3D rtldm->default_cck_index;
+	rtldm->cck_index =3D 0;
+
+	for (p =3D RF90_PATH_A; p <=3D RF90_PATH_B; ++p) {
+		rtldm->swing_idx_ofdm_base[p] =3D rtldm->default_ofdm_index;
+		rtldm->swing_idx_ofdm[p] =3D rtldm->default_ofdm_index;
+		rtldm->ofdm_index[p] =3D rtldm->default_ofdm_index;
+
+		rtldm->power_index_offset[p] =3D 0;
+		rtldm->delta_power_index[p] =3D 0;
+		rtldm->delta_power_index_last[p] =3D 0;
+		/*Initial Mix mode power tracking*/
+		rtldm->absolute_ofdm_swing_idx[p] =3D 0;
+		rtldm->remnant_ofdm_swing_idx[p] =3D 0;
+	}
+	/*Initial at Modify Tx Scaling Mode*/
+	rtldm->modify_txagc_flag_path_a =3D false;
+	/*Initial at Modify Tx Scaling Mode*/
+	rtldm->modify_txagc_flag_path_b =3D false;
+	rtldm->remnant_cck_idx =3D 0;
+	rtldm->thermalvalue =3D rtlefuse->eeprom_thermalmeter;
+	rtldm->thermalvalue_iqk =3D rtlefuse->eeprom_thermalmeter;
+	rtldm->thermalvalue_lck =3D rtlefuse->eeprom_thermalmeter;
+}
+
+static u8  rtl8821ae_dm_get_swing_index(struct ieee80211_hw *hw)
+{
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 i =3D 0;
+	u32  bb_swing;
+
+	bb_swing =3D phy_get_tx_swing_8812A(hw, rtlhal->current_bandtype,
+					  RF90_PATH_A);
+
+	for (i =3D 0; i < TXSCALE_TABLE_SIZE; ++i)
+		if (bb_swing =3D=3D rtl8821ae_txscaling_table[i])
+			break;
+
+	return i;
+}
+
+void rtl8821ae_dm_initialize_txpower_tracking_thermalmeter(
+				struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm *rtldm =3D rtl_dm(rtlpriv);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtlpriv);
+	u8 default_swing_index  =3D 0;
+	u8 p =3D 0;
+
+	rtlpriv->dm.txpower_track_control =3D true;
+	rtldm->thermalvalue =3D rtlefuse->eeprom_thermalmeter;
+	rtldm->thermalvalue_iqk =3D rtlefuse->eeprom_thermalmeter;
+	rtldm->thermalvalue_lck =3D rtlefuse->eeprom_thermalmeter;
+	default_swing_index =3D rtl8821ae_dm_get_swing_index(hw);
+
+	rtldm->default_ofdm_index =3D
+		(default_swing_index =3D=3D TXSCALE_TABLE_SIZE) ?
+		24 : default_swing_index;
+	rtldm->default_cck_index =3D 24;
+
+	rtldm->swing_idx_cck_base =3D rtldm->default_cck_index;
+	rtldm->cck_index =3D rtldm->default_cck_index;
+
+	for (p =3D RF90_PATH_A; p < MAX_RF_PATH; ++p) {
+		rtldm->swing_idx_ofdm_base[p] =3D
+			rtldm->default_ofdm_index;
+		rtldm->ofdm_index[p] =3D rtldm->default_ofdm_index;
+		rtldm->delta_power_index[p] =3D 0;
+		rtldm->power_index_offset[p] =3D 0;
+		rtldm->delta_power_index_last[p] =3D 0;
+	}
+}
+
+static void rtl8821ae_dm_diginit(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+
+	dm_digtable->cur_igvalue =3D rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7=
f);
+	dm_digtable->rssi_lowthresh =3D DM_DIG_THRESH_LOW;
+	dm_digtable->rssi_highthresh =3D DM_DIG_THRESH_HIGH;
+	dm_digtable->fa_lowthresh =3D DM_FALSEALARM_THRESH_LOW;
+	dm_digtable->fa_highthresh =3D DM_FALSEALARM_THRESH_HIGH;
+	dm_digtable->rx_gain_max =3D DM_DIG_MAX;
+	dm_digtable->rx_gain_min =3D DM_DIG_MIN;
+	dm_digtable->back_val =3D DM_DIG_BACKOFF_DEFAULT;
+	dm_digtable->back_range_max =3D DM_DIG_BACKOFF_MAX;
+	dm_digtable->back_range_min =3D DM_DIG_BACKOFF_MIN;
+	dm_digtable->pre_cck_cca_thres =3D 0xff;
+	dm_digtable->cur_cck_cca_thres =3D 0x83;
+	dm_digtable->forbidden_igi =3D DM_DIG_MIN;
+	dm_digtable->large_fa_hit =3D 0;
+	dm_digtable->recover_cnt =3D 0;
+	dm_digtable->dig_dynamic_min =3D DM_DIG_MIN;
+	dm_digtable->dig_dynamic_min_1 =3D DM_DIG_MIN;
+	dm_digtable->media_connect_0 =3D false;
+	dm_digtable->media_connect_1 =3D false;
+	rtlpriv->dm.dm_initialgain_enable =3D true;
+	dm_digtable->bt30_cur_igi =3D 0x32;
+}
+
+void rtl8821ae_dm_init_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtlpriv->dm.current_turbo_edca =3D false;
+	rtlpriv->dm.is_any_nonbepkts =3D false;
+	rtlpriv->dm.is_cur_rdlstate =3D false;
+}
+
+void rtl8821ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rate_adaptive *p_ra =3D &rtlpriv->ra;
+
+	p_ra->ratr_state =3D DM_RATR_STA_INIT;
+	p_ra->pre_ratr_state =3D DM_RATR_STA_INIT;
+
+	rtlpriv->dm.dm_type =3D DM_TYPE_BYDRIVER;
+	if (rtlpriv->dm.dm_type =3D=3D DM_TYPE_BYDRIVER)
+		rtlpriv->dm.useramask =3D true;
+	else
+		rtlpriv->dm.useramask =3D false;
+
+	p_ra->high_rssi_thresh_for_ra =3D 50;
+	p_ra->low_rssi_thresh_for_ra40m =3D 20;
+}
+
+static void rtl8821ae_dm_init_dynamic_atc_switch(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtlpriv->dm.crystal_cap =3D rtlpriv->efuse.crystalcap;
+
+	rtlpriv->dm.atc_status =3D rtl_get_bbreg(hw, ROFDM1_CFOTRACKING, BIT(=
11));
+	rtlpriv->dm.cfo_threshold =3D CFO_THRESHOLD_XTAL;
+}
+
+static void rtl8821ae_dm_common_info_self_init(struct ieee80211_hw *hw=
)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 tmp;
+
+	rtlphy->cck_high_power =3D
+		(bool)rtl_get_bbreg(hw, ODM_REG_CCK_RPT_FORMAT_11AC,
+				    ODM_BIT_CCK_RPT_FORMAT_11AC);
+
+	tmp =3D (u8)rtl_get_bbreg(hw, ODM_REG_BB_RX_PATH_11AC,
+				ODM_BIT_BB_RX_PATH_11AC);
+	if (tmp & BIT(0))
+		rtlpriv->dm.rfpath_rxenable[0] =3D true;
+	if (tmp & BIT(1))
+		rtlpriv->dm.rfpath_rxenable[1] =3D true;
+}
+
+void rtl8821ae_dm_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	spin_lock(&rtlpriv->locks.iqk_lock);
+	rtlphy->lck_inprogress =3D false;
+	spin_unlock(&rtlpriv->locks.iqk_lock);
+
+	rtlpriv->dm.dm_type =3D DM_TYPE_BYDRIVER;
+	rtl8821ae_dm_common_info_self_init(hw);
+	rtl8821ae_dm_diginit(hw);
+	rtl8821ae_dm_init_rate_adaptive_mask(hw);
+	rtl8821ae_dm_init_edca_turbo(hw);
+	rtl8821ae_dm_initialize_txpower_tracking_thermalmeter(hw);
+	rtl8821ae_dm_init_dynamic_atc_switch(hw);
+}
+
+static void rtl8821ae_dm_find_minimum_rssi(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *rtl_dm_dig =3D &rtlpriv->dm_digtable;
+	struct rtl_mac *mac =3D rtl_mac(rtlpriv);
+
+	/* Determine the minimum RSSI  */
+	if ((mac->link_state < MAC80211_LINKED) &&
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb =3D=3D 0)) {
+		rtl_dm_dig->min_undec_pwdb_for_dm =3D 0;
+		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
+			 "Not connected to any\n");
+	}
+	if (mac->link_state >=3D MAC80211_LINKED) {
+		if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+		    mac->opmode =3D=3D NL80211_IFTYPE_ADHOC) {
+			rtl_dm_dig->min_undec_pwdb_for_dm =3D
+			    rtlpriv->dm.entry_min_undec_sm_pwdb;
+			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
+				 "AP Client PWDB =3D 0x%lx\n",
+				 rtlpriv->dm.entry_min_undec_sm_pwdb);
+		} else {
+			rtl_dm_dig->min_undec_pwdb_for_dm =3D
+			    rtlpriv->dm.undec_sm_pwdb;
+			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
+				 "STA Default Port PWDB =3D 0x%x\n",
+				 rtl_dm_dig->min_undec_pwdb_for_dm);
+		}
+	} else {
+		rtl_dm_dig->min_undec_pwdb_for_dm =3D
+		    rtlpriv->dm.entry_min_undec_sm_pwdb;
+		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
+			 "AP Ext Port or disconnet PWDB =3D 0x%x\n",
+			 rtl_dm_dig->min_undec_pwdb_for_dm);
+	}
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "MinUndecoratedPWDBForDM =3D%d\n",
+		 rtl_dm_dig->min_undec_pwdb_for_dm);
+}
+
+static void  rtl8812ae_dm_rssi_dump_to_register(struct ieee80211_hw *h=
w)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtl_write_byte(rtlpriv, RA_RSSI_DUMP,
+		       rtlpriv->stats.rx_rssi_percentage[0]);
+	rtl_write_byte(rtlpriv, RB_RSSI_DUMP,
+		       rtlpriv->stats.rx_rssi_percentage[1]);
+
+	/* Rx EVM*/
+	rtl_write_byte(rtlpriv, RS1_RX_EVM_DUMP,
+		       rtlpriv->stats.rx_evm_dbm[0]);
+	rtl_write_byte(rtlpriv, RS2_RX_EVM_DUMP,
+		       rtlpriv->stats.rx_evm_dbm[1]);
+
+	/*Rx SNR*/
+	rtl_write_byte(rtlpriv, RA_RX_SNR_DUMP,
+		       (u8)(rtlpriv->stats.rx_snr_db[0]));
+	rtl_write_byte(rtlpriv, RB_RX_SNR_DUMP,
+		       (u8)(rtlpriv->stats.rx_snr_db[1]));
+
+	/*Rx Cfo_Short*/
+	rtl_write_word(rtlpriv, RA_CFO_SHORT_DUMP,
+		       rtlpriv->stats.rx_cfo_short[0]);
+	rtl_write_word(rtlpriv, RB_CFO_SHORT_DUMP,
+		       rtlpriv->stats.rx_cfo_short[1]);
+
+	/*Rx Cfo_Tail*/
+	rtl_write_word(rtlpriv, RA_CFO_LONG_DUMP,
+		       rtlpriv->stats.rx_cfo_tail[0]);
+	rtl_write_word(rtlpriv, RB_CFO_LONG_DUMP,
+		       rtlpriv->stats.rx_cfo_tail[1]);
+}
+
+static void rtl8821ae_dm_check_rssi_monitor(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_sta_info *drv_priv;
+	u8 h2c_parameter[4] =3D { 0 };
+	long tmp_entry_max_pwdb =3D 0, tmp_entry_min_pwdb =3D 0xff;
+	u8 stbc_tx =3D 0;
+	u64 cur_txokcnt =3D 0, cur_rxokcnt =3D 0;
+	static u64 last_txokcnt =3D 0, last_rxokcnt;
+
+	cur_txokcnt =3D rtlpriv->stats.txbytesunicast - last_txokcnt;
+	cur_rxokcnt =3D rtlpriv->stats.rxbytesunicast - last_rxokcnt;
+	last_txokcnt =3D rtlpriv->stats.txbytesunicast;
+	last_rxokcnt =3D rtlpriv->stats.rxbytesunicast;
+	if (cur_rxokcnt > (last_txokcnt * 6))
+		h2c_parameter[3] =3D 0x01;
+	else
+		h2c_parameter[3] =3D 0x00;
+
+	/* AP & ADHOC & MESH */
+	if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+	    mac->opmode =3D=3D NL80211_IFTYPE_ADHOC ||
+	    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
+			if (drv_priv->rssi_stat.undec_sm_pwdb <
+					tmp_entry_min_pwdb)
+				tmp_entry_min_pwdb =3D
+					drv_priv->rssi_stat.undec_sm_pwdb;
+			if (drv_priv->rssi_stat.undec_sm_pwdb >
+					tmp_entry_max_pwdb)
+				tmp_entry_max_pwdb =3D
+					drv_priv->rssi_stat.undec_sm_pwdb;
+		}
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+
+		/* If associated entry is found */
+		if (tmp_entry_max_pwdb !=3D 0) {
+			rtlpriv->dm.entry_max_undec_sm_pwdb =3D
+				tmp_entry_max_pwdb;
+			RTPRINT(rtlpriv, FDM, DM_PWDB,
+				"EntryMaxPWDB =3D 0x%lx(%ld)\n",
+				tmp_entry_max_pwdb, tmp_entry_max_pwdb);
+		} else {
+			rtlpriv->dm.entry_max_undec_sm_pwdb =3D 0;
+		}
+		/* If associated entry is found */
+		if (tmp_entry_min_pwdb !=3D 0xff) {
+			rtlpriv->dm.entry_min_undec_sm_pwdb =3D
+				tmp_entry_min_pwdb;
+			RTPRINT(rtlpriv, FDM, DM_PWDB,
+				"EntryMinPWDB =3D 0x%lx(%ld)\n",
+				tmp_entry_min_pwdb, tmp_entry_min_pwdb);
+		} else {
+			rtlpriv->dm.entry_min_undec_sm_pwdb =3D 0;
+		}
+	}
+	/* Indicate Rx signal strength to FW. */
+	if (rtlpriv->dm.useramask) {
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			if (mac->mode =3D=3D WIRELESS_MODE_AC_24G ||
+			    mac->mode =3D=3D WIRELESS_MODE_AC_5G ||
+			    mac->mode =3D=3D WIRELESS_MODE_AC_ONLY)
+				stbc_tx =3D (mac->vht_cur_stbc &
+					   STBC_VHT_ENABLE_TX) ? 1 : 0;
+			else
+				stbc_tx =3D (mac->ht_cur_stbc &
+					   STBC_HT_ENABLE_TX) ? 1 : 0;
+			h2c_parameter[3] |=3D stbc_tx << 1;
+		}
+		h2c_parameter[2] =3D
+			(u8)(rtlpriv->dm.undec_sm_pwdb & 0xFF);
+		h2c_parameter[1] =3D 0x20;
+		h2c_parameter[0] =3D 0;
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8821ae_fill_h2c_cmd(hw, H2C_RSSI_21AE_REPORT, 4,
+					       h2c_parameter);
+		else
+			rtl8821ae_fill_h2c_cmd(hw, H2C_RSSI_21AE_REPORT, 3,
+					       h2c_parameter);
+	} else {
+		rtl_write_byte(rtlpriv, 0x4fe, rtlpriv->dm.undec_sm_pwdb);
+	}
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+		rtl8812ae_dm_rssi_dump_to_register(hw);
+	rtl8821ae_dm_find_minimum_rssi(hw);
+	dm_digtable->rssi_val_min =3D rtlpriv->dm_digtable.min_undec_pwdb_for=
_dm;
+}
+
+void rtl8821ae_dm_write_cck_cca_thres(struct ieee80211_hw *hw, u8 curr=
ent_cca)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+
+	if (dm_digtable->cur_cck_cca_thres !=3D current_cca)
+		rtl_write_byte(rtlpriv, DM_REG_CCK_CCA_11AC, current_cca);
+
+	dm_digtable->pre_cck_cca_thres =3D dm_digtable->cur_cck_cca_thres;
+	dm_digtable->cur_cck_cca_thres =3D current_cca;
+}
+
+void rtl8821ae_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+
+	if (dm_digtable->stop_dig)
+		return;
+
+	if (dm_digtable->cur_igvalue !=3D current_igi) {
+		rtl_set_bbreg(hw, DM_REG_IGI_A_11AC,
+			      DM_BIT_IGI_11AC, current_igi);
+		if (rtlpriv->phy.rf_type !=3D RF_1T1R)
+			rtl_set_bbreg(hw, DM_REG_IGI_B_11AC,
+				      DM_BIT_IGI_11AC, current_igi);
+	}
+	dm_digtable->cur_igvalue =3D current_igi;
+}
+
+static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 dig_dynamic_min;
+	u8 dig_max_of_min;
+	bool first_connect, first_disconnect;
+	u8 dm_dig_max, dm_dig_min, offset;
+	u8 current_igi =3D dm_digtable->cur_igvalue;
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "\n");
+
+	if (mac->act_scanning) {
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "Return: In Scan Progress\n");
+		return;
+	}
+
+	/*add by Neil Chen to avoid PSD is processing*/
+	dig_dynamic_min =3D dm_digtable->dig_dynamic_min;
+	first_connect =3D (mac->link_state >=3D MAC80211_LINKED) &&
+			(!dm_digtable->media_connect_0);
+	first_disconnect =3D (mac->link_state < MAC80211_LINKED) &&
+			(dm_digtable->media_connect_0);
+
+	/*1 Boundary Decision*/
+
+	dm_dig_max =3D 0x5A;
+
+	if (rtlhal->hw_type !=3D HARDWARE_TYPE_RTL8821AE)
+		dm_dig_min =3D DM_DIG_MIN;
+	else
+		dm_dig_min =3D 0x1C;
+
+	dig_max_of_min =3D DM_DIG_MAX_AP;
+
+	if (mac->link_state >=3D MAC80211_LINKED) {
+		if (rtlhal->hw_type !=3D HARDWARE_TYPE_RTL8821AE)
+			offset =3D 20;
+		else
+			offset =3D 10;
+
+		if ((dm_digtable->rssi_val_min + offset) > dm_dig_max)
+			dm_digtable->rx_gain_max =3D dm_dig_max;
+		else if ((dm_digtable->rssi_val_min + offset) < dm_dig_min)
+			dm_digtable->rx_gain_max =3D dm_dig_min;
+		else
+			dm_digtable->rx_gain_max =3D
+				dm_digtable->rssi_val_min + offset;
+
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "dm_digtable->rssi_val_min=3D0x%x,dm_digtable->rx_gain_max =3D 0x%=
x",
+			 dm_digtable->rssi_val_min,
+			 dm_digtable->rx_gain_max);
+		if (rtlpriv->dm.one_entry_only) {
+			offset =3D 0;
+
+			if (dm_digtable->rssi_val_min - offset < dm_dig_min)
+				dig_dynamic_min =3D dm_dig_min;
+			else if (dm_digtable->rssi_val_min -
+				offset > dig_max_of_min)
+				dig_dynamic_min =3D dig_max_of_min;
+			else
+				dig_dynamic_min =3D
+					dm_digtable->rssi_val_min - offset;
+
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "bOneEntryOnly=3DTRUE, dig_dynamic_min=3D0x%x\n",
+				 dig_dynamic_min);
+		} else {
+			dig_dynamic_min =3D dm_dig_min;
+		}
+	} else {
+		dm_digtable->rx_gain_max =3D dm_dig_max;
+		dig_dynamic_min =3D dm_dig_min;
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "No Link\n");
+	}
+
+	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "Abnornally false alarm case.\n");
+
+		if (dm_digtable->large_fa_hit !=3D 3)
+			dm_digtable->large_fa_hit++;
+		if (dm_digtable->forbidden_igi < current_igi) {
+			dm_digtable->forbidden_igi =3D current_igi;
+			dm_digtable->large_fa_hit =3D 1;
+		}
+
+		if (dm_digtable->large_fa_hit >=3D 3) {
+			if ((dm_digtable->forbidden_igi + 1) >
+				dm_digtable->rx_gain_max)
+				dm_digtable->rx_gain_min =3D
+					dm_digtable->rx_gain_max;
+			else
+				dm_digtable->rx_gain_min =3D
+					(dm_digtable->forbidden_igi + 1);
+			dm_digtable->recover_cnt =3D 3600;
+		}
+	} else {
+		/*Recovery mechanism for IGI lower bound*/
+		if (dm_digtable->recover_cnt !=3D 0) {
+			dm_digtable->recover_cnt--;
+		} else {
+			if (dm_digtable->large_fa_hit < 3) {
+				if ((dm_digtable->forbidden_igi - 1) <
+				    dig_dynamic_min) {
+					dm_digtable->forbidden_igi =3D
+						dig_dynamic_min;
+					dm_digtable->rx_gain_min =3D
+						dig_dynamic_min;
+					RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+						 "Normal Case: At Lower Bound\n");
+				} else {
+					dm_digtable->forbidden_igi--;
+					dm_digtable->rx_gain_min =3D
+					  (dm_digtable->forbidden_igi + 1);
+					RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+						 "Normal Case: Approach Lower Bound\n");
+				}
+			} else {
+				dm_digtable->large_fa_hit =3D 0;
+			}
+		}
+	}
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "pDM_DigTable->LargeFAHit=3D%d\n",
+		 dm_digtable->large_fa_hit);
+
+	if (rtlpriv->dm.dbginfo.num_qry_beacon_pkt < 10)
+		dm_digtable->rx_gain_min =3D dm_dig_min;
+
+	if (dm_digtable->rx_gain_min > dm_digtable->rx_gain_max)
+		dm_digtable->rx_gain_min =3D dm_digtable->rx_gain_max;
+
+	/*Adjust initial gain by false alarm*/
+	if (mac->link_state >=3D MAC80211_LINKED) {
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "DIG AfterLink\n");
+		if (first_connect) {
+			if (dm_digtable->rssi_val_min <=3D dig_max_of_min)
+				current_igi =3D dm_digtable->rssi_val_min;
+			else
+				current_igi =3D dig_max_of_min;
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "First Connect\n");
+		} else {
+			if (rtlpriv->falsealm_cnt.cnt_all > DM_DIG_FA_TH2)
+				current_igi =3D current_igi + 4;
+			else if (rtlpriv->falsealm_cnt.cnt_all > DM_DIG_FA_TH1)
+				current_igi =3D current_igi + 2;
+			else if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH0)
+				current_igi =3D current_igi - 2;
+
+			if ((rtlpriv->dm.dbginfo.num_qry_beacon_pkt < 10) &&
+			    (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH1)) {
+				current_igi =3D dm_digtable->rx_gain_min;
+				RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+					 "Beacon is less than 10 and FA is less than 768, IGI GOES TO 0x1=
E!!!!!!!!!!!!\n");
+			}
+		}
+	} else {
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "DIG BeforeLink\n");
+		if (first_disconnect) {
+			current_igi =3D dm_digtable->rx_gain_min;
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "First DisConnect\n");
+		} else {
+			/* 2012.03.30 LukeLee: enable DIG before
+			 * link but with very high thresholds
+			 */
+			if (rtlpriv->falsealm_cnt.cnt_all > 2000)
+				current_igi =3D current_igi + 4;
+			else if (rtlpriv->falsealm_cnt.cnt_all > 600)
+				current_igi =3D current_igi + 2;
+			else if (rtlpriv->falsealm_cnt.cnt_all < 300)
+				current_igi =3D current_igi - 2;
+
+			if (current_igi >=3D 0x3e)
+				current_igi =3D 0x3e;
+
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "England DIG\n");
+		}
+	}
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "DIG End Adjust IGI\n");
+	/* Check initial gain by upper/lower bound*/
+
+	if (current_igi > dm_digtable->rx_gain_max)
+		current_igi =3D dm_digtable->rx_gain_max;
+	if (current_igi < dm_digtable->rx_gain_min)
+		current_igi =3D dm_digtable->rx_gain_min;
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "rx_gain_max=3D0x%x, rx_gain_min=3D0x%x\n",
+		dm_digtable->rx_gain_max, dm_digtable->rx_gain_min);
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "TotalFA=3D%d\n", rtlpriv->falsealm_cnt.cnt_all);
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "CurIGValue=3D0x%x\n", current_igi);
+
+	rtl8821ae_dm_write_dig(hw, current_igi);
+	dm_digtable->media_connect_0 =3D
+		((mac->link_state >=3D MAC80211_LINKED) ? true : false);
+	dm_digtable->dig_dynamic_min =3D dig_dynamic_min;
+}
+
+static void rtl8821ae_dm_common_info_self_update(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 cnt =3D 0;
+	struct rtl_sta_info *drv_priv;
+
+	rtlpriv->dm.tx_rate =3D 0xff;
+
+	rtlpriv->dm.one_entry_only =3D false;
+
+	if (rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_STATION &&
+	    rtlpriv->mac80211.link_state >=3D MAC80211_LINKED) {
+		rtlpriv->dm.one_entry_only =3D true;
+		return;
+	}
+
+	if (rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_AP ||
+	    rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_ADHOC ||
+	    rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list)
+			cnt++;
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+
+		if (cnt =3D=3D 1)
+			rtlpriv->dm.one_entry_only =3D true;
+	}
+}
+
+static void rtl8821ae_dm_false_alarm_counter_statistics(struct ieee802=
11_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct false_alarm_statistics *falsealm_cnt =3D &rtlpriv->falsealm_cn=
t;
+	u32 cck_enable =3D 0;
+
+	/*read OFDM FA counter*/
+	falsealm_cnt->cnt_ofdm_fail =3D
+		rtl_get_bbreg(hw, ODM_REG_OFDM_FA_11AC, BMASKLWORD);
+	falsealm_cnt->cnt_cck_fail =3D
+		rtl_get_bbreg(hw, ODM_REG_CCK_FA_11AC, BMASKLWORD);
+
+	cck_enable =3D  rtl_get_bbreg(hw, ODM_REG_BB_RX_PATH_11AC, BIT(28));
+	if (cck_enable)  /*if(pDM_Odm->pBandType =3D=3D ODM_BAND_2_4G)*/
+		falsealm_cnt->cnt_all =3D falsealm_cnt->cnt_ofdm_fail +
+					falsealm_cnt->cnt_cck_fail;
+	else
+		falsealm_cnt->cnt_all =3D falsealm_cnt->cnt_ofdm_fail;
+
+	/*reset OFDM FA coutner*/
+	rtl_set_bbreg(hw, ODM_REG_OFDM_FA_RST_11AC, BIT(17), 1);
+	rtl_set_bbreg(hw, ODM_REG_OFDM_FA_RST_11AC, BIT(17), 0);
+	/* reset CCK FA counter*/
+	rtl_set_bbreg(hw, ODM_REG_CCK_FA_RST_11AC, BIT(15), 0);
+	rtl_set_bbreg(hw, ODM_REG_CCK_FA_RST_11AC, BIT(15), 1);
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "Cnt_Cck_fail=3D%d\n",
+		 falsealm_cnt->cnt_cck_fail);
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "cnt_ofdm_fail=3D%d\n",
+		 falsealm_cnt->cnt_ofdm_fail);
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "Total False Alarm=3D%d\n",
+		 falsealm_cnt->cnt_all);
+}
+
+static void rtl8812ae_dm_check_txpower_tracking_thermalmeter(
+		struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	static u8 tm_trigger;
+
+	if (!tm_trigger) {
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_T_METER_88E,
+			      BIT(17) | BIT(16), 0x03);
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "Trigger 8812 Thermal Meter!!\n");
+		tm_trigger =3D 1;
+		return;
+	}
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "Schedule TxPowerTracking direct call!!\n");
+	rtl8812ae_dm_txpower_tracking_callback_thermalmeter(hw);
+	tm_trigger =3D 0;
+}
+
+static void rtl8821ae_dm_iq_calibrate(struct ieee80211_hw *hw)
+{
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	if (mac->link_state >=3D MAC80211_LINKED) {
+		if (rtldm->linked_interval < 3)
+			rtldm->linked_interval++;
+
+		if (rtldm->linked_interval =3D=3D 2) {
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+				rtl8812ae_phy_iq_calibrate(hw, false);
+			else
+				rtl8821ae_phy_iq_calibrate(hw, false);
+		}
+	} else {
+		rtldm->linked_interval =3D 0;
+	}
+}
+
+static void rtl8812ae_get_delta_swing_table(struct ieee80211_hw *hw,
+					    u8 **up_a, u8 **down_a,
+					    u8 **up_b, u8 **down_b)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	u8 channel =3D rtlphy->current_channel;
+	u8 rate =3D rtldm->tx_rate;
+
+	if (1 <=3D channel && channel <=3D 14) {
+		if (RTL8821AE_RX_HAL_IS_CCK_RATE(rate)) {
+			*up_a =3D rtl8812ae_delta_swing_table_idx_24gccka_p;
+			*down_a =3D rtl8812ae_delta_swing_table_idx_24gccka_n;
+			*up_b =3D rtl8812ae_delta_swing_table_idx_24gcckb_p;
+			*down_b =3D rtl8812ae_delta_swing_table_idx_24gcckb_n;
+		} else {
+			*up_a =3D rtl8812ae_delta_swing_table_idx_24ga_p;
+			*down_a =3D rtl8812ae_delta_swing_table_idx_24ga_n;
+			*up_b =3D rtl8812ae_delta_swing_table_idx_24gb_p;
+			*down_b =3D rtl8812ae_delta_swing_table_idx_24gb_n;
+		}
+	} else if (36 <=3D channel && channel <=3D 64) {
+		*up_a =3D rtl8812ae_delta_swing_table_idx_5ga_p[0];
+		*down_a =3D rtl8812ae_delta_swing_table_idx_5ga_n[0];
+		*up_b =3D rtl8812ae_delta_swing_table_idx_5gb_p[0];
+		*down_b =3D rtl8812ae_delta_swing_table_idx_5gb_n[0];
+	} else if (100 <=3D channel && channel <=3D 140) {
+		*up_a =3D rtl8812ae_delta_swing_table_idx_5ga_p[1];
+		*down_a =3D rtl8812ae_delta_swing_table_idx_5ga_n[1];
+		*up_b =3D rtl8812ae_delta_swing_table_idx_5gb_p[1];
+		*down_b =3D rtl8812ae_delta_swing_table_idx_5gb_n[1];
+	} else if (149 <=3D channel && channel <=3D 173) {
+		*up_a =3D rtl8812ae_delta_swing_table_idx_5ga_p[2];
+		*down_a =3D rtl8812ae_delta_swing_table_idx_5ga_n[2];
+		*up_b =3D rtl8812ae_delta_swing_table_idx_5gb_p[2];
+		*down_b =3D rtl8812ae_delta_swing_table_idx_5gb_n[2];
+	} else {
+	    *up_a =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_p;
+	    *down_a =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_n;
+	    *up_b =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_p;
+	    *down_b =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_n;
+	}
+}
+
+void rtl8821ae_dm_update_init_rate(struct ieee80211_hw *hw, u8 rate)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 p =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "Get C2H Command! Rate=3D0x%x\n", rate);
+
+	rtldm->tx_rate =3D rate;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		rtl8821ae_dm_txpwr_track_set_pwr(hw, MIX_MODE, RF90_PATH_A, 0);
+	} else {
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++)
+			rtl8812ae_dm_txpwr_track_set_pwr(hw, MIX_MODE, p, 0);
+	}
+}
+
+u8 rtl8821ae_hw_rate_to_mrate(struct ieee80211_hw *hw, u8 rate)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 ret_rate =3D MGN_1M;
+
+	switch (rate) {
+	case DESC_RATE1M:
+		ret_rate =3D MGN_1M;
+		break;
+	case DESC_RATE2M:
+		ret_rate =3D MGN_2M;
+		break;
+	case DESC_RATE5_5M:
+		ret_rate =3D MGN_5_5M;
+		break;
+	case DESC_RATE11M:
+		ret_rate =3D MGN_11M;
+		break;
+	case DESC_RATE6M:
+		ret_rate =3D MGN_6M;
+		break;
+	case DESC_RATE9M:
+		ret_rate =3D MGN_9M;
+		break;
+	case DESC_RATE12M:
+		ret_rate =3D MGN_12M;
+		break;
+	case DESC_RATE18M:
+		ret_rate =3D MGN_18M;
+		break;
+	case DESC_RATE24M:
+		ret_rate =3D MGN_24M;
+		break;
+	case DESC_RATE36M:
+		ret_rate =3D MGN_36M;
+		break;
+	case DESC_RATE48M:
+		ret_rate =3D MGN_48M;
+		break;
+	case DESC_RATE54M:
+		ret_rate =3D MGN_54M;
+		break;
+	case DESC_RATEMCS0:
+		ret_rate =3D MGN_MCS0;
+		break;
+	case DESC_RATEMCS1:
+		ret_rate =3D MGN_MCS1;
+		break;
+	case DESC_RATEMCS2:
+		ret_rate =3D MGN_MCS2;
+		break;
+	case DESC_RATEMCS3:
+		ret_rate =3D MGN_MCS3;
+		break;
+	case DESC_RATEMCS4:
+		ret_rate =3D MGN_MCS4;
+		break;
+	case DESC_RATEMCS5:
+		ret_rate =3D MGN_MCS5;
+		break;
+	case DESC_RATEMCS6:
+		ret_rate =3D MGN_MCS6;
+		break;
+	case DESC_RATEMCS7:
+		ret_rate =3D MGN_MCS7;
+		break;
+	case DESC_RATEMCS8:
+		ret_rate =3D MGN_MCS8;
+		break;
+	case DESC_RATEMCS9:
+		ret_rate =3D MGN_MCS9;
+		break;
+	case DESC_RATEMCS10:
+		ret_rate =3D MGN_MCS10;
+		break;
+	case DESC_RATEMCS11:
+		ret_rate =3D MGN_MCS11;
+		break;
+	case DESC_RATEMCS12:
+		ret_rate =3D MGN_MCS12;
+		break;
+	case DESC_RATEMCS13:
+		ret_rate =3D MGN_MCS13;
+		break;
+	case DESC_RATEMCS14:
+		ret_rate =3D MGN_MCS14;
+		break;
+	case DESC_RATEMCS15:
+		ret_rate =3D MGN_MCS15;
+		break;
+	case DESC_RATEVHT1SS_MCS0:
+		ret_rate =3D MGN_VHT1SS_MCS0;
+		break;
+	case DESC_RATEVHT1SS_MCS1:
+		ret_rate =3D MGN_VHT1SS_MCS1;
+		break;
+	case DESC_RATEVHT1SS_MCS2:
+		ret_rate =3D MGN_VHT1SS_MCS2;
+		break;
+	case DESC_RATEVHT1SS_MCS3:
+		ret_rate =3D MGN_VHT1SS_MCS3;
+		break;
+	case DESC_RATEVHT1SS_MCS4:
+		ret_rate =3D MGN_VHT1SS_MCS4;
+		break;
+	case DESC_RATEVHT1SS_MCS5:
+		ret_rate =3D MGN_VHT1SS_MCS5;
+		break;
+	case DESC_RATEVHT1SS_MCS6:
+		ret_rate =3D MGN_VHT1SS_MCS6;
+		break;
+	case DESC_RATEVHT1SS_MCS7:
+		ret_rate =3D MGN_VHT1SS_MCS7;
+		break;
+	case DESC_RATEVHT1SS_MCS8:
+		ret_rate =3D MGN_VHT1SS_MCS8;
+		break;
+	case DESC_RATEVHT1SS_MCS9:
+		ret_rate =3D MGN_VHT1SS_MCS9;
+		break;
+	case DESC_RATEVHT2SS_MCS0:
+		ret_rate =3D MGN_VHT2SS_MCS0;
+		break;
+	case DESC_RATEVHT2SS_MCS1:
+		ret_rate =3D MGN_VHT2SS_MCS1;
+		break;
+	case DESC_RATEVHT2SS_MCS2:
+		ret_rate =3D MGN_VHT2SS_MCS2;
+		break;
+	case DESC_RATEVHT2SS_MCS3:
+		ret_rate =3D MGN_VHT2SS_MCS3;
+		break;
+	case DESC_RATEVHT2SS_MCS4:
+		ret_rate =3D MGN_VHT2SS_MCS4;
+		break;
+	case DESC_RATEVHT2SS_MCS5:
+		ret_rate =3D MGN_VHT2SS_MCS5;
+		break;
+	case DESC_RATEVHT2SS_MCS6:
+		ret_rate =3D MGN_VHT2SS_MCS6;
+		break;
+	case DESC_RATEVHT2SS_MCS7:
+		ret_rate =3D MGN_VHT2SS_MCS7;
+		break;
+	case DESC_RATEVHT2SS_MCS8:
+		ret_rate =3D MGN_VHT2SS_MCS8;
+		break;
+	case DESC_RATEVHT2SS_MCS9:
+		ret_rate =3D MGN_VHT2SS_MCS9;
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "HwRateToMRate8812(): Non supported Rate [%x]!!!\n",
+			 rate);
+		break;
+	}
+	return ret_rate;
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	odm_TxPwrTrackSetPwr88E()
+ *
+ * Overview:	88E change all channel tx power accordign to flag.
+ *				OFDM & CCK are all different.
+ *
+ * Input:		NONE
+ *
+ * Output:		NONE
+ *
+ * Return:		NONE
+ *
+ * Revised History:
+ *	When		Who		Remark
+ *	04/23/2012	MHC		Create Version 0.
+ *
+ *--------------------------------------------------------------------=
-------
+ */
+void rtl8812ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
+				      enum pwr_track_control_method method,
+				      u8 rf_path, u8 channel_mapped_index)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u32 final_swing_idx[2];
+	u8 pwr_tracking_limit =3D 26; /*+1.0dB*/
+	u8 tx_rate =3D 0xFF;
+	char final_ofdm_swing_index =3D 0;
+
+	if (rtldm->tx_rate !=3D 0xFF)
+		tx_rate =3D
+			rtl8821ae_hw_rate_to_mrate(hw, rtldm->tx_rate);
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+	/*20130429 Mimic Modify High Rate BBSwing Limit.*/
+	if (tx_rate !=3D 0xFF) {
+		/*CCK*/
+		if ((tx_rate >=3D MGN_1M) && (tx_rate <=3D MGN_11M))
+			pwr_tracking_limit =3D 32; /*+4dB*/
+		/*OFDM*/
+		else if ((tx_rate >=3D MGN_6M) && (tx_rate <=3D MGN_48M))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		else if (tx_rate =3D=3D MGN_54M)
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		/*HT*/
+		 /*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_MCS0) && (tx_rate <=3D MGN_MCS2))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		 /*16QAM*/
+		else if ((tx_rate >=3D MGN_MCS3) && (tx_rate <=3D MGN_MCS4))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		 /*64QAM*/
+		else if ((tx_rate >=3D MGN_MCS5) && (tx_rate <=3D MGN_MCS7))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		 /*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_MCS8) && (tx_rate <=3D MGN_MCS10))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		 /*16QAM*/
+		else if ((tx_rate >=3D MGN_MCS11) && (tx_rate <=3D MGN_MCS12))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		 /*64QAM*/
+		else if ((tx_rate >=3D MGN_MCS13) && (tx_rate <=3D MGN_MCS15))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+
+		/*2 VHT*/
+		 /*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS0) &&
+			 (tx_rate <=3D MGN_VHT1SS_MCS2))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		 /*16QAM*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS3) &&
+			 (tx_rate <=3D MGN_VHT1SS_MCS4))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		 /*64QAM*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS5) &&
+			 (tx_rate <=3D MGN_VHT1SS_MCS6))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS7) /*64QAM*/
+			pwr_tracking_limit =3D 26; /*+1dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS8) /*256QAM*/
+			pwr_tracking_limit =3D 24; /*+0dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS9) /*256QAM*/
+			pwr_tracking_limit =3D 22; /*-1dB*/
+		 /*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_VHT2SS_MCS0) &&
+			 (tx_rate <=3D MGN_VHT2SS_MCS2))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		 /*16QAM*/
+		else if ((tx_rate >=3D MGN_VHT2SS_MCS3) &&
+			 (tx_rate <=3D MGN_VHT2SS_MCS4))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		 /*64QAM*/
+		else if ((tx_rate >=3D MGN_VHT2SS_MCS5) &&
+			 (tx_rate <=3D MGN_VHT2SS_MCS6))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		else if (tx_rate =3D=3D MGN_VHT2SS_MCS7) /*64QAM*/
+			pwr_tracking_limit =3D 26; /*+1dB*/
+		else if (tx_rate =3D=3D MGN_VHT2SS_MCS8) /*256QAM*/
+			pwr_tracking_limit =3D 24; /*+0dB*/
+		else if (tx_rate =3D=3D MGN_VHT2SS_MCS9) /*256QAM*/
+			pwr_tracking_limit =3D 22; /*-1dB*/
+		else
+			pwr_tracking_limit =3D 24;
+	}
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "TxRate=3D0x%x, PwrTrackingLimit=3D%d\n",
+		 tx_rate, pwr_tracking_limit);
+
+	if (method =3D=3D BBSWING) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+
+		if (rf_path =3D=3D RF90_PATH_A) {
+			u32 tmp;
+
+			final_swing_idx[RF90_PATH_A] =3D
+				(rtldm->ofdm_index[RF90_PATH_A] >
+				pwr_tracking_limit) ?
+				pwr_tracking_limit :
+				rtldm->ofdm_index[RF90_PATH_A];
+			tmp =3D final_swing_idx[RF90_PATH_A];
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "pDM_Odm->RFCalibrateInfo.OFDM_index[ODM_RF_PATH_A]=3D%d,pDM_Odm-=
>RealBbSwingIdx[ODM_RF_PATH_A]=3D%d\n",
+				 rtldm->ofdm_index[RF90_PATH_A],
+				 final_swing_idx[RF90_PATH_A]);
+
+			rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+				      txscaling_tbl[tmp]);
+		} else {
+			u32 tmp;
+
+			final_swing_idx[RF90_PATH_B] =3D
+				rtldm->ofdm_index[RF90_PATH_B] >
+				pwr_tracking_limit ?
+				pwr_tracking_limit :
+				rtldm->ofdm_index[RF90_PATH_B];
+			tmp =3D final_swing_idx[RF90_PATH_B];
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "pDM_Odm->RFCalibrateInfo.OFDM_index[ODM_RF_PATH_B]=3D%d, pDM_Odm=
->RealBbSwingIdx[ODM_RF_PATH_B]=3D%d\n",
+				 rtldm->ofdm_index[RF90_PATH_B],
+				 final_swing_idx[RF90_PATH_B]);
+
+			rtl_set_bbreg(hw, RB_TXSCALE, 0xFFE00000,
+				      txscaling_tbl[tmp]);
+		}
+	} else if (method =3D=3D MIX_MODE) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "pDM_Odm->DefaultOfdmIndex=3D%d, pDM_Odm->Aboslute_OFDMSwingIdx[RF=
Path]=3D%d, RF_Path =3D %d\n",
+			 rtldm->default_ofdm_index,
+			 rtldm->absolute_ofdm_swing_idx[rf_path],
+			 rf_path);
+
+		final_ofdm_swing_index =3D rtldm->default_ofdm_index +
+				rtldm->absolute_ofdm_swing_idx[rf_path];
+
+		if (rf_path =3D=3D RF90_PATH_A) {
+			/*BBSwing higher then Limit*/
+			if (final_ofdm_swing_index > pwr_tracking_limit) {
+				rtldm->remnant_cck_idx =3D
+					final_ofdm_swing_index -
+					pwr_tracking_limit;
+				/* CCK Follow the same compensation value
+				 * as Path A
+				 */
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index -
+					pwr_tracking_limit;
+
+				rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+					      txscaling_tbl[pwr_tracking_limit]);
+
+				rtldm->modify_txagc_flag_path_a =3D true;
+
+				/*Set TxAGC Page C{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel,
+					RF90_PATH_A);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_A Over BBSwing Limit ,PwrTrackingLimit =3D %d ,Remna=
nt TxAGC Value =3D %d\n",
+					 pwr_tracking_limit,
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else if (final_ofdm_swing_index < 0) {
+				rtldm->remnant_cck_idx =3D final_ofdm_swing_index;
+				/* CCK Follow the same compensate value as Path A*/
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index;
+
+				rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+					txscaling_tbl[0]);
+
+				rtldm->modify_txagc_flag_path_a =3D true;
+
+				/*Set TxAGC Page C{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel, RF90_PATH_A);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_A Lower then BBSwing lower bound  0 , Remnant TxAGC =
Value =3D %d\n",
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else {
+				rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+					txscaling_tbl[(u8)final_ofdm_swing_index]);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_A Compensate with BBSwing, Final_OFDM_Swing_Index =3D=
 %d\n",
+					final_ofdm_swing_index);
+				/*If TxAGC has changed, reset TxAGC again*/
+				if (rtldm->modify_txagc_flag_path_a) {
+					rtldm->remnant_cck_idx =3D 0;
+					rtldm->remnant_ofdm_swing_idx[rf_path] =3D 0;
+
+					/*Set TxAGC Page C{};*/
+					rtl8821ae_phy_set_txpower_level_by_path(hw,
+						rtlphy->current_channel, RF90_PATH_A);
+					rtldm->modify_txagc_flag_path_a =3D false;
+
+					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
+						 DBG_LOUD,
+						 "******Path_A pDM_Odm->Modify_TxAGC_Flag =3D FALSE\n");
+				}
+			}
+		}
+		/*BBSwing higher then Limit*/
+		if (rf_path =3D=3D RF90_PATH_B) {
+			if (final_ofdm_swing_index > pwr_tracking_limit) {
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index -
+					pwr_tracking_limit;
+
+				rtl_set_bbreg(hw, RB_TXSCALE,
+					0xFFE00000,
+					txscaling_tbl[pwr_tracking_limit]);
+
+				rtldm->modify_txagc_flag_path_b =3D true;
+
+				/*Set TxAGC Page E{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel, RF90_PATH_B);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_B Over BBSwing Limit , PwrTrackingLimit =3D %d , Rem=
nant TxAGC Value =3D %d\n",
+					 pwr_tracking_limit,
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else if (final_ofdm_swing_index < 0) {
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index;
+
+				rtl_set_bbreg(hw, RB_TXSCALE, 0xFFE00000,
+					      txscaling_tbl[0]);
+
+				rtldm->modify_txagc_flag_path_b =3D true;
+
+				/*Set TxAGC Page E{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel, RF90_PATH_B);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_B Lower then BBSwing lower bound  0 , Remnant TxAGC =
Value =3D %d\n",
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else {
+				rtl_set_bbreg(hw, RB_TXSCALE, 0xFFE00000,
+					txscaling_tbl[(u8)final_ofdm_swing_index]);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_B Compensate with BBSwing ,Final_OFDM_Swing_Index =3D=
 %d\n",
+					final_ofdm_swing_index);
+				 /*If TxAGC has changed, reset TxAGC again*/
+				if (rtldm->modify_txagc_flag_path_b) {
+					rtldm->remnant_ofdm_swing_idx[rf_path] =3D 0;
+
+					/*Set TxAGC Page E{};*/
+					rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel, RF90_PATH_B);
+
+					rtldm->modify_txagc_flag_path_b =3D
+						false;
+
+					RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+						 "******Path_B pDM_Odm->Modify_TxAGC_Flag =3D FALSE\n");
+				}
+			}
+		}
+	} else {
+		return;
+	}
+}
+
+void rtl8812ae_dm_txpower_tracking_callback_thermalmeter(
+	struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 thermal_value =3D 0, delta, delta_lck, delta_iqk, p =3D 0, i =3D 0=
;
+	u8 thermal_value_avg_count =3D 0;
+	u32 thermal_value_avg =3D 0;
+	/* OFDM BB Swing should be less than +3.0dB, */
+	u8 ofdm_min_index =3D 6;
+	 /* GetRightChnlPlaceforIQK(pHalData->CurrentChannel)*/
+	u8 index_for_channel =3D 0;
+	/* 1. The following TWO tables decide
+	 * the final index of OFDM/CCK swing table.
+	 */
+	u8 *delta_swing_table_idx_tup_a;
+	u8 *delta_swing_table_idx_tdown_a;
+	u8 *delta_swing_table_idx_tup_b;
+	u8 *delta_swing_table_idx_tdown_b;
+
+	/*2. Initilization ( 7 steps in total )*/
+	rtl8812ae_get_delta_swing_table(hw,
+		(u8 **)&delta_swing_table_idx_tup_a,
+		(u8 **)&delta_swing_table_idx_tdown_a,
+		(u8 **)&delta_swing_table_idx_tup_b,
+		(u8 **)&delta_swing_table_idx_tdown_b);
+
+	rtldm->txpower_trackinginit =3D true;
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "pDM_Odm->BbSwingIdxCckBase: %d, pDM_Odm->BbSwingIdxOfdmBase[A]:%d,=
 pDM_Odm->DefaultOfdmIndex: %d\n",
+		 rtldm->swing_idx_cck_base,
+		 rtldm->swing_idx_ofdm_base[RF90_PATH_A],
+		 rtldm->default_ofdm_index);
+
+	thermal_value =3D (u8)rtl_get_rfreg(hw, RF90_PATH_A,
+		/*0x42: RF Reg[15:10] 88E*/
+		RF_T_METER_8812A, 0xfc00);
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "Thermal Meter =3D 0x%X, EFUSE Thermal Base =3D 0x%X\n",
+		 thermal_value, rtlefuse->eeprom_thermalmeter);
+	if (!rtldm->txpower_track_control ||
+	    rtlefuse->eeprom_thermalmeter =3D=3D 0 ||
+	    rtlefuse->eeprom_thermalmeter =3D=3D 0xFF)
+		return;
+
+	/* 3. Initialize ThermalValues of RFCalibrateInfo*/
+
+	if (rtlhal->reloadtxpowerindex)
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "reload ofdm index for band switch\n");
+
+	/*4. Calculate average thermal meter*/
+	rtldm->thermalvalue_avg[rtldm->thermalvalue_avg_index] =3D thermal_va=
lue;
+	rtldm->thermalvalue_avg_index++;
+	if (rtldm->thermalvalue_avg_index =3D=3D AVG_THERMAL_NUM_8812A)
+		/*Average times =3D  c.AverageThermalNum*/
+		rtldm->thermalvalue_avg_index =3D 0;
+
+	for (i =3D 0; i < AVG_THERMAL_NUM_8812A; i++) {
+		if (rtldm->thermalvalue_avg[i]) {
+			thermal_value_avg +=3D rtldm->thermalvalue_avg[i];
+			thermal_value_avg_count++;
+		}
+	}
+	/*Calculate Average ThermalValue after average enough times*/
+	if (thermal_value_avg_count) {
+		thermal_value =3D (u8)(thermal_value_avg /
+				thermal_value_avg_count);
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "AVG Thermal Meter =3D 0x%X, EFUSE Thermal Base =3D 0x%X\n",
+			 thermal_value, rtlefuse->eeprom_thermalmeter);
+	}
+
+	/*5. Calculate delta, delta_LCK, delta_IQK.
+	 *"delta" here is used to determine whether
+	 *thermal value changes or not.
+	 */
+	delta =3D (thermal_value > rtldm->thermalvalue) ?
+		(thermal_value - rtldm->thermalvalue) :
+		(rtldm->thermalvalue - thermal_value);
+	delta_lck =3D (thermal_value > rtldm->thermalvalue_lck) ?
+		(thermal_value - rtldm->thermalvalue_lck) :
+		(rtldm->thermalvalue_lck - thermal_value);
+	delta_iqk =3D (thermal_value > rtldm->thermalvalue_iqk) ?
+		(thermal_value - rtldm->thermalvalue_iqk) :
+		(rtldm->thermalvalue_iqk - thermal_value);
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "(delta, delta_LCK, delta_IQK) =3D (%d, %d, %d)\n",
+		 delta, delta_lck, delta_iqk);
+
+	/* 6. If necessary, do LCK.
+	 * Delta temperature is equal to or larger than 20 centigrade.
+	 */
+	if (delta_lck >=3D IQK_THRESHOLD) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "delta_LCK(%d) >=3D Threshold_IQK(%d)\n",
+			 delta_lck, IQK_THRESHOLD);
+		rtldm->thermalvalue_lck =3D thermal_value;
+		rtl8821ae_phy_lc_calibrate(hw);
+	}
+
+	/*7. If necessary, move the index of swing table to adjust Tx power.*=
/
+
+	if (delta > 0 && rtldm->txpower_track_control) {
+		/* "delta" here is used to record the
+		 * absolute value of differrence.
+		 */
+		delta =3D thermal_value > rtlefuse->eeprom_thermalmeter ?
+			(thermal_value - rtlefuse->eeprom_thermalmeter) :
+			(rtlefuse->eeprom_thermalmeter - thermal_value);
+
+		if (delta >=3D TXPWR_TRACK_TABLE_SIZE)
+			delta =3D TXPWR_TRACK_TABLE_SIZE - 1;
+
+		/*7.1 The Final Power Index =3D BaseIndex + PowerIndexOffset*/
+
+		if (thermal_value > rtlefuse->eeprom_thermalmeter) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "delta_swing_table_idx_tup_a[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tup_a[delta]);
+			rtldm->delta_power_index_last[RF90_PATH_A] =3D
+				rtldm->delta_power_index[RF90_PATH_A];
+			rtldm->delta_power_index[RF90_PATH_A] =3D
+				delta_swing_table_idx_tup_a[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_A] =3D
+				delta_swing_table_idx_tup_a[delta];
+			/*Record delta swing for mix mode power tracking*/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is higher and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_P=
ATH_A] =3D %d\n",
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_A]);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "delta_swing_table_idx_tup_b[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tup_b[delta]);
+			rtldm->delta_power_index_last[RF90_PATH_B] =3D
+				rtldm->delta_power_index[RF90_PATH_B];
+			rtldm->delta_power_index[RF90_PATH_B] =3D
+				delta_swing_table_idx_tup_b[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_B] =3D
+				delta_swing_table_idx_tup_b[delta];
+			/*Record delta swing for mix mode power tracking*/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is higher and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_P=
ATH_B] =3D %d\n",
+				 rtldm->absolute_ofdm_swing_idx[RF90_PATH_B]);
+		} else {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "delta_swing_table_idx_tdown_a[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tdown_a[delta]);
+
+			rtldm->delta_power_index_last[RF90_PATH_A] =3D
+				rtldm->delta_power_index[RF90_PATH_A];
+			rtldm->delta_power_index[RF90_PATH_A] =3D
+				-1 * delta_swing_table_idx_tdown_a[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_A] =3D
+				-1 * delta_swing_table_idx_tdown_a[delta];
+			/* Record delta swing for mix mode power tracking*/
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is lower and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_PA=
TH_A] =3D %d\n",
+				 rtldm->absolute_ofdm_swing_idx[RF90_PATH_A]);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "deltaSwingTableIdx_TDOWN_B[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tdown_b[delta]);
+
+			rtldm->delta_power_index_last[RF90_PATH_B] =3D
+				rtldm->delta_power_index[RF90_PATH_B];
+			rtldm->delta_power_index[RF90_PATH_B] =3D
+				-1 * delta_swing_table_idx_tdown_b[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_B] =3D
+				-1 * delta_swing_table_idx_tdown_b[delta];
+			/*Record delta swing for mix mode power tracking*/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is lower and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_PA=
TH_B] =3D %d\n",
+				 rtldm->absolute_ofdm_swing_idx[RF90_PATH_B]);
+		}
+
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D [Path-%c]Calculating PowerIndexOffset =3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D\n",
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'));
+
+			if (rtldm->delta_power_index[p] =3D=3D
+				rtldm->delta_power_index_last[p])
+				/*If Thermal value changes but lookup
+				table value still the same*/
+				rtldm->power_index_offset[p] =3D 0;
+			else
+				rtldm->power_index_offset[p] =3D
+					rtldm->delta_power_index[p] -
+					rtldm->delta_power_index_last[p];
+				/* Power Index Diff between 2
+				 * times Power Tracking
+				 */
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "[Path-%c] PowerIndexOffset(%d) =3DDeltaPowerIndex(%d) -DeltaPowe=
rIndexLast(%d)\n",
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+				 rtldm->power_index_offset[p],
+				 rtldm->delta_power_index[p] ,
+				 rtldm->delta_power_index_last[p]);
+
+			rtldm->ofdm_index[p] =3D
+					rtldm->swing_idx_ofdm_base[p] +
+					rtldm->power_index_offset[p];
+			rtldm->cck_index =3D
+					rtldm->swing_idx_cck_base +
+					rtldm->power_index_offset[p];
+
+			rtldm->swing_idx_cck =3D rtldm->cck_index;
+			rtldm->swing_idx_ofdm[p] =3D rtldm->ofdm_index[p];
+
+			/****Print BB Swing Base and Index Offset */
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "The 'CCK' final index(%d) =3D BaseIndex(%d) + PowerIndexOffset(%=
d)\n",
+				 rtldm->swing_idx_cck,
+				rtldm->swing_idx_cck_base,
+				rtldm->power_index_offset[p]);
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "The 'OFDM' final index(%d) =3D BaseIndex[%c](%d) + PowerIndexOff=
set(%d)\n",
+				 rtldm->swing_idx_ofdm[p],
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+				 rtldm->swing_idx_ofdm_base[p],
+				 rtldm->power_index_offset[p]);
+
+			/*7.1 Handle boundary conditions of index.*/
+
+			if (rtldm->ofdm_index[p] > TXSCALE_TABLE_SIZE - 1)
+				rtldm->ofdm_index[p] =3D TXSCALE_TABLE_SIZE - 1;
+			else if (rtldm->ofdm_index[p] < ofdm_min_index)
+				rtldm->ofdm_index[p] =3D ofdm_min_index;
+		}
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "\n\n=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
+		if (rtldm->cck_index > TXSCALE_TABLE_SIZE - 1)
+			rtldm->cck_index =3D TXSCALE_TABLE_SIZE - 1;
+		else if (rtldm->cck_index < 0)
+			rtldm->cck_index =3D 0;
+	} else {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "The thermal meter is unchanged or TxPowerTracking OFF(%d): Therma=
lValue: %d , pDM_Odm->RFCalibrateInfo.ThermalValue: %d\n",
+			 rtldm->txpower_track_control,
+			 thermal_value,
+			 rtldm->thermalvalue);
+
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++)
+			rtldm->power_index_offset[p] =3D 0;
+	}
+	/*Print Swing base & current*/
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "TxPowerTracking: [CCK] Swing Current Index: %d,Swing Base Index: %=
d\n",
+		 rtldm->cck_index, rtldm->swing_idx_cck_base);
+	for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "TxPowerTracking: [OFDM] Swing Current Index: %d,Swing Base Index[=
%c]: %d\n",
+			 rtldm->ofdm_index[p],
+			 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+			 rtldm->swing_idx_ofdm_base[p]);
+	}
+
+	if ((rtldm->power_index_offset[RF90_PATH_A] !=3D 0 ||
+		rtldm->power_index_offset[RF90_PATH_B] !=3D 0) &&
+		rtldm->txpower_track_control) {
+		/*7.2 Configure the Swing Table to adjust Tx Power.
+		 *Always TRUE after Tx Power is adjusted by power tracking.
+		 *
+		 *2012/04/23 MH According to Luke's suggestion,
+		 *we can not write BB digital
+		 *to increase TX power. Otherwise, EVM will be bad.
+		 *
+		 *2012/04/25 MH Add for tx power tracking to set
+		 *tx power in tx agc for 88E.
+		 */
+		if (thermal_value > rtldm->thermalvalue) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Increasing(A): delta_pi: %d , delta_t: %d, Now_t: %d=
,EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_A],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Increasing(B): delta_pi: %d ,delta_t: %d, Now_t: %d,=
 EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_B],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+		} else if (thermal_value < rtldm->thermalvalue) { /*Low temperature*=
/
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Decreasing(A): delta_pi: %d , delta_t: %d, Now_t: %d=
, EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_A],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Decreasing(B): delta_pi: %d , delta_t: %d, Now_t: %d=
, EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_B],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+		}
+
+		if (thermal_value > rtlefuse->eeprom_thermalmeter) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature(%d) higher than PG value(%d)\n",
+				 thermal_value, rtlefuse->eeprom_thermalmeter);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "**********Enter POWER Tracking MIX_MODE**********\n");
+			for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++)
+				rtl8812ae_dm_txpwr_track_set_pwr(hw, MIX_MODE,
+								 p, 0);
+		} else {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature(%d) lower than PG value(%d)\n",
+				 thermal_value, rtlefuse->eeprom_thermalmeter);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "**********Enter POWER Tracking MIX_MODE**********\n");
+			for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++)
+				rtl8812ae_dm_txpwr_track_set_pwr(hw, MIX_MODE,
+								 p, index_for_channel);
+		}
+		/*Record last time Power Tracking result as base.*/
+		rtldm->swing_idx_cck_base =3D rtldm->swing_idx_cck;
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8812A; p++)
+				rtldm->swing_idx_ofdm_base[p] =3D
+					rtldm->swing_idx_ofdm[p];
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "pDM_Odm->RFCalibrateInfo.ThermalValue =3D%d ThermalValue=3D %d\n=
",
+				 rtldm->thermalvalue, thermal_value);
+		/*Record last Power Tracking Thermal Value*/
+		rtldm->thermalvalue =3D thermal_value;
+	}
+	/*Delta temperature is equal to or larger than
+	20 centigrade (When threshold is 8).*/
+	if (delta_iqk >=3D IQK_THRESHOLD)
+		rtl8812ae_do_iqk(hw, delta_iqk, thermal_value, 8);
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "<=3D=3D=3Drtl8812ae_dm_txpower_tracking_callback_thermalmeter\n");
+}
+
+static void rtl8821ae_get_delta_swing_table(struct ieee80211_hw *hw, u=
8 **up_a,
+					    u8 **down_a, u8 **up_b, u8 **down_b)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	u8 channel =3D rtlphy->current_channel;
+	u8 rate =3D rtldm->tx_rate;
+
+	if (1 <=3D channel && channel <=3D 14) {
+		if (RTL8821AE_RX_HAL_IS_CCK_RATE(rate)) {
+			*up_a =3D rtl8821ae_delta_swing_table_idx_24gccka_p;
+			*down_a =3D rtl8821ae_delta_swing_table_idx_24gccka_n;
+			*up_b =3D rtl8821ae_delta_swing_table_idx_24gcckb_p;
+			*down_b =3D rtl8821ae_delta_swing_table_idx_24gcckb_n;
+		} else {
+			*up_a =3D rtl8821ae_delta_swing_table_idx_24ga_p;
+			*down_a =3D rtl8821ae_delta_swing_table_idx_24ga_n;
+			*up_b =3D rtl8821ae_delta_swing_table_idx_24gb_p;
+			*down_b =3D rtl8821ae_delta_swing_table_idx_24gb_n;
+		}
+	} else if (36 <=3D channel && channel <=3D 64) {
+		*up_a =3D rtl8821ae_delta_swing_table_idx_5ga_p[0];
+		*down_a =3D rtl8821ae_delta_swing_table_idx_5ga_n[0];
+		*up_b =3D rtl8821ae_delta_swing_table_idx_5gb_p[0];
+		*down_b =3D rtl8821ae_delta_swing_table_idx_5gb_n[0];
+	} else if (100 <=3D channel && channel <=3D 140) {
+		*up_a =3D rtl8821ae_delta_swing_table_idx_5ga_p[1];
+		*down_a =3D rtl8821ae_delta_swing_table_idx_5ga_n[1];
+		*up_b =3D rtl8821ae_delta_swing_table_idx_5gb_p[1];
+		*down_b =3D rtl8821ae_delta_swing_table_idx_5gb_n[1];
+	} else if (149 <=3D channel && channel <=3D 173) {
+		*up_a =3D rtl8821ae_delta_swing_table_idx_5ga_p[2];
+		*down_a =3D rtl8821ae_delta_swing_table_idx_5ga_n[2];
+		*up_b =3D rtl8821ae_delta_swing_table_idx_5gb_p[2];
+		*down_b =3D rtl8821ae_delta_swing_table_idx_5gb_n[2];
+	} else {
+	    *up_a =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_p;
+	    *down_a =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_n;
+	    *up_b =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_p;
+	    *down_b =3D (u8 *)rtl8818e_delta_swing_table_idx_24gb_n;
+	}
+	return;
+}
+
+/*--------------------------------------------------------------------=
---------
+ * Function:	odm_TxPwrTrackSetPwr88E()
+ *
+ * Overview:	88E change all channel tx power accordign to flag.
+ *				OFDM & CCK are all different.
+ *
+ * Input:		NONE
+ *
+ * Output:		NONE
+ *
+ * Return:		NONE
+ *
+ * Revised History:
+ *	When		Who		Remark
+ *	04/23/2012	MHC		Create Version 0.
+ *
+ *--------------------------------------------------------------------=
-------
+ */
+void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
+				      enum pwr_track_control_method method,
+				      u8 rf_path, u8 channel_mapped_index)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u32 final_swing_idx[1];
+	u8 pwr_tracking_limit =3D 26; /*+1.0dB*/
+	u8 tx_rate =3D 0xFF;
+	char final_ofdm_swing_index =3D 0;
+
+	if (rtldm->tx_rate !=3D 0xFF)
+		tx_rate =3D rtl8821ae_hw_rate_to_mrate(hw, rtldm->tx_rate);
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+
+	if (tx_rate !=3D 0xFF) { /* Mimic Modify High Rate BBSwing Limit.*/
+		/*CCK*/
+		if ((tx_rate >=3D MGN_1M) && (tx_rate <=3D MGN_11M))
+			pwr_tracking_limit =3D 32; /*+4dB*/
+		/*OFDM*/
+		else if ((tx_rate >=3D MGN_6M) && (tx_rate <=3D MGN_48M))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		else if (tx_rate =3D=3D MGN_54M)
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		/*HT*/
+		/*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_MCS0) && (tx_rate <=3D MGN_MCS2))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		/*16QAM*/
+		else if ((tx_rate >=3D MGN_MCS3) && (tx_rate <=3D MGN_MCS4))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		/*64QAM*/
+		else if ((tx_rate >=3D MGN_MCS5) && (tx_rate <=3D MGN_MCS7))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		/*2 VHT*/
+		/*QPSK/BPSK*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS0) &&
+			(tx_rate <=3D MGN_VHT1SS_MCS2))
+			pwr_tracking_limit =3D 34; /*+5dB*/
+		/*16QAM*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS3) &&
+			(tx_rate <=3D MGN_VHT1SS_MCS4))
+			pwr_tracking_limit =3D 30; /*+3dB*/
+		/*64QAM*/
+		else if ((tx_rate >=3D MGN_VHT1SS_MCS5) &&
+			(tx_rate <=3D MGN_VHT1SS_MCS6))
+			pwr_tracking_limit =3D 28; /*+2dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS7) /*64QAM*/
+			pwr_tracking_limit =3D 26; /*+1dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS8) /*256QAM*/
+			pwr_tracking_limit =3D 24; /*+0dB*/
+		else if (tx_rate =3D=3D MGN_VHT1SS_MCS9) /*256QAM*/
+			pwr_tracking_limit =3D 22; /*-1dB*/
+		else
+			pwr_tracking_limit =3D 24;
+	}
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "TxRate=3D0x%x, PwrTrackingLimit=3D%d\n",
+		 tx_rate, pwr_tracking_limit);
+
+	if (method =3D=3D BBSWING) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "=3D=3D=3D>rtl8812ae_dm_txpwr_track_set_pwr\n");
+		if (rf_path =3D=3D RF90_PATH_A) {
+			final_swing_idx[RF90_PATH_A] =3D
+				(rtldm->ofdm_index[RF90_PATH_A] >
+				pwr_tracking_limit) ?
+				pwr_tracking_limit :
+				rtldm->ofdm_index[RF90_PATH_A];
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "pDM_Odm->RFCalibrateInfo.OFDM_index[ODM_RF_PATH_A]=3D%d,pDM_Odm-=
>RealBbSwingIdx[ODM_RF_PATH_A]=3D%d\n",
+				 rtldm->ofdm_index[RF90_PATH_A],
+				 final_swing_idx[RF90_PATH_A]);
+
+			rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+				txscaling_tbl[final_swing_idx[RF90_PATH_A]]);
+		}
+	} else if (method =3D=3D MIX_MODE) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "pDM_Odm->DefaultOfdmIndex=3D%d,pDM_Odm->Aboslute_OFDMSwingIdx[RFP=
ath]=3D%d, RF_Path =3D %d\n",
+			 rtldm->default_ofdm_index,
+			 rtldm->absolute_ofdm_swing_idx[rf_path],
+			 rf_path);
+
+		final_ofdm_swing_index =3D
+			rtldm->default_ofdm_index +
+			rtldm->absolute_ofdm_swing_idx[rf_path];
+		/*BBSwing higher then Limit*/
+		if (rf_path =3D=3D RF90_PATH_A) {
+			if (final_ofdm_swing_index > pwr_tracking_limit) {
+				rtldm->remnant_cck_idx =3D
+					final_ofdm_swing_index -
+					pwr_tracking_limit;
+				/* CCK Follow the same compensate value as Path A*/
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index -
+					pwr_tracking_limit;
+
+				rtl_set_bbreg(hw, RA_TXSCALE,
+					0xFFE00000,
+					txscaling_tbl[pwr_tracking_limit]);
+
+				rtldm->modify_txagc_flag_path_a =3D true;
+
+				/*Set TxAGC Page C{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel,
+					RF90_PATH_A);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					" ******Path_A Over BBSwing Limit , PwrTrackingLimit =3D %d , Rem=
nant TxAGC Value =3D %d\n",
+					 pwr_tracking_limit,
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else if (final_ofdm_swing_index < 0) {
+				rtldm->remnant_cck_idx =3D final_ofdm_swing_index;
+				/* CCK Follow the same compensate value as Path A*/
+				rtldm->remnant_ofdm_swing_idx[rf_path] =3D
+					final_ofdm_swing_index;
+
+				rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+					txscaling_tbl[0]);
+
+				rtldm->modify_txagc_flag_path_a =3D true;
+
+				/*Set TxAGC Page C{};*/
+				rtl8821ae_phy_set_txpower_level_by_path(hw,
+					rtlphy->current_channel, RF90_PATH_A);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_A Lower then BBSwing lower bound  0 , Remnant TxAGC =
Value =3D %d\n",
+					 rtldm->remnant_ofdm_swing_idx[rf_path]);
+			} else {
+				rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+					txscaling_tbl[(u8)final_ofdm_swing_index]);
+
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "******Path_A Compensate with BBSwing ,Final_OFDM_Swing_Index =3D=
 %d\n",
+					 final_ofdm_swing_index);
+				/*If TxAGC has changed, reset TxAGC again*/
+				if (rtldm->modify_txagc_flag_path_a) {
+					rtldm->remnant_cck_idx =3D 0;
+					rtldm->remnant_ofdm_swing_idx[rf_path] =3D 0;
+
+					/*Set TxAGC Page C{};*/
+					rtl8821ae_phy_set_txpower_level_by_path(hw,
+						rtlphy->current_channel, RF90_PATH_A);
+
+					rtldm->modify_txagc_flag_path_a =3D false;
+
+					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
+						 DBG_LOUD,
+						 "******Path_A pDM_Odm->Modify_TxAGC_Flag=3D FALSE\n");
+				}
+			}
+		}
+	} else {
+		return;
+	}
+}
+
+void rtl8821ae_dm_txpower_tracking_callback_thermalmeter(
+	struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	u8 thermal_value =3D 0, delta, delta_lck, delta_iqk, p =3D 0, i =3D 0=
;
+	u8 thermal_value_avg_count =3D 0;
+	u32 thermal_value_avg =3D 0;
+
+	u8 ofdm_min_index =3D 6;  /*OFDM BB Swing should be less than +3.0dB =
*/
+	/* GetRightChnlPlaceforIQK(pHalData->CurrentChannel)*/
+	u8 index_for_channel =3D 0;
+
+	/* 1. The following TWO tables decide the final
+	 * index of OFDM/CCK swing table.
+	 */
+	u8 *delta_swing_table_idx_tup_a;
+	u8 *delta_swing_table_idx_tdown_a;
+	u8 *delta_swing_table_idx_tup_b;
+	u8 *delta_swing_table_idx_tdown_b;
+
+	/*2. Initilization ( 7 steps in total )*/
+	rtl8821ae_get_delta_swing_table(hw, (u8 **)&delta_swing_table_idx_tup=
_a,
+					(u8 **)&delta_swing_table_idx_tdown_a,
+					(u8 **)&delta_swing_table_idx_tup_b,
+					(u8 **)&delta_swing_table_idx_tdown_b);
+
+	rtldm->txpower_trackinginit =3D true;
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "=3D=3D=3D>rtl8812ae_dm_txpower_tracking_callback_thermalmeter,\n p=
DM_Odm->BbSwingIdxCckBase: %d,pDM_Odm->BbSwingIdxOfdmBase[A]:%d, pDM_Od=
m->DefaultOfdmIndex: %d\n",
+		 rtldm->swing_idx_cck_base,
+		 rtldm->swing_idx_ofdm_base[RF90_PATH_A],
+		 rtldm->default_ofdm_index);
+	/*0x42: RF Reg[15:10] 88E*/
+	thermal_value =3D (u8)rtl_get_rfreg(hw,
+		RF90_PATH_A, RF_T_METER_8812A, 0xfc00);
+	if (!rtldm->txpower_track_control ||
+		rtlefuse->eeprom_thermalmeter =3D=3D 0 ||
+		rtlefuse->eeprom_thermalmeter =3D=3D 0xFF)
+		return;
+
+	/* 3. Initialize ThermalValues of RFCalibrateInfo*/
+
+	if (rtlhal->reloadtxpowerindex) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "reload ofdm index for band switch\n");
+	}
+
+	/*4. Calculate average thermal meter*/
+	rtldm->thermalvalue_avg[rtldm->thermalvalue_avg_index] =3D thermal_va=
lue;
+	rtldm->thermalvalue_avg_index++;
+	if (rtldm->thermalvalue_avg_index =3D=3D AVG_THERMAL_NUM_8812A)
+		/*Average times =3D  c.AverageThermalNum*/
+		rtldm->thermalvalue_avg_index =3D 0;
+
+	for (i =3D 0; i < AVG_THERMAL_NUM_8812A; i++) {
+		if (rtldm->thermalvalue_avg[i]) {
+			thermal_value_avg +=3D rtldm->thermalvalue_avg[i];
+			thermal_value_avg_count++;
+		}
+	}
+	/*Calculate Average ThermalValue after average enough times*/
+	if (thermal_value_avg_count) {
+		thermal_value =3D (u8)(thermal_value_avg /
+				thermal_value_avg_count);
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "AVG Thermal Meter =3D 0x%X, EFUSE Thermal Base =3D 0x%X\n",
+			 thermal_value, rtlefuse->eeprom_thermalmeter);
+	}
+
+	/*5. Calculate delta, delta_LCK, delta_IQK.
+	 *"delta" here is used to determine whether
+	 * thermal value changes or not.
+	 */
+	delta =3D (thermal_value > rtldm->thermalvalue) ?
+		(thermal_value - rtldm->thermalvalue) :
+		(rtldm->thermalvalue - thermal_value);
+	delta_lck =3D (thermal_value > rtldm->thermalvalue_lck) ?
+		(thermal_value - rtldm->thermalvalue_lck) :
+		(rtldm->thermalvalue_lck - thermal_value);
+	delta_iqk =3D (thermal_value > rtldm->thermalvalue_iqk) ?
+		(thermal_value - rtldm->thermalvalue_iqk) :
+		(rtldm->thermalvalue_iqk - thermal_value);
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "(delta, delta_LCK, delta_IQK) =3D (%d, %d, %d)\n",
+		 delta, delta_lck, delta_iqk);
+
+	/* 6. If necessary, do LCK.	*/
+	/*Delta temperature is equal to or larger than 20 centigrade.*/
+	if (delta_lck >=3D IQK_THRESHOLD) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "delta_LCK(%d) >=3D Threshold_IQK(%d)\n",
+			 delta_lck, IQK_THRESHOLD);
+		rtldm->thermalvalue_lck =3D thermal_value;
+		rtl8821ae_phy_lc_calibrate(hw);
+	}
+
+	/*7. If necessary, move the index of swing table to adjust Tx power.*=
/
+
+	if (delta > 0 && rtldm->txpower_track_control) {
+		/*"delta" here is used to record the
+		 * absolute value of differrence.
+		 */
+		delta =3D thermal_value > rtlefuse->eeprom_thermalmeter ?
+			(thermal_value - rtlefuse->eeprom_thermalmeter) :
+			(rtlefuse->eeprom_thermalmeter - thermal_value);
+
+		if (delta >=3D TXSCALE_TABLE_SIZE)
+			delta =3D TXSCALE_TABLE_SIZE - 1;
+
+		/*7.1 The Final Power Index =3D BaseIndex + PowerIndexOffset*/
+
+		if (thermal_value > rtlefuse->eeprom_thermalmeter) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "delta_swing_table_idx_tup_a[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tup_a[delta]);
+			rtldm->delta_power_index_last[RF90_PATH_A] =3D
+				rtldm->delta_power_index[RF90_PATH_A];
+			rtldm->delta_power_index[RF90_PATH_A] =3D
+				delta_swing_table_idx_tup_a[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_A] =3D
+				delta_swing_table_idx_tup_a[delta];
+			/*Record delta swing for mix mode power tracking*/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is higher and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_P=
ATH_A] =3D %d\n",
+				 rtldm->absolute_ofdm_swing_idx[RF90_PATH_A]);
+		} else {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "delta_swing_table_idx_tdown_a[%d] =3D %d\n",
+				 delta, delta_swing_table_idx_tdown_a[delta]);
+
+			rtldm->delta_power_index_last[RF90_PATH_A] =3D
+				rtldm->delta_power_index[RF90_PATH_A];
+			rtldm->delta_power_index[RF90_PATH_A] =3D
+				-1 * delta_swing_table_idx_tdown_a[delta];
+
+			rtldm->absolute_ofdm_swing_idx[RF90_PATH_A] =3D
+				-1 * delta_swing_table_idx_tdown_a[delta];
+			/* Record delta swing for mix mode power tracking*/
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "******Temp is lower and pDM_Odm->Aboslute_OFDMSwingIdx[ODM_RF_PA=
TH_A] =3D %d\n",
+				 rtldm->absolute_ofdm_swing_idx[RF90_PATH_A]);
+		}
+
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "\n\n=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D [Path-%c]Calculating PowerIndexOff=
set =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D\n",
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'));
+			/*If Thermal value changes but lookup table value
+			 * still the same
+			 */
+			if (rtldm->delta_power_index[p] =3D=3D
+				rtldm->delta_power_index_last[p])
+
+				rtldm->power_index_offset[p] =3D 0;
+			else
+				rtldm->power_index_offset[p] =3D
+					rtldm->delta_power_index[p] -
+					rtldm->delta_power_index_last[p];
+			/*Power Index Diff between 2 times Power Tracking*/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "[Path-%c] PowerIndexOffset(%d) =3D DeltaPowerIndex(%d) - DeltaPo=
werIndexLast(%d)\n",
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+				rtldm->power_index_offset[p],
+				rtldm->delta_power_index[p] ,
+				rtldm->delta_power_index_last[p]);
+
+			rtldm->ofdm_index[p] =3D
+					rtldm->swing_idx_ofdm_base[p] +
+					rtldm->power_index_offset[p];
+			rtldm->cck_index =3D
+					rtldm->swing_idx_cck_base +
+					rtldm->power_index_offset[p];
+
+			rtldm->swing_idx_cck =3D rtldm->cck_index;
+			rtldm->swing_idx_ofdm[p] =3D rtldm->ofdm_index[p];
+
+			/*********Print BB Swing Base and Index Offset********/
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "The 'CCK' final index(%d) =3D BaseIndex(%d) + PowerIndexOffset(%=
d)\n",
+				 rtldm->swing_idx_cck,
+				 rtldm->swing_idx_cck_base,
+				 rtldm->power_index_offset[p]);
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "The 'OFDM' final index(%d) =3D BaseIndex[%c](%d) + PowerIndexOff=
set(%d)\n",
+				 rtldm->swing_idx_ofdm[p],
+				 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+				 rtldm->swing_idx_ofdm_base[p],
+				 rtldm->power_index_offset[p]);
+
+			/*7.1 Handle boundary conditions of index.*/
+
+			if (rtldm->ofdm_index[p] > TXSCALE_TABLE_SIZE - 1)
+				rtldm->ofdm_index[p] =3D TXSCALE_TABLE_SIZE - 1;
+			else if (rtldm->ofdm_index[p] < ofdm_min_index)
+				rtldm->ofdm_index[p] =3D ofdm_min_index;
+		}
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "\n\n=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
+		if (rtldm->cck_index > TXSCALE_TABLE_SIZE - 1)
+			rtldm->cck_index =3D TXSCALE_TABLE_SIZE - 1;
+		else if (rtldm->cck_index < 0)
+			rtldm->cck_index =3D 0;
+	} else {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "The thermal meter is unchanged or TxPowerTracking OFF(%d):Thermal=
Value: %d , pDM_Odm->RFCalibrateInfo.ThermalValue: %d\n",
+			 rtldm->txpower_track_control,
+			 thermal_value,
+			 rtldm->thermalvalue);
+
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++)
+			rtldm->power_index_offset[p] =3D 0;
+	}
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "TxPowerTracking: [CCK] Swing Current Index: %d, Swing Base Index: =
%d\n",
+		 /*Print Swing base & current*/
+		rtldm->cck_index, rtldm->swing_idx_cck_base);
+	for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++) {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "TxPowerTracking: [OFDM] Swing Current Index: %d, Swing Base Index=
[%c]: %d\n",
+			 rtldm->ofdm_index[p],
+			 (p =3D=3D RF90_PATH_A ? 'A' : 'B'),
+			 rtldm->swing_idx_ofdm_base[p]);
+	}
+
+	if ((rtldm->power_index_offset[RF90_PATH_A] !=3D 0 ||
+		rtldm->power_index_offset[RF90_PATH_B] !=3D 0) &&
+		rtldm->txpower_track_control) {
+		/*7.2 Configure the Swing Table to adjust Tx Power.*/
+		/*Always TRUE after Tx Power is adjusted by power tracking.*/
+		/*
+		 *  2012/04/23 MH According to Luke's suggestion,
+		 *  we can not write BB digital
+		 *  to increase TX power. Otherwise, EVM will be bad.
+		 *
+		 *  2012/04/25 MH Add for tx power tracking to
+		 *  set tx power in tx agc for 88E.
+		 */
+		if (thermal_value > rtldm->thermalvalue) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Increasing(A): delta_pi: %d , delta_t: %d,Now_t: %d,=
 EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_A],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+		} else if (thermal_value < rtldm->thermalvalue) { /*Low temperature*=
/
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature Decreasing(A): delta_pi: %d , delta_t: %d, Now_t: %d=
, EFUSE_t: %d, Last_t: %d\n",
+				 rtldm->power_index_offset[RF90_PATH_A],
+				 delta, thermal_value,
+				 rtlefuse->eeprom_thermalmeter,
+				 rtldm->thermalvalue);
+		}
+
+		if (thermal_value > rtlefuse->eeprom_thermalmeter) {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature(%d) higher than PG value(%d)\n",
+				 thermal_value, rtlefuse->eeprom_thermalmeter);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "****Enter POWER Tracking MIX_MODE****\n");
+			for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++)
+					rtl8821ae_dm_txpwr_track_set_pwr(hw,
+						MIX_MODE, p, index_for_channel);
+		} else {
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "Temperature(%d) lower than PG value(%d)\n",
+				 thermal_value, rtlefuse->eeprom_thermalmeter);
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "*****Enter POWER Tracking MIX_MODE*****\n");
+			for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++)
+				rtl8812ae_dm_txpwr_track_set_pwr(hw,
+					MIX_MODE, p, index_for_channel);
+		}
+		/*Record last time Power Tracking result as base.*/
+		rtldm->swing_idx_cck_base =3D rtldm->swing_idx_cck;
+		for (p =3D RF90_PATH_A; p < MAX_PATH_NUM_8821A; p++)
+			rtldm->swing_idx_ofdm_base[p] =3D rtldm->swing_idx_ofdm[p];
+
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+				 "pDM_Odm->RFCalibrateInfo.ThermalValue =3D %d ThermalValue=3D %d\=
n",
+				 rtldm->thermalvalue, thermal_value);
+		/*Record last Power Tracking Thermal Value*/
+		rtldm->thermalvalue =3D thermal_value;
+	}
+	/* Delta temperature is equal to or larger than
+	 * 20 centigrade (When threshold is 8).
+	 */
+	if (delta_iqk >=3D IQK_THRESHOLD) {
+		if (!rtlphy->lck_inprogress) {
+			spin_lock(&rtlpriv->locks.iqk_lock);
+			rtlphy->lck_inprogress =3D true;
+			spin_unlock(&rtlpriv->locks.iqk_lock);
+
+			rtl8821ae_do_iqk(hw, delta_iqk, thermal_value, 8);
+
+			spin_lock(&rtlpriv->locks.iqk_lock);
+			rtlphy->lck_inprogress =3D false;
+			spin_unlock(&rtlpriv->locks.iqk_lock);
+		}
+	}
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "<=3D=3D=3Drtl8812ae_dm_txpower_tracking_callback_thermalmeter\n");
+}
+
+void rtl8821ae_dm_check_txpower_tracking_thermalmeter(struct ieee80211=
_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	static u8 tm_trigger;
+
+	if (!tm_trigger) {
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_T_METER_88E, BIT(17)|BIT(16),
+			      0x03);
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "Trigger 8821ae Thermal Meter!!\n");
+		tm_trigger =3D 1;
+		return;
+	} else {
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			 "Schedule TxPowerTracking !!\n");
+
+		rtl8821ae_dm_txpower_tracking_callback_thermalmeter(hw);
+		tm_trigger =3D 0;
+	}
+}
+
+static void rtl8821ae_dm_refresh_rate_adaptive_mask(struct ieee80211_h=
w *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rate_adaptive *p_ra =3D &rtlpriv->ra;
+	u32 low_rssithresh_for_ra =3D p_ra->low2high_rssi_thresh_for_ra40m;
+	u32 high_rssithresh_for_ra =3D p_ra->high_rssi_thresh_for_ra;
+	u8 go_up_gap =3D 5;
+	struct ieee80211_sta *sta =3D NULL;
+
+	if (is_hal_stop(rtlhal)) {
+		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+			 "driver is going to unload\n");
+		return;
+	}
+
+	if (!rtlpriv->dm.useramask) {
+		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+			 "driver does not control rate adaptive mask\n");
+		return;
+	}
+
+	if (mac->link_state =3D=3D MAC80211_LINKED &&
+		mac->opmode =3D=3D NL80211_IFTYPE_STATION) {
+		switch (p_ra->pre_ratr_state) {
+		case DM_RATR_STA_MIDDLE:
+			high_rssithresh_for_ra +=3D go_up_gap;
+			break;
+		case DM_RATR_STA_LOW:
+			high_rssithresh_for_ra +=3D go_up_gap;
+			low_rssithresh_for_ra +=3D go_up_gap;
+			break;
+		default:
+			break;
+		}
+
+		if (rtlpriv->dm.undec_sm_pwdb >
+		    (long)high_rssithresh_for_ra)
+			p_ra->ratr_state =3D DM_RATR_STA_HIGH;
+		else if (rtlpriv->dm.undec_sm_pwdb >
+			 (long)low_rssithresh_for_ra)
+			p_ra->ratr_state =3D DM_RATR_STA_MIDDLE;
+		else
+			p_ra->ratr_state =3D DM_RATR_STA_LOW;
+
+		if (p_ra->pre_ratr_state !=3D p_ra->ratr_state) {
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "RSSI =3D %ld\n",
+				  rtlpriv->dm.undec_sm_pwdb);
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "RSSI_LEVEL =3D %d\n", p_ra->ratr_state);
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "PreState =3D %d, CurState =3D %d\n",
+				  p_ra->pre_ratr_state, p_ra->ratr_state);
+
+			rcu_read_lock();
+			sta =3D rtl_find_sta(hw, mac->bssid);
+			if (sta)
+				rtlpriv->cfg->ops->update_rate_tbl(hw,
+						sta, p_ra->ratr_state);
+			rcu_read_unlock();
+
+			p_ra->pre_ratr_state =3D p_ra->ratr_state;
+		}
+	}
+}
+
+static void rtl8821ae_dm_refresh_basic_rate_mask(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+	struct rtl_mac *mac =3D &rtlpriv->mac80211;
+	static u8 stage;
+	u8 cur_stage =3D 0;
+	u16 basic_rate =3D RRSR_1M | RRSR_2M | RRSR_5_5M | RRSR_11M | RRSR_6M=
;
+
+	if (mac->link_state < MAC80211_LINKED)
+		cur_stage =3D 0;
+	else if (dm_digtable->rssi_val_min < 25)
+		cur_stage =3D 1;
+	else if (dm_digtable->rssi_val_min > 30)
+		cur_stage =3D 3;
+	else
+		cur_stage =3D 2;
+
+	if (cur_stage !=3D stage) {
+		if (cur_stage =3D=3D 1) {
+			basic_rate &=3D (!(basic_rate ^ mac->basic_rates));
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_BASIC_RATE, (u8 *)&basic_rate);
+		} else if (cur_stage =3D=3D 3 && (stage =3D=3D 1 || stage =3D=3D 2))=
 {
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_BASIC_RATE, (u8 *)&mac->basic_rates);
+		}
+	}
+	stage =3D cur_stage;
+}
+
+static void rtl8821ae_dm_edca_choose_traffic_idx(
+	struct ieee80211_hw *hw, u64 cur_tx_bytes,
+	u64 cur_rx_bytes, bool b_bias_on_rx,
+	bool *pb_is_cur_rdl_state)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (b_bias_on_rx) {
+		if (cur_tx_bytes > (cur_rx_bytes*4)) {
+			*pb_is_cur_rdl_state =3D false;
+			RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+				 "Uplink Traffic\n ");
+		} else {
+			*pb_is_cur_rdl_state =3D true;
+			RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+				 "Balance Traffic\n");
+		}
+	} else {
+		if (cur_rx_bytes > (cur_tx_bytes*4)) {
+			*pb_is_cur_rdl_state =3D true;
+			RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+				 "Downlink	Traffic\n");
+		} else {
+			*pb_is_cur_rdl_state =3D false;
+			RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+				 "Balance Traffic\n");
+		}
+	}
+	return;
+}
+
+static void rtl8821ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_dm *rtldm =3D  rtl_dm(rtl_priv(hw));
+
+	/*Keep past Tx/Rx packet count for RT-to-RT EDCA turbo.*/
+	u64 cur_tx_ok_cnt =3D 0;
+	u64 cur_rx_ok_cnt =3D 0;
+	u32 edca_be_ul =3D 0x5ea42b;
+	u32 edca_be_dl =3D 0x5ea42b;
+	u32 edca_be =3D 0x5ea42b;
+	u8 iot_peer =3D 0;
+	bool *pb_is_cur_rdl_state =3D NULL;
+	bool b_last_is_cur_rdl_state =3D false;
+	bool b_bias_on_rx =3D false;
+	bool b_edca_turbo_on =3D false;
+
+	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+		 "rtl8821ae_dm_check_edca_turbo=3D=3D=3D=3D=3D>");
+	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+		 "Orginial BE PARAM: 0x%x\n",
+		 rtl_read_dword(rtlpriv, DM_REG_EDCA_BE_11N));
+
+	if (rtlpriv->dm.dbginfo.num_non_be_pkt > 0x100)
+		rtlpriv->dm.is_any_nonbepkts =3D true;
+	rtlpriv->dm.dbginfo.num_non_be_pkt =3D 0;
+
+	/*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
+	 * list paramter for different platform
+	 *=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
+	 */
+	b_last_is_cur_rdl_state =3D rtlpriv->dm.is_cur_rdlstate;
+	pb_is_cur_rdl_state =3D &rtlpriv->dm.is_cur_rdlstate;
+
+	cur_tx_ok_cnt =3D rtlpriv->stats.txbytesunicast - rtldm->last_tx_ok_c=
nt;
+	cur_rx_ok_cnt =3D rtlpriv->stats.rxbytesunicast - rtldm->last_rx_ok_c=
nt;
+
+	rtldm->last_tx_ok_cnt =3D rtlpriv->stats.txbytesunicast;
+	rtldm->last_rx_ok_cnt =3D rtlpriv->stats.rxbytesunicast;
+
+	iot_peer =3D rtlpriv->mac80211.vendor;
+	b_bias_on_rx =3D false;
+	b_edca_turbo_on =3D ((!rtlpriv->dm.is_any_nonbepkts) &&
+			   (!rtlpriv->dm.disable_framebursting)) ?
+			   true : false;
+
+	if (rtlpriv->rtlhal.hw_type !=3D HARDWARE_TYPE_RTL8812AE) {
+		if ((iot_peer =3D=3D PEER_CISCO) &&
+			(mac->mode =3D=3D WIRELESS_MODE_N_24G)) {
+			edca_be_dl =3D edca_setting_dl[iot_peer];
+			edca_be_ul =3D edca_setting_ul[iot_peer];
+		}
+	}
+
+	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+		 "bIsAnyNonBEPkts : 0x%x  bDisableFrameBursting : 0x%x\n",
+		 rtlpriv->dm.is_any_nonbepkts,
+		 rtlpriv->dm.disable_framebursting);
+
+	RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+		 "bEdcaTurboOn : 0x%x bBiasOnRx : 0x%x\n",
+		 b_edca_turbo_on, b_bias_on_rx);
+
+	if (b_edca_turbo_on) {
+		RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+			 "curTxOkCnt : 0x%llx\n", cur_tx_ok_cnt);
+		RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+			 "curRxOkCnt : 0x%llx\n", cur_rx_ok_cnt);
+		if (b_bias_on_rx)
+			rtl8821ae_dm_edca_choose_traffic_idx(hw, cur_tx_ok_cnt,
+				cur_rx_ok_cnt, true, pb_is_cur_rdl_state);
+		else
+			rtl8821ae_dm_edca_choose_traffic_idx(hw, cur_tx_ok_cnt,
+				cur_rx_ok_cnt, false, pb_is_cur_rdl_state);
+
+		edca_be =3D (*pb_is_cur_rdl_state) ?  edca_be_dl : edca_be_ul;
+
+		rtl_write_dword(rtlpriv, DM_REG_EDCA_BE_11N, edca_be);
+
+		RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+			 "EDCA Turbo on: EDCA_BE:0x%x\n", edca_be);
+
+		rtlpriv->dm.current_turbo_edca =3D true;
+
+		RT_TRACE(rtlpriv, COMP_TURBO, DBG_LOUD,
+			 "EDCA_BE_DL : 0x%x  EDCA_BE_UL : 0x%x  EDCA_BE : 0x%x\n",
+			 edca_be_dl, edca_be_ul, edca_be);
+	} else {
+		if (rtlpriv->dm.current_turbo_edca) {
+			u8 tmp =3D AC0_BE;
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      (u8 *)(&tmp));
+		}
+		rtlpriv->dm.current_turbo_edca =3D false;
+	}
+
+	rtlpriv->dm.is_any_nonbepkts =3D false;
+	rtldm->last_tx_ok_cnt =3D rtlpriv->stats.txbytesunicast;
+	rtldm->last_rx_ok_cnt =3D rtlpriv->stats.rxbytesunicast;
+}
+
+static void rtl8821ae_dm_cck_packet_detection_thresh(struct ieee80211_=
hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+	u8 cur_cck_cca_thresh;
+
+	if (rtlpriv->mac80211.link_state >=3D MAC80211_LINKED) {
+		if (dm_digtable->rssi_val_min > 25) {
+			cur_cck_cca_thresh =3D 0xcd;
+		} else if ((dm_digtable->rssi_val_min <=3D 25) &&
+			   (dm_digtable->rssi_val_min > 10)) {
+			cur_cck_cca_thresh =3D 0x83;
+		} else {
+			if (rtlpriv->falsealm_cnt.cnt_cck_fail > 1000)
+				cur_cck_cca_thresh =3D 0x83;
+			else
+				cur_cck_cca_thresh =3D 0x40;
+		}
+	} else {
+		if (rtlpriv->falsealm_cnt.cnt_cck_fail > 1000)
+			cur_cck_cca_thresh =3D 0x83;
+		else
+			cur_cck_cca_thresh =3D 0x40;
+	}
+
+	if (dm_digtable->cur_cck_cca_thres !=3D cur_cck_cca_thresh)
+		rtl_write_byte(rtlpriv, ODM_REG_CCK_CCA_11AC,
+			       cur_cck_cca_thresh);
+
+	dm_digtable->pre_cck_cca_thres =3D dm_digtable->cur_cck_cca_thres;
+	dm_digtable->cur_cck_cca_thres =3D cur_cck_cca_thresh;
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "CCK cca thresh hold =3D%x\n", dm_digtable->cur_cck_cca_thres);
+}
+
+static void rtl8821ae_dm_dynamic_atc_switch(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	u8 crystal_cap;
+	u32 packet_count;
+	int cfo_khz_a, cfo_khz_b, cfo_ave =3D 0, adjust_xtal =3D 0;
+	int cfo_ave_diff;
+
+	if (rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		/*1.Enable ATC*/
+		if (rtldm->atc_status =3D=3D ATC_STATUS_OFF) {
+			rtl_set_bbreg(hw, RFC_AREA, BIT(14), ATC_STATUS_ON);
+			rtldm->atc_status =3D ATC_STATUS_ON;
+		}
+
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "No link!!\n");
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "atc_status =3D %d\n", rtldm->atc_status);
+
+		if (rtldm->crystal_cap !=3D rtlpriv->efuse.crystalcap) {
+			rtldm->crystal_cap =3D rtlpriv->efuse.crystalcap;
+			crystal_cap =3D rtldm->crystal_cap & 0x3f;
+			crystal_cap =3D crystal_cap & 0x3f;
+			if (rtlpriv->rtlhal.hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+				rtl_set_bbreg(hw, REG_MAC_PHY_CTRL,
+					      0x7ff80000, (crystal_cap |
+					      (crystal_cap << 6)));
+			else
+				rtl_set_bbreg(hw, REG_MAC_PHY_CTRL,
+					      0xfff000, (crystal_cap |
+					      (crystal_cap << 6)));
+		}
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "crystal_cap =3D 0x%x\n",
+			 rtldm->crystal_cap);
+	} else{
+		/*1. Calculate CFO for path-A & path-B*/
+		cfo_khz_a =3D (int)(rtldm->cfo_tail[0] * 3125) / 1280;
+		cfo_khz_b =3D (int)(rtldm->cfo_tail[1] * 3125) / 1280;
+		packet_count =3D rtldm->packet_count;
+
+		/*2.No new packet*/
+		if (packet_count =3D=3D rtldm->packet_count_pre) {
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "packet counter doesn't change\n");
+			return;
+		}
+
+		rtldm->packet_count_pre =3D packet_count;
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "packet counter =3D %d\n",
+			 rtldm->packet_count);
+
+		/*3.Average CFO*/
+		if (rtlpriv->phy.rf_type =3D=3D RF_1T1R)
+			cfo_ave =3D cfo_khz_a;
+		else
+			cfo_ave =3D (cfo_khz_a + cfo_khz_b) >> 1;
+
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "cfo_khz_a =3D %dkHz, cfo_khz_b =3D %dkHz, cfo_ave =3D %dkHz\n",
+			 cfo_khz_a, cfo_khz_b, cfo_ave);
+
+		/*4.Avoid abnormal large CFO*/
+		cfo_ave_diff =3D (rtldm->cfo_ave_pre >=3D cfo_ave) ?
+						(rtldm->cfo_ave_pre - cfo_ave) :
+						(cfo_ave - rtldm->cfo_ave_pre);
+
+		if (cfo_ave_diff > 20 && rtldm->large_cfo_hit =3D=3D 0) {
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "first large CFO hit\n");
+			rtldm->large_cfo_hit =3D 1;
+			return;
+		} else
+			rtldm->large_cfo_hit =3D 0;
+
+		rtldm->cfo_ave_pre =3D cfo_ave;
+
+		/*CFO tracking by adjusting Xtal cap.*/
+
+		/*1.Dynamic Xtal threshold*/
+		if (cfo_ave >=3D -rtldm->cfo_threshold &&
+			cfo_ave <=3D rtldm->cfo_threshold &&
+			rtldm->is_freeze =3D=3D 0) {
+			if (rtldm->cfo_threshold =3D=3D CFO_THRESHOLD_XTAL) {
+				rtldm->cfo_threshold =3D CFO_THRESHOLD_XTAL + 10;
+				rtldm->is_freeze =3D 1;
+			} else {
+				rtldm->cfo_threshold =3D CFO_THRESHOLD_XTAL;
+			}
+		}
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "Dynamic threshold =3D %d\n",
+			 rtldm->cfo_threshold);
+
+		/* 2.Calculate Xtal offset*/
+		if (cfo_ave > rtldm->cfo_threshold && rtldm->crystal_cap < 0x3f)
+			adjust_xtal =3D ((cfo_ave - CFO_THRESHOLD_XTAL) >> 2) + 1;
+		else if ((cfo_ave < -rtlpriv->dm.cfo_threshold) &&
+			 rtlpriv->dm.crystal_cap > 0)
+			adjust_xtal =3D ((cfo_ave + CFO_THRESHOLD_XTAL) >> 2) - 1;
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+			 "Crystal cap =3D 0x%x, Crystal cap offset =3D %d\n",
+			 rtldm->crystal_cap, adjust_xtal);
+
+		/*3.Adjudt Crystal Cap.*/
+		if (adjust_xtal !=3D 0) {
+			rtldm->is_freeze =3D 0;
+			rtldm->crystal_cap +=3D adjust_xtal;
+
+			if (rtldm->crystal_cap > 0x3f)
+				rtldm->crystal_cap =3D 0x3f;
+			else if (rtldm->crystal_cap < 0)
+				rtldm->crystal_cap =3D 0;
+
+			crystal_cap =3D rtldm->crystal_cap & 0x3f;
+			crystal_cap =3D crystal_cap & 0x3f;
+			if (rtlpriv->rtlhal.hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+				rtl_set_bbreg(hw, REG_MAC_PHY_CTRL,
+					      0x7ff80000, (crystal_cap |
+					      (crystal_cap << 6)));
+			else
+				rtl_set_bbreg(hw, REG_MAC_PHY_CTRL,
+					      0xfff000, (crystal_cap |
+					      (crystal_cap << 6)));
+			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+				 "New crystal cap =3D 0x%x\n",
+				 rtldm->crystal_cap);
+		}
+	}
+}
+
+void rtl8821ae_dm_watchdog(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	bool fw_current_inpsmode =3D false;
+	bool fw_ps_awake =3D true;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				      (u8 *)(&fw_current_inpsmode));
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
+				      (u8 *)(&fw_ps_awake));
+
+	if (ppsc->p2p_ps_info.p2p_ps_mode)
+		fw_ps_awake =3D false;
+
+	if ((ppsc->rfpwr_state =3D=3D ERFON) &&
+	    ((!fw_current_inpsmode) && fw_ps_awake) &&
+	    (!ppsc->rfchange_inprogress)) {
+		rtl8821ae_dm_common_info_self_update(hw);
+		rtl8821ae_dm_false_alarm_counter_statistics(hw);
+		rtl8821ae_dm_check_rssi_monitor(hw);
+		rtl8821ae_dm_dig(hw);
+		rtl8821ae_dm_cck_packet_detection_thresh(hw);
+		rtl8821ae_dm_refresh_rate_adaptive_mask(hw);
+		rtl8821ae_dm_refresh_basic_rate_mask(hw);
+		rtl8821ae_dm_check_edca_turbo(hw);
+		rtl8821ae_dm_dynamic_atc_switch(hw);
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_dm_check_txpower_tracking_thermalmeter(hw);
+		else
+			rtl8821ae_dm_check_txpower_tracking_thermalmeter(hw);
+		rtl8821ae_dm_iq_calibrate(hw);
+	}
+
+	rtlpriv->dm.dbginfo.num_qry_beacon_pkt =3D 0;
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_DMESG, "\n");
+}
+
+void rtl8821ae_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw,
+					u8 *pdesc, u32 mac_id)
+{
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	struct fast_ant_training *pfat_table =3D &rtldm->fat_table;
+
+	if (rtlhal->hw_type !=3D HARDWARE_TYPE_RTL8812AE)
+		return;
+
+	if (rtlefuse->antenna_div_type =3D=3D CG_TRX_HW_ANTDIV)
+		SET_TX_DESC_TX_ANT(pdesc, pfat_table->antsel_a[mac_id]);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h b/drivers/net/=
wireless/rtlwifi/rtl8821ae/dm.h
new file mode 100644
index 0000000..9dd40dd
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.h
@@ -0,0 +1,356 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef	__RTL8821AE_DM_H__
+#define __RTL8821AE_DM_H__
+
+#define	MAIN_ANT	0
+#define	AUX_ANT	1
+#define	MAIN_ANT_CG_TRX	1
+#define	AUX_ANT_CG_TRX	0
+#define	MAIN_ANT_CGCS_RX	0
+#define	AUX_ANT_CGCS_RX	1
+
+#define	TXSCALE_TABLE_SIZE 37
+
+/*RF REG LIST*/
+#define	DM_REG_RF_MODE_11N				0x00
+#define	DM_REG_RF_0B_11N				0x0B
+#define	DM_REG_CHNBW_11N				0x18
+#define	DM_REG_T_METER_11N				0x24
+#define	DM_REG_RF_25_11N				0x25
+#define	DM_REG_RF_26_11N				0x26
+#define	DM_REG_RF_27_11N				0x27
+#define	DM_REG_RF_2B_11N				0x2B
+#define	DM_REG_RF_2C_11N				0x2C
+#define	DM_REG_RXRF_A3_11N				0x3C
+#define	DM_REG_T_METER_92D_11N			0x42
+#define	DM_REG_T_METER_88E_11N			0x42
+
+/*BB REG LIST*/
+/*PAGE 8 */
+#define	DM_REG_BB_CTRL_11N				0x800
+#define	DM_REG_RF_PIN_11N				0x804
+#define	DM_REG_PSD_CTRL_11N				0x808
+#define	DM_REG_TX_ANT_CTRL_11N			0x80C
+#define	DM_REG_BB_PWR_SAV5_11N			0x818
+#define	DM_REG_CCK_RPT_FORMAT_11N		0x824
+#define	DM_REG_RX_DEFUALT_A_11N		0x858
+#define	DM_REG_RX_DEFUALT_B_11N		0x85A
+#define	DM_REG_BB_PWR_SAV3_11N			0x85C
+#define	DM_REG_ANTSEL_CTRL_11N			0x860
+#define	DM_REG_RX_ANT_CTRL_11N			0x864
+#define	DM_REG_PIN_CTRL_11N				0x870
+#define	DM_REG_BB_PWR_SAV1_11N			0x874
+#define	DM_REG_ANTSEL_PATH_11N			0x878
+#define	DM_REG_BB_3WIRE_11N			0x88C
+#define	DM_REG_SC_CNT_11N				0x8C4
+#define	DM_REG_PSD_DATA_11N			0x8B4
+/*PAGE 9*/
+#define	DM_REG_ANT_MAPPING1_11N		0x914
+#define	DM_REG_ANT_MAPPING2_11N		0x918
+/*PAGE A*/
+#define	DM_REG_CCK_ANTDIV_PARA1_11N	0xA00
+#define	DM_REG_CCK_CCA_11N			0xA0A
+#define	DM_REG_CCK_CCA_11AC			0xA0A
+#define	DM_REG_CCK_ANTDIV_PARA2_11N	0xA0C
+#define	DM_REG_CCK_ANTDIV_PARA3_11N	0xA10
+#define	DM_REG_CCK_ANTDIV_PARA4_11N	0xA14
+#define	DM_REG_CCK_FILTER_PARA1_11N	0xA22
+#define	DM_REG_CCK_FILTER_PARA2_11N	0xA23
+#define	DM_REG_CCK_FILTER_PARA3_11N	0xA24
+#define	DM_REG_CCK_FILTER_PARA4_11N	0xA25
+#define	DM_REG_CCK_FILTER_PARA5_11N	0xA26
+#define	DM_REG_CCK_FILTER_PARA6_11N	0xA27
+#define	DM_REG_CCK_FILTER_PARA7_11N	0xA28
+#define	DM_REG_CCK_FILTER_PARA8_11N	0xA29
+#define	DM_REG_CCK_FA_RST_11N			0xA2C
+#define	DM_REG_CCK_FA_MSB_11N			0xA58
+#define	DM_REG_CCK_FA_LSB_11N			0xA5C
+#define	DM_REG_CCK_CCA_CNT_11N			0xA60
+#define	DM_REG_BB_PWR_SAV4_11N			0xA74
+/*PAGE B */
+#define	DM_REG_LNA_SWITCH_11N			0xB2C
+#define	DM_REG_PATH_SWITCH_11N			0xB30
+#define	DM_REG_RSSI_CTRL_11N			0xB38
+#define	DM_REG_CONFIG_ANTA_11N			0xB68
+#define	DM_REG_RSSI_BT_11N				0xB9C
+/*PAGE C */
+#define	DM_REG_OFDM_FA_HOLDC_11N		0xC00
+#define	DM_REG_RX_PATH_11N				0xC04
+#define	DM_REG_TRMUX_11N				0xC08
+#define	DM_REG_OFDM_FA_RSTC_11N		0xC0C
+#define	DM_REG_RXIQI_MATRIX_11N		0xC14
+#define	DM_REG_TXIQK_MATRIX_LSB1_11N	0xC4C
+#define	DM_REG_IGI_A_11N				0xC50
+#define	DM_REG_IGI_A_11AC				0xC50
+#define	DM_REG_ANTDIV_PARA2_11N		0xC54
+#define	DM_REG_IGI_B_11N					0xC58
+#define	DM_REG_IGI_B_11AC					0xE50
+#define	DM_REG_ANTDIV_PARA3_11N		0xC5C
+#define	DM_REG_BB_PWR_SAV2_11N			0xC70
+#define	DM_REG_RX_OFF_11N				0xC7C
+#define	DM_REG_TXIQK_MATRIXA_11N		0xC80
+#define	DM_REG_TXIQK_MATRIXB_11N		0xC88
+#define	DM_REG_TXIQK_MATRIXA_LSB2_11N	0xC94
+#define	DM_REG_TXIQK_MATRIXB_LSB2_11N	0xC9C
+#define	DM_REG_RXIQK_MATRIX_LSB_11N	0xCA0
+#define	DM_REG_ANTDIV_PARA1_11N		0xCA4
+#define	DM_REG_OFDM_FA_TYPE1_11N		0xCF0
+/*PAGE D */
+#define	DM_REG_OFDM_FA_RSTD_11N		0xD00
+#define	DM_REG_OFDM_FA_TYPE2_11N		0xDA0
+#define	DM_REG_OFDM_FA_TYPE3_11N		0xDA4
+#define	DM_REG_OFDM_FA_TYPE4_11N		0xDA8
+/*PAGE E */
+#define	DM_REG_TXAGC_A_6_18_11N		0xE00
+#define	DM_REG_TXAGC_A_24_54_11N		0xE04
+#define	DM_REG_TXAGC_A_1_MCS32_11N	0xE08
+#define	DM_REG_TXAGC_A_MCS0_3_11N		0xE10
+#define	DM_REG_TXAGC_A_MCS4_7_11N		0xE14
+#define	DM_REG_TXAGC_A_MCS8_11_11N	0xE18
+#define	DM_REG_TXAGC_A_MCS12_15_11N	0xE1C
+#define	DM_REG_FPGA0_IQK_11N			0xE28
+#define	DM_REG_TXIQK_TONE_A_11N		0xE30
+#define	DM_REG_RXIQK_TONE_A_11N		0xE34
+#define	DM_REG_TXIQK_PI_A_11N			0xE38
+#define	DM_REG_RXIQK_PI_A_11N			0xE3C
+#define	DM_REG_TXIQK_11N				0xE40
+#define	DM_REG_RXIQK_11N				0xE44
+#define	DM_REG_IQK_AGC_PTS_11N			0xE48
+#define	DM_REG_IQK_AGC_RSP_11N			0xE4C
+#define	DM_REG_BLUETOOTH_11N			0xE6C
+#define	DM_REG_RX_WAIT_CCA_11N			0xE70
+#define	DM_REG_TX_CCK_RFON_11N			0xE74
+#define	DM_REG_TX_CCK_BBON_11N			0xE78
+#define	DM_REG_OFDM_RFON_11N			0xE7C
+#define	DM_REG_OFDM_BBON_11N			0xE80
+#define DM_REG_TX2RX_11N				0xE84
+#define	DM_REG_TX2TX_11N				0xE88
+#define	DM_REG_RX_CCK_11N				0xE8C
+#define	DM_REG_RX_OFDM_11N				0xED0
+#define	DM_REG_RX_WAIT_RIFS_11N		0xED4
+#define	DM_REG_RX2RX_11N				0xED8
+#define	DM_REG_STANDBY_11N				0xEDC
+#define	DM_REG_SLEEP_11N				0xEE0
+#define	DM_REG_PMPD_ANAEN_11N			0xEEC
+
+/*MAC REG LIST*/
+#define	DM_REG_BB_RST_11N				0x02
+#define	DM_REG_ANTSEL_PIN_11N			0x4C
+#define	DM_REG_EARLY_MODE_11N			0x4D0
+#define	DM_REG_RSSI_MONITOR_11N		0x4FE
+#define	DM_REG_EDCA_VO_11N				0x500
+#define	DM_REG_EDCA_VI_11N				0x504
+#define	DM_REG_EDCA_BE_11N				0x508
+#define	DM_REG_EDCA_BK_11N				0x50C
+#define	DM_REG_TXPAUSE_11N				0x522
+#define	DM_REG_RESP_TX_11N				0x6D8
+#define	DM_REG_ANT_TRAIN_PARA1_11N	0x7b0
+#define	DM_REG_ANT_TRAIN_PARA2_11N	0x7b4
+
+/*DIG Related*/
+#define	DM_BIT_IGI_11N					0x0000007F
+#define	DM_BIT_IGI_11AC					0xFFFFFFFF
+
+#define HAL_DM_DIG_DISABLE			BIT(0)
+#define HAL_DM_HIPWR_DISABLE		BIT(1)
+
+#define OFDM_TABLE_LENGTH			43
+#define CCK_TABLE_LENGTH			33
+
+#define OFDM_TABLE_SIZE				37
+#define CCK_TABLE_SIZE				33
+
+#define BW_AUTO_SWITCH_HIGH_LOW		25
+#define BW_AUTO_SWITCH_LOW_HIGH		30
+
+#define DM_DIG_THRESH_HIGH			40
+#define DM_DIG_THRESH_LOW			35
+
+#define DM_FALSEALARM_THRESH_LOW	400
+#define DM_FALSEALARM_THRESH_HIGH	1000
+
+#define DM_DIG_MAX					0x3e
+#define DM_DIG_MIN					0x1e
+
+#define DM_DIG_MAX_AP				0x32
+#define DM_DIG_MIN_AP				0x20
+
+#define DM_DIG_FA_UPPER				0x3e
+#define DM_DIG_FA_LOWER				0x1e
+#define DM_DIG_FA_TH0				200
+#define DM_DIG_FA_TH1				0x300
+#define DM_DIG_FA_TH2				0x400
+
+#define DM_DIG_BACKOFF_MAX			12
+#define DM_DIG_BACKOFF_MIN			-4
+#define DM_DIG_BACKOFF_DEFAULT		10
+
+#define RXPATHSELECTION_SS_TH_LOW	30
+#define RXPATHSELECTION_DIFF_TH		18
+
+#define DM_RATR_STA_INIT			0
+#define DM_RATR_STA_HIGH			1
+#define DM_RATR_STA_MIDDLE			2
+#define DM_RATR_STA_LOW				3
+
+#define CTS2SELF_THVAL				30
+#define REGC38_TH					20
+
+#define WAIOTTHVAL					25
+
+#define TXHIGHPWRLEVEL_NORMAL		0
+#define TXHIGHPWRLEVEL_LEVEL1		1
+#define TXHIGHPWRLEVEL_LEVEL2		2
+#define TXHIGHPWRLEVEL_BT1			3
+#define TXHIGHPWRLEVEL_BT2			4
+
+#define DM_TYPE_BYFW				0
+#define DM_TYPE_BYDRIVER			1
+
+#define TX_POWER_NEAR_FIELD_THRESH_LVL2	74
+#define TX_POWER_NEAR_FIELD_THRESH_LVL1	67
+#define TXPWRTRACK_MAX_IDX 6
+
+/* Dynamic ATC switch */
+#define ATC_STATUS_OFF				0x0	/* enable */
+#define	ATC_STATUS_ON				0x1	/* disable */
+#define	CFO_THRESHOLD_XTAL			10	/* kHz */
+#define	CFO_THRESHOLD_ATC			80	/* kHz */
+
+#define AVG_THERMAL_NUM_8812A	4
+#define TXPWR_TRACK_TABLE_SIZE	30
+#define MAX_PATH_NUM_8812A		2
+#define MAX_PATH_NUM_8821A		1
+
+enum FAT_STATE {
+	FAT_NORMAL_STATE	=3D 0,
+	FAT_TRAINING_STATE =3D 1,
+};
+
+enum tag_dynamic_init_gain_operation_type_definition {
+	DIG_TYPE_THRESH_HIGH =3D 0,
+	DIG_TYPE_THRESH_LOW =3D 1,
+	DIG_TYPE_BACKOFF =3D 2,
+	DIG_TYPE_RX_GAIN_MIN =3D 3,
+	DIG_TYPE_RX_GAIN_MAX =3D 4,
+	DIG_TYPE_ENABLE =3D 5,
+	DIG_TYPE_DISABLE =3D 6,
+	DIG_OP_TYPE_MAX
+};
+
+enum tag_cck_packet_detection_threshold_type_definition {
+	CCK_PD_STAGE_LOWRSSI =3D 0,
+	CCK_PD_STAGE_HIGHRSSI =3D 1,
+	CCK_FA_STAGE_LOW =3D 2,
+	CCK_FA_STAGE_HIGH =3D 3,
+	CCK_PD_STAGE_MAX =3D 4,
+};
+
+enum dm_1r_cca_e {
+	CCA_1R =3D 0,
+	CCA_2R =3D 1,
+	CCA_MAX =3D 2,
+};
+
+enum dm_rf_e {
+	RF_SAVE =3D 0,
+	RF_NORMAL =3D 1,
+	RF_MAX =3D 2,
+};
+
+enum dm_sw_ant_switch_e {
+	ANS_ANTENNA_B =3D 1,
+	ANS_ANTENNA_A =3D 2,
+	ANS_ANTENNA_MAX =3D 3,
+};
+
+enum dm_dig_ext_port_alg_e {
+	DIG_EXT_PORT_STAGE_0 =3D 0,
+	DIG_EXT_PORT_STAGE_1 =3D 1,
+	DIG_EXT_PORT_STAGE_2 =3D 2,
+	DIG_EXT_PORT_STAGE_3 =3D 3,
+	DIG_EXT_PORT_STAGE_MAX =3D 4,
+};
+
+enum dm_dig_connect_e {
+	DIG_STA_DISCONNECT =3D 0,
+	DIG_STA_CONNECT =3D 1,
+	DIG_STA_BEFORE_CONNECT =3D 2,
+	DIG_MULTISTA_DISCONNECT =3D 3,
+	DIG_MULTISTA_CONNECT =3D 4,
+	DIG_CONNECT_MAX
+};
+
+enum pwr_track_control_method {
+	BBSWING,
+	TXAGC,
+	MIX_MODE
+};
+
+#define BT_RSSI_STATE_NORMAL_POWER      BIT_OFFSET_LEN_MASK_32(0, 1)
+#define BT_RSSI_STATE_AMDPU_OFF         BIT_OFFSET_LEN_MASK_32(1, 1)
+#define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
+#define BT_RSSI_STATE_BG_EDCA_LOW       BIT_OFFSET_LEN_MASK_32(3, 1)
+#define BT_RSSI_STATE_TXPOWER_LOW       BIT_OFFSET_LEN_MASK_32(4, 1)
+#define GET_UNDECORATED_AVERAGE_RSSI(_priv)     \
+	((((struct rtl_priv *)(_priv))->mac80211.opmode =3D=3D	\
+			      NL80211_IFTYPE_ADHOC) ? \
+	(((struct rtl_priv *)(_priv))->dm.entry_min_undec_sm_pwdb) : \
+	(((struct rtl_priv *)(_priv))->dm.undec_sm_pwdb))
+
+void rtl8821ae_dm_set_tx_ant_by_tx_info(struct ieee80211_hw *hw,
+					u8 *pdesc, u32 mac_id);
+void rtl8821ae_dm_ant_sel_statistics(struct ieee80211_hw *hw,
+				     u8 antsel_tr_mux, u32 mac_id,
+				     u32 rx_pwdb_all);
+void rtl8821ae_dm_fast_antenna_training_callback(unsigned long data);
+void rtl8821ae_dm_init(struct ieee80211_hw *hw);
+void rtl8821ae_dm_watchdog(struct ieee80211_hw *hw);
+void rtl8821ae_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi);
+void rtl8821ae_dm_init_edca_turbo(struct ieee80211_hw *hw);
+void rtl8821ae_dm_check_txpower_tracking_thermalmeter(struct ieee80211=
_hw *hw);
+void rtl8821ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
+void rtl8821ae_dm_txpower_track_adjust(struct ieee80211_hw *hw,
+				       u8 type, u8 *pdirection,
+				       u32 *poutwrite_val);
+void rtl8821ae_dm_clear_txpower_tracking_state(struct ieee80211_hw *hw=
);
+void rtl8821ae_dm_write_cck_cca_thres(struct ieee80211_hw *hw, u8 curr=
ent_cca);
+void rtl8821ae_dm_initialize_txpower_tracking_thermalmeter(struct ieee=
80211_hw *hw);
+void rtl8812ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
+				      enum pwr_track_control_method method,
+				      u8 rf_path,
+				      u8 channel_mapped_index);
+void rtl8821ae_dm_txpwr_track_set_pwr(struct ieee80211_hw *hw,
+				      enum pwr_track_control_method method,
+				      u8 rf_path, u8 channel_mapped_index);
+
+void rtl8821ae_dm_update_init_rate(struct ieee80211_hw *hw, u8 rate);
+u8 rtl8821ae_hw_rate_to_mrate(struct ieee80211_hw *hw, u8 rate);
+void rtl8812ae_dm_txpower_tracking_callback_thermalmeter(struct ieee80=
211_hw *hw);
+void rtl8821ae_dm_txpower_tracking_callback_thermalmeter(struct ieee80=
211_hw *hw);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c b/drivers/net/=
wireless/rtlwifi/rtl8821ae/fw.c
new file mode 100644
index 0000000..6f71aaa
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.c
@@ -0,0 +1,1889 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "reg.h"
+#include "def.h"
+#include "fw.h"
+#include "dm.h"
+
+static void _rtl8821ae_enable_fw_download(struct ieee80211_hw *hw, boo=
l enable)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 tmp;
+
+	if (enable) {
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x05);
+
+		tmp =3D rtl_read_byte(rtlpriv, REG_MCUFWDL + 2);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL + 2, tmp & 0xf7);
+
+		tmp =3D rtl_read_byte(rtlpriv, REG_MCUFWDL);
+	} else {
+		tmp =3D rtl_read_byte(rtlpriv, REG_MCUFWDL);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, tmp & 0xfe);
+		tmp =3D rtl_read_byte(rtlpriv, REG_MCUFWDL);
+	}
+}
+
+static void _rtl8821ae_fw_block_write(struct ieee80211_hw *hw,
+				      const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 blocksize =3D sizeof(u32);
+	u8 *bufferptr =3D (u8 *)buffer;
+	u32 *pu4byteptr =3D (u32 *)buffer;
+	u32 i, offset, blockcount, remainsize;
+
+	blockcount =3D size / blocksize;
+	remainsize =3D size % blocksize;
+
+	for (i =3D 0; i < blockcount; i++) {
+		offset =3D i * blocksize;
+		rtl_write_dword(rtlpriv, (FW_8821AE_START_ADDRESS + offset),
+				*(pu4byteptr + i));
+	}
+
+	if (remainsize) {
+		offset =3D blockcount * blocksize;
+		bufferptr +=3D offset;
+		for (i =3D 0; i < remainsize; i++) {
+			rtl_write_byte(rtlpriv, (FW_8821AE_START_ADDRESS +
+					offset + i), *(bufferptr + i));
+		}
+	}
+}
+
+static void _rtl8821ae_fw_page_write(struct ieee80211_hw *hw,
+				     u32 page, const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 value8;
+	u8 u8page =3D (u8)(page & 0x07);
+
+	value8 =3D (rtl_read_byte(rtlpriv, REG_MCUFWDL + 2) & 0xF8) | u8page;
+
+	rtl_write_byte(rtlpriv, (REG_MCUFWDL + 2), value8);
+	_rtl8821ae_fw_block_write(hw, buffer, size);
+}
+
+static void _rtl8821ae_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
+{
+	u32 fwlen =3D *pfwlen;
+	u8 remain =3D (u8)(fwlen % 4);
+
+	remain =3D (remain =3D=3D 0) ? 0 : (4 - remain);
+
+	while (remain > 0) {
+		pfwbuf[fwlen] =3D 0;
+		fwlen++;
+		remain--;
+	}
+
+	*pfwlen =3D fwlen;
+}
+
+static void _rtl8821ae_write_fw(struct ieee80211_hw *hw,
+				enum version_8821ae version,
+				u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 *bufferptr =3D (u8 *)buffer;
+	u32 pagenums, remainsize;
+	u32 page, offset;
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "FW size is %d bytes,\n", size);
+
+	_rtl8821ae_fill_dummy(bufferptr, &size);
+
+	pagenums =3D size / FW_8821AE_PAGE_SIZE;
+	remainsize =3D size % FW_8821AE_PAGE_SIZE;
+
+	if (pagenums > 8) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Page numbers should not greater then 8\n");
+	}
+
+	for (page =3D 0; page < pagenums; page++) {
+		offset =3D page * FW_8821AE_PAGE_SIZE;
+		_rtl8821ae_fw_page_write(hw, page, (bufferptr + offset),
+					 FW_8821AE_PAGE_SIZE);
+	}
+
+	if (remainsize) {
+		offset =3D pagenums * FW_8821AE_PAGE_SIZE;
+		page =3D pagenums;
+		_rtl8821ae_fw_page_write(hw, page, (bufferptr + offset),
+					 remainsize);
+	}
+}
+
+static int _rtl8821ae_fw_free_to_go(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	int err =3D -EIO;
+	u32 counter =3D 0;
+	u32 value32;
+
+	do {
+		value32 =3D rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	} while ((counter++ < FW_8821AE_POLLING_TIMEOUT_COUNT) &&
+		 (!(value32 & FWDL_CHKSUM_RPT)));
+
+	if (counter >=3D FW_8821AE_POLLING_TIMEOUT_COUNT) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "chksum report faill ! REG_MCUFWDL:0x%08x .\n",
+			  value32);
+		goto exit;
+	}
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_EMERG,
+		 "Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32);
+
+	value32 =3D rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	value32 |=3D MCUFWDL_RDY;
+	value32 &=3D ~WINTINI_RDY;
+	rtl_write_dword(rtlpriv, REG_MCUFWDL, value32);
+
+	rtl8821ae_firmware_selfreset(hw);
+
+	counter =3D 0;
+	do {
+		value32 =3D rtl_read_dword(rtlpriv, REG_MCUFWDL);
+		if (value32 & WINTINI_RDY) {
+			RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+				 "Polling FW ready success!! REG_MCUFWDL:0x%08x .\n",
+				  value32);
+			err =3D 0;
+			goto exit;
+		}
+
+		udelay(FW_8821AE_POLLING_DELAY);
+	} while (counter++ < FW_8821AE_POLLING_TIMEOUT_COUNT);
+
+	RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x .\n",
+		 value32);
+
+exit:
+	return err;
+}
+
+static void _rtl8821ae_wait_for_h2c_cmd_finish(struct rtl_priv *rtlpri=
v)
+{
+	u8 val;
+	u16 count =3D 0;
+
+	do {
+		val =3D rtl_read_byte(rtlpriv, REG_HMETFR);
+		mdelay(1);
+		count++;
+	} while ((val & 0x0F) && (count < 1000));
+}
+
+int rtl8821ae_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_w=
lan_fw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl8821a_firmware_header *pfwheader;
+	u8 *pfwdata;
+	u32 fwsize;
+	int err;
+	bool support_remote_wakeup;
+	enum version_8821ae version =3D rtlhal->version;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *)(&support_remote_wakeup));
+
+	if (support_remote_wakeup)
+		_rtl8821ae_wait_for_h2c_cmd_finish(rtlpriv);
+
+	if (buse_wake_on_wlan_fw) {
+		if (!rtlhal->wowlan_firmware)
+			return 1;
+
+		pfwheader =3D
+		  (struct rtl8821a_firmware_header *)rtlhal->wowlan_firmware;
+		rtlhal->fw_version =3D pfwheader->version;
+		rtlhal->fw_subversion =3D pfwheader->subversion;
+		pfwdata =3D (u8 *)rtlhal->wowlan_firmware;
+		fwsize =3D rtlhal->wowlan_fwsize;
+	} else {
+		if (!rtlhal->pfirmware)
+			return 1;
+
+		pfwheader =3D
+		  (struct rtl8821a_firmware_header *)rtlhal->pfirmware;
+		rtlhal->fw_version =3D pfwheader->version;
+		rtlhal->fw_subversion =3D pfwheader->subversion;
+		pfwdata =3D (u8 *)rtlhal->pfirmware;
+		fwsize =3D rtlhal->fwsize;
+	}
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
+		 "%s Firmware SIZE %d\n",
+		 buse_wake_on_wlan_fw ? "Wowlan" : "Normal", fwsize);
+
+	if (IS_FW_HEADER_EXIST_8812(pfwheader) ||
+	    IS_FW_HEADER_EXIST_8821(pfwheader)) {
+		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
+			 "Firmware Version(%d), Signature(%#x)\n",
+			 pfwheader->version, pfwheader->signature);
+
+		pfwdata =3D pfwdata + sizeof(struct rtl8821a_firmware_header);
+		fwsize =3D fwsize - sizeof(struct rtl8821a_firmware_header);
+	}
+
+	if (rtlhal->mac_func_enable) {
+		if (rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) {
+			rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
+			rtl8821ae_firmware_selfreset(hw);
+		}
+	}
+	_rtl8821ae_enable_fw_download(hw, true);
+	_rtl8821ae_write_fw(hw, version, pfwdata, fwsize);
+	_rtl8821ae_enable_fw_download(hw, false);
+
+	err =3D _rtl8821ae_fw_free_to_go(hw);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Firmware is not ready to run!\n");
+	} else {
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+			 "Firmware is ready to run!\n");
+	}
+
+	return 0;
+}
+
+#if (USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN =3D=3D 1)
+void rtl8821ae_set_fw_related_for_wowlan(struct ieee80211_hw *hw,
+					 bool used_wowlan_fw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	/* 1. Before WoWLAN or After WOWLAN we need to re-download Fw. */
+	if (rtl8821ae_download_fw(hw, used_wowlan_fw)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+			 "Re-Download Firmware failed!!\n");
+		rtlhal->fw_ready =3D false;
+		return;
+	}
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "Re-Download Firmware Success !!\n");
+	rtlhal->fw_ready =3D true;
+
+	/* 2. Re-Init the variables about Fw related setting. */
+	ppsc->fw_current_inpsmode =3D false;
+	rtlhal->fw_ps_state =3D FW_PS_STATE_ALL_ON_8821AE;
+	rtlhal->fw_clk_change_in_progress =3D false;
+	rtlhal->allow_sw_to_change_hwclc =3D false;
+	rtlhal->last_hmeboxnum =3D 0;
+}
+#endif
+
+static bool _rtl8821ae_check_fw_read_last_h2c(struct ieee80211_hw *hw,
+					      u8 boxnum)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 val_hmetfr;
+	bool result =3D false;
+
+	val_hmetfr =3D rtl_read_byte(rtlpriv, REG_HMETFR);
+	if (((val_hmetfr >> boxnum) & BIT(0)) =3D=3D 0)
+		result =3D true;
+	return result;
+}
+
+static void _rtl8821ae_fill_h2c_command(struct ieee80211_hw *hw,
+					u8 element_id, u32 cmd_len,
+					u8 *cmdbuffer)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 boxnum =3D 0;
+	u16 box_reg =3D 0, box_extreg =3D 0;
+	u8 u1b_tmp =3D 0;
+	bool isfw_read =3D false;
+	u8 buf_index =3D 0;
+	bool bwrite_sucess =3D false;
+	u8 wait_h2c_limmit =3D 100;
+	/*u8 wait_writeh2c_limmit =3D 100;*/
+	u8 boxcontent[4], boxextcontent[4];
+	u32 h2c_waitcounter =3D 0;
+	unsigned long flag =3D 0;
+	u8 idx =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "come in\n");
+
+	while (true) {
+		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+		if (rtlhal->h2c_setinprogress) {
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+				 "H2C set in progress! Wait to set..element_id(%d).\n",
+				 element_id);
+
+			while (rtlhal->h2c_setinprogress) {
+				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
+						       flag);
+				h2c_waitcounter++;
+				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+					 "Wait 100 us (%d times)...\n",
+					  h2c_waitcounter);
+				udelay(100);
+
+				if (h2c_waitcounter > 1000)
+					return;
+				spin_lock_irqsave(&rtlpriv->locks.h2c_lock,
+						  flag);
+			}
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+		} else {
+			rtlhal->h2c_setinprogress =3D true;
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+			break;
+		}
+	}
+
+	while (!bwrite_sucess) {
+		boxnum =3D rtlhal->last_hmeboxnum;
+		switch (boxnum) {
+		case 0:
+			box_reg =3D REG_HMEBOX_0;
+			box_extreg =3D REG_HMEBOX_EXT_0;
+			break;
+		case 1:
+			box_reg =3D REG_HMEBOX_1;
+			box_extreg =3D REG_HMEBOX_EXT_1;
+			break;
+		case 2:
+			box_reg =3D REG_HMEBOX_2;
+			box_extreg =3D REG_HMEBOX_EXT_2;
+			break;
+		case 3:
+			box_reg =3D REG_HMEBOX_3;
+			box_extreg =3D REG_HMEBOX_EXT_3;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
+			break;
+		}
+
+		isfw_read =3D false;
+		u1b_tmp =3D rtl_read_byte(rtlpriv, REG_CR);
+
+		if (u1b_tmp !=3D 0xEA) {
+			isfw_read =3D true;
+		} else {
+			if (rtl_read_byte(rtlpriv, REG_TXDMA_STATUS) =3D=3D 0xEA ||
+			    rtl_read_byte(rtlpriv, REG_TXPKT_EMPTY) =3D=3D 0xEA)
+				rtl_write_byte(rtlpriv, REG_SYS_CFG1 + 3, 0xFF);
+		}
+
+		if (isfw_read) {
+			wait_h2c_limmit =3D 100;
+			isfw_read =3D
+			  _rtl8821ae_check_fw_read_last_h2c(hw, boxnum);
+			while (!isfw_read) {
+				/*wait until Fw read*/
+				wait_h2c_limmit--;
+				if (wait_h2c_limmit =3D=3D 0) {
+					RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+						 "Waiting too long for FW read clear HMEBox(%d)!\n",
+						 boxnum);
+					break;
+				}
+
+				udelay(10);
+
+				isfw_read =3D
+				  _rtl8821ae_check_fw_read_last_h2c(hw, boxnum);
+				u1b_tmp =3D rtl_read_byte(rtlpriv, 0x130);
+				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+					 "Waiting for FW read clear HMEBox(%d)!!! 0x130 =3D %2x\n",
+					 boxnum, u1b_tmp);
+			}
+		}
+
+		if (!isfw_read) {
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
+				 boxnum);
+			break;
+		}
+
+		memset(boxcontent, 0, sizeof(boxcontent));
+		memset(boxextcontent, 0, sizeof(boxextcontent));
+		boxcontent[0] =3D element_id;
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+			 "Write element_id box_reg(%4x) =3D %2x\n",
+			 box_reg, element_id);
+
+		switch (cmd_len) {
+		case 1:
+		case 2:
+		case 3:
+			/*boxcontent[0] &=3D ~(BIT(7));*/
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, cmd_len);
+
+			for (idx =3D 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		case 4:
+		case 5:
+		case 6:
+		case 7:
+			/*boxcontent[0] |=3D (BIT(7));*/
+			memcpy((u8 *)(boxextcontent),
+			       cmdbuffer + buf_index+3, cmd_len-3);
+			memcpy((u8 *)(boxcontent) + 1,
+			       cmdbuffer + buf_index, 3);
+
+			for (idx =3D 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_extreg + idx,
+					       boxextcontent[idx]);
+			}
+
+			for (idx =3D 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
+			break;
+		}
+
+		bwrite_sucess =3D true;
+
+		rtlhal->last_hmeboxnum =3D boxnum + 1;
+		if (rtlhal->last_hmeboxnum =3D=3D 4)
+			rtlhal->last_hmeboxnum =3D 0;
+
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
+			 "pHalData->last_hmeboxnum  =3D %d\n",
+			  rtlhal->last_hmeboxnum);
+	}
+
+	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+	rtlhal->h2c_setinprogress =3D false;
+	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "go out\n");
+}
+
+void rtl8821ae_fill_h2c_cmd(struct ieee80211_hw *hw,
+			    u8 element_id, u32 cmd_len, u8 *cmdbuffer)
+{
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u32 tmp_cmdbuf[2];
+
+	if (!rtlhal->fw_ready) {
+		RT_ASSERT(false,
+			  "return H2C cmd because of Fw download fail!!!\n");
+		return;
+	}
+
+	memset(tmp_cmdbuf, 0, 8);
+	memcpy(tmp_cmdbuf, cmdbuffer, cmd_len);
+	_rtl8821ae_fill_h2c_command(hw, element_id, cmd_len, (u8 *)&tmp_cmdbu=
f);
+}
+
+void rtl8821ae_firmware_selfreset(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 u1b_tmp;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp & (~BIT(3))));
+	} else {
+		u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp & (~BIT(0))));
+	}
+
+	u1b_tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN+1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp & (~BIT(2))));
+	udelay(50);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp | BIT(3)));
+	} else {
+		u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL+1);
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL+1, (u1b_tmp | BIT(0)));
+	}
+
+	u1b_tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN+1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp | BIT(2)));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "_8051Reset8812ae(): 8051 reset success .\n");
+}
+
+void rtl8821ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 u1_h2c_set_pwrmode[H2C_8821AE_PWEMODE_LENGTH] =3D { 0 };
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	u8 rlbm, power_state =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode =3D %d\n", mode)=
;
+
+	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, ((mode) ? 1 : 0));
+	rlbm =3D 0;/*YJ,temp,120316. FW now not support RLBM=3D2.*/
+	SET_H2CCMD_PWRMODE_PARM_RLBM(u1_h2c_set_pwrmode, rlbm);
+	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
+					 (rtlpriv->mac80211.p2p) ?
+					 ppsc->smart_ps : 1);
+	SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(u1_h2c_set_pwrmode,
+					       ppsc->reg_max_lps_awakeintvl);
+	SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(u1_h2c_set_pwrmode, 0);
+	if (mode =3D=3D FW_PS_ACTIVE_MODE)
+		power_state |=3D FW_PWR_STATE_ACTIVE;
+	else
+		power_state |=3D FW_PWR_STATE_RF_OFF;
+
+	SET_H2CCMD_PWRMODE_PARM_PWR_STATE(u1_h2c_set_pwrmode, power_state);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+		      "rtl92c_set_fw_pwrmode(): u1_h2c_set_pwrmode\n",
+		      u1_h2c_set_pwrmode, H2C_8821AE_PWEMODE_LENGTH);
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_SETPWRMODE,
+			       H2C_8821AE_PWEMODE_LENGTH,
+			       u1_h2c_set_pwrmode);
+}
+
+void rtl8821ae_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw,
+					   u8 mstatus)
+{
+	u8 parm[3] =3D { 0, 0, 0 };
+	/* parm[0]: bit0=3D0-->Disconnect, bit0=3D1-->Connect
+	 *          bit1=3D0-->update Media Status to MACID
+	 *          bit1=3D1-->update Media Status from MACID to MACID_End
+	 * parm[1]: MACID, if this is INFRA_STA, MacID =3D 0
+	 * parm[2]: MACID_End
+	 */
+
+	SET_H2CCMD_MSRRPT_PARM_OPMODE(parm, mstatus);
+	SET_H2CCMD_MSRRPT_PARM_MACID_IND(parm, 0);
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_MSRRPT, 3, parm);
+}
+
+void rtl8821ae_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
+				      u8 ap_offload_enable)
+{
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	u8 u1_apoffload_parm[H2C_8821AE_AP_OFFLOAD_LENGTH] =3D { 0 };
+
+	SET_H2CCMD_AP_OFFLOAD_ON(u1_apoffload_parm, ap_offload_enable);
+	SET_H2CCMD_AP_OFFLOAD_HIDDEN(u1_apoffload_parm, mac->hiddenssid);
+	SET_H2CCMD_AP_OFFLOAD_DENYANY(u1_apoffload_parm, 0);
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_AP_OFFLOAD,
+			       H2C_8821AE_AP_OFFLOAD_LENGTH,
+			       u1_apoffload_parm);
+}
+
+void rtl8821ae_set_fw_wowlan_mode(struct ieee80211_hw *hw, bool func_e=
n)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	u8 fw_wowlan_info[H2C_8821AE_WOWLAN_LENGTH] =3D {0};
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "enable(%d)\n", func_en);
+
+	SET_8812_H2CCMD_WOWLAN_FUNC_ENABLE(fw_wowlan_info,
+					   (func_en ? true : false));
+
+	SET_8812_H2CCMD_WOWLAN_PATTERN_MATCH_ENABLE(fw_wowlan_info,
+		((ppsc->wo_wlan_mode & WAKE_ON_PATTERN_MATCH) ? 1 : 0));
+	SET_8812_H2CCMD_WOWLAN_MAGIC_PKT_ENABLE(fw_wowlan_info,
+		((ppsc->wo_wlan_mode & WAKE_ON_MAGIC_PACKET) ? 1 : 0));
+
+	SET_8812_H2CCMD_WOWLAN_UNICAST_PKT_ENABLE(fw_wowlan_info, 0);
+	SET_8812_H2CCMD_WOWLAN_ALL_PKT_DROP(fw_wowlan_info, false);
+	SET_8812_H2CCMD_WOWLAN_GPIO_ACTIVE(fw_wowlan_info, 0);
+	SET_8812_H2CCMD_WOWLAN_DISCONNECT_WAKE_UP(fw_wowlan_info, 1);
+	SET_8812_H2CCMD_WOWLAN_GPIONUM(fw_wowlan_info, 0);
+	SET_8812_H2CCMD_WOWLAN_GPIO_DURATION(fw_wowlan_info, 0);
+
+	RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_DMESG,
+		      "wowlan mode: cmd 0x80: Content:\n",
+		      fw_wowlan_info, H2C_8821AE_WOWLAN_LENGTH);
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_WO_WLAN,
+			       H2C_8821AE_WOWLAN_LENGTH,
+			       fw_wowlan_info);
+}
+
+void rtl8821ae_set_fw_remote_wake_ctrl_cmd(struct ieee80211_hw *hw,
+					   u8 enable)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 remote_wake_ctrl_parm[H2C_8821AE_REMOTE_WAKE_CTRL_LEN] =3D {0};
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+		 "enable=3D%d, ARP offload=3D%d, GTK offload=3D%d\n",
+		 enable, ppsc->arp_offload_enable, ppsc->gtk_offload_enable);
+
+	SET_8812_H2CCMD_REMOTE_WAKECTRL_ENABLE(remote_wake_ctrl_parm, enable)=
;
+	SET_8812_H2CCMD_REMOTE_WAKE_CTRL_ARP_OFFLOAD_EN(remote_wake_ctrl_parm=
,
+					(ppsc->arp_offload_enable ? 1 : 0));
+	SET_8812_H2CCMD_REMOTE_WAKE_CTRL_GTK_OFFLOAD_EN(remote_wake_ctrl_parm=
,
+					(ppsc->gtk_offload_enable ? 1 : 0));
+	SET_8812_H2CCMD_REMOTE_WAKE_CTRL_REALWOWV2_EN(remote_wake_ctrl_parm,
+					(rtlhal->real_wow_v2_enable ? 1 : 0));
+
+	RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+		      "remote_wake_ctrl: cmd 0x4: Content:\n",
+		      remote_wake_ctrl_parm, H2C_8821AE_REMOTE_WAKE_CTRL_LEN);
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_REMOTE_WAKE_CTRL,
+			       H2C_8821AE_REMOTE_WAKE_CTRL_LEN,
+			       remote_wake_ctrl_parm);
+}
+
+void rtl8821ae_set_fw_keep_alive_cmd(struct ieee80211_hw *hw,
+				     bool func_en)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 keep_alive_info[H2C_8821AE_KEEP_ALIVE_CTRL_LENGTH] =3D {0};
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Enable(%d)\n", func_en);
+
+	SET_8812_H2CCMD_KEEP_ALIVE_ENABLE(keep_alive_info, func_en);
+	/* 1: the period is controled by driver, 0: by Fw default */
+	SET_8812_H2CCMD_KEEP_ALIVE_ACCPEPT_USER_DEFINED(keep_alive_info, 1);
+	SET_8812_H2CCMD_KEEP_ALIVE_PERIOD(keep_alive_info, 10); /* 10 sec */
+
+	RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+		      "keep alive: cmd 0x3: Content:\n",
+		      keep_alive_info, H2C_8821AE_KEEP_ALIVE_CTRL);
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_KEEP_ALIVE_CTRL,
+			       H2C_8821AE_KEEP_ALIVE_CTRL_LENGTH,
+			       keep_alive_info);
+}
+
+void rtl8821ae_set_fw_disconnect_decision_ctrl_cmd(struct ieee80211_hw=
 *hw,
+						   bool enabled)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 parm[H2C_8821AE_DISCONNECT_DECISION_CTRL_LEN] =3D {0};
+
+	SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_ENABLE(parm, enabled);
+	SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_USER_SETTING(parm, 1);
+	SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_CHECK_PERIOD(parm, 30);
+	SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_TRYPKT_NUM(parm, 3);
+
+	RT_PRINT_DATA(rtlpriv, COMP_POWER, DBG_TRACE,
+		      "disconnect_decision_ctrl: cmd 0x4: Content:\n",
+		      parm, H2C_8821AE_DISCONNECT_DECISION_CTRL_LEN);
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_DISCONNECT_DECISION,
+			       H2C_8821AE_DISCONNECT_DECISION_CTRL_LEN, parm);
+}
+
+void rtl8821ae_set_fw_global_info_cmd(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_security *sec =3D &rtlpriv->sec;
+	u8 remote_wakeup_sec_info[H2C_8821AE_AOAC_GLOBAL_INFO_LEN] =3D {0};
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+		 "PairwiseEncAlgorithm=3D%d, GroupEncAlgorithm=3D%d\n",
+		 sec->pairwise_enc_algorithm, sec->group_enc_algorithm);
+
+	SET_8812_H2CCMD_AOAC_GLOBAL_INFO_PAIRWISE_ENC_ALG(
+						remote_wakeup_sec_info,
+						sec->pairwise_enc_algorithm);
+	SET_8812_H2CCMD_AOAC_GLOBAL_INFO_GROUP_ENC_ALG(remote_wakeup_sec_info=
,
+						      sec->group_enc_algorithm);
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_AOAC_GLOBAL_INFO,
+			       H2C_8821AE_AOAC_GLOBAL_INFO_LEN,
+			       remote_wakeup_sec_info);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_TRACE,
+		      "rtl8821ae_set_global_info: cmd 0x82:\n",
+		      remote_wakeup_sec_info, H2C_8821AE_AOAC_GLOBAL_INFO_LEN);
+}
+
+static bool _rtl8821ae_cmd_send_packet(struct ieee80211_hw *hw,
+				struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	struct rtl_tx_desc *pdesc;
+	struct sk_buff *pskb =3D NULL;
+	u8 own;
+	unsigned long flags;
+
+	ring =3D &rtlpci->tx_ring[BEACON_QUEUE];
+
+	pskb =3D __skb_dequeue(&ring->queue);
+	if (pskb)
+		kfree_skb(pskb);
+
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
+
+	pdesc =3D &ring->desc[0];
+	own =3D (u8)rtlpriv->cfg->ops->get_desc((u8 *)pdesc, true, HW_DESC_OW=
N);
+
+	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *)pdesc, 1, 1, skb);
+
+	__skb_queue_tail(&ring->queue, skb);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+
+	rtlpriv->cfg->ops->tx_polling(hw, BEACON_QUEUE);
+
+	return true;
+}
+
+#define BEACON_PG		0
+#define PSPOLL_PG		1
+#define NULL_PG			2
+#define QOSNULL_PG		3
+#define ARPRESP_PG		4
+#define REMOTE_PG		5
+#define GTKEXT_PG		6
+
+#define TOTAL_RESERVED_PKT_LEN_8812	3584
+#define TOTAL_RESERVED_PKT_LEN_8821	1792
+
+static u8 reserved_page_packet_8821[TOTAL_RESERVED_PKT_LEN_8821] =3D {
+	/* page 0: beacon */
+	0x80, 0x00, 0x00, 0x00,  0xff, 0xff, 0xff, 0xff,
+	0xff, 0xff, 0x00, 0xe0,  0x4c, 0x02, 0xe2, 0x64,
+	0x40, 0x16, 0x9f, 0x23,  0xd4, 0x46, 0x20, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x64, 0x00, 0x20, 0x04,  0x00, 0x06, 0x64, 0x6c,
+	0x69, 0x6e, 0x6b, 0x31,  0x01, 0x08, 0x82, 0x84,
+	0x8b, 0x96, 0x0c, 0x18,  0x30, 0x48, 0x03, 0x01,
+	0x0b, 0x06, 0x02, 0x00,  0x00, 0x2a, 0x01, 0x8b,
+	0x32, 0x04, 0x12, 0x24,  0x60, 0x6c, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x10, 0x00, 0x28, 0x8c,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x81, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 1: ps-poll */
+	0xa4, 0x10, 0x01, 0xc0,  0x40, 0x16, 0x9f, 0x23,
+	0xd4, 0x46, 0x00, 0xe0,  0x4c, 0x02, 0xe2, 0x64,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x18, 0x00, 0x28, 0x8c,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 2: null data */
+	0x48, 0x01, 0x00, 0x00,  0x40, 0x16, 0x9f, 0x23,
+	0xd4, 0x46, 0x00, 0xe0,  0x4c, 0x02, 0xe2, 0x64,
+	0x40, 0x16, 0x9f, 0x23,  0xd4, 0x46, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x1A, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 3: qos null data */
+	0xC8, 0x01, 0x00, 0x00,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x3C, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 4~6 is for wowlan */
+	/* page 4: ARP resp */
+	0x08, 0x01, 0x00, 0x00,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x00, 0x00,
+	0xAA, 0xAA, 0x03, 0x00,  0x00, 0x00, 0x08, 0x06,
+	0x00, 0x01, 0x08, 0x00,  0x06, 0x04, 0x00, 0x02,
+	0x00, 0xE0, 0x4C, 0x02,  0x51, 0x02, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 5: H2C_REMOTE_WAKE_CTRL_INFO */
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 6: Rsvd GTK extend memory (zero memory) */
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+};
+
+static u8 reserved_page_packet_8812[TOTAL_RESERVED_PKT_LEN_8812] =3D {
+	/* page 0: beacon */
+	0x80, 0x00, 0x00, 0x00,  0xFF, 0xFF, 0xFF, 0xFF,
+	0xFF, 0xFF, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x60, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x64, 0x00, 0x20, 0x04,  0x00, 0x03, 0x32, 0x31,
+	0x35, 0x01, 0x08, 0x82,  0x84, 0x8B, 0x96, 0x0C,
+	0x12, 0x18, 0x24, 0x03,  0x01, 0x01, 0x06, 0x02,
+	0x00, 0x00, 0x2A, 0x01,  0x02, 0x32, 0x04, 0x30,
+	0x48, 0x60, 0x6C, 0x2D,  0x1A, 0xED, 0x09, 0x03,
+	0xFF, 0xFF, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x3D,
+	0x00, 0xDD, 0x07, 0x00,  0xE0, 0x4C, 0x02, 0x02,
+	0x08, 0x04, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x10, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x81, 0x00, 0x00,
+	0x04, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 1: ps-poll */
+	0xA4, 0x10, 0x09, 0xC0,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x18, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 2: null data */
+	0x48, 0x01, 0x00, 0x00,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x1A, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 3: Qos null data */
+	0xC8, 0x01, 0x00, 0x00,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x3C, 0x00, 0x28, 0x8C,  0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 4~6 is for wowlan */
+	/* page 4: ARP resp */
+	0x08, 0x01, 0x00, 0x00,  0x84, 0xC9, 0xB2, 0xA7,
+	0xB3, 0x6E, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x84, 0xC9, 0xB2, 0xA7,  0xB3, 0x6E, 0x00, 0x00,
+	0xAA, 0xAA, 0x03, 0x00,  0x00, 0x00, 0x08, 0x06,
+	0x00, 0x01, 0x08, 0x00,  0x06, 0x04, 0x00, 0x02,
+	0x00, 0xE0, 0x4C, 0x02,  0x51, 0x02, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0xE0,  0x4C, 0x02, 0x51, 0x02,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 5: H2C_REMOTE_WAKE_CTRL_INFO */
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	/* page 6: Rsvd GTK extend memory (zero memory) */
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00,
+};
+
+void rtl8812ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
+				  bool b_dl_finished, bool dl_whole_packets)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtlpriv);
+	struct sk_buff *skb =3D NULL;
+	u32 totalpacketlen;
+	bool rtstatus;
+	u8 u1RsvdPageLoc[5] =3D { 0 };
+	u8 u1RsvdPageLoc2[7] =3D { 0 };
+	bool b_dlok =3D false;
+	u8 *beacon;
+	u8 *p_pspoll;
+	u8 *nullfunc;
+	u8 *qosnull;
+	u8 *arpresp;
+
+	/*---------------------------------------------------------
+	 *			(1) beacon
+	 *---------------------------------------------------------
+	 */
+	beacon =3D &reserved_page_packet_8812[BEACON_PG * 512];
+	SET_80211_HDR_ADDRESS2(beacon, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(beacon, mac->bssid);
+
+	if (b_dl_finished) {
+		totalpacketlen =3D 512 - 40;
+		goto out;
+	}
+	/*-------------------------------------------------------
+	 *			(2) ps-poll
+	 *--------------------------------------------------------
+	 */
+	p_pspoll =3D &reserved_page_packet_8812[PSPOLL_PG * 512];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+
+	/*--------------------------------------------------------
+	 *			(3) null data
+	 *---------------------------------------------------------
+	 */
+	nullfunc =3D &reserved_page_packet_8812[NULL_PG * 512];
+	SET_80211_HDR_ADDRESS1(nullfunc, mac->bssid);
+	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+
+	/*---------------------------------------------------------
+	 *			(4) Qos null data
+	 *----------------------------------------------------------
+	 */
+	qosnull =3D &reserved_page_packet_8812[QOSNULL_PG * 512];
+	SET_80211_HDR_ADDRESS1(qosnull, mac->bssid);
+	SET_80211_HDR_ADDRESS2(qosnull, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(qosnull, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_QOS_NULL_DATA(u1RsvdPageLoc, QOSNULL_PG);
+
+	if (!dl_whole_packets) {
+		totalpacketlen =3D 512 * (QOSNULL_PG + 1) - 40;
+		goto out;
+	}
+	/*---------------------------------------------------------
+	 *			(5) ARP Resp
+	 *----------------------------------------------------------
+	 */
+	arpresp =3D &reserved_page_packet_8812[ARPRESP_PG * 512];
+	SET_80211_HDR_ADDRESS1(arpresp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(arpresp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(arpresp, mac->bssid);
+
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_ARP_RSP(u1RsvdPageLoc2, ARPRESP_P=
G);
+
+	/*---------------------------------------------------------
+	 *			(6) Remote Wake Ctrl
+	 *----------------------------------------------------------
+	 */
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_REMOTE_WAKE_CTRL_INFO(u1RsvdPageL=
oc2,
+								REMOTE_PG);
+
+	/*---------------------------------------------------------
+	 *			(7) GTK Ext Memory
+	 *----------------------------------------------------------
+	 */
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_EXT_MEM(u1RsvdPageLoc2, GTKEX=
T_PG);
+
+	totalpacketlen =3D TOTAL_RESERVED_PKT_LEN_8812 - 40;
+
+out:
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "rtl8812ae_set_fw_rsvdpagepkt(): packet data\n",
+		      &reserved_page_packet_8812[0], totalpacketlen);
+
+	skb =3D dev_alloc_skb(totalpacketlen);
+	memcpy((u8 *)skb_put(skb, totalpacketlen),
+	       &reserved_page_packet_8812, totalpacketlen);
+
+	rtstatus =3D _rtl8821ae_cmd_send_packet(hw, skb);
+
+	if (rtstatus)
+		b_dlok =3D true;
+
+	if (!b_dl_finished && b_dlok) {
+		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+			      "H2C_RSVDPAGE:\n", u1RsvdPageLoc, 5);
+		rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_RSVDPAGE,
+				       sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+		if (dl_whole_packets) {
+			RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+				      "wowlan H2C_RSVDPAGE:\n", u1RsvdPageLoc2, 7);
+			rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_AOAC_RSVDPAGE,
+					       sizeof(u1RsvdPageLoc2), u1RsvdPageLoc2);
+		}
+	}
+
+	if (!b_dlok)
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
+}
+
+void rtl8821ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
+				  bool b_dl_finished, bool dl_whole_packets)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct sk_buff *skb =3D NULL;
+	u32 totalpacketlen;
+	bool rtstatus;
+	u8 u1RsvdPageLoc[5] =3D { 0 };
+	u8 u1RsvdPageLoc2[7] =3D { 0 };
+	bool b_dlok =3D false;
+	u8 *beacon;
+	u8 *p_pspoll;
+	u8 *nullfunc;
+	u8 *qosnull;
+	u8 *arpresp;
+
+	/*---------------------------------------------------------
+	 *			(1) beacon
+	 *---------------------------------------------------------
+	 */
+	beacon =3D &reserved_page_packet_8821[BEACON_PG * 256];
+	SET_80211_HDR_ADDRESS2(beacon, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(beacon, mac->bssid);
+
+	if (b_dl_finished) {
+		totalpacketlen =3D 256 - 40;
+		goto out;
+	}
+	/*-------------------------------------------------------
+	 *			(2) ps-poll
+	 *--------------------------------------------------------
+	 */
+	p_pspoll =3D &reserved_page_packet_8821[PSPOLL_PG * 256];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+
+	/*--------------------------------------------------------
+	 *			(3) null data
+	 *---------------------------------------------------------i
+	 */
+	nullfunc =3D &reserved_page_packet_8821[NULL_PG * 256];
+	SET_80211_HDR_ADDRESS1(nullfunc, mac->bssid);
+	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+
+	/*---------------------------------------------------------
+	 *			(4) Qos null data
+	 *----------------------------------------------------------
+	 */
+	qosnull =3D &reserved_page_packet_8821[QOSNULL_PG * 256];
+	SET_80211_HDR_ADDRESS1(qosnull, mac->bssid);
+	SET_80211_HDR_ADDRESS2(qosnull, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(qosnull, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_QOS_NULL_DATA(u1RsvdPageLoc, QOSNULL_PG);
+
+	if (!dl_whole_packets) {
+		totalpacketlen =3D 256 * (QOSNULL_PG + 1) - 40;
+		goto out;
+	}
+	/*---------------------------------------------------------
+	 *			(5) ARP Resp
+	 *----------------------------------------------------------
+	 */
+	arpresp =3D &reserved_page_packet_8821[ARPRESP_PG * 256];
+	SET_80211_HDR_ADDRESS1(arpresp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(arpresp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(arpresp, mac->bssid);
+
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_ARP_RSP(u1RsvdPageLoc2, ARPRESP_P=
G);
+
+	/*---------------------------------------------------------
+	 *			(6) Remote Wake Ctrl
+	 *----------------------------------------------------------
+	 */
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_REMOTE_WAKE_CTRL_INFO(u1RsvdPageL=
oc2,
+									REMOTE_PG);
+
+	/*---------------------------------------------------------
+	 *			(7) GTK Ext Memory
+	 *----------------------------------------------------------
+	 */
+	SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_EXT_MEM(u1RsvdPageLoc2, GTKEX=
T_PG);
+
+	totalpacketlen =3D TOTAL_RESERVED_PKT_LEN_8821 - 40;
+
+out:
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "rtl8821ae_set_fw_rsvdpagepkt(): packet data\n",
+		      &reserved_page_packet_8821[0], totalpacketlen);
+
+	skb =3D dev_alloc_skb(totalpacketlen);
+	memcpy((u8 *)skb_put(skb, totalpacketlen),
+	       &reserved_page_packet_8821, totalpacketlen);
+
+	rtstatus =3D _rtl8821ae_cmd_send_packet(hw, skb);
+
+	if (rtstatus)
+		b_dlok =3D true;
+
+	if (!b_dl_finished && b_dlok) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Set RSVD page location to Fw.\n");
+		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+				"H2C_RSVDPAGE:\n", u1RsvdPageLoc, 5);
+		rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_RSVDPAGE,
+				       sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+		if (dl_whole_packets) {
+			RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+				      "wowlan H2C_RSVDPAGE:\n",
+				      u1RsvdPageLoc2, 7);
+			rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_AOAC_RSVDPAGE,
+					       sizeof(u1RsvdPageLoc2),
+					       u1RsvdPageLoc2);
+		}
+	}
+
+	if (!b_dlok) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set RSVD page location to Fw FAIL!!!!!!.\n");
+	}
+}
+
+/*Should check FW support p2p or not.*/
+static void rtl8821ae_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, =
u8 ctwindow)
+{
+	u8 u1_ctwindow_period[1] =3D { ctwindow};
+
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_P2P_PS_CTW_CMD, 1,
+			       u1_ctwindow_period);
+}
+
+void rtl8821ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_=
ps_state)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *rtlps =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_p2p_ps_info *p2pinfo =3D &rtlps->p2p_ps_info;
+	struct p2p_ps_offload_t *p2p_ps_offload =3D &rtlhal->p2p_ps_offload;
+	u8	i;
+	u16	ctwindow;
+	u32	start_time, tsf_low;
+
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_DISABLE\n");
+		memset(p2p_ps_offload, 0, 1);
+		break;
+	case P2P_PS_ENABLE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_ENABLE\n");
+		/* update CTWindow value. */
+		if (p2pinfo->ctwindow > 0) {
+			p2p_ps_offload->ctwindow_en =3D 1;
+			ctwindow =3D p2pinfo->ctwindow;
+			rtl8821ae_set_p2p_ctw_period_cmd(hw, ctwindow);
+		}
+
+		/* hw only support 2 set of NoA */
+		for (i =3D 0 ; i < p2pinfo->noa_num ; i++) {
+			/* To control the register setting for which NOA*/
+			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
+			if (i =3D=3D 0)
+				p2p_ps_offload->noa0_en =3D 1;
+			else
+				p2p_ps_offload->noa1_en =3D 1;
+
+			/* config P2P NoA Descriptor Register */
+			rtl_write_dword(rtlpriv, 0x5E0, p2pinfo->noa_duration[i]);
+			rtl_write_dword(rtlpriv, 0x5E4, p2pinfo->noa_interval[i]);
+
+			/*Get Current =14TSF value */
+			tsf_low =3D rtl_read_dword(rtlpriv, REG_TSFTR);
+
+			start_time =3D p2pinfo->noa_start_time[i];
+			if (p2pinfo->noa_count_type[i] !=3D 1) {
+				while (start_time <=3D (tsf_low+(50*1024))) {
+					start_time +=3D p2pinfo->noa_interval[i];
+					if (p2pinfo->noa_count_type[i] !=3D 255)
+						p2pinfo->noa_count_type[i]--;
+				}
+			}
+			rtl_write_dword(rtlpriv, 0x5E8, start_time);
+			rtl_write_dword(rtlpriv, 0x5EC,
+					p2pinfo->noa_count_type[i]);
+		}
+
+		if ((p2pinfo->opp_ps =3D=3D 1) || (p2pinfo->noa_num > 0)) {
+			/* rst p2p circuit */
+			rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, BIT(4));
+
+			p2p_ps_offload->offload_en =3D 1;
+
+			if (P2P_ROLE_GO =3D=3D rtlpriv->mac80211.p2p) {
+				p2p_ps_offload->role =3D 1;
+				p2p_ps_offload->allstasleep =3D 0;
+			} else {
+				p2p_ps_offload->role =3D 0;
+			}
+
+			p2p_ps_offload->discovery =3D 0;
+		}
+		break;
+	case P2P_PS_SCAN:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN\n");
+		p2p_ps_offload->discovery =3D 1;
+		break;
+	case P2P_PS_SCAN_DONE:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "P2P_PS_SCAN_DONE\n");
+		p2p_ps_offload->discovery =3D 0;
+		p2pinfo->p2p_ps_state =3D P2P_PS_ENABLE;
+		break;
+	default:
+		break;
+	}
+
+	rtl8821ae_fill_h2c_cmd(hw,
+			H2C_8821AE_P2P_PS_OFFLOAD, 1, (u8 *)p2p_ps_offload);
+}
+
+static void rtl8821ae_c2h_ra_report_handler(struct ieee80211_hw *hw,
+				     u8 *cmd_buf, u8 cmd_len)
+{
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 rate =3D cmd_buf[0] & 0x3F;
+
+	rtlhal->current_ra_rate =3D rtl8821ae_hw_rate_to_mrate(hw, rate);
+
+	rtl8821ae_dm_update_init_rate(hw, rate);
+}
+
+static void _rtl8821ae_c2h_content_parsing(struct ieee80211_hw *hw,
+					   u8 c2h_cmd_id, u8 c2h_cmd_len,
+					   u8 *tmp_buf)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	switch (c2h_cmd_id) {
+	case C2H_8812_DBG:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD, "[C2H], C2H_8812_DBG!!\n");
+		break;
+	case C2H_8812_RA_RPT:
+		rtl8821ae_c2h_ra_report_handler(hw, tmp_buf, c2h_cmd_len);
+		break;
+	case C2H_8812_BT_INFO:
+		RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+			 "[C2H], C2H_8812_BT_INFO!!\n");
+		if (rtlpriv->cfg->ops->get_btc_status())
+			rtlpriv->btcoexist.btc_ops->btc_btinfo_notify(rtlpriv,
+								      tmp_buf,
+								      c2h_cmd_len);
+		break;
+	default:
+		break;
+	}
+}
+
+void rtl8821ae_c2h_packet_handler(struct ieee80211_hw *hw, u8 *buffer,
+				  u8 length)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 c2h_cmd_id =3D 0, c2h_cmd_seq =3D 0, c2h_cmd_len =3D 0;
+	u8 *tmp_buf =3D NULL;
+
+	c2h_cmd_id =3D buffer[0];
+	c2h_cmd_seq =3D buffer[1];
+	c2h_cmd_len =3D length - 2;
+	tmp_buf =3D buffer + 2;
+
+	RT_TRACE(rtlpriv, COMP_FW, DBG_LOUD,
+		 "[C2H packet], c2hCmdId=3D0x%x, c2hCmdSeq=3D0x%x, c2hCmdLen=3D%d\n"=
,
+		 c2h_cmd_id, c2h_cmd_seq, c2h_cmd_len);
+
+	RT_PRINT_DATA(rtlpriv, COMP_FW, DBG_LOUD,
+		      "[C2H packet], Content Hex:\n", tmp_buf, c2h_cmd_len);
+	_rtl8821ae_c2h_content_parsing(hw, c2h_cmd_id, c2h_cmd_len, tmp_buf);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/fw.h b/drivers/net/=
wireless/rtlwifi/rtl8821ae/fw.h
new file mode 100644
index 0000000..591c14c
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/fw.h
@@ -0,0 +1,351 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE__FW__H__
+#define __RTL8821AE__FW__H__
+#include "def.h"
+
+#define FW_8821AE_SIZE					0x8000
+#define FW_8821AE_START_ADDRESS			0x1000
+#define FW_8821AE_END_ADDRESS			0x5FFF
+#define FW_8821AE_PAGE_SIZE				4096
+#define FW_8821AE_POLLING_DELAY			5
+#define FW_8821AE_POLLING_TIMEOUT_COUNT	6000
+
+#define IS_FW_HEADER_EXIST_8812(_pfwhdr)	\
+	((_pfwhdr->signature&0xFFF0) =3D=3D 0x9500)
+
+#define IS_FW_HEADER_EXIST_8821(_pfwhdr)	\
+	((_pfwhdr->signature&0xFFF0) =3D=3D 0x2100)
+
+#define USE_OLD_WOWLAN_DEBUG_FW 0
+
+#define H2C_8821AE_RSVDPAGE_LOC_LEN		5
+#define H2C_8821AE_PWEMODE_LENGTH			5
+#define H2C_8821AE_JOINBSSRPT_LENGTH		1
+#define H2C_8821AE_AP_OFFLOAD_LENGTH		3
+#define H2C_8821AE_WOWLAN_LENGTH			3
+#define H2C_8821AE_KEEP_ALIVE_CTRL_LENGTH	3
+#if (USE_OLD_WOWLAN_DEBUG_FW =3D=3D 0)
+#define H2C_8821AE_REMOTE_WAKE_CTRL_LEN	1
+#else
+#define H2C_8821AE_REMOTE_WAKE_CTRL_LEN	3
+#endif
+#define H2C_8821AE_AOAC_GLOBAL_INFO_LEN	2
+#define H2C_8821AE_AOAC_RSVDPAGE_LOC_LEN	7
+#define H2C_8821AE_DISCONNECT_DECISION_CTRL_LEN	3
+
+/* Fw PS state for RPWM.
+*BIT[2:0] =3D HW state
+
+*BIT[3] =3D Protocol PS state,
+1: register active state ,
+0: register sleep state
+
+*BIT[4] =3D sub-state
+*/
+#define	FW_PS_GO_ON			BIT(0)
+#define	FW_PS_TX_NULL			BIT(1)
+#define	FW_PS_RF_ON			BIT(2)
+#define	FW_PS_REGISTER_ACTIVE	BIT(3)
+
+#define	FW_PS_DPS		BIT(0)
+#define	FW_PS_LCLK		(FW_PS_DPS)
+#define	FW_PS_RF_OFF		BIT(1)
+#define	FW_PS_ALL_ON		BIT(2)
+#define	FW_PS_ST_ACTIVE		BIT(3)
+#define	FW_PS_ISR_ENABLE	BIT(4)
+#define	FW_PS_IMR_ENABLE	BIT(5)
+
+#define	FW_PS_ACK		BIT(6)
+#define	FW_PS_TOGGLE		BIT(7)
+
+ /* 8821AE RPWM value*/
+ /* BIT[0] =3D 1: 32k, 0: 40M*/
+ /* 32k*/
+#define	FW_PS_CLOCK_OFF		BIT(0)
+/*40M*/
+#define	FW_PS_CLOCK_ON		0
+
+#define	FW_PS_STATE_MASK		(0x0F)
+#define	FW_PS_STATE_HW_MASK	(0x07)
+/*ISR_ENABLE, IMR_ENABLE, and PS mode should be inherited.*/
+#define	FW_PS_STATE_INT_MASK	(0x3F)
+
+#define	FW_PS_STATE(x)			(FW_PS_STATE_MASK & (x))
+#define	FW_PS_STATE_HW(x)		(FW_PS_STATE_HW_MASK & (x))
+#define	FW_PS_STATE_INT(x)	(FW_PS_STATE_INT_MASK & (x))
+#define	FW_PS_ISR_VAL(x)		((x) & 0x70)
+#define	FW_PS_IMR_MASK(x)	((x) & 0xDF)
+#define	FW_PS_KEEP_IMR(x)		((x) & 0x20)
+
+#define	FW_PS_STATE_S0		(FW_PS_DPS)
+#define	FW_PS_STATE_S1		(FW_PS_LCLK)
+#define	FW_PS_STATE_S2		(FW_PS_RF_OFF)
+#define	FW_PS_STATE_S3		(FW_PS_ALL_ON)
+#define	FW_PS_STATE_S4		((FW_PS_ST_ACTIVE) | (FW_PS_ALL_ON))
+ /* ((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))*/
+#define	FW_PS_STATE_ALL_ON_8821AE	(FW_PS_CLOCK_ON)
+ /* (FW_PS_RF_ON)*/
+#define	FW_PS_STATE_RF_ON_8821AE	(FW_PS_CLOCK_ON)
+ /* 0x0*/
+#define	FW_PS_STATE_RF_OFF_8821AE	(FW_PS_CLOCK_ON)
+ /* (FW_PS_STATE_RF_OFF)*/
+#define	FW_PS_STATE_RF_OFF_LOW_PWR_8821AE	(FW_PS_CLOCK_OFF)
+
+#define	FW_PS_STATE_ALL_ON_92C	(FW_PS_STATE_S4)
+#define	FW_PS_STATE_RF_ON_92C		(FW_PS_STATE_S3)
+#define	FW_PS_STATE_RF_OFF_92C	(FW_PS_STATE_S2)
+#define	FW_PS_STATE_RF_OFF_LOW_PWR_92C	(FW_PS_STATE_S1)
+
+/* For 8821AE H2C PwrMode Cmd ID 5.*/
+#define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
+#define	FW_PWR_STATE_RF_OFF	0
+
+#define	FW_PS_IS_ACK(x)		((x) & FW_PS_ACK)
+#define	FW_PS_IS_CLK_ON(x)	((x) & (FW_PS_RF_OFF | FW_PS_ALL_ON))
+#define	FW_PS_IS_RF_ON(x)	((x) & (FW_PS_ALL_ON))
+#define	FW_PS_IS_ACTIVE(x)	((x) & (FW_PS_ST_ACTIVE))
+#define	FW_PS_IS_CPWM_INT(x)	((x) & 0x40)
+
+#define	FW_CLR_PS_STATE(x)	((x) =3D ((x) & (0xF0)))
+
+#define	IS_IN_LOW_POWER_STATE_8821AE(__state)		\
+			(FW_PS_STATE(__state) =3D=3D FW_PS_CLOCK_OFF)
+
+#define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
+#define	FW_PWR_STATE_RF_OFF	0
+
+struct rtl8821a_firmware_header {
+	u16 signature;
+	u8 category;
+	u8 function;
+	u16 version;
+	u8 subversion;
+	u8 rsvd1;
+	u8 month;
+	u8 date;
+	u8 hour;
+	u8 minute;
+	u16 ramcodeSize;
+	u16 rsvd2;
+	u32 svnindex;
+	u32 rsvd3;
+	u32 rsvd4;
+	u32 rsvd5;
+};
+
+enum rtl8812_c2h_evt {
+	C2H_8812_DBG =3D 0,
+	C2H_8812_LB =3D 1,
+	C2H_8812_TXBF =3D 2,
+	C2H_8812_TX_REPORT =3D 3,
+	C2H_8812_BT_INFO =3D 9,
+	C2H_8812_BT_MP =3D 11,
+	C2H_8812_RA_RPT =3D 12,
+
+	C2H_8812_FW_SWCHNL =3D 0x10,
+	C2H_8812_IQK_FINISH =3D 0x11,
+	MAX_8812_C2HEVENT
+};
+
+enum rtl8821a_h2c_cmd {
+	H2C_8821AE_RSVDPAGE =3D 0,
+	H2C_8821AE_MSRRPT =3D 1,
+	H2C_8821AE_SCAN =3D 2,
+	H2C_8821AE_KEEP_ALIVE_CTRL =3D 3,
+	H2C_8821AE_DISCONNECT_DECISION =3D 4,
+	H2C_8821AE_INIT_OFFLOAD =3D 6,
+	H2C_8821AE_AP_OFFLOAD =3D 8,
+	H2C_8821AE_BCN_RSVDPAGE =3D 9,
+	H2C_8821AE_PROBERSP_RSVDPAGE =3D 10,
+
+	H2C_8821AE_SETPWRMODE =3D 0x20,
+	H2C_8821AE_PS_TUNING_PARA =3D 0x21,
+	H2C_8821AE_PS_TUNING_PARA2 =3D 0x22,
+	H2C_8821AE_PS_LPS_PARA =3D 0x23,
+	H2C_8821AE_P2P_PS_OFFLOAD =3D 024,
+
+	H2C_8821AE_WO_WLAN =3D 0x80,
+	H2C_8821AE_REMOTE_WAKE_CTRL =3D 0x81,
+	H2C_8821AE_AOAC_GLOBAL_INFO =3D 0x82,
+	H2C_8821AE_AOAC_RSVDPAGE =3D 0x83,
+
+	H2C_RSSI_21AE_REPORT =3D 0x42,
+	H2C_8821AE_RA_MASK =3D 0x40,
+	H2C_8821AE_SELECTIVE_SUSPEND_ROF_CMD,
+	H2C_8821AE_P2P_PS_MODE,
+	H2C_8821AE_PSD_RESULT,
+	/*Not defined CTW CMD for P2P yet*/
+	H2C_8821AE_P2P_PS_CTW_CMD,
+	MAX_8821AE_H2CCMD
+};
+
+#define pagenum_128(_len)	(u32)(((_len)>>7) + ((_len)&0x7F ? 1 : 0))
+
+#define SET_8812_H2CCMD_WOWLAN_FUNC_ENABLE(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_PATTERN_MATCH_ENABLE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 1, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_MAGIC_PKT_ENABLE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 2, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_UNICAST_PKT_ENABLE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 3, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_ALL_PKT_DROP(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE(__cmd, 4, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_GPIO_ACTIVE(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE(__cmd, 5, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_REKEY_WAKE_UP(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 6, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_DISCONNECT_WAKE_UP(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 7, 1, __value)
+#define SET_8812_H2CCMD_WOWLAN_GPIONUM(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE((__cmd) + 1, 0, 8, __value)
+#define SET_8812_H2CCMD_WOWLAN_GPIO_DURATION(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd) + 2, 0, 8, __value)
+
+#define SET_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd, __val)			\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_PWRMODE_PARM_RLBM(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 4, __value)
+#define SET_H2CCMD_PWRMODE_PARM_SMART_PS(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 4, 4, __value)
+#define SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+2, 0, 8, __value)
+#define SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(__cmd, __value)		\
+	SET_BITS_TO_LE_1BYTE((__cmd)+3, 0, 8, __value)
+#define SET_H2CCMD_PWRMODE_PARM_PWR_STATE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+4, 0, 8, __value)
+#define GET_8821AE_H2CCMD_PWRMODE_PARM_MODE(__cmd)		\
+	LE_BITS_TO_1BYTE(__cmd, 0, 8)
+
+#define SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_QOS_NULL_DATA(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+3, 0, 8, __val)
+
+/* _MEDIA_STATUS_RPT_PARM_CMD1 */
+#define SET_H2CCMD_MSRRPT_PARM_OPMODE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 1, __value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID_IND(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 1, 1, __value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd+1, 0, 8, __value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID_END(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd+2, 0, 8, __value)
+
+/* AP_OFFLOAD */
+#define SET_H2CCMD_AP_OFFLOAD_ON(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 8, __value)
+#define SET_H2CCMD_AP_OFFLOAD_HIDDEN(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 8, __value)
+#define SET_H2CCMD_AP_OFFLOAD_DENYANY(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+2, 0, 8, __value)
+#define SET_H2CCMD_AP_OFFLOAD_WAKEUP_EVT_RPT(__cmd, __value) \
+	SET_BITS_TO_LE_1BYTE((__cmd)+3, 0, 8, __value)
+
+/* Keep Alive Control*/
+#define SET_8812_H2CCMD_KEEP_ALIVE_ENABLE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 1, __value)
+#define SET_8812_H2CCMD_KEEP_ALIVE_ACCPEPT_USER_DEFINED(__cmd, __value=
)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 1, 1, __value)
+#define SET_8812_H2CCMD_KEEP_ALIVE_PERIOD(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 8, __value)
+
+/*REMOTE_WAKE_CTRL */
+#define SET_8812_H2CCMD_REMOTE_WAKECTRL_ENABLE(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 1, __value)
+#define SET_8812_H2CCMD_REMOTE_WAKE_CTRL_ARP_OFFLOAD_EN(__cmd, __value=
)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 1, 1, __value)
+#define SET_8812_H2CCMD_REMOTE_WAKE_CTRL_NDP_OFFLOAD_EN(__cmd, __value=
)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 2, 1, __value)
+#define SET_8812_H2CCMD_REMOTE_WAKE_CTRL_GTK_OFFLOAD_EN(__cmd, __value=
)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 3, 1, __value)
+#define SET_8812_H2CCMD_REMOTE_WAKE_CTRL_REALWOWV2_EN(__cmd, __value)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 6, 1, __value)
+
+/* GTK_OFFLOAD */
+#define SET_8812_H2CCMD_AOAC_GLOBAL_INFO_PAIRWISE_ENC_ALG(__cmd, __val=
ue)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 8, __value)
+#define SET_8812_H2CCMD_AOAC_GLOBAL_INFO_GROUP_ENC_ALG(__cmd, __value)=
	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 8, __value)
+
+/* AOAC_RSVDPAGE_LOC */
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_REMOTE_WAKE_CTRL_INFO(__cm=
d, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd), 0, 8, __value)
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_ARP_RSP(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 8, __value)
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_NEIGHBOR_ADV(__cmd, __valu=
e)\
+	SET_BITS_TO_LE_1BYTE((__cmd)+2, 0, 8, __value)
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_RSP(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+3, 0, 8, __value)
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_INFO(__cmd, __value)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+4, 0, 8, __value)
+#define SET_8821AE_H2CCMD_AOAC_RSVDPAGE_LOC_GTK_EXT_MEM(__cmd, __value=
)	\
+	SET_BITS_TO_LE_1BYTE((__cmd)+5, 0, 8, __value)
+
+/* Disconnect_Decision_Control */
+#define SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_ENABLE(__cmd, __value=
)	\
+	SET_BITS_TO_LE_1BYTE(__cmd, 0, 1, __value)
+#define SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_USER_SETTING(__cmd, _=
_value)\
+	SET_BITS_TO_LE_1BYTE(__cmd, 1, 1, __value)
+#define SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_CHECK_PERIOD(__cmd, _=
_value)\
+	SET_BITS_TO_LE_1BYTE((__cmd)+1, 0, 8, __value) /* unit: beacon period=
 */
+#define SET_8812_H2CCMD_DISCONNECT_DECISION_CTRL_TRYPKT_NUM(__cmd, __v=
alue)\
+	SET_BITS_TO_LE_1BYTE((__cmd)+2, 0, 8, __value)
+
+int rtl8821ae_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_w=
lan_fw);
+#if (USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN =3D=3D 1)
+void rtl8821ae_set_fw_related_for_wowlan(struct ieee80211_hw *hw,
+					 bool used_wowlan_fw);
+
+#endif
+void rtl8821ae_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
+			    u32 cmd_len, u8 *cmdbuffer);
+void rtl8821ae_firmware_selfreset(struct ieee80211_hw *hw);
+void rtl8821ae_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
+void rtl8821ae_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw,
+					   u8 mstatus);
+void rtl8821ae_set_fw_ap_off_load_cmd(struct ieee80211_hw *hw,
+				      u8 ap_offload_enable);
+void rtl8821ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
+				  bool b_dl_finished, bool dl_whole_packet);
+void rtl8812ae_set_fw_rsvdpagepkt(struct ieee80211_hw *hw,
+				  bool b_dl_finished, bool dl_whole_packet);
+void rtl8821ae_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw,
+				      u8 p2p_ps_state);
+void rtl8821ae_set_fw_wowlan_mode(struct ieee80211_hw *hw, bool func_e=
n);
+void rtl8821ae_set_fw_remote_wake_ctrl_cmd(struct ieee80211_hw *hw,
+					   u8 enable);
+void rtl8821ae_set_fw_keep_alive_cmd(struct ieee80211_hw *hw, bool fun=
c_en);
+void rtl8821ae_set_fw_disconnect_decision_ctrl_cmd(struct ieee80211_hw=
 *hw,
+						   bool enabled);
+void rtl8821ae_set_fw_global_info_cmd(struct ieee80211_hw *hw);
+void rtl8821ae_c2h_packet_handler(struct ieee80211_hw *hw,
+				  u8 *buffer, u8 length);
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/=
wireless/rtlwifi/rtl8821ae/hw.c
new file mode 100644
index 0000000..58bbaf4
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -0,0 +1,4215 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../efuse.h"
+#include "../base.h"
+#include "../regd.h"
+#include "../cam.h"
+#include "../ps.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "dm.h"
+#include "fw.h"
+#include "led.h"
+#include "hw.h"
+#include "../pwrseqcmd.h"
+#include "pwrseq.h"
+#include "../btcoexist/rtl_btc.h"
+
+#define LLT_CONFIG	5
+
+static void _rtl8821ae_return_beacon_queue_skb(struct ieee80211_hw *hw=
)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring =3D &rtlpci->tx_ring[BEACON_QUEUE];
+
+	while (skb_queue_len(&ring->queue)) {
+		struct rtl_tx_desc *entry =3D &ring->desc[ring->idx];
+		struct sk_buff *skb =3D __skb_dequeue(&ring->queue);
+
+		pci_unmap_single(rtlpci->pdev,
+				 rtlpriv->cfg->ops->get_desc(
+				 (u8 *)entry, true, HW_DESC_TXBUFF_ADDR),
+				 skb->len, PCI_DMA_TODEVICE);
+		kfree_skb(skb);
+		ring->idx =3D (ring->idx + 1) % ring->entries;
+	}
+}
+
+static void _rtl8821ae_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
+					u8 set_bits, u8 clear_bits)
+{
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtlpci->reg_bcn_ctrl_val |=3D set_bits;
+	rtlpci->reg_bcn_ctrl_val &=3D ~clear_bits;
+
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8)rtlpci->reg_bcn_ctrl_val);
+}
+
+void _rtl8821ae_stop_tx_beacon(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 tmp1byte;
+
+	tmp1byte =3D rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp1byte & (~BIT(6)));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0x64);
+	tmp1byte =3D rtl_read_byte(rtlpriv, REG_TBTT_PROHIBIT + 2);
+	tmp1byte &=3D ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp1byte);
+}
+
+void _rtl8821ae_resume_tx_beacon(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 tmp1byte;
+
+	tmp1byte =3D rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp1byte | BIT(6));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0xff);
+	tmp1byte =3D rtl_read_byte(rtlpriv, REG_TBTT_PROHIBIT + 2);
+	tmp1byte |=3D BIT(0);
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp1byte);
+}
+
+static void _rtl8821ae_enable_bcn_sub_func(struct ieee80211_hw *hw)
+{
+	_rtl8821ae_set_bcn_ctrl_reg(hw, 0, BIT(1));
+}
+
+static void _rtl8821ae_disable_bcn_sub_func(struct ieee80211_hw *hw)
+{
+	_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(1), 0);
+}
+
+static void _rtl8821ae_set_fw_clock_on(struct ieee80211_hw *hw,
+				       u8 rpwm_val, bool b_need_turn_off_ckk)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	bool b_support_remote_wake_up;
+	u32 count =3D 0, isr_regaddr, content;
+	bool b_schedule_timer =3D b_need_turn_off_ckk;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+					(u8 *)(&b_support_remote_wake_up));
+
+	if (!rtlhal->fw_ready)
+		return;
+	if (!rtlpriv->psc.fw_current_inpsmode)
+		return;
+
+	while (1) {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (rtlhal->fw_clk_change_in_progress) {
+			while (rtlhal->fw_clk_change_in_progress) {
+				spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+				count++;
+				udelay(100);
+				if (count > 1000)
+					goto change_done;
+				spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+			}
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		} else {
+			rtlhal->fw_clk_change_in_progress =3D false;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			goto change_done;
+		}
+	}
+change_done:
+	if (IS_IN_LOW_POWER_STATE_8821AE(rtlhal->fw_ps_state)) {
+		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM,
+					(u8 *)(&rpwm_val));
+		if (FW_PS_IS_ACK(rpwm_val)) {
+			isr_regaddr =3D REG_HISR;
+			content =3D rtl_read_dword(rtlpriv, isr_regaddr);
+			while (!(content & IMR_CPWM) && (count < 500)) {
+				udelay(50);
+				count++;
+				content =3D rtl_read_dword(rtlpriv, isr_regaddr);
+			}
+
+			if (content & IMR_CPWM) {
+				rtl_write_word(rtlpriv, isr_regaddr, 0x0100);
+				rtlhal->fw_ps_state =3D FW_PS_STATE_RF_ON_8821AE;
+				RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+					 "Receive CPWM INT!!! Set rtlhal->FwPSState =3D %X\n",
+					 rtlhal->fw_ps_state);
+			}
+		}
+
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		rtlhal->fw_clk_change_in_progress =3D false;
+		spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (b_schedule_timer)
+			mod_timer(&rtlpriv->works.fw_clockoff_timer,
+				  jiffies + MSECS(10));
+	} else  {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		rtlhal->fw_clk_change_in_progress =3D false;
+		spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+	}
+}
+
+static void _rtl8821ae_set_fw_clock_off(struct ieee80211_hw *hw,
+					u8 rpwm_val)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	enum rf_pwrstate rtstate;
+	bool b_schedule_timer =3D false;
+	u8 queue;
+
+	if (!rtlhal->fw_ready)
+		return;
+	if (!rtlpriv->psc.fw_current_inpsmode)
+		return;
+	if (!rtlhal->allow_sw_to_change_hwclc)
+		return;
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RF_STATE, (u8 *)(&rtstate));
+	if (rtstate =3D=3D ERFOFF || rtlpriv->psc.inactive_pwrstate =3D=3D ER=
=46OFF)
+		return;
+
+	for (queue =3D 0; queue < RTL_PCI_MAX_TX_QUEUE_COUNT; queue++) {
+		ring =3D &rtlpci->tx_ring[queue];
+		if (skb_queue_len(&ring->queue)) {
+			b_schedule_timer =3D true;
+			break;
+		}
+	}
+
+	if (b_schedule_timer) {
+		mod_timer(&rtlpriv->works.fw_clockoff_timer,
+			  jiffies + MSECS(10));
+		return;
+	}
+
+	if (FW_PS_STATE(rtlhal->fw_ps_state) !=3D
+		FW_PS_STATE_RF_OFF_LOW_PWR_8821AE) {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (!rtlhal->fw_clk_change_in_progress) {
+			rtlhal->fw_clk_change_in_progress =3D true;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			rtlhal->fw_ps_state =3D FW_PS_STATE(rpwm_val);
+			rtl_write_word(rtlpriv, REG_HISR, 0x0100);
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+						      (u8 *)(&rpwm_val));
+			spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+			rtlhal->fw_clk_change_in_progress =3D false;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		} else {
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			mod_timer(&rtlpriv->works.fw_clockoff_timer,
+				  jiffies + MSECS(10));
+		}
+	}
+}
+
+static void _rtl8821ae_set_fw_ps_rf_on(struct ieee80211_hw *hw)
+{
+	u8 rpwm_val =3D 0;
+
+	rpwm_val |=3D (FW_PS_STATE_RF_OFF_8821AE | FW_PS_ACK);
+	_rtl8821ae_set_fw_clock_on(hw, rpwm_val, true);
+}
+
+static void _rtl8821ae_fwlps_leave(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	bool fw_current_inps =3D false;
+	u8 rpwm_val =3D 0, fw_pwrmode =3D FW_PS_ACTIVE_MODE;
+
+	if (ppsc->low_power_enable) {
+		rpwm_val =3D (FW_PS_STATE_ALL_ON_8821AE|FW_PS_ACK);/* RF on */
+		_rtl8821ae_set_fw_clock_on(hw, rpwm_val, false);
+		rtlhal->allow_sw_to_change_hwclc =3D false;
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+				(u8 *)(&fw_pwrmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				(u8 *)(&fw_current_inps));
+	} else {
+		rpwm_val =3D FW_PS_STATE_ALL_ON_8821AE;	/* RF on */
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+				(u8 *)(&rpwm_val));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+				(u8 *)(&fw_pwrmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				(u8 *)(&fw_current_inps));
+	}
+}
+
+static void _rtl8821ae_fwlps_enter(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	bool fw_current_inps =3D true;
+	u8 rpwm_val;
+
+	if (ppsc->low_power_enable) {
+		rpwm_val =3D FW_PS_STATE_RF_OFF_LOW_PWR_8821AE;	/* RF off */
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_FW_PSMODE_STATUS,
+				(u8 *)(&fw_current_inps));
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_H2C_FW_PWRMODE,
+				(u8 *)(&ppsc->fwctrl_psmode));
+		rtlhal->allow_sw_to_change_hwclc =3D true;
+		_rtl8821ae_set_fw_clock_off(hw, rpwm_val);
+	} else {
+		rpwm_val =3D FW_PS_STATE_RF_OFF_8821AE;	/* RF off */
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_FW_PSMODE_STATUS,
+				(u8 *)(&fw_current_inps));
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_H2C_FW_PWRMODE,
+				(u8 *)(&ppsc->fwctrl_psmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+				HW_VAR_SET_RPWM,
+				(u8 *)(&rpwm_val));
+	}
+}
+
+static void _rtl8821ae_download_rsvd_page(struct ieee80211_hw *hw,
+					  bool dl_whole_packets)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	u8 tmp_regcr, tmp_reg422, bcnvalid_reg;
+	u8 count =3D 0, dlbcn_count =3D 0;
+	bool send_beacon =3D false;
+
+	tmp_regcr =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, (tmp_regcr | BIT(0)));
+
+	_rtl8821ae_set_bcn_ctrl_reg(hw, 0, BIT(3));
+	_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(4), 0);
+
+	tmp_reg422 =3D rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2,
+		       tmp_reg422 & (~BIT(6)));
+	if (tmp_reg422 & BIT(6))
+		send_beacon =3D true;
+
+	do {
+		bcnvalid_reg =3D rtl_read_byte(rtlpriv, REG_TDECTRL + 2);
+		rtl_write_byte(rtlpriv, REG_TDECTRL + 2,
+			       (bcnvalid_reg | BIT(0)));
+		_rtl8821ae_return_beacon_queue_skb(hw);
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_set_fw_rsvdpagepkt(hw, false,
+						     dl_whole_packets);
+		else
+			rtl8821ae_set_fw_rsvdpagepkt(hw, false,
+						     dl_whole_packets);
+
+		bcnvalid_reg =3D rtl_read_byte(rtlpriv, REG_TDECTRL + 2);
+		count =3D 0;
+		while (!(bcnvalid_reg & BIT(0)) && count < 20) {
+			count++;
+			udelay(10);
+			bcnvalid_reg =3D rtl_read_byte(rtlpriv, REG_TDECTRL + 2);
+		}
+		dlbcn_count++;
+	} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
+
+	if (!(bcnvalid_reg & BIT(0)))
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Download RSVD page failed!\n");
+	if (bcnvalid_reg & BIT(0) && rtlhal->enter_pnp_sleep) {
+		rtl_write_byte(rtlpriv, REG_TDECTRL + 2, bcnvalid_reg | BIT(0));
+		_rtl8821ae_return_beacon_queue_skb(hw);
+		if (send_beacon) {
+			dlbcn_count =3D 0;
+			do {
+				rtl_write_byte(rtlpriv, REG_TDECTRL + 2,
+					       bcnvalid_reg | BIT(0));
+
+				_rtl8821ae_return_beacon_queue_skb(hw);
+
+				if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+					rtl8812ae_set_fw_rsvdpagepkt(hw, true,
+								     false);
+				else
+					rtl8821ae_set_fw_rsvdpagepkt(hw, true,
+								     false);
+
+				/* check rsvd page download OK. */
+				bcnvalid_reg =3D rtl_read_byte(rtlpriv,
+							     REG_TDECTRL + 2);
+				count =3D 0;
+				while (!(bcnvalid_reg & BIT(0)) && count < 20) {
+					count++;
+					udelay(10);
+					bcnvalid_reg =3D
+					  rtl_read_byte(rtlpriv,
+							REG_TDECTRL + 2);
+				}
+				dlbcn_count++;
+			} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
+
+			if (!(bcnvalid_reg & BIT(0)))
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "2 Download RSVD page failed!\n");
+		}
+	}
+
+	if (bcnvalid_reg & BIT(0))
+		rtl_write_byte(rtlpriv, REG_TDECTRL + 2, BIT(0));
+
+	_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(3), 0);
+	_rtl8821ae_set_bcn_ctrl_reg(hw, 0, BIT(4));
+
+	if (send_beacon)
+		rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp_reg422);
+
+	if (!rtlhal->enter_pnp_sleep) {
+		tmp_regcr =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+		rtl_write_byte(rtlpriv, REG_CR + 1, (tmp_regcr & ~(BIT(0))));
+	}
+}
+
+void rtl8821ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *va=
l)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+
+	switch (variable) {
+	case HW_VAR_ETHER_ADDR:
+		*((u32 *)(val)) =3D rtl_read_dword(rtlpriv, REG_MACID);
+		*((u16 *)(val+4)) =3D rtl_read_word(rtlpriv, REG_MACID + 4);
+		break;
+	case HW_VAR_BSSID:
+		*((u32 *)(val)) =3D rtl_read_dword(rtlpriv, REG_BSSID);
+		*((u16 *)(val+4)) =3D rtl_read_word(rtlpriv, REG_BSSID+4);
+		break;
+	case HW_VAR_MEDIA_STATUS:
+		val[0] =3D rtl_read_byte(rtlpriv, REG_CR+2) & 0x3;
+		break;
+	case HW_VAR_SLOT_TIME:
+		*((u8 *)(val)) =3D mac->slot_time;
+		break;
+	case HW_VAR_BEACON_INTERVAL:
+		*((u16 *)(val)) =3D rtl_read_word(rtlpriv, REG_BCN_INTERVAL);
+		break;
+	case HW_VAR_ATIM_WINDOW:
+		*((u16 *)(val)) =3D  rtl_read_word(rtlpriv, REG_ATIMWND);
+		break;
+	case HW_VAR_RCR:
+		*((u32 *)(val)) =3D rtlpci->receive_config;
+		break;
+	case HW_VAR_RF_STATE:
+		*((enum rf_pwrstate *)(val)) =3D ppsc->rfpwr_state;
+		break;
+	case HW_VAR_FWLPS_RF_ON:{
+		enum rf_pwrstate rfstate;
+		u32 val_rcr;
+
+		rtlpriv->cfg->ops->get_hw_reg(hw,
+					      HW_VAR_RF_STATE,
+					      (u8 *)(&rfstate));
+		if (rfstate =3D=3D ERFOFF) {
+			*((bool *)(val)) =3D true;
+		} else {
+			val_rcr =3D rtl_read_dword(rtlpriv, REG_RCR);
+			val_rcr &=3D 0x00070000;
+			if (val_rcr)
+				*((bool *)(val)) =3D false;
+			else
+				*((bool *)(val)) =3D true;
+		}
+		break; }
+	case HW_VAR_FW_PSMODE_STATUS:
+		*((bool *)(val)) =3D ppsc->fw_current_inpsmode;
+		break;
+	case HW_VAR_CORRECT_TSF:{
+		u64 tsf;
+		u32 *ptsf_low =3D (u32 *)&tsf;
+		u32 *ptsf_high =3D ((u32 *)&tsf) + 1;
+
+		*ptsf_high =3D rtl_read_dword(rtlpriv, (REG_TSFTR + 4));
+		*ptsf_low =3D rtl_read_dword(rtlpriv, REG_TSFTR);
+
+		*((u64 *)(val)) =3D tsf;
+
+		break; }
+	case HAL_DEF_WOWLAN:
+		if (ppsc->wo_wlan_mode)
+			*((bool *)(val)) =3D true;
+		else
+			*((bool *)(val)) =3D false;
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process %x\n", variable);
+		break;
+	}
+}
+
+void rtl8821ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *va=
l)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 idx;
+
+	switch (variable) {
+	case HW_VAR_ETHER_ADDR:{
+			for (idx =3D 0; idx < ETH_ALEN; idx++) {
+				rtl_write_byte(rtlpriv, (REG_MACID + idx),
+					       val[idx]);
+			}
+			break;
+		}
+	case HW_VAR_BASIC_RATE:{
+			u16 b_rate_cfg =3D ((u16 *)val)[0];
+			b_rate_cfg =3D b_rate_cfg & 0x15f;
+			rtl_write_word(rtlpriv, REG_RRSR, b_rate_cfg);
+			break;
+		}
+	case HW_VAR_BSSID:{
+			for (idx =3D 0; idx < ETH_ALEN; idx++) {
+				rtl_write_byte(rtlpriv, (REG_BSSID + idx),
+					       val[idx]);
+			}
+			break;
+		}
+	case HW_VAR_SIFS:
+		rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
+		rtl_write_byte(rtlpriv, REG_SIFS_TRX + 1, val[0]);
+
+		rtl_write_byte(rtlpriv, REG_SPEC_SIFS + 1, val[0]);
+		rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
+
+		rtl_write_byte(rtlpriv, REG_RESP_SIFS_OFDM + 1, val[0]);
+		rtl_write_byte(rtlpriv, REG_RESP_SIFS_OFDM, val[0]);
+		break;
+	case HW_VAR_R2T_SIFS:
+		rtl_write_byte(rtlpriv, REG_RESP_SIFS_OFDM + 1, val[0]);
+		break;
+	case HW_VAR_SLOT_TIME:{
+		u8 e_aci;
+
+		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+			 "HW_VAR_SLOT_TIME %x\n", val[0]);
+
+		rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
+
+		for (e_aci =3D 0; e_aci < AC_MAX; e_aci++) {
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_AC_PARAM,
+						      (u8 *)(&e_aci));
+		}
+		break; }
+	case HW_VAR_ACK_PREAMBLE:{
+		u8 reg_tmp;
+		u8 short_preamble =3D (bool)(*(u8 *)val);
+
+		reg_tmp =3D rtl_read_byte(rtlpriv, REG_TRXPTCL_CTL+2);
+		if (short_preamble) {
+			reg_tmp |=3D BIT(1);
+			rtl_write_byte(rtlpriv, REG_TRXPTCL_CTL + 2,
+				       reg_tmp);
+		} else {
+			reg_tmp &=3D (~BIT(1));
+			rtl_write_byte(rtlpriv,
+				REG_TRXPTCL_CTL + 2,
+				reg_tmp);
+		}
+		break; }
+	case HW_VAR_WPA_CONFIG:
+		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *)val));
+		break;
+	case HW_VAR_AMPDU_MIN_SPACE:{
+		u8 min_spacing_to_set;
+		u8 sec_min_space;
+
+		min_spacing_to_set =3D *((u8 *)val);
+		if (min_spacing_to_set <=3D 7) {
+			sec_min_space =3D 0;
+
+			if (min_spacing_to_set < sec_min_space)
+				min_spacing_to_set =3D sec_min_space;
+
+			mac->min_space_cfg =3D ((mac->min_space_cfg &
+					       0xf8) |
+					      min_spacing_to_set);
+
+			*val =3D min_spacing_to_set;
+
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+				 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+				  mac->min_space_cfg);
+
+			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
+				       mac->min_space_cfg);
+		}
+		break; }
+	case HW_VAR_SHORTGI_DENSITY:{
+		u8 density_to_set;
+
+		density_to_set =3D *((u8 *)val);
+		mac->min_space_cfg |=3D (density_to_set << 3);
+
+		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+			 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+			  mac->min_space_cfg);
+
+		rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
+			       mac->min_space_cfg);
+
+		break; }
+	case HW_VAR_AMPDU_FACTOR:{
+		u32	ampdu_len =3D  (*((u8 *)val));
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			if (ampdu_len < VHT_AGG_SIZE_128K)
+				ampdu_len =3D
+					(0x2000 << (*((u8 *)val))) - 1;
+			else
+				ampdu_len =3D 0x1ffff;
+		} else if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			if (ampdu_len < HT_AGG_SIZE_64K)
+				ampdu_len =3D
+					(0x2000 << (*((u8 *)val))) - 1;
+			else
+				ampdu_len =3D 0xffff;
+		}
+		ampdu_len |=3D BIT(31);
+
+		rtl_write_dword(rtlpriv,
+			REG_AMPDU_MAX_LENGTH_8812, ampdu_len);
+		break; }
+	case HW_VAR_AC_PARAM:{
+		u8 e_aci =3D *((u8 *)val);
+
+		rtl8821ae_dm_init_edca_turbo(hw);
+		if (rtlpci->acm_method !=3D EACMWAY2_SW)
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_ACM_CTRL,
+						      (u8 *)(&e_aci));
+		break; }
+	case HW_VAR_ACM_CTRL:{
+		u8 e_aci =3D *((u8 *)val);
+		union aci_aifsn *p_aci_aifsn =3D
+		    (union aci_aifsn *)(&mac->ac[0].aifs);
+		u8 acm =3D p_aci_aifsn->f.acm;
+		u8 acm_ctrl =3D rtl_read_byte(rtlpriv, REG_ACMHWCTRL);
+
+		acm_ctrl =3D
+		    acm_ctrl | ((rtlpci->acm_method =3D=3D 2) ? 0x0 : 0x1);
+
+		if (acm) {
+			switch (e_aci) {
+			case AC0_BE:
+				acm_ctrl |=3D ACMHW_BEQEN;
+				break;
+			case AC2_VI:
+				acm_ctrl |=3D ACMHW_VIQEN;
+				break;
+			case AC3_VO:
+				acm_ctrl |=3D ACMHW_VOQEN;
+				break;
+			default:
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+					 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+					 acm);
+				break;
+			}
+		} else {
+			switch (e_aci) {
+			case AC0_BE:
+				acm_ctrl &=3D (~ACMHW_BEQEN);
+				break;
+			case AC2_VI:
+				acm_ctrl &=3D (~ACMHW_VIQEN);
+				break;
+			case AC3_VO:
+				acm_ctrl &=3D (~ACMHW_BEQEN);
+				break;
+			default:
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+					 "switch case not process\n");
+				break;
+			}
+		}
+
+		RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
+			 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+			 acm_ctrl);
+		rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
+		break; }
+	case HW_VAR_RCR:
+		rtl_write_dword(rtlpriv, REG_RCR, ((u32 *)(val))[0]);
+		rtlpci->receive_config =3D ((u32 *)(val))[0];
+		break;
+	case HW_VAR_RETRY_LIMIT:{
+		u8 retry_limit =3D ((u8 *)(val))[0];
+
+		rtl_write_word(rtlpriv, REG_RL,
+			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
+			       retry_limit << RETRY_LIMIT_LONG_SHIFT);
+		break; }
+	case HW_VAR_DUAL_TSF_RST:
+		rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, (BIT(0) | BIT(1)));
+		break;
+	case HW_VAR_EFUSE_BYTES:
+		rtlefuse->efuse_usedbytes =3D *((u16 *)val);
+		break;
+	case HW_VAR_EFUSE_USAGE:
+		rtlefuse->efuse_usedpercentage =3D *((u8 *)val);
+		break;
+	case HW_VAR_IO_CMD:
+		rtl8821ae_phy_set_io_cmd(hw, (*(enum io_type *)val));
+		break;
+	case HW_VAR_SET_RPWM:{
+		u8 rpwm_val;
+
+		rpwm_val =3D rtl_read_byte(rtlpriv, REG_PCIE_HRPWM);
+		udelay(1);
+
+		if (rpwm_val & BIT(7)) {
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+				       (*(u8 *)val));
+		} else {
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+				       ((*(u8 *)val) | BIT(7)));
+		}
+
+		break; }
+	case HW_VAR_H2C_FW_PWRMODE:
+		rtl8821ae_set_fw_pwrmode_cmd(hw, (*(u8 *)val));
+		break;
+	case HW_VAR_FW_PSMODE_STATUS:
+		ppsc->fw_current_inpsmode =3D *((bool *)val);
+		break;
+	case HW_VAR_INIT_RTS_RATE:
+		break;
+	case HW_VAR_RESUME_CLK_ON:
+		_rtl8821ae_set_fw_ps_rf_on(hw);
+		break;
+	case HW_VAR_FW_LPS_ACTION:{
+		bool b_enter_fwlps =3D *((bool *)val);
+
+		if (b_enter_fwlps)
+			_rtl8821ae_fwlps_enter(hw);
+		 else
+			_rtl8821ae_fwlps_leave(hw);
+		 break; }
+	case HW_VAR_H2C_FW_JOINBSSRPT:{
+		u8 mstatus =3D (*(u8 *)val);
+
+		if (mstatus =3D=3D RT_MEDIA_CONNECT) {
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID,
+						      NULL);
+			_rtl8821ae_download_rsvd_page(hw, false);
+		}
+		rtl8821ae_set_fw_media_status_rpt_cmd(hw, mstatus);
+
+		break; }
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
+		rtl8821ae_set_p2p_ps_offload_cmd(hw, (*(u8 *)val));
+		break;
+	case HW_VAR_AID:{
+		u16 u2btmp;
+		u2btmp =3D rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
+		u2btmp &=3D 0xC000;
+		rtl_write_word(rtlpriv, REG_BCN_PSR_RPT, (u2btmp |
+			       mac->assoc_id));
+		break; }
+	case HW_VAR_CORRECT_TSF:{
+		u8 btype_ibss =3D ((u8 *)(val))[0];
+
+		if (btype_ibss)
+			_rtl8821ae_stop_tx_beacon(hw);
+
+		_rtl8821ae_set_bcn_ctrl_reg(hw, 0, BIT(3));
+
+		rtl_write_dword(rtlpriv, REG_TSFTR,
+				(u32)(mac->tsf & 0xffffffff));
+		rtl_write_dword(rtlpriv, REG_TSFTR + 4,
+				(u32)((mac->tsf >> 32) & 0xffffffff));
+
+		_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(3), 0);
+
+		if (btype_ibss)
+			_rtl8821ae_resume_tx_beacon(hw);
+		break; }
+	case HW_VAR_NAV_UPPER: {
+		u32	us_nav_upper =3D ((u32)*val);
+
+		if (us_nav_upper > HAL_92C_NAV_UPPER_UNIT * 0xFF) {
+			RT_TRACE(rtlpriv, COMP_INIT , DBG_WARNING,
+				 "The setting value (0x%08X us) of NAV_UPPER is larger than (%d * =
0xFF)!!!\n",
+				 us_nav_upper, HAL_92C_NAV_UPPER_UNIT);
+			break;
+		}
+		rtl_write_byte(rtlpriv, REG_NAV_UPPER,
+			       ((u8)((us_nav_upper +
+				HAL_92C_NAV_UPPER_UNIT - 1) /
+				HAL_92C_NAV_UPPER_UNIT)));
+		break; }
+	case HW_VAR_KEEP_ALIVE: {
+		u8 array[2];
+		array[0] =3D 0xff;
+		array[1] =3D *((u8 *)val);
+		rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_KEEP_ALIVE_CTRL, 2,
+				       array);
+		break; }
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process %x\n", variable);
+		break;
+	}
+}
+
+static bool _rtl8821ae_llt_write(struct ieee80211_hw *hw, u32 address,=
 u32 data)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	bool status =3D true;
+	long count =3D 0;
+	u32 value =3D _LLT_INIT_ADDR(address) | _LLT_INIT_DATA(data) |
+		    _LLT_OP(_LLT_WRITE_ACCESS);
+
+	rtl_write_dword(rtlpriv, REG_LLT_INIT, value);
+
+	do {
+		value =3D rtl_read_dword(rtlpriv, REG_LLT_INIT);
+		if (_LLT_NO_ACTIVE =3D=3D _LLT_OP_VALUE(value))
+			break;
+
+		if (count > POLLING_LLT_THRESHOLD) {
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Failed to polling write LLT done at address %d!\n",
+				 address);
+			status =3D false;
+			break;
+		}
+	} while (++count);
+
+	return status;
+}
+
+static bool _rtl8821ae_llt_table_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	unsigned short i;
+	u8 txpktbuf_bndy;
+	u32 rqpn;
+	u8 maxpage;
+	bool status;
+
+	maxpage =3D 255;
+	txpktbuf_bndy =3D 0xF8;
+	rqpn =3D 0x80e70808;
+	if (rtlpriv->rtlhal.hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		txpktbuf_bndy =3D 0xFA;
+		rqpn =3D 0x80e90808;
+	}
+
+	rtl_write_byte(rtlpriv, REG_TRXFF_BNDY, txpktbuf_bndy);
+	rtl_write_word(rtlpriv, REG_TRXFF_BNDY + 2, MAX_RX_DMA_BUFFER_SIZE - =
1);
+
+	rtl_write_byte(rtlpriv, REG_TDECTRL + 1, txpktbuf_bndy);
+
+	rtl_write_byte(rtlpriv, REG_TXPKTBUF_BCNQ_BDNY, txpktbuf_bndy);
+	rtl_write_byte(rtlpriv, REG_TXPKTBUF_MGQ_BDNY, txpktbuf_bndy);
+
+	rtl_write_byte(rtlpriv, REG_PBP, 0x31);
+	rtl_write_byte(rtlpriv, REG_RX_DRVINFO_SZ, 0x4);
+
+	for (i =3D 0; i < (txpktbuf_bndy - 1); i++) {
+		status =3D _rtl8821ae_llt_write(hw, i, i + 1);
+		if (!status)
+			return status;
+	}
+
+	status =3D _rtl8821ae_llt_write(hw, (txpktbuf_bndy - 1), 0xFF);
+	if (!status)
+		return status;
+
+	for (i =3D txpktbuf_bndy; i < maxpage; i++) {
+		status =3D _rtl8821ae_llt_write(hw, i, (i + 1));
+		if (!status)
+			return status;
+	}
+
+	status =3D _rtl8821ae_llt_write(hw, maxpage, txpktbuf_bndy);
+	if (!status)
+		return status;
+
+	rtl_write_dword(rtlpriv, REG_RQPN, rqpn);
+
+	rtl_write_byte(rtlpriv, REG_RQPN_NPQ, 0x00);
+
+	return true;
+}
+
+static void _rtl8821ae_gen_refresh_led_state(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_led *pled0 =3D &pcipriv->ledctl.sw_led0;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	if (rtlpriv->rtlhal.up_first_time)
+		return;
+
+	if (ppsc->rfoff_reason =3D=3D RF_CHANGE_BY_IPS)
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_sw_led_on(hw, pled0);
+		else
+			rtl8821ae_sw_led_on(hw, pled0);
+	else if (ppsc->rfoff_reason =3D=3D RF_CHANGE_BY_INIT)
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_sw_led_on(hw, pled0);
+		else
+			rtl8821ae_sw_led_on(hw, pled0);
+	else
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_sw_led_off(hw, pled0);
+		else
+			rtl8821ae_sw_led_off(hw, pled0);
+}
+
+static bool _rtl8821ae_init_mac(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	u8 bytetmp =3D 0;
+	u16 wordtmp =3D 0;
+	bool mac_func_enable =3D rtlhal->mac_func_enable;
+
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x00);
+
+	/*Auto Power Down to CHIP-off State*/
+	bytetmp =3D rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1) & (~BIT(7));
+	rtl_write_byte(rtlpriv, REG_APS_FSMCO + 1, bytetmp);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		/* HW Power on sequence*/
+		if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK,
+					      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+					      RTL8812_NIC_ENABLE_FLOW)) {
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "init 8812 MAC Fail as power on failure\n");
+				return false;
+		}
+	} else {
+		/* HW Power on sequence */
+		if (!rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_A_MSK,
+					      PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,
+					      RTL8821A_NIC_ENABLE_FLOW)){
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				"init 8821 MAC Fail as power on failure\n");
+			return false;
+		}
+	}
+
+	bytetmp =3D rtl_read_byte(rtlpriv, REG_APS_FSMCO) | BIT(4);
+	rtl_write_byte(rtlpriv, REG_APS_FSMCO, bytetmp);
+
+	bytetmp =3D rtl_read_byte(rtlpriv, REG_CR);
+	bytetmp =3D 0xff;
+	rtl_write_byte(rtlpriv, REG_CR, bytetmp);
+	mdelay(2);
+
+	bytetmp =3D 0xff;
+	rtl_write_byte(rtlpriv, REG_HWSEQ_CTRL, bytetmp);
+	mdelay(2);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		bytetmp =3D rtl_read_byte(rtlpriv, REG_SYS_CFG + 3);
+		if (bytetmp & BIT(0)) {
+			bytetmp =3D rtl_read_byte(rtlpriv, 0x7c);
+			bytetmp |=3D BIT(6);
+			rtl_write_byte(rtlpriv, 0x7c, bytetmp);
+		}
+	}
+
+	bytetmp =3D rtl_read_byte(rtlpriv, REG_GPIO_MUXCFG + 1);
+	bytetmp &=3D ~BIT(4);
+	rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG + 1, bytetmp);
+
+	rtl_write_word(rtlpriv, REG_CR, 0x2ff);
+
+	if (!mac_func_enable) {
+		if (!_rtl8821ae_llt_table_init(hw))
+			return false;
+	}
+
+	rtl_write_dword(rtlpriv, REG_HISR, 0xffffffff);
+	rtl_write_dword(rtlpriv, REG_HISRE, 0xffffffff);
+
+	/* Enable FW Beamformer Interrupt */
+	bytetmp =3D rtl_read_byte(rtlpriv, REG_FWIMR + 3);
+	rtl_write_byte(rtlpriv, REG_FWIMR + 3, bytetmp | BIT(6));
+
+	wordtmp =3D rtl_read_word(rtlpriv, REG_TRXDMA_CTRL);
+	wordtmp &=3D 0xf;
+	wordtmp |=3D 0xF5B1;
+	rtl_write_word(rtlpriv, REG_TRXDMA_CTRL, wordtmp);
+
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 1, 0x1F);
+	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
+	rtl_write_word(rtlpriv, REG_RXFLTMAP2, 0xFFFF);
+	/*low address*/
+	rtl_write_dword(rtlpriv, REG_BCNQ_DESA,
+			rtlpci->tx_ring[BEACON_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_MGQ_DESA,
+			rtlpci->tx_ring[MGNT_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VOQ_DESA,
+			rtlpci->tx_ring[VO_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VIQ_DESA,
+			rtlpci->tx_ring[VI_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_BEQ_DESA,
+			rtlpci->tx_ring[BE_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_BKQ_DESA,
+			rtlpci->tx_ring[BK_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_HQ_DESA,
+			rtlpci->tx_ring[HIGH_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_RX_DESA,
+			rtlpci->rx_ring[RX_MPDU_QUEUE].dma & DMA_BIT_MASK(32));
+
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 3, 0x77);
+
+	rtl_write_dword(rtlpriv, REG_INT_MIG, 0);
+
+	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0);
+
+	rtl_write_byte(rtlpriv, REG_SECONDARY_CCA_CTRL, 0x3);
+	_rtl8821ae_gen_refresh_led_state(hw);
+
+	return true;
+}
+
+static void _rtl8821ae_hw_configure(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rrsr;
+
+	reg_rrsr =3D RATE_ALL_CCK | RATE_ALL_OFDM_AG;
+
+	rtl_write_dword(rtlpriv, REG_RRSR, reg_rrsr);
+	/* ARFB table 9 for 11ac 5G 2SS */
+	rtl_write_dword(rtlpriv, REG_ARFR0 + 4, 0xfffff000);
+	/* ARFB table 10 for 11ac 5G 1SS */
+	rtl_write_dword(rtlpriv, REG_ARFR1 + 4, 0x003ff000);
+	/* ARFB table 11 for 11ac 24G 1SS */
+	rtl_write_dword(rtlpriv, REG_ARFR2, 0x00000015);
+	rtl_write_dword(rtlpriv, REG_ARFR2 + 4, 0x003ff000);
+	/* ARFB table 12 for 11ac 24G 1SS */
+	rtl_write_dword(rtlpriv, REG_ARFR3, 0x00000015);
+	rtl_write_dword(rtlpriv, REG_ARFR3 + 4, 0xffcff000);
+	/* 0x420[7] =3D 0 , enable retry AMPDU in new AMPD not singal MPDU. *=
/
+	rtl_write_word(rtlpriv, REG_FWHW_TXQ_CTRL, 0x1F00);
+	rtl_write_byte(rtlpriv, REG_AMPDU_MAX_TIME, 0x70);
+
+	/*Set retry limit*/
+	rtl_write_word(rtlpriv, REG_RL, 0x0707);
+
+	/* Set Data / Response auto rate fallack retry count*/
+	rtl_write_dword(rtlpriv, REG_DARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_DARFRC + 4, 0x07060504);
+	rtl_write_dword(rtlpriv, REG_RARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_RARFRC + 4, 0x07060504);
+
+	rtlpci->reg_bcn_ctrl_val =3D 0x1d;
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, rtlpci->reg_bcn_ctrl_val);
+
+	/* TBTT prohibit hold time. Suggested by designer TimChen. */
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0xff);
+
+	/* AGGR_BK_TIME Reg51A 0x16 */
+	rtl_write_word(rtlpriv, REG_NAV_PROT_LEN, 0x0040);
+
+	/*For Rx TP. Suggested by SD1 Richard. Added by tynli. 2010.04.12.*/
+	rtl_write_dword(rtlpriv, REG_FAST_EDCA_CTRL, 0x03086666);
+
+	rtl_write_byte(rtlpriv, REG_HT_SINGLE_AMPDU, 0x80);
+	rtl_write_byte(rtlpriv, REG_RX_PKT_LIMIT, 0x20);
+	rtl_write_word(rtlpriv, REG_MAX_AGGR_NUM, 0x1F1F);
+}
+
+static u16 _rtl8821ae_mdio_read(struct rtl_priv *rtlpriv, u8 addr)
+{
+	u16 ret =3D 0;
+	u8 tmp =3D 0, count =3D 0;
+
+	rtl_write_byte(rtlpriv, REG_MDIO_CTL, addr | BIT(6));
+	tmp =3D rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(6);
+	count =3D 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp =3D rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(6);
+		count++;
+	}
+	if (0 =3D=3D tmp)
+		ret =3D rtl_read_word(rtlpriv, REG_MDIO_RDATA);
+
+	return ret;
+}
+
+static void _rtl8821ae_mdio_write(struct rtl_priv *rtlpriv, u8 addr, u=
16 data)
+{
+	u8 tmp =3D 0, count =3D 0;
+
+	rtl_write_word(rtlpriv, REG_MDIO_WDATA, data);
+	rtl_write_byte(rtlpriv, REG_MDIO_CTL, addr | BIT(5));
+	tmp =3D rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(5);
+	count =3D 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp =3D rtl_read_byte(rtlpriv, REG_MDIO_CTL) & BIT(5);
+		count++;
+	}
+}
+
+static u8 _rtl8821ae_dbi_read(struct rtl_priv *rtlpriv, u16 addr)
+{
+	u16 read_addr =3D addr & 0xfffc;
+	u8 tmp =3D 0, count =3D 0, ret =3D 0;
+
+	rtl_write_word(rtlpriv, REG_DBI_ADDR, read_addr);
+	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x2);
+	tmp =3D rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+	count =3D 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp =3D rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+		count++;
+	}
+	if (0 =3D=3D tmp) {
+		read_addr =3D REG_DBI_RDATA + addr % 4;
+		ret =3D rtl_read_word(rtlpriv, read_addr);
+	}
+	return ret;
+}
+
+static void _rtl8821ae_dbi_write(struct rtl_priv *rtlpriv, u16 addr, u=
8 data)
+{
+	u8 tmp =3D 0, count =3D 0;
+	u16 wrtie_addr, remainder =3D addr % 4;
+
+	wrtie_addr =3D REG_DBI_WDATA + remainder;
+	rtl_write_byte(rtlpriv, wrtie_addr, data);
+
+	wrtie_addr =3D (addr & 0xfffc) | (BIT(0) << (remainder + 12));
+	rtl_write_word(rtlpriv, REG_DBI_ADDR, wrtie_addr);
+
+	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x1);
+
+	tmp =3D rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+	count =3D 0;
+	while (tmp && count < 20) {
+		udelay(10);
+		tmp =3D rtl_read_byte(rtlpriv, REG_DBI_FLAG);
+		count++;
+	}
+}
+
+static void _rtl8821ae_enable_aspm_back_door(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 tmp;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		if (_rtl8821ae_mdio_read(rtlpriv, 0x04) !=3D 0x8544)
+			_rtl8821ae_mdio_write(rtlpriv, 0x04, 0x8544);
+
+		if (_rtl8821ae_mdio_read(rtlpriv, 0x0b) !=3D 0x0070)
+			_rtl8821ae_mdio_write(rtlpriv, 0x0b, 0x0070);
+	}
+
+	tmp =3D _rtl8821ae_dbi_read(rtlpriv, 0x70f);
+	_rtl8821ae_dbi_write(rtlpriv, 0x70f, tmp | BIT(7));
+
+	tmp =3D _rtl8821ae_dbi_read(rtlpriv, 0x719);
+	_rtl8821ae_dbi_write(rtlpriv, 0x719, tmp | BIT(3) | BIT(4));
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		tmp  =3D _rtl8821ae_dbi_read(rtlpriv, 0x718);
+		_rtl8821ae_dbi_write(rtlpriv, 0x718, tmp|BIT(4));
+	}
+}
+
+void rtl8821ae_enable_hw_security_config(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 sec_reg_value;
+	u8 tmp;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "PairwiseEncAlgorithm =3D %d GroupEncAlgorithm =3D %d\n",
+		  rtlpriv->sec.pairwise_enc_algorithm,
+		  rtlpriv->sec.group_enc_algorithm);
+
+	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+			 "not open hw encryption\n");
+		return;
+	}
+
+	sec_reg_value =3D SCR_TXENCENABLE | SCR_RXDECENABLE;
+
+	if (rtlpriv->sec.use_defaultkey) {
+		sec_reg_value |=3D SCR_TXUSEDK;
+		sec_reg_value |=3D SCR_RXUSEDK;
+	}
+
+	sec_reg_value |=3D (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
+
+	tmp =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, tmp | BIT(1));
+
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+		 "The SECR-value %x\n", sec_reg_value);
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
+}
+
+/* Static MacID Mapping (cf. Used in MacIdDoStaticMapping) ---------- =
*/
+#define MAC_ID_STATIC_FOR_DEFAULT_PORT				0
+#define MAC_ID_STATIC_FOR_BROADCAST_MULTICAST		1
+#define MAC_ID_STATIC_FOR_BT_CLIENT_START				2
+#define MAC_ID_STATIC_FOR_BT_CLIENT_END				3
+/* ----------------------------------------------------------- */
+
+static void rtl8821ae_macid_initialize_mediastatus(struct ieee80211_hw=
 *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8	media_rpt[4] =3D {RT_MEDIA_CONNECT, 1,
+		MAC_ID_STATIC_FOR_BROADCAST_MULTICAST,
+		MAC_ID_STATIC_FOR_BT_CLIENT_END};
+
+	rtlpriv->cfg->ops->set_hw_reg(hw,
+		HW_VAR_H2C_FW_MEDIASTATUSRPT, media_rpt);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Initialize MacId media status: from %d to %d\n",
+		 MAC_ID_STATIC_FOR_BROADCAST_MULTICAST,
+		 MAC_ID_STATIC_FOR_BT_CLIENT_END);
+}
+
+static bool _rtl8821ae_check_pcie_dma_hang(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 tmp;
+
+	/* write reg 0x350 Bit[26]=3D1. Enable debug port. */
+	tmp =3D rtl_read_byte(rtlpriv, REG_DBI_CTRL + 3);
+	if (!(tmp & BIT(2))) {
+		rtl_write_byte(rtlpriv, REG_DBI_CTRL + 3, (tmp | BIT(2)));
+		mdelay(100);
+	}
+
+	/* read reg 0x350 Bit[25] if 1 : RX hang */
+	/* read reg 0x350 Bit[24] if 1 : TX hang */
+	tmp =3D rtl_read_byte(rtlpriv, REG_DBI_CTRL + 3);
+	if ((tmp & BIT(0)) || (tmp & BIT(1))) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "CheckPcieDMAHang8821AE(): true! Reset PCIE DMA!\n");
+		return true;
+	} else {
+		return false;
+	}
+}
+
+static bool _rtl8821ae_reset_pcie_interface_dma(struct ieee80211_hw *h=
w,
+					 bool mac_power_on,
+					 bool in_watchdog)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 tmp;
+	bool release_mac_rx_pause;
+	u8 backup_pcie_dma_pause;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+
+	/* 1. Disable register write lock. 0x1c[1] =3D 0 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL);
+	tmp &=3D ~(BIT(1));
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, tmp);
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/* write 0xCC bit[2] =3D 1'b1 */
+		tmp =3D rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+		tmp |=3D BIT(2);
+		rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+	}
+
+	/* 2. Check and pause TRX DMA */
+	/* write 0x284 bit[18] =3D 1'b1 */
+	/* write 0x301 =3D 0xFF */
+	tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	if (tmp & BIT(2)) {
+		/* Already pause before the function for another purpose. */
+		release_mac_rx_pause =3D false;
+	} else {
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, (tmp | BIT(2)));
+		release_mac_rx_pause =3D true;
+	}
+	backup_pcie_dma_pause =3D rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG + =
1);
+	if (backup_pcie_dma_pause !=3D 0xFF)
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xFF);
+
+	if (mac_power_on) {
+		/* 3. reset TRX function */
+		/* write 0x100 =3D 0x00 */
+		rtl_write_byte(rtlpriv, REG_CR, 0);
+	}
+
+	/* 4. Reset PCIe DMA. 0x3[0] =3D 0 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp &=3D ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	/* 5. Enable PCIe DMA. 0x3[0] =3D 1 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	tmp |=3D BIT(0);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, tmp);
+
+	if (mac_power_on) {
+		/* 6. enable TRX function */
+		/* write 0x100 =3D 0xFF */
+		rtl_write_byte(rtlpriv, REG_CR, 0xFF);
+
+		/* We should init LLT & RQPN and
+		 * prepare Tx/Rx descrptor address later
+		 * because MAC function is reset.*/
+	}
+
+	/* 7. Restore PCIe autoload down bit */
+	/* 8812AE does not has the defination. */
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/* write 0xF8 bit[17] =3D 1'b1 */
+		tmp =3D rtl_read_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2);
+		tmp |=3D BIT(1);
+		rtl_write_byte(rtlpriv, REG_MAC_PHY_CTRL_NORMAL + 2, tmp);
+	}
+
+	/* In MAC power on state, BB and RF maybe in ON state,
+	 * if we release TRx DMA here.
+	 * it will cause packets to be started to Tx/Rx,
+	 * so we release Tx/Rx DMA later.*/
+	if (!mac_power_on/* || in_watchdog*/) {
+		/* 8. release TRX DMA */
+		/* write 0x284 bit[18] =3D 1'b0 */
+		/* write 0x301 =3D 0x00 */
+		if (release_mac_rx_pause) {
+			tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+			rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL,
+				       tmp & (~BIT(2)));
+		}
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1,
+			       backup_pcie_dma_pause);
+	}
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/* 9. lock system register */
+		/* write 0xCC bit[2] =3D 1'b0 */
+		tmp =3D rtl_read_byte(rtlpriv, REG_PMC_DBG_CTRL2);
+		tmp &=3D ~(BIT(2));
+		rtl_write_byte(rtlpriv, REG_PMC_DBG_CTRL2, tmp);
+	}
+	return true;
+}
+
+static void _rtl8821ae_get_wakeup_reason(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtlpriv);
+	u8 fw_reason =3D 0;
+	struct timeval ts;
+
+	fw_reason =3D rtl_read_byte(rtlpriv, REG_MCUTST_WOWLAN);
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "WOL Read 0x1c7 =3D %02X\n",
+		 fw_reason);
+
+	ppsc->wakeup_reason =3D 0;
+
+	rtlhal->last_suspend_sec =3D ts.tv_sec;
+
+	switch (fw_reason) {
+	case FW_WOW_V2_PTK_UPDATE_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_PTK_UPDATE;
+		do_gettimeofday(&ts);
+		ppsc->last_wakeup_time =3D ts.tv_sec*1000 + ts.tv_usec/1000;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a WOL PTK Key update event!\n");
+		break;
+	case FW_WOW_V2_GTK_UPDATE_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_GTK_UPDATE;
+		do_gettimeofday(&ts);
+		ppsc->last_wakeup_time =3D ts.tv_sec*1000 + ts.tv_usec/1000;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a WOL GTK Key update event!\n");
+		break;
+	case FW_WOW_V2_DISASSOC_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_DISASSOC;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a disassociation event!\n");
+		break;
+	case FW_WOW_V2_DEAUTH_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_DEAUTH;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a deauth event!\n");
+		break;
+	case FW_WOW_V2_FW_DISCONNECT_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_AP_LOST;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a Fw disconnect decision (AP lost) event!\n");
+	break;
+	case FW_WOW_V2_MAGIC_PKT_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_MAGIC_PKT;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a magic packet event!\n");
+		break;
+	case FW_WOW_V2_UNICAST_PKT_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_UNICAST_PKT;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's an unicast packet event!\n");
+		break;
+	case FW_WOW_V2_PATTERN_PKT_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_PATTERN_PKT;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's a pattern match event!\n");
+		break;
+	case FW_WOW_V2_RTD3_SSID_MATCH_EVENT:
+		ppsc->wakeup_reason =3D WOL_REASON_RTD3_SSID_MATCH;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's an RTD3 Ssid match event!\n");
+		break;
+	case FW_WOW_V2_REALWOW_V2_WAKEUPPKT:
+		ppsc->wakeup_reason =3D WOL_REASON_REALWOW_V2_WAKEUPPKT;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's an RealWoW wake packet event!\n");
+		break;
+	case FW_WOW_V2_REALWOW_V2_ACKLOST:
+		ppsc->wakeup_reason =3D WOL_REASON_REALWOW_V2_ACKLOST;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "It's an RealWoW ack lost event!\n");
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "WOL Read 0x1c7 =3D %02X, Unknown reason!\n",
+			  fw_reason);
+		break;
+	}
+}
+
+static void _rtl8821ae_init_trx_desc_hw_address(struct ieee80211_hw *h=
w)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	/*low address*/
+	rtl_write_dword(rtlpriv, REG_BCNQ_DESA,
+			rtlpci->tx_ring[BEACON_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_MGQ_DESA,
+			rtlpci->tx_ring[MGNT_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VOQ_DESA,
+			rtlpci->tx_ring[VO_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VIQ_DESA,
+			rtlpci->tx_ring[VI_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_BEQ_DESA,
+			rtlpci->tx_ring[BE_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_BKQ_DESA,
+			rtlpci->tx_ring[BK_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_HQ_DESA,
+			rtlpci->tx_ring[HIGH_QUEUE].dma & DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_RX_DESA,
+			rtlpci->rx_ring[RX_MPDU_QUEUE].dma & DMA_BIT_MASK(32));
+}
+
+static bool _rtl8821ae_init_llt_table(struct ieee80211_hw *hw, u32 bou=
ndary)
+{
+	bool status =3D true;
+	u32 i;
+	u32 txpktbuf_bndy =3D boundary;
+	u32 last_entry_of_txpktbuf =3D LAST_ENTRY_OF_TX_PKT_BUFFER;
+
+	for (i =3D 0 ; i < (txpktbuf_bndy - 1) ; i++) {
+		status =3D _rtl8821ae_llt_write(hw, i , i + 1);
+		if (!status)
+			return status;
+	}
+
+	status =3D _rtl8821ae_llt_write(hw, (txpktbuf_bndy - 1), 0xFF);
+	if (!status)
+		return status;
+
+	for (i =3D txpktbuf_bndy ; i < last_entry_of_txpktbuf ; i++) {
+		status =3D _rtl8821ae_llt_write(hw, i, (i + 1));
+		if (!status)
+			return status;
+	}
+
+	status =3D _rtl8821ae_llt_write(hw, last_entry_of_txpktbuf,
+				      txpktbuf_bndy);
+	if (!status)
+		return status;
+
+	return status;
+}
+
+static bool _rtl8821ae_dynamic_rqpn(struct ieee80211_hw *hw, u32 bound=
ary,
+			     u16 npq_rqpn_value, u32 rqpn_val)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 tmp;
+	bool ret =3D true;
+	u16 count =3D 0, tmp16;
+	bool support_remote_wakeup;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *)(&support_remote_wakeup));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "boundary=3D0x%#X, NPQ_RQPNValue=3D0x%#X, RQPNValue=3D0x%#X\n",
+		  boundary, npq_rqpn_value, rqpn_val);
+
+	/* stop PCIe DMA
+	 * 1. 0x301[7:0] =3D 0xFE */
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xFE);
+
+	/* wait TXFF empty
+	 * 2. polling till 0x41A[15:0]=3D0x07FF */
+	tmp16 =3D rtl_read_word(rtlpriv, REG_TXPKT_EMPTY);
+	while ((tmp16 & 0x07FF) !=3D 0x07FF) {
+		udelay(100);
+		tmp16 =3D rtl_read_word(rtlpriv, REG_TXPKT_EMPTY);
+		count++;
+		if ((count % 200) =3D=3D 0) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Tx queue is not empty for 20ms!\n");
+		}
+		if (count >=3D 1000) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Wait for Tx FIFO empty timeout!\n");
+			break;
+		}
+	}
+
+	/* TX pause
+	 * 3. reg 0x522=3D0xFF */
+	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
+
+	/* Wait TX State Machine OK
+	 * 4. polling till reg 0x5FB~0x5F8 =3D 0x00000000 for 50ms */
+	count =3D 0;
+	while (rtl_read_byte(rtlpriv, REG_SCH_TXCMD) !=3D 0) {
+		udelay(100);
+		count++;
+		if (count >=3D 500) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Wait for TX State Machine ready timeout !!\n");
+			break;
+		}
+	}
+
+	/* stop RX DMA path
+	 * 5.	0x284[18] =3D 1
+	 * 6.	wait till 0x284[17] =3D=3D 1
+	 * wait RX DMA idle */
+	count =3D 0;
+	tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, (tmp | BIT(2)));
+	do {
+		tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+		udelay(10);
+		count++;
+	} while (!(tmp & BIT(1)) && count < 100);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Wait until Rx DMA Idle. count=3D%d REG[0x286]=3D0x%x\n",
+		  count, tmp);
+
+	/* reset BB
+	 * 7.	0x02 [0] =3D 0 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN);
+	tmp &=3D ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, tmp);
+
+	/* Reset TRX MAC
+	 * 8.	 0x100 =3D 0x00
+	 * Delay (1ms) */
+	rtl_write_byte(rtlpriv, REG_CR, 0x00);
+	udelay(1000);
+
+	/* Disable MAC Security Engine
+	 * 9.	0x100 bit[9]=3D0 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+	tmp &=3D ~(BIT(1));
+	rtl_write_byte(rtlpriv, REG_CR + 1, tmp);
+
+	/* To avoid DD-Tim Circuit hang
+	 * 10.	0x553 bit[5]=3D1 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_DUAL_TSF_RST);
+	rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, (tmp | BIT(5)));
+
+	/* Enable MAC Security Engine
+	 * 11.	0x100 bit[9]=3D1 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, (tmp | BIT(1)));
+
+	/* Enable TRX MAC
+	 * 12.	 0x100 =3D 0xFF
+	 *	Delay (1ms) */
+	rtl_write_byte(rtlpriv, REG_CR, 0xFF);
+	udelay(1000);
+
+	/* Enable BB
+	 * 13.	0x02 [0] =3D 1 */
+	tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, (tmp | BIT(0)));
+
+	/* beacon setting
+	 * 14,15. set beacon head page (reg 0x209 and 0x424) */
+	rtl_write_byte(rtlpriv, REG_TDECTRL + 1, (u8)boundary);
+	rtl_write_byte(rtlpriv, REG_TXPKTBUF_BCNQ_BDNY, (u8)boundary);
+	rtl_write_byte(rtlpriv, REG_TXPKTBUF_MGQ_BDNY, (u8)boundary);
+
+	/* 16.	WMAC_LBK_BF_HD 0x45D[7:0]
+	 * WMAC_LBK_BF_HD */
+	rtl_write_byte(rtlpriv, REG_TXPKTBUF_WMAC_LBK_BF_HD,
+		       (u8)boundary);
+
+	rtl_write_word(rtlpriv, REG_TRXFF_BNDY, boundary);
+
+	/* init LLT
+	 * 17. init LLT */
+	if (!_rtl8821ae_init_llt_table(hw, boundary)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING,
+			 "Failed to init LLT table!\n");
+		return false;
+	}
+
+	/* reallocate RQPN
+	 * 18. reallocate RQPN and init LLT */
+	rtl_write_word(rtlpriv, REG_RQPN_NPQ, npq_rqpn_value);
+	rtl_write_dword(rtlpriv, REG_RQPN, rqpn_val);
+
+	/* release Tx pause
+	 * 19. 0x522=3D0x00 */
+	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
+
+	/* enable PCIE DMA
+	 * 20. 0x301[7:0] =3D 0x00
+	 * 21. 0x284[18] =3D 0 */
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0x00);
+	tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, (tmp&~BIT(2)));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "End.\n");
+	return ret;
+}
+
+static void _rtl8821ae_simple_initialize_adapter(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtlpriv);
+
+#if (USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN =3D=3D 1)
+	/* Re-download normal Fw. */
+	rtl8821ae_set_fw_related_for_wowlan(hw, false);
+#endif
+
+	/* Re-Initialize LLT table. */
+	if (rtlhal->re_init_llt_table) {
+		u32 rqpn =3D 0x80e70808;
+		u8 rqpn_npq =3D 0, boundary =3D 0xF8;
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			rqpn =3D 0x80e90808;
+			boundary =3D 0xFA;
+		}
+		if (_rtl8821ae_dynamic_rqpn(hw, boundary, rqpn_npq, rqpn))
+			rtlhal->re_init_llt_table =3D false;
+	}
+
+	ppsc->rfpwr_state =3D ERFON;
+}
+
+static void _rtl8821ae_enable_l1off(struct ieee80211_hw *hw)
+{
+	u8 tmp  =3D 0;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "--->\n");
+
+	tmp =3D _rtl8821ae_dbi_read(rtlpriv, 0x160);
+	if (!(tmp & (BIT(2) | BIT(3)))) {
+		RT_TRACE(rtlpriv, COMP_POWER | COMP_INIT, DBG_LOUD,
+			 "0x160(%#x)return!!\n", tmp);
+		return;
+	}
+
+	tmp =3D _rtl8821ae_mdio_read(rtlpriv, 0x1b);
+	_rtl8821ae_mdio_write(rtlpriv, 0x1b, (tmp | BIT(4)));
+
+	tmp =3D _rtl8821ae_dbi_read(rtlpriv, 0x718);
+	_rtl8821ae_dbi_write(rtlpriv, 0x718, tmp | BIT(5));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "<---\n");
+}
+
+static void _rtl8821ae_enable_ltr(struct ieee80211_hw *hw)
+{
+	u8 tmp  =3D 0;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "--->\n");
+
+	/* Check 0x98[10] */
+	tmp =3D _rtl8821ae_dbi_read(rtlpriv, 0x99);
+	if (!(tmp & BIT(2))) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "<---0x99(%#x) return!!\n", tmp);
+		return;
+	}
+
+	/* LTR idle latency, 0x90 for 144us */
+	rtl_write_dword(rtlpriv, 0x798, 0x88908890);
+
+	/* LTR active latency, 0x3c for 60us */
+	rtl_write_dword(rtlpriv, 0x79c, 0x883c883c);
+
+	tmp =3D rtl_read_byte(rtlpriv, 0x7a4);
+	rtl_write_byte(rtlpriv, 0x7a4, (tmp | BIT(4)));
+
+	tmp =3D rtl_read_byte(rtlpriv, 0x7a4);
+	rtl_write_byte(rtlpriv, 0x7a4, (tmp & (~BIT(0))));
+	rtl_write_byte(rtlpriv, 0x7a4, (tmp | BIT(0)));
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "<---\n");
+}
+
+static bool _rtl8821ae_wowlan_initialize_adapter(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	bool init_finished =3D true;
+	u8 tmp =3D 0;
+
+	/* Get Fw wake up reason. */
+	_rtl8821ae_get_wakeup_reason(hw);
+
+	/* Patch Pcie Rx DMA hang after S3/S4 several times.
+	 * The root cause has not be found. */
+	if (_rtl8821ae_check_pcie_dma_hang(hw))
+		_rtl8821ae_reset_pcie_interface_dma(hw, true, false);
+
+	/* Prepare Tx/Rx Desc Hw address. */
+	_rtl8821ae_init_trx_desc_hw_address(hw);
+
+	/* Release Pcie Interface Rx DMA to allow wake packet DMA. */
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xFE);
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Enable PCIE Rx DMA.\n");
+
+	/* Check wake up event.
+	 * We should check wake packet bit before disable wowlan by H2C or
+	 * Fw will clear the bit. */
+	tmp =3D rtl_read_byte(rtlpriv, REG_FTISR + 3);
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+		 "Read REG_FTISR 0x13f =3D %#X\n", tmp);
+
+	/* Set the WoWLAN related function control disable. */
+	rtl8821ae_set_fw_wowlan_mode(hw, false);
+	rtl8821ae_set_fw_remote_wake_ctrl_cmd(hw, 0);
+
+	if (rtlhal->hw_rof_enable) {
+		tmp =3D rtl_read_byte(rtlpriv, REG_HSISR + 3);
+		if (tmp & BIT(1)) {
+			/* Clear GPIO9 ISR */
+			rtl_write_byte(rtlpriv, REG_HSISR + 3, tmp | BIT(1));
+			init_finished =3D false;
+		} else {
+			init_finished =3D true;
+		}
+	}
+
+	if (init_finished) {
+		_rtl8821ae_simple_initialize_adapter(hw);
+
+		/* Release Pcie Interface Tx DMA. */
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0x00);
+		/* Release Pcie RX DMA */
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, 0x02);
+
+		tmp =3D rtl_read_byte(rtlpriv, REG_CR + 1);
+		rtl_write_byte(rtlpriv, REG_CR + 1, (tmp & (~BIT(0))));
+
+		_rtl8821ae_enable_l1off(hw);
+		_rtl8821ae_enable_ltr(hw);
+	}
+
+	return init_finished;
+}
+
+static void _rtl8812ae_bb8812_config_1t(struct ieee80211_hw *hw)
+{
+	/* BB OFDM RX Path_A */
+	rtl_set_bbreg(hw, 0x808, 0xff, 0x11);
+	/* BB OFDM TX Path_A */
+	rtl_set_bbreg(hw, 0x80c, MASKLWORD, 0x1111);
+	/* BB CCK R/Rx Path_A */
+	rtl_set_bbreg(hw, 0xa04, 0x0c000000, 0x0);
+	/* MCS support */
+	rtl_set_bbreg(hw, 0x8bc, 0xc0000060, 0x4);
+	/* RF Path_B HSSI OFF */
+	rtl_set_bbreg(hw, 0xe00, 0xf, 0x4);
+	/* RF Path_B Power Down */
+	rtl_set_bbreg(hw, 0xe90, MASKDWORD, 0);
+	/* ADDA Path_B OFF */
+	rtl_set_bbreg(hw, 0xe60, MASKDWORD, 0);
+	rtl_set_bbreg(hw, 0xe64, MASKDWORD, 0);
+}
+
+static void _rtl8821ae_poweroff_adapter(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 u1b_tmp;
+
+	rtlhal->mac_func_enable =3D false;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/* Combo (PCIe + USB) Card and PCIe-MF Card */
+		/* 1. Run LPS WL RFOFF flow */
+		/* RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		"=3D=3D=3D=3D=3D>CardDisableRTL8812E,RTL8821A_NIC_LPS_ENTER_FLOW\n")=
;
+		*/
+		rtl_hal_pwrseqcmdparsing(rtlpriv,
+			PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+			PWR_INTF_PCI_MSK, RTL8821A_NIC_LPS_ENTER_FLOW);
+	}
+	/* 2. 0x1F[7:0] =3D 0 */
+	/* turn off RF */
+	/* rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00); */
+	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) &&
+		rtlhal->fw_ready) {
+		rtl8821ae_firmware_selfreset(hw);
+	}
+
+	/* Reset MCU. Suggested by Filen. */
+	u1b_tmp =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN+1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN+1, (u1b_tmp & (~BIT(2))));
+
+	/* g.	MCUFWDL 0x80[1:0]=3D0	 */
+	/* reset MCU ready status */
+	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/* HW card disable configuration. */
+		rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+			PWR_INTF_PCI_MSK, RTL8821A_NIC_DISABLE_FLOW);
+	} else {
+		/* HW card disable configuration. */
+		rtl_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+			PWR_INTF_PCI_MSK, RTL8812_NIC_DISABLE_FLOW);
+	}
+
+	/* Reset MCU IO Wrapper */
+	u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+	u1b_tmp =3D rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, u1b_tmp | BIT(0));
+
+	/* 7. RSV_CTRL 0x1C[7:0] =3D 0x0E */
+	/* lock ISO/CLK/Power control register */
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0e);
+}
+
+int rtl8821ae_hw_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	bool rtstatus =3D true;
+	int err;
+	u8 tmp_u1b;
+	bool support_remote_wakeup;
+	u32 nav_upper =3D WIFI_NAV_UPPER_US;
+
+	rtlhal->being_init_adapter =3D true;
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *)(&support_remote_wakeup));
+	rtlpriv->intf_ops->disable_aspm(hw);
+
+	/*YP wowlan not considered*/
+
+	tmp_u1b =3D rtl_read_byte(rtlpriv, REG_CR);
+	if (tmp_u1b !=3D 0 && tmp_u1b !=3D 0xEA) {
+		rtlhal->mac_func_enable =3D true;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "MAC has already power on.\n");
+	} else {
+		rtlhal->mac_func_enable =3D false;
+		rtlhal->fw_ps_state =3D FW_PS_STATE_ALL_ON_8821AE;
+	}
+
+	if (support_remote_wakeup &&
+		rtlhal->wake_from_pnp_sleep &&
+		rtlhal->mac_func_enable) {
+		if (_rtl8821ae_wowlan_initialize_adapter(hw)) {
+			rtlhal->being_init_adapter =3D false;
+			return 0;
+		}
+	}
+
+	if (_rtl8821ae_check_pcie_dma_hang(hw)) {
+		_rtl8821ae_reset_pcie_interface_dma(hw,
+						    rtlhal->mac_func_enable,
+						    false);
+		rtlhal->mac_func_enable =3D false;
+	}
+
+	/* Reset MAC/BB/RF status if it is not powered off
+	 * before calling initialize Hw flow to prevent
+	 * from interface and MAC status mismatch.
+	 * 2013.06.21, by tynli. Suggested by SD1 JackieLau. */
+	if (rtlhal->mac_func_enable) {
+		_rtl8821ae_poweroff_adapter(hw);
+		rtlhal->mac_func_enable =3D false;
+	}
+
+	rtstatus =3D _rtl8821ae_init_mac(hw);
+	if (rtstatus !=3D true) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
+		err =3D 1;
+		return err;
+	}
+
+	tmp_u1b =3D rtl_read_byte(rtlpriv, REG_SYS_CFG);
+	tmp_u1b &=3D 0x7F;
+	rtl_write_byte(rtlpriv, REG_SYS_CFG, tmp_u1b);
+
+	err =3D rtl8821ae_download_fw(hw, false);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Failed to download FW. Init HW without FW now\n");
+		err =3D 1;
+		rtlhal->fw_ready =3D false;
+		return err;
+	} else {
+		rtlhal->fw_ready =3D true;
+	}
+	ppsc->fw_current_inpsmode =3D false;
+	rtlhal->fw_ps_state =3D FW_PS_STATE_ALL_ON_8821AE;
+	rtlhal->fw_clk_change_in_progress =3D false;
+	rtlhal->allow_sw_to_change_hwclc =3D false;
+	rtlhal->last_hmeboxnum =3D 0;
+
+	/*SIC_Init(Adapter);
+	if(rtlhal->AMPDUBurstMode)
+		rtl_write_byte(rtlpriv,REG_AMPDU_BURST_MODE_8812,  0x7F);*/
+
+	rtl8821ae_phy_mac_config(hw);
+	/* because last function modify RCR, so we update
+	 * rcr var here, or TP will unstable for receive_config
+	 * is wrong, RX RCR_ACRC32 will cause TP unstabel & Rx
+	 * RCR_APP_ICV will cause mac80211 unassoc for cisco 1252
+	rtlpci->receive_config =3D rtl_read_dword(rtlpriv, REG_RCR);
+	rtlpci->receive_config &=3D ~(RCR_ACRC32 | RCR_AICV);
+	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);*/
+	rtl8821ae_phy_bb_config(hw);
+
+	rtl8821ae_phy_rf_config(hw);
+
+	if (rtlpriv->phy.rf_type =3D=3D RF_1T1R &&
+		rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+		_rtl8812ae_bb8812_config_1t(hw);
+
+	_rtl8821ae_hw_configure(hw);
+
+	rtl8821ae_phy_switch_wirelessband(hw, BAND_ON_2_4G);
+
+	/*set wireless mode*/
+
+	rtlhal->mac_func_enable =3D true;
+
+	rtl_cam_reset_all_entry(hw);
+
+	rtl8821ae_enable_hw_security_config(hw);
+
+	ppsc->rfpwr_state =3D ERFON;
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR, mac->mac_addr);
+	_rtl8821ae_enable_aspm_back_door(hw);
+	rtlpriv->intf_ops->enable_aspm(hw);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE &&
+	    (rtlhal->rfe_type =3D=3D 1 || rtlhal->rfe_type =3D=3D 5))
+		rtl_set_bbreg(hw, 0x900, 0x00000303, 0x0302);
+
+	rtl8821ae_bt_hw_init(hw);
+	rtlpriv->rtlhal.being_init_adapter =3D false;
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_NAV_UPPER, (u8 *)&nav_upper)=
;
+
+	/* rtl8821ae_dm_check_txpower_tracking(hw); */
+	/* rtl8821ae_phy_lc_calibrate(hw); */
+	if (support_remote_wakeup)
+		rtl_write_byte(rtlpriv, REG_WOW_CTRL, 0);
+
+	/* Release Rx DMA*/
+	tmp_u1b =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+	if (tmp_u1b & BIT(2)) {
+		/* Release Rx DMA if needed*/
+		tmp_u1b &=3D ~BIT(2);
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, tmp_u1b);
+	}
+
+	/* Release Tx/Rx PCIE DMA if*/
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0);
+
+	rtl8821ae_dm_init(hw);
+	rtl8821ae_macid_initialize_mediastatus(hw);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "rtl8821ae_hw_init() <=3D=3D=3D=
=3D\n");
+	return err;
+}
+
+static enum version_8821ae _rtl8821ae_read_chip_version(struct ieee802=
11_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	enum version_8821ae version =3D VERSION_UNKNOWN;
+	u32 value32;
+
+	value32 =3D rtl_read_dword(rtlpriv, REG_SYS_CFG);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "ReadChipVersion8812A 0xF0 =3D 0x%x\n", value32);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+		rtlphy->rf_type =3D RF_2T2R;
+	else if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE)
+		rtlphy->rf_type =3D RF_1T1R;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "RF_Type is %x!!\n", rtlphy->rf_type);
+
+	if (value32 & TRP_VAUX_EN) {
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			if (rtlphy->rf_type =3D=3D RF_2T2R)
+				version =3D VERSION_TEST_CHIP_2T2R_8812;
+			else
+				version =3D VERSION_TEST_CHIP_1T1R_8812;
+		} else
+			version =3D VERSION_TEST_CHIP_8821;
+	} else {
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			u32 rtl_id =3D ((value32 & CHIP_VER_RTL_MASK) >> 12) + 1;
+
+			if (rtlphy->rf_type =3D=3D RF_2T2R)
+				version =3D
+					(enum version_8821ae)(CHIP_8812
+					| NORMAL_CHIP |
+					RF_TYPE_2T2R);
+			else
+				version =3D (enum version_8821ae)(CHIP_8812
+					| NORMAL_CHIP);
+
+			version =3D (enum version_8821ae)(version | (rtl_id << 12));
+		} else if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			u32 rtl_id =3D value32 & CHIP_VER_RTL_MASK;
+
+			version =3D (enum version_8821ae)(CHIP_8821
+				| NORMAL_CHIP | rtl_id);
+		}
+	}
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		/*WL_HWROF_EN.*/
+		value32 =3D rtl_read_dword(rtlpriv, REG_MULTI_FUNC_CTRL);
+		rtlhal->hw_rof_enable =3D ((value32 & WL_HWROF_EN) ? 1 : 0);
+	}
+
+	switch (version) {
+	case VERSION_TEST_CHIP_1T1R_8812:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_TEST_CHIP_1T1R_8812\n");
+		break;
+	case VERSION_TEST_CHIP_2T2R_8812:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_TEST_CHIP_2T2R_8812\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_1T1R_8812:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID:VERSION_NORMAL_TSMC_CHIP_1T1R_8812\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_2T2R_8812:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_2T2R_8812\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_1T1R_8812_C_CUT:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_1T1R_8812 C CUT\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_2T2R_8812_C_CUT:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_2T2R_8812 C CUT\n");
+		break;
+	case VERSION_TEST_CHIP_8821:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_TEST_CHIP_8821\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_8821:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_8821 A CUT\n");
+		break;
+	case VERSION_NORMAL_TSMC_CHIP_8821_B_CUT:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_8821 B CUT\n");
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Chip Version ID: Unknow (0x%X)\n", version);
+		break;
+	}
+
+	return version;
+}
+
+static int _rtl8821ae_set_media_status(struct ieee80211_hw *hw,
+				     enum nl80211_iftype type)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 bt_msr =3D rtl_read_byte(rtlpriv, MSR);
+	enum led_ctl_mode ledaction =3D LED_CTL_NO_LINK;
+	bt_msr &=3D 0xfc;
+
+	rtl_write_dword(rtlpriv, REG_BCN_CTRL, 0);
+	RT_TRACE(rtlpriv, COMP_BEACON, DBG_LOUD,
+		"clear 0x550 when set HW_VAR_MEDIA_STATUS\n");
+
+	if (type =3D=3D NL80211_IFTYPE_UNSPECIFIED ||
+	    type =3D=3D NL80211_IFTYPE_STATION) {
+		_rtl8821ae_stop_tx_beacon(hw);
+		_rtl8821ae_enable_bcn_sub_func(hw);
+	} else if (type =3D=3D NL80211_IFTYPE_ADHOC ||
+		type =3D=3D NL80211_IFTYPE_AP) {
+		_rtl8821ae_resume_tx_beacon(hw);
+		_rtl8821ae_disable_bcn_sub_func(hw);
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x).\n",
+			 type);
+	}
+
+	switch (type) {
+	case NL80211_IFTYPE_UNSPECIFIED:
+		bt_msr |=3D MSR_NOLINK;
+		ledaction =3D LED_CTL_LINK;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Set Network type to NO LINK!\n");
+		break;
+	case NL80211_IFTYPE_ADHOC:
+		bt_msr |=3D MSR_ADHOC;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Set Network type to Ad Hoc!\n");
+		break;
+	case NL80211_IFTYPE_STATION:
+		bt_msr |=3D MSR_INFRA;
+		ledaction =3D LED_CTL_LINK;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Set Network type to STA!\n");
+		break;
+	case NL80211_IFTYPE_AP:
+		bt_msr |=3D MSR_AP;
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Set Network type to AP!\n");
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Network type %d not support!\n", type);
+		return 1;
+	}
+
+	rtl_write_byte(rtlpriv, (MSR), bt_msr);
+	rtlpriv->cfg->ops->led_control(hw, ledaction);
+	if ((bt_msr & 0xfc) =3D=3D MSR_AP)
+		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
+	else
+		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
+
+	return 0;
+}
+
+void rtl8821ae_set_check_bssid(struct ieee80211_hw *hw, bool check_bss=
id)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rcr =3D rtlpci->receive_config;
+
+	if (rtlpriv->psc.rfpwr_state !=3D ERFON)
+		return;
+
+	if (check_bssid) {
+		reg_rcr |=3D (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
+					      (u8 *)(&reg_rcr));
+		_rtl8821ae_set_bcn_ctrl_reg(hw, 0, BIT(4));
+	} else if (!check_bssid) {
+		reg_rcr &=3D (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
+		_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(4), 0);
+		rtlpriv->cfg->ops->set_hw_reg(hw,
+			HW_VAR_RCR, (u8 *)(&reg_rcr));
+	}
+}
+
+int rtl8821ae_set_network_type(struct ieee80211_hw *hw, enum nl80211_i=
ftype type)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "rtl8821ae_set_network_type!\n=
");
+
+	if (_rtl8821ae_set_media_status(hw, type))
+		return -EOPNOTSUPP;
+
+	if (rtlpriv->mac80211.link_state =3D=3D MAC80211_LINKED) {
+		if (type !=3D NL80211_IFTYPE_AP)
+			rtl8821ae_set_check_bssid(hw, true);
+	} else {
+		rtl8821ae_set_check_bssid(hw, false);
+	}
+
+	return 0;
+}
+
+/* don't set REG_EDCA_BE_PARAM here because mac80211 will send pkt whe=
n scan */
+void rtl8821ae_set_qos(struct ieee80211_hw *hw, int aci)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	rtl8821ae_dm_init_edca_turbo(hw);
+	switch (aci) {
+	case AC1_BK:
+		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, 0xa44f);
+		break;
+	case AC0_BE:
+		/* rtl_write_dword(rtlpriv, REG_EDCA_BE_PARAM, u4b_ac_param); */
+		break;
+	case AC2_VI:
+		rtl_write_dword(rtlpriv, REG_EDCA_VI_PARAM, 0x5e4322);
+		break;
+	case AC3_VO:
+		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, 0x2f3222);
+		break;
+	default:
+		RT_ASSERT(false, "invalid aci: %d !\n", aci);
+		break;
+	}
+}
+
+static void rtl8821ae_clear_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 tmp;
+	tmp =3D rtl_read_dword(rtlpriv, REG_HISR);
+	/*printk("clear interrupt first:\n");
+	printk("0x%x =3D 0x%08x\n",REG_HISR, tmp);*/
+	rtl_write_dword(rtlpriv, REG_HISR, tmp);
+
+	tmp =3D rtl_read_dword(rtlpriv, REG_HISRE);
+	/*printk("0x%x =3D 0x%08x\n",REG_HISRE, tmp);*/
+	rtl_write_dword(rtlpriv, REG_HISRE, tmp);
+
+	tmp =3D rtl_read_dword(rtlpriv, REG_HSISR);
+	/*printk("0x%x =3D 0x%08x\n",REG_HSISR, tmp);*/
+	rtl_write_dword(rtlpriv, REG_HSISR, tmp);
+}
+
+void rtl8821ae_enable_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	rtl8821ae_clear_interrupt(hw);/*clear it here first*/
+
+	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
+	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF)=
;
+	rtlpci->irq_enabled =3D true;
+	/* there are some C2H CMDs have been sent before
+	system interrupt is enabled, e.g., C2H, CPWM.
+	*So we need to clear all C2H events that FW has
+	notified, otherwise FW won't schedule any commands anymore.
+	*/
+	/* rtl_write_byte(rtlpriv, REG_C2HEVT_CLEAR, 0); */
+	/*enable system interrupt*/
+	rtl_write_dword(rtlpriv, REG_HSIMR, rtlpci->sys_irq_mask & 0xFFFFFFFF=
);
+}
+
+void rtl8821ae_disable_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	rtl_write_dword(rtlpriv, REG_HIMR, IMR_DISABLED);
+	rtl_write_dword(rtlpriv, REG_HIMRE, IMR_DISABLED);
+	rtlpci->irq_enabled =3D false;
+	/*synchronize_irq(rtlpci->pdev->irq);*/
+}
+
+static void _rtl8821ae_clear_pci_pme_status(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	u16 cap_hdr;
+	u8 cap_pointer;
+	u8 cap_id =3D 0xff;
+	u8 pmcs_reg;
+	u8 cnt =3D 0;
+
+	/* Get the Capability pointer first,
+	 * the Capability Pointer is located at
+	 * offset 0x34 from the Function Header */
+
+	pci_read_config_byte(rtlpci->pdev, 0x34, &cap_pointer);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "PCI configration 0x34 =3D 0x%2x\n", cap_pointer);
+
+	do {
+		pci_read_config_word(rtlpci->pdev, cap_pointer, &cap_hdr);
+		cap_id =3D cap_hdr & 0xFF;
+
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "in pci configration, cap_pointer%x =3D %x\n",
+			  cap_pointer, cap_id);
+
+		if (cap_id =3D=3D 0x01) {
+			break;
+		} else {
+			/* point to next Capability */
+			cap_pointer =3D (cap_hdr >> 8) & 0xFF;
+			/* 0: end of pci capability, 0xff: invalid value */
+			if (cap_pointer =3D=3D 0x00 || cap_pointer =3D=3D 0xff) {
+				cap_id =3D 0xff;
+				break;
+			}
+		}
+	} while (cnt++ < 200);
+
+	if (cap_id =3D=3D 0x01) {
+		/* Get the PM CSR (Control/Status Register),
+		 * The PME_Status is located at PM Capatibility offset 5, bit 7
+		 */
+		pci_read_config_byte(rtlpci->pdev, cap_pointer + 5, &pmcs_reg);
+
+		if (pmcs_reg & BIT(7)) {
+			/* PME event occured, clear the PM_Status by write 1 */
+			pmcs_reg =3D pmcs_reg | BIT(7);
+
+			pci_write_config_byte(rtlpci->pdev, cap_pointer + 5,
+					      pmcs_reg);
+			/* Read it back to check */
+			pci_read_config_byte(rtlpci->pdev, cap_pointer + 5,
+					     &pmcs_reg);
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+				 "Clear PME status 0x%2x to 0x%2x\n",
+				  cap_pointer + 5, pmcs_reg);
+		} else {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+				 "PME status(0x%2x) =3D 0x%2x\n",
+				  cap_pointer + 5, pmcs_reg);
+		}
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING,
+			 "Cannot find PME Capability\n");
+	}
+}
+
+void rtl8821ae_card_disable(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtlpriv);
+	struct rtl_mac *mac =3D rtl_mac(rtlpriv);
+	enum nl80211_iftype opmode;
+	bool support_remote_wakeup;
+	u8 tmp;
+	u32 count =3D 0;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *)(&support_remote_wakeup));
+
+	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+
+	if (!(support_remote_wakeup && mac->opmode =3D=3D NL80211_IFTYPE_STAT=
ION)
+	    || !rtlhal->enter_pnp_sleep) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Normal Power off\n");
+		mac->link_state =3D MAC80211_NOLINK;
+		opmode =3D NL80211_IFTYPE_UNSPECIFIED;
+		_rtl8821ae_set_media_status(hw, opmode);
+		_rtl8821ae_poweroff_adapter(hw);
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Wowlan Supported.\n");
+		/* 3 <1> Prepare for configuring wowlan related infomations */
+		/* Clear Fw WoWLAN event. */
+		rtl_write_byte(rtlpriv, REG_MCUTST_WOWLAN, 0x0);
+
+#if (USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN =3D=3D 1)
+		rtl8821ae_set_fw_related_for_wowlan(hw, true);
+#endif
+		/* Dynamically adjust Tx packet boundary
+		 * for download reserved page packet.
+		 * reserve 30 pages for rsvd page */
+		if (_rtl8821ae_dynamic_rqpn(hw, 0xE0, 0x3, 0x80c20d0d))
+			rtlhal->re_init_llt_table =3D true;
+
+		/* 3 <2> Set Fw releted H2C cmd. */
+
+		/* Set WoWLAN related security information. */
+		rtl8821ae_set_fw_global_info_cmd(hw);
+
+		_rtl8821ae_download_rsvd_page(hw, true);
+
+		/* Just enable AOAC related functions when we connect to AP. */
+		printk("mac->link_state =3D %d\n", mac->link_state);
+		if (mac->link_state >=3D MAC80211_LINKED &&
+		    mac->opmode =3D=3D NL80211_IFTYPE_STATION) {
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID, NULL);
+			rtl8821ae_set_fw_media_status_rpt_cmd(hw,
+							      RT_MEDIA_CONNECT);
+
+			rtl8821ae_set_fw_wowlan_mode(hw, true);
+			/* Enable Fw Keep alive mechanism. */
+			rtl8821ae_set_fw_keep_alive_cmd(hw, true);
+
+			/* Enable disconnect decision control. */
+			rtl8821ae_set_fw_disconnect_decision_ctrl_cmd(hw, true);
+		}
+
+		/* 3 <3> Hw Configutations */
+
+		/* Wait untill Rx DMA Finished before host sleep.
+		 * FW Pause Rx DMA may happens when received packet doing dma.
+		 */
+		rtl_write_byte(rtlpriv, REG_RXDMA_CONTROL, BIT(2));
+
+		tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+		count =3D 0;
+		while (!(tmp & BIT(1)) && (count++ < 100)) {
+			udelay(10);
+			tmp =3D rtl_read_byte(rtlpriv, REG_RXDMA_CONTROL);
+		}
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Wait Rx DMA Finished before host sleep. count=3D%d\n",
+			  count);
+
+		/* reset trx ring */
+		rtlpriv->intf_ops->reset_trx_ring(hw);
+
+		rtl_write_byte(rtlpriv, REG_APS_FSMCO + 1, 0x0);
+
+		_rtl8821ae_clear_pci_pme_status(hw);
+		tmp =3D rtl_read_byte(rtlpriv, REG_SYS_CLKR);
+		rtl_write_byte(rtlpriv, REG_SYS_CLKR, tmp | BIT(3));
+		/* prevent 8051 to be reset by PERST */
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x20);
+		rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x60);
+	}
+
+	if (rtlpriv->rtlhal.driver_is_goingto_unload ||
+	    ppsc->rfoff_reason > RF_CHANGE_BY_PS)
+		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
+	/* For wowlan+LPS+32k. */
+	if (support_remote_wakeup && rtlhal->enter_pnp_sleep) {
+		/* Set the WoWLAN related function control enable.
+		 * It should be the last H2C cmd in the WoWLAN flow. */
+		rtl8821ae_set_fw_remote_wake_ctrl_cmd(hw, 1);
+
+		/* Stop Pcie Interface Tx DMA. */
+		rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xff);
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Stop PCIE Tx DMA.\n");
+
+		/* Wait for TxDMA idle. */
+		count =3D 0;
+		do {
+			tmp =3D rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG);
+			udelay(10);
+			count++;
+		} while ((tmp !=3D 0) && (count < 100));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Wait Tx DMA Finished before host sleep. count=3D%d\n",
+			  count);
+
+		if (rtlhal->hw_rof_enable) {
+			printk("hw_rof_enable\n");
+			tmp =3D rtl_read_byte(rtlpriv, REG_HSISR + 3);
+			rtl_write_byte(rtlpriv, REG_HSISR + 3, tmp | BIT(1));
+		}
+	}
+	/* after power off we should do iqk again */
+	rtlpriv->phy.iqk_initialized =3D false;
+}
+
+void rtl8821ae_interrupt_recognized(struct ieee80211_hw *hw,
+				  u32 *p_inta, u32 *p_intb)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	*p_inta =3D rtl_read_dword(rtlpriv, ISR) & rtlpci->irq_mask[0];
+	rtl_write_dword(rtlpriv, ISR, *p_inta);
+
+	*p_intb =3D rtl_read_dword(rtlpriv, REG_HISRE) & rtlpci->irq_mask[1];
+	rtl_write_dword(rtlpriv, REG_HISRE, *p_intb);
+}
+
+void rtl8821ae_set_beacon_related_registers(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	u16 bcn_interval, atim_window;
+
+	bcn_interval =3D mac->beacon_interval;
+	atim_window =3D 2;	/*FIX MERGE */
+	rtl8821ae_disable_interrupt(hw);
+	rtl_write_word(rtlpriv, REG_ATIMWND, atim_window);
+	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
+	rtl_write_word(rtlpriv, REG_BCNTCFG, 0x660f);
+	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_CCK, 0x18);
+	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_OFDM, 0x18);
+	rtl_write_byte(rtlpriv, 0x606, 0x30);
+	rtlpci->reg_bcn_ctrl_val |=3D BIT(3);
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8)rtlpci->reg_bcn_ctrl_val);
+	rtl8821ae_enable_interrupt(hw);
+}
+
+void rtl8821ae_set_beacon_interval(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	u16 bcn_interval =3D mac->beacon_interval;
+
+	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG,
+		 "beacon_interval:%d\n", bcn_interval);
+	rtl8821ae_disable_interrupt(hw);
+	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
+	rtl8821ae_enable_interrupt(hw);
+}
+
+void rtl8821ae_update_interrupt_mask(struct ieee80211_hw *hw,
+				   u32 add_msr, u32 rm_msr)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
+		 "add_msr:%x, rm_msr:%x\n", add_msr, rm_msr);
+
+	if (add_msr)
+		rtlpci->irq_mask[0] |=3D add_msr;
+	if (rm_msr)
+		rtlpci->irq_mask[0] &=3D (~rm_msr);
+	rtl8821ae_disable_interrupt(hw);
+	rtl8821ae_enable_interrupt(hw);
+}
+
+static u8 _rtl8821ae_get_chnl_group(u8 chnl)
+{
+	u8 group =3D 0;
+
+	if (chnl <=3D 14) {
+		if (1 <=3D chnl && chnl <=3D 2)
+			group =3D 0;
+	else if (3 <=3D chnl && chnl <=3D 5)
+			group =3D 1;
+	else if (6 <=3D chnl && chnl <=3D 8)
+			group =3D 2;
+	else if (9 <=3D chnl && chnl <=3D 11)
+			group =3D 3;
+	else /*if (12 <=3D chnl && chnl <=3D 14)*/
+			group =3D 4;
+	} else {
+		if (36 <=3D chnl && chnl <=3D 42)
+			group =3D 0;
+	else if (44 <=3D chnl && chnl <=3D 48)
+			group =3D 1;
+	else if (50 <=3D chnl && chnl <=3D 58)
+			group =3D 2;
+	else if (60 <=3D chnl && chnl <=3D 64)
+			group =3D 3;
+	else if (100 <=3D chnl && chnl <=3D 106)
+			group =3D 4;
+	else if (108 <=3D chnl && chnl <=3D 114)
+			group =3D 5;
+	else if (116 <=3D chnl && chnl <=3D 122)
+			group =3D 6;
+	else if (124 <=3D chnl && chnl <=3D 130)
+			group =3D 7;
+	else if (132 <=3D chnl && chnl <=3D 138)
+			group =3D 8;
+	else if (140 <=3D chnl && chnl <=3D 144)
+			group =3D 9;
+	else if (149 <=3D chnl && chnl <=3D 155)
+			group =3D 10;
+	else if (157 <=3D chnl && chnl <=3D 161)
+			group =3D 11;
+	else if (165 <=3D chnl && chnl <=3D 171)
+			group =3D 12;
+	else if (173 <=3D chnl && chnl <=3D 177)
+			group =3D 13;
+		else
+			/*RT_TRACE(rtlpriv, COMP_EFUSE,DBG_LOUD,
+				"5G, Channel %d in Group not found\n",chnl);*/
+			RT_ASSERT(!COMP_EFUSE,
+				"5G, Channel %d in Group not found\n", chnl);
+	}
+	return group;
+}
+
+static void _rtl8821ae_read_power_value_fromprom(struct ieee80211_hw *=
hw,
+	struct txpower_info_2g *pwrinfo24g,
+	struct txpower_info_5g *pwrinfo5g,
+	bool autoload_fail,
+	u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 rfPath, eeAddr =3D EEPROM_TX_PWR_INX, group, TxCount =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "hal_ReadPowerValueFromPROM8821ae(): hwinfo[0x%x]=3D0x%x\n",
+		 (eeAddr+1), hwinfo[eeAddr+1]);
+	if (0xFF =3D=3D hwinfo[eeAddr+1])  /*YJ,add,120316*/
+		autoload_fail =3D true;
+
+	if (autoload_fail) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "auto load fail : Use Default value!\n");
+		for (rfPath =3D 0 ; rfPath < MAX_RF_PATH ; rfPath++) {
+			/*2.4G default value*/
+			for (group =3D 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+				pwrinfo24g->index_cck_base[rfPath][group] =3D	0x2D;
+				pwrinfo24g->index_bw40_base[rfPath][group] =3D 0x2D;
+			}
+			for (TxCount =3D 0; TxCount < MAX_TX_COUNT; TxCount++) {
+				if (TxCount =3D=3D 0) {
+					pwrinfo24g->bw20_diff[rfPath][0] =3D 0x02;
+					pwrinfo24g->ofdm_diff[rfPath][0] =3D 0x04;
+				} else {
+					pwrinfo24g->bw20_diff[rfPath][TxCount] =3D 0xFE;
+					pwrinfo24g->bw40_diff[rfPath][TxCount] =3D 0xFE;
+					pwrinfo24g->cck_diff[rfPath][TxCount] =3D	0xFE;
+					pwrinfo24g->ofdm_diff[rfPath][TxCount] =3D 0xFE;
+				}
+			}
+			/*5G default value*/
+			for (group =3D 0 ; group < MAX_CHNL_GROUP_5G; group++)
+				pwrinfo5g->index_bw40_base[rfPath][group] =3D 0x2A;
+
+			for (TxCount =3D 0; TxCount < MAX_TX_COUNT; TxCount++) {
+				if (TxCount =3D=3D 0) {
+					pwrinfo5g->ofdm_diff[rfPath][0] =3D 0x04;
+					pwrinfo5g->bw20_diff[rfPath][0] =3D 0x00;
+					pwrinfo5g->bw80_diff[rfPath][0] =3D 0xFE;
+					pwrinfo5g->bw160_diff[rfPath][0] =3D 0xFE;
+				} else {
+					pwrinfo5g->ofdm_diff[rfPath][0] =3D 0xFE;
+					pwrinfo5g->bw20_diff[rfPath][0] =3D 0xFE;
+					pwrinfo5g->bw40_diff[rfPath][0] =3D 0xFE;
+					pwrinfo5g->bw80_diff[rfPath][0] =3D 0xFE;
+					pwrinfo5g->bw160_diff[rfPath][0] =3D 0xFE;
+				}
+			}
+		}
+		return;
+	}
+
+	rtl_priv(hw)->efuse.txpwr_fromeprom =3D true;
+
+	for (rfPath =3D 0 ; rfPath < MAX_RF_PATH ; rfPath++) {
+		/*2.4G default value*/
+		for (group =3D 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+			pwrinfo24g->index_cck_base[rfPath][group] =3D hwinfo[eeAddr++];
+			if (pwrinfo24g->index_cck_base[rfPath][group] =3D=3D 0xFF)
+				pwrinfo24g->index_cck_base[rfPath][group] =3D 0x2D;
+		}
+		for (group =3D 0 ; group < MAX_CHNL_GROUP_24G - 1; group++) {
+			pwrinfo24g->index_bw40_base[rfPath][group] =3D hwinfo[eeAddr++];
+			if (pwrinfo24g->index_bw40_base[rfPath][group] =3D=3D 0xFF)
+				pwrinfo24g->index_bw40_base[rfPath][group] =3D 0x2D;
+		}
+		for (TxCount =3D 0; TxCount < MAX_TX_COUNT; TxCount++) {
+			if (TxCount =3D=3D 0) {
+				pwrinfo24g->bw40_diff[rfPath][TxCount] =3D 0;
+				/*bit sign number to 8 bit sign number*/
+				pwrinfo24g->bw20_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0xf0)=
 >> 4;
+				if (pwrinfo24g->bw20_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->bw20_diff[rfPath][TxCount] |=3D 0xF0;
+				/*bit sign number to 8 bit sign number*/
+				pwrinfo24g->ofdm_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0x0f)=
;
+				if (pwrinfo24g->ofdm_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->ofdm_diff[rfPath][TxCount] |=3D 0xF0;
+
+				pwrinfo24g->cck_diff[rfPath][TxCount] =3D 0;
+				eeAddr++;
+			} else {
+				pwrinfo24g->bw40_diff[rfPath][TxCount] =3D (hwinfo[eeAddr]&0xf0) >=
> 4;
+				if (pwrinfo24g->bw40_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->bw40_diff[rfPath][TxCount] |=3D 0xF0;
+
+				pwrinfo24g->bw20_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0x0f)=
;
+				if (pwrinfo24g->bw20_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->bw20_diff[rfPath][TxCount] |=3D 0xF0;
+
+				eeAddr++;
+
+				pwrinfo24g->ofdm_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0xf0)=
 >> 4;
+				if (pwrinfo24g->ofdm_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->ofdm_diff[rfPath][TxCount] |=3D 0xF0;
+
+				pwrinfo24g->cck_diff[rfPath][TxCount] =3D	(hwinfo[eeAddr] & 0x0f);
+				if (pwrinfo24g->cck_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo24g->cck_diff[rfPath][TxCount] |=3D 0xF0;
+
+				eeAddr++;
+			}
+		}
+
+		/*5G default value*/
+		for (group =3D 0 ; group < MAX_CHNL_GROUP_5G; group++) {
+			pwrinfo5g->index_bw40_base[rfPath][group] =3D hwinfo[eeAddr++];
+			if (pwrinfo5g->index_bw40_base[rfPath][group] =3D=3D 0xFF)
+				pwrinfo5g->index_bw40_base[rfPath][group] =3D 0xFE;
+		}
+
+		for (TxCount =3D 0; TxCount < MAX_TX_COUNT; TxCount++) {
+			if (TxCount =3D=3D 0) {
+				pwrinfo5g->bw40_diff[rfPath][TxCount] =3D 0;
+
+				pwrinfo5g->bw20_diff[rfPath][0] =3D (hwinfo[eeAddr] & 0xf0) >> 4;
+				if (pwrinfo5g->bw20_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo5g->bw20_diff[rfPath][TxCount] |=3D 0xF0;
+
+				pwrinfo5g->ofdm_diff[rfPath][0] =3D (hwinfo[eeAddr] & 0x0f);
+				if (pwrinfo5g->ofdm_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo5g->ofdm_diff[rfPath][TxCount] |=3D 0xF0;
+
+				eeAddr++;
+			} else {
+				pwrinfo5g->bw40_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0xf0) =
>> 4;
+				if (pwrinfo5g->bw40_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo5g->bw40_diff[rfPath][TxCount] |=3D 0xF0;
+
+				pwrinfo5g->bw20_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0x0f);
+				if (pwrinfo5g->bw20_diff[rfPath][TxCount] & BIT(3))
+					pwrinfo5g->bw20_diff[rfPath][TxCount] |=3D 0xF0;
+
+				eeAddr++;
+			}
+		}
+
+		pwrinfo5g->ofdm_diff[rfPath][1] =3D	(hwinfo[eeAddr] & 0xf0) >> 4;
+		pwrinfo5g->ofdm_diff[rfPath][2] =3D	(hwinfo[eeAddr] & 0x0f);
+
+		eeAddr++;
+
+		pwrinfo5g->ofdm_diff[rfPath][3] =3D (hwinfo[eeAddr] & 0x0f);
+
+		eeAddr++;
+
+		for (TxCount =3D 1; TxCount < MAX_TX_COUNT; TxCount++) {
+			if (pwrinfo5g->ofdm_diff[rfPath][TxCount] & BIT(3))
+				pwrinfo5g->ofdm_diff[rfPath][TxCount] |=3D 0xF0;
+		}
+		for (TxCount =3D 0; TxCount < MAX_TX_COUNT; TxCount++) {
+			pwrinfo5g->bw80_diff[rfPath][TxCount] =3D	(hwinfo[eeAddr] & 0xf0) >=
> 4;
+			/* 4bit sign number to 8 bit sign number */
+			if (pwrinfo5g->bw80_diff[rfPath][TxCount] & BIT(3))
+				pwrinfo5g->bw80_diff[rfPath][TxCount] |=3D 0xF0;
+			/* 4bit sign number to 8 bit sign number */
+			pwrinfo5g->bw160_diff[rfPath][TxCount] =3D (hwinfo[eeAddr] & 0x0f);
+			if (pwrinfo5g->bw160_diff[rfPath][TxCount] & BIT(3))
+				pwrinfo5g->bw160_diff[rfPath][TxCount] |=3D 0xF0;
+
+			eeAddr++;
+		}
+	}
+}
+#if 0
+static void _rtl8812ae_read_txpower_info_from_hwpg(struct ieee80211_hw=
 *hw,
+						 bool autoload_fail,
+						 u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct txpower_info_2g pwrinfo24g;
+	struct txpower_info_5g pwrinfo5g;
+	u8 channel5g[CHANNEL_MAX_NUMBER_5G] =3D {
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54,
+		56, 58, 60, 62, 64, 100, 102, 104, 106,
+		108, 110, 112, 114, 116, 118, 120, 122,
+		124, 126, 128, 130, 132, 134, 136, 138,
+		140, 142, 144, 149, 151, 153, 155, 157,
+		159, 161, 163, 165, 167, 168, 169, 171, 173, 175, 177};
+	u8 channel5g_80m[CHANNEL_MAX_NUMBER_5G_80M] =3D {42, 58, 106, 122, 13=
8, 155, 171};
+	u8 rf_path, index;
+	u8 i;
+
+	_rtl8821ae_read_power_value_fromprom(hw, &pwrinfo24g,
+					&pwrinfo5g, autoload_fail, hwinfo);
+
+	for (rf_path =3D 0; rf_path < 2; rf_path++) {
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_2G; i++) {
+			index =3D _rtl8821ae_get_chnl_group(i + 1);
+
+			if (i =3D=3D CHANNEL_MAX_NUMBER_2G - 1) {
+				rtlefuse->txpwrlevel_cck[rf_path][i] =3D
+					pwrinfo24g.index_cck_base[rf_path][5];
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =3D
+					pwrinfo24g.index_bw40_base[rf_path][index];
+			} else {
+				rtlefuse->txpwrlevel_cck[rf_path][i] =3D
+					pwrinfo24g.index_cck_base[rf_path][index];
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =3D
+					pwrinfo24g.index_bw40_base[rf_path][index];
+			}
+		}
+
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_5G; i++) {
+			index =3D _rtl8821ae_get_chnl_group(channel5g[i]);
+			rtlefuse->txpwr_5g_bw40base[rf_path][i] =3D
+					pwrinfo5g.index_bw40_base[rf_path][index];
+		}
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_5G_80M; i++) {
+			u8 upper, lower;
+			index =3D _rtl8821ae_get_chnl_group(channel5g_80m[i]);
+			upper =3D pwrinfo5g.index_bw40_base[rf_path][index];
+			lower =3D pwrinfo5g.index_bw40_base[rf_path][index + 1];
+
+			rtlefuse->txpwr_5g_bw80base[rf_path][i] =3D (upper + lower) / 2;
+		}
+		for (i =3D 0; i < MAX_TX_COUNT; i++) {
+			rtlefuse->txpwr_cckdiff[rf_path][i] =3D
+				pwrinfo24g.cck_diff[rf_path][i];
+			rtlefuse->txpwr_legacyhtdiff[rf_path][i] =3D
+				pwrinfo24g.ofdm_diff[rf_path][i];
+			rtlefuse->txpwr_ht20diff[rf_path][i] =3D
+				pwrinfo24g.bw20_diff[rf_path][i];
+			rtlefuse->txpwr_ht40diff[rf_path][i] =3D
+				pwrinfo24g.bw40_diff[rf_path][i];
+
+			rtlefuse->txpwr_5g_ofdmdiff[rf_path][i] =3D
+				pwrinfo5g.ofdm_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw20diff[rf_path][i] =3D
+				pwrinfo5g.bw20_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw40diff[rf_path][i] =3D
+				pwrinfo5g.bw40_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw80diff[rf_path][i] =3D
+				pwrinfo5g.bw80_diff[rf_path][i];
+		}
+	}
+
+	if (!autoload_fail) {
+		rtlefuse->eeprom_regulatory =3D
+			hwinfo[EEPROM_RF_BOARD_OPTION] & 0x07;/*bit0~2*/
+		if (hwinfo[EEPROM_RF_BOARD_OPTION] =3D=3D 0xFF)
+			rtlefuse->eeprom_regulatory =3D 0;
+	} else {
+		rtlefuse->eeprom_regulatory =3D 0;
+	}
+
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
+	"eeprom_regulatory =3D 0x%x\n", rtlefuse->eeprom_regulatory);
+}
+#endif
+static void _rtl8821ae_read_txpower_info_from_hwpg(struct ieee80211_hw=
 *hw,
+						 bool autoload_fail,
+						 u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct txpower_info_2g pwrinfo24g;
+	struct txpower_info_5g pwrinfo5g;
+	u8 channel5g[CHANNEL_MAX_NUMBER_5G] =3D {
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54,
+		56, 58, 60, 62, 64, 100, 102, 104, 106,
+		108, 110, 112, 114, 116, 118, 120, 122,
+		124, 126, 128, 130, 132, 134, 136, 138,
+		140, 142, 144, 149, 151, 153, 155, 157,
+		159, 161, 163, 165, 167, 168, 169, 171,
+		173, 175, 177};
+	u8 channel5g_80m[CHANNEL_MAX_NUMBER_5G_80M] =3D {
+		42, 58, 106, 122, 138, 155, 171};
+	u8 rf_path, index;
+	u8 i;
+
+	_rtl8821ae_read_power_value_fromprom(hw, &pwrinfo24g,
+		&pwrinfo5g, autoload_fail, hwinfo);
+
+	for (rf_path =3D 0; rf_path < 2; rf_path++) {
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_2G; i++) {
+			index =3D _rtl8821ae_get_chnl_group(i + 1);
+
+			if (i =3D=3D CHANNEL_MAX_NUMBER_2G - 1) {
+				rtlefuse->txpwrlevel_cck[rf_path][i] =3D
+					pwrinfo24g.index_cck_base[rf_path][5];
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =3D
+					pwrinfo24g.index_bw40_base[rf_path][index];
+			} else {
+				rtlefuse->txpwrlevel_cck[rf_path][i] =3D
+					pwrinfo24g.index_cck_base[rf_path][index];
+				rtlefuse->txpwrlevel_ht40_1s[rf_path][i] =3D
+					pwrinfo24g.index_bw40_base[rf_path][index];
+			}
+		}
+
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_5G; i++) {
+			index =3D _rtl8821ae_get_chnl_group(channel5g[i]);
+			rtlefuse->txpwr_5g_bw40base[rf_path][i] =3D
+				pwrinfo5g.index_bw40_base[rf_path][index];
+		}
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_5G_80M; i++) {
+			u8 upper, lower;
+			index =3D _rtl8821ae_get_chnl_group(channel5g_80m[i]);
+			upper =3D pwrinfo5g.index_bw40_base[rf_path][index];
+			lower =3D pwrinfo5g.index_bw40_base[rf_path][index + 1];
+
+			rtlefuse->txpwr_5g_bw80base[rf_path][i] =3D (upper + lower) / 2;
+		}
+		for (i =3D 0; i < MAX_TX_COUNT; i++) {
+			rtlefuse->txpwr_cckdiff[rf_path][i] =3D
+				pwrinfo24g.cck_diff[rf_path][i];
+			rtlefuse->txpwr_legacyhtdiff[rf_path][i] =3D
+				pwrinfo24g.ofdm_diff[rf_path][i];
+			rtlefuse->txpwr_ht20diff[rf_path][i] =3D
+				pwrinfo24g.bw20_diff[rf_path][i];
+			rtlefuse->txpwr_ht40diff[rf_path][i] =3D
+				pwrinfo24g.bw40_diff[rf_path][i];
+
+			rtlefuse->txpwr_5g_ofdmdiff[rf_path][i] =3D
+				pwrinfo5g.ofdm_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw20diff[rf_path][i] =3D
+				pwrinfo5g.bw20_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw40diff[rf_path][i] =3D
+				pwrinfo5g.bw40_diff[rf_path][i];
+			rtlefuse->txpwr_5g_bw80diff[rf_path][i] =3D
+				pwrinfo5g.bw80_diff[rf_path][i];
+		}
+	}
+	/*bit0~2*/
+	if (!autoload_fail) {
+		rtlefuse->eeprom_regulatory =3D hwinfo[EEPROM_RF_BOARD_OPTION] & 0x0=
7;
+		if (hwinfo[EEPROM_RF_BOARD_OPTION] =3D=3D 0xFF)
+			rtlefuse->eeprom_regulatory =3D 0;
+	} else {
+		rtlefuse->eeprom_regulatory =3D 0;
+	}
+
+	RTPRINT(rtlpriv, FINIT, INIT_TXPOWER,
+	"eeprom_regulatory =3D 0x%x\n", rtlefuse->eeprom_regulatory);
+}
+
+static void _rtl8812ae_read_pa_type(struct ieee80211_hw *hw, u8 *hwinf=
o,
+				    bool autoload_fail)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+
+	if (!autoload_fail) {
+		rtlhal->pa_type_2g =3D hwinfo[0xBC];
+		rtlhal->lna_type_2g =3D hwinfo[0xBD];
+		if (rtlhal->pa_type_2g =3D=3D 0xFF && rtlhal->lna_type_2g =3D=3D 0xF=
=46) {
+			rtlhal->pa_type_2g =3D 0;
+			rtlhal->lna_type_2g =3D 0;
+		}
+		rtlhal->external_pa_2g =3D ((rtlhal->pa_type_2g & BIT(5)) &&
+					  (rtlhal->pa_type_2g & BIT(4))) ?
+					 1 : 0;
+		rtlhal->external_lna_2g =3D ((rtlhal->lna_type_2g & BIT(7)) &&
+					   (rtlhal->lna_type_2g & BIT(3))) ?
+					  1 : 0;
+
+		rtlhal->pa_type_5g =3D hwinfo[0xBC];
+		rtlhal->lna_type_5g =3D hwinfo[0xBF];
+		if (rtlhal->pa_type_5g =3D=3D 0xFF && rtlhal->lna_type_5g =3D=3D 0xF=
=46) {
+			rtlhal->pa_type_5g =3D 0;
+			rtlhal->lna_type_5g =3D 0;
+		}
+		rtlhal->external_pa_5g =3D ((rtlhal->pa_type_5g & BIT(1)) &&
+					  (rtlhal->pa_type_5g & BIT(0))) ?
+					 1 : 0;
+		rtlhal->external_lna_5g =3D ((rtlhal->lna_type_5g & BIT(7)) &&
+					   (rtlhal->lna_type_5g & BIT(3))) ?
+					  1 : 0;
+	} else {
+		rtlhal->external_pa_2g  =3D 0;
+		rtlhal->external_lna_2g =3D 0;
+		rtlhal->external_pa_5g  =3D 0;
+		rtlhal->external_lna_5g =3D 0;
+	}
+}
+
+static void _rtl8821ae_read_pa_type(struct ieee80211_hw *hw, u8 *hwinf=
o,
+				    bool autoload_fail)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+
+	if (!autoload_fail) {
+		rtlhal->pa_type_2g =3D hwinfo[0xBC];
+		rtlhal->lna_type_2g =3D hwinfo[0xBD];
+		if (rtlhal->pa_type_2g =3D=3D 0xFF && rtlhal->lna_type_2g =3D=3D 0xF=
=46) {
+			rtlhal->pa_type_2g =3D 0;
+			rtlhal->lna_type_2g =3D 0;
+		}
+		rtlhal->external_pa_2g =3D (rtlhal->pa_type_2g & BIT(5)) ? 1 : 0;
+		rtlhal->external_lna_2g =3D (rtlhal->lna_type_2g & BIT(7)) ? 1 : 0;
+
+		rtlhal->pa_type_5g =3D hwinfo[0xBC];
+		rtlhal->lna_type_5g =3D hwinfo[0xBF];
+		if (rtlhal->pa_type_5g =3D=3D 0xFF && rtlhal->lna_type_5g =3D=3D 0xF=
=46) {
+			rtlhal->pa_type_5g =3D 0;
+			rtlhal->lna_type_5g =3D 0;
+		}
+		rtlhal->external_pa_5g =3D (rtlhal->pa_type_5g & BIT(1)) ? 1 : 0;
+		rtlhal->external_lna_5g =3D (rtlhal->lna_type_5g & BIT(7)) ? 1 : 0;
+	} else {
+		rtlhal->external_pa_2g  =3D 0;
+		rtlhal->external_lna_2g =3D 0;
+		rtlhal->external_pa_5g  =3D 0;
+		rtlhal->external_lna_5g =3D 0;
+	}
+}
+
+static void _rtl8821ae_read_rfe_type(struct ieee80211_hw *hw, u8 *hwin=
fo,
+			      bool autoload_fail)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+
+	if (!autoload_fail) {
+		if (hwinfo[EEPROM_RFE_OPTION] & BIT(7)) {
+			if (rtlhal->external_lna_5g) {
+				if (rtlhal->external_pa_5g) {
+					if (rtlhal->external_lna_2g &&
+					    rtlhal->external_pa_2g)
+						rtlhal->rfe_type =3D 3;
+					else
+						rtlhal->rfe_type =3D 0;
+				} else {
+					rtlhal->rfe_type =3D 2;
+				}
+			} else {
+				rtlhal->rfe_type =3D 4;
+			}
+		} else {
+			rtlhal->rfe_type =3D hwinfo[EEPROM_RFE_OPTION] & 0x3F;
+
+			if (rtlhal->rfe_type =3D=3D 4 &&
+			    (rtlhal->external_pa_5g ||
+			     rtlhal->external_pa_2g ||
+			     rtlhal->external_lna_5g ||
+			     rtlhal->external_lna_2g)) {
+				if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+					rtlhal->rfe_type =3D 2;
+			}
+		}
+	} else {
+		rtlhal->rfe_type =3D 0x04;
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "RFE Type: 0x%2x\n", rtlhal->rfe_type);
+}
+
+static void _rtl8812ae_read_bt_coexist_info_from_hwpg(struct ieee80211=
_hw *hw,
+					      bool auto_load_fail, u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 value;
+
+	if (!auto_load_fail) {
+		value =3D *(u8 *)&hwinfo[EEPROM_RF_BOARD_OPTION];
+		if (((value & 0xe0) >> 5) =3D=3D 0x1)
+			rtlpriv->btcoexist.btc_info.btcoexist =3D 1;
+		else
+			rtlpriv->btcoexist.btc_info.btcoexist =3D 0;
+		rtlpriv->btcoexist.btc_info.bt_type =3D BT_RTL8812A;
+
+		value =3D hwinfo[EEPROM_RF_BT_SETTING];
+		rtlpriv->btcoexist.btc_info.ant_num =3D (value & 0x1);
+	} else {
+		rtlpriv->btcoexist.btc_info.btcoexist =3D 0;
+		rtlpriv->btcoexist.btc_info.bt_type =3D BT_RTL8812A;
+		rtlpriv->btcoexist.btc_info.ant_num =3D ANT_X2;
+	}
+	/*move BT_InitHalVars() to init_sw_vars*/
+}
+
+static void _rtl8821ae_read_bt_coexist_info_from_hwpg(struct ieee80211=
_hw *hw,
+					      bool auto_load_fail, u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 value;
+	u32 tmpu_32;
+
+	if (!auto_load_fail) {
+		tmpu_32 =3D rtl_read_dword(rtlpriv, REG_MULTI_FUNC_CTRL);
+		if (tmpu_32 & BIT(18))
+			rtlpriv->btcoexist.btc_info.btcoexist =3D 1;
+		else
+			rtlpriv->btcoexist.btc_info.btcoexist =3D 0;
+		rtlpriv->btcoexist.btc_info.bt_type =3D BT_RTL8821A;
+
+		value =3D hwinfo[EEPROM_RF_BT_SETTING];
+		rtlpriv->btcoexist.btc_info.ant_num =3D (value & 0x1);
+	} else {
+		rtlpriv->btcoexist.btc_info.btcoexist =3D 0;
+		rtlpriv->btcoexist.btc_info.bt_type =3D BT_RTL8821A;
+		rtlpriv->btcoexist.btc_info.ant_num =3D ANT_X2;
+	}
+	/*move BT_InitHalVars() to init_sw_vars*/
+}
+
+static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool=
 b_pseudo_test)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	u16 i, usvalue;
+	u8 hwinfo[HWSET_MAX_SIZE];
+	u16 eeprom_id;
+
+	if (b_pseudo_test) {
+		;/* need add */
+	}
+
+	if (rtlefuse->epromtype =3D=3D EEPROM_BOOT_EFUSE) {
+		rtl_efuse_shadow_map_update(hw);
+		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
+		       HWSET_MAX_SIZE);
+	} else if (rtlefuse->epromtype =3D=3D EEPROM_93C46) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "RTL819X Not boot from eeprom, check it !!");
+	}
+
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP\n",
+		      hwinfo, HWSET_MAX_SIZE);
+
+	eeprom_id =3D *((u16 *)&hwinfo[0]);
+	if (eeprom_id !=3D RTL_EEPROM_ID) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "EEPROM ID(%#x) is invalid!!\n", eeprom_id);
+		rtlefuse->autoload_failflag =3D true;
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
+		rtlefuse->autoload_failflag =3D false;
+	}
+
+	if (rtlefuse->autoload_failflag) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "RTL8812AE autoload_failflag, check it !!");
+		return;
+	}
+
+	rtlefuse->eeprom_version =3D *(u8 *)&hwinfo[EEPROM_VERSION];
+	if (rtlefuse->eeprom_version =3D=3D 0xff)
+			rtlefuse->eeprom_version =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM version: 0x%2x\n", rtlefuse->eeprom_version);
+
+	rtlefuse->eeprom_vid =3D *(u16 *)&hwinfo[EEPROM_VID];
+	rtlefuse->eeprom_did =3D *(u16 *)&hwinfo[EEPROM_DID];
+	rtlefuse->eeprom_svid =3D *(u16 *)&hwinfo[EEPROM_SVID];
+	rtlefuse->eeprom_smid =3D *(u16 *)&hwinfo[EEPROM_SMID];
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROMId =3D 0x%4x\n", eeprom_id);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM VID =3D 0x%4x\n", rtlefuse->eeprom_vid);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM DID =3D 0x%4x\n", rtlefuse->eeprom_did);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM SVID =3D 0x%4x\n", rtlefuse->eeprom_svid);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM SMID =3D 0x%4x\n", rtlefuse->eeprom_smid);
+
+	/*customer ID*/
+	rtlefuse->eeprom_oemid =3D *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	if (rtlefuse->eeprom_oemid =3D=3D 0xFF)
+		rtlefuse->eeprom_oemid =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
+
+	for (i =3D 0; i < 6; i +=3D 2) {
+		usvalue =3D *(u16 *)&hwinfo[EEPROM_MAC_ADDR + i];
+		*((u16 *)(&rtlefuse->dev_addr[i])) =3D usvalue;
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "dev_addr: %pM\n", rtlefuse->dev_addr);
+
+	_rtl8821ae_read_txpower_info_from_hwpg(hw, rtlefuse->autoload_failfla=
g,
+					       hwinfo);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		_rtl8812ae_read_pa_type(hw, hwinfo, rtlefuse->autoload_failflag);
+		_rtl8812ae_read_bt_coexist_info_from_hwpg(hw,
+				rtlefuse->autoload_failflag, hwinfo);
+	} else {
+		_rtl8821ae_read_pa_type(hw, hwinfo, rtlefuse->autoload_failflag);
+		_rtl8821ae_read_bt_coexist_info_from_hwpg(hw,
+				rtlefuse->autoload_failflag, hwinfo);
+	}
+
+	_rtl8821ae_read_rfe_type(hw, hwinfo, rtlefuse->autoload_failflag);
+	/*board type*/
+	rtlefuse->board_type =3D ODM_BOARD_DEFAULT;
+	if (rtlhal->external_lna_2g !=3D 0)
+		rtlefuse->board_type |=3D ODM_BOARD_EXT_LNA;
+	if (rtlhal->external_lna_5g !=3D 0)
+		rtlefuse->board_type |=3D ODM_BOARD_EXT_LNA_5G;
+	if (rtlhal->external_pa_2g !=3D 0)
+		rtlefuse->board_type |=3D ODM_BOARD_EXT_PA;
+	if (rtlhal->external_pa_5g !=3D 0)
+		rtlefuse->board_type |=3D ODM_BOARD_EXT_PA_5G;
+
+	if (rtlpriv->btcoexist.btc_info.btcoexist =3D=3D 1)
+		rtlefuse->board_type |=3D ODM_BOARD_BT;
+
+	rtlhal->board_type =3D rtlefuse->board_type;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "board_type =3D 0x%x\n", rtlefuse->board_type);
+
+	rtlefuse->eeprom_channelplan =3D *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	if (rtlefuse->eeprom_channelplan =3D=3D 0xff)
+		rtlefuse->eeprom_channelplan =3D 0x7F;
+
+	/* set channel paln to world wide 13 */
+	/* rtlefuse->channel_plan =3D (u8)rtlefuse->eeprom_channelplan; */
+
+	/*parse xtal*/
+	rtlefuse->crystalcap =3D hwinfo[EEPROM_XTAL_8821AE];
+	if (rtlefuse->crystalcap =3D=3D 0xFF)
+		rtlefuse->crystalcap =3D 0x20;
+
+	rtlefuse->eeprom_thermalmeter =3D *(u8 *)&hwinfo[EEPROM_THERMAL_METER=
];
+	if ((rtlefuse->eeprom_thermalmeter =3D=3D 0xff) ||
+	    rtlefuse->autoload_failflag) {
+		rtlefuse->apk_thermalmeterignore =3D true;
+		rtlefuse->eeprom_thermalmeter =3D 0xff;
+	}
+
+	rtlefuse->thermalmeter[0] =3D rtlefuse->eeprom_thermalmeter;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "thermalmeter =3D 0x%x\n", rtlefuse->eeprom_thermalmeter);
+
+	if (!rtlefuse->autoload_failflag) {
+		rtlefuse->antenna_div_cfg =3D
+		  (hwinfo[EEPROM_RF_BOARD_OPTION] & 0x18) >> 3;
+		if (hwinfo[EEPROM_RF_BOARD_OPTION] =3D=3D 0xff)
+			rtlefuse->antenna_div_cfg =3D 0;
+
+		if (rtlpriv->btcoexist.btc_info.btcoexist =3D=3D 1 &&
+		    rtlpriv->btcoexist.btc_info.ant_num =3D=3D ANT_X1)
+			rtlefuse->antenna_div_cfg =3D 0;
+
+		rtlefuse->antenna_div_type =3D hwinfo[EEPROM_RF_ANTENNA_OPT_88E];
+		if (rtlefuse->antenna_div_type =3D=3D 0xff)
+			rtlefuse->antenna_div_type =3D FIXED_HW_ANTDIV;
+	} else {
+		rtlefuse->antenna_div_cfg =3D 0;
+		rtlefuse->antenna_div_type =3D 0;
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		"SWAS: bHwAntDiv =3D %x, TRxAntDivType =3D %x\n",
+		rtlefuse->antenna_div_cfg, rtlefuse->antenna_div_type);
+
+	pcipriv->ledctl.led_opendrain =3D true;
+
+	if (rtlhal->oem_id =3D=3D RT_CID_DEFAULT) {
+		switch (rtlefuse->eeprom_oemid) {
+		case RT_CID_DEFAULT:
+			break;
+		case EEPROM_CID_TOSHIBA:
+			rtlhal->oem_id =3D RT_CID_TOSHIBA;
+			break;
+		case EEPROM_CID_CCX:
+			rtlhal->oem_id =3D RT_CID_CCX;
+			break;
+		case EEPROM_CID_QMI:
+			rtlhal->oem_id =3D RT_CID_819X_QMI;
+			break;
+		case EEPROM_CID_WHQL:
+			break;
+		default:
+			break;
+		}
+	}
+}
+
+/*static void _rtl8821ae_hal_customized_behavior(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	pcipriv->ledctl.led_opendrain =3D true;
+	switch (rtlhal->oem_id) {
+	case RT_CID_819X_HP:
+		pcipriv->ledctl.led_opendrain =3D true;
+		break;
+	case RT_CID_819X_LENOVO:
+	case RT_CID_DEFAULT:
+	case RT_CID_TOSHIBA:
+	case RT_CID_CCX:
+	case RT_CID_819X_ACER:
+	case RT_CID_WHQL:
+	default:
+		break;
+	}
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
+		 "RT Customized ID: 0x%02X\n", rtlhal->oem_id);
+}*/
+
+void rtl8821ae_read_eeprom_info(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 tmp_u1b;
+
+	rtlhal->version =3D _rtl8821ae_read_chip_version(hw);
+	if (get_rf_type(rtlphy) =3D=3D RF_1T1R)
+		rtlpriv->dm.rfpath_rxenable[0] =3D true;
+	else
+		rtlpriv->dm.rfpath_rxenable[0] =3D
+		    rtlpriv->dm.rfpath_rxenable[1] =3D true;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "VersionID =3D 0x%4x\n",
+						rtlhal->version);
+
+	tmp_u1b =3D rtl_read_byte(rtlpriv, REG_9346CR);
+	if (tmp_u1b & BIT(4)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EEPROM\n");
+		rtlefuse->epromtype =3D EEPROM_93C46;
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EFUSE\n");
+		rtlefuse->epromtype =3D EEPROM_BOOT_EFUSE;
+	}
+
+	if (tmp_u1b & BIT(5)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
+		rtlefuse->autoload_failflag =3D false;
+		_rtl8821ae_read_adapter_info(hw, false);
+	} else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Autoload ERR!!\n");
+	}
+	/*hal_ReadRFType_8812A()*/
+	/* _rtl8821ae_hal_customized_behavior(hw); */
+}
+
+static void rtl8821ae_update_hal_rate_table(struct ieee80211_hw *hw,
+		struct ieee80211_sta *sta)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u32 ratr_value;
+	u8 ratr_index =3D 0;
+	u8 b_nmode =3D mac->ht_enable;
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+	u16 shortgi_rate;
+	u32 tmp_ratr_value;
+	u8 curtxbw_40mhz =3D mac->bw_40;
+	u8 b_curshortgi_40mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40)=
 ?
+				1 : 0;
+	u8 b_curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20)=
 ?
+				1 : 0;
+	enum wireless_mode wirelessmode =3D mac->mode;
+
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_5G)
+		ratr_value =3D sta->supp_rates[1] << 4;
+	else
+		ratr_value =3D sta->supp_rates[0];
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_value =3D 0xfff;
+	ratr_value |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		if (ratr_value & 0x0000000c)
+			ratr_value &=3D 0x0000000d;
+		else
+			ratr_value &=3D 0x0000000f;
+		break;
+	case WIRELESS_MODE_G:
+		ratr_value &=3D 0x00000FF5;
+		break;
+	case WIRELESS_MODE_N_24G:
+	case WIRELESS_MODE_N_5G:
+		b_nmode =3D 1;
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC) {
+			ratr_value &=3D 0x0007F005;
+		} else {
+			u32 ratr_mask;
+
+			if (get_rf_type(rtlphy) =3D=3D RF_1T2R ||
+			    get_rf_type(rtlphy) =3D=3D RF_1T1R)
+				ratr_mask =3D 0x000ff005;
+			else
+				ratr_mask =3D 0x0f0ff005;
+
+			ratr_value &=3D ratr_mask;
+		}
+		break;
+	default:
+		if (rtlphy->rf_type =3D=3D RF_1T2R)
+			ratr_value &=3D 0x000ff0ff;
+		else
+			ratr_value &=3D 0x0f0ff0ff;
+
+		break;
+	}
+
+	if ((rtlpriv->btcoexist.bt_coexistence) &&
+	     (rtlpriv->btcoexist.bt_coexist_type =3D=3D BT_CSR_BC4) &&
+	     (rtlpriv->btcoexist.bt_cur_state) &&
+	     (rtlpriv->btcoexist.bt_ant_isolation) &&
+	     ((rtlpriv->btcoexist.bt_service =3D=3D BT_SCO) ||
+	     (rtlpriv->btcoexist.bt_service =3D=3D BT_BUSY)))
+		ratr_value &=3D 0x0fffcfc0;
+	else
+		ratr_value &=3D 0x0FFFFFFF;
+
+	if (b_nmode && ((curtxbw_40mhz &&
+			 b_curshortgi_40mhz) || (!curtxbw_40mhz &&
+						 b_curshortgi_20mhz))) {
+		ratr_value |=3D 0x10000000;
+		tmp_ratr_value =3D (ratr_value >> 12);
+
+		for (shortgi_rate =3D 15; shortgi_rate > 0; shortgi_rate--) {
+			if ((1 << shortgi_rate) & tmp_ratr_value)
+				break;
+		}
+
+		shortgi_rate =3D (shortgi_rate << 12) | (shortgi_rate << 8) |
+		    (shortgi_rate << 4) | (shortgi_rate);
+	}
+
+	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "%x\n", rtl_read_dword(rtlpriv, REG_ARFR0));
+}
+
+static u8 _rtl8821ae_mrate_idx_to_arfr_id(
+	struct ieee80211_hw *hw, u8 rate_index,
+	enum wireless_mode wirelessmode)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 ret =3D 0;
+	switch (rate_index) {
+	case RATR_INX_WIRELESS_NGB:
+		if (rtlphy->rf_type =3D=3D RF_1T1R)
+			ret =3D 1;
+		else
+			ret =3D 0;
+		; break;
+	case RATR_INX_WIRELESS_N:
+	case RATR_INX_WIRELESS_NG:
+		if (rtlphy->rf_type =3D=3D RF_1T1R)
+			ret =3D 5;
+		else
+			ret =3D 4;
+		; break;
+	case RATR_INX_WIRELESS_NB:
+		if (rtlphy->rf_type =3D=3D RF_1T1R)
+			ret =3D 3;
+		else
+			ret =3D 2;
+		; break;
+	case RATR_INX_WIRELESS_GB:
+		ret =3D 6;
+		break;
+	case RATR_INX_WIRELESS_G:
+		ret =3D 7;
+		break;
+	case RATR_INX_WIRELESS_B:
+		ret =3D 8;
+		break;
+	case RATR_INX_WIRELESS_MC:
+		if ((wirelessmode =3D=3D WIRELESS_MODE_B)
+			|| (wirelessmode =3D=3D WIRELESS_MODE_G)
+			|| (wirelessmode =3D=3D WIRELESS_MODE_N_24G)
+			|| (wirelessmode =3D=3D WIRELESS_MODE_AC_24G))
+			ret =3D 6;
+		else
+			ret =3D 7;
+	case RATR_INX_WIRELESS_AC_5N:
+		if (rtlphy->rf_type =3D=3D RF_1T1R)
+			ret =3D 10;
+		else
+			ret =3D 9;
+		break;
+	case RATR_INX_WIRELESS_AC_24N:
+		if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80) {
+			if (rtlphy->rf_type =3D=3D RF_1T1R)
+				ret =3D 10;
+			else
+				ret =3D 9;
+		} else {
+			if (rtlphy->rf_type =3D=3D RF_1T1R)
+				ret =3D 11;
+			else
+				ret =3D 12;
+		}
+		break;
+	default:
+		ret =3D 0; break;
+	}
+	return ret;
+}
+
+static u32 _rtl8821ae_rate_to_bitmap_2ssvht(__le16 vht_rate)
+{
+	u8 i, j, tmp_rate;
+	u32 rate_bitmap =3D 0;
+
+	for (i =3D j =3D 0; i < 4; i +=3D 2, j +=3D 10) {
+		tmp_rate =3D (le16_to_cpu(vht_rate) >> i) & 3;
+
+		switch (tmp_rate) {
+		case 2:
+			rate_bitmap =3D rate_bitmap | (0x03ff << j);
+			break;
+		case 1:
+			rate_bitmap =3D rate_bitmap | (0x01ff << j);
+			break;
+		case 0:
+			rate_bitmap =3D rate_bitmap | (0x00ff << j);
+			break;
+		default:
+			break;
+		}
+	}
+
+	return rate_bitmap;
+}
+
+static u32 _rtl8821ae_set_ra_vht_ratr_bitmap(struct ieee80211_hw *hw,
+					     enum wireless_mode wirelessmode,
+					     u32 ratr_bitmap)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u32 ret_bitmap =3D ratr_bitmap;
+
+	if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40
+		|| rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80)
+		ret_bitmap =3D ratr_bitmap;
+	else if (wirelessmode =3D=3D WIRELESS_MODE_AC_5G
+		|| wirelessmode =3D=3D WIRELESS_MODE_AC_24G) {
+		if (rtlphy->rf_type =3D=3D RF_1T1R)
+			ret_bitmap =3D ratr_bitmap & (~BIT21);
+		else
+			ret_bitmap =3D ratr_bitmap & (~(BIT31|BIT21));
+	}
+
+	return ret_bitmap;
+}
+
+static u8 _rtl8821ae_get_vht_eni(enum wireless_mode wirelessmode,
+			u32 ratr_bitmap)
+{
+	u8 ret =3D 0;
+	if (wirelessmode < WIRELESS_MODE_N_24G)
+		ret =3D  0;
+	else if (wirelessmode =3D=3D WIRELESS_MODE_AC_24G) {
+		if (ratr_bitmap & 0xfff00000)	/* Mix , 2SS */
+			ret =3D 3;
+		else					/* Mix, 1SS */
+			ret =3D 2;
+	} else if (wirelessmode =3D=3D WIRELESS_MODE_AC_5G) {
+			ret =3D 1;
+	} /* VHT */
+
+	return ret << 4;
+}
+
+static u8 _rtl8821ae_get_ra_ldpc(struct ieee80211_hw *hw,
+			     u8 mac_id, struct rtl_sta_info *sta_entry,
+			     enum wireless_mode wirelessmode)
+{
+	u8 b_ldpc =3D 0;
+	/*not support ldpc, do not open*/
+	return b_ldpc << 2;
+}
+
+static u8 _rtl8821ae_get_ra_rftype(struct ieee80211_hw *hw,
+			  enum wireless_mode wirelessmode,
+			  u32 ratr_bitmap)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 rf_type =3D RF_1T1R;
+
+	if (rtlphy->rf_type =3D=3D RF_1T1R)
+		rf_type =3D RF_1T1R;
+	else if (wirelessmode =3D=3D WIRELESS_MODE_AC_5G
+		|| wirelessmode =3D=3D WIRELESS_MODE_AC_24G
+		|| wirelessmode =3D=3D WIRELESS_MODE_AC_ONLY) {
+		if (ratr_bitmap & 0xffc00000)
+			rf_type =3D RF_2T2R;
+	} else if (wirelessmode =3D=3D WIRELESS_MODE_N_5G
+		|| wirelessmode =3D=3D WIRELESS_MODE_N_24G) {
+		if (ratr_bitmap & 0xfff00000)
+			rf_type =3D RF_2T2R;
+	}
+
+	return rf_type;
+}
+
+static bool _rtl8821ae_get_ra_shortgi(struct ieee80211_hw *hw, struct =
ieee80211_sta *sta,
+			      u8 mac_id)
+{
+	bool b_short_gi =3D false;
+	u8 b_curshortgi_40mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40)=
 ?
+				1 : 0;
+	u8 b_curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20)=
 ?
+				1 : 0;
+	u8 b_curshortgi_80mhz =3D 0;
+	b_curshortgi_80mhz =3D (sta->vht_cap.cap &
+			      IEEE80211_VHT_CAP_SHORT_GI_80) ? 1 : 0;
+
+	if (mac_id =3D=3D MAC_ID_STATIC_FOR_BROADCAST_MULTICAST)
+			b_short_gi =3D false;
+
+	if (b_curshortgi_40mhz || b_curshortgi_80mhz
+		|| b_curshortgi_20mhz)
+		b_short_gi =3D true;
+
+	return b_short_gi;
+}
+
+static void rtl8821ae_update_hal_rate_mask(struct ieee80211_hw *hw,
+		struct ieee80211_sta *sta, u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_sta_info *sta_entry =3D NULL;
+	u32 ratr_bitmap;
+	u8 ratr_index;
+	enum wireless_mode wirelessmode =3D 0;
+	u8 curtxbw_40mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20=
_40)
+				? 1 : 0;
+	bool b_shortgi =3D false;
+	u8 rate_mask[7];
+	u8 macid =3D 0;
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+	u8 rf_type;
+
+	sta_entry =3D (struct rtl_sta_info *)sta->drv_priv;
+	wirelessmode =3D sta_entry->wireless_mode;
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_LOUD,
+		 "wireless mode =3D 0x%x\n", wirelessmode);
+	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION ||
+		mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
+		curtxbw_40mhz =3D mac->bw_40;
+	} else if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+		mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		macid =3D sta->aid + 1;
+	if (wirelessmode =3D=3D WIRELESS_MODE_N_5G ||
+	    wirelessmode =3D=3D WIRELESS_MODE_AC_5G)
+		ratr_bitmap =3D sta->supp_rates[NL80211_BAND_5GHZ];
+	else
+		ratr_bitmap =3D sta->supp_rates[NL80211_BAND_2GHZ];
+
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_bitmap =3D 0xfff;
+
+	if (wirelessmode =3D=3D WIRELESS_MODE_N_24G
+		|| wirelessmode =3D=3D WIRELESS_MODE_N_5G)
+		ratr_bitmap |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+				sta->ht_cap.mcs.rx_mask[0] << 12);
+	else if (wirelessmode =3D=3D WIRELESS_MODE_AC_24G
+		|| wirelessmode =3D=3D WIRELESS_MODE_AC_5G
+		|| wirelessmode =3D=3D WIRELESS_MODE_AC_ONLY)
+		ratr_bitmap |=3D _rtl8821ae_rate_to_bitmap_2ssvht(
+				sta->vht_cap.vht_mcs.rx_mcs_map) << 12;
+
+	b_shortgi =3D _rtl8821ae_get_ra_shortgi(hw, sta, macid);
+	rf_type =3D _rtl8821ae_get_ra_rftype(hw, wirelessmode, ratr_bitmap);
+
+/*mac id owner*/
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		ratr_index =3D RATR_INX_WIRELESS_B;
+		if (ratr_bitmap & 0x0000000c)
+			ratr_bitmap &=3D 0x0000000d;
+		else
+			ratr_bitmap &=3D 0x0000000f;
+		break;
+	case WIRELESS_MODE_G:
+		ratr_index =3D RATR_INX_WIRELESS_GB;
+
+		if (rssi_level =3D=3D 1)
+			ratr_bitmap &=3D 0x00000f00;
+		else if (rssi_level =3D=3D 2)
+			ratr_bitmap &=3D 0x00000ff0;
+		else
+			ratr_bitmap &=3D 0x00000ff5;
+		break;
+	case WIRELESS_MODE_A:
+		ratr_index =3D RATR_INX_WIRELESS_G;
+		ratr_bitmap &=3D 0x00000ff0;
+		break;
+	case WIRELESS_MODE_N_24G:
+	case WIRELESS_MODE_N_5G:
+		if (wirelessmode =3D=3D WIRELESS_MODE_N_24G)
+			ratr_index =3D RATR_INX_WIRELESS_NGB;
+		else
+			ratr_index =3D RATR_INX_WIRELESS_NG;
+
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC
+			|| mimo_ps =3D=3D IEEE80211_SMPS_DYNAMIC) {
+			if (rssi_level =3D=3D 1)
+				ratr_bitmap &=3D 0x000f0000;
+			else if (rssi_level =3D=3D 2)
+				ratr_bitmap &=3D 0x000ff000;
+			else
+				ratr_bitmap &=3D 0x000ff005;
+		} else {
+			if (rf_type =3D=3D RF_1T1R) {
+				if (curtxbw_40mhz) {
+					if (rssi_level =3D=3D 1)
+						ratr_bitmap &=3D 0x000f0000;
+					else if (rssi_level =3D=3D 2)
+						ratr_bitmap &=3D 0x000ff000;
+					else
+						ratr_bitmap &=3D 0x000ff015;
+				} else {
+					if (rssi_level =3D=3D 1)
+						ratr_bitmap &=3D 0x000f0000;
+					else if (rssi_level =3D=3D 2)
+						ratr_bitmap &=3D 0x000ff000;
+					else
+						ratr_bitmap &=3D 0x000ff005;
+				}
+			} else {
+				if (curtxbw_40mhz) {
+					if (rssi_level =3D=3D 1)
+						ratr_bitmap &=3D 0x0fff0000;
+					else if (rssi_level =3D=3D 2)
+						ratr_bitmap &=3D 0x0ffff000;
+					else
+						ratr_bitmap &=3D 0x0ffff015;
+				} else {
+					if (rssi_level =3D=3D 1)
+						ratr_bitmap &=3D 0x0fff0000;
+					else if (rssi_level =3D=3D 2)
+						ratr_bitmap &=3D 0x0ffff000;
+					else
+						ratr_bitmap &=3D 0x0ffff005;
+				}
+			}
+		}
+		break;
+
+	case WIRELESS_MODE_AC_24G:
+		ratr_index =3D RATR_INX_WIRELESS_AC_24N;
+		if (rssi_level =3D=3D 1)
+			ratr_bitmap &=3D 0xfc3f0000;
+		else if (rssi_level =3D=3D 2)
+			ratr_bitmap &=3D 0xfffff000;
+		else
+			ratr_bitmap &=3D 0xffffffff;
+		break;
+
+	case WIRELESS_MODE_AC_5G:
+		ratr_index =3D RATR_INX_WIRELESS_AC_5N;
+
+		if (rf_type =3D=3D RF_1T1R) {
+			if (rssi_level =3D=3D 1)	/*add by Gary for ac-series*/
+				ratr_bitmap &=3D 0x003f8000;
+			else if (rssi_level =3D=3D 2)
+				ratr_bitmap &=3D 0x003ff000;
+			else
+				ratr_bitmap &=3D 0x003ff010;
+		} else {
+			if (rssi_level =3D=3D 1)
+				ratr_bitmap &=3D 0xfe3f8000;
+			else if (rssi_level =3D=3D 2)
+				ratr_bitmap &=3D 0xfffff000;
+			else
+				ratr_bitmap &=3D 0xfffff010;
+		}
+		break;
+
+	default:
+		ratr_index =3D RATR_INX_WIRELESS_NGB;
+
+		if (rf_type =3D=3D RF_1T2R)
+			ratr_bitmap &=3D 0x000ff0ff;
+		else
+			ratr_bitmap &=3D 0x0f8ff0ff;
+		break;
+	}
+
+	ratr_index =3D _rtl8821ae_mrate_idx_to_arfr_id(hw, ratr_index, wirele=
ssmode);
+	sta_entry->ratr_index =3D ratr_index;
+	ratr_bitmap =3D _rtl8821ae_set_ra_vht_ratr_bitmap(hw, wirelessmode,
+							ratr_bitmap);
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_LOUD,
+		 "ratr_bitmap :%x\n", ratr_bitmap);
+
+	/* *(u32 *)& rate_mask =3D EF4BYTE((ratr_bitmap & 0x0fffffff) |
+				       (ratr_index << 28)); */
+
+	rate_mask[0] =3D macid;
+	rate_mask[1] =3D ratr_index | (b_shortgi ? 0x80 : 0x00);
+	rate_mask[2] =3D rtlphy->current_chan_bw
+			   | _rtl8821ae_get_vht_eni(wirelessmode, ratr_bitmap)
+			   | _rtl8821ae_get_ra_ldpc(hw, macid, sta_entry, wirelessmode);
+
+	rate_mask[3] =3D (u8)(ratr_bitmap & 0x000000ff);
+	rate_mask[4] =3D (u8)((ratr_bitmap & 0x0000ff00) >> 8);
+	rate_mask[5] =3D (u8)((ratr_bitmap & 0x00ff0000) >> 16);
+	rate_mask[6] =3D (u8)((ratr_bitmap & 0xff000000) >> 24);
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x:%x:%x\n",
+		 ratr_index, ratr_bitmap,
+		 rate_mask[0], rate_mask[1],
+		 rate_mask[2], rate_mask[3],
+		 rate_mask[4], rate_mask[5],
+		 rate_mask[6]);
+	rtl8821ae_fill_h2c_cmd(hw, H2C_8821AE_RA_MASK, 7, rate_mask);
+	_rtl8821ae_set_bcn_ctrl_reg(hw, BIT(3), 0);
+}
+
+void rtl8821ae_update_hal_rate_tbl(struct ieee80211_hw *hw,
+		struct ieee80211_sta *sta, u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	if (rtlpriv->dm.useramask)
+		rtl8821ae_update_hal_rate_mask(hw, sta, rssi_level);
+	else
+		/*RT_TRACE(rtlpriv, COMP_RATR,DBG_LOUD,
+			   "rtl8821ae_update_hal_rate_tbl() Error! 8821ae FW RA Only");*/
+		rtl8821ae_update_hal_rate_table(hw, sta);
+}
+
+void rtl8821ae_update_channel_access_setting(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	u8 wireless_mode =3D mac->mode;
+	u8 sifs_timer, r2t_sifs;
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
+				      (u8 *)&mac->slot_time);
+	if (wireless_mode =3D=3D WIRELESS_MODE_G)
+		sifs_timer =3D 0x0a;
+	else
+		sifs_timer =3D 0x0e;
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SIFS, (u8 *)&sifs_timer);
+
+	r2t_sifs =3D 0xa;
+
+	if (wireless_mode =3D=3D WIRELESS_MODE_AC_5G &&
+	    (mac->vht_ldpc_cap & LDPC_VHT_ENABLE_RX) &&
+	    (mac->vht_stbc_cap & STBC_VHT_ENABLE_RX)) {
+		if (mac->vendor =3D=3D PEER_ATH)
+			r2t_sifs =3D 0x8;
+		else
+			r2t_sifs =3D 0xa;
+	} else if (wireless_mode =3D=3D WIRELESS_MODE_AC_5G) {
+		r2t_sifs =3D 0xa;
+	}
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_R2T_SIFS, (u8 *)&r2t_sifs);
+}
+
+bool rtl8821ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 =
*valid)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	enum rf_pwrstate e_rfpowerstate_toset, cur_rfstate;
+	u8 u1tmp =3D 0;
+	bool b_actuallyset =3D false;
+
+	if (rtlpriv->rtlhal.being_init_adapter)
+		return false;
+
+	if (ppsc->swrf_processing)
+		return false;
+
+	spin_lock(&rtlpriv->locks.rf_ps_lock);
+	if (ppsc->rfchange_inprogress) {
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+		return false;
+	} else {
+		ppsc->rfchange_inprogress =3D true;
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+	}
+
+	cur_rfstate =3D ppsc->rfpwr_state;
+
+	rtl_write_byte(rtlpriv, REG_GPIO_IO_SEL_2,
+			rtl_read_byte(rtlpriv,
+					REG_GPIO_IO_SEL_2) & ~(BIT(1)));
+
+	u1tmp =3D rtl_read_byte(rtlpriv, REG_GPIO_PIN_CTRL_2);
+
+	if (rtlphy->polarity_ctl)
+		e_rfpowerstate_toset =3D (u1tmp & BIT(1)) ? ERFOFF : ERFON;
+	else
+		e_rfpowerstate_toset =3D (u1tmp & BIT(1)) ? ERFON : ERFOFF;
+
+	if ((ppsc->hwradiooff) && (e_rfpowerstate_toset =3D=3D ERFON)) {
+		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
+
+		e_rfpowerstate_toset =3D ERFON;
+		ppsc->hwradiooff =3D false;
+		b_actuallyset =3D true;
+	} else if ((!ppsc->hwradiooff)
+		   && (e_rfpowerstate_toset =3D=3D ERFOFF)) {
+		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
+
+		e_rfpowerstate_toset =3D ERFOFF;
+		ppsc->hwradiooff =3D true;
+		b_actuallyset =3D true;
+	}
+
+	if (b_actuallyset) {
+		spin_lock(&rtlpriv->locks.rf_ps_lock);
+		ppsc->rfchange_inprogress =3D false;
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+	} else {
+		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC)
+			RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+
+		spin_lock(&rtlpriv->locks.rf_ps_lock);
+		ppsc->rfchange_inprogress =3D false;
+		spin_unlock(&rtlpriv->locks.rf_ps_lock);
+	}
+
+	*valid =3D 1;
+	return !ppsc->hwradiooff;
+}
+
+void rtl8821ae_set_key(struct ieee80211_hw *hw, u32 key_index,
+		     u8 *p_macaddr, bool is_group, u8 enc_algo,
+		     bool is_wepkey, bool clear_all)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	u8 *macaddr =3D p_macaddr;
+	u32 entry_id =3D 0;
+	bool is_pairwise =3D false;
+
+	static u8 cam_const_addr[4][6] =3D {
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x01},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x02},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x03}
+	};
+	static u8 cam_const_broad[] =3D {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+
+	if (clear_all) {
+		u8 idx =3D 0;
+		u8 cam_offset =3D 0;
+		u8 clear_number =3D 5;
+
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "clear_all\n");
+
+		for (idx =3D 0; idx < clear_number; idx++) {
+			rtl_cam_mark_invalid(hw, cam_offset + idx);
+			rtl_cam_empty_entry(hw, cam_offset + idx);
+
+			if (idx < 5) {
+				memset(rtlpriv->sec.key_buf[idx], 0,
+				       MAX_KEY_LEN);
+				rtlpriv->sec.key_len[idx] =3D 0;
+			}
+		}
+	} else {
+		switch (enc_algo) {
+		case WEP40_ENCRYPTION:
+			enc_algo =3D CAM_WEP40;
+			break;
+		case WEP104_ENCRYPTION:
+			enc_algo =3D CAM_WEP104;
+			break;
+		case TKIP_ENCRYPTION:
+			enc_algo =3D CAM_TKIP;
+			break;
+		case AESCCMP_ENCRYPTION:
+			enc_algo =3D CAM_AES;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+				 "switch case not process\n");
+			enc_algo =3D CAM_TKIP;
+			break;
+		}
+
+		if (is_wepkey || rtlpriv->sec.use_defaultkey) {
+			macaddr =3D cam_const_addr[key_index];
+			entry_id =3D key_index;
+		} else {
+			if (is_group) {
+				macaddr =3D cam_const_broad;
+				entry_id =3D key_index;
+			} else {
+				if (mac->opmode =3D=3D NL80211_IFTYPE_AP) {
+					entry_id =3D rtl_cam_get_free_entry(hw, p_macaddr);
+					if (entry_id >=3D  TOTAL_CAM_ENTRY) {
+						RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
+							 "Can not find free hwsecurity cam entry\n");
+						return;
+					}
+				} else {
+					entry_id =3D CAM_PAIRWISE_KEY_POSITION;
+				}
+
+				key_index =3D PAIRWISE_KEYIDX;
+				is_pairwise =3D true;
+			}
+		}
+
+		if (rtlpriv->sec.key_len[key_index] =3D=3D 0) {
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+				 "delete one entry, entry_id is %d\n",
+				 entry_id);
+			if (mac->opmode =3D=3D NL80211_IFTYPE_AP)
+				rtl_cam_del_entry(hw, p_macaddr);
+			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
+		} else {
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+				 "add one entry\n");
+			if (is_pairwise) {
+				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+					 "set Pairwise key\n");
+
+				rtl_cam_add_one_entry(hw, macaddr, key_index,
+						      entry_id, enc_algo,
+						      CAM_CONFIG_NO_USEDK,
+						      rtlpriv->sec.key_buf[key_index]);
+			} else {
+				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+					 "set group key\n");
+
+				if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC) {
+					rtl_cam_add_one_entry(hw,
+							rtlefuse->dev_addr,
+							PAIRWISE_KEYIDX,
+							CAM_PAIRWISE_KEY_POSITION,
+							enc_algo,
+							CAM_CONFIG_NO_USEDK,
+							rtlpriv->sec.key_buf
+							[entry_id]);
+				}
+
+				rtl_cam_add_one_entry(hw, macaddr, key_index,
+						entry_id, enc_algo,
+						CAM_CONFIG_NO_USEDK,
+						rtlpriv->sec.key_buf[entry_id]);
+			}
+		}
+	}
+}
+
+void rtl8821ae_bt_reg_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	/* 0:Low, 1:High, 2:From Efuse. */
+	rtlpriv->btcoexist.reg_bt_iso =3D 2;
+	/* 0:Idle, 1:None-SCO, 2:SCO, 3:From Counter. */
+	rtlpriv->btcoexist.reg_bt_sco =3D 3;
+	/* 0:Disable BT control A-MPDU, 1:Enable BT control A-MPDU. */
+	rtlpriv->btcoexist.reg_bt_sco =3D 0;
+}
+
+void rtl8821ae_bt_hw_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (rtlpriv->cfg->ops->get_btc_status())
+		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+}
+
+void rtl8821ae_suspend(struct ieee80211_hw *hw)
+{
+}
+
+void rtl8821ae_resume(struct ieee80211_hw *hw)
+{
+}
+
+/* Turn on AAP (RCR:bit 0) for promicuous mode. */
+void rtl8821ae_allow_all_destaddr(struct ieee80211_hw *hw,
+	bool allow_all_da, bool write_into_reg)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	if (allow_all_da) /* Set BIT0 */
+		rtlpci->receive_config |=3D RCR_AAP;
+	else /* Clear BIT0 */
+		rtlpci->receive_config &=3D ~RCR_AAP;
+
+	if (write_into_reg)
+		rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
+
+	RT_TRACE(rtlpriv, COMP_TURBO | COMP_INIT, DBG_LOUD,
+		"receive_config=3D0x%08X, write_into_reg=3D%d\n",
+		rtlpci->receive_config, write_into_reg);
+}
+
+/* WKFMCAMAddAllEntry8812 */
+void rtl8821ae_add_wowlan_pattern(struct ieee80211_hw *hw,
+				  struct rtl_wow_pattern *rtl_pattern,
+				  u8 index)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 cam =3D 0;
+	u8 addr =3D 0;
+	u16 rxbuf_addr;
+	u8 tmp, count =3D 0;
+	u16 cam_start;
+	u16 offset;
+
+	/* Count the WFCAM entry start offset. */
+
+	/* RX page size =3D 128 byte */
+	offset =3D MAX_RX_DMA_BUFFER_SIZE_8812 / 128;
+	/* We should start from the boundry */
+	cam_start =3D offset * 128;
+
+	/* Enable Rx packet buffer access. */
+	rtl_write_byte(rtlpriv, REG_PKT_BUFF_ACCESS_CTRL, RXPKT_BUF_SELECT);
+	for (addr =3D 0; addr < WKFMCAM_ADDR_NUM; addr++) {
+		/* Set Rx packet buffer offset.
+		 * RxBufer pointer increases 1,
+		 * we can access 8 bytes in Rx packet buffer.
+		 * CAM start offset (unit: 1 byte) =3D  index*WKFMCAM_SIZE
+		 * RxBufer addr =3D (CAM start offset +
+		 *                 per entry offset of a WKFM CAM)/8
+		 *	* index: The index of the wake up frame mask
+		 *	* WKFMCAM_SIZE: the total size of one WKFM CAM
+		 *	* per entry offset of a WKFM CAM: Addr*4 bytes
+		 */
+		rxbuf_addr =3D (cam_start + index * WKFMCAM_SIZE + addr * 4) >> 3;
+		/* Set R/W start offset */
+		rtl_write_word(rtlpriv, REG_PKTBUF_DBG_CTRL, rxbuf_addr);
+
+		if (addr =3D=3D 0) {
+			cam =3D BIT(31) | rtl_pattern->crc;
+
+			if (rtl_pattern->type =3D=3D UNICAST_PATTERN)
+				cam |=3D BIT(24);
+			else if (rtl_pattern->type =3D=3D MULTICAST_PATTERN)
+				cam |=3D BIT(25);
+			else if (rtl_pattern->type =3D=3D BROADCAST_PATTERN)
+				cam |=3D BIT(26);
+
+			rtl_write_dword(rtlpriv, REG_PKTBUF_DBG_DATA_L, cam);
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+				 "WRITE entry[%d] 0x%x: %x\n", addr,
+				  REG_PKTBUF_DBG_DATA_L, cam);
+
+			/* Write to Rx packet buffer. */
+			rtl_write_word(rtlpriv, REG_RXPKTBUF_CTRL, 0x0f01);
+		} else if (addr =3D=3D 2 || addr =3D=3D 4) {/* WKFM[127:0] */
+			cam =3D rtl_pattern->mask[addr - 2];
+
+			rtl_write_dword(rtlpriv, REG_PKTBUF_DBG_DATA_L, cam);
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+				 "WRITE entry[%d] 0x%x: %x\n", addr,
+				  REG_PKTBUF_DBG_DATA_L, cam);
+
+			rtl_write_word(rtlpriv, REG_RXPKTBUF_CTRL, 0x0f01);
+		} else if (addr =3D=3D 3 || addr =3D=3D 5) {/* WKFM[127:0] */
+			cam =3D rtl_pattern->mask[addr - 2];
+
+			rtl_write_dword(rtlpriv, REG_PKTBUF_DBG_DATA_H, cam);
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+				 "WRITE entry[%d] 0x%x: %x\n", addr,
+				  REG_PKTBUF_DBG_DATA_H, cam);
+
+			rtl_write_word(rtlpriv, REG_RXPKTBUF_CTRL, 0xf001);
+		}
+
+		count =3D 0;
+		do {
+			tmp =3D rtl_read_byte(rtlpriv, REG_RXPKTBUF_CTRL);
+			udelay(2);
+			count++;
+		} while (tmp && count < 100);
+
+		RT_ASSERT((count < 100),
+			  "Write wake up frame mask FAIL %d value!\n", tmp);
+	}
+	/* Disable Rx packet buffer access. */
+	rtl_write_byte(rtlpriv, REG_PKT_BUFF_ACCESS_CTRL,
+		       DISABLE_TRXPKT_BUF_ACCESS);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.h b/drivers/net/=
wireless/rtlwifi/rtl8821ae/hw.h
new file mode 100644
index 0000000..a3553e3
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.h
@@ -0,0 +1,70 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_HW_H__
+#define __RTL8821AE_HW_H__
+
+void rtl8821ae_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *va=
l);
+void rtl8821ae_read_eeprom_info(struct ieee80211_hw *hw);
+
+void rtl8821ae_interrupt_recognized(struct ieee80211_hw *hw,
+				    u32 *p_inta, u32 *p_intb);
+int rtl8821ae_hw_init(struct ieee80211_hw *hw);
+void rtl8821ae_card_disable(struct ieee80211_hw *hw);
+void rtl8821ae_enable_interrupt(struct ieee80211_hw *hw);
+void rtl8821ae_disable_interrupt(struct ieee80211_hw *hw);
+int rtl8821ae_set_network_type(struct ieee80211_hw *hw,
+			       enum nl80211_iftype type);
+void rtl8821ae_set_check_bssid(struct ieee80211_hw *hw, bool check_bss=
id);
+void rtl8821ae_set_qos(struct ieee80211_hw *hw, int aci);
+void rtl8821ae_set_beacon_related_registers(struct ieee80211_hw *hw);
+void rtl8821ae_set_beacon_interval(struct ieee80211_hw *hw);
+void rtl8821ae_update_interrupt_mask(struct ieee80211_hw *hw,
+				     u32 add_msr, u32 rm_msr);
+void rtl8821ae_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *va=
l);
+void rtl8821ae_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				   struct ieee80211_sta *sta,
+				   u8 rssi_level);
+void rtl8821ae_update_channel_access_setting(struct ieee80211_hw *hw);
+bool rtl8821ae_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 =
*valid);
+void rtl8821ae_enable_hw_security_config(struct ieee80211_hw *hw);
+void rtl8821ae_set_key(struct ieee80211_hw *hw, u32 key_index,
+		       u8 *p_macaddr, bool is_group, u8 enc_algo,
+		       bool is_wepkey, bool clear_all);
+
+void rtl8821ae_bt_reg_init(struct ieee80211_hw *hw);
+void rtl8821ae_bt_hw_init(struct ieee80211_hw *hw);
+void rtl8821ae_suspend(struct ieee80211_hw *hw);
+void rtl8821ae_resume(struct ieee80211_hw *hw);
+void rtl8821ae_allow_all_destaddr(struct ieee80211_hw *hw,
+				  bool allow_all_da,
+				  bool write_into_reg);
+void _rtl8821ae_stop_tx_beacon(struct ieee80211_hw *hw);
+void _rtl8821ae_resume_tx_beacon(struct ieee80211_hw *hw);
+void rtl8821ae_add_wowlan_pattern(struct ieee80211_hw *hw,
+				  struct rtl_wow_pattern *rtl_pattern,
+				  u8 index);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/led.c b/drivers/net=
/wireless/rtlwifi/rtl8821ae/led.c
new file mode 100644
index 0000000..ba1946a
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/led.c
@@ -0,0 +1,237 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "reg.h"
+#include "led.h"
+
+static void _rtl8821ae_init_led(struct ieee80211_hw *hw,
+				struct rtl_led *pled,
+				enum rtl_led_pin ledpin)
+{
+	pled->hw =3D hw;
+	pled->ledpin =3D ledpin;
+	pled->ledon =3D false;
+}
+
+void rtl8821ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled=
)
+{
+	u8 ledcfg;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin=3D%d\n", REG_LEDCFG2, pled->ledpin);
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg =3D rtl_read_byte(rtlpriv, REG_LEDCFG2);
+		ledcfg &=3D ~BIT(6);
+		rtl_write_byte(rtlpriv,
+			       REG_LEDCFG2, (ledcfg & 0xf0) | BIT(5));
+		break;
+	case LED_PIN_LED1:
+		ledcfg =3D rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg & 0x10);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
+		break;
+	}
+	pled->ledon =3D true;
+}
+
+void rtl8812ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled=
)
+{
+	u16	ledreg =3D REG_LEDCFG1;
+	u8	ledcfg =3D 0;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	switch (pled->ledpin) {
+	case LED_PIN_LED0:
+		ledreg =3D REG_LEDCFG1;
+		break;
+
+	case LED_PIN_LED1:
+		ledreg =3D REG_LEDCFG2;
+		break;
+
+	case LED_PIN_GPIO0:
+	default:
+		break;
+	}
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "In SwLedOn, LedAddr:%X LEDPIN=3D%d\n",
+		 ledreg, pled->ledpin);
+
+	ledcfg =3D  rtl_read_byte(rtlpriv, ledreg);
+	ledcfg |=3D BIT(5); /*Set 0x4c[21]*/
+	ledcfg &=3D ~(BIT(7) | BIT(6) | BIT(3) | BIT(2) | BIT(1) | BIT(0));
+		/*Clear 0x4c[23:22] and 0x4c[19:16]*/
+	rtl_write_byte(rtlpriv, ledreg, ledcfg); /*SW control led0 on.*/
+	pled->ledon =3D true;
+}
+
+void rtl8821ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *ple=
d)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	u8 ledcfg;
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "LedAddr:%X ledpin=3D%d\n", REG_LEDCFG2, pled->ledpin);
+
+	ledcfg =3D rtl_read_byte(rtlpriv, REG_LEDCFG2);
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg &=3D 0xf0;
+		if (pcipriv->ledctl.led_opendrain) {
+			ledcfg &=3D 0x90; /* Set to software control. */
+			rtl_write_byte(rtlpriv, REG_LEDCFG2, (ledcfg|BIT(3)));
+			ledcfg =3D rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
+			ledcfg &=3D 0xFE;
+			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG, ledcfg);
+		} else {
+			ledcfg &=3D ~BIT(6);
+			rtl_write_byte(rtlpriv, REG_LEDCFG2,
+				       (ledcfg | BIT(3) | BIT(5)));
+		}
+		break;
+	case LED_PIN_LED1:
+		ledcfg =3D rtl_read_byte(rtlpriv, REG_LEDCFG1);
+		ledcfg &=3D 0x10; /* Set to software control. */
+		rtl_write_byte(rtlpriv, REG_LEDCFG1, ledcfg|BIT(3));
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
+			 "switch case not process\n");
+		break;
+	}
+	pled->ledon =3D false;
+}
+
+void rtl8812ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *ple=
d)
+{
+	u16 ledreg =3D REG_LEDCFG1;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+
+	switch (pled->ledpin) {
+	case LED_PIN_LED0:
+		ledreg =3D REG_LEDCFG1;
+		break;
+
+	case LED_PIN_LED1:
+		ledreg =3D REG_LEDCFG2;
+		break;
+
+	case LED_PIN_GPIO0:
+	default:
+		break;
+	}
+
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
+		 "In SwLedOff,LedAddr:%X LEDPIN=3D%d\n",
+		 ledreg, pled->ledpin);
+	/*Open-drain arrangement for controlling the LED*/
+	if (pcipriv->ledctl.led_opendrain) {
+		u8 ledcfg =3D rtl_read_byte(rtlpriv, ledreg);
+
+		ledreg &=3D 0xd0; /* Set to software control.*/
+		rtl_write_byte(rtlpriv, ledreg, (ledcfg | BIT(3)));
+
+		/*Open-drain arrangement*/
+		ledcfg =3D rtl_read_byte(rtlpriv, REG_MAC_PINMUX_CFG);
+		ledcfg &=3D 0xFE;/*Set GPIO[8] to input mode*/
+		rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG, ledcfg);
+	} else {
+		rtl_write_byte(rtlpriv, ledreg, 0x28);
+	}
+
+	pled->ledon =3D false;
+}
+
+void rtl8821ae_init_sw_leds(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+
+	_rtl8821ae_init_led(hw, &pcipriv->ledctl.sw_led0, LED_PIN_LED0);
+	_rtl8821ae_init_led(hw, &pcipriv->ledctl.sw_led1, LED_PIN_LED1);
+}
+
+static void _rtl8821ae_sw_led_control(struct ieee80211_hw *hw,
+				      enum led_ctl_mode ledaction)
+{
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	struct rtl_led *pLed0 =3D &pcipriv->ledctl.sw_led0;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	switch (ledaction) {
+	case LED_CTL_POWER_ON:
+	case LED_CTL_LINK:
+	case LED_CTL_NO_LINK:
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_sw_led_on(hw, pLed0);
+		else
+			rtl8821ae_sw_led_on(hw, pLed0);
+		break;
+	case LED_CTL_POWER_OFF:
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+			rtl8812ae_sw_led_off(hw, pLed0);
+		else
+			rtl8821ae_sw_led_off(hw, pLed0);
+		break;
+	default:
+		break;
+	}
+}
+
+void rtl8821ae_led_control(struct ieee80211_hw *hw,
+			   enum led_ctl_mode ledaction)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+
+	if ((ppsc->rfoff_reason > RF_CHANGE_BY_PS) &&
+	    (ledaction =3D=3D LED_CTL_TX ||
+	     ledaction =3D=3D LED_CTL_RX ||
+	     ledaction =3D=3D LED_CTL_SITE_SURVEY ||
+	     ledaction =3D=3D LED_CTL_LINK ||
+	     ledaction =3D=3D LED_CTL_NO_LINK ||
+	     ledaction =3D=3D LED_CTL_START_TO_LINK ||
+	     ledaction =3D=3D LED_CTL_POWER_ON)) {
+		return;
+	}
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d,\n",
+		 ledaction);
+	_rtl8821ae_sw_led_control(hw, ledaction);
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/led.h b/drivers/net=
/wireless/rtlwifi/rtl8821ae/led.h
new file mode 100644
index 0000000..038e64e
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/led.h
@@ -0,0 +1,37 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_LED_H__
+#define __RTL8821AE_LED_H__
+
+void rtl8821ae_init_sw_leds(struct ieee80211_hw *hw);
+void rtl8821ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled=
);
+void rtl8812ae_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled=
);
+void rtl8821ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *ple=
d);
+void rtl8812ae_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *ple=
d);
+void rtl8821ae_led_control(struct ieee80211_hw *hw,
+			   enum led_ctl_mode ledaction);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c b/drivers/net=
/wireless/rtlwifi/rtl8821ae/phy.c
new file mode 100644
index 0000000..9786313
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.c
@@ -0,0 +1,4855 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "../ps.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "rf.h"
+#include "dm.h"
+#include "table.h"
+#include "trx.h"
+#include "../btcoexist/halbt_precomp.h"
+#include "hw.h"
+#include "../efuse.h"
+
+#define READ_NEXT_PAIR(array_table, v1, v2, i) \
+	do { \
+		i +=3D 2; \
+		v1 =3D array_table[i]; \
+		v2 =3D array_table[i+1]; \
+	} while (0)
+
+static u32 _rtl8821ae_phy_rf_serial_read(struct ieee80211_hw *hw,
+					 enum radio_path rfpath, u32 offset);
+static void _rtl8821ae_phy_rf_serial_write(struct ieee80211_hw *hw,
+					   enum radio_path rfpath, u32 offset,
+					   u32 data);
+static u32 _rtl8821ae_phy_calculate_bit_shift(u32 bitmask);
+static bool _rtl8821ae_phy_bb8821a_config_parafile(struct ieee80211_hw=
 *hw);
+/*static bool _rtl8812ae_phy_config_mac_with_headerfile(struct ieee802=
11_hw *hw);*/
+static bool _rtl8821ae_phy_config_mac_with_headerfile(struct ieee80211=
_hw *hw);
+static bool _rtl8821ae_phy_config_bb_with_headerfile(struct ieee80211_=
hw *hw,
+						     u8 configtype);
+static bool _rtl8821ae_phy_config_bb_with_pgheaderfile(struct ieee8021=
1_hw *hw,
+						       u8 configtype);
+static void phy_init_bb_rf_register_definition(struct ieee80211_hw *hw=
);
+
+static long _rtl8821ae_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					    enum wireless_mode wirelessmode,
+					    u8 txpwridx);
+static void rtl8821ae_phy_set_rf_on(struct ieee80211_hw *hw);
+static void rtl8821ae_phy_set_io(struct ieee80211_hw *hw);
+
+static void rtl8812ae_fixspur(struct ieee80211_hw *hw,
+			      enum ht_channel_width band_width, u8 channel)
+{
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	/*C cut Item12 ADC FIFO CLOCK*/
+	if (IS_VENDOR_8812A_C_CUT(rtlhal->version)) {
+		if (band_width =3D=3D HT_CHANNEL_WIDTH_20_40 && channel =3D=3D 11)
+			rtl_set_bbreg(hw, RRFMOD, 0xC00, 0x3);
+			/* 0x8AC[11:10] =3D 2'b11*/
+		else
+			rtl_set_bbreg(hw, RRFMOD, 0xC00, 0x2);
+			/* 0x8AC[11:10] =3D 2'b10*/
+
+		/* <20120914, Kordan> A workarould to resolve
+		 * 2480Mhz spur by setting ADC clock as 160M. (Asked by Binson)
+		 */
+		if (band_width =3D=3D HT_CHANNEL_WIDTH_20 &&
+		    (channel =3D=3D 13 || channel =3D=3D 14)) {
+			rtl_set_bbreg(hw, RRFMOD, 0x300, 0x3);
+			/*0x8AC[9:8] =3D 2'b11*/
+			rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 1);
+			/* 0x8C4[30] =3D 1*/
+		} else if (band_width =3D=3D HT_CHANNEL_WIDTH_20_40 &&
+			   channel =3D=3D 11) {
+			rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 1);
+			/*0x8C4[30] =3D 1*/
+		} else if (band_width !=3D HT_CHANNEL_WIDTH_80) {
+			rtl_set_bbreg(hw, RRFMOD, 0x300, 0x2);
+			/*0x8AC[9:8] =3D 2'b10*/
+			rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 0);
+			/*0x8C4[30] =3D 0*/
+		}
+	} else if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		/* <20120914, Kordan> A workarould to resolve
+		 * 2480Mhz spur by setting ADC clock as 160M.
+		 */
+		if (band_width =3D=3D HT_CHANNEL_WIDTH_20 &&
+		    (channel =3D=3D 13 || channel =3D=3D 14))
+			rtl_set_bbreg(hw, RRFMOD, 0x300, 0x3);
+			/*0x8AC[9:8] =3D 11*/
+		else if (channel  <=3D 14) /*2.4G only*/
+			rtl_set_bbreg(hw, RRFMOD, 0x300, 0x2);
+			/*0x8AC[9:8] =3D 10*/
+	}
+}
+
+u32 rtl8821ae_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
+			       u32 bitmask)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 returnvalue, originalvalue, bitshift;
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x)\n",
+		 regaddr, bitmask);
+	originalvalue =3D rtl_read_dword(rtlpriv, regaddr);
+	bitshift =3D _rtl8821ae_phy_calculate_bit_shift(bitmask);
+	returnvalue =3D (originalvalue & bitmask) >> bitshift;
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "BBR MASK=3D0x%x Addr[0x%x]=3D0x%x\n",
+		 bitmask, regaddr, originalvalue);
+	return returnvalue;
+}
+
+void rtl8821ae_phy_set_bb_reg(struct ieee80211_hw *hw,
+			      u32 regaddr, u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 originalvalue, bitshift;
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
+
+	if (bitmask !=3D MASKDWORD) {
+		originalvalue =3D rtl_read_dword(rtlpriv, regaddr);
+		bitshift =3D _rtl8821ae_phy_calculate_bit_shift(bitmask);
+		data =3D ((originalvalue & (~bitmask)) |
+			((data << bitshift) & bitmask));
+	}
+
+	rtl_write_dword(rtlpriv, regaddr, data);
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
+}
+
+u32 rtl8821ae_phy_query_rf_reg(struct ieee80211_hw *hw,
+			       enum radio_path rfpath, u32 regaddr,
+			       u32 bitmask)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 original_value, readback_value, bitshift;
+	unsigned long flags;
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		 regaddr, rfpath, bitmask);
+
+	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
+
+	original_value =3D _rtl8821ae_phy_rf_serial_read(hw, rfpath, regaddr)=
;
+	bitshift =3D _rtl8821ae_phy_calculate_bit_shift(bitmask);
+	readback_value =3D (original_value & bitmask) >> bitshift;
+
+	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
+
+	return readback_value;
+}
+
+void rtl8821ae_phy_set_rf_reg(struct ieee80211_hw *hw,
+			   enum radio_path rfpath,
+			   u32 regaddr, u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 original_value, bitshift;
+	unsigned long flags;
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		  regaddr, bitmask, data, rfpath);
+
+	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
+
+	if (bitmask !=3D RFREG_OFFSET_MASK) {
+		original_value =3D
+		   _rtl8821ae_phy_rf_serial_read(hw, rfpath, regaddr);
+		bitshift =3D _rtl8821ae_phy_calculate_bit_shift(bitmask);
+		data =3D ((original_value & (~bitmask)) | (data << bitshift));
+	}
+
+	_rtl8821ae_phy_rf_serial_write(hw, rfpath, regaddr, data);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
+
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
+}
+
+static u32 _rtl8821ae_phy_rf_serial_read(struct ieee80211_hw *hw,
+					 enum radio_path rfpath, u32 offset)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	bool is_pi_mode =3D false;
+	u32 retvalue =3D 0;
+
+	/* 2009/06/17 MH We can not execute IO for power
+	save or other accident mode.*/
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
+		return 0xFFFFFFFF;
+	}
+	/* <20120809, Kordan> CCA OFF(when entering),
+		asked by James to avoid reading the wrong value.
+	    <20120828, Kordan> Toggling CCA would affect RF 0x0, skip it!*/
+	if (offset !=3D 0x0 &&
+	    !((rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) ||
+	    (IS_VENDOR_8812A_C_CUT(rtlhal->version))))
+		rtl_set_bbreg(hw, RCCAONSEC, 0x8, 1);
+	offset &=3D 0xff;
+
+	if (rfpath =3D=3D RF90_PATH_A)
+		is_pi_mode =3D (bool)rtl_get_bbreg(hw, 0xC00, 0x4);
+	else if (rfpath =3D=3D RF90_PATH_B)
+		is_pi_mode =3D (bool)rtl_get_bbreg(hw, 0xE00, 0x4);
+
+	rtl_set_bbreg(hw, RHSSIREAD_8821AE, 0xff, offset);
+
+	if ((rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) ||
+	    (IS_VENDOR_8812A_C_CUT(rtlhal->version)))
+		udelay(20);
+
+	if (is_pi_mode) {
+		if (rfpath =3D=3D RF90_PATH_A)
+			retvalue =3D
+			  rtl_get_bbreg(hw, RA_PIREAD_8821A, BLSSIREADBACKDATA);
+		else if (rfpath =3D=3D RF90_PATH_B)
+			retvalue =3D
+			  rtl_get_bbreg(hw, RB_PIREAD_8821A, BLSSIREADBACKDATA);
+	} else {
+		if (rfpath =3D=3D RF90_PATH_A)
+			retvalue =3D
+			  rtl_get_bbreg(hw, RA_SIREAD_8821A, BLSSIREADBACKDATA);
+		else if (rfpath =3D=3D RF90_PATH_B)
+			retvalue =3D
+			  rtl_get_bbreg(hw, RB_SIREAD_8821A, BLSSIREADBACKDATA);
+	}
+
+	/*<20120809, Kordan> CCA ON(when exiting),
+	 * asked by James to avoid reading the wrong value.
+	 *   <20120828, Kordan> Toggling CCA would affect RF 0x0, skip it!
+	 */
+	if (offset !=3D 0x0 &&
+	    !((rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) ||
+	    (IS_VENDOR_8812A_C_CUT(rtlhal->version))))
+		rtl_set_bbreg(hw, RCCAONSEC, 0x8, 0);
+	return retvalue;
+}
+
+static void _rtl8821ae_phy_rf_serial_write(struct ieee80211_hw *hw,
+					   enum radio_path rfpath, u32 offset,
+					   u32 data)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct bb_reg_def *pphyreg =3D &rtlphy->phyreg_def[rfpath];
+	u32 data_and_addr;
+	u32 newoffset;
+
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
+		return;
+	}
+	offset &=3D 0xff;
+	newoffset =3D offset;
+	data_and_addr =3D ((newoffset << 20) |
+			 (data & 0x000fffff)) & 0x0fffffff;
+	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "RFW-%d Addr[0x%x]=3D0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
+}
+
+static u32 _rtl8821ae_phy_calculate_bit_shift(u32 bitmask)
+{
+	u32 i;
+
+	for (i =3D 0; i <=3D 31; i++) {
+		if (((bitmask >> i) & 0x1) =3D=3D 1)
+			break;
+	}
+	return i;
+}
+
+bool rtl8821ae_phy_mac_config(struct ieee80211_hw *hw)
+{
+	bool rtstatus =3D 0;
+
+	rtstatus =3D _rtl8821ae_phy_config_mac_with_headerfile(hw);
+
+	return rtstatus;
+}
+
+bool rtl8821ae_phy_bb_config(struct ieee80211_hw *hw)
+{
+	bool rtstatus =3D true;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 regval;
+	u8 crystal_cap;
+
+	phy_init_bb_rf_register_definition(hw);
+
+	regval =3D rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN);
+	regval |=3D FEN_PCIEA;
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, regval);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN,
+		       regval | FEN_BB_GLB_RSTN | FEN_BBRSTB);
+
+	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x7);
+	rtl_write_byte(rtlpriv, REG_OPT_CTRL + 2, 0x7);
+
+	rtstatus =3D _rtl8821ae_phy_bb8821a_config_parafile(hw);
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		crystal_cap =3D rtlefuse->crystalcap & 0x3F;
+		rtl_set_bbreg(hw, REG_MAC_PHY_CTRL, 0x7FF80000,
+			      (crystal_cap | (crystal_cap << 6)));
+	} else {
+		crystal_cap =3D rtlefuse->crystalcap & 0x3F;
+		rtl_set_bbreg(hw, REG_MAC_PHY_CTRL, 0xFFF000,
+			      (crystal_cap | (crystal_cap << 6)));
+	}
+	rtlphy->reg_837 =3D rtl_read_byte(rtlpriv, 0x837);
+
+	return rtstatus;
+}
+
+bool rtl8821ae_phy_rf_config(struct ieee80211_hw *hw)
+{
+	return rtl8821ae_phy_rf6052_config(hw);
+}
+
+u32 phy_get_tx_swing_8812A(struct ieee80211_hw *hw, u8	band,
+			   u8 rf_path)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_dm *rtldm =3D rtl_dm(rtlpriv);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	char reg_swing_2g =3D -1;/* 0xff; */
+	char reg_swing_5g =3D -1;/* 0xff; */
+	char swing_2g =3D -1 * reg_swing_2g;
+	char swing_5g =3D -1 * reg_swing_5g;
+	u32  out =3D 0x200;
+	const char auto_temp =3D -1;
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+		 "=3D=3D=3D> PHY_GetTxBBSwing_8812A, bbSwing_2G: %d, bbSwing_5G: %d,=
autoload_failflag=3D%d.\n",
+		 (int)swing_2g, (int)swing_5g,
+		 (int)rtlefuse->autoload_failflag);
+
+	if (rtlefuse->autoload_failflag) {
+		if (band =3D=3D BAND_ON_2_4G) {
+			rtldm->swing_diff_2g =3D swing_2g;
+			if (swing_2g =3D=3D 0) {
+				out =3D 0x200; /* 0 dB */
+			} else if (swing_2g =3D=3D -3) {
+				out =3D 0x16A; /* -3 dB */
+			} else if (swing_2g =3D=3D -6) {
+				out =3D 0x101; /* -6 dB */
+			} else if (swing_2g =3D=3D -9) {
+				out =3D 0x0B6; /* -9 dB */
+			} else {
+				rtldm->swing_diff_2g =3D 0;
+				out =3D 0x200;
+			}
+		} else if (band =3D=3D BAND_ON_5G) {
+			rtldm->swing_diff_5g =3D swing_5g;
+			if (swing_5g =3D=3D 0) {
+				out =3D 0x200; /* 0 dB */
+			} else if (swing_5g =3D=3D -3) {
+				out =3D 0x16A; /* -3 dB */
+			} else if (swing_5g =3D=3D -6) {
+				out =3D 0x101; /* -6 dB */
+			} else if (swing_5g =3D=3D -9) {
+				out =3D 0x0B6; /* -9 dB */
+			} else {
+				if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+					rtldm->swing_diff_5g =3D -3;
+					out =3D 0x16A;
+				} else {
+					rtldm->swing_diff_5g =3D 0;
+					out =3D 0x200;
+				}
+			}
+		} else {
+			rtldm->swing_diff_2g =3D -3;
+			rtldm->swing_diff_5g =3D -3;
+			out =3D 0x16A; /* -3 dB */
+		}
+	} else {
+	    u32 swing =3D 0, swing_a =3D 0, swing_b =3D 0;
+
+	    if (band =3D=3D BAND_ON_2_4G) {
+			if (reg_swing_2g =3D=3D auto_temp) {
+				efuse_shadow_read(hw, 1, 0xC6, (u32 *)&swing);
+				swing =3D (swing =3D=3D 0xFF) ? 0x00 : swing;
+			} else if (swing_2g =3D=3D  0) {
+				swing =3D 0x00; /* 0 dB */
+			} else if (swing_2g =3D=3D -3) {
+				swing =3D 0x05; /* -3 dB */
+			} else if (swing_2g =3D=3D -6) {
+				swing =3D 0x0A; /* -6 dB */
+			} else if (swing_2g =3D=3D -9) {
+				swing =3D 0xFF; /* -9 dB */
+			} else {
+				swing =3D 0x00;
+			}
+		} else {
+			if (reg_swing_5g =3D=3D auto_temp) {
+				efuse_shadow_read(hw, 1, 0xC7, (u32 *)&swing);
+				swing =3D (swing =3D=3D 0xFF) ? 0x00 : swing;
+			} else if (swing_5g =3D=3D  0) {
+				swing =3D 0x00; /* 0 dB */
+			} else if (swing_5g =3D=3D -3) {
+				swing =3D 0x05; /* -3 dB */
+			} else if (swing_5g =3D=3D -6) {
+				swing =3D 0x0A; /* -6 dB */
+			} else if (swing_5g =3D=3D -9) {
+				swing =3D 0xFF; /* -9 dB */
+			} else {
+				swing =3D 0x00;
+			}
+		}
+
+		swing_a =3D (swing & 0x3) >> 0; /* 0xC6/C7[1:0] */
+		swing_b =3D (swing & 0xC) >> 2; /* 0xC6/C7[3:2] */
+		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+			 "=3D=3D=3D> PHY_GetTxBBSwing_8812A, swingA: 0x%X, swingB: 0x%X\n",
+			 swing_a, swing_b);
+
+		/* 3 Path-A */
+		if (swing_a =3D=3D 0x0) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D 0;
+			else
+				rtldm->swing_diff_5g =3D 0;
+			out =3D 0x200; /* 0 dB */
+		} else if (swing_a =3D=3D 0x1) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -3;
+			else
+				rtldm->swing_diff_5g =3D -3;
+			out =3D 0x16A; /* -3 dB */
+		} else if (swing_a =3D=3D 0x2) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -6;
+			else
+				rtldm->swing_diff_5g =3D -6;
+			out =3D 0x101; /* -6 dB */
+		} else if (swing_a =3D=3D 0x3) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -9;
+			else
+				rtldm->swing_diff_5g =3D -9;
+			out =3D 0x0B6; /* -9 dB */
+		}
+		/* 3 Path-B */
+		if (swing_b =3D=3D 0x0) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D 0;
+			else
+				rtldm->swing_diff_5g =3D 0;
+			out =3D 0x200; /* 0 dB */
+		} else if (swing_b =3D=3D 0x1) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -3;
+			else
+				rtldm->swing_diff_5g =3D -3;
+			out =3D 0x16A; /* -3 dB */
+		} else if (swing_b =3D=3D 0x2) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -6;
+			else
+				rtldm->swing_diff_5g =3D -6;
+			out =3D 0x101; /* -6 dB */
+		} else if (swing_b =3D=3D 0x3) {
+			if (band =3D=3D BAND_ON_2_4G)
+				rtldm->swing_diff_2g =3D -9;
+			else
+				rtldm->swing_diff_5g =3D -9;
+			out =3D 0x0B6; /* -9 dB */
+		}
+	}
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+		 "<=3D=3D=3D PHY_GetTxBBSwing_8812A, out =3D 0x%X\n", out);
+	 return out;
+}
+
+void rtl8821ae_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 ban=
d)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_dm *rtldm =3D rtl_dm(rtlpriv);
+	u8 current_band =3D rtlhal->current_bandtype;
+	u32 txpath, rxpath;
+	char bb_diff_between_band;
+
+	txpath =3D rtl8821ae_phy_query_bb_reg(hw, RTXPATH, 0xf0);
+	rxpath =3D rtl8821ae_phy_query_bb_reg(hw, RCCK_RX, 0x0f000000);
+	rtlhal->current_bandtype =3D (enum band_type) band;
+	/* reconfig BB/RF according to wireless mode */
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_2_4G) {
+		/* BB & RF Config */
+		rtl_set_bbreg(hw, ROFDMCCKEN, BOFDMEN|BCCKEN, 0x03);
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			/* 0xCB0[15:12] =3D 0x7 (LNA_On)*/
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, 0xF000, 0x7);
+			/* 0xCB0[7:4] =3D 0x7 (PAPE_A)*/
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, 0xF0, 0x7);
+		}
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			/*0x834[1:0] =3D 0x1*/
+			rtl_set_bbreg(hw, 0x834, 0x3, 0x1);
+		}
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			/* 0xC1C[11:8] =3D 0 */
+			rtl_set_bbreg(hw, RA_TXSCALE, 0xF00, 0);
+		} else {
+			/* 0x82C[1:0] =3D 2b'00 */
+			rtl_set_bbreg(hw, 0x82c, 0x3, 0);
+		}
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, BMASKDWORD,
+				      0x77777777);
+			rtl_set_bbreg(hw, RB_RFE_PINMUX, BMASKDWORD,
+				      0x77777777);
+			rtl_set_bbreg(hw, RA_RFE_INV, 0x3ff00000, 0x000);
+			rtl_set_bbreg(hw, RB_RFE_INV, 0x3ff00000, 0x000);
+		}
+
+		rtl_set_bbreg(hw, RTXPATH, 0xf0, 0x1);
+		rtl_set_bbreg(hw, RCCK_RX, 0x0f000000, 0x1);
+
+		rtl_write_byte(rtlpriv, REG_CCK_CHECK, 0x0);
+	} else {/* 5G band */
+		u16 count, reg_41a;
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			/*0xCB0[15:12] =3D 0x5 (LNA_On)*/
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, 0xF000, 0x5);
+			/*0xCB0[7:4] =3D 0x4 (PAPE_A)*/
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, 0xF0, 0x4);
+		}
+		/*CCK_CHECK_en*/
+		rtl_write_byte(rtlpriv, REG_CCK_CHECK, 0x80);
+
+		count =3D 0;
+		reg_41a =3D rtl_read_word(rtlpriv, REG_TXPKT_EMPTY);
+		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+			 "Reg41A value %d", reg_41a);
+		reg_41a &=3D 0x30;
+		while ((reg_41a !=3D 0x30) && (count < 50)) {
+			udelay(50);
+			RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD, "Delay 50us\n");
+
+			reg_41a =3D rtl_read_word(rtlpriv, REG_TXPKT_EMPTY);
+			reg_41a &=3D 0x30;
+			count++;
+			RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+				 "Reg41A value %d", reg_41a);
+		}
+		if (count !=3D 0)
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
+				 "PHY_SwitchWirelessBand8812(): Switch to 5G Band. Count =3D %d re=
g41A=3D0x%x\n",
+				 count, reg_41a);
+
+		/* 2012/02/01, Sinda add registry to switch workaround
+		without long-run verification for scan issue. */
+		rtl_set_bbreg(hw, ROFDMCCKEN, BOFDMEN|BCCKEN, 0x03);
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			/*0x834[1:0] =3D 0x2*/
+			rtl_set_bbreg(hw, 0x834, 0x3, 0x2);
+		}
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+			/* AGC table select */
+			/* 0xC1C[11:8] =3D 1*/
+			rtl_set_bbreg(hw, RA_TXSCALE, 0xF00, 1);
+		} else
+			/* 0x82C[1:0] =3D 2'b00 */
+			rtl_set_bbreg(hw, 0x82c, 0x3, 1);
+
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			rtl_set_bbreg(hw, RA_RFE_PINMUX, BMASKDWORD,
+				      0x77337777);
+			rtl_set_bbreg(hw, RB_RFE_PINMUX, BMASKDWORD,
+				      0x77337777);
+			rtl_set_bbreg(hw, RA_RFE_INV, 0x3ff00000, 0x010);
+			rtl_set_bbreg(hw, RB_RFE_INV, 0x3ff00000, 0x010);
+		}
+
+		rtl_set_bbreg(hw, RTXPATH, 0xf0, 0);
+		rtl_set_bbreg(hw, RCCK_RX, 0x0f000000, 0xf);
+
+		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
+			 "=3D=3D>PHY_SwitchWirelessBand8812() BAND_ON_5G settings OFDM inde=
x 0x%x\n",
+			 rtlpriv->dm.ofdm_index[RF90_PATH_A]);
+	}
+
+	if ((rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) ||
+	    (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)) {
+		/* 0xC1C[31:21] */
+		rtl_set_bbreg(hw, RA_TXSCALE, 0xFFE00000,
+			      phy_get_tx_swing_8812A(hw, band, RF90_PATH_A));
+		/* 0xE1C[31:21] */
+		rtl_set_bbreg(hw, RB_TXSCALE, 0xFFE00000,
+			      phy_get_tx_swing_8812A(hw, band, RF90_PATH_B));
+
+		/* <20121005, Kordan> When TxPowerTrack is ON,
+		 *	we should take care of the change of BB swing.
+		 *   That is, reset all info to trigger Tx power tracking.
+		 */
+		if (band !=3D current_band) {
+			bb_diff_between_band =3D
+				(rtldm->swing_diff_2g - rtldm->swing_diff_5g);
+			bb_diff_between_band =3D (band =3D=3D BAND_ON_2_4G) ?
+						bb_diff_between_band :
+						(-1 * bb_diff_between_band);
+			rtldm->default_ofdm_index +=3D bb_diff_between_band * 2;
+		}
+		rtl8821ae_dm_clear_txpower_tracking_state(hw);
+	}
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
+		 "<=3D=3Drtl8821ae_phy_switch_wirelessband():Switch Band OK.\n");
+	return;
+}
+
+static bool _rtl8821ae_check_condition(struct ieee80211_hw *hw,
+				       const u32 condition)
+{
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	u32 _board =3D rtlefuse->board_type; /*need efuse define*/
+	u32 _interface =3D 0x01; /* ODM_ITRF_PCIE */
+	u32 _platform =3D 0x08;/* ODM_WIN */
+	u32 cond =3D condition;
+
+	if (condition =3D=3D 0xCDCDCDCD)
+		return true;
+
+	cond =3D condition & 0xFF;
+	if ((_board !=3D cond) && cond !=3D 0xFF)
+		return false;
+
+	cond =3D condition & 0xFF00;
+	cond =3D cond >> 8;
+	if ((_interface & cond) =3D=3D 0 && cond !=3D 0x07)
+		return false;
+
+	cond =3D condition & 0xFF0000;
+	cond =3D cond >> 16;
+	if ((_platform & cond) =3D=3D 0 && cond !=3D 0x0F)
+		return false;
+	return true;
+}
+
+static void _rtl8821ae_config_rf_reg(struct ieee80211_hw *hw,
+				     u32 addr, u32 data,
+				     enum radio_path rfpath, u32 regaddr)
+{
+	if (addr =3D=3D 0xfe || addr =3D=3D 0xffe) {
+		/* In order not to disturb BT music when
+		 * wifi init.(1ant NIC only)
+		 */
+		mdelay(50);
+	} else {
+		rtl_set_rfreg(hw, rfpath, regaddr, RFREG_OFFSET_MASK, data);
+		udelay(1);
+	}
+}
+
+static void _rtl8821ae_config_rf_radio_a(struct ieee80211_hw *hw,
+					 u32 addr, u32 data)
+{
+	u32 content =3D 0x1000; /*RF Content: radio_a_txt*/
+	u32 maskforphyset =3D (u32)(content & 0xE000);
+
+	_rtl8821ae_config_rf_reg(hw, addr, data,
+				 RF90_PATH_A, addr | maskforphyset);
+}
+
+static void _rtl8821ae_config_rf_radio_b(struct ieee80211_hw *hw,
+					 u32 addr, u32 data)
+{
+	u32 content =3D 0x1001; /*RF Content: radio_b_txt*/
+	u32 maskforphyset =3D (u32)(content & 0xE000);
+
+	_rtl8821ae_config_rf_reg(hw, addr, data,
+				 RF90_PATH_B, addr | maskforphyset);
+}
+
+static void _rtl8821ae_config_bb_reg(struct ieee80211_hw *hw,
+				     u32 addr, u32 data)
+{
+	if (addr =3D=3D 0xfe)
+		mdelay(50);
+	else if (addr =3D=3D 0xfd)
+		mdelay(5);
+	else if (addr =3D=3D 0xfc)
+		mdelay(1);
+	else if (addr =3D=3D 0xfb)
+		udelay(50);
+	else if (addr =3D=3D 0xfa)
+		udelay(5);
+	else if (addr =3D=3D 0xf9)
+		udelay(1);
+	else
+		rtl_set_bbreg(hw, addr, MASKDWORD, data);
+
+	udelay(1);
+}
+
+static void _rtl8821ae_phy_init_tx_power_by_rate(struct ieee80211_hw *=
hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 band, rfpath, txnum, rate_section;
+
+	for (band =3D BAND_ON_2_4G; band <=3D BAND_ON_5G; ++band)
+		for (rfpath =3D 0; rfpath < TX_PWR_BY_RATE_NUM_RF; ++rfpath)
+			for (txnum =3D 0; txnum < TX_PWR_BY_RATE_NUM_RF; ++txnum)
+				for (rate_section =3D 0;
+				     rate_section < TX_PWR_BY_RATE_NUM_SECTION;
+				     ++rate_section)
+					rtlphy->tx_power_by_rate_offset[band]
+					    [rfpath][txnum][rate_section] =3D 0;
+}
+
+static void _rtl8821ae_phy_set_txpower_by_rate_base(struct ieee80211_h=
w *hw,
+					  u8 band, u8 path,
+					  u8 rate_section,
+					  u8 txnum, u8 value)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	if (path > RF90_PATH_D) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			"Invalid Rf Path %d in phy_SetTxPowerByRatBase()\n", path);
+		return;
+	}
+
+	if (band =3D=3D BAND_ON_2_4G) {
+		switch (rate_section) {
+		case CCK:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][0] =3D value;
+			break;
+		case OFDM:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][1] =3D value;
+			break;
+		case HT_MCS0_MCS7:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][2] =3D value;
+			break;
+		case HT_MCS8_MCS15:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][3] =3D value;
+			break;
+		case VHT_1SSMCS0_1SSMCS9:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][4] =3D value;
+			break;
+		case VHT_2SSMCS0_2SSMCS9:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][5] =3D value;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Invalid RateSection %d in Band 2.4G,Rf Path %d, %dTx in PHY_SetT=
xPowerByRateBase()\n",
+				 rate_section, path, txnum);
+			break;
+		};
+	} else if (band =3D=3D BAND_ON_5G) {
+		switch (rate_section) {
+		case OFDM:
+			rtlphy->txpwr_by_rate_base_5g[path][txnum][0] =3D value;
+			break;
+		case HT_MCS0_MCS7:
+			rtlphy->txpwr_by_rate_base_5g[path][txnum][1] =3D value;
+			break;
+		case HT_MCS8_MCS15:
+			rtlphy->txpwr_by_rate_base_5g[path][txnum][2] =3D value;
+			break;
+		case VHT_1SSMCS0_1SSMCS9:
+			rtlphy->txpwr_by_rate_base_5g[path][txnum][3] =3D value;
+			break;
+		case VHT_2SSMCS0_2SSMCS9:
+			rtlphy->txpwr_by_rate_base_5g[path][txnum][4] =3D value;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				"Invalid RateSection %d in Band 5G, Rf Path %d, %dTx in PHY_SetTxP=
owerByRateBase()\n",
+				rate_section, path, txnum);
+			break;
+		};
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			"Invalid Band %d in PHY_SetTxPowerByRateBase()\n", band);
+	}
+}
+
+static u8 _rtl8821ae_phy_get_txpower_by_rate_base(struct ieee80211_hw =
*hw,
+						  u8 band, u8 path,
+						  u8 txnum, u8 rate_section)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 value =3D 0;
+
+	if (path > RF90_PATH_D) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Invalid Rf Path %d in PHY_GetTxPowerByRateBase()\n",
+			 path);
+		return 0;
+	}
+
+	if (band =3D=3D BAND_ON_2_4G) {
+		switch (rate_section) {
+		case CCK:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][0];
+			break;
+		case OFDM:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][1];
+			break;
+		case HT_MCS0_MCS7:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][2];
+			break;
+		case HT_MCS8_MCS15:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][3];
+			break;
+		case VHT_1SSMCS0_1SSMCS9:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][4];
+			break;
+		case VHT_2SSMCS0_2SSMCS9:
+			value =3D rtlphy->txpwr_by_rate_base_24g[path][txnum][5];
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Invalid RateSection %d in Band 2.4G, Rf Path %d, %dTx in PHY_Get=
TxPowerByRateBase()\n",
+				 rate_section, path, txnum);
+			break;
+		};
+	} else if (band =3D=3D BAND_ON_5G) {
+		switch (rate_section) {
+		case OFDM:
+			value =3D rtlphy->txpwr_by_rate_base_5g[path][txnum][0];
+			break;
+		case HT_MCS0_MCS7:
+			value =3D rtlphy->txpwr_by_rate_base_5g[path][txnum][1];
+			break;
+		case HT_MCS8_MCS15:
+			value =3D rtlphy->txpwr_by_rate_base_5g[path][txnum][2];
+			break;
+		case VHT_1SSMCS0_1SSMCS9:
+			value =3D rtlphy->txpwr_by_rate_base_5g[path][txnum][3];
+			break;
+		case VHT_2SSMCS0_2SSMCS9:
+			value =3D rtlphy->txpwr_by_rate_base_5g[path][txnum][4];
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				 "Invalid RateSection %d in Band 5G, Rf Path %d, %dTx in PHY_GetTx=
PowerByRateBase()\n",
+				 rate_section, path, txnum);
+			break;
+		};
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "Invalid Band %d in PHY_GetTxPowerByRateBase()\n", band);
+	}
+
+	return value;
+}
+
+static void _rtl8821ae_phy_store_txpower_by_rate_base(struct ieee80211=
_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u16 rawValue =3D 0;
+	u8 base =3D 0, path =3D 0;
+
+	for (path =3D RF90_PATH_A; path <=3D RF90_PATH_B; ++path) {
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_1TX][0] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, CCK,=
 RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_1TX][2] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, OFDM=
, RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_1TX][4] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, HT_M=
CS0_MCS7, RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_2TX][6] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, HT_M=
CS8_MCS15, RF_2TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_1TX][8] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, VHT_=
1SSMCS0_1SSMCS9, RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][pat=
h][RF_2TX][11] >> 8) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path, VHT_=
2SSMCS0_2SSMCS9, RF_2TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_5G][path]=
[RF_1TX][2] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_5G, path, OFDM, =
RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_5G][path]=
[RF_1TX][4] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_5G, path, HT_MCS=
0_MCS7, RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_5G][path]=
[RF_2TX][6] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_5G, path, HT_MCS=
8_MCS15, RF_2TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_5G][path]=
[RF_1TX][8] >> 24) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_5G, path, VHT_1S=
SMCS0_1SSMCS9, RF_1TX, base);
+
+		rawValue =3D (u16)(rtlphy->tx_power_by_rate_offset[BAND_ON_5G][path]=
[RF_2TX][11] >> 8) & 0xFF;
+		base =3D (rawValue >> 4) * 10 + (rawValue & 0xF);
+		_rtl8821ae_phy_set_txpower_by_rate_base(hw, BAND_ON_5G, path, VHT_2S=
SMCS0_2SSMCS9, RF_2TX, base);
+	}
+}
+
+static void _phy_convert_txpower_dbm_to_relative_value(u32 *data, u8 s=
tart,
+						u8 end, u8 base_val)
+{
+	char i =3D 0;
+	u8 temp_value =3D 0;
+	u32 temp_data =3D 0;
+
+	for (i =3D 3; i >=3D 0; --i) {
+		if (i >=3D start && i <=3D end) {
+			/* Get the exact value */
+			temp_value =3D (u8)(*data >> (i * 8)) & 0xF;
+			temp_value +=3D ((u8)((*data >> (i * 8 + 4)) & 0xF)) * 10;
+
+			/* Change the value to a relative value */
+			temp_value =3D (temp_value > base_val) ? temp_value -
+					base_val : base_val - temp_value;
+		} else {
+			temp_value =3D (u8)(*data >> (i * 8)) & 0xFF;
+		}
+		temp_data <<=3D 8;
+		temp_data |=3D temp_value;
+	}
+	*data =3D temp_data;
+}
+
+static void _rtl8812ae_phy_cross_reference_ht_and_vht_txpower_limit(st=
ruct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 regulation, bw, channel, rate_section;
+	char temp_pwrlmt =3D 0;
+
+	for (regulation =3D 0; regulation < MAX_REGULATION_NUM; ++regulation)=
 {
+		for (bw =3D 0; bw < MAX_5G_BANDWITH_NUM; ++bw) {
+			for (channel =3D 0; channel < CHANNEL_MAX_NUMBER_5G; ++channel) {
+				for (rate_section =3D 0; rate_section < MAX_RATE_SECTION_NUM; ++ra=
te_section) {
+					temp_pwrlmt =3D rtlphy->txpwr_limit_5g[regulation]
+						[bw][rate_section][channel][RF90_PATH_A];
+					if (temp_pwrlmt =3D=3D MAX_POWER_INDEX) {
+						if (bw =3D=3D 0 || bw =3D=3D 1) { /*5G 20M 40M VHT and HT can cr=
oss reference*/
+							RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+								"No power limit table of the specified band %d, bandwidth %d, =
ratesection %d, channel %d, rf path %d\n",
+								1, bw, rate_section, channel, RF90_PATH_A);
+							if (rate_section =3D=3D 2) {
+								rtlphy->txpwr_limit_5g[regulation][bw][2][channel][RF90_PATH_A=
] =3D
+									rtlphy->txpwr_limit_5g[regulation][bw][4][channel][RF90_PATH_=
A];
+							} else if (rate_section =3D=3D 4) {
+								rtlphy->txpwr_limit_5g[regulation][bw][4][channel][RF90_PATH_A=
] =3D
+									rtlphy->txpwr_limit_5g[regulation][bw][2][channel][RF90_PATH_=
A];
+							} else if (rate_section =3D=3D 3) {
+								rtlphy->txpwr_limit_5g[regulation][bw][3][channel][RF90_PATH_A=
] =3D
+									rtlphy->txpwr_limit_5g[regulation][bw][5][channel][RF90_PATH_=
A];
+							} else if (rate_section =3D=3D 5) {
+								rtlphy->txpwr_limit_5g[regulation][bw][5][channel][RF90_PATH_A=
] =3D
+									rtlphy->txpwr_limit_5g[regulation][bw][3][channel][RF90_PATH_=
A];
+							}
+
+							RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "use other value %d", t=
emp_pwrlmt);
+						}
+					}
+				}
+			}
+		}
+	}
+}
+
+static u8 _rtl8812ae_phy_get_txpower_by_rate_base_index(struct ieee802=
11_hw *hw,
+						   enum band_type band, u8 rate)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 index =3D 0;
+	if (band =3D=3D BAND_ON_2_4G) {
+		switch (rate) {
+		case MGN_1M:
+		case MGN_2M:
+		case MGN_5_5M:
+		case MGN_11M:
+			index =3D 0;
+			break;
+
+		case MGN_6M:
+		case MGN_9M:
+		case MGN_12M:
+		case MGN_18M:
+		case MGN_24M:
+		case MGN_36M:
+		case MGN_48M:
+		case MGN_54M:
+			index =3D 1;
+			break;
+
+		case MGN_MCS0:
+		case MGN_MCS1:
+		case MGN_MCS2:
+		case MGN_MCS3:
+		case MGN_MCS4:
+		case MGN_MCS5:
+		case MGN_MCS6:
+		case MGN_MCS7:
+			index =3D 2;
+			break;
+
+		case MGN_MCS8:
+		case MGN_MCS9:
+		case MGN_MCS10:
+		case MGN_MCS11:
+		case MGN_MCS12:
+		case MGN_MCS13:
+		case MGN_MCS14:
+		case MGN_MCS15:
+			index =3D 3;
+			break;
+
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				"Wrong rate 0x%x to obtain index in 2.4G in PHY_GetTxPowerByRateBa=
seIndex()\n",
+				rate);
+			break;
+		}
+	} else if (band =3D=3D BAND_ON_5G) {
+		switch (rate) {
+		case MGN_6M:
+		case MGN_9M:
+		case MGN_12M:
+		case MGN_18M:
+		case MGN_24M:
+		case MGN_36M:
+		case MGN_48M:
+		case MGN_54M:
+			index =3D 0;
+			break;
+
+		case MGN_MCS0:
+		case MGN_MCS1:
+		case MGN_MCS2:
+		case MGN_MCS3:
+		case MGN_MCS4:
+		case MGN_MCS5:
+		case MGN_MCS6:
+		case MGN_MCS7:
+			index =3D 1;
+			break;
+
+		case MGN_MCS8:
+		case MGN_MCS9:
+		case MGN_MCS10:
+		case MGN_MCS11:
+		case MGN_MCS12:
+		case MGN_MCS13:
+		case MGN_MCS14:
+		case MGN_MCS15:
+			index =3D 2;
+			break;
+
+		case MGN_VHT1SS_MCS0:
+		case MGN_VHT1SS_MCS1:
+		case MGN_VHT1SS_MCS2:
+		case MGN_VHT1SS_MCS3:
+		case MGN_VHT1SS_MCS4:
+		case MGN_VHT1SS_MCS5:
+		case MGN_VHT1SS_MCS6:
+		case MGN_VHT1SS_MCS7:
+		case MGN_VHT1SS_MCS8:
+		case MGN_VHT1SS_MCS9:
+			index =3D 3;
+			break;
+
+		case MGN_VHT2SS_MCS0:
+		case MGN_VHT2SS_MCS1:
+		case MGN_VHT2SS_MCS2:
+		case MGN_VHT2SS_MCS3:
+		case MGN_VHT2SS_MCS4:
+		case MGN_VHT2SS_MCS5:
+		case MGN_VHT2SS_MCS6:
+		case MGN_VHT2SS_MCS7:
+		case MGN_VHT2SS_MCS8:
+		case MGN_VHT2SS_MCS9:
+			index =3D 4;
+			break;
+
+		default:
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+				"Wrong rate 0x%x to obtain index in 5G in PHY_GetTxPowerByRateBase=
Index()\n",
+				rate);
+			break;
+		}
+	}
+
+	return index;
+}
+
+static void _rtl8812ae_phy_convert_txpower_limit_to_power_index(struct=
 ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 bw40_pwr_base_dbm2_4G, bw40_pwr_base_dbm5G;
+	u8 regulation, bw, channel, rate_section;
+	u8 base_index2_4G =3D 0;
+	u8 base_index5G =3D 0;
+	char temp_value =3D 0, temp_pwrlmt =3D 0;
+	u8 rf_path =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		"=3D=3D=3D=3D=3D> _rtl8812ae_phy_convert_txpower_limit_to_power_inde=
x()\n");
+
+	_rtl8812ae_phy_cross_reference_ht_and_vht_txpower_limit(hw);
+
+	for (regulation =3D 0; regulation < MAX_REGULATION_NUM; ++regulation)=
 {
+		for (bw =3D 0; bw < MAX_2_4G_BANDWITH_NUM; ++bw) {
+			for (channel =3D 0; channel < CHANNEL_MAX_NUMBER_2G; ++channel) {
+				for (rate_section =3D 0; rate_section < MAX_RATE_SECTION_NUM; ++ra=
te_section) {
+					/* obtain the base dBm values in 2.4G band
+					 CCK =3D> 11M, OFDM =3D> 54M, HT 1T =3D> MCS7, HT 2T =3D> MCS15*/
+					if (rate_section =3D=3D 0) { /*CCK*/
+						base_index2_4G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_2_4G, MGN_11M);
+					} else if (rate_section =3D=3D 1) { /*OFDM*/
+						base_index2_4G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_2_4G, MGN_54M);
+					} else if (rate_section =3D=3D 2) { /*HT IT*/
+						base_index2_4G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_2_4G, MGN_MCS7);
+					} else if (rate_section =3D=3D 3) { /*HT 2T*/
+						base_index2_4G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_2_4G, MGN_MCS15);
+					}
+
+					temp_pwrlmt =3D rtlphy->txpwr_limit_2_4g[regulation]
+						[bw][rate_section][channel][RF90_PATH_A];
+
+					for (rf_path =3D RF90_PATH_A;
+						rf_path < MAX_RF_PATH_NUM;
+						++rf_path) {
+						if (rate_section =3D=3D 3)
+							bw40_pwr_base_dbm2_4G =3D
+							rtlphy->txpwr_by_rate_base_24g[rf_path][RF_2TX][base_index2_4G]=
;
+						else
+							bw40_pwr_base_dbm2_4G =3D
+							rtlphy->txpwr_by_rate_base_24g[rf_path][RF_1TX][base_index2_4G]=
;
+
+						if (temp_pwrlmt !=3D MAX_POWER_INDEX) {
+							temp_value =3D temp_pwrlmt - bw40_pwr_base_dbm2_4G;
+							rtlphy->txpwr_limit_2_4g[regulation]
+								[bw][rate_section][channel][rf_path] =3D
+								temp_value;
+						}
+
+						RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+							"TxPwrLimit_2_4G[regulation %d][bw %d][rateSection %d][channel =
%d] =3D %d\n(TxPwrLimit in dBm %d - BW40PwrLmt2_4G[channel %d][rfPath %=
d] %d)\n",
+							regulation, bw, rate_section, channel,
+							rtlphy->txpwr_limit_2_4g[regulation][bw]
+							[rate_section][channel][rf_path], (temp_pwrlmt =3D=3D 63)
+							? 0 : temp_pwrlmt/2, channel, rf_path,
+							bw40_pwr_base_dbm2_4G);
+					}
+				}
+			}
+		}
+	}
+	for (regulation =3D 0; regulation < MAX_REGULATION_NUM; ++regulation)=
 {
+		for (bw =3D 0; bw < MAX_5G_BANDWITH_NUM; ++bw) {
+			for (channel =3D 0; channel < CHANNEL_MAX_NUMBER_5G; ++channel) {
+				for (rate_section =3D 0; rate_section < MAX_RATE_SECTION_NUM; ++ra=
te_section) {
+					/* obtain the base dBm values in 5G band
+					 OFDM =3D> 54M, HT 1T =3D> MCS7, HT 2T =3D> MCS15,
+					VHT =3D> 1SSMCS7, VHT 2T =3D> 2SSMCS7*/
+					if (rate_section =3D=3D 1) { /*OFDM*/
+						base_index5G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_5G, MGN_54M);
+					} else if (rate_section =3D=3D 2) { /*HT 1T*/
+						base_index5G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_5G, MGN_MCS7);
+					} else if (rate_section =3D=3D 3) { /*HT 2T*/
+						base_index5G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_5G, MGN_MCS15);
+					} else if (rate_section =3D=3D 4) { /*VHT 1T*/
+						base_index5G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_5G, MGN_VHT1SS_MCS7);
+					} else if (rate_section =3D=3D 5) { /*VHT 2T*/
+						base_index5G =3D
+							_rtl8812ae_phy_get_txpower_by_rate_base_index(hw,
+							BAND_ON_5G, MGN_VHT2SS_MCS7);
+					}
+
+					temp_pwrlmt =3D rtlphy->txpwr_limit_5g[regulation]
+						[bw][rate_section][channel]
+						[RF90_PATH_A];
+
+					for (rf_path =3D RF90_PATH_A;
+					     rf_path < MAX_RF_PATH_NUM;
+					     ++rf_path) {
+						if (rate_section =3D=3D 3 || rate_section =3D=3D 5)
+							bw40_pwr_base_dbm5G =3D
+							rtlphy->txpwr_by_rate_base_5g[rf_path]
+							[RF_2TX][base_index5G];
+						else
+							bw40_pwr_base_dbm5G =3D
+							rtlphy->txpwr_by_rate_base_5g[rf_path]
+							[RF_1TX][base_index5G];
+
+						if (temp_pwrlmt !=3D MAX_POWER_INDEX) {
+							temp_value =3D
+								temp_pwrlmt - bw40_pwr_base_dbm5G;
+							rtlphy->txpwr_limit_5g[regulation]
+								[bw][rate_section][channel]
+								[rf_path] =3D temp_value;
+						}
+
+						RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+							"TxPwrLimit_5G[regulation %d][bw %d][rateSection %d][channel %d=
] =3D%d\n(TxPwrLimit in dBm %d - BW40PwrLmt5G[chnl group %d][rfPath %d]=
 %d)\n",
+							regulation, bw, rate_section,
+							channel, rtlphy->txpwr_limit_5g[regulation]
+							[bw][rate_section][channel][rf_path],
+							temp_pwrlmt, channel, rf_path, bw40_pwr_base_dbm5G);
+					}
+				}
+			}
+		}
+	}
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "<=3D=3D=3D=3D=3D _rtl8812ae_phy_convert_txpower_limit_to_power_ind=
ex()\n");
+}
+
+static void _rtl8821ae_phy_init_txpower_limit(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 i, j, k, l, m;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "=3D=3D=3D=3D=3D> _rtl8821ae_phy_init_txpower_limit()!\n");
+
+	for (i =3D 0; i < MAX_REGULATION_NUM; ++i) {
+		for (j =3D 0; j < MAX_2_4G_BANDWITH_NUM; ++j)
+			for (k =3D 0; k < MAX_RATE_SECTION_NUM; ++k)
+				for (m =3D 0; m < CHANNEL_MAX_NUMBER_2G; ++m)
+					for (l =3D 0; l < MAX_RF_PATH_NUM; ++l)
+						rtlphy->txpwr_limit_2_4g
+								[i][j][k][m][l]
+							=3D MAX_POWER_INDEX;
+	}
+	for (i =3D 0; i < MAX_REGULATION_NUM; ++i) {
+		for (j =3D 0; j < MAX_5G_BANDWITH_NUM; ++j)
+			for (k =3D 0; k < MAX_RATE_SECTION_NUM; ++k)
+				for (m =3D 0; m < CHANNEL_MAX_NUMBER_5G; ++m)
+					for (l =3D 0; l < MAX_RF_PATH_NUM; ++l)
+						rtlphy->txpwr_limit_5g
+								[i][j][k][m][l]
+							=3D MAX_POWER_INDEX;
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "<=3D=3D=3D=3D=3D _rtl8821ae_phy_init_txpower_limit()!\n");
+}
+
+static void _rtl8821ae_phy_convert_txpower_dbm_to_relative_value(struc=
t ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 base =3D 0, rfPath =3D 0;
+
+	for (rfPath =3D RF90_PATH_A; rfPath <=3D RF90_PATH_B; ++rfPath) {
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_1TX, CCK);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][0],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_1TX, OFDM);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][1],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][2],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_1TX, HT_MCS0_MCS7);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][3],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][4],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_2TX, HT_MCS8_MCS15);
+
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_2TX][5],
+			0, 3, base);
+
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_2TX][6],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_1TX, VHT_1SSMCS0_1SSMCS9);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][7],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][8],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][9],
+			0, 1, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_2_4G, r=
fPath, RF_2TX, VHT_2SSMCS0_2SSMCS9);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_1TX][9],
+			2, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_2TX][10],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][rfPath][RF_2TX][11],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_5G, rfP=
ath, RF_1TX, OFDM);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][1],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][2],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_5G, rfP=
ath, RF_1TX, HT_MCS0_MCS7);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][3],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][4],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_5G, rfP=
ath, RF_2TX, HT_MCS8_MCS15);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_2TX][5],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_2TX][6],
+			0, 3, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_5G, rfP=
ath, RF_1TX, VHT_1SSMCS0_1SSMCS9);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][7],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][8],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][9],
+			0, 1, base);
+
+		base =3D _rtl8821ae_phy_get_txpower_by_rate_base(hw, BAND_ON_5G, rfP=
ath, RF_2TX, VHT_2SSMCS0_2SSMCS9);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_1TX][9],
+			2, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_2TX][10],
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&rtlphy->tx_power_by_rate_offset[BAND_ON_5G][rfPath][RF_2TX][11],
+			0, 3, base);
+	}
+
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+		"<=3D=3D=3D_rtl8821ae_phy_convert_txpower_dbm_to_relative_value()\n"=
);
+}
+
+static void _rtl8821ae_phy_txpower_by_rate_configuration(struct ieee80=
211_hw *hw)
+{
+	_rtl8821ae_phy_store_txpower_by_rate_base(hw);
+	_rtl8821ae_phy_convert_txpower_dbm_to_relative_value(hw);
+}
+
+/* string is in decimal */
+static bool _rtl8812ae_get_integer_from_string(char *str, u8 *pint)
+{
+	u16 i =3D 0;
+	*pint =3D 0;
+
+	while (str[i] !=3D '\0') {
+		if (str[i] >=3D '0' && str[i] <=3D '9') {
+			*pint *=3D 10;
+			*pint +=3D (str[i] - '0');
+		} else {
+			return false;
+		}
+		++i;
+	}
+
+	return true;
+}
+
+static bool _rtl8812ae_eq_n_byte(u8 *str1, u8 *str2, u32 num)
+{
+	if (num =3D=3D 0)
+		return false;
+	while (num > 0) {
+		num--;
+		if (str1[num] !=3D str2[num])
+			return false;
+	}
+	return true;
+}
+
+static char _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(struct ieee80211_=
hw *hw,
+					      u8 band, u8 channel)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	char channel_index =3D -1;
+	u8 channel_5g[CHANNEL_MAX_NUMBER_5G] =3D {
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64,
+		100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122,
+		124, 126, 128, 130, 132, 134, 136, 138, 140, 142, 144, 149,
+		151, 153, 155, 157, 159, 161, 163, 165, 167, 168, 169, 171,
+		173, 175, 177};
+	u8  i =3D 0;
+	if (band =3D=3D BAND_ON_2_4G)
+		channel_index =3D channel - 1;
+	else if (band =3D=3D BAND_ON_5G) {
+		for (i =3D 0; i < sizeof(channel_5g)/sizeof(u8); ++i) {
+			if (channel_5g[i] =3D=3D channel)
+				channel_index =3D i;
+		}
+	} else
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Invalid Band %d in %s",
+			 band,  __func__);
+
+	if (channel_index =3D=3D -1)
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Invalid Channel %d of Band %d in %s", channel,
+			 band, __func__);
+
+	return channel_index;
+}
+
+static void _rtl8812ae_phy_set_txpower_limit(struct ieee80211_hw *hw, =
u8 *pregulation,
+				      u8 *pband, u8 *pbandwidth,
+				      u8 *prate_section, u8 *prf_path,
+				      u8 *pchannel, u8 *ppower_limit)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 regulation =3D 0, bandwidth =3D 0, rate_section =3D 0, channel;
+	u8 channel_index;
+	char power_limit =3D 0, prev_power_limit, ret;
+
+	if (!_rtl8812ae_get_integer_from_string((char *)pchannel, &channel) |=
|
+	    !_rtl8812ae_get_integer_from_string((char *)ppower_limit,
+						&power_limit)) {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Illegal index of pwr_lmt table [chnl %d][val %d]\n",
+			  channel, power_limit);
+	}
+
+	power_limit =3D power_limit > MAX_POWER_INDEX ?
+		      MAX_POWER_INDEX : power_limit;
+
+	if (_rtl8812ae_eq_n_byte(pregulation, (u8 *)("FCC"), 3))
+		regulation =3D 0;
+	else if (_rtl8812ae_eq_n_byte(pregulation, (u8 *)("MKK"), 3))
+		regulation =3D 1;
+	else if (_rtl8812ae_eq_n_byte(pregulation, (u8 *)("ETSI"), 4))
+		regulation =3D 2;
+	else if (_rtl8812ae_eq_n_byte(pregulation, (u8 *)("WW13"), 4))
+		regulation =3D 3;
+
+	if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("CCK"), 3))
+		rate_section =3D 0;
+	else if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("OFDM"), 4))
+		rate_section =3D 1;
+	else if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("HT"), 2) &&
+		 _rtl8812ae_eq_n_byte(prf_path, (u8 *)("1T"), 2))
+		rate_section =3D 2;
+	else if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("HT"), 2) &&
+		 _rtl8812ae_eq_n_byte(prf_path, (u8 *)("2T"), 2))
+		rate_section =3D 3;
+	else if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("VHT"), 3) &&
+		 _rtl8812ae_eq_n_byte(prf_path, (u8 *)("1T"), 2))
+		rate_section =3D 4;
+	else if (_rtl8812ae_eq_n_byte(prate_section, (u8 *)("VHT"), 3) &&
+		 _rtl8812ae_eq_n_byte(prf_path, (u8 *)("2T"), 2))
+		rate_section =3D 5;
+
+	if (_rtl8812ae_eq_n_byte(pbandwidth, (u8 *)("20M"), 3))
+		bandwidth =3D 0;
+	else if (_rtl8812ae_eq_n_byte(pbandwidth, (u8 *)("40M"), 3))
+		bandwidth =3D 1;
+	else if (_rtl8812ae_eq_n_byte(pbandwidth, (u8 *)("80M"), 3))
+		bandwidth =3D 2;
+	else if (_rtl8812ae_eq_n_byte(pbandwidth, (u8 *)("160M"), 4))
+		bandwidth =3D 3;
+
+	if (_rtl8812ae_eq_n_byte(pband, (u8 *)("2.4G"), 4)) {
+		ret =3D _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(hw,
+							       BAND_ON_2_4G,
+							       channel);
+
+		if (ret =3D=3D -1)
+			return;
+
+		channel_index =3D ret;
+
+		prev_power_limit =3D rtlphy->txpwr_limit_2_4g[regulation]
+						[bandwidth][rate_section]
+						[channel_index][RF90_PATH_A];
+
+		if (power_limit < prev_power_limit)
+			rtlphy->txpwr_limit_2_4g[regulation][bandwidth]
+				[rate_section][channel_index][RF90_PATH_A] =3D
+								   power_limit;
+
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "2.4G [regula %d][bw %d][sec %d][chnl %d][val %d]\n",
+			  regulation, bandwidth, rate_section, channel_index,
+			  rtlphy->txpwr_limit_2_4g[regulation][bandwidth]
+				[rate_section][channel_index][RF90_PATH_A]);
+	} else if (_rtl8812ae_eq_n_byte(pband, (u8 *)("5G"), 2)) {
+		ret =3D _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(hw,
+							       BAND_ON_5G,
+							       channel);
+
+		if (ret =3D=3D -1)
+			return;
+
+		channel_index =3D ret;
+
+		prev_power_limit =3D rtlphy->txpwr_limit_5g[regulation][bandwidth]
+						[rate_section][channel_index]
+						[RF90_PATH_A];
+
+		if (power_limit < prev_power_limit)
+			rtlphy->txpwr_limit_5g[regulation][bandwidth]
+			[rate_section][channel_index][RF90_PATH_A] =3D power_limit;
+
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "5G: [regul %d][bw %d][sec %d][chnl %d][val %d]\n",
+			  regulation, bandwidth, rate_section, channel,
+			  rtlphy->txpwr_limit_5g[regulation][bandwidth]
+				[rate_section][channel_index][RF90_PATH_A]);
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+			 "Cannot recognize the band info in %s\n", pband);
+		return;
+	}
+}
+
+static void _rtl8812ae_phy_config_bb_txpwr_lmt(struct ieee80211_hw *hw=
,
+					  u8 *regulation, u8 *band,
+					  u8 *bandwidth, u8 *rate_section,
+					  u8 *rf_path, u8 *channel,
+					  u8 *power_limit)
+{
+	_rtl8812ae_phy_set_txpower_limit(hw, regulation, band, bandwidth,
+					 rate_section, rf_path, channel,
+					 power_limit);
+}
+
+static void _rtl8821ae_phy_read_and_config_txpwr_lmt(struct ieee80211_=
hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	u32 i =3D 0;
+	u32 array_len;
+	u8 **array;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		array_len =3D RTL8812AE_TXPWR_LMT_ARRAY_LEN;
+		array =3D RTL8812AE_TXPWR_LMT;
+	} else {
+		array_len =3D RTL8821AE_TXPWR_LMT_ARRAY_LEN;
+		array =3D RTL8821AE_TXPWR_LMT;
+	}
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "\n");
+
+	for (i =3D 0; i < array_len; i +=3D 7) {
+		u8 *regulation =3D array[i];
+		u8 *band =3D array[i+1];
+		u8 *bandwidth =3D array[i+2];
+		u8 *rate =3D array[i+3];
+		u8 *rf_path =3D array[i+4];
+		u8 *chnl =3D array[i+5];
+		u8 *val =3D array[i+6];
+
+		_rtl8812ae_phy_config_bb_txpwr_lmt(hw, regulation, band,
+						   bandwidth, rate, rf_path,
+						   chnl, val);
+	}
+}
+
+static bool _rtl8821ae_phy_bb8821a_config_parafile(struct ieee80211_hw=
 *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	bool rtstatus;
+
+	_rtl8821ae_phy_init_txpower_limit(hw);
+
+	/* RegEnableTxPowerLimit =3D=3D 1 for 8812a & 8821a */
+	if (rtlefuse->eeprom_regulatory !=3D 2)
+		_rtl8821ae_phy_read_and_config_txpwr_lmt(hw);
+
+	rtstatus =3D _rtl8821ae_phy_config_bb_with_headerfile(hw,
+						       BASEBAND_CONFIG_PHY_REG);
+	if (rtstatus !=3D true) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!");
+		return false;
+	}
+	_rtl8821ae_phy_init_tx_power_by_rate(hw);
+	if (rtlefuse->autoload_failflag =3D=3D false) {
+		rtstatus =3D _rtl8821ae_phy_config_bb_with_pgheaderfile(hw,
+						    BASEBAND_CONFIG_PHY_REG);
+	}
+	if (rtstatus !=3D true) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!");
+		return false;
+	}
+
+	_rtl8821ae_phy_txpower_by_rate_configuration(hw);
+
+	/* RegEnableTxPowerLimit =3D=3D 1 for 8812a & 8821a */
+	if (rtlefuse->eeprom_regulatory !=3D 2)
+		_rtl8812ae_phy_convert_txpower_limit_to_power_index(hw);
+
+	rtstatus =3D _rtl8821ae_phy_config_bb_with_headerfile(hw,
+						BASEBAND_CONFIG_AGC_TAB);
+
+	if (rtstatus !=3D true) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
+		return false;
+	}
+	rtlphy->cck_high_power =3D (bool)(rtl_get_bbreg(hw,
+			RFPGA0_XA_HSSIPARAMETER2, 0x200));
+	return true;
+}
+
+static bool _rtl8821ae_phy_config_mac_with_headerfile(struct ieee80211=
_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	u32 i, v1, v2;
+	u32 arraylength;
+	u32 *ptrarray;
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read MAC_REG_Array\n");
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+		arraylength =3D RTL8821AEMAC_1T_ARRAYLEN;
+		ptrarray =3D RTL8821AE_MAC_REG_ARRAY;
+	} else {
+		arraylength =3D RTL8812AEMAC_1T_ARRAYLEN;
+		ptrarray =3D RTL8812AE_MAC_REG_ARRAY;
+	}
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Img: MAC_REG_ARRAY LEN %d\n", arraylength);
+	for (i =3D 0; i < arraylength; i +=3D 2) {
+		v1 =3D ptrarray[i];
+		v2 =3D (u8)ptrarray[i + 1];
+		if (v1 < 0xCDCDCDCD) {
+			rtl_write_byte(rtlpriv, v1, (u8)v2);
+			continue;
+		} else {
+			if (!_rtl8821ae_check_condition(hw, v1)) {
+				/*Discard the following (offset, data) pairs*/
+				READ_NEXT_PAIR(ptrarray, v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < arraylength - 2) {
+					READ_NEXT_PAIR(ptrarray, v1, v2, i);
+				}
+				i -=3D 2; /* prevent from for-loop +=3D 2*/
+			} else {/*Configure matched pairs and skip to end of if-else.*/
+				READ_NEXT_PAIR(ptrarray, v1, v2, i);
+				while (v2 !=3D 0xDEAD &&
+				       v2 !=3D 0xCDEF &&
+				       v2 !=3D 0xCDCD && i < arraylength - 2) {
+					rtl_write_byte(rtlpriv, v1, v2);
+					READ_NEXT_PAIR(ptrarray, v1, v2, i);
+				}
+
+				while (v2 !=3D 0xDEAD && i < arraylength - 2)
+					READ_NEXT_PAIR(ptrarray, v1, v2, i);
+			}
+		}
+	}
+	return true;
+}
+
+static bool _rtl8821ae_phy_config_bb_with_headerfile(struct ieee80211_=
hw *hw,
+						     u8 configtype)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	int i;
+	u32 *array_table;
+	u16 arraylen;
+	u32 v1 =3D 0, v2 =3D 0;
+
+	if (configtype =3D=3D BASEBAND_CONFIG_PHY_REG) {
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			arraylen =3D RTL8812AEPHY_REG_1TARRAYLEN;
+			array_table =3D RTL8812AE_PHY_REG_ARRAY;
+		} else {
+			arraylen =3D RTL8821AEPHY_REG_1TARRAYLEN;
+			array_table =3D RTL8821AE_PHY_REG_ARRAY;
+		}
+
+		for (i =3D 0; i < arraylen; i +=3D 2) {
+			v1 =3D array_table[i];
+			v2 =3D array_table[i + 1];
+			if (v1 < 0xCDCDCDCD) {
+				_rtl8821ae_config_bb_reg(hw, v1, v2);
+				continue;
+			} else {/*This line is the start line of branch.*/
+				if (!_rtl8821ae_check_condition(hw, v1)) {
+					/*Discard the following (offset, data) pairs*/
+					READ_NEXT_PAIR(array_table, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD &&
+					       i < arraylen - 2) {
+						READ_NEXT_PAIR(array_table, v1,
+								v2, i);
+					}
+
+					i -=3D 2; /* prevent from for-loop +=3D 2*/
+				} else {/*Configure matched pairs and skip to end of if-else.*/
+					READ_NEXT_PAIR(array_table, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD &&
+					       i < arraylen - 2) {
+						_rtl8821ae_config_bb_reg(hw, v1,
+									 v2);
+						READ_NEXT_PAIR(array_table, v1,
+							       v2, i);
+					}
+
+					while (v2 !=3D 0xDEAD &&
+					       i < arraylen - 2) {
+						READ_NEXT_PAIR(array_table, v1,
+							       v2, i);
+					}
+				}
+			}
+		}
+	} else if (configtype =3D=3D BASEBAND_CONFIG_AGC_TAB) {
+		if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			arraylen =3D RTL8812AEAGCTAB_1TARRAYLEN;
+			array_table =3D RTL8812AE_AGC_TAB_ARRAY;
+		} else {
+			arraylen =3D RTL8821AEAGCTAB_1TARRAYLEN;
+			array_table =3D RTL8821AE_AGC_TAB_ARRAY;
+		}
+
+		for (i =3D 0; i < arraylen; i =3D i + 2) {
+			v1 =3D array_table[i];
+			v2 =3D array_table[i+1];
+			if (v1 < 0xCDCDCDCD) {
+				rtl_set_bbreg(hw, v1, MASKDWORD, v2);
+				udelay(1);
+				continue;
+			} else {/*This line is the start line of branch.*/
+				if (!_rtl8821ae_check_condition(hw, v1)) {
+					/*Discard the following (offset, data) pairs*/
+					READ_NEXT_PAIR(array_table, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD &&
+					       i < arraylen - 2) {
+						READ_NEXT_PAIR(array_table, v1,
+								v2, i);
+					}
+					i -=3D 2; /* prevent from for-loop +=3D 2*/
+				} else {/*Configure matched pairs and skip to end of if-else.*/
+					READ_NEXT_PAIR(array_table, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD &&
+					       i < arraylen - 2) {
+						rtl_set_bbreg(hw, v1, MASKDWORD,
+							      v2);
+						udelay(1);
+						READ_NEXT_PAIR(array_table, v1,
+							       v2, i);
+					}
+
+					while (v2 !=3D 0xDEAD &&
+						i < arraylen - 2) {
+						READ_NEXT_PAIR(array_table, v1,
+								v2, i);
+					}
+				}
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+					 "The agctab_array_table[0] is %x Rtl818EEPHY_REGArray[1] is %x\n=
",
+					  array_table[i],  array_table[i + 1]);
+			}
+		}
+	}
+	return true;
+}
+
+static u8 _rtl8821ae_get_rate_section_index(u32 regaddr)
+{
+	u8 index =3D 0;
+	regaddr &=3D 0xFFF;
+	if (regaddr >=3D 0xC20 && regaddr <=3D 0xC4C)
+		index =3D (u8)((regaddr - 0xC20) / 4);
+	else if (regaddr >=3D 0xE20 && regaddr <=3D 0xE4C)
+		index =3D (u8)((regaddr - 0xE20) / 4);
+	else
+		RT_ASSERT(!COMP_INIT,
+			  "Invalid RegAddr 0x%x\n", regaddr);
+	return index;
+}
+
+static void _rtl8821ae_store_tx_power_by_rate(struct ieee80211_hw *hw,
+					      u32 band, u32 rfpath,
+					      u32 txnum, u32 regaddr,
+					      u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 rate_section =3D _rtl8821ae_get_rate_section_index(regaddr);
+
+	if (band !=3D BAND_ON_2_4G && band !=3D BAND_ON_5G)
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid Band %d\n", band)=
;
+
+	if (rfpath >=3D MAX_RF_PATH)
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid RfPath %d\n", rfp=
ath);
+
+	if (txnum >=3D MAX_RF_PATH)
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_WARNING, "Invalid TxNum %d\n", txnu=
m);
+
+	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section] =3D=
 data;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "TxPwrByRateOffset[Band %d][RfPath %d][TxNum %d][RateSection %d] =3D=
 0x%x\n",
+		 band, rfpath, txnum, rate_section,
+		 rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][rate_section])=
;
+}
+
+static bool _rtl8821ae_phy_config_bb_with_pgheaderfile(struct ieee8021=
1_hw *hw,
+							u8 configtype)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	int i;
+	u32 *array;
+	u16 arraylen;
+	u32 v1, v2, v3, v4, v5, v6;
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+		arraylen =3D RTL8812AEPHY_REG_ARRAY_PGLEN;
+		array =3D RTL8812AE_PHY_REG_ARRAY_PG;
+	} else {
+		arraylen =3D RTL8821AEPHY_REG_ARRAY_PGLEN;
+		array =3D RTL8821AE_PHY_REG_ARRAY_PG;
+	}
+
+	if (configtype !=3D BASEBAND_CONFIG_PHY_REG) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "configtype !=3D BaseBand_Config_PHY_REG\n");
+		return true;
+	}
+	for (i =3D 0; i < arraylen; i +=3D 6) {
+		v1 =3D array[i];
+		v2 =3D array[i+1];
+		v3 =3D array[i+2];
+		v4 =3D array[i+3];
+		v5 =3D array[i+4];
+		v6 =3D array[i+5];
+
+		if (v1 < 0xCDCDCDCD) {
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE &&
+				(v4 =3D=3D 0xfe || v4 =3D=3D 0xffe)) {
+				msleep(50);
+				continue;
+			}
+
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+				if (v4 =3D=3D 0xfe)
+					msleep(50);
+				else if (v4 =3D=3D 0xfd)
+					mdelay(5);
+				else if (v4 =3D=3D 0xfc)
+					mdelay(1);
+				else if (v4 =3D=3D 0xfb)
+					udelay(50);
+				else if (v4 =3D=3D 0xfa)
+					udelay(5);
+				else if (v4 =3D=3D 0xf9)
+					udelay(1);
+			}
+			_rtl8821ae_store_tx_power_by_rate(hw, v1, v2, v3,
+							  v4, v5, v6);
+			continue;
+		} else {
+			 /*don't need the hw_body*/
+			if (!_rtl8821ae_check_condition(hw, v1)) {
+				i +=3D 2; /* skip the pair of expression*/
+				v1 =3D array[i];
+				v2 =3D array[i+1];
+				v3 =3D array[i+2];
+				while (v2 !=3D 0xDEAD) {
+					i +=3D 3;
+					v1 =3D array[i];
+					v2 =3D array[i+1];
+					v3 =3D array[i+2];
+				}
+			}
+		}
+	}
+
+	return true;
+}
+
+bool rtl8812ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					     enum radio_path rfpath)
+{
+	int i;
+	bool rtstatus =3D true;
+	u32 *radioa_array_table_a, *radioa_array_table_b;
+	u16 radioa_arraylen_a, radioa_arraylen_b;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 v1 =3D 0, v2 =3D 0;
+
+	radioa_arraylen_a =3D RTL8812AE_RADIOA_1TARRAYLEN;
+	radioa_array_table_a =3D RTL8812AE_RADIOA_ARRAY;
+	radioa_arraylen_b =3D RTL8812AE_RADIOB_1TARRAYLEN;
+	radioa_array_table_b =3D RTL8812AE_RADIOB_ARRAY;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Radio_A:RTL8821AE_RADIOA_ARRAY %d\n", radioa_arraylen_a);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Radio No %x\n", rfpath);
+	rtstatus =3D true;
+	switch (rfpath) {
+	case RF90_PATH_A:
+		for (i =3D 0; i < radioa_arraylen_a; i =3D i + 2) {
+			v1 =3D radioa_array_table_a[i];
+			v2 =3D radioa_array_table_a[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl8821ae_config_rf_radio_a(hw, v1, v2);
+				continue;
+			} else{/*This line is the start line of branch.*/
+				if (!_rtl8821ae_check_condition(hw, v1)) {
+					/*Discard the following (offset, data) pairs*/
+					READ_NEXT_PAIR(radioa_array_table_a, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD && i < radioa_arraylen_a-2)
+						READ_NEXT_PAIR(radioa_array_table_a, v1, v2, i);
+
+					i -=3D 2; /* prevent from for-loop +=3D 2*/
+				} else {/*Configure matched pairs and skip to end of if-else.*/
+					READ_NEXT_PAIR(radioa_array_table_a, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD && i < radioa_arraylen_a - 2) {
+						_rtl8821ae_config_rf_radio_a(hw, v1, v2);
+						READ_NEXT_PAIR(radioa_array_table_a, v1, v2, i);
+					}
+
+					while (v2 !=3D 0xDEAD && i < radioa_arraylen_a-2)
+						READ_NEXT_PAIR(radioa_array_table_a, v1, v2, i);
+
+				}
+			}
+		}
+		break;
+	case RF90_PATH_B:
+		for (i =3D 0; i < radioa_arraylen_b; i =3D i + 2) {
+			v1 =3D radioa_array_table_b[i];
+			v2 =3D radioa_array_table_b[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl8821ae_config_rf_radio_b(hw, v1, v2);
+				continue;
+			} else{/*This line is the start line of branch.*/
+				if (!_rtl8821ae_check_condition(hw, v1)) {
+					/*Discard the following (offset, data) pairs*/
+					READ_NEXT_PAIR(radioa_array_table_b, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD && i < radioa_arraylen_b-2)
+						READ_NEXT_PAIR(radioa_array_table_b, v1, v2, i);
+
+					i -=3D 2; /* prevent from for-loop +=3D 2*/
+				} else {/*Configure matched pairs and skip to end of if-else.*/
+					READ_NEXT_PAIR(radioa_array_table_b, v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD && i < radioa_arraylen_b-2) {
+						_rtl8821ae_config_rf_radio_b(hw, v1, v2);
+						READ_NEXT_PAIR(radioa_array_table_b, v1, v2, i);
+					}
+
+					while (v2 !=3D 0xDEAD && i < radioa_arraylen_b-2)
+						READ_NEXT_PAIR(radioa_array_table_b, v1, v2, i);
+				}
+			}
+		}
+		break;
+	case RF90_PATH_C:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	case RF90_PATH_D:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	}
+	return true;
+}
+
+bool rtl8821ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+						enum radio_path rfpath)
+{
+	#define READ_NEXT_RF_PAIR(v1, v2, i) \
+	do { \
+		i +=3D 2; \
+		v1 =3D radioa_array_table[i]; \
+		v2 =3D radioa_array_table[i+1]; \
+	} \
+	while (0)
+
+	int i;
+	bool rtstatus =3D true;
+	u32 *radioa_array_table;
+	u16 radioa_arraylen;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	/* struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw)); */
+	u32 v1 =3D 0, v2 =3D 0;
+
+	radioa_arraylen =3D RTL8821AE_RADIOA_1TARRAYLEN;
+	radioa_array_table =3D RTL8821AE_RADIOA_ARRAY;
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Radio_A:RTL8821AE_RADIOA_ARRAY %d\n", radioa_arraylen);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Radio No %x\n", rfpath);
+	rtstatus =3D true;
+	switch (rfpath) {
+	case RF90_PATH_A:
+		for (i =3D 0; i < radioa_arraylen; i =3D i + 2) {
+			v1 =3D radioa_array_table[i];
+			v2 =3D radioa_array_table[i+1];
+			if (v1 < 0xcdcdcdcd)
+				_rtl8821ae_config_rf_radio_a(hw, v1, v2);
+			else{/*This line is the start line of branch.*/
+				if (!_rtl8821ae_check_condition(hw, v1)) {
+					/*Discard the following (offset, data) pairs*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+						v2 !=3D 0xCDEF &&
+						v2 !=3D 0xCDCD && i < radioa_arraylen - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+
+					i -=3D 2; /* prevent from for-loop +=3D 2*/
+				} else {/*Configure matched pairs and skip to end of if-else.*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 !=3D 0xDEAD &&
+					       v2 !=3D 0xCDEF &&
+					       v2 !=3D 0xCDCD && i < radioa_arraylen - 2) {
+						_rtl8821ae_config_rf_radio_a(hw, v1, v2);
+						READ_NEXT_RF_PAIR(v1, v2, i);
+					}
+
+					while (v2 !=3D 0xDEAD && i < radioa_arraylen - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+				}
+			}
+		}
+		break;
+
+	case RF90_PATH_B:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	case RF90_PATH_C:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	case RF90_PATH_D:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	}
+	return true;
+}
+
+void rtl8821ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	rtlphy->default_initialgain[0] =3D
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[1] =3D
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[2] =3D
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[3] =3D
+	    (u8)rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Default initial gain (c50=3D0x%x, c58=3D0x%x, c60=3D0x%x, c68=3D0x=
%x\n",
+		  rtlphy->default_initialgain[0],
+		  rtlphy->default_initialgain[1],
+		  rtlphy->default_initialgain[2],
+		  rtlphy->default_initialgain[3]);
+
+	rtlphy->framesync =3D (u8)rtl_get_bbreg(hw,
+					       ROFDM0_RXDETECTOR3, MASKBYTE0);
+	rtlphy->framesync_c34 =3D rtl_get_bbreg(hw,
+					      ROFDM0_RXDETECTOR2, MASKDWORD);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+		 "Default framesync (0x%x) =3D 0x%x\n",
+		  ROFDM0_RXDETECTOR3, rtlphy->framesync);
+}
+
+static void phy_init_bb_rf_register_definition(struct ieee80211_hw *hw=
)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfs =3D RFPGA0_XAB_RFINTERFACESW;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfs =3D RFPGA0_XAB_RFINTERFACESW;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfo =3D RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfo =3D RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfe =3D RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfe =3D RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf3wire_offset =3D RA_LSSIWRITE_8821A=
;
+	rtlphy->phyreg_def[RF90_PATH_B].rf3wire_offset =3D RB_LSSIWRITE_8821A=
;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfhssi_para2 =3D RHSSIREAD_8821AE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfhssi_para2 =3D RHSSIREAD_8821AE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rb =3D RA_SIREAD_8821A;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rb =3D RB_SIREAD_8821A;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi =3D RA_PIREAD_8821A;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi =3D RB_PIREAD_8821A;
+}
+
+void rtl8821ae_phy_get_txpower_level(struct ieee80211_hw *hw, long *po=
werlevel)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 txpwr_level;
+	long txpwr_dbm;
+
+	txpwr_level =3D rtlphy->cur_cck_txpwridx;
+	txpwr_dbm =3D _rtl8821ae_phy_txpwr_idx_to_dbm(hw,
+						 WIRELESS_MODE_B, txpwr_level);
+	txpwr_level =3D rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl8821ae_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =3D
+		    _rtl8821ae_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
+						 txpwr_level);
+	txpwr_level =3D rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl8821ae_phy_txpwr_idx_to_dbm(hw,
+					 WIRELESS_MODE_N_24G,
+					 txpwr_level) > txpwr_dbm)
+		txpwr_dbm =3D
+		    _rtl8821ae_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
+						 txpwr_level);
+	*powerlevel =3D txpwr_dbm;
+}
+
+static bool _rtl8821ae_phy_get_chnl_index(u8 channel, u8 *chnl_index)
+{
+	u8 channel_5g[CHANNEL_MAX_NUMBER_5G] =3D {
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62,
+		64, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118,
+		120, 122, 124, 126, 128, 130, 132, 134, 136, 138, 140,
+		142, 144, 149, 151, 153, 155, 157, 159, 161, 163, 165,
+		167, 168, 169, 171, 173, 175, 177
+	};
+	u8 i =3D 0;
+	bool in_24g =3D true;
+
+	if (channel <=3D 14) {
+		in_24g =3D true;
+		*chnl_index =3D channel - 1;
+	} else {
+		in_24g =3D false;
+
+		for (i =3D 0; i < CHANNEL_MAX_NUMBER_5G; ++i) {
+			if (channel_5g[i] =3D=3D channel) {
+				*chnl_index =3D i;
+				return in_24g;
+			}
+		}
+	}
+	return in_24g;
+}
+
+static char _rtl8821ae_phy_get_ratesection_intxpower_byrate(u8 path, u=
8 rate)
+{
+	char rate_section =3D 0;
+	switch (rate) {
+	case DESC_RATE1M:
+	case DESC_RATE2M:
+	case DESC_RATE5_5M:
+	case DESC_RATE11M:
+		rate_section =3D 0;
+		break;
+	case DESC_RATE6M:
+	case DESC_RATE9M:
+	case DESC_RATE12M:
+	case DESC_RATE18M:
+		rate_section =3D 1;
+		break;
+	case DESC_RATE24M:
+	case DESC_RATE36M:
+	case DESC_RATE48M:
+	case DESC_RATE54M:
+		rate_section =3D 2;
+		break;
+	case DESC_RATEMCS0:
+	case DESC_RATEMCS1:
+	case DESC_RATEMCS2:
+	case DESC_RATEMCS3:
+		rate_section =3D 3;
+		break;
+	case DESC_RATEMCS4:
+	case DESC_RATEMCS5:
+	case DESC_RATEMCS6:
+	case DESC_RATEMCS7:
+		rate_section =3D 4;
+		break;
+	case DESC_RATEMCS8:
+	case DESC_RATEMCS9:
+	case DESC_RATEMCS10:
+	case DESC_RATEMCS11:
+		rate_section =3D 5;
+		break;
+	case DESC_RATEMCS12:
+	case DESC_RATEMCS13:
+	case DESC_RATEMCS14:
+	case DESC_RATEMCS15:
+		rate_section =3D 6;
+		break;
+	case DESC_RATEVHT1SS_MCS0:
+	case DESC_RATEVHT1SS_MCS1:
+	case DESC_RATEVHT1SS_MCS2:
+	case DESC_RATEVHT1SS_MCS3:
+		rate_section =3D 7;
+		break;
+	case DESC_RATEVHT1SS_MCS4:
+	case DESC_RATEVHT1SS_MCS5:
+	case DESC_RATEVHT1SS_MCS6:
+	case DESC_RATEVHT1SS_MCS7:
+		rate_section =3D 8;
+		break;
+	case DESC_RATEVHT1SS_MCS8:
+	case DESC_RATEVHT1SS_MCS9:
+	case DESC_RATEVHT2SS_MCS0:
+	case DESC_RATEVHT2SS_MCS1:
+		rate_section =3D 9;
+		break;
+	case DESC_RATEVHT2SS_MCS2:
+	case DESC_RATEVHT2SS_MCS3:
+	case DESC_RATEVHT2SS_MCS4:
+	case DESC_RATEVHT2SS_MCS5:
+		rate_section =3D 10;
+		break;
+	case DESC_RATEVHT2SS_MCS6:
+	case DESC_RATEVHT2SS_MCS7:
+	case DESC_RATEVHT2SS_MCS8:
+	case DESC_RATEVHT2SS_MCS9:
+		rate_section =3D 11;
+		break;
+	default:
+		RT_ASSERT(true, "Rate_Section is Illegal\n");
+		break;
+	}
+
+	return rate_section;
+}
+
+static char _rtl8812ae_phy_get_world_wide_limit(char  *limit_table)
+{
+	char min =3D limit_table[0];
+	u8 i =3D 0;
+
+	for (i =3D 0; i < MAX_REGULATION_NUM; ++i) {
+		if (limit_table[i] < min)
+			min =3D limit_table[i];
+	}
+	return min;
+}
+
+static char _rtl8812ae_phy_get_txpower_limit(struct ieee80211_hw *hw,
+					     u8 band,
+					     enum ht_channel_width bandwidth,
+					     enum radio_path rf_path,
+					     u8 rate, u8 channel)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtlpriv);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	short band_temp =3D -1, regulation =3D -1, bandwidth_temp =3D -1,
+		 rate_section =3D -1, channel_temp =3D -1;
+	u16 bd, regu, bdwidth, sec, chnl;
+	char power_limit =3D MAX_POWER_INDEX;
+
+	if (rtlefuse->eeprom_regulatory =3D=3D 2)
+		return MAX_POWER_INDEX;
+
+	regulation =3D TXPWR_LMT_WW;
+
+	if (band =3D=3D BAND_ON_2_4G)
+		band_temp =3D 0;
+	else if (band =3D=3D BAND_ON_5G)
+		band_temp =3D 1;
+
+	if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20)
+		bandwidth_temp =3D 0;
+	else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20_40)
+		bandwidth_temp =3D 1;
+	else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_80)
+		bandwidth_temp =3D 2;
+
+	switch (rate) {
+	case DESC_RATE1M:
+	case DESC_RATE2M:
+	case DESC_RATE5_5M:
+	case DESC_RATE11M:
+		rate_section =3D 0;
+		break;
+	case DESC_RATE6M:
+	case DESC_RATE9M:
+	case DESC_RATE12M:
+	case DESC_RATE18M:
+	case DESC_RATE24M:
+	case DESC_RATE36M:
+	case DESC_RATE48M:
+	case DESC_RATE54M:
+		rate_section =3D 1;
+		break;
+	case DESC_RATEMCS0:
+	case DESC_RATEMCS1:
+	case DESC_RATEMCS2:
+	case DESC_RATEMCS3:
+	case DESC_RATEMCS4:
+	case DESC_RATEMCS5:
+	case DESC_RATEMCS6:
+	case DESC_RATEMCS7:
+		rate_section =3D 2;
+		break;
+	case DESC_RATEMCS8:
+	case DESC_RATEMCS9:
+	case DESC_RATEMCS10:
+	case DESC_RATEMCS11:
+	case DESC_RATEMCS12:
+	case DESC_RATEMCS13:
+	case DESC_RATEMCS14:
+	case DESC_RATEMCS15:
+		rate_section =3D 3;
+		break;
+	case DESC_RATEVHT1SS_MCS0:
+	case DESC_RATEVHT1SS_MCS1:
+	case DESC_RATEVHT1SS_MCS2:
+	case DESC_RATEVHT1SS_MCS3:
+	case DESC_RATEVHT1SS_MCS4:
+	case DESC_RATEVHT1SS_MCS5:
+	case DESC_RATEVHT1SS_MCS6:
+	case DESC_RATEVHT1SS_MCS7:
+	case DESC_RATEVHT1SS_MCS8:
+	case DESC_RATEVHT1SS_MCS9:
+		rate_section =3D 4;
+		break;
+	case DESC_RATEVHT2SS_MCS0:
+	case DESC_RATEVHT2SS_MCS1:
+	case DESC_RATEVHT2SS_MCS2:
+	case DESC_RATEVHT2SS_MCS3:
+	case DESC_RATEVHT2SS_MCS4:
+	case DESC_RATEVHT2SS_MCS5:
+	case DESC_RATEVHT2SS_MCS6:
+	case DESC_RATEVHT2SS_MCS7:
+	case DESC_RATEVHT2SS_MCS8:
+	case DESC_RATEVHT2SS_MCS9:
+		rate_section =3D 5;
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			"Wrong rate 0x%x\n", rate);
+		break;
+	}
+
+	if (band_temp =3D=3D BAND_ON_5G  && rate_section =3D=3D 0)
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Wrong rate 0x%x: No CCK in 5G Band\n", rate);
+
+	/*workaround for wrong index combination to obtain tx power limit,
+	  OFDM only exists in BW 20M*/
+	if (rate_section =3D=3D 1)
+		bandwidth_temp =3D 0;
+
+	/*workaround for wrong index combination to obtain tx power limit,
+	 *HT on 80M will reference to HT on 40M
+	 */
+	if ((rate_section =3D=3D 2 || rate_section =3D=3D 3) && band =3D=3D B=
AND_ON_5G &&
+	    bandwidth_temp =3D=3D 2)
+		bandwidth_temp =3D 1;
+
+	if (band =3D=3D BAND_ON_2_4G)
+		channel_temp =3D _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(hw,
+		BAND_ON_2_4G, channel);
+	else if (band =3D=3D BAND_ON_5G)
+		channel_temp =3D _rtl8812ae_phy_get_chnl_idx_of_txpwr_lmt(hw,
+		BAND_ON_5G, channel);
+	else if (band =3D=3D BAND_ON_BOTH)
+		;/* BAND_ON_BOTH don't care temporarily */
+
+	if (band_temp =3D=3D -1 || regulation =3D=3D -1 || bandwidth_temp =3D=
=3D -1 ||
+		rate_section =3D=3D -1 || channel_temp =3D=3D -1) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Wrong index value to access power limit table [band %d][regulatio=
n %d][bandwidth %d][rf_path %d][rate_section %d][chnl %d]\n",
+			 band_temp, regulation, bandwidth_temp, rf_path,
+			 rate_section, channel_temp);
+		return MAX_POWER_INDEX;
+	}
+
+	bd =3D band_temp;
+	regu =3D regulation;
+	bdwidth =3D bandwidth_temp;
+	sec =3D rate_section;
+	chnl =3D channel_temp;
+
+	if (band =3D=3D BAND_ON_2_4G) {
+		char limits[10] =3D {0};
+		u8 i;
+
+		for (i =3D 0; i < 4; ++i)
+			limits[i] =3D rtlphy->txpwr_limit_2_4g[i][bdwidth]
+			[sec][chnl][rf_path];
+
+		power_limit =3D (regulation =3D=3D TXPWR_LMT_WW) ?
+			_rtl8812ae_phy_get_world_wide_limit(limits) :
+			rtlphy->txpwr_limit_2_4g[regu][bdwidth]
+					[sec][chnl][rf_path];
+	} else if (band =3D=3D BAND_ON_5G) {
+		char limits[10] =3D {0};
+		u8 i;
+
+		for (i =3D 0; i < MAX_REGULATION_NUM; ++i)
+			limits[i] =3D rtlphy->txpwr_limit_5g[i][bdwidth]
+			[sec][chnl][rf_path];
+
+		power_limit =3D (regulation =3D=3D TXPWR_LMT_WW) ?
+			_rtl8812ae_phy_get_world_wide_limit(limits) :
+			rtlphy->txpwr_limit_5g[regu][chnl]
+			[sec][chnl][rf_path];
+	} else {
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+			 "No power limit table of the specified band\n");
+	}
+	return power_limit;
+}
+
+static char _rtl8821ae_phy_get_txpower_by_rate(struct ieee80211_hw *hw=
,
+					u8 band, u8 path, u8 rate)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 shift =3D 0, rate_section, tx_num;
+	char tx_pwr_diff =3D 0;
+	char limit =3D 0;
+
+	rate_section =3D _rtl8821ae_phy_get_ratesection_intxpower_byrate(path=
, rate);
+	tx_num =3D RF_TX_NUM_NONIMPLEMENT;
+
+	if (tx_num =3D=3D RF_TX_NUM_NONIMPLEMENT) {
+		if ((rate >=3D DESC_RATEMCS8 && rate <=3D DESC_RATEMCS15) ||
+			(rate >=3D DESC_RATEVHT2SS_MCS2 && rate <=3D DESC_RATEVHT2SS_MCS9))
+			tx_num =3D RF_2TX;
+		else
+			tx_num =3D RF_1TX;
+	}
+
+	switch (rate) {
+	case DESC_RATE1M:
+	case DESC_RATE6M:
+	case DESC_RATE24M:
+	case DESC_RATEMCS0:
+	case DESC_RATEMCS4:
+	case DESC_RATEMCS8:
+	case DESC_RATEMCS12:
+	case DESC_RATEVHT1SS_MCS0:
+	case DESC_RATEVHT1SS_MCS4:
+	case DESC_RATEVHT1SS_MCS8:
+	case DESC_RATEVHT2SS_MCS2:
+	case DESC_RATEVHT2SS_MCS6:
+		shift =3D 0;
+		break;
+	case DESC_RATE2M:
+	case DESC_RATE9M:
+	case DESC_RATE36M:
+	case DESC_RATEMCS1:
+	case DESC_RATEMCS5:
+	case DESC_RATEMCS9:
+	case DESC_RATEMCS13:
+	case DESC_RATEVHT1SS_MCS1:
+	case DESC_RATEVHT1SS_MCS5:
+	case DESC_RATEVHT1SS_MCS9:
+	case DESC_RATEVHT2SS_MCS3:
+	case DESC_RATEVHT2SS_MCS7:
+		shift =3D 8;
+		break;
+	case DESC_RATE5_5M:
+	case DESC_RATE12M:
+	case DESC_RATE48M:
+	case DESC_RATEMCS2:
+	case DESC_RATEMCS6:
+	case DESC_RATEMCS10:
+	case DESC_RATEMCS14:
+	case DESC_RATEVHT1SS_MCS2:
+	case DESC_RATEVHT1SS_MCS6:
+	case DESC_RATEVHT2SS_MCS0:
+	case DESC_RATEVHT2SS_MCS4:
+	case DESC_RATEVHT2SS_MCS8:
+		shift =3D 16;
+		break;
+	case DESC_RATE11M:
+	case DESC_RATE18M:
+	case DESC_RATE54M:
+	case DESC_RATEMCS3:
+	case DESC_RATEMCS7:
+	case DESC_RATEMCS11:
+	case DESC_RATEMCS15:
+	case DESC_RATEVHT1SS_MCS3:
+	case DESC_RATEVHT1SS_MCS7:
+	case DESC_RATEVHT2SS_MCS1:
+	case DESC_RATEVHT2SS_MCS5:
+	case DESC_RATEVHT2SS_MCS9:
+		shift =3D 24;
+		break;
+	default:
+		RT_ASSERT(true, "Rate_Section is Illegal\n");
+		break;
+	}
+
+	tx_pwr_diff =3D (u8)(rtlphy->tx_power_by_rate_offset[band][path]
+		[tx_num][rate_section] >> shift) & 0xff;
+
+	/* RegEnableTxPowerLimit =3D=3D 1 for 8812a & 8821a */
+	if (rtlpriv->efuse.eeprom_regulatory !=3D 2) {
+		limit =3D _rtl8812ae_phy_get_txpower_limit(hw, band,
+			rtlphy->current_chan_bw, path, rate,
+			rtlphy->current_channel);
+
+		if (rate =3D=3D DESC_RATEVHT1SS_MCS8 || rate =3D=3D DESC_RATEVHT1SS_=
MCS9  ||
+			 rate =3D=3D DESC_RATEVHT2SS_MCS8 || rate =3D=3D DESC_RATEVHT2SS_MC=
S9) {
+			if (limit < 0) {
+				if (tx_pwr_diff < (-limit))
+					tx_pwr_diff =3D -limit;
+			}
+		} else {
+			if (limit < 0)
+				tx_pwr_diff =3D limit;
+			else
+				tx_pwr_diff =3D tx_pwr_diff > limit ? limit : tx_pwr_diff;
+		}
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			"Maximum power by rate %d, final power by rate %d\n",
+			limit, tx_pwr_diff);
+	}
+
+	return	tx_pwr_diff;
+}
+
+static u8 _rtl8821ae_get_txpower_index(struct ieee80211_hw *hw, u8 pat=
h,
+					u8 rate, u8 bandwidth, u8 channel)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	u8 index =3D (channel - 1);
+	u8 txpower =3D 0;
+	bool in_24g =3D false;
+	char powerdiff_byrate =3D 0;
+
+	if (((rtlhal->current_bandtype =3D=3D BAND_ON_2_4G) &&
+	    (channel > 14 || channel < 1)) ||
+	    ((rtlhal->current_bandtype =3D=3D BAND_ON_5G) && (channel <=3D 14=
))) {
+		index =3D 0;
+		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+			"Illegal channel!!\n");
+	}
+
+	in_24g =3D _rtl8821ae_phy_get_chnl_index(channel, &index);
+	if (in_24g) {
+		if (RTL8821AE_RX_HAL_IS_CCK_RATE(rate))
+			txpower =3D rtlefuse->txpwrlevel_cck[path][index];
+		else if (DESC_RATE6M <=3D rate)
+			txpower =3D rtlefuse->txpwrlevel_ht40_1s[path][index];
+		else
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "invalid rate\n");
+
+		if (DESC_RATE6M <=3D rate && rate <=3D DESC_RATE54M &&
+		    !RTL8821AE_RX_HAL_IS_CCK_RATE(rate))
+			txpower +=3D rtlefuse->txpwr_legacyhtdiff[path][TX_1S];
+
+		if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20) {
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+				(DESC_RATEVHT1SS_MCS0 <=3D rate && rate <=3D DESC_RATEVHT2SS_MCS9)=
)
+				txpower +=3D rtlefuse->txpwr_ht20diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+				(DESC_RATEVHT2SS_MCS0 <=3D rate && rate <=3D DESC_RATEVHT2SS_MCS9)=
)
+				txpower +=3D rtlefuse->txpwr_ht20diff[path][TX_2S];
+		} else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20_40) {
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+				(DESC_RATEVHT1SS_MCS0 <=3D rate && rate <=3D DESC_RATEVHT2SS_MCS9)=
)
+				txpower +=3D rtlefuse->txpwr_ht40diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+				(DESC_RATEVHT2SS_MCS0 <=3D rate && rate <=3D DESC_RATEVHT2SS_MCS9)=
)
+				txpower +=3D rtlefuse->txpwr_ht40diff[path][TX_2S];
+		} else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_80) {
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT1SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_ht40diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT2SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_ht40diff[path][TX_2S];
+		}
+	} else {
+		if (DESC_RATE6M <=3D rate)
+			txpower =3D rtlefuse->txpwr_5g_bw40base[path][index];
+		else
+			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_WARNING,
+				 "INVALID Rate.\n");
+
+		if (DESC_RATE6M <=3D rate && rate <=3D DESC_RATE54M &&
+		    !RTL8821AE_RX_HAL_IS_CCK_RATE(rate))
+			txpower +=3D rtlefuse->txpwr_5g_ofdmdiff[path][TX_1S];
+
+		if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20) {
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT1SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_5g_bw20diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT2SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_5g_bw20diff[path][TX_2S];
+		} else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_20_40) {
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT1SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_5g_bw40diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT2SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower +=3D rtlefuse->txpwr_5g_bw40diff[path][TX_2S];
+		} else if (bandwidth =3D=3D HT_CHANNEL_WIDTH_80) {
+			u8 channel_5g_80m[CHANNEL_MAX_NUMBER_5G_80M] =3D {
+				42, 58, 106, 122, 138, 155, 171
+			};
+			u8 i;
+
+			for (i =3D 0; i < sizeof(channel_5g_80m) / sizeof(u8); ++i)
+				if (channel_5g_80m[i] =3D=3D channel)
+					index =3D i;
+
+			if ((DESC_RATEMCS0 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT1SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower =3D rtlefuse->txpwr_5g_bw80base[path][index]
+					+ rtlefuse->txpwr_5g_bw80diff[path][TX_1S];
+			if ((DESC_RATEMCS8 <=3D rate && rate <=3D DESC_RATEMCS15) ||
+			    (DESC_RATEVHT2SS_MCS0 <=3D rate &&
+			     rate <=3D DESC_RATEVHT2SS_MCS9))
+				txpower =3D rtlefuse->txpwr_5g_bw80base[path][index]
+					+ rtlefuse->txpwr_5g_bw80diff[path][TX_1S]
+					+ rtlefuse->txpwr_5g_bw80diff[path][TX_2S];
+		    }
+	}
+	if (rtlefuse->eeprom_regulatory !=3D 2)
+		powerdiff_byrate =3D
+		  _rtl8821ae_phy_get_txpower_by_rate(hw, (u8)(!in_24g),
+						     path, rate);
+
+	if (rate =3D=3D DESC_RATEVHT1SS_MCS8 || rate =3D=3D DESC_RATEVHT1SS_M=
CS9 ||
+	    rate =3D=3D DESC_RATEVHT2SS_MCS8 || rate =3D=3D DESC_RATEVHT2SS_M=
CS9)
+		txpower -=3D powerdiff_byrate;
+	else
+		txpower +=3D powerdiff_byrate;
+
+	if (rate > DESC_RATE11M)
+		txpower +=3D rtlpriv->dm.remnant_ofdm_swing_idx[path];
+	else
+		txpower +=3D rtlpriv->dm.remnant_cck_idx;
+
+	if (txpower > MAX_POWER_INDEX)
+		txpower =3D MAX_POWER_INDEX;
+
+	return txpower;
+}
+
+static void _rtl8821ae_phy_set_txpower_index(struct ieee80211_hw *hw,
+					     u8 power_index, u8 path, u8 rate)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (path =3D=3D RF90_PATH_A) {
+		switch (rate) {
+		case DESC_RATE1M:
+			rtl_set_bbreg(hw, RTXAGC_A_CCK11_CCK1,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE2M:
+			rtl_set_bbreg(hw, RTXAGC_A_CCK11_CCK1,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE5_5M:
+			rtl_set_bbreg(hw, RTXAGC_A_CCK11_CCK1,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE11M:
+			rtl_set_bbreg(hw, RTXAGC_A_CCK11_CCK1,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATE6M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM18_OFDM6,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE9M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM18_OFDM6,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE12M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM18_OFDM6,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE18M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM18_OFDM6,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATE24M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM54_OFDM24,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE36M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM54_OFDM24,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE48M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM54_OFDM24,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE54M:
+			rtl_set_bbreg(hw, RTXAGC_A_OFDM54_OFDM24,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS0:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS1:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS2:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS3:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS4:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS5:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS6:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS7:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS8:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS9:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS10:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS11:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS12:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS13:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS14:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS15:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS0:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS1:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS2:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS3:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS4:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS5:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS6:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS7:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS8:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS9:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS0:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS1:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS2:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS3:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS4:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS5:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS6:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS7:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS8:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS9:
+			rtl_set_bbreg(hw, RTXAGC_A_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE3, power_index);
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+				"Invalid Rate!!\n");
+			break;
+		}
+	} else if (path =3D=3D RF90_PATH_B) {
+		switch (rate) {
+		case DESC_RATE1M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_CCK1,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE2M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_CCK1,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE5_5M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_CCK1,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE11M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_CCK1,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATE6M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM18_OFDM6,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE9M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM18_OFDM6,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE12M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM18_OFDM6,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE18M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM18_OFDM6,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATE24M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM54_OFDM24,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATE36M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM54_OFDM24,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATE48M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM54_OFDM24,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATE54M:
+			rtl_set_bbreg(hw, RTXAGC_B_OFDM54_OFDM24,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS0:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS1:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS2:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS3:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS4:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS5:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS6:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS7:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS8:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS9:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS10:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS11:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEMCS12:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEMCS13:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEMCS14:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEMCS15:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS0:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS1:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS2:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS3:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX3_NSS1INDEX0,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS4:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS5:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS6:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS7:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS1INDEX7_NSS1INDEX4,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS8:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT1SS_MCS9:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS0:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS1:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX1_NSS1INDEX8,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS2:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS3:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS4:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS5:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX5_NSS2INDEX2,
+				      MASKBYTE3, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS6:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE0, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS7:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE1, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS8:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE2, power_index);
+			break;
+		case DESC_RATEVHT2SS_MCS9:
+			rtl_set_bbreg(hw, RTXAGC_B_NSS2INDEX9_NSS2INDEX6,
+				      MASKBYTE3, power_index);
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+				 "Invalid Rate!!\n");
+			break;
+		}
+	} else {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "Invalid RFPath!!\n");
+	}
+}
+
+static void _rtl8821ae_phy_set_txpower_level_by_path(struct ieee80211_=
hw *hw,
+						     u8 *array, u8 path,
+						     u8 channel, u8 size)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 i;
+	u8 power_index;
+
+	for (i =3D 0; i < size; i++) {
+		power_index =3D
+		  _rtl8821ae_get_txpower_index(hw, path, array[i],
+					       rtlphy->current_chan_bw,
+					       channel);
+		_rtl8821ae_phy_set_txpower_index(hw, power_index, path,
+						 array[i]);
+	}
+}
+
+static void _rtl8821ae_phy_txpower_training_by_path(struct ieee80211_h=
w *hw,
+						    u8 bw, u8 channel, u8 path)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	u8 i;
+	u32 power_level, data, offset;
+
+	if (path >=3D rtlphy->num_total_rfpath)
+		return;
+
+	data =3D 0;
+	if (path =3D=3D RF90_PATH_A) {
+		power_level =3D
+			_rtl8821ae_get_txpower_index(hw, RF90_PATH_A,
+			DESC_RATEMCS7, bw, channel);
+		offset =3D  RA_TXPWRTRAING;
+	} else {
+		power_level =3D
+			_rtl8821ae_get_txpower_index(hw, RF90_PATH_B,
+			DESC_RATEMCS7, bw, channel);
+		offset =3D  RB_TXPWRTRAING;
+	}
+
+	for (i =3D 0; i < 3; i++) {
+		if (i =3D=3D 0)
+			power_level =3D power_level - 10;
+		else if (i =3D=3D 1)
+			power_level =3D power_level - 8;
+		else
+			power_level =3D power_level - 6;
+
+		data |=3D (((power_level > 2) ? (power_level) : 2) << (i * 8));
+	}
+	rtl_set_bbreg(hw, offset, 0xffffff, data);
+}
+
+void rtl8821ae_phy_set_txpower_level_by_path(struct ieee80211_hw *hw,
+					     u8 channel, u8 path)
+{
+	/* struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw)); */
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 cck_rates[]  =3D {DESC_RATE1M, DESC_RATE2M, DESC_RATE5_5M,
+			      DESC_RATE11M};
+	u8 sizes_of_cck_retes =3D 4;
+	u8 ofdm_rates[]  =3D {DESC_RATE6M, DESC_RATE9M, DESC_RATE12M,
+				DESC_RATE18M, DESC_RATE24M, DESC_RATE36M,
+				DESC_RATE48M, DESC_RATE54M};
+	u8 sizes_of_ofdm_retes =3D 8;
+	u8 ht_rates_1t[]  =3D {DESC_RATEMCS0, DESC_RATEMCS1, DESC_RATEMCS2,
+				DESC_RATEMCS3, DESC_RATEMCS4, DESC_RATEMCS5,
+				DESC_RATEMCS6, DESC_RATEMCS7};
+	u8 sizes_of_ht_retes_1t =3D 8;
+	u8 ht_rates_2t[]  =3D {DESC_RATEMCS8, DESC_RATEMCS9,
+				DESC_RATEMCS10, DESC_RATEMCS11,
+				DESC_RATEMCS12, DESC_RATEMCS13,
+				DESC_RATEMCS14, DESC_RATEMCS15};
+	u8 sizes_of_ht_retes_2t =3D 8;
+	u8 vht_rates_1t[]  =3D {DESC_RATEVHT1SS_MCS0, DESC_RATEVHT1SS_MCS1,
+				DESC_RATEVHT1SS_MCS2, DESC_RATEVHT1SS_MCS3,
+				DESC_RATEVHT1SS_MCS4, DESC_RATEVHT1SS_MCS5,
+				DESC_RATEVHT1SS_MCS6, DESC_RATEVHT1SS_MCS7,
+			     DESC_RATEVHT1SS_MCS8, DESC_RATEVHT1SS_MCS9};
+	u8 vht_rates_2t[]  =3D {DESC_RATEVHT2SS_MCS0, DESC_RATEVHT2SS_MCS1,
+				DESC_RATEVHT2SS_MCS2, DESC_RATEVHT2SS_MCS3,
+				DESC_RATEVHT2SS_MCS4, DESC_RATEVHT2SS_MCS5,
+				DESC_RATEVHT2SS_MCS6, DESC_RATEVHT2SS_MCS7,
+				DESC_RATEVHT2SS_MCS8, DESC_RATEVHT2SS_MCS9};
+	u8 sizes_of_vht_retes =3D 10;
+
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_2_4G)
+		_rtl8821ae_phy_set_txpower_level_by_path(hw, cck_rates, path, channe=
l,
+							 sizes_of_cck_retes);
+
+	_rtl8821ae_phy_set_txpower_level_by_path(hw, ofdm_rates, path, channe=
l,
+						 sizes_of_ofdm_retes);
+	_rtl8821ae_phy_set_txpower_level_by_path(hw, ht_rates_1t, path, chann=
el,
+						 sizes_of_ht_retes_1t);
+	_rtl8821ae_phy_set_txpower_level_by_path(hw, vht_rates_1t, path, chan=
nel,
+						 sizes_of_vht_retes);
+
+	if (rtlphy->num_total_rfpath >=3D 2) {
+		_rtl8821ae_phy_set_txpower_level_by_path(hw, ht_rates_2t, path,
+							 channel,
+							 sizes_of_ht_retes_2t);
+		_rtl8821ae_phy_set_txpower_level_by_path(hw, vht_rates_2t, path,
+							 channel,
+							 sizes_of_vht_retes);
+	}
+
+	_rtl8821ae_phy_txpower_training_by_path(hw, rtlphy->current_chan_bw,
+						channel, path);
+}
+
+/*just in case, write txpower in DW, to reduce time*/
+void rtl8821ae_phy_set_txpower_level(struct ieee80211_hw *hw, u8 chann=
el)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 path =3D 0;
+
+	for (path =3D RF90_PATH_A; path < rtlphy->num_total_rfpath; ++path)
+		rtl8821ae_phy_set_txpower_level_by_path(hw, channel, path);
+}
+
+static long _rtl8821ae_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					    enum wireless_mode wirelessmode,
+					    u8 txpwridx)
+{
+	long offset;
+	long pwrout_dbm;
+
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		offset =3D -7;
+		break;
+	case WIRELESS_MODE_G:
+	case WIRELESS_MODE_N_24G:
+		offset =3D -8;
+		break;
+	default:
+		offset =3D -8;
+		break;
+	}
+	pwrout_dbm =3D txpwridx / 2 + offset;
+	return pwrout_dbm;
+}
+
+void rtl8821ae_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 o=
peration)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	enum io_type iotype =3D IO_CMD_PAUSE_BAND0_DM_BY_SCAN;
+
+	if (!is_hal_stop(rtlhal)) {
+		switch (operation) {
+		case SCAN_OPT_BACKUP_BAND0:
+			iotype =3D IO_CMD_PAUSE_BAND0_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+
+			break;
+		case SCAN_OPT_BACKUP_BAND1:
+			iotype =3D IO_CMD_PAUSE_BAND1_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+
+			break;
+		case SCAN_OPT_RESTORE:
+			iotype =3D IO_CMD_RESUME_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "Unknown Scan Backup operation.\n");
+			break;
+		}
+	}
+}
+
+static void _rtl8821ae_phy_set_reg_bw(struct rtl_priv *rtlpriv, u8 bw)
+{
+	u16 reg_rf_mode_bw, tmp =3D 0;
+
+	reg_rf_mode_bw =3D rtl_read_word(rtlpriv, REG_TRXPTCL_CTL);
+	switch (bw) {
+	case HT_CHANNEL_WIDTH_20:
+		rtl_write_word(rtlpriv, REG_TRXPTCL_CTL, reg_rf_mode_bw & 0xFE7F);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		tmp =3D reg_rf_mode_bw | BIT(7);
+		rtl_write_word(rtlpriv, REG_TRXPTCL_CTL, tmp & 0xFEFF);
+		break;
+	case HT_CHANNEL_WIDTH_80:
+		tmp =3D reg_rf_mode_bw | BIT(8);
+		rtl_write_word(rtlpriv, REG_TRXPTCL_CTL, tmp & 0xFF7F);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, "unknown Bandwidth: 0x%x\n"=
, bw);
+		break;
+	}
+}
+
+static u8 _rtl8821ae_phy_get_secondary_chnl(struct rtl_priv *rtlpriv)
+{
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_mac *mac =3D rtl_mac(rtlpriv);
+	u8 sc_set_40 =3D 0, sc_set_20 =3D 0;
+
+	if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80) {
+		if (mac->cur_80_prime_sc =3D=3D PRIME_CHNL_OFFSET_LOWER)
+			sc_set_40 =3D VHT_DATA_SC_40_LOWER_OF_80MHZ;
+		else if (mac->cur_80_prime_sc =3D=3D PRIME_CHNL_OFFSET_UPPER)
+			sc_set_40 =3D VHT_DATA_SC_40_UPPER_OF_80MHZ;
+		else
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				"SCMapping: Not Correct Primary40MHz Setting\n");
+
+		if ((mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_LOWER) &&
+			(mac->cur_80_prime_sc =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER))
+			sc_set_20 =3D VHT_DATA_SC_20_LOWEST_OF_80MHZ;
+		else if ((mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_UPPER) &&
+			(mac->cur_80_prime_sc =3D=3D HAL_PRIME_CHNL_OFFSET_LOWER))
+			sc_set_20 =3D VHT_DATA_SC_20_LOWER_OF_80MHZ;
+		else if ((mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_LOWER) &&
+			(mac->cur_80_prime_sc =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER))
+			sc_set_20 =3D VHT_DATA_SC_20_UPPER_OF_80MHZ;
+		else if ((mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_UPPER) &&
+			(mac->cur_80_prime_sc =3D=3D HAL_PRIME_CHNL_OFFSET_UPPER))
+			sc_set_20 =3D VHT_DATA_SC_20_UPPERST_OF_80MHZ;
+		else
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				"SCMapping: Not Correct Primary40MHz Setting\n");
+	} else if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+		if (mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_UPPER)
+			sc_set_20 =3D VHT_DATA_SC_20_UPPER_OF_80MHZ;
+		else if (mac->cur_40_prime_sc =3D=3D PRIME_CHNL_OFFSET_LOWER)
+			sc_set_20 =3D VHT_DATA_SC_20_LOWER_OF_80MHZ;
+		else
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "SCMapping: Not Correct Primary40MHz Setting\n");
+	}
+	return (sc_set_40 << 4) | sc_set_20;
+}
+
+void rtl8821ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 sub_chnl =3D 0;
+	u8 l1pk_val =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
+		 "Switch to %s bandwidth\n",
+		  (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20 ?
+		  "20MHz" :
+		  (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40 ?
+		  "40MHz" : "80MHz")));
+
+	_rtl8821ae_phy_set_reg_bw(rtlpriv, rtlphy->current_chan_bw);
+	sub_chnl =3D _rtl8821ae_phy_get_secondary_chnl(rtlpriv);
+	rtl_write_byte(rtlpriv, 0x0483, sub_chnl);
+
+	switch (rtlphy->current_chan_bw) {
+	case HT_CHANNEL_WIDTH_20:
+		rtl_set_bbreg(hw, RRFMOD, 0x003003C3, 0x00300200);
+		rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 0);
+
+		if (rtlphy->rf_type =3D=3D RF_2T2R)
+			rtl_set_bbreg(hw, RL1PEAKTH, 0x03C00000, 7);
+		else
+			rtl_set_bbreg(hw, RL1PEAKTH, 0x03C00000, 8);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		rtl_set_bbreg(hw, RRFMOD, 0x003003C3, 0x00300201);
+		rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 0);
+		rtl_set_bbreg(hw, RRFMOD, 0x3C, sub_chnl);
+		rtl_set_bbreg(hw, RCCAONSEC, 0xf0000000, sub_chnl);
+
+		if (rtlphy->reg_837 & BIT(2))
+			l1pk_val =3D 6;
+		else {
+			if (rtlphy->rf_type =3D=3D RF_2T2R)
+				l1pk_val =3D 7;
+			else
+				l1pk_val =3D 8;
+		}
+		/* 0x848[25:22] =3D 0x6 */
+		rtl_set_bbreg(hw, RL1PEAKTH, 0x03C00000, l1pk_val);
+
+		if (sub_chnl =3D=3D VHT_DATA_SC_20_UPPER_OF_80MHZ)
+			rtl_set_bbreg(hw, RCCK_SYSTEM, BCCK_SYSTEM, 1);
+		else
+			rtl_set_bbreg(hw, RCCK_SYSTEM, BCCK_SYSTEM, 0);
+		break;
+
+	case HT_CHANNEL_WIDTH_80:
+		 /* 0x8ac[21,20,9:6,1,0]=3D8'b11100010 */
+		rtl_set_bbreg(hw, RRFMOD, 0x003003C3, 0x00300202);
+		/* 0x8c4[30] =3D 1 */
+		rtl_set_bbreg(hw, RADC_BUF_CLK, BIT(30), 1);
+		rtl_set_bbreg(hw, RRFMOD, 0x3C, sub_chnl);
+		rtl_set_bbreg(hw, RCCAONSEC, 0xf0000000, sub_chnl);
+
+		if (rtlphy->reg_837 & BIT(2))
+			l1pk_val =3D 5;
+		else {
+			if (rtlphy->rf_type =3D=3D RF_2T2R)
+				l1pk_val =3D 6;
+			else
+				l1pk_val =3D 7;
+		}
+		rtl_set_bbreg(hw, RL1PEAKTH, 0x03C00000, l1pk_val);
+
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
+		break;
+	}
+
+	rtl8812ae_fixspur(hw, rtlphy->current_chan_bw, rtlphy->current_channe=
l);
+
+	rtl8821ae_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
+	rtlphy->set_bwmode_inprogress =3D false;
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD, "\n");
+}
+
+void rtl8821ae_phy_set_bw_mode(struct ieee80211_hw *hw,
+			    enum nl80211_channel_type ch_type)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 tmp_bw =3D rtlphy->current_chan_bw;
+
+	if (rtlphy->set_bwmode_inprogress)
+		return;
+	rtlphy->set_bwmode_inprogress =3D true;
+	if ((!is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw)))
+		rtl8821ae_phy_set_bw_mode_callback(hw);
+	else {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "FALSE driver sleep or unload\n");
+		rtlphy->set_bwmode_inprogress =3D false;
+		rtlphy->current_chan_bw =3D tmp_bw;
+	}
+}
+
+void rtl8821ae_phy_sw_chnl_callback(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 channel =3D rtlphy->current_channel;
+	u8 path;
+	u32 data;
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
+		 "switch to channel%d\n", rtlphy->current_channel);
+	if (is_hal_stop(rtlhal))
+		return;
+
+	if (36 <=3D channel && channel <=3D 48)
+		data =3D 0x494;
+	else if (50 <=3D channel && channel <=3D 64)
+		data =3D 0x453;
+	else if (100 <=3D channel && channel <=3D 116)
+		data =3D 0x452;
+	else if (118 <=3D channel)
+		data =3D 0x412;
+	else
+		data =3D 0x96a;
+	rtl_set_bbreg(hw, RFC_AREA, 0x1ffe0000, data);
+
+	for (path =3D RF90_PATH_A; path < rtlphy->num_total_rfpath; path++) {
+		if (36 <=3D channel && channel <=3D 64)
+			data =3D 0x101;
+		else if (100 <=3D channel && channel <=3D 140)
+			data =3D 0x301;
+		else if (140 < channel)
+			data =3D 0x501;
+		else
+			data =3D 0x000;
+		rtl8821ae_phy_set_rf_reg(hw, path, RF_CHNLBW,
+			BIT(18)|BIT(17)|BIT(16)|BIT(9)|BIT(8), data);
+
+		rtl8821ae_phy_set_rf_reg(hw, path, RF_CHNLBW,
+			BMASKBYTE0, channel);
+
+		if (channel > 14) {
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8821AE) {
+				if (36 <=3D channel && channel <=3D 64)
+					data =3D 0x114E9;
+				else if (100 <=3D channel && channel <=3D 140)
+					data =3D 0x110E9;
+				else
+					data =3D 0x110E9;
+				rtl8821ae_phy_set_rf_reg(hw, path, RF_APK,
+					BRFREGOFFSETMASK, data);
+			}
+		}
+	}
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "\n");
+}
+
+u8 rtl8821ae_phy_sw_chnl(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u32 timeout =3D 1000, timecount =3D 0;
+	u8 channel =3D rtlphy->current_channel;
+
+	if (rtlphy->sw_chnl_inprogress)
+		return 0;
+	if (rtlphy->set_bwmode_inprogress)
+		return 0;
+
+	if ((is_hal_stop(rtlhal)) || (RT_CANNOT_IO(hw))) {
+		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
+			 "sw_chnl_inprogress false driver sleep or unload\n");
+		return 0;
+	}
+	while (rtlphy->lck_inprogress && timecount < timeout) {
+		mdelay(50);
+		timecount +=3D 50;
+	}
+
+	if (rtlphy->current_channel > 14 && rtlhal->current_bandtype !=3D BAN=
D_ON_5G)
+		rtl8821ae_phy_switch_wirelessband(hw, BAND_ON_5G);
+	else if (rtlphy->current_channel <=3D 14 && rtlhal->current_bandtype =
!=3D BAND_ON_2_4G)
+		rtl8821ae_phy_switch_wirelessband(hw, BAND_ON_2_4G);
+
+	rtlphy->sw_chnl_inprogress =3D true;
+	if (channel =3D=3D 0)
+		channel =3D 1;
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
+		 "switch to channel%d, band type is %d\n",
+		 rtlphy->current_channel, rtlhal->current_bandtype);
+
+	rtl8821ae_phy_sw_chnl_callback(hw);
+
+	rtl8821ae_dm_clear_txpower_tracking_state(hw);
+	rtl8821ae_phy_set_txpower_level(hw, rtlphy->current_channel);
+
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "\n");
+	rtlphy->sw_chnl_inprogress =3D false;
+	return 1;
+}
+
+u8 _rtl8812ae_get_right_chnl_place_for_iqk(u8 chnl)
+{
+	u8 channel_all[TARGET_CHNL_NUM_2G_5G_8812] =3D {
+		1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
+		14, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54,
+		56, 58, 60, 62, 64, 100, 102, 104, 106, 108,
+		110, 112, 114, 116, 118, 120, 122, 124, 126,
+		128, 130, 132, 134, 136, 138, 140, 149, 151,
+		153, 155, 157, 159, 161, 163, 165};
+	u8 place =3D chnl;
+
+	if (chnl > 14) {
+		for (place =3D 14; place < sizeof(channel_all); place++)
+			if (channel_all[place] =3D=3D chnl)
+				return place-13;
+	}
+
+	return 0;
+}
+
+#define MACBB_REG_NUM 10
+#define AFE_REG_NUM 14
+#define RF_REG_NUM 3
+
+static void _rtl8821ae_iqk_backup_macbb(struct ieee80211_hw *hw,
+					u32 *macbb_backup,
+					u32 *backup_macbb_reg, u32 mac_bb_num)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 i;
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /*[31] =3D 0 --> Page C*/
+	/*save MACBB default value*/
+	for (i =3D 0; i < mac_bb_num; i++)
+		macbb_backup[i] =3D rtl_read_dword(rtlpriv, backup_macbb_reg[i]);
+
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "BackupMacBB Success!!!!\n");
+}
+
+static void _rtl8821ae_iqk_backup_afe(struct ieee80211_hw *hw, u32 *af=
e_backup,
+				      u32 *backup_afe_REG, u32 afe_num)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 i;
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /*[31] =3D 0 --> Page C*/
+	/*Save AFE Parameters */
+	for (i =3D 0; i < afe_num; i++)
+		afe_backup[i] =3D rtl_read_dword(rtlpriv, backup_afe_REG[i]);
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "BackupAFE Success!!!!\n");
+}
+
+static void _rtl8821ae_iqk_backup_rf(struct ieee80211_hw *hw, u32 *rfa=
_backup,
+				     u32 *rfb_backup, u32 *backup_rf_reg,
+				     u32 rf_num)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 i;
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /*[31] =3D 0 --> Page C*/
+	/*Save RF Parameters*/
+	for (i =3D 0; i < rf_num; i++) {
+		rfa_backup[i] =3D rtl_get_rfreg(hw, RF90_PATH_A, backup_rf_reg[i],
+					      BMASKDWORD);
+		rfb_backup[i] =3D rtl_get_rfreg(hw, RF90_PATH_B, backup_rf_reg[i],
+					      BMASKDWORD);
+	}
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "BackupRF Success!!!!\n");
+}
+
+static void _rtl8821ae_iqk_configure_mac(
+		struct ieee80211_hw *hw
+		)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	/* =3D=3D=3D=3D=3D=3D=3D=3DMAC register setting=3D=3D=3D=3D=3D=3D=3D=3D=
*/
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /*[31] =3D 0 --> Page C*/
+	rtl_write_byte(rtlpriv, 0x522, 0x3f);
+	rtl_set_bbreg(hw, 0x550, BIT(11) | BIT(3), 0x0);
+	rtl_write_byte(rtlpriv, 0x808, 0x00);		/*RX ante off*/
+	rtl_set_bbreg(hw, 0x838, 0xf, 0xc);		/*CCA off*/
+}
+
+static void _rtl8821ae_iqk_tx_fill_iqc(struct ieee80211_hw *hw,
+				       enum radio_path path, u32 tx_x, u32 tx_y)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	switch (path) {
+	case RF90_PATH_A:
+		/* [31] =3D 1 --> Page C1 */
+		rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1);
+		rtl_write_dword(rtlpriv, 0xc90, 0x00000080);
+		rtl_write_dword(rtlpriv, 0xcc4, 0x20040000);
+		rtl_write_dword(rtlpriv, 0xcc8, 0x20000000);
+		rtl_set_bbreg(hw, 0xccc, 0x000007ff, tx_y);
+		rtl_set_bbreg(hw, 0xcd4, 0x000007ff, tx_x);
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "TX_X =3D %x;;TX_Y =3D %x =3D=3D=3D=3D=3D> fill to IQC\n",
+			 tx_x, tx_y);
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "0xcd4 =3D %x;;0xccc =3D %x =3D=3D=3D=3D>fill to IQC\n",
+			 rtl_get_bbreg(hw, 0xcd4, 0x000007ff),
+			 rtl_get_bbreg(hw, 0xccc, 0x000007ff));
+		break;
+	default:
+		break;
+	};
+}
+
+static void _rtl8821ae_iqk_rx_fill_iqc(struct ieee80211_hw *hw,
+				       enum radio_path path, u32 rx_x, u32 rx_y)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	switch (path) {
+	case RF90_PATH_A:
+		rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+		rtl_set_bbreg(hw, 0xc10, 0x000003ff, rx_x>>1);
+		rtl_set_bbreg(hw, 0xc10, 0x03ff0000, rx_y>>1);
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "rx_x =3D %x;;rx_y =3D %x =3D=3D=3D=3D>fill to IQC\n",
+			 rx_x>>1, rx_y>>1);
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "0xc10 =3D %x =3D=3D=3D=3D>fill to IQC\n",
+			 rtl_read_dword(rtlpriv, 0xc10));
+		break;
+	default:
+		break;
+	};
+}
+
+#define cal_num 10
+
+static void _rtl8821ae_iqk_tx(struct ieee80211_hw *hw, enum radio_path=
 path)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	u32	tx_fail, rx_fail, delay_count, iqk_ready, cal_retry, cal =3D 0, t=
emp_reg65;
+	int	tx_x =3D 0, tx_y =3D 0, rx_x =3D 0, rx_y =3D 0, tx_average =3D 0,=
 rx_average =3D 0;
+	int	tx_x0[cal_num], tx_y0[cal_num], tx_x0_rxk[cal_num],
+		tx_y0_rxk[cal_num], rx_x0[cal_num], rx_y0[cal_num];
+	bool	tx0iqkok =3D false, rx0iqkok =3D false;
+	bool	vdf_enable =3D false;
+	int	i, k, vdf_y[3], vdf_x[3], tx_dt[3], rx_dt[3],
+		ii, dx =3D 0, dy =3D 0, tx_finish =3D 0, rx_finish =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			"BandWidth =3D %d.\n",
+			 rtlphy->current_chan_bw);
+	if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80)
+		vdf_enable =3D true;
+
+	while (cal < cal_num) {
+		switch (path) {
+		case RF90_PATH_A:
+			temp_reg65 =3D rtl_get_rfreg(hw, path, 0x65, 0xffffffff);
+			/* Path-A LOK */
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /*[31] =3D 0 --> Page C*/
+			/*=3D=3D=3D=3D=3D=3D=3D=3DPath-A AFE all on=3D=3D=3D=3D=3D=3D=3D=3D=
*/
+			/*Port 0 DAC/ADC on*/
+			rtl_write_dword(rtlpriv, 0xc60, 0x77777777);
+			rtl_write_dword(rtlpriv, 0xc64, 0x77777777);
+			rtl_write_dword(rtlpriv, 0xc68, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc6c, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc70, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc74, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc78, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc7c, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc80, 0x19791979);
+			rtl_write_dword(rtlpriv, 0xc84, 0x19791979);
+
+			rtl_set_bbreg(hw, 0xc00, 0xf, 0x4); /*hardware 3-wire off*/
+
+			/* LOK Setting */
+			/* =3D=3D=3D=3D=3D=3D LOK =3D=3D=3D=3D=3D=3D */
+			/*DAC/ADC sampling rate (160 MHz)*/
+			rtl_set_bbreg(hw, 0xc5c, BIT(26) | BIT(25) | BIT(24), 0x7);
+
+			/* 2. LoK RF Setting (at BW =3D 20M) */
+			rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80002);
+			rtl_set_rfreg(hw, path, 0x18, 0x00c00, 0x3);     /* BW 20M */
+			rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x20000);
+			rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x0003f);
+			rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xf3fc3);
+			rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, 0x931d5);
+			rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x8a001);
+			rtl_set_bbreg(hw, 0xcb8, 0xf, 0xd);
+			rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+			rtl_write_dword(rtlpriv, 0xb00, 0x03000100);
+			rtl_set_bbreg(hw, 0xc94, BIT(0), 0x1);
+			rtl_write_dword(rtlpriv, 0x978, 0x29002000);/* TX (X,Y) */
+			rtl_write_dword(rtlpriv, 0x97c, 0xa9002000);/* RX (X,Y) */
+			rtl_write_dword(rtlpriv, 0x984, 0x00462910);/* [0]:AGC_en, [15]:ida=
c_K_Mask */
+
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 *=
/
+			rtl_write_dword(rtlpriv, 0xc88, 0x821403f4);
+
+			if (rtlhal->current_bandtype)
+				rtl_write_dword(rtlpriv, 0xc8c, 0x68163e96);
+			else
+				rtl_write_dword(rtlpriv, 0xc8c, 0x28163e96);
+
+			rtl_write_dword(rtlpriv, 0xc80, 0x18008c10);/* TX_TONE_idx[9:0], Tx=
K_Mask[29] TX_Tone =3D 16 */
+			rtl_write_dword(rtlpriv, 0xc84, 0x38008c10);/* RX_TONE_idx[9:0], Rx=
K_Mask[29] */
+			rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI \=
A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+			rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+			rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+			mdelay(10); /* Delay 10ms */
+			rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+			rtl_set_rfreg(hw, path, 0x58, 0x7fe00, rtl_get_rfreg(hw, path, 0x8,=
 0xffc00)); /* Load LOK */
+
+			switch (rtlphy->current_chan_bw) {
+			case 1:
+				rtl_set_rfreg(hw, path, 0x18, 0x00c00, 0x1);
+				break;
+			case 2:
+				rtl_set_rfreg(hw, path, 0x18, 0x00c00, 0x0);
+				break;
+			default:
+				break;
+			}
+
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 *=
/
+
+			/* 3. TX RF Setting */
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+			rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80000);
+			rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x20000);
+			rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x0003f);
+			rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xf3fc3);
+			rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, 0x931d5);
+			rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x8a001);
+			rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x00000);
+			/* ODM_SetBBReg(pDM_Odm, 0xcb8, 0xf, 0xd); */
+			rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+			rtl_write_dword(rtlpriv, 0xb00, 0x03000100);
+			rtl_set_bbreg(hw, 0xc94, BIT(0), 0x1);
+			rtl_write_dword(rtlpriv, 0x978, 0x29002000);/* TX (X,Y) */
+			rtl_write_dword(rtlpriv, 0x97c, 0xa9002000);/* RX (X,Y) */
+			rtl_write_dword(rtlpriv, 0x984, 0x0046a910);/* [0]:AGC_en, [15]:ida=
c_K_Mask */
+
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 *=
/
+			rtl_write_dword(rtlpriv, 0xc88, 0x821403f1);
+			if (rtlhal->current_bandtype)
+				rtl_write_dword(rtlpriv, 0xc8c, 0x40163e96);
+			else
+				rtl_write_dword(rtlpriv, 0xc8c, 0x00163e96);
+
+			if (vdf_enable =3D=3D 1) {
+				RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "VDF_enable\n");
+				for (k =3D 0; k <=3D 2; k++) {
+					switch (k) {
+					case 0:
+						rtl_write_dword(rtlpriv, 0xc80, 0x18008c38);/* TX_TONE_idx[9:0],=
 TxK_Mask[29] TX_Tone =3D 16 */
+						rtl_write_dword(rtlpriv, 0xc84, 0x38008c38);/* RX_TONE_idx[9:0],=
 RxK_Mask[29] */
+						rtl_set_bbreg(hw, 0xce8, BIT(31), 0x0);
+						break;
+					case 1:
+						rtl_set_bbreg(hw, 0xc80, BIT(28), 0x0);
+						rtl_set_bbreg(hw, 0xc84, BIT(28), 0x0);
+						rtl_set_bbreg(hw, 0xce8, BIT(31), 0x0);
+						break;
+					case 2:
+						RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+							"vdf_y[1] =3D %x;;;vdf_y[0] =3D %x\n", vdf_y[1]>>21 & 0x00007ff=
, vdf_y[0]>>21 & 0x00007ff);
+						RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+							"vdf_x[1] =3D %x;;;vdf_x[0] =3D %x\n", vdf_x[1]>>21 & 0x00007ff=
, vdf_x[0]>>21 & 0x00007ff);
+						tx_dt[cal] =3D (vdf_y[1]>>20)-(vdf_y[0]>>20);
+						tx_dt[cal] =3D ((16*tx_dt[cal])*10000/15708);
+						tx_dt[cal] =3D (tx_dt[cal] >> 1)+(tx_dt[cal] & BIT(0));
+						rtl_write_dword(rtlpriv, 0xc80, 0x18008c20);/* TX_TONE_idx[9:0],=
 TxK_Mask[29] TX_Tone =3D 16 */
+						rtl_write_dword(rtlpriv, 0xc84, 0x38008c20);/* RX_TONE_idx[9:0],=
 RxK_Mask[29] */
+						rtl_set_bbreg(hw, 0xce8, BIT(31), 0x1);
+						rtl_set_bbreg(hw, 0xce8, 0x3fff0000, tx_dt[cal] & 0x00003fff);
+						break;
+					default:
+						break;
+					}
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI=
 \A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+					cal_retry =3D 0;
+					while (1) {
+						/* one shot */
+						rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+						rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+						mdelay(10); /* Delay 10ms */
+						rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+						delay_count =3D 0;
+						while (1) {
+							iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+							if ((~iqk_ready) || (delay_count > 20))
+								break;
+							else{
+								mdelay(1);
+								delay_count++;
+							}
+						}
+
+						if (delay_count < 20) {							/* If 20ms No Result, then cal_ret=
ry++ */
+							/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DTXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+							tx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(12));
+
+							if (~tx_fail) {
+								rtl_write_dword(rtlpriv, 0xcb8, 0x02000000);
+								vdf_x[k] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								rtl_write_dword(rtlpriv, 0xcb8, 0x04000000);
+								vdf_y[k] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								tx0iqkok =3D true;
+								break;
+							} else {
+								rtl_set_bbreg(hw, 0xccc, 0x000007ff, 0x0);
+								rtl_set_bbreg(hw, 0xcd4, 0x000007ff, 0x200);
+								tx0iqkok =3D false;
+								cal_retry++;
+								if (cal_retry =3D=3D 10)
+									break;
+							}
+						} else {
+							tx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+						}
+					}
+				}
+				if (k =3D=3D 3) {
+					tx_x0[cal] =3D vdf_x[k-1];
+					tx_y0[cal] =3D vdf_y[k-1];
+				}
+			} else {
+				rtl_write_dword(rtlpriv, 0xc80, 0x18008c10);/* TX_TONE_idx[9:0], T=
xK_Mask[29] TX_Tone =3D 16 */
+				rtl_write_dword(rtlpriv, 0xc84, 0x38008c10);/* RX_TONE_idx[9:0], R=
xK_Mask[29] */
+				rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI =
\A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+				cal_retry =3D 0;
+				while (1) {
+					/* one shot */
+					rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+					rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+					mdelay(10); /* Delay 10ms */
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+					delay_count =3D 0;
+					while (1) {
+						iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+						if ((~iqk_ready) || (delay_count > 20))
+							break;
+						else{
+							mdelay(1);
+							delay_count++;
+						}
+					}
+
+					if (delay_count < 20) {							/* If 20ms No Result, then cal_retr=
y++ */
+						/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DTXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+						tx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(12));
+
+						if (~tx_fail) {
+							rtl_write_dword(rtlpriv, 0xcb8, 0x02000000);
+							tx_x0[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							rtl_write_dword(rtlpriv, 0xcb8, 0x04000000);
+							tx_y0[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							tx0iqkok =3D true;
+							break;
+						} else {
+							rtl_set_bbreg(hw, 0xccc, 0x000007ff, 0x0);
+							rtl_set_bbreg(hw, 0xcd4, 0x000007ff, 0x200);
+							tx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+						}
+					} else {
+						tx0iqkok =3D false;
+						cal_retry++;
+						if (cal_retry =3D=3D 10)
+							break;
+					}
+				}
+			}
+
+			if (tx0iqkok =3D=3D false)
+				break;				/* TXK fail, Don't do RXK */
+
+			if (vdf_enable =3D=3D 1) {
+				rtl_set_bbreg(hw, 0xce8, BIT(31), 0x0);    /* TX VDF Disable */
+				RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "RXVDF Start\n");
+				for (k =3D 0; k <=3D 2; k++) {
+					/* =3D=3D=3D=3D=3D=3D RX mode TXK (RXK Step 1) =3D=3D=3D=3D=3D=3D=
 */
+					rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C =
*/
+					/* 1. TX RF Setting */
+					rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80000);
+					rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x30000);
+					rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x00029);
+					rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xd7ffb);
+					rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, temp_reg65);
+					rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x8a001);
+					rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x00000);
+
+					rtl_set_bbreg(hw, 0xcb8, 0xf, 0xd);
+					rtl_write_dword(rtlpriv, 0x978, 0x29002000);/* TX (X,Y) */
+					rtl_write_dword(rtlpriv, 0x97c, 0xa9002000);/* RX (X,Y) */
+					rtl_write_dword(rtlpriv, 0x984, 0x0046a910);/* [0]:AGC_en, [15]:i=
dac_K_Mask */
+					rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+					rtl_write_dword(rtlpriv, 0xb00, 0x03000100);
+					rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1=
 */
+					switch (k) {
+					case 0:
+						{
+							rtl_write_dword(rtlpriv, 0xc80, 0x18008c38);/* TX_TONE_idx[9:0]=
, TxK_Mask[29] TX_Tone =3D 16 */
+							rtl_write_dword(rtlpriv, 0xc84, 0x38008c38);/* RX_TONE_idx[9:0]=
, RxK_Mask[29] */
+							rtl_set_bbreg(hw, 0xce8, BIT(30), 0x0);
+						}
+						break;
+					case 1:
+						{
+							rtl_write_dword(rtlpriv, 0xc80, 0x08008c38);/* TX_TONE_idx[9:0]=
, TxK_Mask[29] TX_Tone =3D 16 */
+							rtl_write_dword(rtlpriv, 0xc84, 0x28008c38);/* RX_TONE_idx[9:0]=
, RxK_Mask[29] */
+							rtl_set_bbreg(hw, 0xce8, BIT(30), 0x0);
+						}
+						break;
+					case 2:
+						{
+							RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+							"VDF_Y[1] =3D %x;;;VDF_Y[0] =3D %x\n",
+							vdf_y[1]>>21 & 0x00007ff, vdf_y[0]>>21 & 0x00007ff);
+							RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+							"VDF_X[1] =3D %x;;;VDF_X[0] =3D %x\n",
+							vdf_x[1]>>21 & 0x00007ff, vdf_x[0]>>21 & 0x00007ff);
+							rx_dt[cal] =3D (vdf_y[1]>>20)-(vdf_y[0]>>20);
+							RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "Rx_dt =3D %d\n", rx_dt[c=
al]);
+							rx_dt[cal] =3D ((16*rx_dt[cal])*10000/13823);
+							rx_dt[cal] =3D (rx_dt[cal] >> 1)+(rx_dt[cal] & BIT(0));
+							rtl_write_dword(rtlpriv, 0xc80, 0x18008c20);/* TX_TONE_idx[9:0]=
, TxK_Mask[29] TX_Tone =3D 16 */
+							rtl_write_dword(rtlpriv, 0xc84, 0x38008c20);/* RX_TONE_idx[9:0]=
, RxK_Mask[29] */
+							rtl_set_bbreg(hw, 0xce8, 0x00003fff, rx_dt[cal] & 0x00003fff);
+						}
+						break;
+					default:
+						break;
+					}
+					rtl_write_dword(rtlpriv, 0xc88, 0x821603e0);
+					rtl_write_dword(rtlpriv, 0xc8c, 0x68163e96);
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI=
 \A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+					cal_retry =3D 0;
+					while (1) {
+						/* one shot */
+						rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+						rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+						mdelay(10); /* Delay 10ms */
+						rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+						delay_count =3D 0;
+						while (1) {
+							iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+							if ((~iqk_ready) || (delay_count > 20))
+								break;
+							else{
+								mdelay(1);
+								delay_count++;
+							}
+						}
+
+						if (delay_count < 20) {							/* If 20ms No Result, then cal_ret=
ry++ */
+							/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DTXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+							tx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(12));
+
+							if (~tx_fail) {
+								rtl_write_dword(rtlpriv, 0xcb8, 0x02000000);
+								tx_x0_rxk[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								rtl_write_dword(rtlpriv, 0xcb8, 0x04000000);
+								tx_y0_rxk[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								tx0iqkok =3D true;
+								break;
+							} else{
+								tx0iqkok =3D false;
+								cal_retry++;
+								if (cal_retry =3D=3D 10)
+									break;
+							}
+						} else {
+							tx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+						}
+					}
+
+					if (tx0iqkok =3D=3D false) {   /* If RX mode TXK fail, then take =
TXK Result */
+						tx_x0_rxk[cal] =3D tx_x0[cal];
+						tx_y0_rxk[cal] =3D tx_y0[cal];
+						tx0iqkok =3D true;
+						RT_TRACE(rtlpriv,
+							 COMP_IQK,
+							 DBG_LOUD,
+							 "RXK Step 1 fail\n");
+					}
+
+					/* =3D=3D=3D=3D=3D=3D RX IQK =3D=3D=3D=3D=3D=3D */
+					rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C =
*/
+					/* 1. RX RF Setting */
+					rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80000);
+					rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x30000);
+					rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x0002f);
+					rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xfffbb);
+					rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x88001);
+					rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, 0x931d8);
+					rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x00000);
+
+					rtl_set_bbreg(hw, 0x978, 0x03FF8000, (tx_x0_rxk[cal])>>21&0x00000=
7ff);
+					rtl_set_bbreg(hw, 0x978, 0x000007FF, (tx_y0_rxk[cal])>>21&0x00000=
7ff);
+					rtl_set_bbreg(hw, 0x978, BIT(31), 0x1);
+					rtl_set_bbreg(hw, 0x97c, BIT(31), 0x0);
+					rtl_set_bbreg(hw, 0xcb8, 0xF, 0xe);
+					rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+					rtl_write_dword(rtlpriv, 0x984, 0x0046a911);
+
+					rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1=
 */
+					rtl_set_bbreg(hw, 0xc80, BIT(29), 0x1);
+					rtl_set_bbreg(hw, 0xc84, BIT(29), 0x0);
+					rtl_write_dword(rtlpriv, 0xc88, 0x02140119);
+
+					rtl_write_dword(rtlpriv, 0xc8c, 0x28160d00); /* pDM_Odm->SupportI=
nterface =3D=3D 1 */
+
+					if (k =3D=3D 2)
+						rtl_set_bbreg(hw, 0xce8, BIT(30), 0x1);  /* RX VDF Enable */
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI=
 \A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+
+					cal_retry =3D 0;
+					while (1) {
+						/* one shot */
+						rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+						rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+						mdelay(10); /* Delay 10ms */
+						rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+						delay_count =3D 0;
+						while (1) {
+							iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+							if ((~iqk_ready) || (delay_count > 20))
+								break;
+							else{
+								mdelay(1);
+								delay_count++;
+							}
+						}
+
+						if (delay_count < 20) {	/* If 20ms No Result, then cal_retry++ *=
/
+							/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DRXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+							rx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(11));
+							if (rx_fail =3D=3D 0) {
+								rtl_write_dword(rtlpriv, 0xcb8, 0x06000000);
+								vdf_x[k] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								rtl_write_dword(rtlpriv, 0xcb8, 0x08000000);
+								vdf_y[k] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+								rx0iqkok =3D true;
+								break;
+							} else {
+								rtl_set_bbreg(hw, 0xc10, 0x000003ff, 0x200>>1);
+								rtl_set_bbreg(hw, 0xc10, 0x03ff0000, 0x0>>1);
+								rx0iqkok =3D false;
+								cal_retry++;
+								if (cal_retry =3D=3D 10)
+									break;
+
+							}
+						} else{
+							rx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+						}
+					}
+
+				}
+				if (k =3D=3D 3) {
+					rx_x0[cal] =3D vdf_x[k-1];
+					rx_y0[cal] =3D vdf_y[k-1];
+				}
+				rtl_set_bbreg(hw, 0xce8, BIT(31), 0x1);    /* TX VDF Enable */
+			}
+
+			else{
+				/* =3D=3D=3D=3D=3D=3D RX mode TXK (RXK Step 1) =3D=3D=3D=3D=3D=3D =
*/
+				rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C *=
/
+				/* 1. TX RF Setting */
+				rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80000);
+				rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x30000);
+				rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x00029);
+				rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xd7ffb);
+				rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, temp_reg65);
+				rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x8a001);
+				rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x00000);
+				rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+				rtl_write_dword(rtlpriv, 0xb00, 0x03000100);
+				rtl_write_dword(rtlpriv, 0x984, 0x0046a910);/* [0]:AGC_en, [15]:id=
ac_K_Mask */
+
+				rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 =
*/
+				rtl_write_dword(rtlpriv, 0xc80, 0x18008c10);/* TX_TONE_idx[9:0], T=
xK_Mask[29] TX_Tone =3D 16 */
+				rtl_write_dword(rtlpriv, 0xc84, 0x38008c10);/* RX_TONE_idx[9:0], R=
xK_Mask[29] */
+				rtl_write_dword(rtlpriv, 0xc88, 0x821603e0);
+				/* ODM_Write4Byte(pDM_Odm, 0xc8c, 0x68163e96); */
+				rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI =
\A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+				cal_retry =3D 0;
+				while (1) {
+					/* one shot */
+					rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+					rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+					mdelay(10); /* Delay 10ms */
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+					delay_count =3D 0;
+					while (1) {
+						iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+						if ((~iqk_ready) || (delay_count > 20))
+							break;
+						else{
+							mdelay(1);
+							delay_count++;
+						}
+					}
+
+					if (delay_count < 20) {							/* If 20ms No Result, then cal_retr=
y++ */
+						/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DTXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+						tx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(12));
+
+						if (~tx_fail) {
+							rtl_write_dword(rtlpriv, 0xcb8, 0x02000000);
+							tx_x0_rxk[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							rtl_write_dword(rtlpriv, 0xcb8, 0x04000000);
+							tx_y0_rxk[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							tx0iqkok =3D true;
+							break;
+						} else {
+							tx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+						}
+					} else{
+						tx0iqkok =3D false;
+						cal_retry++;
+						if (cal_retry =3D=3D 10)
+							break;
+					}
+				}
+
+				if (tx0iqkok =3D=3D false) {   /* If RX mode TXK fail, then take T=
XK Result */
+					tx_x0_rxk[cal] =3D tx_x0[cal];
+					tx_y0_rxk[cal] =3D tx_y0[cal];
+					tx0iqkok =3D true;
+					RT_TRACE(rtlpriv, COMP_IQK,
+						 DBG_LOUD, "1");
+				}
+
+				/* =3D=3D=3D=3D=3D=3D RX IQK =3D=3D=3D=3D=3D=3D */
+				rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C *=
/
+				/* 1. RX RF Setting */
+				rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x80000);
+				rtl_set_rfreg(hw, path, 0x30, RFREG_OFFSET_MASK, 0x30000);
+				rtl_set_rfreg(hw, path, 0x31, RFREG_OFFSET_MASK, 0x0002f);
+				rtl_set_rfreg(hw, path, 0x32, RFREG_OFFSET_MASK, 0xfffbb);
+				rtl_set_rfreg(hw, path, 0x8f, RFREG_OFFSET_MASK, 0x88001);
+				rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, 0x931d8);
+				rtl_set_rfreg(hw, path, 0xef, RFREG_OFFSET_MASK, 0x00000);
+
+				rtl_set_bbreg(hw, 0x978, 0x03FF8000, (tx_x0_rxk[cal])>>21&0x000007=
ff);
+				rtl_set_bbreg(hw, 0x978, 0x000007FF, (tx_y0_rxk[cal])>>21&0x000007=
ff);
+				rtl_set_bbreg(hw, 0x978, BIT(31), 0x1);
+				rtl_set_bbreg(hw, 0x97c, BIT(31), 0x0);
+				/* ODM_SetBBReg(pDM_Odm, 0xcb8, 0xF, 0xe); */
+				rtl_write_dword(rtlpriv, 0x90c, 0x00008000);
+				rtl_write_dword(rtlpriv, 0x984, 0x0046a911);
+
+				rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 =
*/
+				rtl_write_dword(rtlpriv, 0xc80, 0x38008c10);/* TX_TONE_idx[9:0], T=
xK_Mask[29] TX_Tone =3D 16 */
+				rtl_write_dword(rtlpriv, 0xc84, 0x18008c10);/* RX_TONE_idx[9:0], R=
xK_Mask[29] */
+				rtl_write_dword(rtlpriv, 0xc88, 0x02140119);
+
+				rtl_write_dword(rtlpriv, 0xc8c, 0x28160d00); /*pDM_Odm->SupportInt=
erface =3D=3D 1*/
+
+				rtl_write_dword(rtlpriv, 0xcb8, 0x00100000);/* cb8[20] \B1N SI/PI =
\A8=CF=A5\CE\C5v\A4\C1\B5\B9 iqk_dpk module */
+
+				cal_retry =3D 0;
+				while (1) {
+					/* one shot */
+					rtl_write_dword(rtlpriv, 0x980, 0xfa000000);
+					rtl_write_dword(rtlpriv, 0x980, 0xf8000000);
+
+					mdelay(10); /* Delay 10ms */
+					rtl_write_dword(rtlpriv, 0xcb8, 0x00000000);
+					delay_count =3D 0;
+					while (1) {
+						iqk_ready =3D rtl_get_bbreg(hw, 0xd00, BIT(10));
+						if ((~iqk_ready) || (delay_count > 20))
+							break;
+						else{
+							mdelay(1);
+							delay_count++;
+						}
+					}
+
+					if (delay_count < 20) {	/* If 20ms No Result, then cal_retry++ */
+						/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3DRXIQK Check=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D */
+						rx_fail =3D rtl_get_bbreg(hw, 0xd00, BIT(11));
+						if (rx_fail =3D=3D 0) {
+							rtl_write_dword(rtlpriv, 0xcb8, 0x06000000);
+							rx_x0[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							rtl_write_dword(rtlpriv, 0xcb8, 0x08000000);
+							rx_y0[cal] =3D rtl_get_bbreg(hw, 0xd00, 0x07ff0000)<<21;
+							rx0iqkok =3D true;
+							break;
+						} else{
+							rtl_set_bbreg(hw, 0xc10, 0x000003ff, 0x200>>1);
+							rtl_set_bbreg(hw, 0xc10, 0x03ff0000, 0x0>>1);
+							rx0iqkok =3D false;
+							cal_retry++;
+							if (cal_retry =3D=3D 10)
+								break;
+
+						}
+					} else{
+						rx0iqkok =3D false;
+						cal_retry++;
+						if (cal_retry =3D=3D 10)
+							break;
+					}
+				}
+			}
+
+			if (tx0iqkok)
+				tx_average++;
+			if (rx0iqkok)
+				rx_average++;
+			rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+			rtl_set_rfreg(hw, path, 0x65, RFREG_OFFSET_MASK, temp_reg65);
+			break;
+		default:
+			break;
+		}
+		cal++;
+	}
+
+	/* FillIQK Result */
+	switch (path) {
+	case RF90_PATH_A:
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "=3D=3D=3D=3D=3D=3D=3D=3DPath_A =3D=3D=3D=3D=3D=3D=3D\n");
+		if (tx_average =3D=3D 0)
+			break;
+
+		for (i =3D 0; i < tx_average; i++) {
+			RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+				 "TX_X0_RXK[%d] =3D %x ;; TX_Y0_RXK[%d] =3D %x\n", i,
+				 (tx_x0_rxk[i])>>21&0x000007ff, i,
+				 (tx_y0_rxk[i])>>21&0x000007ff);
+			RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+				 "TX_X0[%d] =3D %x ;; TX_Y0[%d] =3D %x\n", i,
+				 (tx_x0[i])>>21&0x000007ff, i,
+				 (tx_y0[i])>>21&0x000007ff);
+		}
+		for (i =3D 0; i < tx_average; i++) {
+			for (ii =3D i+1; ii < tx_average; ii++) {
+				dx =3D (tx_x0[i]>>21) - (tx_x0[ii]>>21);
+				if (dx < 3 && dx > -3) {
+					dy =3D (tx_y0[i]>>21) - (tx_y0[ii]>>21);
+					if (dy < 3 && dy > -3) {
+						tx_x =3D ((tx_x0[i]>>21) + (tx_x0[ii]>>21))/2;
+						tx_y =3D ((tx_y0[i]>>21) + (tx_y0[ii]>>21))/2;
+						tx_finish =3D 1;
+						break;
+					}
+				}
+			}
+			if (tx_finish =3D=3D 1)
+				break;
+		}
+
+		if (tx_finish =3D=3D 1)
+			_rtl8821ae_iqk_tx_fill_iqc(hw, path, tx_x, tx_y); /* ? */
+		else
+			_rtl8821ae_iqk_tx_fill_iqc(hw, path, 0x200, 0x0);
+
+		if (rx_average =3D=3D 0)
+			break;
+
+		for (i =3D 0; i < rx_average; i++)
+			RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+				"RX_X0[%d] =3D %x ;; RX_Y0[%d] =3D %x\n", i,
+				(rx_x0[i])>>21&0x000007ff, i,
+				(rx_y0[i])>>21&0x000007ff);
+		for (i =3D 0; i < rx_average; i++) {
+			for (ii =3D i+1; ii < rx_average; ii++) {
+				dx =3D (rx_x0[i]>>21) - (rx_x0[ii]>>21);
+				if (dx < 4 && dx > -4) {
+					dy =3D (rx_y0[i]>>21) - (rx_y0[ii]>>21);
+					if (dy < 4 && dy > -4) {
+						rx_x =3D ((rx_x0[i]>>21) + (rx_x0[ii]>>21))/2;
+						rx_y =3D ((rx_y0[i]>>21) + (rx_y0[ii]>>21))/2;
+						rx_finish =3D 1;
+						break;
+					}
+				}
+			}
+			if (rx_finish =3D=3D 1)
+				break;
+		}
+
+		if (rx_finish =3D=3D 1)
+			_rtl8821ae_iqk_rx_fill_iqc(hw, path, rx_x, rx_y);
+		else
+			_rtl8821ae_iqk_rx_fill_iqc(hw, path, 0x200, 0x0);
+		break;
+	default:
+		break;
+	}
+}
+
+static void _rtl8821ae_iqk_restore_rf(struct ieee80211_hw *hw,
+				      enum radio_path path,
+				      u32 *backup_rf_reg,
+				      u32 *rf_backup, u32 rf_reg_num)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u32 i;
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+	for (i =3D 0; i < RF_REG_NUM; i++)
+		rtl_set_rfreg(hw, path, backup_rf_reg[i], RFREG_OFFSET_MASK,
+			      rf_backup[i]);
+
+	switch (path) {
+	case RF90_PATH_A:
+		RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+			 "RestoreRF Path A Success!!!!\n");
+		break;
+	default:
+			break;
+	}
+}
+
+static void _rtl8821ae_iqk_restore_afe(struct ieee80211_hw *hw,
+				       u32 *afe_backup, u32 *backup_afe_reg,
+				       u32 afe_num)
+{
+	u32 i;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+	/* Reload AFE Parameters */
+	for (i =3D 0; i < afe_num; i++)
+		rtl_write_dword(rtlpriv, backup_afe_reg[i], afe_backup[i]);
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x1); /* [31] =3D 1 --> Page C1 */
+	rtl_write_dword(rtlpriv, 0xc80, 0x0);
+	rtl_write_dword(rtlpriv, 0xc84, 0x0);
+	rtl_write_dword(rtlpriv, 0xc88, 0x0);
+	rtl_write_dword(rtlpriv, 0xc8c, 0x3c000000);
+	rtl_write_dword(rtlpriv, 0xc90, 0x00000080);
+	rtl_write_dword(rtlpriv, 0xc94, 0x00000000);
+	rtl_write_dword(rtlpriv, 0xcc4, 0x20040000);
+	rtl_write_dword(rtlpriv, 0xcc8, 0x20000000);
+	rtl_write_dword(rtlpriv, 0xcb8, 0x0);
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "RestoreAFE Success!!!!\n");
+}
+
+static void _rtl8821ae_iqk_restore_macbb(struct ieee80211_hw *hw,
+					 u32 *macbb_backup,
+					 u32 *backup_macbb_reg,
+					 u32 macbb_num)
+{
+	u32 i;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtl_set_bbreg(hw, 0x82c, BIT(31), 0x0); /* [31] =3D 0 --> Page C */
+	/* Reload MacBB Parameters */
+	for (i =3D 0; i < macbb_num; i++)
+		rtl_write_dword(rtlpriv, backup_macbb_reg[i], macbb_backup[i]);
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD, "RestoreMacBB Success!!!!\n");
+}
+
+#undef MACBB_REG_NUM
+#undef AFE_REG_NUM
+#undef RF_REG_NUM
+
+#define MACBB_REG_NUM 11
+#define AFE_REG_NUM 12
+#define RF_REG_NUM 3
+
+static void _rtl8821ae_phy_iq_calibrate(struct ieee80211_hw *hw)
+{
+	u32	macbb_backup[MACBB_REG_NUM];
+	u32 afe_backup[AFE_REG_NUM];
+	u32 rfa_backup[RF_REG_NUM];
+	u32 rfb_backup[RF_REG_NUM];
+	u32 backup_macbb_reg[MACBB_REG_NUM] =3D {
+		0xb00, 0x520, 0x550, 0x808, 0x90c, 0xc00, 0xc50,
+		0xe00, 0xe50, 0x838, 0x82c
+	};
+	u32 backup_afe_reg[AFE_REG_NUM] =3D {
+		0xc5c, 0xc60, 0xc64, 0xc68, 0xc6c, 0xc70, 0xc74,
+		0xc78, 0xc7c, 0xc80, 0xc84, 0xcb8
+	};
+	u32	backup_rf_reg[RF_REG_NUM] =3D {0x65, 0x8f, 0x0};
+
+	_rtl8821ae_iqk_backup_macbb(hw, macbb_backup, backup_macbb_reg,
+				    MACBB_REG_NUM);
+	_rtl8821ae_iqk_backup_afe(hw, afe_backup, backup_afe_reg, AFE_REG_NUM=
);
+	_rtl8821ae_iqk_backup_rf(hw, rfa_backup, rfb_backup, backup_rf_reg,
+				 RF_REG_NUM);
+
+	_rtl8821ae_iqk_configure_mac(hw);
+	_rtl8821ae_iqk_tx(hw, RF90_PATH_A);
+	_rtl8821ae_iqk_restore_rf(hw, RF90_PATH_A, backup_rf_reg, rfa_backup,
+				  RF_REG_NUM);
+
+	_rtl8821ae_iqk_restore_afe(hw, afe_backup, backup_afe_reg, AFE_REG_NU=
M);
+	_rtl8821ae_iqk_restore_macbb(hw, macbb_backup, backup_macbb_reg,
+				     MACBB_REG_NUM);
+}
+
+static void _rtl8821ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, =
bool main)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	/* struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw)); */
+	/* struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw)); */
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "\n");
+
+	if (main)
+		rtl_set_bbreg(hw, RA_RFE_PINMUX + 4, BIT(29) | BIT(28), 0x1);
+	else
+		rtl_set_bbreg(hw, RA_RFE_PINMUX + 4, BIT(29) | BIT(28), 0x2);
+}
+
+#undef IQK_ADDA_REG_NUM
+#undef IQK_DELAY_TIME
+
+void rtl8812ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recove=
ry)
+{
+}
+
+void rtl8812ae_do_iqk(struct ieee80211_hw *hw, u8 delta_thermal_index,
+		      u8 thermal_value, u8 threshold)
+{
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+
+	rtldm->thermalvalue_iqk =3D thermal_value;
+	rtl8812ae_phy_iq_calibrate(hw, false);
+}
+
+void rtl8821ae_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recove=
ry)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	if (!rtlphy->lck_inprogress) {
+		spin_lock(&rtlpriv->locks.iqk_lock);
+		rtlphy->lck_inprogress =3D true;
+		spin_unlock(&rtlpriv->locks.iqk_lock);
+
+		_rtl8821ae_phy_iq_calibrate(hw);
+
+		spin_lock(&rtlpriv->locks.iqk_lock);
+		rtlphy->lck_inprogress =3D false;
+		spin_unlock(&rtlpriv->locks.iqk_lock);
+	}
+}
+
+void rtl8821ae_reset_iqk_result(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 i;
+
+	RT_TRACE(rtlpriv, COMP_IQK, DBG_LOUD,
+		 "rtl8812ae_dm_reset_iqk_result:: settings regs %d default regs %d\n=
",
+		 (int)(sizeof(rtlphy->iqk_matrix) /
+		 sizeof(struct iqk_matrix_regs)),
+		 IQK_MATRIX_SETTINGS_NUM);
+
+	for (i =3D 0; i < IQK_MATRIX_SETTINGS_NUM; i++) {
+		rtlphy->iqk_matrix[i].value[0][0] =3D 0x100;
+		rtlphy->iqk_matrix[i].value[0][2] =3D 0x100;
+		rtlphy->iqk_matrix[i].value[0][4] =3D 0x100;
+		rtlphy->iqk_matrix[i].value[0][6] =3D 0x100;
+
+		rtlphy->iqk_matrix[i].value[0][1] =3D 0x0;
+		rtlphy->iqk_matrix[i].value[0][3] =3D 0x0;
+		rtlphy->iqk_matrix[i].value[0][5] =3D 0x0;
+		rtlphy->iqk_matrix[i].value[0][7] =3D 0x0;
+
+		rtlphy->iqk_matrix[i].iqk_done =3D false;
+	}
+}
+
+void rtl8821ae_do_iqk(struct ieee80211_hw *hw, u8 delta_thermal_index,
+		      u8 thermal_value, u8 threshold)
+{
+	struct rtl_dm	*rtldm =3D rtl_dm(rtl_priv(hw));
+
+	rtl8821ae_reset_iqk_result(hw);
+
+	rtldm->thermalvalue_iqk =3D thermal_value;
+	rtl8821ae_phy_iq_calibrate(hw, false);
+}
+
+void rtl8821ae_phy_lc_calibrate(struct ieee80211_hw *hw)
+{
+}
+
+void rtl8821ae_phy_ap_calibrate(struct ieee80211_hw *hw, char delta)
+{
+}
+
+void rtl8821ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bma=
in)
+{
+	_rtl8821ae_phy_set_rfpath_switch(hw, bmain);
+}
+
+bool rtl8821ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type io=
type)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	bool postprocessing =3D false;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
+		  iotype, rtlphy->set_io_inprogress);
+	do {
+		switch (iotype) {
+		case IO_CMD_RESUME_DM_BY_SCAN:
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+				 "[IO CMD] Resume DM after scan.\n");
+			postprocessing =3D true;
+			break;
+		case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+		case IO_CMD_PAUSE_BAND1_DM_BY_SCAN:
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+				 "[IO CMD] Pause DM before scan.\n");
+			postprocessing =3D true;
+			break;
+		default:
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "switch case not process\n");
+			break;
+		}
+	} while (false);
+	if (postprocessing && !rtlphy->set_io_inprogress) {
+		rtlphy->set_io_inprogress =3D true;
+		rtlphy->current_io_type =3D iotype;
+	} else {
+		return false;
+	}
+	rtl8821ae_phy_set_io(hw);
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "IO Type(%#x)\n", iotype);
+	return true;
+}
+
+static void rtl8821ae_phy_set_io(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct dig_t *dm_digtable =3D &rtlpriv->dm_digtable;
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress);
+	switch (rtlphy->current_io_type) {
+	case IO_CMD_RESUME_DM_BY_SCAN:
+		if (rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_ADHOC)
+			_rtl8821ae_resume_tx_beacon(hw);
+		rtl8821ae_dm_write_dig(hw, rtlphy->initgain_backup.xaagccore1);
+		rtl8821ae_dm_write_cck_cca_thres(hw,
+						 rtlphy->initgain_backup.cca);
+		break;
+	case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+		if (rtlpriv->mac80211.opmode =3D=3D NL80211_IFTYPE_ADHOC)
+			_rtl8821ae_stop_tx_beacon(hw);
+		rtlphy->initgain_backup.xaagccore1 =3D dm_digtable->cur_igvalue;
+		rtl8821ae_dm_write_dig(hw, 0x17);
+		rtlphy->initgain_backup.cca =3D dm_digtable->cur_cck_cca_thres;
+		rtl8821ae_dm_write_cck_cca_thres(hw, 0x40);
+		break;
+	case IO_CMD_PAUSE_BAND1_DM_BY_SCAN:
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		break;
+	}
+	rtlphy->set_io_inprogress =3D false;
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
+		 "(%#x)\n", rtlphy->current_io_type);
+}
+
+static void rtl8821ae_phy_set_rf_on(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x2b);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
+	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
+}
+
+static bool _rtl8821ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
+					      enum rf_pwrstate rfpwr_state)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+	bool bresult =3D true;
+	u8 i, queue_id;
+	struct rtl8192_tx_ring *ring =3D NULL;
+
+	switch (rfpwr_state) {
+	case ERFON:
+		if ((ppsc->rfpwr_state =3D=3D ERFOFF) &&
+		    RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
+			bool rtstatus =3D false;
+			u32 initializecount =3D 0;
+
+			do {
+				initializecount++;
+				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+					 "IPS Set eRf nic enable\n");
+				rtstatus =3D rtl_ps_enable_nic(hw);
+			} while (!rtstatus && (initializecount < 10));
+			RT_CLEAR_PS_LEVEL(ppsc,
+					  RT_RF_OFF_LEVL_HALT_NIC);
+		} else {
+			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+				 "Set ERFON sleeped:%d ms\n",
+				  jiffies_to_msecs(jiffies -
+						   ppsc->
+						   last_sleep_jiffies));
+			ppsc->last_awake_jiffies =3D jiffies;
+			rtl8821ae_phy_set_rf_on(hw);
+		}
+		if (mac->link_state =3D=3D MAC80211_LINKED) {
+			rtlpriv->cfg->ops->led_control(hw,
+						       LED_CTL_LINK);
+		} else {
+			rtlpriv->cfg->ops->led_control(hw,
+						       LED_CTL_NO_LINK);
+		}
+		break;
+	case ERFOFF:
+		for (queue_id =3D 0, i =3D 0;
+		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
+			ring =3D &pcipriv->dev.tx_ring[queue_id];
+			if (queue_id =3D=3D BEACON_QUEUE ||
+			    skb_queue_len(&ring->queue) =3D=3D 0) {
+				queue_id++;
+				continue;
+			} else {
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =3D%d before doze!\n",
+					 (i + 1), queue_id,
+					 skb_queue_len(&ring->queue));
+
+				udelay(10);
+				i++;
+			}
+			if (i >=3D MAX_DOZE_WAITING_TIMES_9x) {
+				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+					 "\n ERFSLEEP: %d times TcbBusyQueue[%d] =3D %d !\n",
+					  MAX_DOZE_WAITING_TIMES_9x,
+					  queue_id,
+					  skb_queue_len(&ring->queue));
+				break;
+			}
+		}
+
+		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
+			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
+				 "IPS Set eRf nic disable\n");
+			rtl_ps_disable_nic(hw);
+			RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+		} else {
+			if (ppsc->rfoff_reason =3D=3D RF_CHANGE_BY_IPS) {
+				rtlpriv->cfg->ops->led_control(hw,
+							       LED_CTL_NO_LINK);
+			} else {
+				rtlpriv->cfg->ops->led_control(hw,
+							       LED_CTL_POWER_OFF);
+			}
+		}
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not process\n");
+		bresult =3D false;
+		break;
+	}
+	if (bresult)
+		ppsc->rfpwr_state =3D rfpwr_state;
+	return bresult;
+}
+
+bool rtl8821ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				      enum rf_pwrstate rfpwr_state)
+{
+	struct rtl_ps_ctl *ppsc =3D rtl_psc(rtl_priv(hw));
+
+	bool bresult =3D false;
+
+	if (rfpwr_state =3D=3D ppsc->rfpwr_state)
+		return bresult;
+	bresult =3D _rtl8821ae_phy_set_rf_power_state(hw, rfpwr_state);
+	return bresult;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/phy.h b/drivers/net=
/wireless/rtlwifi/rtl8821ae/phy.h
new file mode 100644
index 0000000..c411f0a
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/phy.h
@@ -0,0 +1,259 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_PHY_H__
+#define __RTL8821AE_PHY_H__
+
+/* MAX_TX_COUNT must always be set to 4, otherwise read
+ * efuse table sequence will be wrong.
+ */
+#define MAX_TX_COUNT				4
+#define	TX_1S					0
+#define	TX_2S					1
+#define	TX_3S					2
+#define	TX_4S					3
+
+#define	MAX_POWER_INDEX				0x3F
+
+#define MAX_PRECMD_CNT				16
+#define MAX_RFDEPENDCMD_CNT			16
+#define MAX_POSTCMD_CNT				16
+
+#define MAX_DOZE_WAITING_TIMES_9x		64
+
+#define RT_CANNOT_IO(hw)			false
+#define HIGHPOWER_RADIOA_ARRAYLEN		22
+
+#define IQK_ADDA_REG_NUM			16
+#define IQK_BB_REG_NUM				9
+#define MAX_TOLERANCE				5
+#define	IQK_DELAY_TIME				10
+#define	index_mapping_NUM			15
+
+#define	APK_BB_REG_NUM				5
+#define	APK_AFE_REG_NUM				16
+#define	APK_CURVE_REG_NUM			4
+#define	PATH_NUM				2
+
+#define LOOP_LIMIT				5
+#define MAX_STALL_TIME				50
+#define AntennaDiversityValue			0x80
+#define MAX_TXPWR_IDX_NMODE_92S			63
+#define Reset_Cnt_Limit				3
+
+#define IQK_ADDA_REG_NUM			16
+#define IQK_MAC_REG_NUM				4
+
+#define RF6052_MAX_PATH				2
+
+#define CT_OFFSET_MAC_ADDR			0X16
+
+#define CT_OFFSET_CCK_TX_PWR_IDX		0x5A
+#define CT_OFFSET_HT401S_TX_PWR_IDX		0x60
+#define CT_OFFSET_HT402S_TX_PWR_IDX_DIFF	0x66
+#define CT_OFFSET_HT20_TX_PWR_IDX_DIFF		0x69
+#define CT_OFFSET_OFDM_TX_PWR_IDX_DIFF		0x6C
+
+#define CT_OFFSET_HT40_MAX_PWR_OFFSET		0x6F
+#define CT_OFFSET_HT20_MAX_PWR_OFFSET		0x72
+
+#define CT_OFFSET_CHANNEL_PLAH			0x75
+#define CT_OFFSET_THERMAL_METER			0x78
+#define CT_OFFSET_RF_OPTION			0x79
+#define CT_OFFSET_VERSION			0x7E
+#define CT_OFFSET_CUSTOMER_ID			0x7F
+
+#define RTL8821AE_MAX_PATH_NUM			2
+
+#define TARGET_CHNL_NUM_2G_5G_8812		59
+
+enum swchnlcmd_id {
+	CMDID_END,
+	CMDID_SET_TXPOWEROWER_LEVEL,
+	CMDID_BBREGWRITE10,
+	CMDID_WRITEPORT_ULONG,
+	CMDID_WRITEPORT_USHORT,
+	CMDID_WRITEPORT_UCHAR,
+	CMDID_RF_WRITEREG,
+};
+
+struct swchnlcmd {
+	enum swchnlcmd_id cmdid;
+	u32 para1;
+	u32 para2;
+	u32 msdelay;
+};
+
+enum hw90_block_e {
+	HW90_BLOCK_MAC =3D 0,
+	HW90_BLOCK_PHY0 =3D 1,
+	HW90_BLOCK_PHY1 =3D 2,
+	HW90_BLOCK_RF =3D 3,
+	HW90_BLOCK_MAXIMUM =3D 4,
+};
+
+enum baseband_config_type {
+	BASEBAND_CONFIG_PHY_REG =3D 0,
+	BASEBAND_CONFIG_AGC_TAB =3D 1,
+};
+
+enum ra_offset_area {
+	RA_OFFSET_LEGACY_OFDM1,
+	RA_OFFSET_LEGACY_OFDM2,
+	RA_OFFSET_HT_OFDM1,
+	RA_OFFSET_HT_OFDM2,
+	RA_OFFSET_HT_OFDM3,
+	RA_OFFSET_HT_OFDM4,
+	RA_OFFSET_HT_CCK,
+};
+
+enum antenna_path {
+	ANTENNA_NONE,
+	ANTENNA_D,
+	ANTENNA_C,
+	ANTENNA_CD,
+	ANTENNA_B,
+	ANTENNA_BD,
+	ANTENNA_BC,
+	ANTENNA_BCD,
+	ANTENNA_A,
+	ANTENNA_AD,
+	ANTENNA_AC,
+	ANTENNA_ACD,
+	ANTENNA_AB,
+	ANTENNA_ABD,
+	ANTENNA_ABC,
+	ANTENNA_ABCD
+};
+
+struct r_antenna_select_ofdm {
+	u32 r_tx_antenna:4;
+	u32 r_ant_l:4;
+	u32 r_ant_non_ht:4;
+	u32 r_ant_ht1:4;
+	u32 r_ant_ht2:4;
+	u32 r_ant_ht_s1:4;
+	u32 r_ant_non_ht_s1:4;
+	u32 ofdm_txsc:2;
+	u32 reserved:2;
+};
+
+struct r_antenna_select_cck {
+	u8 r_cckrx_enable_2:2;
+	u8 r_cckrx_enable:2;
+	u8 r_ccktx_enable:4;
+};
+
+struct efuse_contents {
+	u8 mac_addr[ETH_ALEN];
+	u8 cck_tx_power_idx[6];
+	u8 ht40_1s_tx_power_idx[6];
+	u8 ht40_2s_tx_power_idx_diff[3];
+	u8 ht20_tx_power_idx_diff[3];
+	u8 ofdm_tx_power_idx_diff[3];
+	u8 ht40_max_power_offset[3];
+	u8 ht20_max_power_offset[3];
+	u8 channel_plan;
+	u8 thermal_meter;
+	u8 rf_option[5];
+	u8 version;
+	u8 oem_id;
+	u8 regulatory;
+};
+
+struct tx_power_struct {
+	u8 cck[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 ht40_1s[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 ht40_2s[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 ht20_diff[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 legacy_ht_diff[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 legacy_ht_txpowerdiff;
+	u8 groupht20[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 groupht40[RTL8821AE_MAX_PATH_NUM][CHANNEL_MAX_NUMBER];
+	u8 pwrgroup_cnt;
+	u32 mcs_original_offset[4][16];
+};
+enum _ANT_DIV_TYPE {
+	NO_ANTDIV			=3D 0xFF,
+	CG_TRX_HW_ANTDIV		=3D 0x01,
+	CGCS_RX_HW_ANTDIV		=3D 0x02,
+	FIXED_HW_ANTDIV     		=3D 0x03,
+	CG_TRX_SMART_ANTDIV		=3D 0x04,
+	CGCS_RX_SW_ANTDIV		=3D 0x05,
+
+};
+
+u32 rtl8821ae_phy_query_bb_reg(struct ieee80211_hw *hw,
+			       u32 regaddr, u32 bitmask);
+void rtl8821ae_phy_set_bb_reg(struct ieee80211_hw *hw,
+			      u32 regaddr, u32 bitmask, u32 data);
+u32 rtl8821ae_phy_query_rf_reg(struct ieee80211_hw *hw,
+			       enum radio_path rfpath, u32 regaddr,
+			       u32 bitmask);
+void rtl8821ae_phy_set_rf_reg(struct ieee80211_hw *hw,
+			      enum radio_path rfpath, u32 regaddr,
+			      u32 bitmask, u32 data);
+bool rtl8821ae_phy_mac_config(struct ieee80211_hw *hw);
+bool rtl8821ae_phy_bb_config(struct ieee80211_hw *hw);
+bool rtl8821ae_phy_rf_config(struct ieee80211_hw *hw);
+void rtl8821ae_phy_switch_wirelessband(struct ieee80211_hw *hw,
+				       u8 band);
+void rtl8821ae_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+void rtl8821ae_phy_get_txpower_level(struct ieee80211_hw *hw,
+				     long *powerlevel);
+void rtl8821ae_phy_set_txpower_level(struct ieee80211_hw *hw,
+				     u8 channel);
+void rtl8821ae_phy_scan_operation_backup(struct ieee80211_hw *hw,
+					 u8 operation);
+void rtl8821ae_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl8821ae_phy_set_bw_mode(struct ieee80211_hw *hw,
+			       enum nl80211_channel_type ch_type);
+void rtl8821ae_phy_sw_chnl_callback(struct ieee80211_hw *hw);
+u8 rtl8821ae_phy_sw_chnl(struct ieee80211_hw *hw);
+void rtl8821ae_phy_iq_calibrate(struct ieee80211_hw *hw,
+				bool b_recovery);
+void rtl8812ae_phy_iq_calibrate(struct ieee80211_hw *hw,
+				bool b_recovery);
+void rtl8821ae_phy_ap_calibrate(struct ieee80211_hw *hw, char delta);
+void rtl8821ae_phy_lc_calibrate(struct ieee80211_hw *hw);
+void rtl8821ae_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bma=
in);
+bool rtl8812ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					     enum radio_path rfpath);
+bool rtl8821ae_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					     enum radio_path rfpath);
+bool rtl8821ae_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type io=
type);
+bool rtl8821ae_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				      enum rf_pwrstate rfpwr_state);
+u8 _rtl8812ae_get_right_chnl_place_for_iqk(u8 chnl);
+void rtl8821ae_phy_set_txpower_level_by_path(struct ieee80211_hw *hw,
+					     u8 channel, u8 path);
+void rtl8812ae_do_iqk(struct ieee80211_hw *hw, u8 delta_thermal_index,
+	u8 thermal_value, u8 threshold);
+void rtl8821ae_do_iqk(struct ieee80211_hw *hw, u8 delta_thermal_index,
+		      u8 thermal_value, u8 threshold);
+void rtl8821ae_reset_iqk_result(struct ieee80211_hw *hw);
+u32 phy_get_tx_swing_8812A(struct ieee80211_hw *hw, u8 band, u8 rf_pat=
h);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c b/drivers/=
net/wireless/rtlwifi/rtl8821ae/pwrseq.c
new file mode 100644
index 0000000..9ddf78a
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.c
@@ -0,0 +1,182 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../pwrseqcmd.h"
+#include "pwrseq.h"
+
+/* drivers should parse below arrays and do the corresponding actions =
*/
+/* 3 Power on  Array */
+struct wlan_pwr_cfg rtl8812_power_on_flow[RTL8812_TRANS_CARDEMU_TO_ACT=
_STEPS +
+					RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_CARDEMU_TO_ACT
+	RTL8812_TRANS_END
+};
+
+/* 3Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8812_radio_off_flow[RTL8812_TRANS_ACT_TO_CARDEM=
U_STEPS +
+						RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_ACT_TO_CARDEMU
+	RTL8812_TRANS_END
+};
+
+/* 3Card Disable Array */
+struct wlan_pwr_cfg rtl8812_card_disable_flow[RTL8812_TRANS_ACT_TO_CAR=
DEMU_STEPS
+	+ RTL8812_TRANS_CARDEMU_TO_PDN_STEPS
+	+ RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_ACT_TO_CARDEMU
+	RTL8812_TRANS_CARDEMU_TO_CARDDIS
+	RTL8812_TRANS_END
+};
+
+/* 3 Card Enable Array */
+struct wlan_pwr_cfg rtl8812_card_enable_flow[RTL8812_TRANS_ACT_TO_CARD=
EMU_STEPS
+	+ RTL8812_TRANS_CARDEMU_TO_PDN_STEPS
+	+ RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_CARDDIS_TO_CARDEMU
+	RTL8812_TRANS_CARDEMU_TO_ACT
+	RTL8812_TRANS_END
+};
+
+/* 3Suspend Array */
+struct wlan_pwr_cfg rtl8812_suspend_flow[RTL8812_TRANS_ACT_TO_CARDEMU_=
STEPS +
+					RTL8812_TRANS_CARDEMU_TO_SUS_STEPS +
+					RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_ACT_TO_CARDEMU
+	RTL8812_TRANS_CARDEMU_TO_SUS
+	RTL8812_TRANS_END
+};
+
+/* 3 Resume Array */
+struct wlan_pwr_cfg rtl8812_resume_flow[RTL8812_TRANS_ACT_TO_CARDEMU_S=
TEPS +
+					RTL8812_TRANS_CARDEMU_TO_SUS_STEPS +
+					RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_SUS_TO_CARDEMU
+	RTL8812_TRANS_CARDEMU_TO_ACT
+	RTL8812_TRANS_END
+};
+
+/* 3HWPDN Array */
+struct wlan_pwr_cfg rtl8812_hwpdn_flow[RTL8812_TRANS_ACT_TO_CARDEMU_ST=
EPS +
+					RTL8812_TRANS_CARDEMU_TO_PDN_STEPS +
+					RTL8812_TRANS_END_STEPS] =3D {
+	RTL8812_TRANS_ACT_TO_CARDEMU
+	RTL8812_TRANS_CARDEMU_TO_PDN
+	RTL8812_TRANS_END
+};
+
+/* 3 Enter LPS */
+struct wlan_pwr_cfg rtl8812_enter_lps_flow[RTL8812_TRANS_ACT_TO_LPS_ST=
EPS +
+						RTL8812_TRANS_END_STEPS] =3D {
+	/* FW behavior */
+	RTL8812_TRANS_ACT_TO_LPS
+	RTL8812_TRANS_END
+};
+
+/* 3 Leave LPS */
+struct wlan_pwr_cfg rtl8812_leave_lps_flow[RTL8812_TRANS_LPS_TO_ACT_ST=
EPS +
+						RTL8812_TRANS_END_STEPS] =3D {
+	/* FW behavior */
+	RTL8812_TRANS_LPS_TO_ACT
+	RTL8812_TRANS_END
+};
+
+/* drivers should parse below arrays and do the corresponding actions =
*/
+/*3 Power on  Array*/
+struct wlan_pwr_cfg rtl8821A_power_on_flow[RTL8821A_TRANS_CARDEMU_TO_A=
CT_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_CARDEMU_TO_ACT
+	RTL8821A_TRANS_END
+};
+
+/*3Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8821A_radio_off_flow[RTL8821A_TRANS_ACT_TO_CARD=
EMU_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_ACT_TO_CARDEMU
+	RTL8821A_TRANS_END
+};
+
+/*3Card Disable Array*/
+struct wlan_pwr_cfg rtl8821A_card_disable_flow
+					[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_ACT_TO_CARDEMU
+	RTL8821A_TRANS_CARDEMU_TO_CARDDIS
+	RTL8821A_TRANS_END
+};
+
+/*3 Card Enable Array*/
+/*RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS*/
+struct wlan_pwr_cfg rtl8821A_card_enable_flow
+					[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS
+					+ RTL8821A_TRANS_CARDEMU_TO_ACT_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_CARDDIS_TO_CARDEMU
+	RTL8821A_TRANS_CARDEMU_TO_ACT
+	RTL8821A_TRANS_END
+};
+
+/*3Suspend Array*/
+struct wlan_pwr_cfg rtl8821A_suspend_flow[RTL8821A_TRANS_ACT_TO_CARDEM=
U_STEPS
+					+ RTL8821A_TRANS_CARDEMU_TO_SUS_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_ACT_TO_CARDEMU
+	RTL8821A_TRANS_CARDEMU_TO_SUS
+	RTL8821A_TRANS_END
+};
+
+/*3 Resume Array*/
+struct wlan_pwr_cfg rtl8821A_resume_flow[RTL8821A_TRANS_ACT_TO_CARDEMU=
_STEPS
+					+ RTL8821A_TRANS_CARDEMU_TO_SUS_STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_SUS_TO_CARDEMU
+	RTL8821A_TRANS_CARDEMU_TO_ACT
+	RTL8821A_TRANS_END
+};
+
+/*3HWPDN Array*/
+struct wlan_pwr_cfg rtl8821A_hwpdn_flow[RTL8821A_TRANS_ACT_TO_CARDEMU_=
STEPS
+				+ RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS
+				+ RTL8821A_TRANS_END_STEPS] =3D {
+	RTL8821A_TRANS_ACT_TO_CARDEMU
+	RTL8821A_TRANS_CARDEMU_TO_PDN
+	RTL8821A_TRANS_END
+};
+
+/*3 Enter LPS */
+struct wlan_pwr_cfg rtl8821A_enter_lps_flow[RTL8821A_TRANS_ACT_TO_LPS_=
STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	/*FW behavior*/
+	RTL8821A_TRANS_ACT_TO_LPS
+	RTL8821A_TRANS_END
+};
+
+/*3 Leave LPS */
+struct wlan_pwr_cfg rtl8821A_leave_lps_flow[RTL8821A_TRANS_LPS_TO_ACT_=
STEPS
+					+ RTL8821A_TRANS_END_STEPS] =3D {
+	/*FW behavior*/
+	RTL8821A_TRANS_LPS_TO_ACT
+	RTL8821A_TRANS_END
+};
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h b/drivers/=
net/wireless/rtlwifi/rtl8821ae/pwrseq.h
new file mode 100644
index 0000000..bf0b0ce
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h
@@ -0,0 +1,738 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_PWRSEQ_H__
+#define __RTL8821AE_PWRSEQ_H__
+
+#include "../pwrseqcmd.h"
+#include "../btcoexist/halbt_precomp.h"
+
+#define	RTL8812_TRANS_CARDEMU_TO_ACT_STEPS	15
+#define	RTL8812_TRANS_ACT_TO_CARDEMU_STEPS	15
+#define	RTL8812_TRANS_CARDEMU_TO_SUS_STEPS	15
+#define	RTL8812_TRANS_SUS_TO_CARDEMU_STEPS	15
+#define	RTL8812_TRANS_CARDEMU_TO_PDN_STEPS	25
+#define	RTL8812_TRANS_PDN_TO_CARDEMU_STEPS	15
+#define	RTL8812_TRANS_ACT_TO_LPS_STEPS		15
+#define	RTL8812_TRANS_LPS_TO_ACT_STEPS		15
+#define	RTL8812_TRANS_END_STEPS			1
+
+/* The following macros have the following format:
+ * { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value
+ *   comments },
+ */
+#define RTL8812_TRANS_CARDEMU_TO_ACT					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT2, 0 \
+	/* disable SW LPS 0x04[10]=3D0*/},	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT1, BIT1 \
+	/* wait till 0x04[17] =3D 1    power ready*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, 0 \
+	/* disable HWPDN 0x04[15]=3D0*/}, \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3, 0 \
+	/* disable WL suspend*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/* polling until return 0*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT0, 0},
+
+#define RTL8812_TRANS_ACT_TO_CARDEMU													\
+	{0x0c00, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x04 \
+	 /* 0xc00[7:0] =3D 4	turn off 3-wire */},	\
+	{0x0e00, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x04 \
+	 /* 0xe00[7:0] =3D 4	turn off 3-wire */},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	 /* 0x2[0] =3D 0	 RESET BB, CLOSE RF */},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US \
+	/*Delay 1us*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	  /* Whole BB is reset*/},			\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x2A \
+	 /* 0x07[7:0] =3D 0x28 sps pwm mode 0x2a for BT coex*/},	\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x02, 0 \
+	/*0x8[1] =3D 0 ANA clk =3D500k */},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	 /*0x04[9] =3D 1 turn off MAC by HW state machine*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT1, 0 \
+	 /*wait till 0x04[9] =3D 0 polling until return 0 to disable*/},
+
+#define RTL8812_TRANS_CARDEMU_TO_SUS					\
+	{0x0042, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xF0, 0xcc}, \
+	{0x0042, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xF0, 0xEC}, \
+	{0x0043, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x07 \
+	/* gpio11 input mode, gpio10~8 output mode */},	\
+	{0x0045, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio 0~7 output same value as input ?? */},	\
+	{0x0046, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xff \
+	/* gpio0~7 output mode */},	\
+	{0x0047, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/* 0x47[7:0] =3D 00 gpio mode */},	\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/* suspend option all off */},	\
+	{0x0014, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x80, BIT7 \
+	/*0x14[7] =3D 1 turn on ZCD */},	\
+	{0x0015, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x01, BIT0 \
+	/* 0x15[0] =3D1 trun on ZCD */},	\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x10, BIT4 \
+	/*0x23[4] =3D 1 hpon LDO sleep mode */},	\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x02, 0 \
+	/*0x8[1] =3D 0 ANA clk =3D500k */},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3, BIT3 \
+	/*0x04[11] =3D 2b'11 enable WL suspend for PCIe*/},
+
+#define RTL8812_TRANS_SUS_TO_CARDEMU					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3, 0 \
+	/*0x04[11] =3D 2b'01enable WL suspend*/},   \
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x10, 0 \
+	/*0x23[4] =3D 0 hpon LDO sleep mode leave */},	\
+	{0x0015, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x01, 0 \
+	/* 0x15[0] =3D0 trun off ZCD */},	\
+	{0x0014, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x80, 0 \
+	/*0x14[7] =3D 0 turn off ZCD */},	\
+	{0x0046, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio0~7 input mode */},	\
+	{0x0043, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio11 input mode, gpio10~8 input mode */},
+
+#define RTL8812_TRANS_CARDEMU_TO_CARDDIS				\
+	{0x0003, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT2, 0 \
+	/*0x03[2] =3D 0, reset 8051*/},	\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x05 \
+	/*0x80=3D05h if reload fw, fill the default value of host_CPU handsha=
ke field*/},	\
+	{0x0042, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xF0, 0xcc}, \
+	{0x0042, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xF0, 0xEC}, \
+	{0x0043, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x07 \
+	/* gpio11 input mode, gpio10~8 output mode */},	\
+	{0x0045, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio 0~7 output same value as input ?? */},	\
+	{0x0046, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xff \
+	/* gpio0~7 output mode */},	\
+	{0x0047, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/* 0x47[7:0] =3D 00 gpio mode */},	\
+	{0x0014, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x80, BIT7 \
+	/*0x14[7] =3D 1 turn on ZCD */},	\
+	{0x0015, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x01, BIT0 \
+	/* 0x15[0] =3D1 trun on ZCD */},	\
+	{0x0012, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x01, 0 \
+	/*0x12[0] =3D 0 force PFM mode */},	\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x10, BIT4 \
+	/*0x23[4] =3D 1 hpon LDO sleep mode */},	\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x02, 0 \
+	/*0x8[1] =3D 0 ANA clk =3D500k */},	\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20 \
+	 /*0x07=3D0x20 , SOP option to disable BG/MB*/},	\
+	{0x001f, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	 /*0x01f[1]=3D0 , disable RFC_0  control  REG_RF_CTRL_8812 */},	\
+	{0x0076, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	 /*0x076[1]=3D0 , disable RFC_1  control REG_OPT_CTRL_8812 +2 */},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3, BIT3 \
+	 /*0x04[11] =3D 2b'01 enable WL suspend*/},
+
+#define RTL8812_TRANS_CARDDIS_TO_CARDEMU				\
+	{0x0012, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/*0x12[0] =3D 1 force PWM mode */},	\
+	{0x0014, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x80, 0 \
+	/*0x14[7] =3D 0 turn off ZCD */},	\
+	{0x0015, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x01, 0 \
+	/* 0x15[0] =3D0 trun off ZCD */},	\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0x10, 0 \
+	/*0x23[4] =3D 0 hpon LDO leave sleep mode */},	\
+	{0x0046, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio0~7 input mode */},	\
+	{0x0043, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/* gpio11 input mode, gpio10~8 input mode */}, \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT2, 0 \
+	 /*0x04[10] =3D 0, enable SW LPS PCIE only*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3, 0 \
+	 /*0x04[11] =3D 2b'01enable WL suspend*/},	\
+	{0x0003, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT2, BIT2 \
+	 /*0x03[2] =3D 1, enable 8051*/},	\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/*PCIe DMA start*/},
+
+#define RTL8812_TRANS_CARDEMU_TO_PDN		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, BIT7 \
+	/* 0x04[15] =3D 1*/},
+
+#define RTL8812_TRANS_PDN_TO_CARDEMU			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, 0 \
+	/* 0x04[15] =3D 0*/},
+
+#define RTL8812_TRANS_ACT_TO_LPS		\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF \
+	/*PCIe DMA stop*/},	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x7F \
+	/*Tx Pause*/},		\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x0c00, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x04 \
+	 /* 0xc00[7:0] =3D 4	turn off 3-wire */},	\
+	{0x0e00, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x04 \
+	 /* 0xe00[7:0] =3D 4	turn off 3-wire */},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	/*CCK and OFDM are disabled,and clock are gated,and RF closed*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US \
+	/*Delay 1us*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	  /* Whole BB is reset*/},			\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x03 \
+	/*Reset MAC TRX*/},			\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	/*check if removed later*/},		\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, BIT5 \
+	/*Respond TxOK to scheduler*/},
+
+#define RTL8812_TRANS_LPS_TO_ACT					\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*SDIO RPWM*/},	\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*USB RPWM*/},	\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*PCIe RPWM*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS \
+	 /*Delay*/},	\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0 \
+	 /*.	0x08[4] =3D 0		 switch TSF to 40M*/},	\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT7, 0 \
+	 /*Polling 0x109[7]=3D0  TSF in 40M*/},			\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT6|BIT7, 0 \
+	 /*.	0x29[7:6] =3D 2b'00	 enable BB clock*/},	\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	 /*.	0x101[1] =3D 1*/},					\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF \
+	 /*.	0x100[7:0] =3D 0xFF	 enable WMAC TRX*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1|BIT0, BIT1|BIT0 \
+	 /*.	0x02[1:0] =3D 2b'11	 enable BB macro*/},	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	 /*.	0x522 =3D 0*/},
+
+#define RTL8812_TRANS_END					\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK, \
+	0, PWR_CMD_END, 0, 0},
+
+extern struct wlan_pwr_cfg  rtl8812_power_on_flow
+		[RTL8812_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_radio_off_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_card_disable_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_card_enable_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_suspend_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_resume_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_hwpdn_flow
+		[RTL8812_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8812_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_enter_lps_flow
+		[RTL8812_TRANS_ACT_TO_LPS_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg  rtl8812_leave_lps_flow
+		[RTL8812_TRANS_LPS_TO_ACT_STEPS +
+		 RTL8812_TRANS_END_STEPS];
+
+/* Check document WM-20130516-JackieLau-RTL8821A_Power_Architecture-R1=
0.vsd
+ *	There are 6 HW Power States:
+ *	0: POFF--Power Off
+ *	1: PDN--Power Down
+ *	2: CARDEMU--Card Emulation
+ *	3: ACT--Active Mode
+ *	4: LPS--Low Power State
+ *	5: SUS--Suspend
+ *
+ *	The transision from different states are defined below
+ *	TRANS_CARDEMU_TO_ACT
+ *	TRANS_ACT_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_SUS
+ *	TRANS_SUS_TO_CARDEMU
+ *	TRANS_CARDEMU_TO_PDN
+ *	TRANS_ACT_TO_LPS
+ *	TRANS_LPS_TO_ACT
+ *
+ *	TRANS_END
+ */
+#define	RTL8821A_TRANS_CARDEMU_TO_ACT_STEPS	25
+#define	RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS	15
+#define	RTL8821A_TRANS_CARDEMU_TO_SUS_STEPS	15
+#define	RTL8821A_TRANS_SUS_TO_CARDEMU_STEPS	15
+#define RTL8821A_TRANS_CARDDIS_TO_CARDEMU_STEPS	15
+#define	RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS	15
+#define	RTL8821A_TRANS_PDN_TO_CARDEMU_STEPS	15
+#define	RTL8821A_TRANS_ACT_TO_LPS_STEPS		15
+#define	RTL8821A_TRANS_LPS_TO_ACT_STEPS		15
+#define	RTL8821A_TRANS_END_STEPS		1
+
+#define RTL8821A_TRANS_CARDEMU_TO_ACT					\
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	 /*0x20[0] =3D 1b'1 enable LDOA12 MACRO block for all interface*/},  =
 \
+	{0x0067, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,		\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0 \
+	 /*0x67[0] =3D 0 to disable BT_GPS_SEL pins*/},	\
+	{0x0001, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 1, PWRSEQ_DELAY_MS \
+	/*Delay 1ms*/},   \
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, 0 \
+	 /*0x00[5] =3D 1b'0 release analog Ips to digital ,1:isolation*/},   =
\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT4|BIT3|BIT2), 0 \
+	/* disable SW LPS 0x04[10]=3D0 and WLSUS_EN 0x04[12:11]=3D0*/},	\
+	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0 , BIT0 \
+	/* Disable USB suspend */},	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT1, BIT1 \
+	/* wait till 0x04[17] =3D 1    power ready*/},	\
+	{0x0075, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0 , 0 \
+	/* Enable USB suspend */},	\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/* release WLON reset  0x04[16]=3D1*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, 0 \
+	/* disable HWPDN 0x04[15]=3D0*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT4|BIT3), 0 \
+	/* disable WL suspend*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/* polling until return 0*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT0, 0 \
+	/**/},	\
+	{0x004F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/*0x4C[24] =3D 0x4F[0] =3D 1, switch DPDT_SEL_P output from WL BB */}=
,\
+	{0x0067, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, (BIT5|BIT4), (BIT5|BIT4) \
+	/*0x66[13] =3D 0x67[5] =3D 1, switch for PAPE_G/PAPE_A 	\
+	 from WL BB ; 0x66[12] =3D 0x67[4] =3D 1, switch LNAON from WL BB */}=
,\
+	{0x0025, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT6, 0 \
+	/*anapar_mac<118> , 0x25[6]=3D0 by wlan single function*/},\
+	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	/*Enable falling edge triggering interrupt*/},\
+	{0x0063, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	/*Enable GPIO9 interrupt mode*/},\
+	{0x0062, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	/*Enable GPIO9 input mode*/},\
+	{0x0058, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, BIT0 \
+	/*Enable HSISR GPIO[C:0] interrupt*/},\
+	{0x005A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	/*Enable HSISR GPIO9 interrupt*/},\
+	{0x007A, PWR_CUT_TESTCHIP_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x3A \
+	/*0x7A =3D 0x3A start BT*/},\
+	{0x002E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF , 0x82  \
+	/* 0x2C[23:12]=3D0x820 ; XTAL trim */}, \
+	{0x0010, PWR_CUT_A_MSK , PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT6 , BIT6  \
+	/* 0x10[6]=3D1  */},
+
+#define RTL8821A_TRANS_ACT_TO_CARDEMU					\
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/*0x1F[7:0] =3D 0 turn off RF*/},	\
+	{0x004F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	/*0x4C[24] =3D 0x4F[0] =3D 0, switch DPDT_SEL_P output from		\
+	 register 0x65[2] */},\
+	{0x0049, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	/*Enable rising edge triggering interrupt*/}, \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	 /*0x04[9] =3D 1 turn off MAC by HW state machine*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT1, 0 \
+	 /*wait till 0x04[9] =3D 0 polling until return 0 to disable*/},	\
+	{0x0000, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, BIT5 \
+	 /*0x00[5] =3D 1b'1 analog Ips to digital ,1:isolation*/},   \
+	{0x0020, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,		\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	 /*0x20[0] =3D 1b'0 disable LDOA12 MACRO block*/},
+
+#define RTL8821A_TRANS_CARDEMU_TO_SUS					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4|BIT3, (BIT4|BIT3) \
+	 /*0x04[12:11] =3D 2b'11 enable WL suspend for PCIe*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,		\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3 \
+	 /*0x04[12:11] =3D 2b'01 enable WL suspend*/},	\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4 \
+	 /*0x23[4] =3D 1b'1 12H LDO enter sleep mode*/},   \
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20 \
+	 /*0x07[7:0] =3D 0x20 SDIO SOP option to disable BG/MB/ACK/SWR*/},   =
\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3|BIT4 \
+	 /*0x04[12:11] =3D 2b'11 enable WL suspend for PCIe*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT0, BIT0 \
+	 /*Set SDIO suspend local register*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT1, 0 \
+	 /*wait power state to suspend*/},
+
+#define RTL8821A_TRANS_SUS_TO_CARDEMU					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3 | BIT7, 0 \
+	 /*clear suspend enable and power down enable*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT0, 0 \
+	 /*Set SDIO suspend local register*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT1, BIT1 \
+	 /*wait power state to suspend*/},\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0 \
+	 /*0x23[4] =3D 1b'0 12H LDO enter normal mode*/},   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, 0 \
+	 /*0x04[12:11] =3D 2b'01enable WL suspend*/},
+
+#define RTL8821A_TRANS_CARDEMU_TO_CARDDIS				\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20 \
+	 /*0x07=3D0x20 , SOP option to disable BG/MB*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,		\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, BIT3 \
+	 /*0x04[12:11] =3D 2b'01 enable WL suspend*/},	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT2, BIT2 \
+	 /*0x04[10] =3D 1, enable SW LPS*/},	\
+        {0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 1 \
+	 /*0x48[16] =3D 1 to enable GPIO9 as EXT WAKEUP*/},   \
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4 \
+	 /*0x23[4] =3D 1b'1 12H LDO enter sleep mode*/},   \
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT0, BIT0 \
+	 /*Set SDIO suspend local register*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT1, 0 \
+	 /*wait power state to suspend*/},
+
+#define RTL8821A_TRANS_CARDDIS_TO_CARDEMU				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3 | BIT7, 0 \
+	 /*clear suspend enable and power down enable*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, BIT0, 0 \
+	 /*Set SDIO suspend local register*/},	\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_POLLING, BIT1, BIT1 \
+	 /*wait power state to suspend*/},\
+	{0x004A, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	 /*0x48[16] =3D 0 to disable GPIO9 as EXT WAKEUP*/},   \
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT3|BIT4, 0 \
+	 /*0x04[12:11] =3D 2b'01enable WL suspend*/},\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0 \
+	 /*0x23[4] =3D 1b'0 12H LDO enter normal mode*/},   \
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	/*PCIe DMA start*/},
+
+#define RTL8821A_TRANS_CARDEMU_TO_PDN					\
+	{0x0023, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, BIT4 \
+	 /*0x23[4] =3D 1b'1 12H LDO enter sleep mode*/},   \
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,		\
+	 PWR_INTF_SDIO_MSK|PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x20 \
+	 /*0x07[7:0] =3D 0x20 SOP option to disable BG/MB/ACK/SWR*/},   \
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	/* 0x04[16] =3D 0*/},\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, BIT7 \
+	/* 0x04[15] =3D 1*/},
+
+#define RTL8821A_TRANS_PDN_TO_CARDEMU				\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT7, 0 \
+	/* 0x04[15] =3D 0*/},
+
+#define RTL8821A_TRANS_ACT_TO_LPS					\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF \
+	/*PCIe DMA stop*/},	\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF \
+	/*Tx Pause*/},	\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, 0xFF, 0 \
+	/*Should be zero if no packet is transmitting*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT0, 0 \
+	/*CCK and OFDM are disabled,and clock are gated*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US \
+	/*Delay 1us*/},	\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	/*Whole BB is reset*/},	\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x03 \
+	/*Reset MAC TRX*/},	\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, 0 \
+	/*check if removed later*/},	\
+	{0x0093, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x00 \
+	/*When driver enter Sus/ Disable, enable LOP for BT*/},	\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT5, BIT5 \
+	/*Respond TxOK to scheduler*/},
+
+#define RTL8821A_TRANS_LPS_TO_ACT					\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,\
+	PWR_BASEADDR_SDIO, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*SDIO RPWM*/},\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*USB RPWM*/},\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0x84 \
+	 /*PCIe RPWM*/},\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS \
+	 /*Delay*/},\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT4, 0 \
+	 /*.	0x08[4] =3D 0		 switch TSF to 40M*/},\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_POLLING, BIT7, 0 \
+	 /*Polling 0x109[7]=3D0  TSF in 40M*/},\
+	{0x0029, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT6|BIT7, 0 \
+	 /*.	0x29[7:6] =3D 2b'00	 enable BB clock*/},\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1, BIT1 \
+	 /*.	0x101[1] =3D 1*/},\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0xFF \
+	 /*.	0x100[7:0] =3D 0xFF	 enable WMAC TRX*/},\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, BIT1|BIT0, BIT1|BIT0 \
+	 /*.	0x02[1:0] =3D 2b'11	 enable BB macro*/},\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	PWR_BASEADDR_MAC, PWR_CMD_WRITE, 0xFF, 0 \
+	 /*.	0x522 =3D 0*/},
+
+#define RTL8821A_TRANS_END					\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,\
+	0, PWR_CMD_END, 0, 0},
+
+extern struct wlan_pwr_cfg rtl8821A_power_on_flow
+		[RTL8821A_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_radio_off_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_card_disable_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_card_enable_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_CARDEMU_TO_ACT_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_suspend_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_resume_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_CARDEMU_TO_SUS_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_hwpdn_flow
+		[RTL8821A_TRANS_ACT_TO_CARDEMU_STEPS +
+		 RTL8821A_TRANS_CARDEMU_TO_PDN_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_enter_lps_flow
+		[RTL8821A_TRANS_ACT_TO_LPS_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8821A_leave_lps_flow
+		[RTL8821A_TRANS_LPS_TO_ACT_STEPS +
+		 RTL8821A_TRANS_END_STEPS];
+
+/*RTL8812 Power Configuration CMDs for PCIe interface*/
+#define RTL8812_NIC_PWR_ON_FLOW			rtl8812_power_on_flow
+#define RTL8812_NIC_RF_OFF_FLOW			rtl8812_radio_off_flow
+#define RTL8812_NIC_DISABLE_FLOW		rtl8812_card_disable_flow
+#define RTL8812_NIC_ENABLE_FLOW			rtl8812_card_enable_flow
+#define RTL8812_NIC_SUSPEND_FLOW		rtl8812_suspend_flow
+#define RTL8812_NIC_RESUME_FLOW			rtl8812_resume_flow
+#define RTL8812_NIC_PDN_FLOW			rtl8812_hwpdn_flow
+#define RTL8812_NIC_LPS_ENTER_FLOW		rtl8812_enter_lps_flow
+#define RTL8812_NIC_LPS_LEAVE_FLOW		rtl8812_leave_lps_flow
+
+/* RTL8821 Power Configuration CMDs for PCIe interface */
+#define RTL8821A_NIC_PWR_ON_FLOW		rtl8821A_power_on_flow
+#define RTL8821A_NIC_RF_OFF_FLOW		rtl8821A_radio_off_flow
+#define RTL8821A_NIC_DISABLE_FLOW		rtl8821A_card_disable_flow
+#define RTL8821A_NIC_ENABLE_FLOW		rtl8821A_card_enable_flow
+#define RTL8821A_NIC_SUSPEND_FLOW		rtl8821A_suspend_flow
+#define RTL8821A_NIC_RESUME_FLOW		rtl8821A_resume_flow
+#define RTL8821A_NIC_PDN_FLOW			rtl8821A_hwpdn_flow
+#define RTL8821A_NIC_LPS_ENTER_FLOW		rtl8821A_enter_lps_flow
+#define RTL8821A_NIC_LPS_LEAVE_FLOW		rtl8821A_leave_lps_flow
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h b/drivers/net=
/wireless/rtlwifi/rtl8821ae/reg.h
new file mode 100644
index 0000000..53668fc
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/reg.h
@@ -0,0 +1,2464 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_REG_H__
+#define __RTL8821AE_REG_H__
+
+#define TXPKT_BUF_SELECT			0x69
+#define RXPKT_BUF_SELECT			0xA5
+#define DISABLE_TRXPKT_BUF_ACCESS		0x0
+
+#define REG_SYS_ISO_CTRL			0x0000
+#define REG_SYS_FUNC_EN				0x0002
+#define REG_APS_FSMCO				0x0004
+#define REG_SYS_CLKR				0x0008
+#define REG_9346CR				0x000A
+#define REG_EE_VPD				0x000C
+#define REG_AFE_MISC				0x0010
+#define REG_SPS0_CTRL				0x0011
+#define REG_SPS_OCP_CFG				0x0018
+#define REG_RSV_CTRL				0x001C
+#define REG_RF_CTRL				0x001F
+#define REG_LDOA15_CTRL				0x0020
+#define REG_LDOV12D_CTRL			0x0021
+#define REG_LDOHCI12_CTRL			0x0022
+#define REG_LPLDO_CTRL				0x0023
+#define REG_AFE_XTAL_CTRL			0x0024
+ /* 1.5v for 8188EE test chip, 1.4v for MP chip */
+#define REG_AFE_LDO_CTRL			0x0027
+#define REG_AFE_PLL_CTRL			0x0028
+#define REG_MAC_PHY_CTRL			0x002c
+#define REG_EFUSE_CTRL				0x0030
+#define REG_EFUSE_TEST				0x0034
+#define REG_PWR_DATA				0x0038
+#define REG_CAL_TIMER				0x003C
+#define REG_ACLK_MON				0x003E
+#define REG_GPIO_MUXCFG				0x0040
+#define REG_GPIO_IO_SEL				0x0042
+#define REG_MAC_PINMUX_CFG			0x0043
+#define REG_GPIO_PIN_CTRL			0x0044
+#define REG_GPIO_INTM				0x0048
+#define REG_LEDCFG0				0x004C
+#define REG_LEDCFG1				0x004D
+#define REG_LEDCFG2				0x004E
+#define REG_LEDCFG3				0x004F
+#define REG_FSIMR				0x0050
+#define REG_FSISR				0x0054
+#define REG_HSIMR				0x0058
+#define REG_HSISR				0x005c
+#define REG_GPIO_PIN_CTRL_2			0x0060
+#define REG_GPIO_IO_SEL_2			0x0062
+#define REG_MULTI_FUNC_CTRL			0x0068
+#define REG_GPIO_OUTPUT				0x006c
+#define REG_OPT_CTRL				0x0074
+#define REG_AFE_XTAL_CTRL_EXT			0x0078
+#define REG_XCK_OUT_CTRL			0x007c
+#define REG_MCUFWDL				0x0080
+#define REG_WOL_EVENT				0x0081
+#define REG_MCUTSTCFG				0x0084
+
+#define REG_HIMR				0x00B0
+#define REG_HISR				0x00B4
+#define REG_HIMRE				0x00B8
+#define REG_HISRE				0x00BC
+
+#define REG_PMC_DBG_CTRL2			0x00CC
+
+#define REG_EFUSE_ACCESS			0x00CF
+
+#define REG_BIST_SCAN				0x00D0
+#define REG_BIST_RPT				0x00D4
+#define REG_BIST_ROM_RPT			0x00D8
+#define REG_USB_SIE_INTF			0x00E0
+#define REG_PCIE_MIO_INTF			0x00E4
+#define REG_PCIE_MIO_INTD			0x00E8
+#define REG_HPON_FSM				0x00EC
+#define REG_SYS_CFG				0x00F0
+#define REG_GPIO_OUTSTS				0x00F4
+#define REG_MAC_PHY_CTRL_NORMAL			0x00F8
+#define REG_SYS_CFG1				0x00FC
+#define REG_ROM_VERSION				0x00FD
+
+#define REG_CR					0x0100
+#define REG_PBP					0x0104
+#define REG_PKT_BUFF_ACCESS_CTRL		0x0106
+#define REG_TRXDMA_CTRL				0x010C
+#define REG_TRXFF_BNDY				0x0114
+#define REG_TRXFF_STATUS			0x0118
+#define REG_RXFF_PTR				0x011C
+
+#define REG_CPWM				0x012F
+#define REG_FWIMR				0x0130
+#define REG_FWISR				0x0134
+#define REG_FTISR				0x013C
+#define REG_PKTBUF_DBG_CTRL			0x0140
+#define REG_PKTBUF_DBG_DATA_L			0x0144
+#define REG_PKTBUF_DBG_DATA_H			0x0148
+#define REG_RXPKTBUF_CTRL			(REG_PKTBUF_DBG_CTRL+2)
+
+#define REG_TC0_CTRL				0x0150
+#define REG_TC1_CTRL				0x0154
+#define REG_TC2_CTRL				0x0158
+#define REG_TC3_CTRL				0x015C
+#define REG_TC4_CTRL				0x0160
+#define REG_TCUNIT_BASE				0x0164
+#define REG_MBIST_START				0x0174
+#define REG_MBIST_DONE				0x0178
+#define REG_MBIST_FAIL				0x017C
+#define REG_32K_CTRL				0x0194
+#define REG_C2HEVT_MSG_NORMAL			0x01A0
+#define REG_C2HEVT_CLEAR			0x01AF
+#define REG_C2HEVT_MSG_TEST			0x01B8
+#define REG_MCUTST_1				0x01c0
+#define REG_MCUTST_WOWLAN			0x01C7
+#define REG_FMETHR				0x01C8
+#define REG_HMETFR				0x01CC
+#define REG_HMEBOX_0				0x01D0
+#define REG_HMEBOX_1				0x01D4
+#define REG_HMEBOX_2				0x01D8
+#define REG_HMEBOX_3				0x01DC
+
+#define REG_LLT_INIT				0x01E0
+#define REG_BB_ACCEESS_CTRL			0x01E8
+#define REG_BB_ACCESS_DATA			0x01EC
+
+#define REG_HMEBOX_EXT_0			0x01F0
+#define REG_HMEBOX_EXT_1			0x01F4
+#define REG_HMEBOX_EXT_2			0x01F8
+#define REG_HMEBOX_EXT_3			0x01FC
+
+#define REG_RQPN				0x0200
+#define REG_FIFOPAGE				0x0204
+#define REG_TDECTRL				0x0208
+#define REG_TXDMA_OFFSET_CHK			0x020C
+#define REG_TXDMA_STATUS			0x0210
+#define REG_RQPN_NPQ				0x0214
+
+#define REG_RXDMA_AGG_PG_TH			0x0280
+ /* FW shall update this register before FW write RXPKT_RELEASE_POLL t=
o 1 */
+#define REG_FW_UPD_RDPTR			0x0284
+ /* Control the RX DMA.*/
+#define REG_RXDMA_CONTROL			0x0286
+/* The number of packets in RXPKTBUF.	*/
+#define REG_RXPKT_NUM				0x0287
+
+#define	REG_PCIE_CTRL_REG			0x0300
+#define	REG_INT_MIG				0x0304
+#define	REG_BCNQ_DESA				0x0308
+#define	REG_HQ_DESA				0x0310
+#define	REG_MGQ_DESA				0x0318
+#define	REG_VOQ_DESA				0x0320
+#define	REG_VIQ_DESA				0x0328
+#define	REG_BEQ_DESA				0x0330
+#define	REG_BKQ_DESA				0x0338
+#define	REG_RX_DESA				0x0340
+
+#define	REG_DBI_WDATA				0x0348
+#define	REG_DBI_RDATA				0x034C
+#define	REG_DBI_CTRL				0x0350
+#define	REG_DBI_ADDR				0x0350
+#define	REG_DBI_FLAG				0x0352
+#define	REG_MDIO_WDATA				0x0354
+#define	REG_MDIO_RDATA				0x0356
+#define	REG_MDIO_CTL				0x0358
+#define	REG_DBG_SEL				0x0360
+#define	REG_PCIE_HRPWM				0x0361
+#define	REG_PCIE_HCPWM				0x0363
+#define	REG_UART_CTRL				0x0364
+#define	REG_WATCH_DOG				0x0368
+#define	REG_UART_TX_DESA			0x0370
+#define	REG_UART_RX_DESA			0x0378
+
+#define	REG_HDAQ_DESA_NODEF			0x0000
+#define	REG_CMDQ_DESA_NODEF			0x0000
+
+#define REG_VOQ_INFORMATION			0x0400
+#define REG_VIQ_INFORMATION			0x0404
+#define REG_BEQ_INFORMATION			0x0408
+#define REG_BKQ_INFORMATION			0x040C
+#define REG_MGQ_INFORMATION			0x0410
+#define REG_HGQ_INFORMATION			0x0414
+#define REG_BCNQ_INFORMATION			0x0418
+#define REG_TXPKT_EMPTY				0x041A
+
+#define REG_CPU_MGQ_INFORMATION			0x041C
+#define REG_FWHW_TXQ_CTRL			0x0420
+#define REG_HWSEQ_CTRL				0x0423
+#define REG_TXPKTBUF_BCNQ_BDNY			0x0424
+#define REG_TXPKTBUF_MGQ_BDNY			0x0425
+#define REG_MULTI_BCNQ_EN			0x0426
+#define REG_MULTI_BCNQ_OFFSET			0x0427
+#define REG_SPEC_SIFS				0x0428
+#define REG_RL					0x042A
+#define REG_DARFRC				0x0430
+#define REG_RARFRC				0x0438
+#define REG_RRSR				0x0440
+#define REG_ARFR0				0x0444
+#define REG_ARFR1				0x044C
+#define REG_CCK_CHECK				0x0454
+#define REG_AMPDU_MAX_TIME			0x0456
+#define REG_AGGLEN_LMT				0x0458
+#define REG_AMPDU_MIN_SPACE			0x045C
+#define REG_TXPKTBUF_WMAC_LBK_BF_HD		0x045D
+#define REG_FAST_EDCA_CTRL			0x0460
+#define REG_RD_RESP_PKT_TH			0x0463
+#define REG_INIRTS_RATE_SEL			0x0480
+#define REG_INIDATA_RATE_SEL			0x0484
+#define REG_ARFR2				0x048C
+#define REG_ARFR3				0x0494
+#define REG_POWER_STATUS			0x04A4
+#define REG_POWER_STAGE1			0x04B4
+#define REG_POWER_STAGE2			0x04B8
+#define REG_PKT_LIFE_TIME			0x04C0
+#define REG_STBC_SETTING			0x04C4
+#define REG_HT_SINGLE_AMPDU			0x04C7
+#define REG_PROT_MODE_CTRL			0x04C8
+#define REG_MAX_AGGR_NUM			0x04CA
+#define REG_BAR_MODE_CTRL			0x04CC
+#define REG_RA_TRY_RATE_AGG_LMT			0x04CF
+#define REG_EARLY_MODE_CONTROL			0x04D0
+#define REG_NQOS_SEQ				0x04DC
+#define REG_QOS_SEQ				0x04DE
+#define REG_NEED_CPU_HANDLE			0x04E0
+#define REG_PKT_LOSE_RPT			0x04E1
+#define REG_PTCL_ERR_STATUS			0x04E2
+#define REG_TX_RPT_CTRL				0x04EC
+#define REG_TX_RPT_TIME				0x04F0
+#define REG_DUMMY				0x04FC
+
+#define REG_EDCA_VO_PARAM			0x0500
+#define REG_EDCA_VI_PARAM			0x0504
+#define REG_EDCA_BE_PARAM			0x0508
+#define REG_EDCA_BK_PARAM			0x050C
+#define REG_BCNTCFG				0x0510
+#define REG_PIFS				0x0512
+#define REG_RDG_PIFS				0x0513
+#define REG_SIFS_CTX				0x0514
+#define REG_SIFS_TRX				0x0516
+#define REG_AGGR_BREAK_TIME			0x051A
+#define REG_SLOT				0x051B
+#define REG_TX_PTCL_CTRL			0x0520
+#define REG_TXPAUSE				0x0522
+#define REG_DIS_TXREQ_CLR			0x0523
+#define REG_RD_CTRL				0x0524
+#define REG_TBTT_PROHIBIT			0x0540
+#define REG_RD_NAV_NXT				0x0544
+#define REG_NAV_PROT_LEN			0x0546
+#define REG_BCN_CTRL				0x0550
+#define REG_USTIME_TSF				0x0551
+#define REG_MBID_NUM				0x0552
+#define REG_DUAL_TSF_RST			0x0553
+#define REG_BCN_INTERVAL			0x0554
+#define REG_MBSSID_BCN_SPACE			0x0554
+#define REG_DRVERLYINT				0x0558
+#define REG_BCNDMATIM				0x0559
+#define REG_ATIMWND				0x055A
+#define REG_BCN_MAX_ERR				0x055D
+#define REG_RXTSF_OFFSET_CCK			0x055E
+#define REG_RXTSF_OFFSET_OFDM			0x055F
+#define REG_TSFTR				0x0560
+#define REG_INIT_TSFTR				0x0564
+#define REG_SECONDARY_CCA_CTRL			0x0577
+#define REG_PSTIMER				0x0580
+#define REG_TIMER0				0x0584
+#define REG_TIMER1				0x0588
+#define REG_ACMHWCTRL				0x05C0
+#define REG_ACMRSTCTRL				0x05C1
+#define REG_ACMAVG				0x05C2
+#define REG_VO_ADMTIME				0x05C4
+#define REG_VI_ADMTIME				0x05C6
+#define REG_BE_ADMTIME				0x05C8
+#define REG_EDCA_RANDOM_GEN			0x05CC
+#define REG_NOA_DESC_SEL			0x05CF
+#define REG_NOA_DESC_DURATION			0x05E0
+#define REG_NOA_DESC_INTERVAL			0x05E4
+#define REG_NOA_DESC_START			0x05E8
+#define REG_NOA_DESC_COUNT			0x05EC
+#define REG_SCH_TXCMD				0x05F8
+
+#define REG_APSD_CTRL				0x0600
+#define REG_BWOPMODE				0x0603
+#define REG_TCR					0x0604
+#define REG_RCR					0x0608
+#define REG_RX_PKT_LIMIT			0x060C
+#define REG_RX_DLK_TIME				0x060D
+#define REG_RX_DRVINFO_SZ			0x060F
+
+#define REG_MACID				0x0610
+#define REG_BSSID				0x0618
+#define REG_MAR					0x0620
+#define REG_MBIDCAMCFG				0x0628
+
+#define REG_USTIME_EDCA				0x0638
+#define REG_MAC_SPEC_SIFS			0x063A
+#define REG_RESP_SIFS_CCK			0x063C
+#define REG_RESP_SIFS_OFDM			0x063E
+#define REG_ACKTO				0x0640
+#define REG_CTS2TO				0x0641
+#define REG_EIFS				0x0642
+
+#define REG_NAV_CTRL				0x0650
+#define REG_NAV_UPPER				0x0652
+#define REG_BACAMCMD				0x0654
+#define REG_BACAMCONTENT			0x0658
+#define REG_LBDLY				0x0660
+#define REG_FWDLY				0x0661
+#define REG_RXERR_RPT				0x0664
+#define REG_TRXPTCL_CTL				0x0668
+
+#define REG_CAMCMD				0x0670
+#define REG_CAMWRITE				0x0674
+#define REG_CAMREAD				0x0678
+#define REG_CAMDBG				0x067C
+#define REG_SECCFG				0x0680
+
+#define REG_WOW_CTRL				0x0690
+#define REG_PSSTATUS				0x0691
+#define REG_PS_RX_INFO				0x0692
+#define REG_UAPSD_TID				0x0693
+#define REG_LPNAV_CTRL				0x0694
+#define REG_WKFMCAM_NUM				0x0698
+#define REG_WKFMCAM_RWD				0x069C
+#define REG_RXFLTMAP0				0x06A0
+#define REG_RXFLTMAP1				0x06A2
+#define REG_RXFLTMAP2				0x06A4
+#define REG_BCN_PSR_RPT				0x06A8
+#define REG_CALB32K_CTRL			0x06AC
+#define REG_PKT_MON_CTRL			0x06B4
+#define REG_BT_COEX_TABLE			0x06C0
+#define REG_WMAC_RESP_TXINFO			0x06D8
+
+#define REG_USB_INFO				0xFE17
+#define REG_USB_SPECIAL_OPTION			0xFE55
+#define REG_USB_DMA_AGG_TO			0xFE5B
+#define REG_USB_AGG_TO				0xFE5C
+#define REG_USB_AGG_TH				0xFE5D
+
+#define REG_TEST_USB_TXQS			0xFE48
+#define REG_TEST_SIE_VID			0xFE60
+#define REG_TEST_SIE_PID			0xFE62
+#define REG_TEST_SIE_OPTIONAL			0xFE64
+#define REG_TEST_SIE_CHIRP_K			0xFE65
+#define REG_TEST_SIE_PHY			0xFE66
+#define REG_TEST_SIE_MAC_ADDR			0xFE70
+#define REG_TEST_SIE_STRING			0xFE80
+
+#define REG_NORMAL_SIE_VID			0xFE60
+#define REG_NORMAL_SIE_PID			0xFE62
+#define REG_NORMAL_SIE_OPTIONAL			0xFE64
+#define REG_NORMAL_SIE_EP			0xFE65
+#define REG_NORMAL_SIE_PHY			0xFE68
+#define REG_NORMAL_SIE_MAC_ADDR			0xFE70
+#define REG_NORMAL_SIE_STRING			0xFE80
+
+#define	CR9346					REG_9346CR
+#define	MSR					(REG_CR + 2)
+#define	ISR					REG_HISR
+#define	TSFR					REG_TSFTR
+
+#define	MACIDR0					REG_MACID
+#define	MACIDR4					(REG_MACID + 4)
+
+#define PBP					REG_PBP
+
+#define	IDR0					MACIDR0
+#define	IDR4					MACIDR4
+
+#define	UNUSED_REGISTER				0x1BF
+#define	DCAM					UNUSED_REGISTER
+#define	PSR					UNUSED_REGISTER
+#define BBADDR					UNUSED_REGISTER
+#define	PHYDATAR				UNUSED_REGISTER
+
+#define	INVALID_BBRF_VALUE			0x12345678
+
+#define	MAX_MSS_DENSITY_2T			0x13
+#define	MAX_MSS_DENSITY_1T			0x0A
+
+#define	CMDEEPROM_EN				BIT(5)
+#define	CMDEEPROM_SEL				BIT(4)
+#define	CMD9346CR_9356SEL			BIT(4)
+#define	AUTOLOAD_EEPROM			(CMDEEPROM_EN|CMDEEPROM_SEL)
+#define	AUTOLOAD_EFUSE			CMDEEPROM_EN
+
+#define	GPIOSEL_GPIO				0
+#define	GPIOSEL_ENBT				BIT(5)
+
+#define	GPIO_IN				REG_GPIO_PIN_CTRL
+#define	GPIO_OUT			(REG_GPIO_PIN_CTRL+1)
+#define	GPIO_IO_SEL			(REG_GPIO_PIN_CTRL+2)
+#define	GPIO_MOD			(REG_GPIO_PIN_CTRL+3)
+
+/*    8723/8188E Host System Interrupt Mask Register (offset 0x58, 32 =
byte) */
+#define	HSIMR_GPIO12_0_INT_EN			BIT(0)
+#define	HSIMR_SPS_OCP_INT_EN			BIT(5)
+#define	HSIMR_RON_INT_EN			BIT(6)
+#define	HSIMR_PDN_INT_EN			BIT(7)
+#define	HSIMR_GPIO9_INT_EN			BIT(25)
+
+/* 8723/8188E Host System Interrupt Status Register (offset 0x5C, 32 b=
yte) */
+#define	HSISR_GPIO12_0_INT			BIT(0)
+#define	HSISR_SPS_OCP_INT			BIT(5)
+#define	HSISR_RON_INT_EN			BIT(6)
+#define	HSISR_PDNINT				BIT(7)
+#define	HSISR_GPIO9_INT				BIT(25)
+
+#define	MSR_NOLINK				0x00
+#define	MSR_ADHOC				0x01
+#define	MSR_INFRA				0x02
+#define	MSR_AP					0x03
+
+#define	RRSR_RSC_OFFSET				21
+#define	RRSR_SHORT_OFFSET			23
+#define	RRSR_RSC_BW_40M				0x600000
+#define	RRSR_RSC_UPSUBCHNL			0x400000
+#define	RRSR_RSC_LOWSUBCHNL			0x200000
+#define	RRSR_SHORT				0x800000
+#define	RRSR_1M					BIT(0)
+#define	RRSR_2M					BIT(1)
+#define	RRSR_5_5M				BIT(2)
+#define	RRSR_11M				BIT(3)
+#define	RRSR_6M					BIT(4)
+#define	RRSR_9M					BIT(5)
+#define	RRSR_12M				BIT(6)
+#define	RRSR_18M				BIT(7)
+#define	RRSR_24M				BIT(8)
+#define	RRSR_36M				BIT(9)
+#define	RRSR_48M				BIT(10)
+#define	RRSR_54M				BIT(11)
+#define	RRSR_MCS0				BIT(12)
+#define	RRSR_MCS1				BIT(13)
+#define	RRSR_MCS2				BIT(14)
+#define	RRSR_MCS3				BIT(15)
+#define	RRSR_MCS4				BIT(16)
+#define	RRSR_MCS5				BIT(17)
+#define	RRSR_MCS6				BIT(18)
+#define	RRSR_MCS7				BIT(19)
+#define	BRSR_ACKSHORTPMB			BIT(23)
+
+#define	RATR_1M					0x00000001
+#define	RATR_2M					0x00000002
+#define	RATR_55M				0x00000004
+#define	RATR_11M				0x00000008
+#define	RATR_6M					0x00000010
+#define	RATR_9M					0x00000020
+#define	RATR_12M				0x00000040
+#define	RATR_18M				0x00000080
+#define	RATR_24M				0x00000100
+#define	RATR_36M				0x00000200
+#define	RATR_48M				0x00000400
+#define	RATR_54M				0x00000800
+#define	RATR_MCS0				0x00001000
+#define	RATR_MCS1				0x00002000
+#define	RATR_MCS2				0x00004000
+#define	RATR_MCS3				0x00008000
+#define	RATR_MCS4				0x00010000
+#define	RATR_MCS5				0x00020000
+#define	RATR_MCS6				0x00040000
+#define	RATR_MCS7				0x00080000
+#define	RATR_MCS8				0x00100000
+#define	RATR_MCS9				0x00200000
+#define	RATR_MCS10				0x00400000
+#define	RATR_MCS11				0x00800000
+#define	RATR_MCS12				0x01000000
+#define	RATR_MCS13				0x02000000
+#define	RATR_MCS14				0x04000000
+#define	RATR_MCS15				0x08000000
+
+#define RATE_1M					BIT(0)
+#define RATE_2M					BIT(1)
+#define RATE_5_5M				BIT(2)
+#define RATE_11M				BIT(3)
+#define RATE_6M					BIT(4)
+#define RATE_9M					BIT(5)
+#define RATE_12M				BIT(6)
+#define RATE_18M				BIT(7)
+#define RATE_24M				BIT(8)
+#define RATE_36M				BIT(9)
+#define RATE_48M				BIT(10)
+#define RATE_54M				BIT(11)
+#define RATE_MCS0				BIT(12)
+#define RATE_MCS1				BIT(13)
+#define RATE_MCS2				BIT(14)
+#define RATE_MCS3				BIT(15)
+#define RATE_MCS4				BIT(16)
+#define RATE_MCS5				BIT(17)
+#define RATE_MCS6				BIT(18)
+#define RATE_MCS7				BIT(19)
+#define RATE_MCS8				BIT(20)
+#define RATE_MCS9				BIT(21)
+#define RATE_MCS10				BIT(22)
+#define RATE_MCS11				BIT(23)
+#define RATE_MCS12				BIT(24)
+#define RATE_MCS13				BIT(25)
+#define RATE_MCS14				BIT(26)
+#define RATE_MCS15				BIT(27)
+
+#define	RATE_ALL_CCK		(RATR_1M | RATR_2M | RATR_55M | RATR_11M)
+#define	RATE_ALL_OFDM_AG	(RATR_6M | RATR_9M | RATR_12M | RATR_18M |\
+				RATR_24M | RATR_36M | RATR_48M | RATR_54M)
+#define	RATE_ALL_OFDM_1SS	(RATR_MCS0 | RATR_MCS1 | RATR_MCS2 |\
+				RATR_MCS3 | RATR_MCS4 | RATR_MCS5 |\
+				RATR_MCS6 | RATR_MCS7)
+#define	RATE_ALL_OFDM_2SS	(RATR_MCS8 | RATR_MCS9 | RATR_MCS10 |\
+				RATR_MCS11 | RATR_MCS12 | RATR_MCS13 |\
+				RATR_MCS14 | RATR_MCS15)
+
+#define	BW_OPMODE_20MHZ				BIT(2)
+#define	BW_OPMODE_5G				BIT(1)
+#define	BW_OPMODE_11J				BIT(0)
+
+#define	CAM_VALID				BIT(15)
+#define	CAM_NOTVALID				0x0000
+#define	CAM_USEDK				BIT(5)
+
+#define	CAM_NONE				0x0
+#define	CAM_WEP40				0x01
+#define	CAM_TKIP				0x02
+#define	CAM_AES					0x04
+#define	CAM_WEP104				0x05
+
+#define	TOTAL_CAM_ENTRY				32
+#define	HALF_CAM_ENTRY				16
+
+#define	CAM_WRITE				BIT(16)
+#define	CAM_READ				0x00000000
+#define	CAM_POLLINIG				BIT(31)
+
+#define	SCR_USEDK				0x01
+#define	SCR_TXSEC_ENABLE			0x02
+#define	SCR_RXSEC_ENABLE			0x04
+
+#define	WOW_PMEN				BIT(0)
+#define	WOW_WOMEN				BIT(1)
+#define	WOW_MAGIC				BIT(2)
+#define	WOW_UWF					BIT(3)
+
+/*********************************************
+*       8188 IMR/ISR bits
+**********************************************/
+#define	IMR_DISABLED				0x0
+/* IMR DW0(0x0060-0063) Bit 0-31 */
+/* TXRPT interrupt when CCX bit of the packet is set	*/
+#define	IMR_TXCCK				BIT(30)
+/* Power Save Time Out Interrupt */
+#define	IMR_PSTIMEOUT				BIT(29)
+/* When GTIMER4 expires, this bit is set to 1	*/
+#define	IMR_GTINT4				BIT(28)
+/* When GTIMER3 expires, this bit is set to 1	*/
+#define	IMR_GTINT3				BIT(27)
+/* Transmit Beacon0 Error			*/
+#define	IMR_TBDER				BIT(26)
+/* Transmit Beacon0 OK			*/
+#define	IMR_TBDOK				BIT(25)
+/* TSF Timer BIT32 toggle indication interrupt		*/
+#define	IMR_TSF_BIT32_TOGGLE			BIT(24)
+/* Beacon DMA Interrupt 0			*/
+#define	IMR_BCNDMAINT0				BIT(20)
+/* Beacon Queue DMA OK0			*/
+#define	IMR_BCNDOK0				BIT(16)
+/* HSISR Indicator (HSIMR & HSISR is true, this bit is set to 1) */
+#define	IMR_HSISR_IND_ON_INT			BIT(15)
+/* Beacon DMA Interrupt Extension for Win7			*/
+#define	IMR_BCNDMAINT_E				BIT(14)
+/* CTWidnow End or ATIM Window End */
+#define	IMR_ATIMEND				BIT(12)
+/* HISR1 Indicator (HISR1 & HIMR1 is true, this bit is set to 1)*/
+#define	IMR_HISR1_IND_INT			BIT(11)
+/* CPU to Host Command INT Status, Write 1 clear	*/
+#define	IMR_C2HCMD				BIT(10)
+/* CPU power Mode exchange INT Status, Write 1 clear	*/
+#define	IMR_CPWM2				BIT(9)
+/* CPU power Mode exchange INT Status, Write 1 clear	*/
+#define	IMR_CPWM				BIT(8)
+/* High Queue DMA OK	*/
+#define	IMR_HIGHDOK				BIT(7)
+/* Management Queue DMA OK	*/
+#define	IMR_MGNTDOK				BIT(6)
+/* AC_BK DMA OK		*/
+#define	IMR_BKDOK				BIT(5)
+/* AC_BE DMA OK	*/
+#define	IMR_BEDOK				BIT(4)
+/* AC_VI DMA OK	*/
+#define	IMR_VIDOK				BIT(3)
+/* AC_VO DMA OK	*/
+#define	IMR_VODOK				BIT(2)
+/* Rx Descriptor Unavailable	*/
+#define	IMR_RDU					BIT(1)
+#define	IMR_ROK					BIT(0)	/* Receive DMA OK */
+
+/* IMR DW1(0x00B4-00B7) Bit 0-31 */
+/* Beacon DMA Interrupt 7	*/
+#define	IMR_BCNDMAINT7				BIT(27)
+/* Beacon DMA Interrupt 6		*/
+#define	IMR_BCNDMAINT6				BIT(26)
+/* Beacon DMA Interrupt 5		*/
+#define	IMR_BCNDMAINT5				BIT(25)
+/* Beacon DMA Interrupt 4		*/
+#define	IMR_BCNDMAINT4				BIT(24)
+/* Beacon DMA Interrupt 3		*/
+#define	IMR_BCNDMAINT3				BIT(23)
+/* Beacon DMA Interrupt 2		*/
+#define	IMR_BCNDMAINT2				BIT(22)
+/* Beacon DMA Interrupt 1		*/
+#define	IMR_BCNDMAINT1				BIT(21)
+/* Beacon Queue DMA OK Interrup 7 */
+#define	IMR_BCNDOK7				BIT(20)
+/* Beacon Queue DMA OK Interrup 6 */
+#define	IMR_BCNDOK6				BIT(19)
+/* Beacon Queue DMA OK Interrup 5 */
+#define	IMR_BCNDOK5				BIT(18)
+/* Beacon Queue DMA OK Interrup 4 */
+#define	IMR_BCNDOK4				BIT(17)
+/* Beacon Queue DMA OK Interrup 3 */
+#define	IMR_BCNDOK3				BIT(16)
+/* Beacon Queue DMA OK Interrup 2 */
+#define	IMR_BCNDOK2				BIT(15)
+/* Beacon Queue DMA OK Interrup 1 */
+#define	IMR_BCNDOK1				BIT(14)
+/* ATIM Window End Extension for Win7 */
+#define	IMR_ATIMEND_E				BIT(13)
+/* Tx Error Flag Interrupt Status, write 1 clear. */
+#define	IMR_TXERR				BIT(11)
+/* Rx Error Flag INT Status, Write 1 clear */
+#define	IMR_RXERR				BIT(10)
+/* Transmit FIFO Overflow */
+#define	IMR_TXFOVW				BIT(9)
+/* Receive FIFO Overflow */
+#define	IMR_RXFOVW				BIT(8)
+
+#define	HWSET_MAX_SIZE				512
+#define   EFUSE_MAX_SECTION			64
+#define   EFUSE_REAL_CONTENT_LEN		256
+/* PG data exclude header, dummy 7 bytes frome CP test and reserved 1b=
yte.*/
+#define		EFUSE_OOB_PROTECT_BYTES		18
+
+#define	EEPROM_DEFAULT_TSSI			0x0
+#define EEPROM_DEFAULT_TXPOWERDIFF		0x0
+#define EEPROM_DEFAULT_CRYSTALCAP		0x5
+#define EEPROM_DEFAULT_BOARDTYPE		0x02
+#define EEPROM_DEFAULT_TXPOWER			0x1010
+#define	EEPROM_DEFAULT_HT2T_TXPWR		0x10
+
+#define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
+#define	EEPROM_DEFAULT_THERMALMETER		0x18
+#define	EEPROM_DEFAULT_ANTTXPOWERDIFF		0x0
+#define	EEPROM_DEFAULT_TXPWDIFF_CRYSTALCAP	0x5
+#define	EEPROM_DEFAULT_TXPOWERLEVEL		0x22
+#define	EEPROM_DEFAULT_HT40_2SDIFF		0x0
+#define EEPROM_DEFAULT_HT20_DIFF		2
+#define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
+#define EEPROM_DEFAULT_HT40_PWRMAXOFFSET	0
+#define EEPROM_DEFAULT_HT20_PWRMAXOFFSET	0
+
+#define RF_OPTION1				0x79
+#define RF_OPTION2				0x7A
+#define RF_OPTION3				0x7B
+#define RF_OPTION4				0xC3
+
+#define EEPROM_DEFAULT_PID			0x1234
+#define EEPROM_DEFAULT_VID			0x5678
+#define EEPROM_DEFAULT_CUSTOMERID		0xAB
+#define EEPROM_DEFAULT_SUBCUSTOMERID		0xCD
+#define EEPROM_DEFAULT_VERSION			0
+
+#define	EEPROM_CHANNEL_PLAN_FCC			0x0
+#define	EEPROM_CHANNEL_PLAN_IC			0x1
+#define	EEPROM_CHANNEL_PLAN_ETSI		0x2
+#define	EEPROM_CHANNEL_PLAN_SPAIN		0x3
+#define	EEPROM_CHANNEL_PLAN_FRANCE		0x4
+#define	EEPROM_CHANNEL_PLAN_MKK			0x5
+#define	EEPROM_CHANNEL_PLAN_MKK1		0x6
+#define	EEPROM_CHANNEL_PLAN_ISRAEL		0x7
+#define	EEPROM_CHANNEL_PLAN_TELEC		0x8
+#define	EEPROM_CHANNEL_PLAN_GLOBAL_DOMAIN	0x9
+#define	EEPROM_CHANNEL_PLAN_WORLD_WIDE_13	0xA
+#define	EEPROM_CHANNEL_PLAN_NCC			0xB
+#define	EEPROM_CHANNEL_PLAN_BY_HW_MASK		0x80
+
+#define EEPROM_CID_DEFAULT			0x0
+#define EEPROM_CID_TOSHIBA			0x4
+#define	EEPROM_CID_CCX				0x10
+#define	EEPROM_CID_QMI				0x0D
+#define EEPROM_CID_WHQL				0xFE
+
+#define	RTL_EEPROM_ID				0x8129
+
+#define EEPROM_HPON				0x02
+#define EEPROM_CLK				0x06
+#define EEPROM_TESTR				0x08
+
+#define EEPROM_TXPOWERCCK			0x10
+#define	EEPROM_TXPOWERHT40_1S			0x16
+#define EEPROM_TXPOWERHT20DIFF			0x1B
+#define EEPROM_TXPOWER_OFDMDIFF			0x1B
+
+#define	EEPROM_TX_PWR_INX			0x10
+
+#define	EEPROM_CHANNELPLAN			0xB8
+#define	EEPROM_XTAL_8821AE			0xB9
+#define	EEPROM_THERMAL_METER			0xBA
+#define	EEPROM_IQK_LCK_88E			0xBB
+
+#define	EEPROM_RF_BOARD_OPTION			0xC1
+#define	EEPROM_RF_FEATURE_OPTION_88E		0xC2
+#define	EEPROM_RF_BT_SETTING			0xC3
+#define	EEPROM_VERSION				0xC4
+#define	EEPROM_CUSTOMER_ID			0xC5
+#define	EEPROM_RF_ANTENNA_OPT_88E		0xC9
+#define	EEPROM_RFE_OPTION			0xCA
+
+#define	EEPROM_MAC_ADDR				0xD0
+#define EEPROM_VID				0xD6
+#define EEPROM_DID				0xD8
+#define EEPROM_SVID				0xDA
+#define EEPROM_SMID				0xDC
+
+#define	STOPBECON				BIT(6)
+#define	STOPHIGHT				BIT(5)
+#define	STOPMGT					BIT(4)
+#define	STOPVO					BIT(3)
+#define	STOPVI					BIT(2)
+#define	STOPBE					BIT(1)
+#define	STOPBK					BIT(0)
+
+#define	RCR_APPFCS				BIT(31)
+#define	RCR_APP_MIC				BIT(30)
+#define	RCR_APP_ICV				BIT(29)
+#define	RCR_APP_PHYST_RXFF			BIT(28)
+#define	RCR_APP_BA_SSN				BIT(27)
+#define	RCR_NONQOS_VHT				BIT(26)
+#define	RCR_ENMBID				BIT(24)
+#define	RCR_LSIGEN				BIT(23)
+#define	RCR_MFBEN				BIT(22)
+#define	RCR_HTC_LOC_CTRL			BIT(14)
+#define	RCR_AMF					BIT(13)
+#define	RCR_ACF					BIT(12)
+#define	RCR_ADF					BIT(11)
+#define	RCR_AICV				BIT(9)
+#define	RCR_ACRC32				BIT(8)
+#define	RCR_CBSSID_BCN				BIT(7)
+#define	RCR_CBSSID_DATA				BIT(6)
+#define	RCR_CBSSID				RCR_CBSSID_DATA
+#define	RCR_APWRMGT				BIT(5)
+#define	RCR_ADD3				BIT(4)
+#define	RCR_AB					BIT(3)
+#define	RCR_AM					BIT(2)
+#define	RCR_APM					BIT(1)
+#define	RCR_AAP					BIT(0)
+#define	RCR_MXDMA_OFFSET			8
+#define	RCR_FIFO_OFFSET				13
+
+#define RSV_CTRL				0x001C
+#define RD_CTRL					0x0524
+
+#define REG_USB_INFO				0xFE17
+#define REG_USB_SPECIAL_OPTION			0xFE55
+#define REG_USB_DMA_AGG_TO			0xFE5B
+#define REG_USB_AGG_TO				0xFE5C
+#define REG_USB_AGG_TH				0xFE5D
+
+#define REG_USB_VID				0xFE60
+#define REG_USB_PID				0xFE62
+#define REG_USB_OPTIONAL			0xFE64
+#define REG_USB_CHIRP_K				0xFE65
+#define REG_USB_PHY				0xFE66
+#define REG_USB_MAC_ADDR			0xFE70
+#define REG_USB_HRPWM				0xFE58
+#define REG_USB_HCPWM				0xFE57
+
+#define SW18_FPWM				BIT(3)
+
+#define ISO_MD2PP				BIT(0)
+#define ISO_UA2USB				BIT(1)
+#define ISO_UD2CORE				BIT(2)
+#define ISO_PA2PCIE				BIT(3)
+#define ISO_PD2CORE				BIT(4)
+#define ISO_IP2MAC				BIT(5)
+#define ISO_DIOP				BIT(6)
+#define ISO_DIOE				BIT(7)
+#define ISO_EB2CORE				BIT(8)
+#define ISO_DIOR				BIT(9)
+
+#define PWC_EV25V				BIT(14)
+#define PWC_EV12V				BIT(15)
+
+#define FEN_BBRSTB				BIT(0)
+#define FEN_BB_GLB_RSTN				BIT(1)
+#define FEN_USBA				BIT(2)
+#define FEN_UPLL				BIT(3)
+#define FEN_USBD				BIT(4)
+#define FEN_DIO_PCIE				BIT(5)
+#define FEN_PCIEA				BIT(6)
+#define FEN_PPLL				BIT(7)
+#define FEN_PCIED				BIT(8)
+#define FEN_DIOE				BIT(9)
+#define FEN_CPUEN				BIT(10)
+#define FEN_DCORE				BIT(11)
+#define FEN_ELDR				BIT(12)
+#define FEN_DIO_RF				BIT(13)
+#define FEN_HWPDN				BIT(14)
+#define FEN_MREGEN				BIT(15)
+
+#define PFM_LDALL				BIT(0)
+#define PFM_ALDN				BIT(1)
+#define PFM_LDKP				BIT(2)
+#define PFM_WOWL				BIT(3)
+#define ENPDN					BIT(4)
+#define PDN_PL					BIT(5)
+#define APFM_ONMAC				BIT(8)
+#define APFM_OFF				BIT(9)
+#define APFM_RSM				BIT(10)
+#define AFSM_HSUS				BIT(11)
+#define AFSM_PCIE				BIT(12)
+#define APDM_MAC				BIT(13)
+#define APDM_HOST				BIT(14)
+#define APDM_HPDN				BIT(15)
+#define RDY_MACON				BIT(16)
+#define SUS_HOST				BIT(17)
+#define ROP_ALD					BIT(20)
+#define ROP_PWR					BIT(21)
+#define ROP_SPS					BIT(22)
+#define SOP_MRST				BIT(25)
+#define SOP_FUSE				BIT(26)
+#define SOP_ABG					BIT(27)
+#define SOP_AMB					BIT(28)
+#define SOP_RCK					BIT(29)
+#define SOP_A8M					BIT(30)
+#define XOP_BTCK				BIT(31)
+
+#define ANAD16V_EN				BIT(0)
+#define ANA8M					BIT(1)
+#define MACSLP					BIT(4)
+#define LOADER_CLK_EN				BIT(5)
+#define _80M_SSC_DIS				BIT(7)
+#define _80M_SSC_EN_HO				BIT(8)
+#define PHY_SSC_RSTB				BIT(9)
+#define SEC_CLK_EN				BIT(10)
+#define MAC_CLK_EN				BIT(11)
+#define SYS_CLK_EN				BIT(12)
+#define RING_CLK_EN				BIT(13)
+
+#define	BOOT_FROM_EEPROM			BIT(4)
+#define	EEPROM_EN				BIT(5)
+
+#define AFE_BGEN				BIT(0)
+#define AFE_MBEN				BIT(1)
+#define MAC_ID_EN				BIT(7)
+
+#define WLOCK_ALL				BIT(0)
+#define WLOCK_00				BIT(1)
+#define WLOCK_04				BIT(2)
+#define WLOCK_08				BIT(3)
+#define WLOCK_40				BIT(4)
+#define R_DIS_PRST_0				BIT(5)
+#define R_DIS_PRST_1				BIT(6)
+#define LOCK_ALL_EN				BIT(7)
+
+#define RF_EN					BIT(0)
+#define RF_RSTB					BIT(1)
+#define RF_SDMRSTB				BIT(2)
+
+#define LDA15_EN				BIT(0)
+#define LDA15_STBY				BIT(1)
+#define LDA15_OBUF				BIT(2)
+#define LDA15_REG_VOS				BIT(3)
+#define _LDA15_VOADJ(x)				(((x) & 0x7) << 4)
+
+#define LDV12_EN				BIT(0)
+#define LDV12_SDBY				BIT(1)
+#define LPLDO_HSM				BIT(2)
+#define LPLDO_LSM_DIS				BIT(3)
+#define _LDV12_VADJ(x)				(((x) & 0xF) << 4)
+
+#define XTAL_EN					BIT(0)
+#define XTAL_BSEL				BIT(1)
+#define _XTAL_BOSC(x)				(((x) & 0x3) << 2)
+#define _XTAL_CADJ(x)				(((x) & 0xF) << 4)
+#define XTAL_GATE_USB				BIT(8)
+#define _XTAL_USB_DRV(x)			(((x) & 0x3) << 9)
+#define XTAL_GATE_AFE				BIT(11)
+#define _XTAL_AFE_DRV(x)			(((x) & 0x3) << 12)
+#define XTAL_RF_GATE				BIT(14)
+#define _XTAL_RF_DRV(x)				(((x) & 0x3) << 15)
+#define XTAL_GATE_DIG				BIT(17)
+#define _XTAL_DIG_DRV(x)			(((x) & 0x3) << 18)
+#define XTAL_BT_GATE				BIT(20)
+#define _XTAL_BT_DRV(x)				(((x) & 0x3) << 21)
+#define _XTAL_GPIO(x)				(((x) & 0x7) << 23)
+
+#define CKDLY_AFE				BIT(26)
+#define CKDLY_USB				BIT(27)
+#define CKDLY_DIG				BIT(28)
+#define CKDLY_BT				BIT(29)
+
+#define APLL_EN					BIT(0)
+#define APLL_320_EN				BIT(1)
+#define APLL_FREF_SEL				BIT(2)
+#define APLL_EDGE_SEL				BIT(3)
+#define APLL_WDOGB				BIT(4)
+#define APLL_LPFEN				BIT(5)
+
+#define APLL_REF_CLK_13MHZ			0x1
+#define APLL_REF_CLK_19_2MHZ			0x2
+#define APLL_REF_CLK_20MHZ			0x3
+#define APLL_REF_CLK_25MHZ			0x4
+#define APLL_REF_CLK_26MHZ			0x5
+#define APLL_REF_CLK_38_4MHZ			0x6
+#define APLL_REF_CLK_40MHZ			0x7
+
+#define APLL_320EN				BIT(14)
+#define APLL_80EN				BIT(15)
+#define APLL_1MEN				BIT(24)
+
+#define ALD_EN					BIT(18)
+#define EF_PD					BIT(19)
+#define EF_FLAG					BIT(31)
+
+#define EF_TRPT					BIT(7)
+#define LDOE25_EN				BIT(31)
+
+#define RSM_EN					BIT(0)
+#define TIMER_EN				BIT(4)
+
+#define TRSW0EN					BIT(2)
+#define TRSW1EN					BIT(3)
+#define EROM_EN					BIT(4)
+#define ENBT					BIT(5)
+#define ENUART					BIT(8)
+#define UART_910				BIT(9)
+#define ENPMAC					BIT(10)
+#define SIC_SWRST				BIT(11)
+#define ENSIC					BIT(12)
+#define SIC_23					BIT(13)
+#define ENHDP					BIT(14)
+#define SIC_LBK					BIT(15)
+
+#define LED0PL					BIT(4)
+#define LED1PL					BIT(12)
+#define LED0DIS					BIT(7)
+
+#define MCUFWDL_EN				BIT(0)
+#define MCUFWDL_RDY				BIT(1)
+#define FWDL_CHKSUM_RPT				BIT(2)
+#define MACINI_RDY				BIT(3)
+#define BBINI_RDY				BIT(4)
+#define RFINI_RDY				BIT(5)
+#define WINTINI_RDY				BIT(6)
+#define CPRST					BIT(23)
+
+#define XCLK_VLD				BIT(0)
+#define ACLK_VLD				BIT(1)
+#define UCLK_VLD				BIT(2)
+#define PCLK_VLD				BIT(3)
+#define PCIRSTB					BIT(4)
+#define V15_VLD					BIT(5)
+#define TRP_B15V_EN				BIT(7)
+#define SIC_IDLE				BIT(8)
+#define BD_MAC2					BIT(9)
+#define BD_MAC1					BIT(10)
+#define IC_MACPHY_MODE				BIT(11)
+#define VENDOR_ID				BIT(19)
+#define PAD_HWPD_IDN				BIT(22)
+#define TRP_VAUX_EN				BIT(23)
+#define TRP_BT_EN				BIT(24)
+#define BD_PKG_SEL				BIT(25)
+#define BD_HCI_SEL				BIT(26)
+#define TYPE_ID					BIT(27)
+
+#define CHIP_VER_RTL_MASK			0xF000
+#define CHIP_VER_RTL_SHIFT			12
+
+#define REG_LBMODE				(REG_CR + 3)
+
+#define HCI_TXDMA_EN				BIT(0)
+#define HCI_RXDMA_EN				BIT(1)
+#define TXDMA_EN				BIT(2)
+#define RXDMA_EN				BIT(3)
+#define PROTOCOL_EN				BIT(4)
+#define SCHEDULE_EN				BIT(5)
+#define MACTXEN					BIT(6)
+#define MACRXEN					BIT(7)
+#define ENSWBCN					BIT(8)
+#define ENSEC					BIT(9)
+
+#define _NETTYPE(x)				(((x) & 0x3) << 16)
+#define MASK_NETTYPE				0x30000
+#define NT_NO_LINK				0x0
+#define NT_LINK_AD_HOC				0x1
+#define NT_LINK_AP				0x2
+#define NT_AS_AP				0x3
+
+#define _LBMODE(x)				(((x) & 0xF) << 24)
+#define MASK_LBMODE				0xF000000
+#define LOOPBACK_NORMAL				0x0
+#define LOOPBACK_IMMEDIATELY			0xB
+#define LOOPBACK_MAC_DELAY			0x3
+#define LOOPBACK_PHY				0x1
+#define LOOPBACK_DMA				0x7
+
+#define GET_RX_PAGE_SIZE(value)		((value) & 0xF)
+#define GET_TX_PAGE_SIZE(value)		(((value) & 0xF0) >> 4)
+#define _PSRX_MASK				0xF
+#define _PSTX_MASK				0xF0
+#define _PSRX(x)				(x)
+#define _PSTX(x)				((x) << 4)
+
+#define PBP_64					0x0
+#define PBP_128					0x1
+#define PBP_256					0x2
+#define PBP_512					0x3
+#define PBP_1024				0x4
+
+#define RXDMA_ARBBW_EN				BIT(0)
+#define RXSHFT_EN				BIT(1)
+#define RXDMA_AGG_EN				BIT(2)
+#define QS_VO_QUEUE				BIT(8)
+#define QS_VI_QUEUE				BIT(9)
+#define QS_BE_QUEUE				BIT(10)
+#define QS_BK_QUEUE				BIT(11)
+#define QS_MANAGER_QUEUE			BIT(12)
+#define QS_HIGH_QUEUE				BIT(13)
+
+#define HQSEL_VOQ				BIT(0)
+#define HQSEL_VIQ				BIT(1)
+#define HQSEL_BEQ				BIT(2)
+#define HQSEL_BKQ				BIT(3)
+#define HQSEL_MGTQ				BIT(4)
+#define HQSEL_HIQ				BIT(5)
+
+#define _TXDMA_HIQ_MAP(x)			(((x)&0x3) << 14)
+#define _TXDMA_MGQ_MAP(x)			(((x)&0x3) << 12)
+#define _TXDMA_BKQ_MAP(x)			(((x)&0x3) << 10)
+#define _TXDMA_BEQ_MAP(x)			(((x)&0x3) << 8)
+#define _TXDMA_VIQ_MAP(x)			(((x)&0x3) << 6)
+#define _TXDMA_VOQ_MAP(x)			(((x)&0x3) << 4)
+
+#define QUEUE_LOW				1
+#define QUEUE_NORMAL				2
+#define QUEUE_HIGH				3
+
+#define _LLT_NO_ACTIVE				0x0
+#define _LLT_WRITE_ACCESS			0x1
+#define _LLT_READ_ACCESS			0x2
+
+#define _LLT_INIT_DATA(x)			((x) & 0xFF)
+#define _LLT_INIT_ADDR(x)			(((x) & 0xFF) << 8)
+#define _LLT_OP(x)				(((x) & 0x3) << 30)
+#define _LLT_OP_VALUE(x)			(((x) >> 30) & 0x3)
+
+#define BB_WRITE_READ_MASK			(BIT(31) | BIT(30))
+#define BB_WRITE_EN				BIT(30)
+#define BB_READ_EN				BIT(31)
+
+#define _HPQ(x)				((x) & 0xFF)
+#define _LPQ(x)				(((x) & 0xFF) << 8)
+#define _PUBQ(x)			(((x) & 0xFF) << 16)
+#define _NPQ(x)				((x) & 0xFF)
+
+#define HPQ_PUBLIC_DIS				BIT(24)
+#define LPQ_PUBLIC_DIS				BIT(25)
+#define LD_RQPN					BIT(31)
+
+#define BCN_VALID				BIT(16)
+#define BCN_HEAD(x)			(((x) & 0xFF) << 8)
+#define	BCN_HEAD_MASK				0xFF00
+
+#define BLK_DESC_NUM_SHIFT			4
+#define BLK_DESC_NUM_MASK			0xF
+
+#define DROP_DATA_EN				BIT(9)
+
+#define EN_AMPDU_RTY_NEW			BIT(7)
+
+#define _INIRTSMCS_SEL(x)			((x) & 0x3F)
+
+#define _SPEC_SIFS_CCK(x)			((x) & 0xFF)
+#define _SPEC_SIFS_OFDM(x)			(((x) & 0xFF) << 8)
+
+#define RATE_REG_BITMAP_ALL			0xFFFFF
+
+#define _RRSC_BITMAP(x)				((x) & 0xFFFFF)
+
+#define _RRSR_RSC(x)				(((x) & 0x3) << 21)
+#define RRSR_RSC_RESERVED			0x0
+#define RRSR_RSC_UPPER_SUBCHANNEL		0x1
+#define RRSR_RSC_LOWER_SUBCHANNEL		0x2
+#define RRSR_RSC_DUPLICATE_MODE			0x3
+
+#define USE_SHORT_G1				BIT(20)
+
+#define _AGGLMT_MCS0(x)				((x) & 0xF)
+#define _AGGLMT_MCS1(x)				(((x) & 0xF) << 4)
+#define _AGGLMT_MCS2(x)				(((x) & 0xF) << 8)
+#define _AGGLMT_MCS3(x)				(((x) & 0xF) << 12)
+#define _AGGLMT_MCS4(x)				(((x) & 0xF) << 16)
+#define _AGGLMT_MCS5(x)				(((x) & 0xF) << 20)
+#define _AGGLMT_MCS6(x)				(((x) & 0xF) << 24)
+#define _AGGLMT_MCS7(x)				(((x) & 0xF) << 28)
+
+#define	RETRY_LIMIT_SHORT_SHIFT		8
+#define	RETRY_LIMIT_LONG_SHIFT		0
+
+#define _DARF_RC1(x)			((x) & 0x1F)
+#define _DARF_RC2(x)			(((x) & 0x1F) << 8)
+#define _DARF_RC3(x)			(((x) & 0x1F) << 16)
+#define _DARF_RC4(x)			(((x) & 0x1F) << 24)
+#define _DARF_RC5(x)			((x) & 0x1F)
+#define _DARF_RC6(x)			(((x) & 0x1F) << 8)
+#define _DARF_RC7(x)			(((x) & 0x1F) << 16)
+#define _DARF_RC8(x)			(((x) & 0x1F) << 24)
+
+#define _RARF_RC1(x)			((x) & 0x1F)
+#define _RARF_RC2(x)			(((x) & 0x1F) << 8)
+#define _RARF_RC3(x)			(((x) & 0x1F) << 16)
+#define _RARF_RC4(x)			(((x) & 0x1F) << 24)
+#define _RARF_RC5(x)			((x) & 0x1F)
+#define _RARF_RC6(x)			(((x) & 0x1F) << 8)
+#define _RARF_RC7(x)			(((x) & 0x1F) << 16)
+#define _RARF_RC8(x)			(((x) & 0x1F) << 24)
+
+#define AC_PARAM_TXOP_LIMIT_OFFSET	16
+#define AC_PARAM_ECW_MAX_OFFSET		12
+#define AC_PARAM_ECW_MIN_OFFSET		8
+#define AC_PARAM_AIFS_OFFSET		0
+
+#define _AIFS(x)			(x)
+#define _ECW_MAX_MIN(x)			((x) << 8)
+#define _TXOP_LIMIT(x)			((x) << 16)
+
+#define _BCNIFS(x)			((x) & 0xFF)
+#define _BCNECW(x)			((((x) & 0xF)) << 8)
+
+#define _LRL(x)				((x) & 0x3F)
+#define _SRL(x)				(((x) & 0x3F) << 8)
+
+#define _SIFS_CCK_CTX(x)		((x) & 0xFF)
+#define _SIFS_CCK_TRX(x)		(((x) & 0xFF) << 8)
+
+#define _SIFS_OFDM_CTX(x)		((x) & 0xFF)
+#define _SIFS_OFDM_TRX(x)		(((x) & 0xFF) << 8)
+
+#define _TBTT_PROHIBIT_HOLD(x)		(((x) & 0xFF) << 8)
+
+#define DIS_EDCA_CNT_DWN		BIT(11)
+
+#define EN_MBSSID			BIT(1)
+#define EN_TXBCN_RPT			BIT(2)
+#define	EN_BCN_FUNCTION			BIT(3)
+
+#define TSFTR_RST			BIT(0)
+#define TSFTR1_RST			BIT(1)
+
+#define STOP_BCNQ			BIT(6)
+
+#define	DIS_TSF_UDT0_NORMAL_CHIP	BIT(4)
+#define	DIS_TSF_UDT0_TEST_CHIP		BIT(5)
+
+#define	ACMHW_HWEN			BIT(0)
+#define	ACMHW_BEQEN			BIT(1)
+#define	ACMHW_VIQEN			BIT(2)
+#define	ACMHW_VOQEN			BIT(3)
+#define	ACMHW_BEQSTATUS			BIT(4)
+#define	ACMHW_VIQSTATUS			BIT(5)
+#define	ACMHW_VOQSTATUS			BIT(6)
+
+#define APSDOFF				BIT(6)
+#define APSDOFF_STATUS			BIT(7)
+
+#define BW_20MHZ			BIT(2)
+
+#define RATE_BITMAP_ALL			0xFFFFF
+
+#define RATE_RRSR_CCK_ONLY_1M		0xFFFF1
+
+#define TSFRST				BIT(0)
+#define DIS_GCLK			BIT(1)
+#define PAD_SEL				BIT(2)
+#define PWR_ST				BIT(6)
+#define PWRBIT_OW_EN			BIT(7)
+#define ACRC				BIT(8)
+#define CFENDFORM			BIT(9)
+#define ICV				BIT(10)
+
+#define AAP				BIT(0)
+#define APM				BIT(1)
+#define AM				BIT(2)
+#define AB				BIT(3)
+#define ADD3				BIT(4)
+#define APWRMGT				BIT(5)
+#define CBSSID				BIT(6)
+#define CBSSID_DATA			BIT(6)
+#define CBSSID_BCN			BIT(7)
+#define ACRC32				BIT(8)
+#define AICV				BIT(9)
+#define ADF				BIT(11)
+#define ACF				BIT(12)
+#define AMF				BIT(13)
+#define HTC_LOC_CTRL			BIT(14)
+#define UC_DATA_EN			BIT(16)
+#define BM_DATA_EN			BIT(17)
+#define MFBEN				BIT(22)
+#define LSIGEN				BIT(23)
+#define ENMBID				BIT(24)
+#define APP_BASSN			BIT(27)
+#define APP_PHYSTS			BIT(28)
+#define APP_ICV				BIT(29)
+#define APP_MIC				BIT(30)
+#define APP_FCS				BIT(31)
+
+#define _MIN_SPACE(x)			((x) & 0x7)
+#define _SHORT_GI_PADDING(x)		(((x) & 0x1F) << 3)
+
+#define RXERR_TYPE_OFDM_PPDU		0
+#define RXERR_TYPE_OFDM_FALSE_ALARM	1
+#define	RXERR_TYPE_OFDM_MPDU_OK		2
+#define RXERR_TYPE_OFDM_MPDU_FAIL	3
+#define RXERR_TYPE_CCK_PPDU		4
+#define RXERR_TYPE_CCK_FALSE_ALARM	5
+#define RXERR_TYPE_CCK_MPDU_OK		6
+#define RXERR_TYPE_CCK_MPDU_FAIL	7
+#define RXERR_TYPE_HT_PPDU		8
+#define RXERR_TYPE_HT_FALSE_ALARM	9
+#define RXERR_TYPE_HT_MPDU_TOTAL	10
+#define RXERR_TYPE_HT_MPDU_OK		11
+#define RXERR_TYPE_HT_MPDU_FAIL		12
+#define RXERR_TYPE_RX_FULL_DROP		15
+
+#define RXERR_COUNTER_MASK		0xFFFFF
+#define RXERR_RPT_RST			BIT(27)
+#define _RXERR_RPT_SEL(type)		((type) << 28)
+
+#define	SCR_TXUSEDK			BIT(0)
+#define	SCR_RXUSEDK			BIT(1)
+#define	SCR_TXENCENABLE			BIT(2)
+#define	SCR_RXDECENABLE			BIT(3)
+#define	SCR_SKBYA2			BIT(4)
+#define	SCR_NOSKMC			BIT(5)
+#define SCR_TXBCUSEDK			BIT(6)
+#define SCR_RXBCUSEDK			BIT(7)
+
+#define XCLK_VLD			BIT(0)
+#define ACLK_VLD			BIT(1)
+#define UCLK_VLD			BIT(2)
+#define PCLK_VLD			BIT(3)
+#define PCIRSTB				BIT(4)
+#define V15_VLD				BIT(5)
+#define TRP_B15V_EN			BIT(7)
+#define SIC_IDLE			BIT(8)
+#define BD_MAC2				BIT(9)
+#define BD_MAC1				BIT(10)
+#define IC_MACPHY_MODE			BIT(11)
+#define BT_FUNC				BIT(16)
+#define VENDOR_ID			BIT(19)
+#define PAD_HWPD_IDN			BIT(22)
+#define TRP_VAUX_EN			BIT(23)
+#define TRP_BT_EN			BIT(24)
+#define BD_PKG_SEL			BIT(25)
+#define BD_HCI_SEL			BIT(26)
+#define TYPE_ID				BIT(27)
+
+#define USB_IS_HIGH_SPEED		0
+#define USB_IS_FULL_SPEED		1
+#define USB_SPEED_MASK			BIT(5)
+
+#define USB_NORMAL_SIE_EP_MASK		0xF
+#define USB_NORMAL_SIE_EP_SHIFT		4
+
+#define USB_TEST_EP_MASK		0x30
+#define USB_TEST_EP_SHIFT		4
+
+#define USB_AGG_EN			BIT(3)
+
+#define MAC_ADDR_LEN			6
+#define LAST_ENTRY_OF_TX_PKT_BUFFER	255
+
+#define POLLING_LLT_THRESHOLD		20
+#define POLLING_READY_TIMEOUT_COUNT	3000
+
+#define	MAX_MSS_DENSITY_2T		0x13
+#define	MAX_MSS_DENSITY_1T		0x0A
+
+#define EPROM_CMD_OPERATING_MODE_MASK	((1<<7)|(1<<6))
+#define EPROM_CMD_CONFIG		0x3
+#define EPROM_CMD_LOAD			1
+
+#define	HWSET_MAX_SIZE_92S		HWSET_MAX_SIZE
+
+#define	HAL_8192C_HW_GPIO_WPS_BIT	BIT(2)
+
+#define RA_LSSIWRITE_8821A		0xc90
+#define RB_LSSIWRITE_8821A		0xe90
+
+#define	RA_PIREAD_8821A			0xd04
+#define	RB_PIREAD_8821A			0xd44
+#define	RA_SIREAD_8821A			0xd08
+#define	RB_SIREAD_8821A			0xd48
+
+#define	RPMAC_RESET			0x100
+#define	RPMAC_TXSTART			0x104
+#define	RPMAC_TXLEGACYSIG		0x108
+#define	RPMAC_TXHTSIG1			0x10c
+#define	RPMAC_TXHTSIG2			0x110
+#define	RPMAC_PHYDEBUG			0x114
+#define	RPMAC_TXPACKETNUM		0x118
+#define	RPMAC_TXIDLE			0x11c
+#define	RPMAC_TXMACHEADER0		0x120
+#define	RPMAC_TXMACHEADER1		0x124
+#define	RPMAC_TXMACHEADER2		0x128
+#define	RPMAC_TXMACHEADER3		0x12c
+#define	RPMAC_TXMACHEADER4		0x130
+#define	RPMAC_TXMACHEADER5		0x134
+#define	RPMAC_TXDADATYPE		0x138
+#define	RPMAC_TXRANDOMSEED		0x13c
+#define	RPMAC_CCKPLCPPREAMBLE		0x140
+#define	RPMAC_CCKPLCPHEADER		0x144
+#define	RPMAC_CCKCRC16			0x148
+#define	RPMAC_OFDMRXCRC32OK		0x170
+#define	RPMAC_OFDMRXCRC32ER		0x174
+#define	RPMAC_OFDMRXPARITYER		0x178
+#define	RPMAC_OFDMRXCRC8ER		0x17c
+#define	RPMAC_CCKCRXRC16ER		0x180
+#define	RPMAC_CCKCRXRC32ER		0x184
+#define	RPMAC_CCKCRXRC32OK		0x188
+#define	RPMAC_TXSTATUS			0x18c
+
+#define	RFPGA0_RFMOD			0x800
+
+#define	RFPGA0_TXINFO			0x804
+#define	RFPGA0_PSDFUNCTION		0x808
+
+#define	RFPGA0_TXGAINSTAGE		0x80c
+
+#define	RFPGA0_RFTIMING1		0x810
+#define	RFPGA0_RFTIMING2		0x814
+
+#define	RFPGA0_XA_HSSIPARAMETER1	0x820
+#define	RFPGA0_XA_HSSIPARAMETER2	0x824
+#define	RFPGA0_XB_HSSIPARAMETER1	0x828
+#define	RFPGA0_XB_HSSIPARAMETER2	0x82c
+#define	RCCAONSEC			0x838
+
+#define	RFPGA0_XA_LSSIPARAMETER		0x840
+#define	RFPGA0_XB_LSSIPARAMETER		0x844
+#define	RL1PEAKTH			0x848
+
+#define	RFPGA0_RFWAKEUPPARAMETER	0x850
+#define	RFPGA0_RFSLEEPUPPARAMETER	0x854
+
+#define	RFPGA0_XAB_SWITCHCONTROL	0x858
+#define	RFPGA0_XCD_SWITCHCONTROL	0x85c
+
+#define	RFPGA0_XA_RFINTERFACEOE		0x860
+#define RFC_AREA			0x860
+#define	RFPGA0_XB_RFINTERFACEOE		0x864
+
+#define	RFPGA0_XAB_RFINTERFACESW	0x870
+#define	RFPGA0_XCD_RFINTERFACESW	0x874
+
+#define	RFPGA0_XAB_RFPARAMETER		0x878
+#define	RFPGA0_XCD_RFPARAMETER		0x87c
+
+#define	RFPGA0_ANALOGPARAMETER1		0x880
+#define	RFPGA0_ANALOGPARAMETER2		0x884
+#define	RFPGA0_ANALOGPARAMETER3		0x888
+#define	RFPGA0_ANALOGPARAMETER4		0x88c
+
+#define	RFPGA0_XA_LSSIREADBACK		0x8a0
+#define	RFPGA0_XB_LSSIREADBACK		0x8a4
+#define	RFPGA0_XC_LSSIREADBACK		0x8a8
+#define RRFMOD				0x8ac
+#define	RHSSIREAD_8821AE		0x8b0
+
+#define	RFPGA0_PSDREPORT		0x8b4
+#define	TRANSCEIVEA_HSPI_READBACK	0x8b8
+#define	TRANSCEIVEB_HSPI_READBACK	0x8bc
+#define RADC_BUF_CLK			0x8c4
+#define	RFPGA0_XAB_RFINTERFACERB	0x8e0
+#define	RFPGA0_XCD_RFINTERFACERB	0x8e4
+
+#define	RFPGA1_RFMOD			0x900
+
+#define	RFPGA1_TXBLOCK			0x904
+#define	RFPGA1_DEBUGSELECT		0x908
+#define	RFPGA1_TXINFO			0x90c
+
+#define	RCCK_SYSTEM			0xa00
+#define	BCCK_SYSTEM			0x10
+
+#define	RCCK0_AFESETTING		0xa04
+#define	RCCK0_CCA			0xa08
+
+#define	RCCK0_RXAGC1			0xa0c
+#define	RCCK0_RXAGC2			0xa10
+
+#define	RCCK0_RXHP			0xa14
+
+#define	RCCK0_DSPPARAMETER1		0xa18
+#define	RCCK0_DSPPARAMETER2		0xa1c
+
+#define	RCCK0_TXFILTER1			0xa20
+#define	RCCK0_TXFILTER2			0xa24
+#define	RCCK0_DEBUGPORT			0xa28
+#define	RCCK0_FALSEALARMREPORT		0xa2c
+#define	RCCK0_TRSSIREPORT		0xa50
+#define	RCCK0_RXREPORT			0xa54
+#define	RCCK0_FACOUNTERLOWER		0xa5c
+#define	RCCK0_FACOUNTERUPPER		0xa58
+#define	RCCK0_CCA_CNT			0xa60
+
+/* PageB(0xB00) */
+#define	RPDP_ANTA			0xb00
+#define	RPDP_ANTA_4			0xb04
+#define	RPDP_ANTA_8			0xb08
+#define	RPDP_ANTA_C			0xb0c
+#define	RPDP_ANTA_10			0xb10
+#define	RPDP_ANTA_14			0xb14
+#define	RPDP_ANTA_18			0xb18
+#define	RPDP_ANTA_1C			0xb1c
+#define	RPDP_ANTA_20			0xb20
+#define	RPDP_ANTA_24			0xb24
+
+#define	RCONFIG_PMPD_ANTA		0xb28
+#define	RCONFIG_RAM64x16		0xb2c
+
+#define	RBNDA				0xb30
+#define	RHSSIPAR			0xb34
+
+#define	RCONFIG_ANTA			0xb68
+#define	RCONFIG_ANTB			0xb6c
+
+#define	RPDP_ANTB			0xb70
+#define	RPDP_ANTB_4			0xb74
+#define	RPDP_ANTB_8			0xb78
+#define	RPDP_ANTB_C			0xb7c
+#define	RPDP_ANTB_10			0xb80
+#define	RPDP_ANTB_14			0xb84
+#define	RPDP_ANTB_18			0xb88
+#define	RPDP_ANTB_1C			0xb8c
+#define	RPDP_ANTB_20			0xb90
+#define	RPDP_ANTB_24			0xb94
+
+#define	RCONFIG_PMPD_ANTB		0xb98
+
+#define	RBNDB				0xba0
+
+#define	RAPK				0xbd8
+#define	RPM_RX0_ANTA			0xbdc
+#define	RPM_RX1_ANTA			0xbe0
+#define	RPM_RX2_ANTA			0xbe4
+#define	RPM_RX3_ANTA			0xbe8
+#define	RPM_RX0_ANTB			0xbec
+#define	RPM_RX1_ANTB			0xbf0
+#define	RPM_RX2_ANTB			0xbf4
+#define	RPM_RX3_ANTB			0xbf8
+
+/*RSSI Dump*/
+#define		RA_RSSI_DUMP		0xBF0
+#define		RB_RSSI_DUMP		0xBF1
+#define		RS1_RX_EVM_DUMP		0xBF4
+#define		RS2_RX_EVM_DUMP		0xBF5
+#define		RA_RX_SNR_DUMP		0xBF6
+#define		RB_RX_SNR_DUMP		0xBF7
+#define		RA_CFO_SHORT_DUMP	0xBF8
+#define		RB_CFO_SHORT_DUMP	0xBFA
+#define		RA_CFO_LONG_DUMP	0xBEC
+#define		RB_CFO_LONG_DUMP	0xBEE
+
+/*Page C*/
+#define	ROFDM0_LSTF			0xc00
+
+#define	ROFDM0_TRXPATHENABLE		0xc04
+#define	ROFDM0_TRMUXPAR			0xc08
+#define	ROFDM0_TRSWISOLATION		0xc0c
+
+#define	ROFDM0_XARXAFE			0xc10
+#define	ROFDM0_XARXIQIMBALANCE		0xc14
+#define	ROFDM0_XBRXAFE			0xc18
+#define	ROFDM0_XBRXIQIMBALANCE		0xc1c
+#define	ROFDM0_XCRXAFE			0xc20
+#define	ROFDM0_XCRXIQIMBANLANCE		0xc24
+#define	ROFDM0_XDRXAFE			0xc28
+#define	ROFDM0_XDRXIQIMBALANCE		0xc2c
+
+#define	ROFDM0_RXDETECTOR1		0xc30
+#define	ROFDM0_RXDETECTOR2		0xc34
+#define	ROFDM0_RXDETECTOR3		0xc38
+#define	ROFDM0_RXDETECTOR4		0xc3c
+
+#define	ROFDM0_RXDSP			0xc40
+#define	ROFDM0_CFOANDDAGC		0xc44
+#define	ROFDM0_CCADROPTHRESHOLD		0xc48
+#define	ROFDM0_ECCATHRESHOLD		0xc4c
+
+#define	ROFDM0_XAAGCCORE1		0xc50
+#define	ROFDM0_XAAGCCORE2		0xc54
+#define	ROFDM0_XBAGCCORE1		0xc58
+#define	ROFDM0_XBAGCCORE2		0xc5c
+#define	ROFDM0_XCAGCCORE1		0xc60
+#define	ROFDM0_XCAGCCORE2		0xc64
+#define	ROFDM0_XDAGCCORE1		0xc68
+#define	ROFDM0_XDAGCCORE2		0xc6c
+
+#define	ROFDM0_AGCPARAMETER1		0xc70
+#define	ROFDM0_AGCPARAMETER2		0xc74
+#define	ROFDM0_AGCRSSITABLE		0xc78
+#define	ROFDM0_HTSTFAGC			0xc7c
+
+#define	ROFDM0_XATXIQIMBALANCE		0xc80
+#define	ROFDM0_XATXAFE			0xc84
+#define	ROFDM0_XBTXIQIMBALANCE		0xc88
+#define	ROFDM0_XBTXAFE			0xc8c
+#define	ROFDM0_XCTXIQIMBALANCE		0xc90
+#define	ROFDM0_XCTXAFE			0xc94
+#define	ROFDM0_XDTXIQIMBALANCE		0xc98
+#define	ROFDM0_XDTXAFE			0xc9c
+
+#define ROFDM0_RXIQEXTANTA		0xca0
+#define	ROFDM0_TXCOEFF1			0xca4
+#define	ROFDM0_TXCOEFF2			0xca8
+#define	ROFDM0_TXCOEFF3			0xcac
+#define	ROFDM0_TXCOEFF4			0xcb0
+#define	ROFDM0_TXCOEFF5			0xcb4
+#define	ROFDM0_TXCOEFF6			0xcb8
+
+/*Path_A RFE cotrol */
+#define	RA_RFE_CTRL_8812		0xcb8
+/*Path_B RFE control*/
+#define	RB_RFE_CTRL_8812		0xeb8
+
+#define	ROFDM0_RXHPPARAMETER		0xce0
+#define	ROFDM0_TXPSEUDONOISEWGT		0xce4
+#define	ROFDM0_FRAMESYNC		0xcf0
+#define	ROFDM0_DFSREPORT		0xcf4
+
+#define	ROFDM1_LSTF			0xd00
+#define	ROFDM1_TRXPATHENABLE		0xd04
+
+#define	ROFDM1_CF0			0xd08
+#define	ROFDM1_CSI1			0xd10
+#define	ROFDM1_SBD			0xd14
+#define	ROFDM1_CSI2			0xd18
+#define	ROFDM1_CFOTRACKING		0xd2c
+#define	ROFDM1_TRXMESAURE1		0xd34
+#define	ROFDM1_INTFDET			0xd3c
+#define	ROFDM1_PSEUDONOISESTATEAB	0xd50
+#define	ROFDM1_PSEUDONOISESTATECD	0xd54
+#define	ROFDM1_RXPSEUDONOISEWGT		0xd58
+
+#define	ROFDM_PHYCOUNTER1		0xda0
+#define	ROFDM_PHYCOUNTER2		0xda4
+#define	ROFDM_PHYCOUNTER3		0xda8
+
+#define	ROFDM_SHORTCFOAB		0xdac
+#define	ROFDM_SHORTCFOCD		0xdb0
+#define	ROFDM_LONGCFOAB			0xdb4
+#define	ROFDM_LONGCFOCD			0xdb8
+#define	ROFDM_TAILCF0AB			0xdbc
+#define	ROFDM_TAILCF0CD			0xdc0
+#define	ROFDM_PWMEASURE1		0xdc4
+#define	ROFDM_PWMEASURE2		0xdc8
+#define	ROFDM_BWREPORT			0xdcc
+#define	ROFDM_AGCREPORT			0xdd0
+#define	ROFDM_RXSNR			0xdd4
+#define	ROFDM_RXEVMCSI			0xdd8
+#define	ROFDM_SIGREPORT			0xddc
+
+#define RTXAGC_A_CCK11_CCK1		0xc20
+#define RTXAGC_A_OFDM18_OFDM6		0xc24
+#define RTXAGC_A_OFDM54_OFDM24		0xc28
+#define RTXAGC_A_MCS03_MCS00		0xc2c
+#define RTXAGC_A_MCS07_MCS04		0xc30
+#define RTXAGC_A_MCS11_MCS08		0xc34
+#define RTXAGC_A_MCS15_MCS12		0xc38
+#define RTXAGC_A_NSS1INDEX3_NSS1INDEX0	0xc3c
+#define	RTXAGC_A_NSS1INDEX7_NSS1INDEX4	0xc40
+#define	RTXAGC_A_NSS2INDEX1_NSS1INDEX8	0xc44
+#define	RTXAGC_A_NSS2INDEX5_NSS2INDEX2	0xc48
+#define	RTXAGC_A_NSS2INDEX9_NSS2INDEX6	0xc4c
+#define	RTXAGC_B_CCK11_CCK1		0xe20
+#define	RTXAGC_B_OFDM18_OFDM6		0xe24
+#define	RTXAGC_B_OFDM54_OFDM24		0xe28
+#define	RTXAGC_B_MCS03_MCS00		0xe2c
+#define	RTXAGC_B_MCS07_MCS04		0xe30
+#define	RTXAGC_B_MCS11_MCS08		0xe34
+#define	RTXAGC_B_MCS15_MCS12		0xe38
+#define	RTXAGC_B_NSS1INDEX3_NSS1INDEX0	0xe3c
+#define	RTXAGC_B_NSS1INDEX7_NSS1INDEX4	0xe40
+#define	RTXAGC_B_NSS2INDEX1_NSS1INDEX8	0xe44
+#define	RTXAGC_B_NSS2INDEX5_NSS2INDEX2	0xe48
+#define	RTXAGC_B_NSS2INDEX9_NSS2INDEX6	0xe4c
+
+#define	RA_TXPWRTRAING			0xc54
+#define	RB_TXPWRTRAING			0xe54
+
+#define	RFPGA0_IQK			0xe28
+#define	RTX_IQK_TONE_A			0xe30
+#define	RRX_IQK_TONE_A			0xe34
+#define	RTX_IQK_PI_A			0xe38
+#define	RRX_IQK_PI_A			0xe3c
+
+#define	RTX_IQK				0xe40
+#define	RRX_IQK				0xe44
+#define	RIQK_AGC_PTS			0xe48
+#define	RIQK_AGC_RSP			0xe4c
+#define	RTX_IQK_TONE_B			0xe50
+#define	RRX_IQK_TONE_B			0xe54
+#define	RTX_IQK_PI_B			0xe58
+#define	RRX_IQK_PI_B			0xe5c
+#define	RIQK_AGC_CONT			0xe60
+
+#define	RBLUE_TOOTH			0xe6c
+#define	RRX_WAIT_CCA			0xe70
+#define	RTX_CCK_RFON			0xe74
+#define	RTX_CCK_BBON			0xe78
+#define	RTX_OFDM_RFON			0xe7c
+#define	RTX_OFDM_BBON			0xe80
+#define	RTX_TO_RX			0xe84
+#define	RTX_TO_TX			0xe88
+#define	RRX_CCK				0xe8c
+
+#define	RTX_POWER_BEFORE_IQK_A		0xe94
+#define	RTX_POWER_AFTER_IQK_A		0xe9c
+
+#define	RRX_POWER_BEFORE_IQK_A		0xea0
+#define	RRX_POWER_BEFORE_IQK_A_2	0xea4
+#define	RRX_POWER_AFTER_IQK_A		0xea8
+#define	RRX_POWER_AFTER_IQK_A_2		0xeac
+
+#define	RTX_POWER_BEFORE_IQK_B		0xeb4
+#define	RTX_POWER_AFTER_IQK_B		0xebc
+
+#define	RRX_POER_BEFORE_IQK_B		0xec0
+#define	RRX_POER_BEFORE_IQK_B_2		0xec4
+#define	RRX_POWER_AFTER_IQK_B		0xec8
+#define	RRX_POWER_AFTER_IQK_B_2		0xecc
+
+#define	RRX_OFDM			0xed0
+#define	RRX_WAIT_RIFS			0xed4
+#define	RRX_TO_RX			0xed8
+#define	RSTANDBY			0xedc
+#define	RSLEEP				0xee0
+#define	RPMPD_ANAEN			0xeec
+
+#define	RZEBRA1_HSSIENABLE		0x0
+#define	RZEBRA1_TRXENABLE1		0x1
+#define	RZEBRA1_TRXENABLE2		0x2
+#define	RZEBRA1_AGC			0x4
+#define	RZEBRA1_CHARGEPUMP		0x5
+#define	RZEBRA1_CHANNEL			0x7
+
+#define	RZEBRA1_TXGAIN			0x8
+#define	RZEBRA1_TXLPF			0x9
+#define	RZEBRA1_RXLPF			0xb
+#define	RZEBRA1_RXHPFCORNER		0xc
+
+#define	RGLOBALCTRL			0
+#define	RRTL8256_TXLPF			19
+#define	RRTL8256_RXLPF			11
+#define	RRTL8258_TXLPF			0x11
+#define	RRTL8258_RXLPF			0x13
+#define	RRTL8258_RSSILPF		0xa
+
+#define	RF_AC				0x00
+
+#define	RF_IQADJ_G1			0x01
+#define	RF_IQADJ_G2			0x02
+#define	RF_POW_TRSW			0x05
+
+#define	RF_GAIN_RX			0x06
+#define	RF_GAIN_TX			0x07
+
+#define	RF_TXM_IDAC			0x08
+#define	RF_BS_IQGEN			0x0F
+
+#define	RF_MODE1			0x10
+#define	RF_MODE2			0x11
+
+#define	RF_RX_AGC_HP			0x12
+#define	RF_TX_AGC			0x13
+#define	RF_BIAS				0x14
+#define	RF_IPA				0x15
+#define	RF_POW_ABILITY			0x17
+#define	RF_MODE_AG			0x18
+#define	RRFCHANNEL			0x18
+#define	RF_CHNLBW			0x18
+#define	RF_TOP				0x19
+
+#define	RF_RX_G1			0x1A
+#define	RF_RX_G2			0x1B
+
+#define	RF_RX_BB2			0x1C
+#define	RF_RX_BB1			0x1D
+
+#define	RF_RCK1				0x1E
+#define	RF_RCK2				0x1F
+
+#define	RF_TX_G1			0x20
+#define	RF_TX_G2			0x21
+#define	RF_TX_G3			0x22
+
+#define	RF_TX_BB1			0x23
+#define	RF_T_METER			0x24
+#define	RF_T_METER_88E			0x42
+#define  RF_T_METER_8812A		0x42
+
+#define	RF_SYN_G1			0x25
+#define	RF_SYN_G2			0x26
+#define	RF_SYN_G3			0x27
+#define	RF_SYN_G4			0x28
+#define	RF_SYN_G5			0x29
+#define	RF_SYN_G6			0x2A
+#define	RF_SYN_G7			0x2B
+#define	RF_SYN_G8			0x2C
+
+#define	RF_RCK_OS			0x30
+#define	RF_TXPA_G1			0x31
+#define	RF_TXPA_G2			0x32
+#define	RF_TXPA_G3			0x33
+
+#define	RF_TX_BIAS_A			0x35
+#define	RF_TX_BIAS_D			0x36
+#define	RF_LOBF_9			0x38
+#define	RF_RXRF_A3			0x3C
+#define	RF_TRSW				0x3F
+
+#define	RF_TXRF_A2			0x41
+#define	RF_TXPA_G4			0x46
+#define	RF_TXPA_A4			0x4B
+
+#define RF_APK				0x63
+
+#define	RF_WE_LUT			0xEF
+
+#define	BBBRESETB			0x100
+#define	BGLOBALRESETB			0x200
+#define	BOFDMTXSTART			0x4
+#define	BCCKTXSTART			0x8
+#define	BCRC32DEBUG			0x100
+#define	BPMACLOOPBACK			0x10
+#define	BTXLSIG				0xffffff
+#define	BOFDMTXRATE			0xf
+#define	BOFDMTXRESERVED			0x10
+#define	BOFDMTXLENGTH			0x1ffe0
+#define	BOFDMTXPARITY			0x20000
+#define	BTXHTSIG1			0xffffff
+#define	BTXHTMCSRATE			0x7f
+#define	BTXHTBW				0x80
+#define	BTXHTLENGTH			0xffff00
+#define	BTXHTSIG2			0xffffff
+#define	BTXHTSMOOTHING			0x1
+#define	BTXHTSOUNDING			0x2
+#define	BTXHTRESERVED			0x4
+#define	BTXHTAGGREATION			0x8
+#define	BTXHTSTBC			0x30
+#define	BTXHTADVANCECODING		0x40
+#define	BTXHTSHORTGI			0x80
+#define	BTXHTNUMBERHT_LTF		0x300
+#define	BTXHTCRC8			0x3fc00
+#define	BCOUNTERRESET			0x10000
+#define	BNUMOFOFDMTX			0xffff
+#define	BNUMOFCCKTX			0xffff0000
+#define	BTXIDLEINTERVAL			0xffff
+#define	BOFDMSERVICE			0xffff0000
+#define	BTXMACHEADER			0xffffffff
+#define	BTXDATAINIT			0xff
+#define	BTXHTMODE			0x100
+#define	BTXDATATYPE			0x30000
+#define	BTXRANDOMSEED			0xffffffff
+#define	BCCKTXPREAMBLE			0x1
+#define	BCCKTXSFD			0xffff0000
+#define	BCCKTXSIG			0xff
+#define	BCCKTXSERVICE			0xff00
+#define	BCCKLENGTHEXT			0x8000
+#define	BCCKTXLENGHT			0xffff0000
+#define	BCCKTXCRC16			0xffff
+#define	BCCKTXSTATUS			0x1
+#define	BOFDMTXSTATUS			0x2
+#define IS_BB_REG_OFFSET_92S(__offset)	\
+	((__offset >=3D 0x800) && (__offset <=3D 0xfff))
+
+#define	BRFMOD				0x1
+#define	BJAPANMODE			0x2
+#define	BCCKTXSC			0x30
+/* Block & Path enable*/
+#define ROFDMCCKEN			0x808
+#define	BCCKEN				0x10000000
+#define	BOFDMEN				0x20000000
+/* Rx antenna*/
+#define	RRXPATH				0x808
+#define	BRXPATH				0xff
+/* Tx antenna*/
+#define	RTXPATH				0x80c
+#define	BTXPATH				0x0fffffff
+/* for cck rx path selection*/
+#define	RCCK_RX				0xa04
+#define	BCCK_RX				0x0c000000
+/* Use LSIG for VHT length*/
+#define	RVHTLEN_USE_LSIG		0x8c3
+
+#define	BOFDMRXADCPHASE			0x10000
+#define	BOFDMTXDACPHASE			0x40000
+#define	BXATXAGC			0x3f
+
+#define	BXBTXAGC			0xf00
+#define	BXCTXAGC			0xf000
+#define	BXDTXAGC			0xf0000
+
+#define	BPASTART			0xf0000000
+#define	BTRSTART			0x00f00000
+#define	BRFSTART			0x0000f000
+#define	BBBSTART			0x000000f0
+#define	BBBCCKSTART			0x0000000f
+#define	BPAEND				0xf
+#define	BTREND				0x0f000000
+#define	BRFEND				0x000f0000
+#define	BCCAMASK			0x000000f0
+#define	BR2RCCAMASK			0x00000f00
+#define	BHSSI_R2TDELAY			0xf8000000
+#define	BHSSI_T2RDELAY			0xf80000
+#define	BCONTXHSSI			0x400
+#define	BIGFROMCCK			0x200
+#define	BAGCADDRESS			0x3f
+#define	BRXHPTX				0x7000
+#define	BRXHP2RX			0x38000
+#define	BRXHPCCKINI			0xc0000
+#define	BAGCTXCODE			0xc00000
+#define	BAGCRXCODE			0x300000
+
+#define	B3WIREDATALENGTH		0x800
+#define	B3WIREADDREAALENGTH		0x400
+
+#define	B3WIRERFPOWERDOWN		0x1
+#define	B5GPAPEPOLARITY			0x40000000
+#define	B2GPAPEPOLARITY			0x80000000
+#define	BRFSW_TXDEFAULTANT		0x3
+#define	BRFSW_TXOPTIONANT		0x30
+#define	BRFSW_RXDEFAULTANT		0x300
+#define	BRFSW_RXOPTIONANT		0x3000
+#define	BRFSI_3WIREDATA			0x1
+#define	BRFSI_3WIRECLOCK		0x2
+#define	BRFSI_3WIRELOAD			0x4
+#define	BRFSI_3WIRERW			0x8
+#define	BRFSI_3WIRE			0xf
+
+#define	BRFSI_RFENV			0x10
+
+#define	BRFSI_TRSW			0x20
+#define	BRFSI_TRSWB			0x40
+#define	BRFSI_ANTSW			0x100
+#define	BRFSI_ANTSWB			0x200
+#define	BRFSI_PAPE			0x400
+#define	BRFSI_PAPE5G			0x800
+#define	BBANDSELECT			0x1
+#define	BHTSIG2_GI			0x80
+#define	BHTSIG2_SMOOTHING		0x01
+#define	BHTSIG2_SOUNDING		0x02
+#define	BHTSIG2_AGGREATON		0x08
+#define	BHTSIG2_STBC			0x30
+#define	BHTSIG2_ADVCODING		0x40
+#define	BHTSIG2_NUMOFHTLTF		0x300
+#define	BHTSIG2_CRC8			0x3fc
+#define	BHTSIG1_MCS			0x7f
+#define	BHTSIG1_BANDWIDTH		0x80
+#define	BHTSIG1_HTLENGTH		0xffff
+#define	BLSIG_RATE			0xf
+#define	BLSIG_RESERVED			0x10
+#define	BLSIG_LENGTH			0x1fffe
+#define	BLSIG_PARITY			0x20
+#define	BCCKRXPHASE			0x4
+
+#define	BLSSIREADADDRESS		0x7f800000
+#define	BLSSIREADEDGE			0x80000000
+
+#define	BLSSIREADBACKDATA		0xfffff
+
+#define	BLSSIREADOKFLAG			0x1000
+#define	BCCKSAMPLERATE			0x8
+#define	BREGULATOR0STANDBY		0x1
+#define	BREGULATORPLLSTANDBY		0x2
+#define	BREGULATOR1STANDBY		0x4
+#define	BPLLPOWERUP			0x8
+#define	BDPLLPOWERUP			0x10
+#define	BDA10POWERUP			0x20
+#define	BAD7POWERUP			0x200
+#define	BDA6POWERUP			0x2000
+#define	BXTALPOWERUP			0x4000
+#define	B40MDCLKPOWERUP			0x8000
+#define	BDA6DEBUGMODE			0x20000
+#define	BDA6SWING			0x380000
+
+#define	BADCLKPHASE			0x4000000
+#define	B80MCLKDELAY			0x18000000
+#define	BAFEWATCHDOGENABLE		0x20000000
+
+#define	BXTALCAP01			0xc0000000
+#define	BXTALCAP23			0x3
+#define	BXTALCAP92X			0x0f000000
+#define BXTALCAP			0x0f000000
+
+#define	BINTDIFCLKENABLE		0x400
+#define	BEXTSIGCLKENABLE		0x800
+#define	BBANDGAP_MBIAS_POWERUP		0x10000
+#define	BAD11SH_GAIN			0xc0000
+#define	BAD11NPUT_RANGE			0x700000
+#define	BAD110P_CURRENT			0x3800000
+#define	BLPATH_LOOPBACK			0x4000000
+#define	BQPATH_LOOPBACK			0x8000000
+#define	BAFE_LOOPBACK			0x10000000
+#define	BDA10_SWING			0x7e0
+#define	BDA10_REVERSE			0x800
+#define	BDA_CLK_SOURCE			0x1000
+#define	BDA7INPUT_RANGE			0x6000
+#define	BDA7_GAIN			0x38000
+#define	BDA7OUTPUT_CM_MODE		0x40000
+#define	BDA7INPUT_CM_MODE		0x380000
+#define	BDA7CURRENT			0xc00000
+#define	BREGULATOR_ADJUST		0x7000000
+#define	BAD11POWERUP_ATTX		0x1
+#define	BDA10PS_ATTX			0x10
+#define	BAD11POWERUP_ATRX		0x100
+#define	BDA10PS_ATRX			0x1000
+#define	BCCKRX_AGC_FORMAT		0x200
+#define	BPSDFFT_SAMPLE_POINT		0xc000
+#define	BPSD_AVERAGE_NUM		0x3000
+#define	BIQPATH_CONTROL			0xc00
+#define	BPSD_FREQ			0x3ff
+#define	BPSD_ANTENNA_PATH		0x30
+#define	BPSD_IQ_SWITCH			0x40
+#define	BPSD_RX_TRIGGER			0x400000
+#define	BPSD_TX_TRIGGER			0x80000000
+#define	BPSD_SINE_TONE_SCALE		0x7f000000
+#define	BPSD_REPORT			0xffff
+
+#define	BOFDM_TXSC			0x30000000
+#define	BCCK_TXON			0x1
+#define	BOFDM_TXON			0x2
+#define	BDEBUG_PAGE			0xfff
+#define	BDEBUG_ITEM			0xff
+#define	BANTL				0x10
+#define	BANT_NONHT			0x100
+#define	BANT_HT1			0x1000
+#define	BANT_HT2			0x10000
+#define	BANT_HT1S1			0x100000
+#define	BANT_NONHTS1			0x1000000
+
+#define	BCCK_BBMODE			0x3
+#define	BCCK_TXPOWERSAVING		0x80
+#define	BCCK_RXPOWERSAVING		0x40
+
+#define	BCCK_SIDEBAND			0x10
+
+#define	BCCK_SCRAMBLE			0x8
+#define	BCCK_ANTDIVERSITY		0x8000
+#define	BCCK_CARRIER_RECOVERY		0x4000
+#define	BCCK_TXRATE			0x3000
+#define	BCCK_DCCANCEL			0x0800
+#define	BCCK_ISICANCEL			0x0400
+#define	BCCK_MATCH_FILTER		0x0200
+#define	BCCK_EQUALIZER			0x0100
+#define	BCCK_PREAMBLE_DETECT		0x800000
+#define	BCCK_FAST_FALSECCA		0x400000
+#define	BCCK_CH_ESTSTART		0x300000
+#define	BCCK_CCA_COUNT			0x080000
+#define	BCCK_CS_LIM			0x070000
+#define	BCCK_BIST_MODE			0x80000000
+#define	BCCK_CCAMASK			0x40000000
+#define	BCCK_TX_DAC_PHASE		0x4
+#define	BCCK_RX_ADC_PHASE		0x20000000
+#define	BCCKR_CP_MODE			0x0100
+#define	BCCK_TXDC_OFFSET		0xf0
+#define	BCCK_RXDC_OFFSET		0xf
+#define	BCCK_CCA_MODE			0xc000
+#define	BCCK_FALSECS_LIM		0x3f00
+#define	BCCK_CS_RATIO			0xc00000
+#define	BCCK_CORGBIT_SEL		0x300000
+#define	BCCK_PD_LIM			0x0f0000
+#define	BCCK_NEWCCA			0x80000000
+#define	BCCK_RXHP_OF_IG			0x8000
+#define	BCCK_RXIG			0x7f00
+#define	BCCK_LNA_POLARITY		0x800000
+#define	BCCK_RX1ST_BAIN			0x7f0000
+#define	BCCK_RF_EXTEND			0x20000000
+#define	BCCK_RXAGC_SATLEVEL		0x1f000000
+#define	BCCK_RXAGC_SATCOUNT		0xe0
+#define	BCCKRXRFSETTLE			0x1f
+#define	BCCK_FIXED_RXAGC		0x8000
+#define	BCCK_ANTENNA_POLARITY		0x2000
+#define	BCCK_TXFILTER_TYPE		0x0c00
+#define	BCCK_RXAGC_REPORTTYPE		0x0300
+#define	BCCK_RXDAGC_EN			0x80000000
+#define	BCCK_RXDAGC_PERIOD		0x20000000
+#define	BCCK_RXDAGC_SATLEVEL		0x1f000000
+#define	BCCK_TIMING_RECOVERY		0x800000
+#define	BCCK_TXC0			0x3f0000
+#define	BCCK_TXC1			0x3f000000
+#define	BCCK_TXC2			0x3f
+#define	BCCK_TXC3			0x3f00
+#define	BCCK_TXC4			0x3f0000
+#define	BCCK_TXC5			0x3f000000
+#define	BCCK_TXC6			0x3f
+#define	BCCK_TXC7			0x3f00
+#define	BCCK_DEBUGPORT			0xff0000
+#define	BCCK_DAC_DEBUG			0x0f000000
+#define	BCCK_FALSEALARM_ENABLE		0x8000
+#define	BCCK_FALSEALARM_READ		0x4000
+#define	BCCK_TRSSI			0x7f
+#define	BCCK_RXAGC_REPORT		0xfe
+#define	BCCK_RXREPORT_ANTSEL		0x80000000
+#define	BCCK_RXREPORT_MFOFF		0x40000000
+#define	BCCK_RXREPORT_SQLOSS		0x20000000
+#define	BCCK_RXREPORT_PKTLOSS		0x10000000
+#define	BCCK_RXREPORT_LOCKEDBIT		0x08000000
+#define	BCCK_RXREPORT_RATEERROR		0x04000000
+#define	BCCK_RXREPORT_RXRATE		0x03000000
+#define	BCCK_RXFA_COUNTER_LOWER		0xff
+#define	BCCK_RXFA_COUNTER_UPPER		0xff000000
+#define	BCCK_RXHPAGC_START		0xe000
+#define	BCCK_RXHPAGC_FINAL		0x1c00
+#define	BCCK_RXFALSEALARM_ENABLE	0x8000
+#define	BCCK_FACOUNTER_FREEZE		0x4000
+#define	BCCK_TXPATH_SEL			0x10000000
+#define	BCCK_DEFAULT_RXPATH		0xc000000
+#define	BCCK_OPTION_RXPATH		0x3000000
+
+#define	BNUM_OFSTF			0x3
+#define	BSHIFT_L			0xc0
+#define	BGI_TH				0xc
+#define	BRXPATH_A			0x1
+#define	BRXPATH_B			0x2
+#define	BRXPATH_C			0x4
+#define	BRXPATH_D			0x8
+#define	BTXPATH_A			0x1
+#define	BTXPATH_B			0x2
+#define	BTXPATH_C			0x4
+#define	BTXPATH_D			0x8
+#define	BTRSSI_FREQ			0x200
+#define	BADC_BACKOFF			0x3000
+#define	BDFIR_BACKOFF			0xc000
+#define	BTRSSI_LATCH_PHASE		0x10000
+#define	BRX_LDC_OFFSET			0xff
+#define	BRX_QDC_OFFSET			0xff00
+#define	BRX_DFIR_MODE			0x1800000
+#define	BRX_DCNF_TYPE			0xe000000
+#define	BRXIQIMB_A			0x3ff
+#define	BRXIQIMB_B			0xfc00
+#define	BRXIQIMB_C			0x3f0000
+#define	BRXIQIMB_D			0xffc00000
+#define	BDC_DC_NOTCH			0x60000
+#define	BRXNB_NOTCH			0x1f000000
+#define	BPD_TH				0xf
+#define	BPD_TH_OPT2			0xc000
+#define	BPWED_TH			0x700
+#define	BIFMF_WIN_L			0x800
+#define	BPD_OPTION			0x1000
+#define	BMF_WIN_L			0xe000
+#define	BBW_SEARCH_L			0x30000
+#define	BWIN_ENH_L			0xc0000
+#define	BBW_TH				0x700000
+#define	BED_TH2				0x3800000
+#define	BBW_OPTION			0x4000000
+#define	BRADIO_TH			0x18000000
+#define	BWINDOW_L			0xe0000000
+#define	BSBD_OPTION			0x1
+#define	BFRAME_TH			0x1c
+#define	BFS_OPTION			0x60
+#define	BDC_SLOPE_CHECK			0x80
+#define	BFGUARD_COUNTER_DC_L		0xe00
+#define	BFRAME_WEIGHT_SHORT		0x7000
+#define	BSUB_TUNE			0xe00000
+#define	BFRAME_DC_LENGTH		0xe000000
+#define	BSBD_START_OFFSET		0x30000000
+#define	BFRAME_TH_2			0x7
+#define	BFRAME_GI2_TH			0x38
+#define	BGI2_SYNC_EN			0x40
+#define	BSARCH_SHORT_EARLY		0x300
+#define	BSARCH_SHORT_LATE		0xc00
+#define	BSARCH_GI2_LATE			0x70000
+#define	BCFOANTSUM			0x1
+#define	BCFOACC				0x2
+#define	BCFOSTARTOFFSET			0xc
+#define	BCFOLOOPBACK			0x70
+#define	BCFOSUMWEIGHT			0x80
+#define	BDAGCENABLE			0x10000
+#define	BTXIQIMB_A			0x3ff
+#define	BTXIQIMB_b			0xfc00
+#define	BTXIQIMB_C			0x3f0000
+#define	BTXIQIMB_D			0xffc00000
+#define	BTXIDCOFFSET			0xff
+#define	BTXIQDCOFFSET			0xff00
+#define	BTXDFIRMODE			0x10000
+#define	BTXPESUDO_NOISEON		0x4000000
+#define	BTXPESUDO_NOISE_A		0xff
+#define	BTXPESUDO_NOISE_B		0xff00
+#define	BTXPESUDO_NOISE_C		0xff0000
+#define	BTXPESUDO_NOISE_D		0xff000000
+#define	BCCA_DROPOPTION			0x20000
+#define	BCCA_DROPTHRES			0xfff00000
+#define	BEDCCA_H			0xf
+#define	BEDCCA_L			0xf0
+#define	BLAMBDA_ED			0x300
+#define	BRX_INITIALGAIN			0x7f
+#define	BRX_ANTDIV_EN			0x80
+#define	BRX_AGC_ADDRESS_FOR_LNA		0x7f00
+#define	BRX_HIGHPOWER_FLOW		0x8000
+#define	BRX_AGC_FREEZE_THRES		0xc0000
+#define	BRX_FREEZESTEP_AGC1		0x300000
+#define	BRX_FREEZESTEP_AGC2		0xc00000
+#define	BRX_FREEZESTEP_AGC3		0x3000000
+#define	BRX_FREEZESTEP_AGC0		0xc000000
+#define	BRXRSSI_CMP_EN			0x10000000
+#define	BRXQUICK_AGCEN			0x20000000
+#define	BRXAGC_FREEZE_THRES_MODE	0x40000000
+#define	BRX_OVERFLOW_CHECKTYPE		0x80000000
+#define	BRX_AGCSHIFT			0x7f
+#define	BTRSW_TRI_ONLY			0x80
+#define	BPOWER_THRES			0x300
+#define	BRXAGC_EN			0x1
+#define	BRXAGC_TOGETHER_EN		0x2
+#define	BRXAGC_MIN			0x4
+#define	BRXHP_INI			0x7
+#define	BRXHP_TRLNA			0x70
+#define	BRXHP_RSSI			0x700
+#define	BRXHP_BBP1			0x7000
+#define	BRXHP_BBP2			0x70000
+#define	BRXHP_BBP3			0x700000
+#define	BRSSI_H				0x7f0000
+#define	BRSSI_GEN			0x7f000000
+#define	BRXSETTLE_TRSW			0x7
+#define	BRXSETTLE_LNA			0x38
+#define	BRXSETTLE_RSSI			0x1c0
+#define	BRXSETTLE_BBP			0xe00
+#define	BRXSETTLE_RXHP			0x7000
+#define	BRXSETTLE_ANTSW_RSSI		0x38000
+#define	BRXSETTLE_ANTSW			0xc0000
+#define	BRXPROCESS_TIME_DAGC		0x300000
+#define	BRXSETTLE_HSSI			0x400000
+#define	BRXPROCESS_TIME_BBPPW		0x800000
+#define	BRXANTENNA_POWER_SHIFT		0x3000000
+#define	BRSSI_TABLE_SELECT		0xc000000
+#define	BRXHP_FINAL			0x7000000
+#define	BRXHPSETTLE_BBP			0x7
+#define	BRXHTSETTLE_HSSI		0x8
+#define	BRXHTSETTLE_RXHP		0x70
+#define	BRXHTSETTLE_BBPPW		0x80
+#define	BRXHTSETTLE_IDLE		0x300
+#define	BRXHTSETTLE_RESERVED		0x1c00
+#define	BRXHT_RXHP_EN			0x8000
+#define	BRXAGC_FREEZE_THRES		0x30000
+#define	BRXAGC_TOGETHEREN		0x40000
+#define	BRXHTAGC_MIN			0x80000
+#define	BRXHTAGC_EN			0x100000
+#define	BRXHTDAGC_EN			0x200000
+#define	BRXHT_RXHP_BBP			0x1c00000
+#define	BRXHT_RXHP_FINAL		0xe0000000
+#define	BRXPW_RADIO_TH			0x3
+#define	BRXPW_RADIO_EN			0x4
+#define	BRXMF_HOLD			0x3800
+#define	BRXPD_DELAY_TH1			0x38
+#define	BRXPD_DELAY_TH2			0x1c0
+#define	BRXPD_DC_COUNT_MAX		0x600
+#define	BRXPD_DELAY_TH			0x8000
+#define	BRXPROCESS_DELAY		0xf0000
+#define	BRXSEARCHRANGE_GI2_EARLY	0x700000
+#define	BRXFRAME_FUARD_COUNTER_L	0x3800000
+#define	BRXSGI_GUARD_L			0xc000000
+#define	BRXSGI_SEARCH_L			0x30000000
+#define	BRXSGI_TH			0xc0000000
+#define	BDFSCNT0			0xff
+#define	BDFSCNT1			0xff00
+#define	BDFSFLAG			0xf0000
+#define	BMF_WEIGHT_SUM			0x300000
+#define	BMINIDX_TH			0x7f000000
+#define	BDAFORMAT			0x40000
+#define	BTXCH_EMU_ENABLE		0x01000000
+#define	BTRSW_ISOLATION_A		0x7f
+#define	BTRSW_ISOLATION_B		0x7f00
+#define	BTRSW_ISOLATION_C		0x7f0000
+#define	BTRSW_ISOLATION_D		0x7f000000
+#define	BEXT_LNA_GAIN			0x7c00
+
+#define	BSTBC_EN			0x4
+#define	BANTENNA_MAPPING		0x10
+#define	BNSS				0x20
+#define	BCFO_ANTSUM_ID			0x200
+#define	BPHY_COUNTER_RESET		0x8000000
+#define	BCFO_REPORT_GET			0x4000000
+#define	BOFDM_CONTINUE_TX		0x10000000
+#define	BOFDM_SINGLE_CARRIER		0x20000000
+#define	BOFDM_SINGLE_TONE		0x40000000
+#define	BHT_DETECT			0x100
+#define	BCFOEN				0x10000
+#define	BCFOVALUE			0xfff00000
+#define	BSIGTONE_RE			0x3f
+#define	BSIGTONE_IM			0x7f00
+#define	BCOUNTER_CCA			0xffff
+#define	BCOUNTER_PARITYFAIL		0xffff0000
+#define	BCOUNTER_RATEILLEGAL		0xffff
+#define	BCOUNTER_CRC8FAIL		0xffff0000
+#define	BCOUNTER_MCSNOSUPPORT		0xffff
+#define	BCOUNTER_FASTSYNC		0xffff
+#define	BSHORTCFO			0xfff
+#define	BSHORTCFOT_LENGTH		12
+#define	BSHORTCFOF_LENGTH		11
+#define	BLONGCFO			0x7ff
+#define	BLONGCFOT_LENGTH		11
+#define	BLONGCFOF_LENGTH		11
+#define	BTAILCFO			0x1fff
+#define	BTAILCFOT_LENGTH		13
+#define	BTAILCFOF_LENGTH		12
+#define	BNOISE_EN_PWDB			0xffff
+#define	BCC_POWER_DB			0xffff0000
+#define	BMOISE_PWDB			0xffff
+#define	BPOWERMEAST_LENGTH		10
+#define	BPOWERMEASF_LENGTH		3
+#define	BRX_HT_BW			0x1
+#define	BRXSC				0x6
+#define	BRX_HT				0x8
+#define	BNB_INTF_DET_ON			0x1
+#define	BINTF_WIN_LEN_CFG		0x30
+#define	BNB_INTF_TH_CFG			0x1c0
+#define	BRFGAIN				0x3f
+#define	BTABLESEL			0x40
+#define	BTRSW				0x80
+#define	BRXSNR_A			0xff
+#define	BRXSNR_B			0xff00
+#define	BRXSNR_C			0xff0000
+#define	BRXSNR_D			0xff000000
+#define	BSNR_EVMT_LENGTH		8
+#define	BSNR_EVMF_LENGTH		1
+#define	BCSI1ST				0xff
+#define	BCSI2ND				0xff00
+#define	BRXEVM1ST			0xff0000
+#define	BRXEVM2ND			0xff000000
+#define	BSIGEVM				0xff
+#define	BPWDB				0xff00
+#define	BSGIEN				0x10000
+
+#define	BSFACTOR_QMA1			0xf
+#define	BSFACTOR_QMA2			0xf0
+#define	BSFACTOR_QMA3			0xf00
+#define	BSFACTOR_QMA4			0xf000
+#define	BSFACTOR_QMA5			0xf0000
+#define	BSFACTOR_QMA6			0xf0000
+#define	BSFACTOR_QMA7			0xf00000
+#define	BSFACTOR_QMA8			0xf000000
+#define	BSFACTOR_QMA9			0xf0000000
+#define	BCSI_SCHEME			0x100000
+
+#define	BNOISE_LVL_TOP_SET		0x3
+#define	BCHSMOOTH			0x4
+#define	BCHSMOOTH_CFG1			0x38
+#define	BCHSMOOTH_CFG2			0x1c0
+#define	BCHSMOOTH_CFG3			0xe00
+#define	BCHSMOOTH_CFG4			0x7000
+#define	BMRCMODE			0x800000
+#define	BTHEVMCFG			0x7000000
+
+#define	BLOOP_FIT_TYPE			0x1
+#define	BUPD_CFO			0x40
+#define	BUPD_CFO_OFFDATA		0x80
+#define	BADV_UPD_CFO			0x100
+#define	BADV_TIME_CTRL			0x800
+#define	BUPD_CLKO			0x1000
+#define	BFC				0x6000
+#define	BTRACKING_MODE			0x8000
+#define	BPHCMP_ENABLE			0x10000
+#define	BUPD_CLKO_LTF			0x20000
+#define	BCOM_CH_CFO			0x40000
+#define	BCSI_ESTI_MODE			0x80000
+#define	BADV_UPD_EQZ			0x100000
+#define	BUCHCFG				0x7000000
+#define	BUPDEQZ				0x8000000
+
+#define	BRX_PESUDO_NOISE_ON		0x20000000
+#define	BRX_PESUDO_NOISE_A		0xff
+#define	BRX_PESUDO_NOISE_B		0xff00
+#define	BRX_PESUDO_NOISE_C		0xff0000
+#define	BRX_PESUDO_NOISE_D		0xff000000
+#define	BRX_PESUDO_NOISESTATE_A		0xffff
+#define	BRX_PESUDO_NOISESTATE_B		0xffff0000
+#define	BRX_PESUDO_NOISESTATE_C		0xffff
+#define	BRX_PESUDO_NOISESTATE_D		0xffff0000
+
+#define	BZEBRA1_HSSIENABLE		0x8
+#define	BZEBRA1_TRXCONTROL		0xc00
+#define	BZEBRA1_TRXGAINSETTING		0x07f
+#define	BZEBRA1_RXCOUNTER		0xc00
+#define	BZEBRA1_TXCHANGEPUMP		0x38
+#define	BZEBRA1_RXCHANGEPUMP		0x7
+#define	BZEBRA1_CHANNEL_NUM		0xf80
+#define	BZEBRA1_TXLPFBW			0x400
+#define	BZEBRA1_RXLPFBW			0x600
+
+#define	BRTL8256REG_MODE_CTRL1		0x100
+#define	BRTL8256REG_MODE_CTRL0		0x40
+#define	BRTL8256REG_TXLPFBW		0x18
+#define	BRTL8256REG_RXLPFBW		0x600
+
+#define	BRTL8258_TXLPFBW		0xc
+#define	BRTL8258_RXLPFBW		0xc00
+#define	BRTL8258_RSSILPFBW		0xc0
+
+#define	BBYTE0				0x1
+#define	BBYTE1				0x2
+#define	BBYTE2				0x4
+#define	BBYTE3				0x8
+#define	BWORD0				0x3
+#define	BWORD1				0xc
+#define	BWORD				0xf
+
+#define	MASKBYTE0			0xff
+#define	MASKBYTE1			0xff00
+#define	MASKBYTE2			0xff0000
+#define	MASKBYTE3			0xff000000
+#define	MASKHWORD			0xffff0000
+#define	MASKLWORD			0x0000ffff
+#define	MASKDWORD			0xffffffff
+#define	MASK12BITS			0xfff
+#define	MASKH4BITS			0xf0000000
+#define MASKOFDM_D			0xffc00000
+#define	MASKCCK				0x3f3f3f3f
+
+#define	MASK4BITS			0x0f
+#define	MASK20BITS			0xfffff
+#define RFREG_OFFSET_MASK		0xfffff
+
+#define	BENABLE				0x1
+#define	BDISABLE			0x0
+
+#define	LEFT_ANTENNA			0x0
+#define	RIGHT_ANTENNA			0x1
+
+#define	TCHECK_TXSTATUS			500
+#define	TUPDATE_RXCOUNTER		100
+
+#define	REG_UN_used_register		0x01bf
+
+/* Path_A RFE cotrol pinmux*/
+#define		RA_RFE_PINMUX		0xcb0
+/* Path_B RFE control pinmux*/
+#define		RB_RFE_PINMUX		0xeb0
+
+#define		RA_RFE_INV		0xcb4
+#define		RB_RFE_INV		0xeb4
+
+/* RXIQC */
+/*RxIQ imblance matrix coeff. A & B*/
+#define RA_RXIQC_AB			0xc10
+/*RxIQ imblance matrix coeff. C & D*/
+#define	RA_RXIQC_CD			0xc14
+/* Pah_A TX scaling factor*/
+#define	RA_TXSCALE			0xc1c
+/* Path_B TX scaling factor*/
+#define	RB_TXSCALE			0xe1c
+/*RxIQ imblance matrix coeff. A & B*/
+#define	RB_RXIQC_AB			0xe10
+/*RxIQ imblance matrix coeff. C & D*/
+#define	RB_RXIQC_CD			0xe14
+/*bit mask for IQC matrix element A & C*/
+#define	RXIQC_AC			0x02ff
+ /*bit mask for IQC matrix element A & C*/
+#define	RXIQC_BD			0x02ff0000
+
+/* 2 EFUSE_TEST (For RTL8723 partially) */
+#define EFUSE_SEL(x)			(((x) & 0x3) << 8)
+#define EFUSE_SEL_MASK			0x300
+#define EFUSE_WIFI_SEL_0		0x0
+
+/*REG_MULTI_FUNC_CTRL(For RTL8723 Only)*/
+/* Enable GPIO[9] as WiFi HW PDn source*/
+#define	WL_HWPDN_EN			BIT(0)
+/* WiFi HW PDn polarity control*/
+#define	WL_HWPDN_SL			BIT(1)
+/* WiFi function enable */
+#define	WL_FUNC_EN			BIT(2)
+/* Enable GPIO[9] as WiFi RF HW PDn source */
+#define	WL_HWROF_EN			BIT(3)
+/* Enable GPIO[11] as BT HW PDn source */
+#define	BT_HWPDN_EN			BIT(16)
+/* BT HW PDn polarity control */
+#define	BT_HWPDN_SL			BIT(17)
+/* BT function enable */
+#define	BT_FUNC_EN			BIT(18)
+/* Enable GPIO[11] as BT/GPS RF HW PDn source */
+#define	BT_HWROF_EN			BIT(19)
+/* Enable GPIO[10] as GPS HW PDn source */
+#define	GPS_HWPDN_EN			BIT(20)
+/* GPS HW PDn polarity control */
+#define	GPS_HWPDN_SL			BIT(21)
+/* GPS function enable */
+#define	GPS_FUNC_EN			BIT(22)
+
+#define	BMASKBYTE0			0xff
+#define	BMASKBYTE1			0xff00
+#define	BMASKBYTE2			0xff0000
+#define	BMASKBYTE3			0xff000000
+#define	BMASKHWORD			0xffff0000
+#define	BMASKLWORD			0x0000ffff
+#define	BMASKDWORD			0xffffffff
+#define	BMASK12BITS			0xfff
+#define	BMASKH4BITS			0xf0000000
+#define BMASKOFDM_D			0xffc00000
+#define	BMASKCCK			0x3f3f3f3f
+
+#define BRFREGOFFSETMASK		0xfffff
+
+#define	ODM_REG_CCK_RPT_FORMAT_11AC	0x804
+#define	ODM_REG_BB_RX_PATH_11AC		0x808
+/*PAGE 9*/
+#define	ODM_REG_OFDM_FA_RST_11AC	0x9A4
+/*PAGE A*/
+#define	ODM_REG_CCK_CCA_11AC		0xA0A
+#define	ODM_REG_CCK_FA_RST_11AC		0xA2C
+#define	ODM_REG_CCK_FA_11AC		0xA5C
+/*PAGE C*/
+#define	ODM_REG_IGI_A_11AC		0xC50
+/*PAGE E*/
+#define	ODM_REG_IGI_B_11AC		0xE50
+/*PAGE F*/
+#define	ODM_REG_OFDM_FA_11AC		0xF48
+
+/* 2 MAC REG LIST */
+
+/* DIG Related */
+#define	ODM_BIT_IGI_11AC		0xFFFFFFFF
+#define	ODM_BIT_CCK_RPT_FORMAT_11AC	BIT16
+#define	ODM_BIT_BB_RX_PATH_11AC		0xF
+
+enum AGGRE_SIZE {
+	HT_AGG_SIZE_8K =3D 0,
+	HT_AGG_SIZE_16K =3D 1,
+	HT_AGG_SIZE_32K =3D 2,
+	HT_AGG_SIZE_64K =3D 3,
+	VHT_AGG_SIZE_128K =3D 4,
+	VHT_AGG_SIZE_256K =3D 5,
+	VHT_AGG_SIZE_512K =3D 6,
+	VHT_AGG_SIZE_1024K =3D 7,
+};
+
+#define REG_AMPDU_MAX_LENGTH_8812	0x0458
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/rf.c b/drivers/net/=
wireless/rtlwifi/rtl8821ae/rf.c
new file mode 100644
index 0000000..2922538
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/rf.c
@@ -0,0 +1,465 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "rf.h"
+#include "dm.h"
+
+static bool _rtl8821ae_phy_rf6052_config_parafile(struct ieee80211_hw =
*hw);
+
+void rtl8821ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 ba=
ndwidth)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	switch (bandwidth) {
+	case HT_CHANNEL_WIDTH_20:
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, BIT(11)|BIT(10), 3);
+		rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, BIT(11)|BIT(10), 3);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, BIT(11)|BIT(10), 1);
+		rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, BIT(11)|BIT(10), 1);
+		break;
+	case HT_CHANNEL_WIDTH_80:
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, BIT(11)|BIT(10), 0);
+		rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, BIT(11)|BIT(10), 0);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "unknown bandwidth: %#X\n", bandwidth);
+		break;
+	}
+}
+
+void rtl8821ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	u32 tx_agc[2] =3D {0, 0}, tmpval;
+	bool turbo_scanoff =3D false;
+	u8 idx1, idx2;
+	u8 *ptr;
+	u8 direction;
+	u32 pwrtrac_value;
+
+	if (rtlefuse->eeprom_regulatory !=3D 0)
+		turbo_scanoff =3D true;
+
+	if (mac->act_scanning) {
+		tx_agc[RF90_PATH_A] =3D 0x3f3f3f3f;
+		tx_agc[RF90_PATH_B] =3D 0x3f3f3f3f;
+
+		if (turbo_scanoff) {
+			for (idx1 =3D RF90_PATH_A;
+				idx1 <=3D RF90_PATH_B;
+				idx1++) {
+				tx_agc[idx1] =3D ppowerlevel[idx1] |
+				    (ppowerlevel[idx1] << 8) |
+				    (ppowerlevel[idx1] << 16) |
+				    (ppowerlevel[idx1] << 24);
+			}
+		}
+	} else {
+		for (idx1 =3D RF90_PATH_A; idx1 <=3D RF90_PATH_B; idx1++) {
+			tx_agc[idx1] =3D ppowerlevel[idx1] |
+			    (ppowerlevel[idx1] << 8) |
+			    (ppowerlevel[idx1] << 16) |
+			    (ppowerlevel[idx1] << 24);
+		}
+
+		if (rtlefuse->eeprom_regulatory =3D=3D 0) {
+			tmpval =3D
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] <<
+			     8);
+			tx_agc[RF90_PATH_A] +=3D tmpval;
+
+			tmpval =3D (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
+			    (rtlphy->mcs_txpwrlevel_origoffset[0][15] <<
+			     24);
+			tx_agc[RF90_PATH_B] +=3D tmpval;
+		}
+	}
+
+	for (idx1 =3D RF90_PATH_A; idx1 <=3D RF90_PATH_B; idx1++) {
+		ptr =3D (u8 *)(&tx_agc[idx1]);
+		for (idx2 =3D 0; idx2 < 4; idx2++) {
+			if (*ptr > RF6052_MAX_TX_PWR)
+				*ptr =3D RF6052_MAX_TX_PWR;
+			ptr++;
+		}
+	}
+	rtl8821ae_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
+	if (direction =3D=3D 1) {
+		tx_agc[0] +=3D pwrtrac_value;
+		tx_agc[1] +=3D pwrtrac_value;
+	} else if (direction =3D=3D 2) {
+		tx_agc[0] -=3D pwrtrac_value;
+		tx_agc[1] -=3D pwrtrac_value;
+	}
+	tmpval =3D tx_agc[RF90_PATH_A];
+	rtl_set_bbreg(hw, RTXAGC_A_CCK11_CCK1, MASKDWORD, tmpval);
+
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 1~11M (rf-A) =3D 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_A_CCK11_CCK1);
+
+	tmpval =3D tx_agc[RF90_PATH_B];
+	rtl_set_bbreg(hw, RTXAGC_B_CCK11_CCK1, MASKDWORD, tmpval);
+
+	RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+		"CCK PWR 11M (rf-B) =3D 0x%x (reg 0x%x)\n", tmpval,
+		 RTXAGC_B_CCK11_CCK1);
+}
+
+static void rtl8821ae_phy_get_power_base(struct ieee80211_hw *hw,
+					 u8 *ppowerlevel_ofdm,
+					 u8 *ppowerlevel_bw20,
+					 u8 *ppowerlevel_bw40, u8 channel,
+					 u32 *ofdmbase, u32 *mcsbase)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u32 powerbase0, powerbase1;
+	u8 i, powerlevel[2];
+
+	for (i =3D 0; i < 2; i++) {
+		powerbase0 =3D ppowerlevel_ofdm[i];
+
+		powerbase0 =3D (powerbase0 << 24) | (powerbase0 << 16) |
+		    (powerbase0 << 8) | powerbase0;
+		*(ofdmbase + i) =3D powerbase0;
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+			" [OFDM power base index rf(%c) =3D 0x%x]\n",
+			 ((i =3D=3D 0) ? 'A' : 'B'), *(ofdmbase + i));
+	}
+
+	for (i =3D 0; i < 2; i++) {
+		if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20)
+			powerlevel[i] =3D ppowerlevel_bw20[i];
+		else
+			powerlevel[i] =3D ppowerlevel_bw40[i];
+
+		powerbase1 =3D powerlevel[i];
+		powerbase1 =3D (powerbase1 << 24) |
+		    (powerbase1 << 16) | (powerbase1 << 8) | powerbase1;
+
+		*(mcsbase + i) =3D powerbase1;
+
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+			" [MCS power base index rf(%c) =3D 0x%x]\n",
+			 ((i =3D=3D 0) ? 'A' : 'B'), *(mcsbase + i));
+	}
+}
+
+static void get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw=
,
+					       u8 channel, u8 index,
+					       u32 *powerbase0,
+					       u32 *powerbase1,
+					       u32 *p_outwriteval)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	u8 i, chnlgroup =3D 0, pwr_diff_limit[4], pwr_diff =3D 0, customer_pw=
r_diff;
+	u32 writeval, customer_limit, rf;
+
+	for (rf =3D 0; rf < 2; rf++) {
+		switch (rtlefuse->eeprom_regulatory) {
+		case 0:
+			chnlgroup =3D 0;
+
+			writeval =3D
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index +
+							(rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeval(%c) =3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), writeval);
+			break;
+		case 1:
+			if (rtlphy->pwrgroup_cnt =3D=3D 1) {
+				chnlgroup =3D 0;
+			} else {
+				if (channel < 3)
+					chnlgroup =3D 0;
+				else if (channel < 6)
+					chnlgroup =3D 1;
+				else if (channel < 9)
+					chnlgroup =3D 2;
+				else if (channel < 12)
+					chnlgroup =3D 3;
+				else if (channel < 14)
+					chnlgroup =3D 4;
+				else if (channel =3D=3D 14)
+					chnlgroup =3D 5;
+			}
+
+			writeval =3D
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			    [index + (rf ? 8 : 0)] + ((index < 2) ?
+						      powerbase0[rf] :
+						      powerbase1[rf]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Realtek regulatory, 20MHz, writeval(%c) =3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), writeval);
+
+			break;
+		case 2:
+			writeval =3D
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Better regulatory, writeval(%c) =3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), writeval);
+			break;
+		case 3:
+			chnlgroup =3D 0;
+
+			if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+					"customer's limit, 40MHz rf(%c) =3D 0x%x\n",
+					 ((rf =3D=3D 0) ? 'A' : 'B'),
+					 rtlefuse->pwrgroup_ht40[rf][channel -
+								     1]);
+			} else {
+				RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+					"customer's limit, 20MHz rf(%c) =3D 0x%x\n",
+					 ((rf =3D=3D 0) ? 'A' : 'B'),
+					 rtlefuse->pwrgroup_ht20[rf][channel -
+								     1]);
+			}
+
+			if (index < 2)
+				pwr_diff =3D rtlefuse->txpwr_legacyhtdiff[rf][channel-1];
+			else if (rtlphy->current_chan_bw =3D=3D  HT_CHANNEL_WIDTH_20)
+				pwr_diff =3D
+				  rtlefuse->txpwr_ht20diff[rf][channel-1];
+
+			if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40)
+				customer_pwr_diff =3D
+				  rtlefuse->pwrgroup_ht40[rf][channel-1];
+			else
+				customer_pwr_diff =3D
+				  rtlefuse->pwrgroup_ht20[rf][channel-1];
+
+			if (pwr_diff > customer_pwr_diff)
+				pwr_diff =3D 0;
+			else
+				pwr_diff =3D customer_pwr_diff - pwr_diff;
+
+			for (i =3D 0; i < 4; i++) {
+				pwr_diff_limit[i] =3D
+				    (u8)((rtlphy->mcs_txpwrlevel_origoffset
+				    [chnlgroup][index + (rf ? 8 : 0)] &
+				    (0x7f << (i * 8))) >> (i * 8));
+
+				if (pwr_diff_limit[i] > pwr_diff)
+					pwr_diff_limit[i] =3D pwr_diff;
+			}
+
+			customer_limit =3D (pwr_diff_limit[3] << 24) |
+			    (pwr_diff_limit[2] << 16) |
+			    (pwr_diff_limit[1] << 8) | (pwr_diff_limit[0]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Customer's limit rf(%c) =3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), customer_limit);
+
+			writeval =3D customer_limit +
+			    ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"Customer, writeval rf(%c)=3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), writeval);
+			break;
+		default:
+			chnlgroup =3D 0;
+			writeval =3D
+			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			    [index + (rf ? 8 : 0)]
+			    + ((index < 2) ? powerbase0[rf] : powerbase1[rf]);
+
+			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+				"RTK better performance, writeval rf(%c) =3D 0x%x\n",
+				 ((rf =3D=3D 0) ? 'A' : 'B'), writeval);
+			break;
+		}
+
+		if (rtlpriv->dm.dynamic_txhighpower_lvl =3D=3D TXHIGHPWRLEVEL_BT1)
+			writeval =3D writeval - 0x06060606;
+		else if (rtlpriv->dm.dynamic_txhighpower_lvl =3D=3D
+			 TXHIGHPWRLEVEL_BT2)
+			writeval =3D writeval - 0x0c0c0c0c;
+		*(p_outwriteval + rf) =3D writeval;
+	}
+}
+
+static void _rtl8821ae_write_ofdm_power_reg(struct ieee80211_hw *hw,
+					    u8 index, u32 *pvalue)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u16 regoffset_a[6] =3D {
+		RTXAGC_A_OFDM18_OFDM6, RTXAGC_A_OFDM54_OFDM24,
+		RTXAGC_A_MCS03_MCS00, RTXAGC_A_MCS07_MCS04,
+		RTXAGC_A_MCS11_MCS08, RTXAGC_A_MCS15_MCS12
+	};
+	u16 regoffset_b[6] =3D {
+		RTXAGC_B_OFDM18_OFDM6, RTXAGC_B_OFDM54_OFDM24,
+		RTXAGC_B_MCS03_MCS00, RTXAGC_B_MCS07_MCS04,
+		RTXAGC_B_MCS11_MCS08, RTXAGC_B_MCS15_MCS12
+	};
+	u8 i, rf, pwr_val[4];
+	u32 writeval;
+	u16 regoffset;
+
+	for (rf =3D 0; rf < 2; rf++) {
+		writeval =3D pvalue[rf];
+		for (i =3D 0; i < 4; i++) {
+			pwr_val[i] =3D (u8)((writeval & (0x7f <<
+							(i * 8))) >> (i * 8));
+
+			if (pwr_val[i] > RF6052_MAX_TX_PWR)
+				pwr_val[i] =3D RF6052_MAX_TX_PWR;
+		}
+		writeval =3D (pwr_val[3] << 24) | (pwr_val[2] << 16) |
+		    (pwr_val[1] << 8) | pwr_val[0];
+
+		if (rf =3D=3D 0)
+			regoffset =3D regoffset_a[index];
+		else
+			regoffset =3D regoffset_b[index];
+		rtl_set_bbreg(hw, regoffset, MASKDWORD, writeval);
+
+		RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
+			"Set 0x%x =3D %08x\n", regoffset, writeval);
+	}
+}
+
+void rtl8821ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					   u8 *ppowerlevel_ofdm,
+					   u8 *ppowerlevel_bw20,
+					   u8 *ppowerlevel_bw40,
+					   u8 channel)
+{
+	u32 writeval[2], powerbase0[2], powerbase1[2];
+	u8 index;
+	u8 direction;
+	u32 pwrtrac_value;
+
+	rtl8821ae_phy_get_power_base(hw, ppowerlevel_ofdm,
+				     ppowerlevel_bw20,
+				     ppowerlevel_bw40,
+				     channel,
+				     &powerbase0[0],
+				     &powerbase1[0]);
+
+	rtl8821ae_dm_txpower_track_adjust(hw, 1, &direction, &pwrtrac_value);
+
+	for (index =3D 0; index < 6; index++) {
+		get_txpower_writeval_by_regulatory(hw, channel, index,
+						   &powerbase0[0],
+						   &powerbase1[0],
+						   &writeval[0]);
+		if (direction =3D=3D 1) {
+			writeval[0] +=3D pwrtrac_value;
+			writeval[1] +=3D pwrtrac_value;
+		} else if (direction =3D=3D 2) {
+			writeval[0] -=3D pwrtrac_value;
+			writeval[1] -=3D pwrtrac_value;
+		}
+		_rtl8821ae_write_ofdm_power_reg(hw, index, &writeval[0]);
+	}
+}
+
+bool rtl8821ae_phy_rf6052_config(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+
+	if (rtlphy->rf_type =3D=3D RF_1T1R)
+		rtlphy->num_total_rfpath =3D 1;
+	else
+		rtlphy->num_total_rfpath =3D 2;
+
+	return _rtl8821ae_phy_rf6052_config_parafile(hw);
+}
+
+static bool _rtl8821ae_phy_rf6052_config_parafile(struct ieee80211_hw =
*hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u8 rfpath;
+	bool rtstatus =3D true;
+
+	for (rfpath =3D 0; rfpath < rtlphy->num_total_rfpath; rfpath++) {
+		switch (rfpath) {
+		case RF90_PATH_A: {
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+				rtstatus =3D
+				  rtl8812ae_phy_config_rf_with_headerfile(hw,
+							(enum radio_path)rfpath);
+			else
+				rtstatus =3D
+				  rtl8821ae_phy_config_rf_with_headerfile(hw,
+							(enum radio_path)rfpath);
+			break;
+			}
+		case RF90_PATH_B:
+			if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+				rtstatus =3D
+				  rtl8812ae_phy_config_rf_with_headerfile(hw,
+							(enum radio_path)rfpath);
+			else
+				rtstatus =3D
+				  rtl8821ae_phy_config_rf_with_headerfile(hw,
+							(enum radio_path)rfpath);
+			break;
+		case RF90_PATH_C:
+			break;
+		case RF90_PATH_D:
+			break;
+		}
+
+		if (!rtstatus) {
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
+				 "Radio[%d] Fail!!", rfpath);
+			return false;
+		}
+	}
+
+	/*put arrays in dm.c*/
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "\n");
+	return rtstatus;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h b/drivers/net/=
wireless/rtlwifi/rtl8821ae/rf.h
new file mode 100644
index 0000000..d9582ee
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/rf.h
@@ -0,0 +1,43 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_RF_H__
+#define __RTL8821AE_RF_H__
+
+#define RF6052_MAX_TX_PWR		0x3F
+#define RF6052_MAX_REG			0x3F
+
+void rtl8821ae_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
+					u8 bandwidth);
+void rtl8821ae_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
+					  u8 *ppowerlevel);
+void rtl8821ae_phy_rf6052_set_ofdm_txpower(struct ieee80211_hw *hw,
+					   u8 *ppowerlevel_ofdm,
+					   u8 *ppowerlevel_bw20,
+					   u8 *ppowerlevel_bw40,
+					   u8 channel);
+bool rtl8821ae_phy_rf6052_config(struct ieee80211_hw *hw);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/sw.c b/drivers/net/=
wireless/rtlwifi/rtl8821ae/sw.c
new file mode 100644
index 0000000..3cf7557
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/sw.c
@@ -0,0 +1,484 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../core.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "dm.h"
+#include "hw.h"
+#include "fw.h"
+#include "sw.h"
+#include "trx.h"
+#include "led.h"
+#include "table.h"
+#include "../btcoexist/rtl_btc.h"
+
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+static void rtl8821ae_init_aspm_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+
+	/*close ASPM for AMD defaultly */
+	rtlpci->const_amdpci_aspm =3D 0;
+
+	/**
+	 * ASPM PS mode.
+	 * 0 - Disable ASPM,
+	 * 1 - Enable ASPM without Clock Req,
+	 * 2 - Enable ASPM with Clock Req,
+	 * 3 - Alwyas Enable ASPM with Clock Req,
+	 * 4 - Always Enable ASPM without Clock Req.
+	 * set defult to RTL8192CE:3 RTL8192E:2
+	 */
+	rtlpci->const_pci_aspm =3D 3;
+
+	/*Setting for PCI-E device */
+	rtlpci->const_devicepci_aspm_setting =3D 0x03;
+
+	/*Setting for PCI-E bridge */
+	rtlpci->const_hostpci_aspm_setting =3D 0x02;
+
+	/**
+	 * In Hw/Sw Radio Off situation.
+	 * 0 - Default,
+	 * 1 - From ASPM setting without low Mac Pwr,
+	 * 2 - From ASPM setting with low Mac Pwr,
+	 * 3 - Bus D3
+	 * set default to RTL8192CE:0 RTL8192SE:2
+	 */
+	rtlpci->const_hwsw_rfoff_d3 =3D 0;
+
+	/**
+	 * This setting works for those device with
+	 * backdoor ASPM setting such as EPHY setting.
+	 * 0 - Not support ASPM,
+	 * 1 - Support ASPM,
+	 * 2 - According to chipset.
+	 */
+	rtlpci->const_support_pciaspm =3D 1;
+}
+
+static void load_wowlan_fw(struct rtl_priv *rtlpriv)
+{
+	/* callback routine to load wowlan firmware after main fw has
+	 * been loaded
+	 */
+	const struct firmware *wowlan_firmware;
+	char *fw_name =3D NULL;
+	int err;
+
+	/* for wowlan firmware buf */
+	rtlpriv->rtlhal.wowlan_firmware =3D vmalloc(0x8000);
+	if (!rtlpriv->rtlhal.wowlan_firmware) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Can't alloc buffer for wowlan fw.\n");
+		return;
+	}
+
+	if (rtlpriv->rtlhal.hw_type =3D=3D HARDWARE_TYPE_RTL8821AE)
+		fw_name =3D "rtlwifi/rtl8821aefw_wowlan.bin";
+	else
+		fw_name =3D "rtlwifi/rtl8812aefw_wowlan.bin";
+	err =3D request_firmware(&wowlan_firmware, fw_name, rtlpriv->io.dev);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Failed to request wowlan firmware!\n");
+		goto error;
+	}
+
+	if (wowlan_firmware->size > 0x8000) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Wowlan Firmware is too big!\n");
+		goto error;
+	}
+
+	memcpy(rtlpriv->rtlhal.wowlan_firmware, wowlan_firmware->data,
+	       wowlan_firmware->size);
+	rtlpriv->rtlhal.wowlan_fwsize =3D wowlan_firmware->size;
+	release_firmware(wowlan_firmware);
+
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "WOWLAN FirmwareDownload OK\n"=
);
+	return;
+error:
+	release_firmware(wowlan_firmware);
+	vfree(rtlpriv->rtlhal.wowlan_firmware);
+}
+
+/*InitializeVariables8812E*/
+int rtl8821ae_init_sw_vars(struct ieee80211_hw *hw)
+{
+	int err =3D 0;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+
+	rtl8821ae_bt_reg_init(hw);
+	rtlpci->msi_support =3D rtlpriv->cfg->mod_params->msi_support;
+	rtlpriv->btcoexist.btc_ops =3D rtl_btc_get_ops_pointer();
+
+	rtlpriv->dm.dm_initialgain_enable =3D 1;
+	rtlpriv->dm.dm_flag =3D 0;
+	rtlpriv->dm.disable_framebursting =3D 0;
+	rtlpriv->dm.thermalvalue =3D 0;
+	rtlpci->transmit_config =3D CFENDFORM | BIT(15) | BIT(24) | BIT(25);
+
+	mac->ht_enable =3D true;
+	mac->ht_cur_stbc =3D 0;
+	mac->ht_stbc_cap =3D 0;
+	mac->vht_cur_ldpc =3D 0;
+	mac->vht_ldpc_cap =3D 0;
+	mac->vht_cur_stbc =3D 0;
+	mac->vht_stbc_cap =3D 0;
+
+	rtlpriv->rtlhal.current_bandtype =3D BAND_ON_2_4G;
+	/*following 2 is for register 5G band, refer to _rtl_init_mac80211()*=
/
+	rtlpriv->rtlhal.bandset =3D BAND_ON_BOTH;
+	rtlpriv->rtlhal.macphymode =3D SINGLEMAC_SINGLEPHY;
+
+	rtlpci->receive_config =3D (RCR_APPFCS	|
+				RCR_APP_MIC		|
+				RCR_APP_ICV		|
+				RCR_APP_PHYST_RXFF	|
+				RCR_NONQOS_VHT		|
+				RCR_HTC_LOC_CTRL	|
+				RCR_AMF			|
+				RCR_ACF			|
+			/*This bit controls the PS-Poll packet filter.*/
+				RCR_ADF			|
+				RCR_AICV		|
+				RCR_ACRC32		|
+				RCR_AB			|
+				RCR_AM			|
+				RCR_APM			|
+				0);
+
+	rtlpci->irq_mask[0] =3D
+	     (u32)(IMR_PSTIMEOUT			|
+				IMR_GTINT3		|
+				IMR_HSISR_IND_ON_INT	|
+				IMR_C2HCMD		|
+				IMR_HIGHDOK		|
+				IMR_MGNTDOK		|
+				IMR_BKDOK		|
+				IMR_BEDOK		|
+				IMR_VIDOK		|
+				IMR_VODOK		|
+				IMR_RDU			|
+				IMR_ROK			|
+				0);
+
+	rtlpci->irq_mask[1]	=3D
+		 (u32)(IMR_RXFOVW |
+				IMR_TXFOVW |
+				0);
+	rtlpci->sys_irq_mask =3D (u32)(HSIMR_PDN_INT_EN	|
+				      HSIMR_RON_INT_EN	|
+				      0);
+	/* for WOWLAN */
+	rtlpriv->psc.wo_wlan_mode =3D WAKE_ON_MAGIC_PACKET |
+				    WAKE_ON_PATTERN_MATCH;
+
+	/* for debug level */
+	rtlpriv->dbg.global_debuglevel =3D rtlpriv->cfg->mod_params->debug;
+	/* for LPS & IPS */
+	rtlpriv->psc.inactiveps =3D rtlpriv->cfg->mod_params->inactiveps;
+	rtlpriv->psc.swctrl_lps =3D rtlpriv->cfg->mod_params->swctrl_lps;
+	rtlpriv->psc.fwctrl_lps =3D rtlpriv->cfg->mod_params->fwctrl_lps;
+	rtlpci->msi_support =3D rtlpriv->cfg->mod_params->msi_support;
+	if (rtlpriv->cfg->mod_params->disable_watchdog)
+		pr_info("watchdog disabled\n");
+	rtlpriv->psc.reg_fwctrl_lps =3D 3;
+	rtlpriv->psc.reg_max_lps_awakeintvl =3D 5;
+	rtlpci->msi_support =3D rtlpriv->cfg->mod_params->msi_support;
+
+	/* for ASPM, you can close aspm through
+	 * set const_support_pciaspm =3D 0
+	 */
+	rtl8821ae_init_aspm_vars(hw);
+
+	if (rtlpriv->psc.reg_fwctrl_lps =3D=3D 1)
+		rtlpriv->psc.fwctrl_psmode =3D FW_PS_MIN_MODE;
+	else if (rtlpriv->psc.reg_fwctrl_lps =3D=3D 2)
+		rtlpriv->psc.fwctrl_psmode =3D FW_PS_MAX_MODE;
+	else if (rtlpriv->psc.reg_fwctrl_lps =3D=3D 3)
+		rtlpriv->psc.fwctrl_psmode =3D FW_PS_DTIM_MODE;
+
+	rtlpriv->rtl_fw_second_cb =3D load_wowlan_fw;
+	/* for firmware buf */
+	rtlpriv->rtlhal.pfirmware =3D vzalloc(0x8000);
+	if (!rtlpriv->rtlhal.pfirmware) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Can't alloc buffer for fw.\n");
+		return 1;
+	}
+
+	if (rtlhal->hw_type =3D=3D HARDWARE_TYPE_RTL8812AE)
+		rtlpriv->cfg->fw_name =3D "rtlwifi/rtl8812aefw.bin";
+	else
+		rtlpriv->cfg->fw_name =3D "rtlwifi/rtl8821aefw.bin";
+
+	rtlpriv->max_fw_size =3D 0x8000;
+	pr_info("Using firmware %s\n", rtlpriv->cfg->fw_name);
+	err =3D request_firmware_nowait(THIS_MODULE, 1, rtlpriv->cfg->fw_name=
,
+				      rtlpriv->io.dev, GFP_KERNEL, hw,
+				      rtl_fw_cb);
+	if (err) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "Failed to request firmware!\n");
+		return 1;
+	}
+	return 0;
+}
+
+void rtl8821ae_deinit_sw_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (rtlpriv->rtlhal.pfirmware) {
+		vfree(rtlpriv->rtlhal.pfirmware);
+		rtlpriv->rtlhal.pfirmware =3D NULL;
+	}
+#if (USE_SPECIFIC_FW_TO_SUPPORT_WOWLAN =3D=3D 1)
+	if (rtlpriv->rtlhal.wowlan_firmware) {
+		vfree(rtlpriv->rtlhal.wowlan_firmware);
+		rtlpriv->rtlhal.wowlan_firmware =3D NULL;
+	}
+#endif
+}
+
+/* get bt coexist status */
+bool rtl8821ae_get_btc_status(void)
+{
+	return true;
+}
+
+static struct rtl_hal_ops rtl8821ae_hal_ops =3D {
+	.init_sw_vars =3D rtl8821ae_init_sw_vars,
+	.deinit_sw_vars =3D rtl8821ae_deinit_sw_vars,
+	.read_eeprom_info =3D rtl8821ae_read_eeprom_info,
+	.interrupt_recognized =3D rtl8821ae_interrupt_recognized,
+	.hw_init =3D rtl8821ae_hw_init,
+	.hw_disable =3D rtl8821ae_card_disable,
+	.hw_suspend =3D rtl8821ae_suspend,
+	.hw_resume =3D rtl8821ae_resume,
+	.enable_interrupt =3D rtl8821ae_enable_interrupt,
+	.disable_interrupt =3D rtl8821ae_disable_interrupt,
+	.set_network_type =3D rtl8821ae_set_network_type,
+	.set_chk_bssid =3D rtl8821ae_set_check_bssid,
+	.set_qos =3D rtl8821ae_set_qos,
+	.set_bcn_reg =3D rtl8821ae_set_beacon_related_registers,
+	.set_bcn_intv =3D rtl8821ae_set_beacon_interval,
+	.update_interrupt_mask =3D rtl8821ae_update_interrupt_mask,
+	.get_hw_reg =3D rtl8821ae_get_hw_reg,
+	.set_hw_reg =3D rtl8821ae_set_hw_reg,
+	.update_rate_tbl =3D rtl8821ae_update_hal_rate_tbl,
+	.fill_tx_desc =3D rtl8821ae_tx_fill_desc,
+	.fill_tx_cmddesc =3D rtl8821ae_tx_fill_cmddesc,
+	.query_rx_desc =3D rtl8821ae_rx_query_desc,
+	.set_channel_access =3D rtl8821ae_update_channel_access_setting,
+	.radio_onoff_checking =3D rtl8821ae_gpio_radio_on_off_checking,
+	.set_bw_mode =3D rtl8821ae_phy_set_bw_mode,
+	.switch_channel =3D rtl8821ae_phy_sw_chnl,
+	.dm_watchdog =3D rtl8821ae_dm_watchdog,
+	.scan_operation_backup =3D rtl8821ae_phy_scan_operation_backup,
+	.set_rf_power_state =3D rtl8821ae_phy_set_rf_power_state,
+	.led_control =3D rtl8821ae_led_control,
+	.set_desc =3D rtl8821ae_set_desc,
+	.get_desc =3D rtl8821ae_get_desc,
+	.is_tx_desc_closed =3D rtl8821ae_is_tx_desc_closed,
+	.tx_polling =3D rtl8821ae_tx_polling,
+	.enable_hw_sec =3D rtl8821ae_enable_hw_security_config,
+	.set_key =3D rtl8821ae_set_key,
+	.init_sw_leds =3D rtl8821ae_init_sw_leds,
+	.get_bbreg =3D rtl8821ae_phy_query_bb_reg,
+	.set_bbreg =3D rtl8821ae_phy_set_bb_reg,
+	.get_rfreg =3D rtl8821ae_phy_query_rf_reg,
+	.set_rfreg =3D rtl8821ae_phy_set_rf_reg,
+	.fill_h2c_cmd =3D rtl8821ae_fill_h2c_cmd,
+	.get_btc_status =3D rtl8821ae_get_btc_status,
+	.rx_command_packet =3D rtl8821ae_rx_command_packet,
+	.add_wowlan_pattern =3D rtl8821ae_add_wowlan_pattern,
+};
+
+static struct rtl_mod_params rtl8821ae_mod_params =3D {
+	.sw_crypto =3D false,
+	.inactiveps =3D true,
+	.swctrl_lps =3D false,
+	.fwctrl_lps =3D true,
+	.msi_support =3D true,
+	.debug =3D DBG_EMERG,
+	.disable_watchdog =3D 0,
+};
+
+static struct rtl_hal_cfg rtl8821ae_hal_cfg =3D {
+	.bar_id =3D 2,
+	.write_readback =3D true,
+	.name =3D "rtl8821ae_pci",
+	.fw_name =3D "rtlwifi/rtl8821aefw.bin",
+	.ops =3D &rtl8821ae_hal_ops,
+	.mod_params =3D &rtl8821ae_mod_params,
+	.maps[SYS_ISO_CTRL] =3D REG_SYS_ISO_CTRL,
+	.maps[SYS_FUNC_EN] =3D REG_SYS_FUNC_EN,
+	.maps[SYS_CLK] =3D REG_SYS_CLKR,
+	.maps[MAC_RCR_AM] =3D AM,
+	.maps[MAC_RCR_AB] =3D AB,
+	.maps[MAC_RCR_ACRC32] =3D ACRC32,
+	.maps[MAC_RCR_ACF] =3D ACF,
+	.maps[MAC_RCR_AAP] =3D AAP,
+	.maps[MAC_HIMR] =3D REG_HIMR,
+	.maps[MAC_HIMRE] =3D REG_HIMRE,
+
+	.maps[EFUSE_ACCESS] =3D REG_EFUSE_ACCESS,
+
+	.maps[EFUSE_TEST] =3D REG_EFUSE_TEST,
+	.maps[EFUSE_CTRL] =3D REG_EFUSE_CTRL,
+	.maps[EFUSE_CLK] =3D 0,
+	.maps[EFUSE_CLK_CTRL] =3D REG_EFUSE_CTRL,
+	.maps[EFUSE_PWC_EV12V] =3D PWC_EV12V,
+	.maps[EFUSE_FEN_ELDR] =3D FEN_ELDR,
+	.maps[EFUSE_LOADER_CLK_EN] =3D LOADER_CLK_EN,
+	.maps[EFUSE_ANA8M] =3D ANA8M,
+	.maps[EFUSE_HWSET_MAX_SIZE] =3D HWSET_MAX_SIZE,
+	.maps[EFUSE_MAX_SECTION_MAP] =3D EFUSE_MAX_SECTION,
+	.maps[EFUSE_REAL_CONTENT_SIZE] =3D EFUSE_REAL_CONTENT_LEN,
+	.maps[EFUSE_OOB_PROTECT_BYTES_LEN] =3D EFUSE_OOB_PROTECT_BYTES,
+
+	.maps[RWCAM] =3D REG_CAMCMD,
+	.maps[WCAMI] =3D REG_CAMWRITE,
+	.maps[RCAMO] =3D REG_CAMREAD,
+	.maps[CAMDBG] =3D REG_CAMDBG,
+	.maps[SECR] =3D REG_SECCFG,
+	.maps[SEC_CAM_NONE] =3D CAM_NONE,
+	.maps[SEC_CAM_WEP40] =3D CAM_WEP40,
+	.maps[SEC_CAM_TKIP] =3D CAM_TKIP,
+	.maps[SEC_CAM_AES] =3D CAM_AES,
+	.maps[SEC_CAM_WEP104] =3D CAM_WEP104,
+
+	.maps[RTL_IMR_BCNDMAINT6] =3D IMR_BCNDMAINT6,
+	.maps[RTL_IMR_BCNDMAINT5] =3D IMR_BCNDMAINT5,
+	.maps[RTL_IMR_BCNDMAINT4] =3D IMR_BCNDMAINT4,
+	.maps[RTL_IMR_BCNDMAINT3] =3D IMR_BCNDMAINT3,
+	.maps[RTL_IMR_BCNDMAINT2] =3D IMR_BCNDMAINT2,
+	.maps[RTL_IMR_BCNDMAINT1] =3D IMR_BCNDMAINT1,
+/*	.maps[RTL_IMR_BCNDOK8] =3D IMR_BCNDOK8,     */   /*need check*/
+	.maps[RTL_IMR_BCNDOK7] =3D IMR_BCNDOK7,
+	.maps[RTL_IMR_BCNDOK6] =3D IMR_BCNDOK6,
+	.maps[RTL_IMR_BCNDOK5] =3D IMR_BCNDOK5,
+	.maps[RTL_IMR_BCNDOK4] =3D IMR_BCNDOK4,
+	.maps[RTL_IMR_BCNDOK3] =3D IMR_BCNDOK3,
+	.maps[RTL_IMR_BCNDOK2] =3D IMR_BCNDOK2,
+	.maps[RTL_IMR_BCNDOK1] =3D IMR_BCNDOK1,
+/*	.maps[RTL_IMR_TIMEOUT2] =3D IMR_TIMEOUT2,*/
+/*	.maps[RTL_IMR_TIMEOUT1] =3D IMR_TIMEOUT1,*/
+
+	.maps[RTL_IMR_TXFOVW] =3D IMR_TXFOVW,
+	.maps[RTL_IMR_PSTIMEOUT] =3D IMR_PSTIMEOUT,
+	.maps[RTL_IMR_BCNINT] =3D IMR_BCNDMAINT0,
+	.maps[RTL_IMR_RXFOVW] =3D IMR_RXFOVW,
+	.maps[RTL_IMR_RDU] =3D IMR_RDU,
+	.maps[RTL_IMR_ATIMEND] =3D IMR_ATIMEND,
+	.maps[RTL_IMR_BDOK] =3D IMR_BCNDOK0,
+	.maps[RTL_IMR_MGNTDOK] =3D IMR_MGNTDOK,
+	.maps[RTL_IMR_TBDER] =3D IMR_TBDER,
+	.maps[RTL_IMR_HIGHDOK] =3D IMR_HIGHDOK,
+	.maps[RTL_IMR_TBDOK] =3D IMR_TBDOK,
+	.maps[RTL_IMR_BKDOK] =3D IMR_BKDOK,
+	.maps[RTL_IMR_BEDOK] =3D IMR_BEDOK,
+	.maps[RTL_IMR_VIDOK] =3D IMR_VIDOK,
+	.maps[RTL_IMR_VODOK] =3D IMR_VODOK,
+	.maps[RTL_IMR_ROK] =3D IMR_ROK,
+	.maps[RTL_IBSS_INT_MASKS] =3D (IMR_BCNDMAINT0 | IMR_TBDOK | IMR_TBDER=
),
+
+	.maps[RTL_RC_CCK_RATE1M] =3D DESC_RATE1M,
+	.maps[RTL_RC_CCK_RATE2M] =3D  DESC_RATE2M,
+	.maps[RTL_RC_CCK_RATE5_5M] =3D  DESC_RATE5_5M,
+	.maps[RTL_RC_CCK_RATE11M] =3D  DESC_RATE11M,
+	.maps[RTL_RC_OFDM_RATE6M] =3D  DESC_RATE6M,
+	.maps[RTL_RC_OFDM_RATE9M] =3D  DESC_RATE9M,
+	.maps[RTL_RC_OFDM_RATE12M] =3D  DESC_RATE12M,
+	.maps[RTL_RC_OFDM_RATE18M] =3D  DESC_RATE18M,
+	.maps[RTL_RC_OFDM_RATE24M] =3D  DESC_RATE24M,
+	.maps[RTL_RC_OFDM_RATE36M] =3D  DESC_RATE36M,
+	.maps[RTL_RC_OFDM_RATE48M] =3D  DESC_RATE48M,
+	.maps[RTL_RC_OFDM_RATE54M] =3D  DESC_RATE54M,
+
+	.maps[RTL_RC_HT_RATEMCS7] =3D  DESC_RATEMCS7,
+	.maps[RTL_RC_HT_RATEMCS15] =3D  DESC_RATEMCS15,
+
+	/*VHT hightest rate*/
+	.maps[RTL_RC_VHT_RATE_1SS_MCS7] =3D DESC_RATEVHT1SS_MCS7,
+	.maps[RTL_RC_VHT_RATE_1SS_MCS8] =3D DESC_RATEVHT1SS_MCS8,
+	.maps[RTL_RC_VHT_RATE_1SS_MCS9] =3D DESC_RATEVHT1SS_MCS9,
+	.maps[RTL_RC_VHT_RATE_2SS_MCS7] =3D DESC_RATEVHT2SS_MCS7,
+	.maps[RTL_RC_VHT_RATE_2SS_MCS8] =3D DESC_RATEVHT2SS_MCS8,
+	.maps[RTL_RC_VHT_RATE_2SS_MCS9] =3D DESC_RATEVHT2SS_MCS9,
+};
+
+static struct pci_device_id rtl8821ae_pci_ids[] =3D {
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8812, rtl8821ae_hal_cfg)},
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8821, rtl8821ae_hal_cfg)},
+	{},
+};
+
+MODULE_DEVICE_TABLE(pci, rtl8821ae_pci_ids);
+
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Realtek 8821ae 802.11ac PCI wireless");
+MODULE_FIRMWARE("rtlwifi/rtl8821aefw.bin");
+
+module_param_named(swenc, rtl8821ae_mod_params.sw_crypto, bool, 0444);
+module_param_named(debug, rtl8821ae_mod_params.debug, int, 0444);
+module_param_named(ips, rtl8821ae_mod_params.inactiveps, bool, 0444);
+module_param_named(swlps, rtl8821ae_mod_params.swctrl_lps, bool, 0444)=
;
+module_param_named(fwlps, rtl8821ae_mod_params.fwctrl_lps, bool, 0444)=
;
+module_param_named(msi, rtl8821ae_mod_params.msi_support, bool, 0444);
+module_param_named(disable_watchdog, rtl8821ae_mod_params.disable_watc=
hdog,
+		   bool, 0444);
+MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
+MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)=
\n");
+MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (defaul=
t 0)\n");
+MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (defaul=
t 1)\n");
+MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 1)=
\n");
+MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (=
default 0)\n");
+
+static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resu=
me);
+
+static struct pci_driver rtl8821ae_driver =3D {
+	.name =3D KBUILD_MODNAME,
+	.id_table =3D rtl8821ae_pci_ids,
+	.probe =3D rtl_pci_probe,
+	.remove =3D rtl_pci_disconnect,
+	.driver.pm =3D &rtlwifi_pm_ops,
+};
+
+module_pci_driver(rtl8821ae_driver);
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/sw.h b/drivers/net/=
wireless/rtlwifi/rtl8821ae/sw.h
new file mode 100644
index 0000000..d001e7c
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/sw.h
@@ -0,0 +1,34 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_SW_H__
+#define __RTL8821AE_SW_H__
+
+int rtl8821ae_init_sw_vars(struct ieee80211_hw *hw);
+void rtl8821ae_deinit_sw_vars(struct ieee80211_hw *hw);
+void rtl8821ae_init_var_map(struct ieee80211_hw *hw);
+bool rtl8821ae_get_btc_status(void);
+
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/table.c b/drivers/n=
et/wireless/rtlwifi/rtl8821ae/table.c
new file mode 100644
index 0000000..62a0fb7
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/table.c
@@ -0,0 +1,4572 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "table.h"
+u32 RTL8812AE_PHY_REG_ARRAY[] =3D {
+		0x800, 0x8020D010,
+		0x804, 0x080112E0,
+		0x808, 0x0E028233,
+		0x80C, 0x12131113,
+		0x810, 0x20101263,
+		0x814, 0x020C3D10,
+		0x818, 0x03A00385,
+		0x820, 0x00000000,
+		0x824, 0x00030FE0,
+		0x828, 0x00000000,
+		0x82C, 0x002083DD,
+		0x830, 0x2AAA6C86,
+		0x834, 0x0037A706,
+		0x838, 0x06C89B44,
+		0x83C, 0x0000095B,
+		0x840, 0xC0000001,
+		0x844, 0x40003CDE,
+		0x848, 0x6210FF8B,
+		0x84C, 0x6CFDFFB8,
+		0x850, 0x28874706,
+		0x854, 0x0001520C,
+		0x858, 0x8060E000,
+		0x85C, 0x74210168,
+		0x860, 0x6929C321,
+		0x864, 0x79727432,
+		0x868, 0x8CA7A314,
+		0x86C, 0x338C2878,
+		0x870, 0x03333333,
+		0x874, 0x31602C2E,
+		0x878, 0x00003152,
+		0x87C, 0x000FC000,
+		0x8A0, 0x00000013,
+		0x8A4, 0x7F7F7F7F,
+		0x8A8, 0xA202033E,
+		0x8AC, 0x0FF0FA0A,
+		0x8B0, 0x00000600,
+		0x8B4, 0x000FC080,
+		0x8B8, 0x6C0057FF,
+		0x8BC, 0x4CA520A3,
+		0x8C0, 0x27F00020,
+		0x8C4, 0x00000000,
+		0x8C8, 0x00013169,
+		0x8CC, 0x08248492,
+		0x8D0, 0x0000B800,
+		0x8DC, 0x00000000,
+		0x8D4, 0x940008A0,
+		0x8D8, 0x290B5612,
+		0x8F8, 0x400002C0,
+		0x8FC, 0x00000000,
+	0xFF0F07D8, 0xABCD,
+		0x900, 0x00000701,
+	0xFF0F07D0, 0xCDEF,
+		0x900, 0x00000701,
+	0xCDCDCDCD, 0xCDCD,
+		0x900, 0x00000700,
+	0xFF0F07D8, 0xDEAD,
+		0x90C, 0x00000000,
+		0x910, 0x0000FC00,
+		0x914, 0x00000404,
+		0x918, 0x1C1028C0,
+		0x91C, 0x64B11A1C,
+		0x920, 0xE0767233,
+		0x924, 0x055AA500,
+		0x928, 0x00000004,
+		0x92C, 0xFFFE0000,
+		0x930, 0xFFFFFFFE,
+		0x934, 0x001FFFFF,
+		0x960, 0x00000000,
+		0x964, 0x00000000,
+		0x968, 0x00000000,
+		0x96C, 0x00000000,
+		0x970, 0x801FFFFF,
+		0x978, 0x00000000,
+		0x97C, 0x00000000,
+		0x980, 0x00000000,
+		0x984, 0x00000000,
+		0x988, 0x00000000,
+		0x990, 0x27100000,
+		0x994, 0xFFFF0100,
+		0x998, 0xFFFFFF5C,
+		0x99C, 0xFFFFFFFF,
+		0x9A0, 0x000000FF,
+		0x9A4, 0x00080080,
+		0x9A8, 0x00000000,
+		0x9AC, 0x00000000,
+		0x9B0, 0x81081008,
+		0x9B4, 0x00000000,
+		0x9B8, 0x01081008,
+		0x9BC, 0x01081008,
+		0x9D0, 0x00000000,
+		0x9D4, 0x00000000,
+		0x9D8, 0x00000000,
+		0x9DC, 0x00000000,
+		0x9E4, 0x00000002,
+		0x9E8, 0x000002D5,
+		0xA00, 0x00D047C8,
+		0xA04, 0x01FF000C,
+		0xA08, 0x8C838300,
+		0xA0C, 0x2E7F000F,
+		0xA10, 0x9500BB78,
+		0xA14, 0x11144028,
+		0xA18, 0x00881117,
+		0xA1C, 0x89140F00,
+		0xA20, 0x1A1B0000,
+		0xA24, 0x090E1317,
+		0xA28, 0x00000204,
+		0xA2C, 0x00900000,
+		0xA70, 0x101FFF00,
+		0xA74, 0x00000008,
+		0xA78, 0x00000900,
+		0xA7C, 0x225B0606,
+		0xA80, 0x218075B2,
+		0xA84, 0x001F8C80,
+		0xB00, 0x03100000,
+		0xB04, 0x0000B000,
+		0xB08, 0xAE0201EB,
+		0xB0C, 0x01003207,
+		0xB10, 0x00009807,
+		0xB14, 0x01000000,
+		0xB18, 0x00000002,
+		0xB1C, 0x00000002,
+		0xB20, 0x0000001F,
+		0xB24, 0x03020100,
+		0xB28, 0x07060504,
+		0xB2C, 0x0B0A0908,
+		0xB30, 0x0F0E0D0C,
+		0xB34, 0x13121110,
+		0xB38, 0x17161514,
+		0xB3C, 0x0000003A,
+		0xB40, 0x00000000,
+		0xB44, 0x00000000,
+		0xB48, 0x13000032,
+		0xB4C, 0x48080000,
+		0xB50, 0x00000000,
+		0xB54, 0x00000000,
+		0xB58, 0x00000000,
+		0xB5C, 0x00000000,
+		0xC00, 0x00000007,
+		0xC04, 0x00042020,
+		0xC08, 0x80410231,
+		0xC0C, 0x00000000,
+		0xC10, 0x00000100,
+		0xC14, 0x01000000,
+		0xC1C, 0x40000003,
+		0xC20, 0x12121212,
+		0xC24, 0x12121212,
+		0xC28, 0x12121212,
+		0xC2C, 0x12121212,
+		0xC30, 0x12121212,
+		0xC34, 0x12121212,
+		0xC38, 0x12121212,
+		0xC3C, 0x12121212,
+		0xC40, 0x12121212,
+		0xC44, 0x12121212,
+		0xC48, 0x12121212,
+		0xC4C, 0x12121212,
+		0xC50, 0x00000020,
+		0xC54, 0x0008121C,
+		0xC58, 0x30000C1C,
+		0xC5C, 0x00000058,
+		0xC60, 0x34344443,
+		0xC64, 0x07003333,
+		0xC68, 0x59791979,
+		0xC6C, 0x59795979,
+		0xC70, 0x19795979,
+		0xC74, 0x19795979,
+		0xC78, 0x19791979,
+		0xC7C, 0x19791979,
+		0xC80, 0x19791979,
+		0xC84, 0x19791979,
+		0xC94, 0x0100005C,
+		0xC98, 0x00000000,
+		0xC9C, 0x00000000,
+		0xCA0, 0x00000029,
+		0xCA4, 0x08040201,
+		0xCA8, 0x80402010,
+	0xFF0F0740, 0xABCD,
+		0xCB0, 0x77547717,
+	0xFF0F01C0, 0xCDEF,
+		0xCB0, 0x77547717,
+	0xFF0F02C0, 0xCDEF,
+		0xCB0, 0x77547717,
+	0xFF0F07D8, 0xCDEF,
+		0xCB0, 0x54547710,
+	0xFF0F07D0, 0xCDEF,
+		0xCB0, 0x54547710,
+	0xCDCDCDCD, 0xCDCD,
+		0xCB0, 0x77547777,
+	0xFF0F0740, 0xDEAD,
+		0xCB4, 0x00000077,
+		0xCB8, 0x00508242,
+		0xE00, 0x00000007,
+		0xE04, 0x00042020,
+		0xE08, 0x80410231,
+		0xE0C, 0x00000000,
+		0xE10, 0x00000100,
+		0xE14, 0x01000000,
+		0xE1C, 0x40000003,
+		0xE20, 0x12121212,
+		0xE24, 0x12121212,
+		0xE28, 0x12121212,
+		0xE2C, 0x12121212,
+		0xE30, 0x12121212,
+		0xE34, 0x12121212,
+		0xE38, 0x12121212,
+		0xE3C, 0x12121212,
+		0xE40, 0x12121212,
+		0xE44, 0x12121212,
+		0xE48, 0x12121212,
+		0xE4C, 0x12121212,
+		0xE50, 0x00000020,
+		0xE54, 0x0008121C,
+		0xE58, 0x30000C1C,
+		0xE5C, 0x00000058,
+		0xE60, 0x34344443,
+		0xE64, 0x07003333,
+		0xE68, 0x59791979,
+		0xE6C, 0x59795979,
+		0xE70, 0x19795979,
+		0xE74, 0x19795979,
+		0xE78, 0x19791979,
+		0xE7C, 0x19791979,
+		0xE80, 0x19791979,
+		0xE84, 0x19791979,
+		0xE94, 0x0100005C,
+		0xE98, 0x00000000,
+		0xE9C, 0x00000000,
+		0xEA0, 0x00000029,
+		0xEA4, 0x08040201,
+		0xEA8, 0x80402010,
+	0xFF0F0740, 0xABCD,
+		0xEB0, 0x77547717,
+	0xFF0F01C0, 0xCDEF,
+		0xEB0, 0x77547717,
+	0xFF0F02C0, 0xCDEF,
+		0xEB0, 0x77547717,
+	0xFF0F07D8, 0xCDEF,
+		0xEB0, 0x54547710,
+	0xFF0F07D0, 0xCDEF,
+		0xEB0, 0x54547710,
+	0xCDCDCDCD, 0xCDCD,
+		0xEB0, 0x77547777,
+	0xFF0F0740, 0xDEAD,
+		0xEB4, 0x00000077,
+		0xEB8, 0x00508242,
+};
+
+u32 RTL8821AE_PHY_REG_ARRAY[] =3D {
+	0x800, 0x0020D090,
+	0x804, 0x080112E0,
+	0x808, 0x0E028211,
+	0x80C, 0x92131111,
+	0x810, 0x20101261,
+	0x814, 0x020C3D10,
+	0x818, 0x03A00385,
+	0x820, 0x00000000,
+	0x824, 0x00030FE0,
+	0x828, 0x00000000,
+	0x82C, 0x002081DD,
+	0x830, 0x2AAA8E24,
+	0x834, 0x0037A706,
+	0x838, 0x06489B44,
+	0x83C, 0x0000095B,
+	0x840, 0xC0000001,
+	0x844, 0x40003CDE,
+	0x848, 0x62103F8B,
+	0x84C, 0x6CFDFFB8,
+	0x850, 0x28874706,
+	0x854, 0x0001520C,
+	0x858, 0x8060E000,
+	0x85C, 0x74210168,
+	0x860, 0x6929C321,
+	0x864, 0x79727432,
+	0x868, 0x8CA7A314,
+	0x86C, 0x888C2878,
+	0x870, 0x08888888,
+	0x874, 0x31612C2E,
+	0x878, 0x00000152,
+	0x87C, 0x000FD000,
+	0x8A0, 0x00000013,
+	0x8A4, 0x7F7F7F7F,
+	0x8A8, 0xA2000338,
+	0x8AC, 0x0FF0FA0A,
+	0x8B4, 0x000FC080,
+	0x8B8, 0x6C10D7FF,
+	0x8BC, 0x0CA52090,
+	0x8C0, 0x1BF00020,
+	0x8C4, 0x00000000,
+	0x8C8, 0x00013169,
+	0x8CC, 0x08248492,
+	0x8D4, 0x940008A0,
+	0x8D8, 0x290B5612,
+	0x8F8, 0x400002C0,
+	0x8FC, 0x00000000,
+	0x900, 0x00000700,
+	0x90C, 0x00000000,
+	0x910, 0x0000FC00,
+	0x914, 0x00000404,
+	0x918, 0x1C1028C0,
+	0x91C, 0x64B11A1C,
+	0x920, 0xE0767233,
+	0x924, 0x055AA500,
+	0x928, 0x00000004,
+	0x92C, 0xFFFE0000,
+	0x930, 0xFFFFFFFE,
+	0x934, 0x001FFFFF,
+	0x960, 0x00000000,
+	0x964, 0x00000000,
+	0x968, 0x00000000,
+	0x96C, 0x00000000,
+	0x970, 0x801FFFFF,
+	0x974, 0x000003FF,
+	0x978, 0x00000000,
+	0x97C, 0x00000000,
+	0x980, 0x00000000,
+	0x984, 0x00000000,
+	0x988, 0x00000000,
+	0x990, 0x27100000,
+	0x994, 0xFFFF0100,
+	0x998, 0xFFFFFF5C,
+	0x99C, 0xFFFFFFFF,
+	0x9A0, 0x000000FF,
+	0x9A4, 0x00480080,
+	0x9A8, 0x00000000,
+	0x9AC, 0x00000000,
+	0x9B0, 0x81081008,
+	0x9B4, 0x01081008,
+	0x9B8, 0x01081008,
+	0x9BC, 0x01081008,
+	0x9D0, 0x00000000,
+	0x9D4, 0x00000000,
+	0x9D8, 0x00000000,
+	0x9DC, 0x00000000,
+	0x9E0, 0x00005D00,
+	0x9E4, 0x00000002,
+	0x9E8, 0x00000001,
+	0xA00, 0x00D047C8,
+	0xA04, 0x01FF000C,
+	0xA08, 0x8C8A8300,
+	0xA0C, 0x2E68000F,
+	0xA10, 0x9500BB78,
+	0xA14, 0x11144028,
+	0xA18, 0x00881117,
+	0xA1C, 0x89140F00,
+	0xA20, 0x1A1B0000,
+	0xA24, 0x090E1317,
+	0xA28, 0x00000204,
+	0xA2C, 0x00900000,
+	0xA70, 0x101FFF00,
+	0xA74, 0x00000008,
+	0xA78, 0x00000900,
+	0xA7C, 0x225B0606,
+	0xA80, 0x21805490,
+	0xA84, 0x001F0000,
+	0xB00, 0x03100040,
+	0xB04, 0x0000B000,
+	0xB08, 0xAE0201EB,
+	0xB0C, 0x01003207,
+	0xB10, 0x00009807,
+	0xB14, 0x01000000,
+	0xB18, 0x00000002,
+	0xB1C, 0x00000002,
+	0xB20, 0x0000001F,
+	0xB24, 0x03020100,
+	0xB28, 0x07060504,
+	0xB2C, 0x0B0A0908,
+	0xB30, 0x0F0E0D0C,
+	0xB34, 0x13121110,
+	0xB38, 0x17161514,
+	0xB3C, 0x0000003A,
+	0xB40, 0x00000000,
+	0xB44, 0x00000000,
+	0xB48, 0x13000032,
+	0xB4C, 0x48080000,
+	0xB50, 0x00000000,
+	0xB54, 0x00000000,
+	0xB58, 0x00000000,
+	0xB5C, 0x00000000,
+	0xC00, 0x00000007,
+	0xC04, 0x00042020,
+	0xC08, 0x80410231,
+	0xC0C, 0x00000000,
+	0xC10, 0x00000100,
+	0xC14, 0x01000000,
+	0xC1C, 0x40000003,
+	0xC20, 0x2C2C2C2C,
+	0xC24, 0x30303030,
+	0xC28, 0x30303030,
+	0xC2C, 0x2C2C2C2C,
+	0xC30, 0x2C2C2C2C,
+	0xC34, 0x2C2C2C2C,
+	0xC38, 0x2C2C2C2C,
+	0xC3C, 0x2A2A2A2A,
+	0xC40, 0x2A2A2A2A,
+	0xC44, 0x2A2A2A2A,
+	0xC48, 0x2A2A2A2A,
+	0xC4C, 0x2A2A2A2A,
+	0xC50, 0x00000020,
+	0xC54, 0x001C1208,
+	0xC58, 0x30000C1C,
+	0xC5C, 0x00000058,
+	0xC60, 0x34344443,
+	0xC64, 0x07003333,
+	0xC68, 0x19791979,
+	0xC6C, 0x19791979,
+	0xC70, 0x19791979,
+	0xC74, 0x19791979,
+	0xC78, 0x19791979,
+	0xC7C, 0x19791979,
+	0xC80, 0x19791979,
+	0xC84, 0x19791979,
+	0xC94, 0x0100005C,
+	0xC98, 0x00000000,
+	0xC9C, 0x00000000,
+	0xCA0, 0x00000029,
+	0xCA4, 0x08040201,
+	0xCA8, 0x80402010,
+	0xCB0, 0x77775747,
+	0xCB4, 0x10000077,
+	0xCB8, 0x00508240,
+};
+
+u32 RTL8812AE_PHY_REG_ARRAY_PG[] =3D {
+	0, 0, 0, 0x00000c20, 0xffffffff, 0x34363840,
+	0, 0, 0, 0x00000c24, 0xffffffff, 0x42424444,
+	0, 0, 0, 0x00000c28, 0xffffffff, 0x30323638,
+	0, 0, 0, 0x00000c2c, 0xffffffff, 0x40424444,
+	0, 0, 0, 0x00000c30, 0xffffffff, 0x28303236,
+	0, 0, 1, 0x00000c34, 0xffffffff, 0x38404242,
+	0, 0, 1, 0x00000c38, 0xffffffff, 0x26283034,
+	0, 0, 0, 0x00000c3c, 0xffffffff, 0x40424444,
+	0, 0, 0, 0x00000c40, 0xffffffff, 0x28303236,
+	0, 0, 0, 0x00000c44, 0xffffffff, 0x42422426,
+	0, 0, 1, 0x00000c48, 0xffffffff, 0x30343840,
+	0, 0, 1, 0x00000c4c, 0xffffffff, 0x22242628,
+	0, 1, 0, 0x00000e20, 0xffffffff, 0x34363840,
+	0, 1, 0, 0x00000e24, 0xffffffff, 0x42424444,
+	0, 1, 0, 0x00000e28, 0xffffffff, 0x30323638,
+	0, 1, 0, 0x00000e2c, 0xffffffff, 0x40424444,
+	0, 1, 0, 0x00000e30, 0xffffffff, 0x28303236,
+	0, 1, 1, 0x00000e34, 0xffffffff, 0x38404242,
+	0, 1, 1, 0x00000e38, 0xffffffff, 0x26283034,
+	0, 1, 0, 0x00000e3c, 0xffffffff, 0x40424444,
+	0, 1, 0, 0x00000e40, 0xffffffff, 0x28303236,
+	0, 1, 0, 0x00000e44, 0xffffffff, 0x42422426,
+	0, 1, 1, 0x00000e48, 0xffffffff, 0x30343840,
+	0, 1, 1, 0x00000e4c, 0xffffffff, 0x22242628,
+	1, 0, 0, 0x00000c24, 0xffffffff, 0x42424444,
+	1, 0, 0, 0x00000c28, 0xffffffff, 0x30323640,
+	1, 0, 0, 0x00000c2c, 0xffffffff, 0x40424444,
+	1, 0, 0, 0x00000c30, 0xffffffff, 0x28303236,
+	1, 0, 1, 0x00000c34, 0xffffffff, 0x38404242,
+	1, 0, 1, 0x00000c38, 0xffffffff, 0x26283034,
+	1, 0, 0, 0x00000c3c, 0xffffffff, 0x40424444,
+	1, 0, 0, 0x00000c40, 0xffffffff, 0x28303236,
+	1, 0, 0, 0x00000c44, 0xffffffff, 0x42422426,
+	1, 0, 1, 0x00000c48, 0xffffffff, 0x30343840,
+	1, 0, 1, 0x00000c4c, 0xffffffff, 0x22242628,
+	1, 1, 0, 0x00000e24, 0xffffffff, 0x42424444,
+	1, 1, 0, 0x00000e28, 0xffffffff, 0x30323640,
+	1, 1, 0, 0x00000e2c, 0xffffffff, 0x40424444,
+	1, 1, 0, 0x00000e30, 0xffffffff, 0x28303236,
+	1, 1, 1, 0x00000e34, 0xffffffff, 0x38404242,
+	1, 1, 1, 0x00000e38, 0xffffffff, 0x26283034,
+	1, 1, 0, 0x00000e3c, 0xffffffff, 0x40424444,
+	1, 1, 0, 0x00000e40, 0xffffffff, 0x28303236,
+	1, 1, 0, 0x00000e44, 0xffffffff, 0x42422426,
+	1, 1, 1, 0x00000e48, 0xffffffff, 0x30343840,
+	1, 1, 1, 0x00000e4c, 0xffffffff, 0x22242628
+};
+
+u32 RTL8821AE_PHY_REG_ARRAY_PG[] =3D {
+	0, 0, 0, 0x00000c20, 0xffffffff, 0x32343638,
+	0, 0, 0, 0x00000c24, 0xffffffff, 0x36363838,
+	0, 0, 0, 0x00000c28, 0xffffffff, 0x28303234,
+	0, 0, 0, 0x00000c2c, 0xffffffff, 0x34363838,
+	0, 0, 0, 0x00000c30, 0xffffffff, 0x26283032,
+	0, 0, 0, 0x00000c3c, 0xffffffff, 0x32343636,
+	0, 0, 0, 0x00000c40, 0xffffffff, 0x24262830,
+	0, 0, 0, 0x00000c44, 0x0000ffff, 0x00002022,
+	1, 0, 0, 0x00000c24, 0xffffffff, 0x34343636,
+	1, 0, 0, 0x00000c28, 0xffffffff, 0x26283032,
+	1, 0, 0, 0x00000c2c, 0xffffffff, 0x32343636,
+	1, 0, 0, 0x00000c30, 0xffffffff, 0x24262830,
+	1, 0, 0, 0x00000c3c, 0xffffffff, 0x32343636,
+	1, 0, 0, 0x00000c40, 0xffffffff, 0x24262830,
+	1, 0, 0, 0x00000c44, 0x0000ffff, 0x00002022
+};
+
+u32 RTL8812AE_RADIOA_ARRAY[] =3D {
+		0x000, 0x00010000,
+		0x018, 0x0001712A,
+		0x056, 0x00051CF2,
+		0x066, 0x00040000,
+		0x01E, 0x00080000,
+		0x089, 0x00000080,
+	0xFF0F0740, 0xABCD,
+		0x086, 0x00014B38,
+	0xFF0F02C0, 0xCDEF,
+		0x086, 0x00014B38,
+	0xFF0F01C0, 0xCDEF,
+		0x086, 0x00014B38,
+	0xFF0F07D8, 0xCDEF,
+		0x086, 0x00014B3A,
+	0xFF0F07D0, 0xCDEF,
+		0x086, 0x00014B3A,
+	0xCDCDCDCD, 0xCDCD,
+		0x086, 0x00014B38,
+	0xFF0F0740, 0xDEAD,
+		0x0B1, 0x0001FC1A,
+		0x0B3, 0x000F0810,
+		0x0B4, 0x0001A78D,
+		0x0BA, 0x00086180,
+		0x018, 0x00000006,
+		0x0EF, 0x00002000,
+	0xFF0F07D8, 0xABCD,
+		0x03B, 0x0003F218,
+		0x03B, 0x00030A58,
+		0x03B, 0x0002FA58,
+		0x03B, 0x00022590,
+		0x03B, 0x0001FA50,
+		0x03B, 0x00010248,
+		0x03B, 0x00008240,
+	0xFF0F07D0, 0xCDEF,
+		0x03B, 0x0003F218,
+		0x03B, 0x00030A58,
+		0x03B, 0x0002FA58,
+		0x03B, 0x00022590,
+		0x03B, 0x0001FA50,
+		0x03B, 0x00010248,
+		0x03B, 0x00008240,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x00038A58,
+		0x03B, 0x00037A58,
+		0x03B, 0x0002A590,
+		0x03B, 0x00027A50,
+		0x03B, 0x00018248,
+		0x03B, 0x00010240,
+		0x03B, 0x00008240,
+	0xFF0F07D8, 0xDEAD,
+		0x0EF, 0x00000100,
+	0xFF0F07D8, 0xABCD,
+		0x034, 0x0000A4EE,
+		0x034, 0x00009076,
+		0x034, 0x00008073,
+		0x034, 0x00007070,
+		0x034, 0x0000606D,
+		0x034, 0x0000506A,
+		0x034, 0x00004049,
+		0x034, 0x00003046,
+		0x034, 0x00002028,
+		0x034, 0x00001025,
+		0x034, 0x00000022,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000ADF4,
+		0x034, 0x00009DF1,
+		0x034, 0x00008DEE,
+		0x034, 0x00007DEB,
+		0x034, 0x00006DE8,
+		0x034, 0x00005CEC,
+		0x034, 0x00004CE9,
+		0x034, 0x000034EA,
+		0x034, 0x000024E7,
+		0x034, 0x0000146B,
+		0x034, 0x0000006D,
+	0xFF0F07D8, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0EF, 0x000020A2,
+		0x0DF, 0x00000080,
+		0x035, 0x00000192,
+		0x035, 0x00008192,
+		0x035, 0x00010192,
+		0x036, 0x00000024,
+		0x036, 0x00008024,
+		0x036, 0x00010024,
+		0x036, 0x00018024,
+		0x0EF, 0x00000000,
+		0x051, 0x00000C21,
+		0x052, 0x000006D9,
+		0x053, 0x000FC649,
+		0x054, 0x0000017E,
+		0x0EF, 0x00000002,
+		0x008, 0x00008400,
+		0x018, 0x0001712A,
+		0x0EF, 0x00001000,
+		0x03A, 0x00000080,
+		0x03B, 0x0003A02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x0003202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x0002B064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x00023070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0001B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00012085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0000A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00002080,
+		0x03C, 0x00010000,
+		0x03A, 0x00000080,
+		0x03B, 0x0007A02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x0007202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x0006B064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x00023070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0005B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00052085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0004A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00042080,
+		0x03C, 0x00010000,
+		0x03A, 0x00000080,
+		0x03B, 0x000BA02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x000B202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x000AB064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x000A3070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0009B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00092085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0008A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00082080,
+		0x03C, 0x00010000,
+		0x0EF, 0x00001100,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0004ADF5,
+		0x034, 0x00049DF2,
+		0x034, 0x00048DEF,
+		0x034, 0x00047DEC,
+		0x034, 0x00046DE9,
+		0x034, 0x00045DC9,
+		0x034, 0x00044CE8,
+		0x034, 0x000438CA,
+		0x034, 0x00042889,
+		0x034, 0x0004184A,
+		0x034, 0x0004044A,
+	0xFF0F0740, 0xDEAD,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0002ADF5,
+		0x034, 0x00029DF2,
+		0x034, 0x00028DEF,
+		0x034, 0x00027DEC,
+		0x034, 0x00026DE9,
+		0x034, 0x00025DC9,
+		0x034, 0x00024CE8,
+		0x034, 0x000238CA,
+		0x034, 0x00022889,
+		0x034, 0x0002184A,
+		0x034, 0x0002044A,
+	0xFF0F0740, 0xDEAD,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000AFF7,
+		0x034, 0x00009DF7,
+		0x034, 0x00008DF4,
+		0x034, 0x00007DF1,
+		0x034, 0x00006DEE,
+		0x034, 0x00005DCD,
+		0x034, 0x00004CEB,
+		0x034, 0x000038CC,
+		0x034, 0x0000288B,
+		0x034, 0x0000184C,
+		0x034, 0x0000044C,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+	0xFF0F0740, 0xABCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001D4,
+		0x035, 0x000081D4,
+		0x035, 0x000101D4,
+		0x035, 0x000201B4,
+		0x035, 0x000281B4,
+		0x035, 0x000301B4,
+		0x035, 0x000401B4,
+		0x035, 0x000481B4,
+		0x035, 0x000501B4,
+	0xFF0F02C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001D4,
+		0x035, 0x000081D4,
+		0x035, 0x000101D4,
+		0x035, 0x000201B4,
+		0x035, 0x000281B4,
+		0x035, 0x000301B4,
+		0x035, 0x000401B4,
+		0x035, 0x000481B4,
+		0x035, 0x000501B4,
+	0xFF0F01C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001D4,
+		0x035, 0x000081D4,
+		0x035, 0x000101D4,
+		0x035, 0x000201B4,
+		0x035, 0x000281B4,
+		0x035, 0x000301B4,
+		0x035, 0x000401B4,
+		0x035, 0x000481B4,
+		0x035, 0x000501B4,
+	0xFF0F07D8, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001D4,
+		0x035, 0x000081D4,
+		0x035, 0x000101D4,
+		0x035, 0x000201B4,
+		0x035, 0x000281B4,
+		0x035, 0x000301B4,
+		0x035, 0x000401B4,
+		0x035, 0x000481B4,
+		0x035, 0x000501B4,
+	0xFF0F07D0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001D4,
+		0x035, 0x000081D4,
+		0x035, 0x000101D4,
+		0x035, 0x000201B4,
+		0x035, 0x000281B4,
+		0x035, 0x000301B4,
+		0x035, 0x000401B4,
+		0x035, 0x000481B4,
+		0x035, 0x000501B4,
+	0xCDCDCDCD, 0xCDCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x00000188,
+		0x035, 0x00008147,
+		0x035, 0x00010147,
+		0x035, 0x000201D7,
+		0x035, 0x000281D7,
+		0x035, 0x000301D7,
+		0x035, 0x000401D8,
+		0x035, 0x000481D8,
+		0x035, 0x000501D8,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+	0xFF0F0740, 0xABCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00004BFB,
+		0x036, 0x0000CBFB,
+		0x036, 0x00014BFB,
+		0x036, 0x0001CBFB,
+		0x036, 0x00024F4B,
+		0x036, 0x0002CF4B,
+		0x036, 0x00034F4B,
+		0x036, 0x0003CF4B,
+		0x036, 0x00044F4B,
+		0x036, 0x0004CF4B,
+		0x036, 0x00054F4B,
+		0x036, 0x0005CF4B,
+	0xFF0F02C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00004BFB,
+		0x036, 0x0000CBFB,
+		0x036, 0x00014BFB,
+		0x036, 0x0001CBFB,
+		0x036, 0x00024F4B,
+		0x036, 0x0002CF4B,
+		0x036, 0x00034F4B,
+		0x036, 0x0003CF4B,
+		0x036, 0x00044F4B,
+		0x036, 0x0004CF4B,
+		0x036, 0x00054F4B,
+		0x036, 0x0005CF4B,
+	0xFF0F01C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00004BFB,
+		0x036, 0x0000CBFB,
+		0x036, 0x00014BFB,
+		0x036, 0x0001CBFB,
+		0x036, 0x00024F4B,
+		0x036, 0x0002CF4B,
+		0x036, 0x00034F4B,
+		0x036, 0x0003CF4B,
+		0x036, 0x00044F4B,
+		0x036, 0x0004CF4B,
+		0x036, 0x00054F4B,
+		0x036, 0x0005CF4B,
+	0xFF0F07D8, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00004BFB,
+		0x036, 0x0000CBFB,
+		0x036, 0x00014BFB,
+		0x036, 0x0001CBFB,
+		0x036, 0x00024F4B,
+		0x036, 0x0002CF4B,
+		0x036, 0x00034F4B,
+		0x036, 0x0003CF4B,
+		0x036, 0x00044F4B,
+		0x036, 0x0004CF4B,
+		0x036, 0x00054F4B,
+		0x036, 0x0005CF4B,
+	0xFF0F07D0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00004BFB,
+		0x036, 0x0000CBFB,
+		0x036, 0x00014BFB,
+		0x036, 0x0001CBFB,
+		0x036, 0x00024F4B,
+		0x036, 0x0002CF4B,
+		0x036, 0x00034F4B,
+		0x036, 0x0003CF4B,
+		0x036, 0x00044F4B,
+		0x036, 0x0004CF4B,
+		0x036, 0x00054F4B,
+		0x036, 0x0005CF4B,
+	0xCDCDCDCD, 0xCDCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00084EB4,
+		0x036, 0x0008CC35,
+		0x036, 0x00094C35,
+		0x036, 0x0009CC35,
+		0x036, 0x000A4935,
+		0x036, 0x000ACC35,
+		0x036, 0x000B4C35,
+		0x036, 0x000BCC35,
+		0x036, 0x000C4EB4,
+		0x036, 0x000CCEB5,
+		0x036, 0x000D4EB5,
+		0x036, 0x000DCEB5,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00000008,
+	0xFF0F0740, 0xABCD,
+		0x03C, 0x000002CC,
+		0x03C, 0x00000522,
+		0x03C, 0x00000902,
+	0xFF0F02C0, 0xCDEF,
+		0x03C, 0x000002CC,
+		0x03C, 0x00000522,
+		0x03C, 0x00000902,
+	0xFF0F01C0, 0xCDEF,
+		0x03C, 0x000002CC,
+		0x03C, 0x00000522,
+		0x03C, 0x00000902,
+	0xFF0F07D8, 0xCDEF,
+		0x03C, 0x000002CC,
+		0x03C, 0x00000522,
+		0x03C, 0x00000902,
+	0xFF0F07D0, 0xCDEF,
+		0x03C, 0x000002CC,
+		0x03C, 0x00000522,
+		0x03C, 0x00000902,
+	0xCDCDCDCD, 0xCDCD,
+		0x03C, 0x000002A8,
+		0x03C, 0x000005A2,
+		0x03C, 0x00000880,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000002,
+		0x0DF, 0x00000080,
+		0x01F, 0x00040064,
+	0xFF0F0740, 0xABCD,
+		0x061, 0x000FDD43,
+		0x062, 0x00038F4B,
+		0x063, 0x00032117,
+		0x064, 0x000194AC,
+		0x065, 0x000931D1,
+	0xFF0F02C0, 0xCDEF,
+		0x061, 0x000FDD43,
+		0x062, 0x00038F4B,
+		0x063, 0x00032117,
+		0x064, 0x000194AC,
+		0x065, 0x000931D1,
+	0xFF0F01C0, 0xCDEF,
+		0x061, 0x000FDD43,
+		0x062, 0x00038F4B,
+		0x063, 0x00032117,
+		0x064, 0x000194AC,
+		0x065, 0x000931D1,
+	0xFF0F07D8, 0xCDEF,
+		0x061, 0x000FDD43,
+		0x062, 0x00038F4B,
+		0x063, 0x00032117,
+		0x064, 0x000194AC,
+		0x065, 0x000931D1,
+	0xFF0F07D0, 0xCDEF,
+		0x061, 0x000FDD43,
+		0x062, 0x00038F4B,
+		0x063, 0x00032117,
+		0x064, 0x000194AC,
+		0x065, 0x000931D1,
+	0xCDCDCDCD, 0xCDCD,
+		0x061, 0x000E5D53,
+		0x062, 0x00038FCD,
+		0x063, 0x000314EB,
+		0x064, 0x000196AC,
+		0x065, 0x000911D7,
+	0xFF0F0740, 0xDEAD,
+		0x008, 0x00008400,
+		0x01C, 0x000739D2,
+		0x0B4, 0x0001E78D,
+		0x018, 0x0001F12A,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0B4, 0x0001A78D,
+		0x018, 0x0001712A,
+
+};
+
+u32 RTL8812AE_RADIOB_ARRAY[] =3D {
+		0x056, 0x00051CF2,
+		0x066, 0x00040000,
+		0x089, 0x00000080,
+	0xFF0F0740, 0xABCD,
+		0x086, 0x00014B38,
+	0xFF0F01C0, 0xCDEF,
+		0x086, 0x00014B38,
+	0xFF0F02C0, 0xCDEF,
+		0x086, 0x00014B38,
+	0xFF0F07D8, 0xCDEF,
+		0x086, 0x00014B3A,
+	0xFF0F07D0, 0xCDEF,
+		0x086, 0x00014B3A,
+	0xCDCDCDCD, 0xCDCD,
+		0x086, 0x00014B38,
+	0xFF0F0740, 0xDEAD,
+		0x018, 0x00000006,
+		0x0EF, 0x00002000,
+	0xFF0F07D8, 0xABCD,
+		0x03B, 0x0003F218,
+		0x03B, 0x00030A58,
+		0x03B, 0x0002FA58,
+		0x03B, 0x00022590,
+		0x03B, 0x0001FA50,
+		0x03B, 0x00010248,
+		0x03B, 0x00008240,
+	0xFF0F07D0, 0xCDEF,
+		0x03B, 0x0003F218,
+		0x03B, 0x00030A58,
+		0x03B, 0x0002FA58,
+		0x03B, 0x00022590,
+		0x03B, 0x0001FA50,
+		0x03B, 0x00010248,
+		0x03B, 0x00008240,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x00038A58,
+		0x03B, 0x00037A58,
+		0x03B, 0x0002A590,
+		0x03B, 0x00027A50,
+		0x03B, 0x00018248,
+		0x03B, 0x00010240,
+		0x03B, 0x00008240,
+	0xFF0F07D8, 0xDEAD,
+		0x0EF, 0x00000100,
+	0xFF0F07D8, 0xABCD,
+		0x034, 0x0000A4EE,
+		0x034, 0x00009076,
+		0x034, 0x00008073,
+		0x034, 0x00007070,
+		0x034, 0x0000606D,
+		0x034, 0x0000506A,
+		0x034, 0x00004049,
+		0x034, 0x00003046,
+		0x034, 0x00002028,
+		0x034, 0x00001025,
+		0x034, 0x00000022,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000ADF4,
+		0x034, 0x00009DF1,
+		0x034, 0x00008DEE,
+		0x034, 0x00007DEB,
+		0x034, 0x00006DE8,
+		0x034, 0x00005CEC,
+		0x034, 0x00004CE9,
+		0x034, 0x000034EA,
+		0x034, 0x000024E7,
+		0x034, 0x0000146B,
+		0x034, 0x0000006D,
+	0xFF0F07D8, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0EF, 0x000020A2,
+		0x0DF, 0x00000080,
+		0x035, 0x00000192,
+		0x035, 0x00008192,
+		0x035, 0x00010192,
+		0x036, 0x00000024,
+		0x036, 0x00008024,
+		0x036, 0x00010024,
+		0x036, 0x00018024,
+		0x0EF, 0x00000000,
+		0x051, 0x00000C21,
+		0x052, 0x000006D9,
+		0x053, 0x000FC649,
+		0x054, 0x0000017E,
+		0x0EF, 0x00000002,
+		0x008, 0x00008400,
+		0x018, 0x0001712A,
+		0x0EF, 0x00001000,
+		0x03A, 0x00000080,
+		0x03B, 0x0003A02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x0003202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x0002B064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x00023070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0001B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00012085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0000A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00002080,
+		0x03C, 0x00010000,
+		0x03A, 0x00000080,
+		0x03B, 0x0007A02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x0007202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x0006B064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x00063070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0005B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00052085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0004A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00042080,
+		0x03C, 0x00010000,
+		0x03A, 0x00000080,
+		0x03B, 0x000BA02C,
+		0x03C, 0x00004000,
+		0x03A, 0x00000400,
+		0x03B, 0x000B202C,
+		0x03C, 0x00010000,
+		0x03A, 0x000000A0,
+		0x03B, 0x000AB064,
+		0x03C, 0x00004000,
+		0x03A, 0x000000D8,
+		0x03B, 0x000A3070,
+		0x03C, 0x00004000,
+		0x03A, 0x00000468,
+		0x03B, 0x0009B870,
+		0x03C, 0x00010000,
+		0x03A, 0x00000098,
+		0x03B, 0x00092085,
+		0x03C, 0x000E4000,
+		0x03A, 0x00000418,
+		0x03B, 0x0008A080,
+		0x03C, 0x000F0000,
+		0x03A, 0x00000418,
+		0x03B, 0x00082080,
+		0x03C, 0x00010000,
+		0x0EF, 0x00001100,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0004A0B2,
+		0x034, 0x000490AF,
+		0x034, 0x00048070,
+		0x034, 0x0004706D,
+		0x034, 0x00046050,
+		0x034, 0x0004504D,
+		0x034, 0x0004404A,
+		0x034, 0x00043047,
+		0x034, 0x0004200A,
+		0x034, 0x00041007,
+		0x034, 0x00040004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0004ADF5,
+		0x034, 0x00049DF2,
+		0x034, 0x00048DEF,
+		0x034, 0x00047DEC,
+		0x034, 0x00046DE9,
+		0x034, 0x00045DC9,
+		0x034, 0x00044CE8,
+		0x034, 0x000438CA,
+		0x034, 0x00042889,
+		0x034, 0x0004184A,
+		0x034, 0x0004044A,
+	0xFF0F0740, 0xDEAD,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0002A0B2,
+		0x034, 0x000290AF,
+		0x034, 0x00028070,
+		0x034, 0x0002706D,
+		0x034, 0x00026050,
+		0x034, 0x0002504D,
+		0x034, 0x0002404A,
+		0x034, 0x00023047,
+		0x034, 0x0002200A,
+		0x034, 0x00021007,
+		0x034, 0x00020004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0002ADF5,
+		0x034, 0x00029DF2,
+		0x034, 0x00028DEF,
+		0x034, 0x00027DEC,
+		0x034, 0x00026DE9,
+		0x034, 0x00025DC9,
+		0x034, 0x00024CE8,
+		0x034, 0x000238CA,
+		0x034, 0x00022889,
+		0x034, 0x0002184A,
+		0x034, 0x0002044A,
+	0xFF0F0740, 0xDEAD,
+	0xFF0F0740, 0xABCD,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F01C0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F07D8, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xFF0F07D0, 0xCDEF,
+		0x034, 0x0000A0B2,
+		0x034, 0x000090AF,
+		0x034, 0x00008070,
+		0x034, 0x0000706D,
+		0x034, 0x00006050,
+		0x034, 0x0000504D,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x0000200A,
+		0x034, 0x00001007,
+		0x034, 0x00000004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000AFF7,
+		0x034, 0x00009DF7,
+		0x034, 0x00008DF4,
+		0x034, 0x00007DF1,
+		0x034, 0x00006DEE,
+		0x034, 0x00005DCD,
+		0x034, 0x00004CEB,
+		0x034, 0x000038CC,
+		0x034, 0x0000288B,
+		0x034, 0x0000184C,
+		0x034, 0x0000044C,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+	0xFF0F0740, 0xABCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001C5,
+		0x035, 0x000081C5,
+		0x035, 0x000101C5,
+		0x035, 0x00020174,
+		0x035, 0x00028174,
+		0x035, 0x00030174,
+		0x035, 0x00040185,
+		0x035, 0x00048185,
+		0x035, 0x00050185,
+		0x0EF, 0x00000000,
+	0xFF0F01C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001C5,
+		0x035, 0x000081C5,
+		0x035, 0x000101C5,
+		0x035, 0x00020174,
+		0x035, 0x00028174,
+		0x035, 0x00030174,
+		0x035, 0x00040185,
+		0x035, 0x00048185,
+		0x035, 0x00050185,
+		0x0EF, 0x00000000,
+	0xFF0F02C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001C5,
+		0x035, 0x000081C5,
+		0x035, 0x000101C5,
+		0x035, 0x00020174,
+		0x035, 0x00028174,
+		0x035, 0x00030174,
+		0x035, 0x00040185,
+		0x035, 0x00048185,
+		0x035, 0x00050185,
+		0x0EF, 0x00000000,
+	0xFF0F07D8, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001C5,
+		0x035, 0x000081C5,
+		0x035, 0x000101C5,
+		0x035, 0x00020174,
+		0x035, 0x00028174,
+		0x035, 0x00030174,
+		0x035, 0x00040185,
+		0x035, 0x00048185,
+		0x035, 0x00050185,
+		0x0EF, 0x00000000,
+	0xFF0F07D0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x000001C5,
+		0x035, 0x000081C5,
+		0x035, 0x000101C5,
+		0x035, 0x00020174,
+		0x035, 0x00028174,
+		0x035, 0x00030174,
+		0x035, 0x00040185,
+		0x035, 0x00048185,
+		0x035, 0x00050185,
+		0x0EF, 0x00000000,
+	0xCDCDCDCD, 0xCDCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+		0x035, 0x00000186,
+		0x035, 0x00008186,
+		0x035, 0x00010185,
+		0x035, 0x000201D5,
+		0x035, 0x000281D5,
+		0x035, 0x000301D5,
+		0x035, 0x000401D5,
+		0x035, 0x000481D5,
+		0x035, 0x000501D5,
+		0x0EF, 0x00000000,
+	0xFF0F0740, 0xDEAD,
+	0xFF0F0740, 0xABCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00005B8B,
+		0x036, 0x0000DB8B,
+		0x036, 0x00015B8B,
+		0x036, 0x0001DB8B,
+		0x036, 0x000262DB,
+		0x036, 0x0002E2DB,
+		0x036, 0x000362DB,
+		0x036, 0x0003E2DB,
+		0x036, 0x0004553B,
+		0x036, 0x0004D53B,
+		0x036, 0x0005553B,
+		0x036, 0x0005D53B,
+	0xFF0F01C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00005B8B,
+		0x036, 0x0000DB8B,
+		0x036, 0x00015B8B,
+		0x036, 0x0001DB8B,
+		0x036, 0x000262DB,
+		0x036, 0x0002E2DB,
+		0x036, 0x000362DB,
+		0x036, 0x0003E2DB,
+		0x036, 0x0004553B,
+		0x036, 0x0004D53B,
+		0x036, 0x0005553B,
+		0x036, 0x0005D53B,
+	0xFF0F02C0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00005B8B,
+		0x036, 0x0000DB8B,
+		0x036, 0x00015B8B,
+		0x036, 0x0001DB8B,
+		0x036, 0x000262DB,
+		0x036, 0x0002E2DB,
+		0x036, 0x000362DB,
+		0x036, 0x0003E2DB,
+		0x036, 0x0004553B,
+		0x036, 0x0004D53B,
+		0x036, 0x0005553B,
+		0x036, 0x0005D53B,
+	0xFF0F07D8, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00005B8B,
+		0x036, 0x0000DB8B,
+		0x036, 0x00015B8B,
+		0x036, 0x0001DB8B,
+		0x036, 0x000262DB,
+		0x036, 0x0002E2DB,
+		0x036, 0x000362DB,
+		0x036, 0x0003E2DB,
+		0x036, 0x0004553B,
+		0x036, 0x0004D53B,
+		0x036, 0x0005553B,
+		0x036, 0x0005D53B,
+	0xFF0F07D0, 0xCDEF,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00005B8B,
+		0x036, 0x0000DB8B,
+		0x036, 0x00015B8B,
+		0x036, 0x0001DB8B,
+		0x036, 0x000262DB,
+		0x036, 0x0002E2DB,
+		0x036, 0x000362DB,
+		0x036, 0x0003E2DB,
+		0x036, 0x0004553B,
+		0x036, 0x0004D53B,
+		0x036, 0x0005553B,
+		0x036, 0x0005D53B,
+	0xCDCDCDCD, 0xCDCD,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+		0x036, 0x00084EB4,
+		0x036, 0x0008C9B4,
+		0x036, 0x000949B4,
+		0x036, 0x0009C9B4,
+		0x036, 0x000A4935,
+		0x036, 0x000AC935,
+		0x036, 0x000B4935,
+		0x036, 0x000BC935,
+		0x036, 0x000C4EB4,
+		0x036, 0x000CCEB4,
+		0x036, 0x000D4EB4,
+		0x036, 0x000DCEB4,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00000008,
+	0xFF0F0740, 0xABCD,
+		0x03C, 0x000002DC,
+		0x03C, 0x00000524,
+		0x03C, 0x00000902,
+	0xFF0F01C0, 0xCDEF,
+		0x03C, 0x000002DC,
+		0x03C, 0x00000524,
+		0x03C, 0x00000902,
+	0xFF0F02C0, 0xCDEF,
+		0x03C, 0x000002DC,
+		0x03C, 0x00000524,
+		0x03C, 0x00000902,
+	0xFF0F07D8, 0xCDEF,
+		0x03C, 0x000002DC,
+		0x03C, 0x00000524,
+		0x03C, 0x00000902,
+	0xFF0F07D0, 0xCDEF,
+		0x03C, 0x000002DC,
+		0x03C, 0x00000524,
+		0x03C, 0x00000902,
+	0xCDCDCDCD, 0xCDCD,
+		0x03C, 0x000002AA,
+		0x03C, 0x000005A2,
+		0x03C, 0x00000880,
+	0xFF0F0740, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000002,
+		0x0DF, 0x00000080,
+	0xFF0F0740, 0xABCD,
+		0x061, 0x000EAC43,
+		0x062, 0x00038F47,
+		0x063, 0x00031157,
+		0x064, 0x0001C4AC,
+		0x065, 0x000931D1,
+	0xFF0F01C0, 0xCDEF,
+		0x061, 0x000EAC43,
+		0x062, 0x00038F47,
+		0x063, 0x00031157,
+		0x064, 0x0001C4AC,
+		0x065, 0x000931D1,
+	0xFF0F02C0, 0xCDEF,
+		0x061, 0x000EAC43,
+		0x062, 0x00038F47,
+		0x063, 0x00031157,
+		0x064, 0x0001C4AC,
+		0x065, 0x000931D1,
+	0xFF0F07D8, 0xCDEF,
+		0x061, 0x000EAC43,
+		0x062, 0x00038F47,
+		0x063, 0x00031157,
+		0x064, 0x0001C4AC,
+		0x065, 0x000931D1,
+	0xFF0F07D0, 0xCDEF,
+		0x061, 0x000EAC43,
+		0x062, 0x00038F47,
+		0x063, 0x00031157,
+		0x064, 0x0001C4AC,
+		0x065, 0x000931D1,
+	0xCDCDCDCD, 0xCDCD,
+		0x061, 0x000E5D53,
+		0x062, 0x00038FCD,
+		0x063, 0x000314EB,
+		0x064, 0x000196AC,
+		0x065, 0x000931D7,
+	0xFF0F0740, 0xDEAD,
+		0x008, 0x00008400,
+
+};
+
+u32 RTL8821AE_RADIOA_ARRAY[] =3D {
+		0x018, 0x0001712A,
+		0x056, 0x00051CF2,
+		0x066, 0x00040000,
+		0x000, 0x00010000,
+		0x01E, 0x00080000,
+		0x082, 0x00000830,
+		0x083, 0x00021800,
+		0x084, 0x00028000,
+		0x085, 0x00048000,
+		0x086, 0x00094838,
+		0x087, 0x00044980,
+		0x088, 0x00048000,
+		0x089, 0x0000D480,
+		0x08A, 0x00042240,
+		0x08B, 0x000F0380,
+		0x08C, 0x00090000,
+		0x08D, 0x00022852,
+		0x08E, 0x00065540,
+		0x08F, 0x00088001,
+		0x0EF, 0x00020000,
+		0x03E, 0x00000380,
+		0x03F, 0x00090018,
+		0x03E, 0x00020380,
+		0x03F, 0x000A0018,
+		0x03E, 0x00040308,
+		0x03F, 0x000A0018,
+		0x03E, 0x00060018,
+		0x03F, 0x000A0018,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x089, 0x00000080,
+		0x08B, 0x00080180,
+		0x0EF, 0x00001000,
+		0x03A, 0x00000244,
+		0x03B, 0x00038027,
+		0x03C, 0x00082000,
+		0x03A, 0x00000244,
+		0x03B, 0x00030113,
+		0x03C, 0x00082000,
+		0x03A, 0x0000014C,
+		0x03B, 0x00028027,
+		0x03C, 0x00082000,
+		0x03A, 0x000000CC,
+		0x03B, 0x00027027,
+		0x03C, 0x00042000,
+		0x03A, 0x0000014C,
+		0x03B, 0x0001F913,
+		0x03C, 0x00042000,
+		0x03A, 0x0000010C,
+		0x03B, 0x00017F10,
+		0x03C, 0x00012000,
+		0x03A, 0x000000D0,
+		0x03B, 0x00008027,
+		0x03C, 0x000CA000,
+		0x03A, 0x00000244,
+		0x03B, 0x00078027,
+		0x03C, 0x00082000,
+		0x03A, 0x00000244,
+		0x03B, 0x00070113,
+		0x03C, 0x00082000,
+		0x03A, 0x0000014C,
+		0x03B, 0x00068027,
+		0x03C, 0x00082000,
+		0x03A, 0x000000CC,
+		0x03B, 0x00067027,
+		0x03C, 0x00042000,
+		0x03A, 0x0000014C,
+		0x03B, 0x0005F913,
+		0x03C, 0x00042000,
+		0x03A, 0x0000010C,
+		0x03B, 0x00057F10,
+		0x03C, 0x00012000,
+		0x03A, 0x000000D0,
+		0x03B, 0x00048027,
+		0x03C, 0x000CA000,
+		0x03A, 0x00000244,
+		0x03B, 0x000B8027,
+		0x03C, 0x00082000,
+		0x03A, 0x00000244,
+		0x03B, 0x000B0113,
+		0x03C, 0x00082000,
+		0x03A, 0x0000014C,
+		0x03B, 0x000A8027,
+		0x03C, 0x00082000,
+		0x03A, 0x000000CC,
+		0x03B, 0x000A7027,
+		0x03C, 0x00042000,
+		0x03A, 0x0000014C,
+		0x03B, 0x0009F913,
+		0x03C, 0x00042000,
+		0x03A, 0x0000010C,
+		0x03B, 0x00097F10,
+		0x03C, 0x00012000,
+		0x03A, 0x000000D0,
+		0x03B, 0x00088027,
+		0x03C, 0x000CA000,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00001100,
+	0xFF0F0104, 0xABCD,
+		0x034, 0x0004ADF3,
+		0x034, 0x00049DF0,
+	0xFF0F0204, 0xCDEF,
+		0x034, 0x0004ADF3,
+		0x034, 0x00049DF0,
+	0xFF0F0404, 0xCDEF,
+		0x034, 0x0004ADF3,
+		0x034, 0x00049DF0,
+	0xFF0F0200, 0xCDEF,
+		0x034, 0x0004ADF5,
+		0x034, 0x00049DF2,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0004A0F3,
+		0x034, 0x000490B1,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0004ADF7,
+		0x034, 0x00049DF3,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x034, 0x00048DED,
+		0x034, 0x00047DEA,
+		0x034, 0x00046DE7,
+		0x034, 0x00045CE9,
+		0x034, 0x00044CE6,
+		0x034, 0x000438C6,
+		0x034, 0x00042886,
+		0x034, 0x00041486,
+		0x034, 0x00040447,
+	0xFF0F0204, 0xCDEF,
+		0x034, 0x00048DED,
+		0x034, 0x00047DEA,
+		0x034, 0x00046DE7,
+		0x034, 0x00045CE9,
+		0x034, 0x00044CE6,
+		0x034, 0x000438C6,
+		0x034, 0x00042886,
+		0x034, 0x00041486,
+		0x034, 0x00040447,
+	0xFF0F0404, 0xCDEF,
+		0x034, 0x00048DED,
+		0x034, 0x00047DEA,
+		0x034, 0x00046DE7,
+		0x034, 0x00045CE9,
+		0x034, 0x00044CE6,
+		0x034, 0x000438C6,
+		0x034, 0x00042886,
+		0x034, 0x00041486,
+		0x034, 0x00040447,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x000480AE,
+		0x034, 0x000470AB,
+		0x034, 0x0004608B,
+		0x034, 0x00045069,
+		0x034, 0x00044048,
+		0x034, 0x00043045,
+		0x034, 0x00042026,
+		0x034, 0x00041023,
+		0x034, 0x00040002,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x00048DEF,
+		0x034, 0x00047DEC,
+		0x034, 0x00046DE9,
+		0x034, 0x00045CCB,
+		0x034, 0x0004488D,
+		0x034, 0x0004348D,
+		0x034, 0x0004248A,
+		0x034, 0x0004108D,
+		0x034, 0x0004008A,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0200, 0xABCD,
+		0x034, 0x0002ADF4,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0002A0F3,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0002ADF7,
+	0xFF0F0200, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x034, 0x00029DF4,
+	0xFF0F0204, 0xCDEF,
+		0x034, 0x00029DF4,
+	0xFF0F0404, 0xCDEF,
+		0x034, 0x00029DF4,
+	0xFF0F0200, 0xCDEF,
+		0x034, 0x00029DF1,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x000290F0,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x00029DF2,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x034, 0x00028DF1,
+		0x034, 0x00027DEE,
+		0x034, 0x00026DEB,
+		0x034, 0x00025CEC,
+		0x034, 0x00024CE9,
+		0x034, 0x000238CA,
+		0x034, 0x00022889,
+		0x034, 0x00021489,
+		0x034, 0x0002044A,
+	0xFF0F0204, 0xCDEF,
+		0x034, 0x00028DF1,
+		0x034, 0x00027DEE,
+		0x034, 0x00026DEB,
+		0x034, 0x00025CEC,
+		0x034, 0x00024CE9,
+		0x034, 0x000238CA,
+		0x034, 0x00022889,
+		0x034, 0x00021489,
+		0x034, 0x0002044A,
+	0xFF0F0404, 0xCDEF,
+		0x034, 0x00028DF1,
+		0x034, 0x00027DEE,
+		0x034, 0x00026DEB,
+		0x034, 0x00025CEC,
+		0x034, 0x00024CE9,
+		0x034, 0x000238CA,
+		0x034, 0x00022889,
+		0x034, 0x00021489,
+		0x034, 0x0002044A,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x000280AF,
+		0x034, 0x000270AC,
+		0x034, 0x0002608B,
+		0x034, 0x00025069,
+		0x034, 0x00024048,
+		0x034, 0x00023045,
+		0x034, 0x00022026,
+		0x034, 0x00021023,
+		0x034, 0x00020002,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x00028DEE,
+		0x034, 0x00027DEB,
+		0x034, 0x00026CCD,
+		0x034, 0x00025CCA,
+		0x034, 0x0002488C,
+		0x034, 0x0002384C,
+		0x034, 0x00022849,
+		0x034, 0x00021449,
+		0x034, 0x0002004D,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F02C0, 0xABCD,
+		0x034, 0x0000A0D7,
+		0x034, 0x000090D3,
+		0x034, 0x000080B1,
+		0x034, 0x000070AE,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000ADF7,
+		0x034, 0x00009DF4,
+		0x034, 0x00008DF1,
+		0x034, 0x00007DEE,
+	0xFF0F02C0, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x034, 0x00006DEB,
+		0x034, 0x00005CEC,
+		0x034, 0x00004CE9,
+		0x034, 0x000038CA,
+		0x034, 0x00002889,
+		0x034, 0x00001489,
+		0x034, 0x0000044A,
+	0xFF0F0204, 0xCDEF,
+		0x034, 0x00006DEB,
+		0x034, 0x00005CEC,
+		0x034, 0x00004CE9,
+		0x034, 0x000038CA,
+		0x034, 0x00002889,
+		0x034, 0x00001489,
+		0x034, 0x0000044A,
+	0xFF0F0404, 0xCDEF,
+		0x034, 0x00006DEB,
+		0x034, 0x00005CEC,
+		0x034, 0x00004CE9,
+		0x034, 0x000038CA,
+		0x034, 0x00002889,
+		0x034, 0x00001489,
+		0x034, 0x0000044A,
+	0xFF0F02C0, 0xCDEF,
+		0x034, 0x0000608D,
+		0x034, 0x0000506B,
+		0x034, 0x0000404A,
+		0x034, 0x00003047,
+		0x034, 0x00002044,
+		0x034, 0x00001025,
+		0x034, 0x00000004,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x00006DCD,
+		0x034, 0x00005CCD,
+		0x034, 0x00004CCA,
+		0x034, 0x0000388C,
+		0x034, 0x00002888,
+		0x034, 0x00001488,
+		0x034, 0x00000486,
+	0xFF0F0104, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000040,
+	0xFF0F0104, 0xABCD,
+		0x035, 0x00000187,
+		0x035, 0x00008187,
+		0x035, 0x00010187,
+		0x035, 0x00020188,
+		0x035, 0x00028188,
+		0x035, 0x00030188,
+		0x035, 0x00040188,
+		0x035, 0x00048188,
+		0x035, 0x00050188,
+	0xFF0F0204, 0xCDEF,
+		0x035, 0x00000187,
+		0x035, 0x00008187,
+		0x035, 0x00010187,
+		0x035, 0x00020188,
+		0x035, 0x00028188,
+		0x035, 0x00030188,
+		0x035, 0x00040188,
+		0x035, 0x00048188,
+		0x035, 0x00050188,
+	0xFF0F0404, 0xCDEF,
+		0x035, 0x00000187,
+		0x035, 0x00008187,
+		0x035, 0x00010187,
+		0x035, 0x00020188,
+		0x035, 0x00028188,
+		0x035, 0x00030188,
+		0x035, 0x00040188,
+		0x035, 0x00048188,
+		0x035, 0x00050188,
+	0xCDCDCDCD, 0xCDCD,
+		0x035, 0x00000145,
+		0x035, 0x00008145,
+		0x035, 0x00010145,
+		0x035, 0x00020196,
+		0x035, 0x00028196,
+		0x035, 0x00030196,
+		0x035, 0x000401C7,
+		0x035, 0x000481C7,
+		0x035, 0x000501C7,
+	0xFF0F0104, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000010,
+	0xFF0F0104, 0xABCD,
+		0x036, 0x00085733,
+		0x036, 0x0008D733,
+		0x036, 0x00095733,
+		0x036, 0x0009D733,
+		0x036, 0x000A64B4,
+		0x036, 0x000AE4B4,
+		0x036, 0x000B64B4,
+		0x036, 0x000BE4B4,
+		0x036, 0x000C64B4,
+		0x036, 0x000CE4B4,
+		0x036, 0x000D64B4,
+		0x036, 0x000DE4B4,
+	0xFF0F0204, 0xCDEF,
+		0x036, 0x00085733,
+		0x036, 0x0008D733,
+		0x036, 0x00095733,
+		0x036, 0x0009D733,
+		0x036, 0x000A64B4,
+		0x036, 0x000AE4B4,
+		0x036, 0x000B64B4,
+		0x036, 0x000BE4B4,
+		0x036, 0x000C64B4,
+		0x036, 0x000CE4B4,
+		0x036, 0x000D64B4,
+		0x036, 0x000DE4B4,
+	0xFF0F0404, 0xCDEF,
+		0x036, 0x00085733,
+		0x036, 0x0008D733,
+		0x036, 0x00095733,
+		0x036, 0x0009D733,
+		0x036, 0x000A64B4,
+		0x036, 0x000AE4B4,
+		0x036, 0x000B64B4,
+		0x036, 0x000BE4B4,
+		0x036, 0x000C64B4,
+		0x036, 0x000CE4B4,
+		0x036, 0x000D64B4,
+		0x036, 0x000DE4B4,
+	0xCDCDCDCD, 0xCDCD,
+		0x036, 0x000056B3,
+		0x036, 0x0000D6B3,
+		0x036, 0x000156B3,
+		0x036, 0x0001D6B3,
+		0x036, 0x00026634,
+		0x036, 0x0002E634,
+		0x036, 0x00036634,
+		0x036, 0x0003E634,
+		0x036, 0x000467B4,
+		0x036, 0x0004E7B4,
+		0x036, 0x000567B4,
+		0x036, 0x0005E7B4,
+	0xFF0F0104, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00000008,
+	0xFF0F0104, 0xABCD,
+		0x03C, 0x000001C8,
+		0x03C, 0x00000492,
+	0xFF0F0204, 0xCDEF,
+		0x03C, 0x000001C8,
+		0x03C, 0x00000492,
+	0xFF0F0404, 0xCDEF,
+		0x03C, 0x000001C8,
+		0x03C, 0x00000492,
+	0xCDCDCDCD, 0xCDCD,
+		0x03C, 0x0000022A,
+		0x03C, 0x00000594,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x03C, 0x00000800,
+	0xFF0F0204, 0xCDEF,
+		0x03C, 0x00000800,
+	0xFF0F0404, 0xCDEF,
+		0x03C, 0x00000800,
+	0xFF0F02C0, 0xCDEF,
+		0x03C, 0x00000820,
+	0xCDCDCDCD, 0xCDCD,
+		0x03C, 0x00000900,
+	0xFF0F0104, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x018, 0x0001712A,
+		0x0EF, 0x00000002,
+	0xFF0F0104, 0xABCD,
+		0x008, 0x0004E400,
+	0xFF0F0204, 0xCDEF,
+		0x008, 0x0004E400,
+	0xFF0F0404, 0xCDEF,
+		0x008, 0x0004E400,
+	0xCDCDCDCD, 0xCDCD,
+		0x008, 0x00002000,
+	0xFF0F0104, 0xDEAD,
+		0x0EF, 0x00000000,
+		0x0DF, 0x000000C0,
+		0x01F, 0x00040064,
+	0xFF0F0104, 0xABCD,
+		0x058, 0x000A7284,
+		0x059, 0x000600EC,
+	0xFF0F0204, 0xCDEF,
+		0x058, 0x000A7284,
+		0x059, 0x000600EC,
+	0xFF0F0404, 0xCDEF,
+		0x058, 0x000A7284,
+		0x059, 0x000600EC,
+	0xCDCDCDCD, 0xCDCD,
+		0x058, 0x00081184,
+		0x059, 0x0006016C,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x061, 0x000E8D73,
+		0x062, 0x00093FC5,
+	0xFF0F0204, 0xCDEF,
+		0x061, 0x000E8D73,
+		0x062, 0x00093FC5,
+	0xFF0F0404, 0xCDEF,
+		0x061, 0x000E8D73,
+		0x062, 0x00093FC5,
+	0xCDCDCDCD, 0xCDCD,
+		0x061, 0x000EAD53,
+		0x062, 0x00093BC4,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x063, 0x000110E9,
+	0xFF0F0204, 0xCDEF,
+		0x063, 0x000110E9,
+	0xFF0F0404, 0xCDEF,
+		0x063, 0x000110E9,
+	0xFF0F0200, 0xCDEF,
+		0x063, 0x000710E9,
+	0xFF0F02C0, 0xCDEF,
+		0x063, 0x000110E9,
+	0xCDCDCDCD, 0xCDCD,
+		0x063, 0x000714E9,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0104, 0xABCD,
+		0x064, 0x0001C27C,
+	0xFF0F0204, 0xCDEF,
+		0x064, 0x0001C27C,
+	0xFF0F0404, 0xCDEF,
+		0x064, 0x0001C27C,
+	0xCDCDCDCD, 0xCDCD,
+		0x064, 0x0001C67C,
+	0xFF0F0104, 0xDEAD,
+	0xFF0F0200, 0xABCD,
+		0x065, 0x00093016,
+	0xFF0F02C0, 0xCDEF,
+		0x065, 0x00093015,
+	0xCDCDCDCD, 0xCDCD,
+		0x065, 0x00091016,
+	0xFF0F0200, 0xDEAD,
+		0x018, 0x00000006,
+		0x0EF, 0x00002000,
+		0x03B, 0x0003824B,
+		0x03B, 0x0003024B,
+		0x03B, 0x0002844B,
+		0x03B, 0x00020F4B,
+		0x03B, 0x00018F4B,
+		0x03B, 0x000104B2,
+		0x03B, 0x00008049,
+		0x03B, 0x00000148,
+		0x03B, 0x0007824B,
+		0x03B, 0x0007024B,
+		0x03B, 0x0006824B,
+		0x03B, 0x00060F4B,
+		0x03B, 0x00058F4B,
+		0x03B, 0x000504B2,
+		0x03B, 0x00048049,
+		0x03B, 0x00040148,
+		0x0EF, 0x00000000,
+		0x0EF, 0x00000100,
+		0x034, 0x0000ADF3,
+		0x034, 0x00009DEF,
+		0x034, 0x00008DEC,
+		0x034, 0x00007DE9,
+		0x034, 0x00006CED,
+		0x034, 0x00005CE9,
+		0x034, 0x000044E9,
+		0x034, 0x000034E6,
+		0x034, 0x0000246A,
+		0x034, 0x00001467,
+		0x034, 0x00000068,
+		0x0EF, 0x00000000,
+		0x0ED, 0x00000010,
+		0x044, 0x0000ADF2,
+		0x044, 0x00009DEF,
+		0x044, 0x00008DEC,
+		0x044, 0x00007DE9,
+		0x044, 0x00006CEC,
+		0x044, 0x00005CE9,
+		0x044, 0x000044EC,
+		0x044, 0x000034E9,
+		0x044, 0x0000246C,
+		0x044, 0x00001469,
+		0x044, 0x0000006C,
+		0x0ED, 0x00000000,
+		0x0ED, 0x00000001,
+		0x040, 0x00038DA7,
+		0x040, 0x000300C2,
+		0x040, 0x000288E2,
+		0x040, 0x000200B8,
+		0x040, 0x000188A5,
+		0x040, 0x00010FBC,
+		0x040, 0x00008F71,
+		0x040, 0x00000240,
+		0x0ED, 0x00000000,
+		0x0EF, 0x000020A2,
+		0x0DF, 0x00000080,
+		0x035, 0x00000120,
+		0x035, 0x00008120,
+		0x035, 0x00010120,
+		0x036, 0x00000085,
+		0x036, 0x00008085,
+		0x036, 0x00010085,
+		0x036, 0x00018085,
+		0x0EF, 0x00000000,
+		0x051, 0x00000C31,
+		0x052, 0x00000622,
+		0x053, 0x000FC70B,
+		0x054, 0x0000017E,
+		0x056, 0x00051DF3,
+		0x051, 0x00000C01,
+		0x052, 0x000006D6,
+		0x053, 0x000FC649,
+		0x070, 0x00049661,
+		0x071, 0x0007843E,
+		0x072, 0x00000382,
+		0x074, 0x00051400,
+		0x035, 0x00000160,
+		0x035, 0x00008160,
+		0x035, 0x00010160,
+		0x036, 0x00000124,
+		0x036, 0x00008124,
+		0x036, 0x00010124,
+		0x036, 0x00018124,
+		0x0ED, 0x0000000C,
+		0x045, 0x00000140,
+		0x045, 0x00008140,
+		0x045, 0x00010140,
+		0x046, 0x00000124,
+		0x046, 0x00008124,
+		0x046, 0x00010124,
+		0x046, 0x00018124,
+		0x0DF, 0x00000088,
+		0x0B3, 0x000F0E18,
+		0x0B4, 0x0001214C,
+		0x0B7, 0x0003000C,
+		0x01C, 0x000539D2,
+		0x018, 0x0001F12A,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x018, 0x0001712A,
+};
+
+u32 RTL8812AE_MAC_REG_ARRAY[] =3D {
+		0x010, 0x0000000C,
+	0xFF0F0180, 0xABCD,
+		0x025, 0x0000000F,
+	0xFF0F01C0, 0xCDEF,
+		0x025, 0x0000000F,
+	0xCDCDCDCD, 0xCDCD,
+		0x025, 0x0000006F,
+	0xFF0F0180, 0xDEAD,
+		0x072, 0x00000000,
+		0x428, 0x0000000A,
+		0x429, 0x00000010,
+		0x430, 0x00000000,
+		0x431, 0x00000000,
+		0x432, 0x00000000,
+		0x433, 0x00000001,
+		0x434, 0x00000004,
+		0x435, 0x00000005,
+		0x436, 0x00000007,
+		0x437, 0x00000008,
+		0x43C, 0x00000004,
+		0x43D, 0x00000005,
+		0x43E, 0x00000007,
+		0x43F, 0x00000008,
+		0x440, 0x0000005D,
+		0x441, 0x00000001,
+		0x442, 0x00000000,
+		0x444, 0x00000010,
+		0x445, 0x00000000,
+		0x446, 0x00000000,
+		0x447, 0x00000000,
+		0x448, 0x00000000,
+		0x449, 0x000000F0,
+		0x44A, 0x0000000F,
+		0x44B, 0x0000003E,
+		0x44C, 0x00000010,
+		0x44D, 0x00000000,
+		0x44E, 0x00000000,
+		0x44F, 0x00000000,
+		0x450, 0x00000000,
+		0x451, 0x000000F0,
+		0x452, 0x0000000F,
+		0x453, 0x00000000,
+		0x45B, 0x00000080,
+		0x460, 0x00000066,
+		0x461, 0x00000066,
+		0x4C8, 0x000000FF,
+		0x4C9, 0x00000008,
+		0x4CC, 0x000000FF,
+		0x4CD, 0x000000FF,
+		0x4CE, 0x00000001,
+		0x500, 0x00000026,
+		0x501, 0x000000A2,
+		0x502, 0x0000002F,
+		0x503, 0x00000000,
+		0x504, 0x00000028,
+		0x505, 0x000000A3,
+		0x506, 0x0000005E,
+		0x507, 0x00000000,
+		0x508, 0x0000002B,
+		0x509, 0x000000A4,
+		0x50A, 0x0000005E,
+		0x50B, 0x00000000,
+		0x50C, 0x0000004F,
+		0x50D, 0x000000A4,
+		0x50E, 0x00000000,
+		0x50F, 0x00000000,
+		0x512, 0x0000001C,
+		0x514, 0x0000000A,
+		0x516, 0x0000000A,
+		0x525, 0x0000004F,
+		0x550, 0x00000010,
+		0x551, 0x00000010,
+		0x559, 0x00000002,
+		0x55C, 0x00000050,
+		0x55D, 0x000000FF,
+		0x604, 0x00000001,
+		0x605, 0x00000030,
+		0x607, 0x00000003,
+		0x608, 0x0000000E,
+		0x609, 0x0000002A,
+		0x620, 0x000000FF,
+		0x621, 0x000000FF,
+		0x622, 0x000000FF,
+		0x623, 0x000000FF,
+		0x624, 0x000000FF,
+		0x625, 0x000000FF,
+		0x626, 0x000000FF,
+		0x627, 0x000000FF,
+		0x638, 0x00000050,
+		0x63C, 0x0000000A,
+		0x63D, 0x0000000A,
+		0x63E, 0x0000000E,
+		0x63F, 0x0000000E,
+		0x640, 0x00000080,
+		0x642, 0x00000040,
+		0x643, 0x00000000,
+		0x652, 0x000000C8,
+		0x66E, 0x00000005,
+		0x700, 0x00000021,
+		0x701, 0x00000043,
+		0x702, 0x00000065,
+		0x703, 0x00000087,
+		0x708, 0x00000021,
+		0x709, 0x00000043,
+		0x70A, 0x00000065,
+		0x70B, 0x00000087,
+		0x718, 0x00000040,
+
+};
+
+u32 RTL8821AE_MAC_REG_ARRAY[] =3D {
+		0x428, 0x0000000A,
+		0x429, 0x00000010,
+		0x430, 0x00000000,
+		0x431, 0x00000000,
+		0x432, 0x00000000,
+		0x433, 0x00000001,
+		0x434, 0x00000004,
+		0x435, 0x00000005,
+		0x436, 0x00000007,
+		0x437, 0x00000008,
+		0x43C, 0x00000004,
+		0x43D, 0x00000005,
+		0x43E, 0x00000007,
+		0x43F, 0x00000008,
+		0x440, 0x0000005D,
+		0x441, 0x00000001,
+		0x442, 0x00000000,
+		0x444, 0x00000010,
+		0x445, 0x00000000,
+		0x446, 0x00000000,
+		0x447, 0x00000000,
+		0x448, 0x00000000,
+		0x449, 0x000000F0,
+		0x44A, 0x0000000F,
+		0x44B, 0x0000003E,
+		0x44C, 0x00000010,
+		0x44D, 0x00000000,
+		0x44E, 0x00000000,
+		0x44F, 0x00000000,
+		0x450, 0x00000000,
+		0x451, 0x000000F0,
+		0x452, 0x0000000F,
+		0x453, 0x00000000,
+		0x456, 0x0000005E,
+		0x460, 0x00000066,
+		0x461, 0x00000066,
+		0x4C8, 0x0000003F,
+		0x4C9, 0x000000FF,
+		0x4CC, 0x000000FF,
+		0x4CD, 0x000000FF,
+		0x4CE, 0x00000001,
+		0x500, 0x00000026,
+		0x501, 0x000000A2,
+		0x502, 0x0000002F,
+		0x503, 0x00000000,
+		0x504, 0x00000028,
+		0x505, 0x000000A3,
+		0x506, 0x0000005E,
+		0x507, 0x00000000,
+		0x508, 0x0000002B,
+		0x509, 0x000000A4,
+		0x50A, 0x0000005E,
+		0x50B, 0x00000000,
+		0x50C, 0x0000004F,
+		0x50D, 0x000000A4,
+		0x50E, 0x00000000,
+		0x50F, 0x00000000,
+		0x512, 0x0000001C,
+		0x514, 0x0000000A,
+		0x516, 0x0000000A,
+		0x525, 0x0000004F,
+		0x550, 0x00000010,
+		0x551, 0x00000010,
+		0x559, 0x00000002,
+		0x55C, 0x00000050,
+		0x55D, 0x000000FF,
+		0x605, 0x00000030,
+		0x607, 0x00000007,
+		0x608, 0x0000000E,
+		0x609, 0x0000002A,
+		0x620, 0x000000FF,
+		0x621, 0x000000FF,
+		0x622, 0x000000FF,
+		0x623, 0x000000FF,
+		0x624, 0x000000FF,
+		0x625, 0x000000FF,
+		0x626, 0x000000FF,
+		0x627, 0x000000FF,
+		0x638, 0x00000050,
+		0x63C, 0x0000000A,
+		0x63D, 0x0000000A,
+		0x63E, 0x0000000E,
+		0x63F, 0x0000000E,
+		0x640, 0x00000040,
+		0x642, 0x00000040,
+		0x643, 0x00000000,
+		0x652, 0x000000C8,
+		0x66E, 0x00000005,
+		0x700, 0x00000021,
+		0x701, 0x00000043,
+		0x702, 0x00000065,
+		0x703, 0x00000087,
+		0x708, 0x00000021,
+		0x709, 0x00000043,
+		0x70A, 0x00000065,
+		0x70B, 0x00000087,
+		0x718, 0x00000040,
+};
+
+u32 RTL8812AE_AGC_TAB_ARRAY[] =3D {
+	0xFF0F07D8, 0xABCD,
+		0x81C, 0xFC000001,
+		0x81C, 0xFB020001,
+		0x81C, 0xFA040001,
+		0x81C, 0xF9060001,
+		0x81C, 0xF8080001,
+		0x81C, 0xF70A0001,
+		0x81C, 0xF60C0001,
+		0x81C, 0xF50E0001,
+		0x81C, 0xF4100001,
+		0x81C, 0xF3120001,
+		0x81C, 0xF2140001,
+		0x81C, 0xF1160001,
+		0x81C, 0xF0180001,
+		0x81C, 0xEF1A0001,
+		0x81C, 0xEE1C0001,
+		0x81C, 0xED1E0001,
+		0x81C, 0xEC200001,
+		0x81C, 0xEB220001,
+		0x81C, 0xEA240001,
+		0x81C, 0xCD260001,
+		0x81C, 0xCC280001,
+		0x81C, 0xCB2A0001,
+		0x81C, 0xCA2C0001,
+		0x81C, 0xC92E0001,
+		0x81C, 0xC8300001,
+		0x81C, 0xA6320001,
+		0x81C, 0xA5340001,
+		0x81C, 0xA4360001,
+		0x81C, 0xA3380001,
+		0x81C, 0xA23A0001,
+		0x81C, 0x883C0001,
+		0x81C, 0x873E0001,
+		0x81C, 0x86400001,
+		0x81C, 0x85420001,
+		0x81C, 0x84440001,
+		0x81C, 0x83460001,
+		0x81C, 0x82480001,
+		0x81C, 0x814A0001,
+		0x81C, 0x484C0001,
+		0x81C, 0x474E0001,
+		0x81C, 0x46500001,
+		0x81C, 0x45520001,
+		0x81C, 0x44540001,
+		0x81C, 0x43560001,
+		0x81C, 0x42580001,
+		0x81C, 0x415A0001,
+		0x81C, 0x255C0001,
+		0x81C, 0x245E0001,
+		0x81C, 0x23600001,
+		0x81C, 0x22620001,
+		0x81C, 0x21640001,
+		0x81C, 0x21660001,
+		0x81C, 0x21680001,
+		0x81C, 0x216A0001,
+		0x81C, 0x216C0001,
+		0x81C, 0x216E0001,
+		0x81C, 0x21700001,
+		0x81C, 0x21720001,
+		0x81C, 0x21740001,
+		0x81C, 0x21760001,
+		0x81C, 0x21780001,
+		0x81C, 0x217A0001,
+		0x81C, 0x217C0001,
+		0x81C, 0x217E0001,
+	0xFF0F07D0, 0xCDEF,
+		0x81C, 0xF9000001,
+		0x81C, 0xF8020001,
+		0x81C, 0xF7040001,
+		0x81C, 0xF6060001,
+		0x81C, 0xF5080001,
+		0x81C, 0xF40A0001,
+		0x81C, 0xF30C0001,
+		0x81C, 0xF20E0001,
+		0x81C, 0xF1100001,
+		0x81C, 0xF0120001,
+		0x81C, 0xEF140001,
+		0x81C, 0xEE160001,
+		0x81C, 0xED180001,
+		0x81C, 0xEC1A0001,
+		0x81C, 0xEB1C0001,
+		0x81C, 0xEA1E0001,
+		0x81C, 0xCD200001,
+		0x81C, 0xCC220001,
+		0x81C, 0xCB240001,
+		0x81C, 0xCA260001,
+		0x81C, 0xC9280001,
+		0x81C, 0xC82A0001,
+		0x81C, 0xC72C0001,
+		0x81C, 0xC62E0001,
+		0x81C, 0xA5300001,
+		0x81C, 0xA4320001,
+		0x81C, 0xA3340001,
+		0x81C, 0xA2360001,
+		0x81C, 0x88380001,
+		0x81C, 0x873A0001,
+		0x81C, 0x863C0001,
+		0x81C, 0x853E0001,
+		0x81C, 0x84400001,
+		0x81C, 0x83420001,
+		0x81C, 0x82440001,
+		0x81C, 0x81460001,
+		0x81C, 0x48480001,
+		0x81C, 0x474A0001,
+		0x81C, 0x464C0001,
+		0x81C, 0x454E0001,
+		0x81C, 0x44500001,
+		0x81C, 0x43520001,
+		0x81C, 0x42540001,
+		0x81C, 0x41560001,
+		0x81C, 0x25580001,
+		0x81C, 0x245A0001,
+		0x81C, 0x235C0001,
+		0x81C, 0x225E0001,
+		0x81C, 0x21600001,
+		0x81C, 0x21620001,
+		0x81C, 0x21640001,
+		0x81C, 0x21660001,
+		0x81C, 0x21680001,
+		0x81C, 0x216A0001,
+		0x81C, 0x236C0001,
+		0x81C, 0x226E0001,
+		0x81C, 0x21700001,
+		0x81C, 0x21720001,
+		0x81C, 0x21740001,
+		0x81C, 0x21760001,
+		0x81C, 0x21780001,
+		0x81C, 0x217A0001,
+		0x81C, 0x217C0001,
+		0x81C, 0x217E0001,
+	0xCDCDCDCD, 0xCDCD,
+		0x81C, 0xFF000001,
+		0x81C, 0xFF020001,
+		0x81C, 0xFF040001,
+		0x81C, 0xFF060001,
+		0x81C, 0xFF080001,
+		0x81C, 0xFE0A0001,
+		0x81C, 0xFD0C0001,
+		0x81C, 0xFC0E0001,
+		0x81C, 0xFB100001,
+		0x81C, 0xFA120001,
+		0x81C, 0xF9140001,
+		0x81C, 0xF8160001,
+		0x81C, 0xF7180001,
+		0x81C, 0xF61A0001,
+		0x81C, 0xF51C0001,
+		0x81C, 0xF41E0001,
+		0x81C, 0xF3200001,
+		0x81C, 0xF2220001,
+		0x81C, 0xF1240001,
+		0x81C, 0xF0260001,
+		0x81C, 0xEF280001,
+		0x81C, 0xEE2A0001,
+		0x81C, 0xED2C0001,
+		0x81C, 0xEC2E0001,
+		0x81C, 0xEB300001,
+		0x81C, 0xEA320001,
+		0x81C, 0xE9340001,
+		0x81C, 0xE8360001,
+		0x81C, 0xE7380001,
+		0x81C, 0xE63A0001,
+		0x81C, 0xE53C0001,
+		0x81C, 0xC73E0001,
+		0x81C, 0xC6400001,
+		0x81C, 0xC5420001,
+		0x81C, 0xC4440001,
+		0x81C, 0xC3460001,
+		0x81C, 0xC2480001,
+		0x81C, 0xC14A0001,
+		0x81C, 0xA74C0001,
+		0x81C, 0xA64E0001,
+		0x81C, 0xA5500001,
+		0x81C, 0xA4520001,
+		0x81C, 0xA3540001,
+		0x81C, 0xA2560001,
+		0x81C, 0xA1580001,
+		0x81C, 0x675A0001,
+		0x81C, 0x665C0001,
+		0x81C, 0x655E0001,
+		0x81C, 0x64600001,
+		0x81C, 0x63620001,
+		0x81C, 0x48640001,
+		0x81C, 0x47660001,
+		0x81C, 0x46680001,
+		0x81C, 0x456A0001,
+		0x81C, 0x446C0001,
+		0x81C, 0x436E0001,
+		0x81C, 0x42700001,
+		0x81C, 0x41720001,
+		0x81C, 0x41740001,
+		0x81C, 0x41760001,
+		0x81C, 0x41780001,
+		0x81C, 0x417A0001,
+		0x81C, 0x417C0001,
+		0x81C, 0x417E0001,
+	0xFF0F07D8, 0xDEAD,
+	0xFF0F0180, 0xABCD,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F0280, 0xCDEF,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F01C0, 0xCDEF,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F02C0, 0xCDEF,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F07D8, 0xCDEF,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F07D0, 0xCDEF,
+		0x81C, 0xFC800001,
+		0x81C, 0xFB820001,
+		0x81C, 0xFA840001,
+		0x81C, 0xF9860001,
+		0x81C, 0xF8880001,
+		0x81C, 0xF78A0001,
+		0x81C, 0xF68C0001,
+		0x81C, 0xF58E0001,
+		0x81C, 0xF4900001,
+		0x81C, 0xF3920001,
+		0x81C, 0xF2940001,
+		0x81C, 0xF1960001,
+		0x81C, 0xF0980001,
+		0x81C, 0xEF9A0001,
+		0x81C, 0xEE9C0001,
+		0x81C, 0xED9E0001,
+		0x81C, 0xECA00001,
+		0x81C, 0xEBA20001,
+		0x81C, 0xEAA40001,
+		0x81C, 0xE9A60001,
+		0x81C, 0xE8A80001,
+		0x81C, 0xE7AA0001,
+		0x81C, 0xE6AC0001,
+		0x81C, 0xE5AE0001,
+		0x81C, 0xE4B00001,
+		0x81C, 0xE3B20001,
+		0x81C, 0xA8B40001,
+		0x81C, 0xA7B60001,
+		0x81C, 0xA6B80001,
+		0x81C, 0xA5BA0001,
+		0x81C, 0xA4BC0001,
+		0x81C, 0xA3BE0001,
+		0x81C, 0xA2C00001,
+		0x81C, 0xA1C20001,
+		0x81C, 0x68C40001,
+		0x81C, 0x67C60001,
+		0x81C, 0x66C80001,
+		0x81C, 0x65CA0001,
+		0x81C, 0x64CC0001,
+		0x81C, 0x47CE0001,
+		0x81C, 0x46D00001,
+		0x81C, 0x45D20001,
+		0x81C, 0x44D40001,
+		0x81C, 0x43D60001,
+		0x81C, 0x42D80001,
+		0x81C, 0x08DA0001,
+		0x81C, 0x07DC0001,
+		0x81C, 0x06DE0001,
+		0x81C, 0x05E00001,
+		0x81C, 0x04E20001,
+		0x81C, 0x03E40001,
+		0x81C, 0x02E60001,
+		0x81C, 0x01E80001,
+		0x81C, 0x01EA0001,
+		0x81C, 0x01EC0001,
+		0x81C, 0x01EE0001,
+		0x81C, 0x01F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xCDCDCDCD, 0xCDCD,
+		0x81C, 0xFF800001,
+		0x81C, 0xFF820001,
+		0x81C, 0xFF840001,
+		0x81C, 0xFE860001,
+		0x81C, 0xFD880001,
+		0x81C, 0xFC8A0001,
+		0x81C, 0xFB8C0001,
+		0x81C, 0xFA8E0001,
+		0x81C, 0xF9900001,
+		0x81C, 0xF8920001,
+		0x81C, 0xF7940001,
+		0x81C, 0xF6960001,
+		0x81C, 0xF5980001,
+		0x81C, 0xF49A0001,
+		0x81C, 0xF39C0001,
+		0x81C, 0xF29E0001,
+		0x81C, 0xF1A00001,
+		0x81C, 0xF0A20001,
+		0x81C, 0xEFA40001,
+		0x81C, 0xEEA60001,
+		0x81C, 0xEDA80001,
+		0x81C, 0xECAA0001,
+		0x81C, 0xEBAC0001,
+		0x81C, 0xEAAE0001,
+		0x81C, 0xE9B00001,
+		0x81C, 0xE8B20001,
+		0x81C, 0xE7B40001,
+		0x81C, 0xE6B60001,
+		0x81C, 0xE5B80001,
+		0x81C, 0xE4BA0001,
+		0x81C, 0xE3BC0001,
+		0x81C, 0xA8BE0001,
+		0x81C, 0xA7C00001,
+		0x81C, 0xA6C20001,
+		0x81C, 0xA5C40001,
+		0x81C, 0xA4C60001,
+		0x81C, 0xA3C80001,
+		0x81C, 0xA2CA0001,
+		0x81C, 0xA1CC0001,
+		0x81C, 0x68CE0001,
+		0x81C, 0x67D00001,
+		0x81C, 0x66D20001,
+		0x81C, 0x65D40001,
+		0x81C, 0x64D60001,
+		0x81C, 0x47D80001,
+		0x81C, 0x46DA0001,
+		0x81C, 0x45DC0001,
+		0x81C, 0x44DE0001,
+		0x81C, 0x43E00001,
+		0x81C, 0x42E20001,
+		0x81C, 0x08E40001,
+		0x81C, 0x07E60001,
+		0x81C, 0x06E80001,
+		0x81C, 0x05EA0001,
+		0x81C, 0x04EC0001,
+		0x81C, 0x03EE0001,
+		0x81C, 0x02F00001,
+		0x81C, 0x01F20001,
+		0x81C, 0x01F40001,
+		0x81C, 0x01F60001,
+		0x81C, 0x01F80001,
+		0x81C, 0x01FA0001,
+		0x81C, 0x01FC0001,
+		0x81C, 0x01FE0001,
+	0xFF0F0180, 0xDEAD,
+		0xC50, 0x00000022,
+		0xC50, 0x00000020,
+		0xE50, 0x00000022,
+		0xE50, 0x00000020,
+
+};
+
+u32 RTL8821AE_AGC_TAB_ARRAY[] =3D {
+		0x81C, 0xBF000001,
+		0x81C, 0xBF020001,
+		0x81C, 0xBF040001,
+		0x81C, 0xBF060001,
+		0x81C, 0xBE080001,
+		0x81C, 0xBD0A0001,
+		0x81C, 0xBC0C0001,
+		0x81C, 0xBA0E0001,
+		0x81C, 0xB9100001,
+		0x81C, 0xB8120001,
+		0x81C, 0xB7140001,
+		0x81C, 0xB6160001,
+		0x81C, 0xB5180001,
+		0x81C, 0xB41A0001,
+		0x81C, 0xB31C0001,
+		0x81C, 0xB21E0001,
+		0x81C, 0xB1200001,
+		0x81C, 0xB0220001,
+		0x81C, 0xAF240001,
+		0x81C, 0xAE260001,
+		0x81C, 0xAD280001,
+		0x81C, 0xAC2A0001,
+		0x81C, 0xAB2C0001,
+		0x81C, 0xAA2E0001,
+		0x81C, 0xA9300001,
+		0x81C, 0xA8320001,
+		0x81C, 0xA7340001,
+		0x81C, 0xA6360001,
+		0x81C, 0xA5380001,
+		0x81C, 0xA43A0001,
+		0x81C, 0xA33C0001,
+		0x81C, 0x673E0001,
+		0x81C, 0x66400001,
+		0x81C, 0x65420001,
+		0x81C, 0x64440001,
+		0x81C, 0x63460001,
+		0x81C, 0x62480001,
+		0x81C, 0x614A0001,
+		0x81C, 0x474C0001,
+		0x81C, 0x464E0001,
+		0x81C, 0x45500001,
+		0x81C, 0x44520001,
+		0x81C, 0x43540001,
+		0x81C, 0x42560001,
+		0x81C, 0x41580001,
+		0x81C, 0x285A0001,
+		0x81C, 0x275C0001,
+		0x81C, 0x265E0001,
+		0x81C, 0x25600001,
+		0x81C, 0x24620001,
+		0x81C, 0x0A640001,
+		0x81C, 0x09660001,
+		0x81C, 0x08680001,
+		0x81C, 0x076A0001,
+		0x81C, 0x066C0001,
+		0x81C, 0x056E0001,
+		0x81C, 0x04700001,
+		0x81C, 0x03720001,
+		0x81C, 0x02740001,
+		0x81C, 0x01760001,
+		0x81C, 0x01780001,
+		0x81C, 0x017A0001,
+		0x81C, 0x017C0001,
+		0x81C, 0x017E0001,
+	0xFF0F02C0, 0xABCD,
+		0x81C, 0xFB000101,
+		0x81C, 0xFA020101,
+		0x81C, 0xF9040101,
+		0x81C, 0xF8060101,
+		0x81C, 0xF7080101,
+		0x81C, 0xF60A0101,
+		0x81C, 0xF50C0101,
+		0x81C, 0xF40E0101,
+		0x81C, 0xF3100101,
+		0x81C, 0xF2120101,
+		0x81C, 0xF1140101,
+		0x81C, 0xF0160101,
+		0x81C, 0xEF180101,
+		0x81C, 0xEE1A0101,
+		0x81C, 0xED1C0101,
+		0x81C, 0xEC1E0101,
+		0x81C, 0xEB200101,
+		0x81C, 0xEA220101,
+		0x81C, 0xE9240101,
+		0x81C, 0xE8260101,
+		0x81C, 0xE7280101,
+		0x81C, 0xE62A0101,
+		0x81C, 0xE52C0101,
+		0x81C, 0xE42E0101,
+		0x81C, 0xE3300101,
+		0x81C, 0xA5320101,
+		0x81C, 0xA4340101,
+		0x81C, 0xA3360101,
+		0x81C, 0x87380101,
+		0x81C, 0x863A0101,
+		0x81C, 0x853C0101,
+		0x81C, 0x843E0101,
+		0x81C, 0x69400101,
+		0x81C, 0x68420101,
+		0x81C, 0x67440101,
+		0x81C, 0x66460101,
+		0x81C, 0x49480101,
+		0x81C, 0x484A0101,
+		0x81C, 0x474C0101,
+		0x81C, 0x2A4E0101,
+		0x81C, 0x29500101,
+		0x81C, 0x28520101,
+		0x81C, 0x27540101,
+		0x81C, 0x26560101,
+		0x81C, 0x25580101,
+		0x81C, 0x245A0101,
+		0x81C, 0x235C0101,
+		0x81C, 0x055E0101,
+		0x81C, 0x04600101,
+		0x81C, 0x03620101,
+		0x81C, 0x02640101,
+		0x81C, 0x01660101,
+		0x81C, 0x01680101,
+		0x81C, 0x016A0101,
+		0x81C, 0x016C0101,
+		0x81C, 0x016E0101,
+		0x81C, 0x01700101,
+		0x81C, 0x01720101,
+	0xCDCDCDCD, 0xCDCD,
+		0x81C, 0xFF000101,
+		0x81C, 0xFF020101,
+		0x81C, 0xFE040101,
+		0x81C, 0xFD060101,
+		0x81C, 0xFC080101,
+		0x81C, 0xFD0A0101,
+		0x81C, 0xFC0C0101,
+		0x81C, 0xFB0E0101,
+		0x81C, 0xFA100101,
+		0x81C, 0xF9120101,
+		0x81C, 0xF8140101,
+		0x81C, 0xF7160101,
+		0x81C, 0xF6180101,
+		0x81C, 0xF51A0101,
+		0x81C, 0xF41C0101,
+		0x81C, 0xF31E0101,
+		0x81C, 0xF2200101,
+		0x81C, 0xF1220101,
+		0x81C, 0xF0240101,
+		0x81C, 0xEF260101,
+		0x81C, 0xEE280101,
+		0x81C, 0xED2A0101,
+		0x81C, 0xEC2C0101,
+		0x81C, 0xEB2E0101,
+		0x81C, 0xEA300101,
+		0x81C, 0xE9320101,
+		0x81C, 0xE8340101,
+		0x81C, 0xE7360101,
+		0x81C, 0xE6380101,
+		0x81C, 0xE53A0101,
+		0x81C, 0xE43C0101,
+		0x81C, 0xE33E0101,
+		0x81C, 0xA5400101,
+		0x81C, 0xA4420101,
+		0x81C, 0xA3440101,
+		0x81C, 0x87460101,
+		0x81C, 0x86480101,
+		0x81C, 0x854A0101,
+		0x81C, 0x844C0101,
+		0x81C, 0x694E0101,
+		0x81C, 0x68500101,
+		0x81C, 0x67520101,
+		0x81C, 0x66540101,
+		0x81C, 0x49560101,
+		0x81C, 0x48580101,
+		0x81C, 0x475A0101,
+		0x81C, 0x2A5C0101,
+		0x81C, 0x295E0101,
+		0x81C, 0x28600101,
+		0x81C, 0x27620101,
+		0x81C, 0x26640101,
+		0x81C, 0x25660101,
+		0x81C, 0x24680101,
+		0x81C, 0x236A0101,
+		0x81C, 0x056C0101,
+		0x81C, 0x046E0101,
+		0x81C, 0x03700101,
+		0x81C, 0x02720101,
+	0xFF0F02C0, 0xDEAD,
+		0x81C, 0x01740101,
+		0x81C, 0x01760101,
+		0x81C, 0x01780101,
+		0x81C, 0x017A0101,
+		0x81C, 0x017C0101,
+		0x81C, 0x017E0101,
+		0xC50, 0x00000022,
+		0xC50, 0x00000020,
+
+};
+
+/*********************************************************************=
*********
+*                           TXPWR_LMT.TXT
+**********************************************************************=
********/
+
+u8 *RTL8812AE_TXPWR_LMT[] =3D {
+	"FCC", "2.4G", "20M", "CCK", "1T", "01", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "02", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "03", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "04", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "05", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "06", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "07", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "08", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "09", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "10", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "11", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "CCK", "1T", "14", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "01", "34",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "02", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "03", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "04", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "05", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "06", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "07", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "08", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "09", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "10", "36",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "11", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"FCC", "2.4G", "20M", "HT", "1T", "01", "34",
+	"ETSI", "2.4G", "20M", "HT", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "02", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "03", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "04", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "05", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "06", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "07", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "08", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "09", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "10", "36",
+	"ETSI", "2.4G", "20M", "HT", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "11", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "HT", "1T", "14", "63",
+	"FCC", "2.4G", "20M", "HT", "2T", "01", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "01", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "01", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "02", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "02", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "02", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "03", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "03", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "03", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "04", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "04", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "04", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "05", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "05", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "05", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "06", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "06", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "06", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "07", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "07", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "07", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "08", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "08", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "08", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "09", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "09", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "09", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "10", "34",
+	"ETSI", "2.4G", "20M", "HT", "2T", "10", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "10", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "11", "30",
+	"ETSI", "2.4G", "20M", "HT", "2T", "11", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "11", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "12", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "12", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "12", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "13", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "13", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "13", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "14", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "14", "63",
+	"MKK", "2.4G", "20M", "HT", "2T", "14", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "01", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "01", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "01", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "02", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "02", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "02", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "03", "32",
+	"ETSI", "2.4G", "40M", "HT", "1T", "03", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "03", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "04", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "04", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "04", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "05", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "05", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "05", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "06", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "06", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "06", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "07", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "07", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "07", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "08", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "08", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "08", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "09", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "09", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "09", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "10", "36",
+	"ETSI", "2.4G", "40M", "HT", "1T", "10", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "10", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "11", "32",
+	"ETSI", "2.4G", "40M", "HT", "1T", "11", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "11", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "12", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "12", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "12", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "13", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "13", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "13", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "14", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "14", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "14", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "01", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "01", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "01", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "02", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "02", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "02", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "03", "30",
+	"ETSI", "2.4G", "40M", "HT", "2T", "03", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "03", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "04", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "04", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "04", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "05", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "05", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "05", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "06", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "06", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "06", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "07", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "07", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "07", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "08", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "08", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "08", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "09", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "09", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "09", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "10", "34",
+	"ETSI", "2.4G", "40M", "HT", "2T", "10", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "10", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "11", "30",
+	"ETSI", "2.4G", "40M", "HT", "2T", "11", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "11", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "12", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "12", "32",
+	"MKK", "2.4G", "40M", "HT", "2T", "12", "32",
+	"FCC", "2.4G", "40M", "HT", "2T", "13", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "13", "32",
+	"MKK", "2.4G", "40M", "HT", "2T", "13", "32",
+	"FCC", "2.4G", "40M", "HT", "2T", "14", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "14", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "14", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "36", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "36", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "36", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "40", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "40", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "40", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "44", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "44", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "44", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "48", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "48", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "48", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "52", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "52", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "52", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "56", "34",
+	"ETSI", "5G", "20M", "OFDM", "1T", "56", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "56", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "60", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "60", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "60", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "64", "28",
+	"ETSI", "5G", "20M", "OFDM", "1T", "64", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "64", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "100", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "100", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "100", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "114", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "114", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "114", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "108", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "108", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "108", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "112", "34",
+	"ETSI", "5G", "20M", "OFDM", "1T", "112", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "112", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "116", "34",
+	"ETSI", "5G", "20M", "OFDM", "1T", "116", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "116", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "120", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "120", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "120", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "124", "34",
+	"ETSI", "5G", "20M", "OFDM", "1T", "124", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "124", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "128", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "128", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "128", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "132", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "132", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "132", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "136", "30",
+	"ETSI", "5G", "20M", "OFDM", "1T", "136", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "136", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "140", "28",
+	"ETSI", "5G", "20M", "OFDM", "1T", "140", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "140", "32",
+	"FCC", "5G", "20M", "OFDM", "1T", "149", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "149", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "149", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "153", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "153", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "153", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "157", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "157", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "157", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "161", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "161", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "161", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "165", "36",
+	"ETSI", "5G", "20M", "OFDM", "1T", "165", "32",
+	"MKK", "5G", "20M", "OFDM", "1T", "165", "63",
+	"FCC", "5G", "20M", "HT", "1T", "36", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "36", "32",
+	"MKK", "5G", "20M", "HT", "1T", "36", "32",
+	"FCC", "5G", "20M", "HT", "1T", "40", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "40", "32",
+	"MKK", "5G", "20M", "HT", "1T", "40", "32",
+	"FCC", "5G", "20M", "HT", "1T", "44", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "44", "32",
+	"MKK", "5G", "20M", "HT", "1T", "44", "32",
+	"FCC", "5G", "20M", "HT", "1T", "48", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "48", "32",
+	"MKK", "5G", "20M", "HT", "1T", "48", "32",
+	"FCC", "5G", "20M", "HT", "1T", "52", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "52", "32",
+	"MKK", "5G", "20M", "HT", "1T", "52", "32",
+	"FCC", "5G", "20M", "HT", "1T", "56", "34",
+	"ETSI", "5G", "20M", "HT", "1T", "56", "32",
+	"MKK", "5G", "20M", "HT", "1T", "56", "32",
+	"FCC", "5G", "20M", "HT", "1T", "60", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "60", "32",
+	"MKK", "5G", "20M", "HT", "1T", "60", "32",
+	"FCC", "5G", "20M", "HT", "1T", "64", "28",
+	"ETSI", "5G", "20M", "HT", "1T", "64", "32",
+	"MKK", "5G", "20M", "HT", "1T", "64", "32",
+	"FCC", "5G", "20M", "HT", "1T", "100", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "100", "32",
+	"MKK", "5G", "20M", "HT", "1T", "100", "32",
+	"FCC", "5G", "20M", "HT", "1T", "114", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "114", "32",
+	"MKK", "5G", "20M", "HT", "1T", "114", "32",
+	"FCC", "5G", "20M", "HT", "1T", "108", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "108", "32",
+	"MKK", "5G", "20M", "HT", "1T", "108", "32",
+	"FCC", "5G", "20M", "HT", "1T", "112", "34",
+	"ETSI", "5G", "20M", "HT", "1T", "112", "32",
+	"MKK", "5G", "20M", "HT", "1T", "112", "32",
+	"FCC", "5G", "20M", "HT", "1T", "116", "34",
+	"ETSI", "5G", "20M", "HT", "1T", "116", "32",
+	"MKK", "5G", "20M", "HT", "1T", "116", "32",
+	"FCC", "5G", "20M", "HT", "1T", "120", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "120", "32",
+	"MKK", "5G", "20M", "HT", "1T", "120", "32",
+	"FCC", "5G", "20M", "HT", "1T", "124", "34",
+	"ETSI", "5G", "20M", "HT", "1T", "124", "32",
+	"MKK", "5G", "20M", "HT", "1T", "124", "32",
+	"FCC", "5G", "20M", "HT", "1T", "128", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "128", "32",
+	"MKK", "5G", "20M", "HT", "1T", "128", "32",
+	"FCC", "5G", "20M", "HT", "1T", "132", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "132", "32",
+	"MKK", "5G", "20M", "HT", "1T", "132", "32",
+	"FCC", "5G", "20M", "HT", "1T", "136", "30",
+	"ETSI", "5G", "20M", "HT", "1T", "136", "32",
+	"MKK", "5G", "20M", "HT", "1T", "136", "32",
+	"FCC", "5G", "20M", "HT", "1T", "140", "28",
+	"ETSI", "5G", "20M", "HT", "1T", "140", "32",
+	"MKK", "5G", "20M", "HT", "1T", "140", "32",
+	"FCC", "5G", "20M", "HT", "1T", "149", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "149", "32",
+	"MKK", "5G", "20M", "HT", "1T", "149", "63",
+	"FCC", "5G", "20M", "HT", "1T", "153", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "153", "32",
+	"MKK", "5G", "20M", "HT", "1T", "153", "63",
+	"FCC", "5G", "20M", "HT", "1T", "157", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "157", "32",
+	"MKK", "5G", "20M", "HT", "1T", "157", "63",
+	"FCC", "5G", "20M", "HT", "1T", "161", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "161", "32",
+	"MKK", "5G", "20M", "HT", "1T", "161", "63",
+	"FCC", "5G", "20M", "HT", "1T", "165", "36",
+	"ETSI", "5G", "20M", "HT", "1T", "165", "32",
+	"MKK", "5G", "20M", "HT", "1T", "165", "63",
+	"FCC", "5G", "20M", "HT", "2T", "36", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "36", "30",
+	"MKK", "5G", "20M", "HT", "2T", "36", "30",
+	"FCC", "5G", "20M", "HT", "2T", "40", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "40", "30",
+	"MKK", "5G", "20M", "HT", "2T", "40", "30",
+	"FCC", "5G", "20M", "HT", "2T", "44", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "44", "30",
+	"MKK", "5G", "20M", "HT", "2T", "44", "30",
+	"FCC", "5G", "20M", "HT", "2T", "48", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "48", "30",
+	"MKK", "5G", "20M", "HT", "2T", "48", "30",
+	"FCC", "5G", "20M", "HT", "2T", "52", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "52", "30",
+	"MKK", "5G", "20M", "HT", "2T", "52", "30",
+	"FCC", "5G", "20M", "HT", "2T", "56", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "56", "30",
+	"MKK", "5G", "20M", "HT", "2T", "56", "30",
+	"FCC", "5G", "20M", "HT", "2T", "60", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "60", "30",
+	"MKK", "5G", "20M", "HT", "2T", "60", "30",
+	"FCC", "5G", "20M", "HT", "2T", "64", "26",
+	"ETSI", "5G", "20M", "HT", "2T", "64", "30",
+	"MKK", "5G", "20M", "HT", "2T", "64", "30",
+	"FCC", "5G", "20M", "HT", "2T", "100", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "100", "30",
+	"MKK", "5G", "20M", "HT", "2T", "100", "30",
+	"FCC", "5G", "20M", "HT", "2T", "114", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "114", "30",
+	"MKK", "5G", "20M", "HT", "2T", "114", "30",
+	"FCC", "5G", "20M", "HT", "2T", "108", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "108", "30",
+	"MKK", "5G", "20M", "HT", "2T", "108", "30",
+	"FCC", "5G", "20M", "HT", "2T", "112", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "112", "30",
+	"MKK", "5G", "20M", "HT", "2T", "112", "30",
+	"FCC", "5G", "20M", "HT", "2T", "116", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "116", "30",
+	"MKK", "5G", "20M", "HT", "2T", "116", "30",
+	"FCC", "5G", "20M", "HT", "2T", "120", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "120", "30",
+	"MKK", "5G", "20M", "HT", "2T", "120", "30",
+	"FCC", "5G", "20M", "HT", "2T", "124", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "124", "30",
+	"MKK", "5G", "20M", "HT", "2T", "124", "30",
+	"FCC", "5G", "20M", "HT", "2T", "128", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "128", "30",
+	"MKK", "5G", "20M", "HT", "2T", "128", "30",
+	"FCC", "5G", "20M", "HT", "2T", "132", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "132", "30",
+	"MKK", "5G", "20M", "HT", "2T", "132", "30",
+	"FCC", "5G", "20M", "HT", "2T", "136", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "136", "30",
+	"MKK", "5G", "20M", "HT", "2T", "136", "30",
+	"FCC", "5G", "20M", "HT", "2T", "140", "26",
+	"ETSI", "5G", "20M", "HT", "2T", "140", "30",
+	"MKK", "5G", "20M", "HT", "2T", "140", "30",
+	"FCC", "5G", "20M", "HT", "2T", "149", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "149", "30",
+	"MKK", "5G", "20M", "HT", "2T", "149", "63",
+	"FCC", "5G", "20M", "HT", "2T", "153", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "153", "30",
+	"MKK", "5G", "20M", "HT", "2T", "153", "63",
+	"FCC", "5G", "20M", "HT", "2T", "157", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "157", "30",
+	"MKK", "5G", "20M", "HT", "2T", "157", "63",
+	"FCC", "5G", "20M", "HT", "2T", "161", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "161", "30",
+	"MKK", "5G", "20M", "HT", "2T", "161", "63",
+	"FCC", "5G", "20M", "HT", "2T", "165", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "165", "30",
+	"MKK", "5G", "20M", "HT", "2T", "165", "63",
+	"FCC", "5G", "40M", "HT", "1T", "38", "30",
+	"ETSI", "5G", "40M", "HT", "1T", "38", "32",
+	"MKK", "5G", "40M", "HT", "1T", "38", "32",
+	"FCC", "5G", "40M", "HT", "1T", "46", "30",
+	"ETSI", "5G", "40M", "HT", "1T", "46", "32",
+	"MKK", "5G", "40M", "HT", "1T", "46", "32",
+	"FCC", "5G", "40M", "HT", "1T", "54", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "54", "32",
+	"MKK", "5G", "40M", "HT", "1T", "54", "32",
+	"FCC", "5G", "40M", "HT", "1T", "62", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "62", "32",
+	"MKK", "5G", "40M", "HT", "1T", "62", "32",
+	"FCC", "5G", "40M", "HT", "1T", "102", "28",
+	"ETSI", "5G", "40M", "HT", "1T", "102", "32",
+	"MKK", "5G", "40M", "HT", "1T", "102", "32",
+	"FCC", "5G", "40M", "HT", "1T", "110", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "110", "32",
+	"MKK", "5G", "40M", "HT", "1T", "110", "32",
+	"FCC", "5G", "40M", "HT", "1T", "118", "36",
+	"ETSI", "5G", "40M", "HT", "1T", "118", "32",
+	"MKK", "5G", "40M", "HT", "1T", "118", "32",
+	"FCC", "5G", "40M", "HT", "1T", "126", "34",
+	"ETSI", "5G", "40M", "HT", "1T", "126", "32",
+	"MKK", "5G", "40M", "HT", "1T", "126", "32",
+	"FCC", "5G", "40M", "HT", "1T", "134", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "134", "32",
+	"MKK", "5G", "40M", "HT", "1T", "134", "32",
+	"FCC", "5G", "40M", "HT", "1T", "151", "36",
+	"ETSI", "5G", "40M", "HT", "1T", "151", "32",
+	"MKK", "5G", "40M", "HT", "1T", "151", "63",
+	"FCC", "5G", "40M", "HT", "1T", "159", "36",
+	"ETSI", "5G", "40M", "HT", "1T", "159", "32",
+	"MKK", "5G", "40M", "HT", "1T", "159", "63",
+	"FCC", "5G", "40M", "HT", "2T", "38", "28",
+	"ETSI", "5G", "40M", "HT", "2T", "38", "30",
+	"MKK", "5G", "40M", "HT", "2T", "38", "30",
+	"FCC", "5G", "40M", "HT", "2T", "46", "28",
+	"ETSI", "5G", "40M", "HT", "2T", "46", "30",
+	"MKK", "5G", "40M", "HT", "2T", "46", "30",
+	"FCC", "5G", "40M", "HT", "2T", "54", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "54", "30",
+	"MKK", "5G", "40M", "HT", "2T", "54", "30",
+	"FCC", "5G", "40M", "HT", "2T", "62", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "62", "30",
+	"MKK", "5G", "40M", "HT", "2T", "62", "30",
+	"FCC", "5G", "40M", "HT", "2T", "102", "26",
+	"ETSI", "5G", "40M", "HT", "2T", "102", "30",
+	"MKK", "5G", "40M", "HT", "2T", "102", "30",
+	"FCC", "5G", "40M", "HT", "2T", "110", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "110", "30",
+	"MKK", "5G", "40M", "HT", "2T", "110", "30",
+	"FCC", "5G", "40M", "HT", "2T", "118", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "118", "30",
+	"MKK", "5G", "40M", "HT", "2T", "118", "30",
+	"FCC", "5G", "40M", "HT", "2T", "126", "32",
+	"ETSI", "5G", "40M", "HT", "2T", "126", "30",
+	"MKK", "5G", "40M", "HT", "2T", "126", "30",
+	"FCC", "5G", "40M", "HT", "2T", "134", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "134", "30",
+	"MKK", "5G", "40M", "HT", "2T", "134", "30",
+	"FCC", "5G", "40M", "HT", "2T", "151", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "151", "30",
+	"MKK", "5G", "40M", "HT", "2T", "151", "63",
+	"FCC", "5G", "40M", "HT", "2T", "159", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "159", "30",
+	"MKK", "5G", "40M", "HT", "2T", "159", "63",
+	"FCC", "5G", "80M", "VHT", "1T", "42", "30",
+	"ETSI", "5G", "80M", "VHT", "1T", "42", "32",
+	"MKK", "5G", "80M", "VHT", "1T", "42", "32",
+	"FCC", "5G", "80M", "VHT", "1T", "58", "28",
+	"ETSI", "5G", "80M", "VHT", "1T", "58", "32",
+	"MKK", "5G", "80M", "VHT", "1T", "58", "32",
+	"FCC", "5G", "80M", "VHT", "1T", "106", "30",
+	"ETSI", "5G", "80M", "VHT", "1T", "106", "32",
+	"MKK", "5G", "80M", "VHT", "1T", "106", "32",
+	"FCC", "5G", "80M", "VHT", "1T", "122", "34",
+	"ETSI", "5G", "80M", "VHT", "1T", "122", "32",
+	"MKK", "5G", "80M", "VHT", "1T", "122", "32",
+	"FCC", "5G", "80M", "VHT", "1T", "155", "36",
+	"ETSI", "5G", "80M", "VHT", "1T", "155", "32",
+	"MKK", "5G", "80M", "VHT", "1T", "155", "63",
+	"FCC", "5G", "80M", "VHT", "2T", "42", "28",
+	"ETSI", "5G", "80M", "VHT", "2T", "42", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "42", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "58", "26",
+	"ETSI", "5G", "80M", "VHT", "2T", "58", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "58", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "106", "28",
+	"ETSI", "5G", "80M", "VHT", "2T", "106", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "106", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "122", "32",
+	"ETSI", "5G", "80M", "VHT", "2T", "122", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "122", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "155", "34",
+	"ETSI", "5G", "80M", "VHT", "2T", "155", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "155", "63"
+};
+
+u8 *RTL8821AE_TXPWR_LMT[] =3D {
+	"FCC", "2.4G", "20M", "CCK", "1T", "01", "32",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "02", "32",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "03", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "04", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "05", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "06", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "07", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "08", "36",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "09", "32",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "10", "32",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "11", "32",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "CCK", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "CCK", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "CCK", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "CCK", "1T", "14", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "01", "30",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "02", "30",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "03", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "04", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "05", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "06", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "07", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "08", "32",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "09", "30",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "10", "30",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "11", "30",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "OFDM", "1T", "14", "63",
+	"FCC", "2.4G", "20M", "HT", "1T", "01", "26",
+	"ETSI", "2.4G", "20M", "HT", "1T", "01", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "01", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "02", "26",
+	"ETSI", "2.4G", "20M", "HT", "1T", "02", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "02", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "03", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "03", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "03", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "04", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "04", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "04", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "05", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "05", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "05", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "06", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "06", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "06", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "07", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "07", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "07", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "08", "32",
+	"ETSI", "2.4G", "20M", "HT", "1T", "08", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "08", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "09", "26",
+	"ETSI", "2.4G", "20M", "HT", "1T", "09", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "09", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "10", "26",
+	"ETSI", "2.4G", "20M", "HT", "1T", "10", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "10", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "11", "26",
+	"ETSI", "2.4G", "20M", "HT", "1T", "11", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "11", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "12", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "12", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "12", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "13", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "13", "32",
+	"MKK", "2.4G", "20M", "HT", "1T", "13", "32",
+	"FCC", "2.4G", "20M", "HT", "1T", "14", "63",
+	"ETSI", "2.4G", "20M", "HT", "1T", "14", "63",
+	"MKK", "2.4G", "20M", "HT", "1T", "14", "63",
+	"FCC", "2.4G", "20M", "HT", "2T", "01", "30",
+	"ETSI", "2.4G", "20M", "HT", "2T", "01", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "01", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "02", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "02", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "02", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "03", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "03", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "03", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "04", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "04", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "04", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "05", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "05", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "05", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "06", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "06", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "06", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "07", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "07", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "07", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "08", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "08", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "08", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "09", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "09", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "09", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "10", "32",
+	"ETSI", "2.4G", "20M", "HT", "2T", "10", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "10", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "11", "30",
+	"ETSI", "2.4G", "20M", "HT", "2T", "11", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "11", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "12", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "12", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "12", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "13", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "13", "32",
+	"MKK", "2.4G", "20M", "HT", "2T", "13", "32",
+	"FCC", "2.4G", "20M", "HT", "2T", "14", "63",
+	"ETSI", "2.4G", "20M", "HT", "2T", "14", "63",
+	"MKK", "2.4G", "20M", "HT", "2T", "14", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "01", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "01", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "01", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "02", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "02", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "02", "63",
+	"FCC", "2.4G", "40M", "HT", "1T", "03", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "03", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "03", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "04", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "04", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "04", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "05", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "05", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "05", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "06", "32",
+	"ETSI", "2.4G", "40M", "HT", "1T", "06", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "06", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "07", "32",
+	"ETSI", "2.4G", "40M", "HT", "1T", "07", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "07", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "08", "32",
+	"ETSI", "2.4G", "40M", "HT", "1T", "08", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "08", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "09", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "09", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "09", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "10", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "10", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "10", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "11", "26",
+	"ETSI", "2.4G", "40M", "HT", "1T", "11", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "11", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "12", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "12", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "12", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "13", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "13", "32",
+	"MKK", "2.4G", "40M", "HT", "1T", "13", "32",
+	"FCC", "2.4G", "40M", "HT", "1T", "14", "63",
+	"ETSI", "2.4G", "40M", "HT", "1T", "14", "63",
+	"MKK", "2.4G", "40M", "HT", "1T", "14", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "01", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "01", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "01", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "02", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "02", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "02", "63",
+	"FCC", "2.4G", "40M", "HT", "2T", "03", "30",
+	"ETSI", "2.4G", "40M", "HT", "2T", "03", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "03", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "04", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "04", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "04", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "05", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "05", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "05", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "06", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "06", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "06", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "07", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "07", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "07", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "08", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "08", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "08", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "09", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "09", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "09", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "10", "32",
+	"ETSI", "2.4G", "40M", "HT", "2T", "10", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "10", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "11", "30",
+	"ETSI", "2.4G", "40M", "HT", "2T", "11", "30",
+	"MKK", "2.4G", "40M", "HT", "2T", "11", "30",
+	"FCC", "2.4G", "40M", "HT", "2T", "12", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "12", "32",
+	"MKK", "2.4G", "40M", "HT", "2T", "12", "32",
+	"FCC", "2.4G", "40M", "HT", "2T", "13", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "13", "32",
+	"MKK", "2.4G", "40M", "HT", "2T", "13", "32",
+	"FCC", "2.4G", "40M", "HT", "2T", "14", "63",
+	"ETSI", "2.4G", "40M", "HT", "2T", "14", "63",
+	"MKK", "2.4G", "40M", "HT", "2T", "14", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "36", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "36", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "36", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "40", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "40", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "40", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "44", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "44", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "44", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "48", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "48", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "48", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "52", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "52", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "52", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "56", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "56", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "56", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "60", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "60", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "60", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "64", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "64", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "64", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "100", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "100", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "100", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "114", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "114", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "114", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "108", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "108", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "108", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "112", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "112", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "112", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "116", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "116", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "116", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "120", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "120", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "120", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "124", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "124", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "124", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "128", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "128", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "128", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "132", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "132", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "132", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "136", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "136", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "136", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "140", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "140", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "140", "30",
+	"FCC", "5G", "20M", "OFDM", "1T", "149", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "149", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "149", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "153", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "153", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "153", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "157", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "157", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "157", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "161", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "161", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "161", "63",
+	"FCC", "5G", "20M", "OFDM", "1T", "165", "32",
+	"ETSI", "5G", "20M", "OFDM", "1T", "165", "30",
+	"MKK", "5G", "20M", "OFDM", "1T", "165", "63",
+	"FCC", "5G", "20M", "HT", "1T", "36", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "36", "30",
+	"MKK", "5G", "20M", "HT", "1T", "36", "30",
+	"FCC", "5G", "20M", "HT", "1T", "40", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "40", "30",
+	"MKK", "5G", "20M", "HT", "1T", "40", "30",
+	"FCC", "5G", "20M", "HT", "1T", "44", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "44", "30",
+	"MKK", "5G", "20M", "HT", "1T", "44", "30",
+	"FCC", "5G", "20M", "HT", "1T", "48", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "48", "30",
+	"MKK", "5G", "20M", "HT", "1T", "48", "30",
+	"FCC", "5G", "20M", "HT", "1T", "52", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "52", "30",
+	"MKK", "5G", "20M", "HT", "1T", "52", "30",
+	"FCC", "5G", "20M", "HT", "1T", "56", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "56", "30",
+	"MKK", "5G", "20M", "HT", "1T", "56", "30",
+	"FCC", "5G", "20M", "HT", "1T", "60", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "60", "30",
+	"MKK", "5G", "20M", "HT", "1T", "60", "30",
+	"FCC", "5G", "20M", "HT", "1T", "64", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "64", "30",
+	"MKK", "5G", "20M", "HT", "1T", "64", "30",
+	"FCC", "5G", "20M", "HT", "1T", "100", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "100", "30",
+	"MKK", "5G", "20M", "HT", "1T", "100", "30",
+	"FCC", "5G", "20M", "HT", "1T", "114", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "114", "30",
+	"MKK", "5G", "20M", "HT", "1T", "114", "30",
+	"FCC", "5G", "20M", "HT", "1T", "108", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "108", "30",
+	"MKK", "5G", "20M", "HT", "1T", "108", "30",
+	"FCC", "5G", "20M", "HT", "1T", "112", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "112", "30",
+	"MKK", "5G", "20M", "HT", "1T", "112", "30",
+	"FCC", "5G", "20M", "HT", "1T", "116", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "116", "30",
+	"MKK", "5G", "20M", "HT", "1T", "116", "30",
+	"FCC", "5G", "20M", "HT", "1T", "120", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "120", "30",
+	"MKK", "5G", "20M", "HT", "1T", "120", "30",
+	"FCC", "5G", "20M", "HT", "1T", "124", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "124", "30",
+	"MKK", "5G", "20M", "HT", "1T", "124", "30",
+	"FCC", "5G", "20M", "HT", "1T", "128", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "128", "30",
+	"MKK", "5G", "20M", "HT", "1T", "128", "30",
+	"FCC", "5G", "20M", "HT", "1T", "132", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "132", "30",
+	"MKK", "5G", "20M", "HT", "1T", "132", "30",
+	"FCC", "5G", "20M", "HT", "1T", "136", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "136", "30",
+	"MKK", "5G", "20M", "HT", "1T", "136", "30",
+	"FCC", "5G", "20M", "HT", "1T", "140", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "140", "30",
+	"MKK", "5G", "20M", "HT", "1T", "140", "30",
+	"FCC", "5G", "20M", "HT", "1T", "149", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "149", "30",
+	"MKK", "5G", "20M", "HT", "1T", "149", "63",
+	"FCC", "5G", "20M", "HT", "1T", "153", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "153", "30",
+	"MKK", "5G", "20M", "HT", "1T", "153", "63",
+	"FCC", "5G", "20M", "HT", "1T", "157", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "157", "30",
+	"MKK", "5G", "20M", "HT", "1T", "157", "63",
+	"FCC", "5G", "20M", "HT", "1T", "161", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "161", "30",
+	"MKK", "5G", "20M", "HT", "1T", "161", "63",
+	"FCC", "5G", "20M", "HT", "1T", "165", "32",
+	"ETSI", "5G", "20M", "HT", "1T", "165", "30",
+	"MKK", "5G", "20M", "HT", "1T", "165", "63",
+	"FCC", "5G", "20M", "HT", "2T", "36", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "36", "30",
+	"MKK", "5G", "20M", "HT", "2T", "36", "30",
+	"FCC", "5G", "20M", "HT", "2T", "40", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "40", "30",
+	"MKK", "5G", "20M", "HT", "2T", "40", "30",
+	"FCC", "5G", "20M", "HT", "2T", "44", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "44", "30",
+	"MKK", "5G", "20M", "HT", "2T", "44", "30",
+	"FCC", "5G", "20M", "HT", "2T", "48", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "48", "30",
+	"MKK", "5G", "20M", "HT", "2T", "48", "30",
+	"FCC", "5G", "20M", "HT", "2T", "52", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "52", "30",
+	"MKK", "5G", "20M", "HT", "2T", "52", "30",
+	"FCC", "5G", "20M", "HT", "2T", "56", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "56", "30",
+	"MKK", "5G", "20M", "HT", "2T", "56", "30",
+	"FCC", "5G", "20M", "HT", "2T", "60", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "60", "30",
+	"MKK", "5G", "20M", "HT", "2T", "60", "30",
+	"FCC", "5G", "20M", "HT", "2T", "64", "26",
+	"ETSI", "5G", "20M", "HT", "2T", "64", "30",
+	"MKK", "5G", "20M", "HT", "2T", "64", "30",
+	"FCC", "5G", "20M", "HT", "2T", "100", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "100", "30",
+	"MKK", "5G", "20M", "HT", "2T", "100", "30",
+	"FCC", "5G", "20M", "HT", "2T", "114", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "114", "30",
+	"MKK", "5G", "20M", "HT", "2T", "114", "30",
+	"FCC", "5G", "20M", "HT", "2T", "108", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "108", "30",
+	"MKK", "5G", "20M", "HT", "2T", "108", "30",
+	"FCC", "5G", "20M", "HT", "2T", "112", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "112", "30",
+	"MKK", "5G", "20M", "HT", "2T", "112", "30",
+	"FCC", "5G", "20M", "HT", "2T", "116", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "116", "30",
+	"MKK", "5G", "20M", "HT", "2T", "116", "30",
+	"FCC", "5G", "20M", "HT", "2T", "120", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "120", "30",
+	"MKK", "5G", "20M", "HT", "2T", "120", "30",
+	"FCC", "5G", "20M", "HT", "2T", "124", "32",
+	"ETSI", "5G", "20M", "HT", "2T", "124", "30",
+	"MKK", "5G", "20M", "HT", "2T", "124", "30",
+	"FCC", "5G", "20M", "HT", "2T", "128", "30",
+	"ETSI", "5G", "20M", "HT", "2T", "128", "30",
+	"MKK", "5G", "20M", "HT", "2T", "128", "30",
+	"FCC", "5G", "20M", "HT", "2T", "132", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "132", "30",
+	"MKK", "5G", "20M", "HT", "2T", "132", "30",
+	"FCC", "5G", "20M", "HT", "2T", "136", "28",
+	"ETSI", "5G", "20M", "HT", "2T", "136", "30",
+	"MKK", "5G", "20M", "HT", "2T", "136", "30",
+	"FCC", "5G", "20M", "HT", "2T", "140", "26",
+	"ETSI", "5G", "20M", "HT", "2T", "140", "30",
+	"MKK", "5G", "20M", "HT", "2T", "140", "30",
+	"FCC", "5G", "20M", "HT", "2T", "149", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "149", "30",
+	"MKK", "5G", "20M", "HT", "2T", "149", "63",
+	"FCC", "5G", "20M", "HT", "2T", "153", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "153", "30",
+	"MKK", "5G", "20M", "HT", "2T", "153", "63",
+	"FCC", "5G", "20M", "HT", "2T", "157", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "157", "30",
+	"MKK", "5G", "20M", "HT", "2T", "157", "63",
+	"FCC", "5G", "20M", "HT", "2T", "161", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "161", "30",
+	"MKK", "5G", "20M", "HT", "2T", "161", "63",
+	"FCC", "5G", "20M", "HT", "2T", "165", "34",
+	"ETSI", "5G", "20M", "HT", "2T", "165", "30",
+	"MKK", "5G", "20M", "HT", "2T", "165", "63",
+	"FCC", "5G", "40M", "HT", "1T", "38", "26",
+	"ETSI", "5G", "40M", "HT", "1T", "38", "30",
+	"MKK", "5G", "40M", "HT", "1T", "38", "30",
+	"FCC", "5G", "40M", "HT", "1T", "46", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "46", "30",
+	"MKK", "5G", "40M", "HT", "1T", "46", "30",
+	"FCC", "5G", "40M", "HT", "1T", "54", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "54", "30",
+	"MKK", "5G", "40M", "HT", "1T", "54", "30",
+	"FCC", "5G", "40M", "HT", "1T", "62", "24",
+	"ETSI", "5G", "40M", "HT", "1T", "62", "30",
+	"MKK", "5G", "40M", "HT", "1T", "62", "30",
+	"FCC", "5G", "40M", "HT", "1T", "102", "24",
+	"ETSI", "5G", "40M", "HT", "1T", "102", "30",
+	"MKK", "5G", "40M", "HT", "1T", "102", "30",
+	"FCC", "5G", "40M", "HT", "1T", "110", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "110", "30",
+	"MKK", "5G", "40M", "HT", "1T", "110", "30",
+	"FCC", "5G", "40M", "HT", "1T", "118", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "118", "30",
+	"MKK", "5G", "40M", "HT", "1T", "118", "30",
+	"FCC", "5G", "40M", "HT", "1T", "126", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "126", "30",
+	"MKK", "5G", "40M", "HT", "1T", "126", "30",
+	"FCC", "5G", "40M", "HT", "1T", "134", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "134", "30",
+	"MKK", "5G", "40M", "HT", "1T", "134", "30",
+	"FCC", "5G", "40M", "HT", "1T", "151", "30",
+	"ETSI", "5G", "40M", "HT", "1T", "151", "30",
+	"MKK", "5G", "40M", "HT", "1T", "151", "63",
+	"FCC", "5G", "40M", "HT", "1T", "159", "32",
+	"ETSI", "5G", "40M", "HT", "1T", "159", "30",
+	"MKK", "5G", "40M", "HT", "1T", "159", "63",
+	"FCC", "5G", "40M", "HT", "2T", "38", "28",
+	"ETSI", "5G", "40M", "HT", "2T", "38", "30",
+	"MKK", "5G", "40M", "HT", "2T", "38", "30",
+	"FCC", "5G", "40M", "HT", "2T", "46", "28",
+	"ETSI", "5G", "40M", "HT", "2T", "46", "30",
+	"MKK", "5G", "40M", "HT", "2T", "46", "30",
+	"FCC", "5G", "40M", "HT", "2T", "54", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "54", "30",
+	"MKK", "5G", "40M", "HT", "2T", "54", "30",
+	"FCC", "5G", "40M", "HT", "2T", "62", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "62", "30",
+	"MKK", "5G", "40M", "HT", "2T", "62", "30",
+	"FCC", "5G", "40M", "HT", "2T", "102", "26",
+	"ETSI", "5G", "40M", "HT", "2T", "102", "30",
+	"MKK", "5G", "40M", "HT", "2T", "102", "30",
+	"FCC", "5G", "40M", "HT", "2T", "110", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "110", "30",
+	"MKK", "5G", "40M", "HT", "2T", "110", "30",
+	"FCC", "5G", "40M", "HT", "2T", "118", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "118", "30",
+	"MKK", "5G", "40M", "HT", "2T", "118", "30",
+	"FCC", "5G", "40M", "HT", "2T", "126", "32",
+	"ETSI", "5G", "40M", "HT", "2T", "126", "30",
+	"MKK", "5G", "40M", "HT", "2T", "126", "30",
+	"FCC", "5G", "40M", "HT", "2T", "134", "30",
+	"ETSI", "5G", "40M", "HT", "2T", "134", "30",
+	"MKK", "5G", "40M", "HT", "2T", "134", "30",
+	"FCC", "5G", "40M", "HT", "2T", "151", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "151", "30",
+	"MKK", "5G", "40M", "HT", "2T", "151", "63",
+	"FCC", "5G", "40M", "HT", "2T", "159", "34",
+	"ETSI", "5G", "40M", "HT", "2T", "159", "30",
+	"MKK", "5G", "40M", "HT", "2T", "159", "63",
+	"FCC", "5G", "80M", "VHT", "1T", "42", "22",
+	"ETSI", "5G", "80M", "VHT", "1T", "42", "30",
+	"MKK", "5G", "80M", "VHT", "1T", "42", "30",
+	"FCC", "5G", "80M", "VHT", "1T", "58", "20",
+	"ETSI", "5G", "80M", "VHT", "1T", "58", "30",
+	"MKK", "5G", "80M", "VHT", "1T", "58", "30",
+	"FCC", "5G", "80M", "VHT", "1T", "106", "20",
+	"ETSI", "5G", "80M", "VHT", "1T", "106", "30",
+	"MKK", "5G", "80M", "VHT", "1T", "106", "30",
+	"FCC", "5G", "80M", "VHT", "1T", "122", "20",
+	"ETSI", "5G", "80M", "VHT", "1T", "122", "30",
+	"MKK", "5G", "80M", "VHT", "1T", "122", "30",
+	"FCC", "5G", "80M", "VHT", "1T", "155", "28",
+	"ETSI", "5G", "80M", "VHT", "1T", "155", "30",
+	"MKK", "5G", "80M", "VHT", "1T", "155", "63",
+	"FCC", "5G", "80M", "VHT", "2T", "42", "28",
+	"ETSI", "5G", "80M", "VHT", "2T", "42", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "42", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "58", "26",
+	"ETSI", "5G", "80M", "VHT", "2T", "58", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "58", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "106", "28",
+	"ETSI", "5G", "80M", "VHT", "2T", "106", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "106", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "122", "32",
+	"ETSI", "5G", "80M", "VHT", "2T", "122", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "122", "30",
+	"FCC", "5G", "80M", "VHT", "2T", "155", "34",
+	"ETSI", "5G", "80M", "VHT", "2T", "155", "30",
+	"MKK", "5G", "80M", "VHT", "2T", "155", "63"
+};
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/table.h b/drivers/n=
et/wireless/rtlwifi/rtl8821ae/table.h
new file mode 100644
index 0000000..24bcff6
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/table.h
@@ -0,0 +1,60 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_TABLE__H_
+#define __RTL8821AE_TABLE__H_
+
+#include <linux/types.h>
+#define  RTL8821AEPHY_REG_1TARRAYLEN	344
+extern u32 RTL8821AE_PHY_REG_ARRAY[];
+#define  RTL8812AEPHY_REG_1TARRAYLEN	490
+extern u32 RTL8812AE_PHY_REG_ARRAY[];
+#define RTL8821AEPHY_REG_ARRAY_PGLEN	90
+extern u32 RTL8821AE_PHY_REG_ARRAY_PG[];
+#define RTL8812AEPHY_REG_ARRAY_PGLEN	276
+extern u32 RTL8812AE_PHY_REG_ARRAY_PG[];
+/* #define	RTL8723BE_RADIOA_1TARRAYLEN	206 */
+/* extern u8 *RTL8821AE_TXPWR_LMT_ARRAY[]; */
+#define	RTL8812AE_RADIOA_1TARRAYLEN	1264
+extern u32 RTL8812AE_RADIOA_ARRAY[];
+#define	RTL8812AE_RADIOB_1TARRAYLEN	1240
+extern u32 RTL8812AE_RADIOB_ARRAY[];
+#define	RTL8821AE_RADIOA_1TARRAYLEN	1176
+extern u32 RTL8821AE_RADIOA_ARRAY[];
+#define RTL8821AEMAC_1T_ARRAYLEN		194
+extern u32 RTL8821AE_MAC_REG_ARRAY[];
+#define RTL8812AEMAC_1T_ARRAYLEN		214
+extern u32 RTL8812AE_MAC_REG_ARRAY[];
+#define RTL8821AEAGCTAB_1TARRAYLEN		382
+extern u32 RTL8821AE_AGC_TAB_ARRAY[];
+#define RTL8812AEAGCTAB_1TARRAYLEN		1312
+extern u32 RTL8812AE_AGC_TAB_ARRAY[];
+#define RTL8812AE_TXPWR_LMT_ARRAY_LEN		3948
+extern u8 *RTL8812AE_TXPWR_LMT[];
+#define RTL8821AE_TXPWR_LMT_ARRAY_LEN		3948
+extern u8 *RTL8821AE_TXPWR_LMT[];
+#endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c b/drivers/net=
/wireless/rtlwifi/rtl8821ae/trx.c
new file mode 100644
index 0000000..7ece0ef
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.c
@@ -0,0 +1,1243 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "../stats.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "trx.h"
+#include "led.h"
+#include "dm.h"
+#include "phy.h"
+#include "fw.h"
+
+static u8 _rtl8821ae_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw=
_queue)
+{
+	__le16 fc =3D rtl_get_fc(skb);
+
+	if (unlikely(ieee80211_is_beacon(fc)))
+		return QSLT_BEACON;
+	if (ieee80211_is_mgmt(fc) || ieee80211_is_ctl(fc))
+		return QSLT_MGNT;
+
+	return skb->priority;
+}
+
+/* mac80211's rate_idx is like this:
+ *
+ * 2.4G band:rx_status->band =3D=3D IEEE80211_BAND_2GHZ
+ *
+ * B/G rate:
+ * (rx_status->flag & RX_FLAG_HT) =3D 0,
+ * DESC_RATE1M-->DESC_RATE54M =3D=3D> idx is 0-->11,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) =3D 1,
+ * DESC_RATEMCS0-->DESC_RATEMCS15 =3D=3D> idx is 0-->15
+ *
+ * 5G band:rx_status->band =3D=3D IEEE80211_BAND_5GHZ
+ * A rate:
+ * (rx_status->flag & RX_FLAG_HT) =3D 0,
+ * DESC_RATE6M-->DESC_RATE54M =3D=3D> idx is 0-->7,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) =3D 1,
+ * DESC_RATEMCS0-->DESC_RATEMCS15 =3D=3D> idx is 0-->15
+ */
+static int _rtl8821ae_rate_mapping(struct ieee80211_hw *hw,
+				   bool isht, bool isvht, u8 desc_rate)
+{
+	int rate_idx;
+
+	if (!isht) {
+		if (IEEE80211_BAND_2GHZ =3D=3D hw->conf.chandef.chan->band) {
+			switch (desc_rate) {
+			case DESC_RATE1M:
+				rate_idx =3D 0;
+				break;
+			case DESC_RATE2M:
+				rate_idx =3D 1;
+				break;
+			case DESC_RATE5_5M:
+				rate_idx =3D 2;
+				break;
+			case DESC_RATE11M:
+				rate_idx =3D 3;
+				break;
+			case DESC_RATE6M:
+				rate_idx =3D 4;
+				break;
+			case DESC_RATE9M:
+				rate_idx =3D 5;
+				break;
+			case DESC_RATE12M:
+				rate_idx =3D 6;
+				break;
+			case DESC_RATE18M:
+				rate_idx =3D 7;
+				break;
+			case DESC_RATE24M:
+				rate_idx =3D 8;
+				break;
+			case DESC_RATE36M:
+				rate_idx =3D 9;
+				break;
+			case DESC_RATE48M:
+				rate_idx =3D 10;
+				break;
+			case DESC_RATE54M:
+				rate_idx =3D 11;
+				break;
+			default:
+				rate_idx =3D 0;
+				break;
+			}
+		} else {
+			switch (desc_rate) {
+			case DESC_RATE6M:
+				rate_idx =3D 0;
+				break;
+			case DESC_RATE9M:
+				rate_idx =3D 1;
+				break;
+			case DESC_RATE12M:
+				rate_idx =3D 2;
+				break;
+			case DESC_RATE18M:
+				rate_idx =3D 3;
+				break;
+			case DESC_RATE24M:
+				rate_idx =3D 4;
+				break;
+			case DESC_RATE36M:
+				rate_idx =3D 5;
+				break;
+			case DESC_RATE48M:
+				rate_idx =3D 6;
+				break;
+			case DESC_RATE54M:
+				rate_idx =3D 7;
+				break;
+			default:
+				rate_idx =3D 0;
+				break;
+			}
+		}
+	} else {
+		switch (desc_rate) {
+		case DESC_RATEMCS0:
+			rate_idx =3D 0;
+			break;
+		case DESC_RATEMCS1:
+			rate_idx =3D 1;
+			break;
+		case DESC_RATEMCS2:
+			rate_idx =3D 2;
+			break;
+		case DESC_RATEMCS3:
+			rate_idx =3D 3;
+			break;
+		case DESC_RATEMCS4:
+			rate_idx =3D 4;
+			break;
+		case DESC_RATEMCS5:
+			rate_idx =3D 5;
+			break;
+		case DESC_RATEMCS6:
+			rate_idx =3D 6;
+			break;
+		case DESC_RATEMCS7:
+			rate_idx =3D 7;
+			break;
+		case DESC_RATEMCS8:
+			rate_idx =3D 8;
+			break;
+		case DESC_RATEMCS9:
+			rate_idx =3D 9;
+			break;
+		case DESC_RATEMCS10:
+			rate_idx =3D 10;
+			break;
+		case DESC_RATEMCS11:
+			rate_idx =3D 11;
+			break;
+		case DESC_RATEMCS12:
+			rate_idx =3D 12;
+			break;
+		case DESC_RATEMCS13:
+			rate_idx =3D 13;
+			break;
+		case DESC_RATEMCS14:
+			rate_idx =3D 14;
+			break;
+		case DESC_RATEMCS15:
+			rate_idx =3D 15;
+			break;
+		default:
+			rate_idx =3D 0;
+			break;
+		}
+	}
+
+	if (isvht) {
+		switch (desc_rate) {
+		case DESC_RATEVHT1SS_MCS0:
+			rate_idx =3D 0;
+			break;
+		case DESC_RATEVHT1SS_MCS1:
+			rate_idx =3D 1;
+			break;
+		case DESC_RATEVHT1SS_MCS2:
+			rate_idx =3D 2;
+			break;
+		case DESC_RATEVHT1SS_MCS3:
+			rate_idx =3D 3;
+			break;
+		case DESC_RATEVHT1SS_MCS4:
+			rate_idx =3D 4;
+			break;
+		case DESC_RATEVHT1SS_MCS5:
+			rate_idx =3D 5;
+			break;
+		case DESC_RATEVHT1SS_MCS6:
+			rate_idx =3D 6;
+			break;
+		case DESC_RATEVHT1SS_MCS7:
+			rate_idx =3D 7;
+			break;
+		case DESC_RATEVHT1SS_MCS8:
+			rate_idx =3D 8;
+			break;
+		case DESC_RATEVHT1SS_MCS9:
+			rate_idx =3D 9;
+			break;
+		case DESC_RATEVHT2SS_MCS0:
+			rate_idx =3D 0;
+			break;
+		case DESC_RATEVHT2SS_MCS1:
+			rate_idx =3D 1;
+			break;
+		case DESC_RATEVHT2SS_MCS2:
+			rate_idx =3D 2;
+			break;
+		case DESC_RATEVHT2SS_MCS3:
+			rate_idx =3D 3;
+			break;
+		case DESC_RATEVHT2SS_MCS4:
+			rate_idx =3D 4;
+			break;
+		case DESC_RATEVHT2SS_MCS5:
+			rate_idx =3D 5;
+			break;
+		case DESC_RATEVHT2SS_MCS6:
+			rate_idx =3D 6;
+			break;
+		case DESC_RATEVHT2SS_MCS7:
+			rate_idx =3D 7;
+			break;
+		case DESC_RATEVHT2SS_MCS8:
+			rate_idx =3D 8;
+			break;
+		case DESC_RATEVHT2SS_MCS9:
+			rate_idx =3D 9;
+			break;
+		default:
+			rate_idx =3D 0;
+			break;
+		}
+	}
+	return rate_idx;
+}
+
+static u16 odm_cfo(char value)
+{
+	int ret_val;
+
+	if (value < 0) {
+		ret_val =3D 0 - value;
+		ret_val =3D (ret_val << 1) + (ret_val >> 1);
+		/* set bit12 as 1 for negative cfo */
+		ret_val =3D ret_val | BIT(12);
+	} else {
+		ret_val =3D value;
+		ret_val =3D (ret_val << 1) + (ret_val >> 1);
+	}
+	return ret_val;
+}
+
+static void query_rxphystatus(struct ieee80211_hw *hw,
+			      struct rtl_stats *pstatus, u8 *pdesc,
+			      struct rx_fwinfo_8821ae *p_drvinfo,
+			      bool bpacket_match_bssid,
+			      bool bpacket_toself, bool packet_beacon)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct phy_status_rpt *p_phystrpt =3D (struct phy_status_rpt *)p_drvi=
nfo;
+	struct rtl_dm *rtldm =3D rtl_dm(rtl_priv(hw));
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	char rx_pwr_all =3D 0, rx_pwr[4];
+	u8 rf_rx_num =3D 0, evm, evmdbm, pwdb_all;
+	u8 i, max_spatial_stream;
+	u32 rssi, total_rssi =3D 0;
+	bool is_cck =3D pstatus->is_cck;
+	u8 lan_idx, vga_idx;
+
+	/* Record it for next packet processing */
+	pstatus->packet_matchbssid =3D bpacket_match_bssid;
+	pstatus->packet_toself =3D bpacket_toself;
+	pstatus->packet_beacon =3D packet_beacon;
+	pstatus->rx_mimo_signalquality[0] =3D -1;
+	pstatus->rx_mimo_signalquality[1] =3D -1;
+
+	if (is_cck) {
+		u8 cck_highpwr;
+		u8 cck_agc_rpt;
+
+		cck_agc_rpt =3D p_phystrpt->cfosho[0];
+
+		/* (1)Hardware does not provide RSSI for CCK
+		 * (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
+		cck_highpwr =3D (u8)rtlphy->cck_high_power;
+
+		lan_idx =3D ((cck_agc_rpt & 0xE0) >> 5);
+		vga_idx =3D (cck_agc_rpt & 0x1f);
+		if (rtlpriv->rtlhal.hw_type =3D=3D HARDWARE_TYPE_RTL8812AE) {
+			switch (lan_idx) {
+			case 7:
+				if (vga_idx <=3D 27)
+					/*VGA_idx =3D 27~2*/
+					rx_pwr_all =3D -100 + 2*(27-vga_idx);
+				else
+					rx_pwr_all =3D -100;
+				break;
+			case 6:
+				/*VGA_idx =3D 2~0*/
+				rx_pwr_all =3D -48 + 2*(2-vga_idx);
+				break;
+			case 5:
+				/*VGA_idx =3D 7~5*/
+				rx_pwr_all =3D -42 + 2*(7-vga_idx);
+				break;
+			case 4:
+				/*VGA_idx =3D 7~4*/
+				rx_pwr_all =3D -36 + 2*(7-vga_idx);
+				break;
+			case 3:
+				/*VGA_idx =3D 7~0*/
+				rx_pwr_all =3D -24 + 2*(7-vga_idx);
+				break;
+			case 2:
+				if (cck_highpwr)
+					/*VGA_idx =3D 5~0*/
+					rx_pwr_all =3D -12 + 2*(5-vga_idx);
+				else
+					rx_pwr_all =3D -6 + 2*(5-vga_idx);
+				break;
+			case 1:
+				rx_pwr_all =3D 8-2*vga_idx;
+				break;
+			case 0:
+				rx_pwr_all =3D 14-2*vga_idx;
+				break;
+			default:
+				break;
+			}
+			rx_pwr_all +=3D 6;
+			pwdb_all =3D rtl_query_rxpwrpercentage(rx_pwr_all);
+			if (!cck_highpwr) {
+				if (pwdb_all >=3D 80)
+					pwdb_all =3D
+					  ((pwdb_all - 80)<<1) +
+					 ((pwdb_all - 80)>>1) + 80;
+				else if ((pwdb_all <=3D 78) && (pwdb_all >=3D 20))
+					pwdb_all +=3D 3;
+				if (pwdb_all > 100)
+					pwdb_all =3D 100;
+			}
+		} else { /* 8821 */
+			char pout =3D -6;
+
+			switch (lan_idx) {
+			case 5:
+				rx_pwr_all =3D pout - 32 - (2*vga_idx);
+					break;
+			case 4:
+				rx_pwr_all =3D pout - 24 - (2*vga_idx);
+					break;
+			case 2:
+				rx_pwr_all =3D pout - 11 - (2*vga_idx);
+					break;
+			case 1:
+				rx_pwr_all =3D pout + 5 - (2*vga_idx);
+					break;
+			case 0:
+				rx_pwr_all =3D pout + 21 - (2*vga_idx);
+					break;
+			}
+			pwdb_all =3D rtl_query_rxpwrpercentage(rx_pwr_all);
+		}
+
+		pstatus->rx_pwdb_all =3D pwdb_all;
+		pstatus->recvsignalpower =3D rx_pwr_all;
+
+		/* (3) Get Signal Quality (EVM) */
+		if (bpacket_match_bssid) {
+			u8 sq;
+
+			if (pstatus->rx_pwdb_all > 40) {
+				sq =3D 100;
+			} else {
+				sq =3D p_phystrpt->pwdb_all;
+				if (sq > 64)
+					sq =3D 0;
+				else if (sq < 20)
+					sq =3D 100;
+				else
+					sq =3D ((64 - sq) * 100) / 44;
+			}
+
+			pstatus->signalquality =3D sq;
+			pstatus->rx_mimo_signalquality[0] =3D sq;
+			pstatus->rx_mimo_signalquality[1] =3D -1;
+		}
+	} else {
+		/* (1)Get RSSI for HT rate */
+		for (i =3D RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
+			/* we will judge RF RX path now. */
+			if (rtlpriv->dm.rfpath_rxenable[i])
+				rf_rx_num++;
+
+			rx_pwr[i] =3D (p_phystrpt->gain_trsw[i] & 0x7f) - 110;
+
+			/* Translate DBM to percentage. */
+			rssi =3D rtl_query_rxpwrpercentage(rx_pwr[i]);
+			total_rssi +=3D rssi;
+
+			/* Get Rx snr value in DB */
+			pstatus->rx_snr[i] =3D p_phystrpt->rxsnr[i] / 2;
+			rtlpriv->stats.rx_snr_db[i] =3D p_phystrpt->rxsnr[i] / 2;
+
+			pstatus->cfo_short[i] =3D odm_cfo(p_phystrpt->cfosho[i]);
+			pstatus->cfo_tail[i] =3D odm_cfo(p_phystrpt->cfotail[i]);
+			/* Record Signal Strength for next packet */
+			pstatus->rx_mimo_signalstrength[i] =3D (u8)rssi;
+		}
+
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive)
+		 */
+		rx_pwr_all =3D ((p_drvinfo->pwdb_all >> 1) & 0x7f) - 110;
+
+		pwdb_all =3D rtl_query_rxpwrpercentage(rx_pwr_all);
+		pstatus->rx_pwdb_all =3D pwdb_all;
+		pstatus->rxpower =3D rx_pwr_all;
+		pstatus->recvsignalpower =3D rx_pwr_all;
+
+		/* (3)EVM of HT rate */
+		if ((pstatus->is_ht && pstatus->rate >=3D DESC_RATEMCS8 &&
+		     pstatus->rate <=3D DESC_RATEMCS15) ||
+		    (pstatus->is_vht &&
+		     pstatus->rate >=3D DESC_RATEVHT2SS_MCS0 &&
+		     pstatus->rate <=3D DESC_RATEVHT2SS_MCS9))
+			max_spatial_stream =3D 2;
+		else
+			max_spatial_stream =3D 1;
+
+		for (i =3D 0; i < max_spatial_stream; i++) {
+			evm =3D rtl_evm_db_to_percentage(p_phystrpt->rxevm[i]);
+			evmdbm =3D rtl_evm_dbm_jaguar(p_phystrpt->rxevm[i]);
+
+			if (bpacket_match_bssid) {
+				/* Fill value in RFD, Get the first
+				 * spatial stream only
+				 */
+				if (i =3D=3D 0)
+					pstatus->signalquality =3D evm;
+				pstatus->rx_mimo_signalquality[i] =3D evm;
+				pstatus->rx_mimo_evm_dbm[i] =3D evmdbm;
+			}
+		}
+		if (bpacket_match_bssid) {
+			for (i =3D RF90_PATH_A; i <=3D RF90_PATH_B; i++)
+				rtl_priv(hw)->dm.cfo_tail[i] =3D
+					(char)p_phystrpt->cfotail[i];
+
+			rtl_priv(hw)->dm.packet_count++;
+		}
+	}
+
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100.
+	 */
+	if (is_cck)
+		pstatus->signalstrength =3D (u8)(rtl_signal_scale_mapping(hw,
+			pwdb_all));
+	else if (rf_rx_num !=3D 0)
+		pstatus->signalstrength =3D (u8)(rtl_signal_scale_mapping(hw,
+			total_rssi /=3D rf_rx_num));
+	/*HW antenna diversity*/
+	rtldm->fat_table.antsel_rx_keep_0 =3D p_phystrpt->antidx_anta;
+	rtldm->fat_table.antsel_rx_keep_1 =3D p_phystrpt->antidx_antb;
+}
+
+static void translate_rx_signal_stuff(struct ieee80211_hw *hw,
+				      struct sk_buff *skb,
+				      struct rtl_stats *pstatus, u8 *pdesc,
+				      struct rx_fwinfo_8821ae *p_drvinfo)
+{
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse =3D rtl_efuse(rtl_priv(hw));
+	struct ieee80211_hdr *hdr;
+	u8 *tmp_buf;
+	u8 *praddr;
+	u8 *psaddr;
+	__le16 fc;
+	u16 type;
+	bool packet_matchbssid, packet_toself, packet_beacon;
+
+	tmp_buf =3D skb->data + pstatus->rx_drvinfo_size + pstatus->rx_bufshi=
ft;
+
+	hdr =3D (struct ieee80211_hdr *)tmp_buf;
+	fc =3D hdr->frame_control;
+	type =3D WLAN_FC_GET_TYPE(hdr->frame_control);
+	praddr =3D hdr->addr1;
+	psaddr =3D ieee80211_get_SA(hdr);
+	ether_addr_copy(pstatus->psaddr, psaddr);
+
+	packet_matchbssid =3D (!ieee80211_is_ctl(fc) &&
+			     (ether_addr_equal(mac->bssid,
+					       ieee80211_has_tods(fc) ?
+					       hdr->addr1 :
+					       ieee80211_has_fromds(fc) ?
+					       hdr->addr2 : hdr->addr3)) &&
+			      (!pstatus->hwerror) &&
+			      (!pstatus->crc) && (!pstatus->icv));
+
+	packet_toself =3D packet_matchbssid &&
+	    (ether_addr_equal(praddr, rtlefuse->dev_addr));
+
+	if (ieee80211_is_beacon(hdr->frame_control))
+		packet_beacon =3D true;
+	else
+		packet_beacon =3D false;
+
+	if (packet_beacon && packet_matchbssid)
+		rtl_priv(hw)->dm.dbginfo.num_qry_beacon_pkt++;
+
+	if (packet_matchbssid &&
+	    ieee80211_is_data_qos(hdr->frame_control) &&
+	    !is_multicast_ether_addr(ieee80211_get_DA(hdr))) {
+		struct ieee80211_qos_hdr *hdr_qos =3D
+			(struct ieee80211_qos_hdr *)tmp_buf;
+		u16 tid =3D le16_to_cpu(hdr_qos->qos_ctrl) & 0xf;
+
+		if (tid !=3D 0 && tid !=3D 3)
+			rtl_priv(hw)->dm.dbginfo.num_non_be_pkt++;
+	}
+
+	query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+			  packet_matchbssid, packet_toself,
+			  packet_beacon);
+	/*_rtl8821ae_smart_antenna(hw, pstatus); */
+	rtl_process_phyinfo(hw, tmp_buf, pstatus);
+}
+
+static void _rtl8821ae_insert_emcontent(struct rtl_tcb_desc *ptcb_desc=
,
+					u8 *virtualaddress)
+{
+	u32 dwtmp =3D 0;
+
+	memset(virtualaddress, 0, 8);
+
+	SET_EARLYMODE_PKTNUM(virtualaddress, ptcb_desc->empkt_num);
+	if (ptcb_desc->empkt_num =3D=3D 1) {
+		dwtmp =3D ptcb_desc->empkt_len[0];
+	} else {
+		dwtmp =3D ptcb_desc->empkt_len[0];
+		dwtmp +=3D ((dwtmp % 4) ? (4 - dwtmp % 4) : 0)+4;
+		dwtmp +=3D ptcb_desc->empkt_len[1];
+	}
+	SET_EARLYMODE_LEN0(virtualaddress, dwtmp);
+
+	if (ptcb_desc->empkt_num <=3D 3) {
+		dwtmp =3D ptcb_desc->empkt_len[2];
+	} else {
+		dwtmp =3D ptcb_desc->empkt_len[2];
+		dwtmp +=3D ((dwtmp % 4) ? (4 - dwtmp % 4) : 0)+4;
+		dwtmp +=3D ptcb_desc->empkt_len[3];
+	}
+	SET_EARLYMODE_LEN1(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <=3D 5) {
+		dwtmp =3D ptcb_desc->empkt_len[4];
+	} else {
+		dwtmp =3D ptcb_desc->empkt_len[4];
+		dwtmp +=3D ((dwtmp % 4) ? (4 - dwtmp % 4) : 0)+4;
+		dwtmp +=3D ptcb_desc->empkt_len[5];
+	}
+	SET_EARLYMODE_LEN2_1(virtualaddress, dwtmp & 0xF);
+	SET_EARLYMODE_LEN2_2(virtualaddress, dwtmp >> 4);
+	if (ptcb_desc->empkt_num <=3D 7) {
+		dwtmp =3D ptcb_desc->empkt_len[6];
+	} else {
+		dwtmp =3D ptcb_desc->empkt_len[6];
+		dwtmp +=3D ((dwtmp % 4) ? (4 - dwtmp % 4) : 0)+4;
+		dwtmp +=3D ptcb_desc->empkt_len[7];
+	}
+	SET_EARLYMODE_LEN3(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <=3D 9) {
+		dwtmp =3D ptcb_desc->empkt_len[8];
+	} else {
+		dwtmp =3D ptcb_desc->empkt_len[8];
+		dwtmp +=3D ((dwtmp % 4) ? (4 - dwtmp % 4) : 0)+4;
+		dwtmp +=3D ptcb_desc->empkt_len[9];
+	}
+	SET_EARLYMODE_LEN4(virtualaddress, dwtmp);
+}
+
+static bool rtl8821ae_get_rxdesc_is_ht(struct ieee80211_hw *hw, u8 *pd=
esc)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 rx_rate =3D 0;
+
+	rx_rate =3D GET_RX_DESC_RXMCS(pdesc);
+
+	RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD, "rx_rate=3D0x%02x.\n", rx_ra=
te);
+
+	if ((rx_rate >=3D DESC_RATEMCS0) && (rx_rate <=3D DESC_RATEMCS15))
+		return true;
+	return false;
+}
+
+static bool rtl8821ae_get_rxdesc_is_vht(struct ieee80211_hw *hw, u8 *p=
desc)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	u8 rx_rate =3D 0;
+
+	rx_rate =3D GET_RX_DESC_RXMCS(pdesc);
+
+	RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD, "rx_rate=3D0x%02x.\n", rx_ra=
te);
+
+	if (rx_rate >=3D DESC_RATEVHT1SS_MCS0)
+		return true;
+	return false;
+}
+
+static u8 rtl8821ae_get_rx_vht_nss(struct ieee80211_hw *hw, u8 *pdesc)
+{
+	u8 rx_rate =3D 0;
+	u8 vht_nss =3D 0;
+
+	rx_rate =3D GET_RX_DESC_RXMCS(pdesc);
+	if ((rx_rate >=3D DESC_RATEVHT1SS_MCS0) &&
+	    (rx_rate <=3D DESC_RATEVHT1SS_MCS9))
+		vht_nss =3D 1;
+	else if ((rx_rate >=3D DESC_RATEVHT2SS_MCS0) &&
+		 (rx_rate <=3D DESC_RATEVHT2SS_MCS9))
+		vht_nss =3D 2;
+
+	return vht_nss;
+}
+
+bool rtl8821ae_rx_query_desc(struct ieee80211_hw *hw,
+			     struct rtl_stats *status,
+			     struct ieee80211_rx_status *rx_status,
+			     u8 *pdesc, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rx_fwinfo_8821ae *p_drvinfo;
+	struct ieee80211_hdr *hdr;
+
+	u32 phystatus =3D GET_RX_DESC_PHYST(pdesc);
+
+	status->length =3D (u16)GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size =3D (u8)GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+	    RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift =3D (u8)(GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->icv =3D (u16)GET_RX_DESC_ICV(pdesc);
+	status->crc =3D (u16)GET_RX_DESC_CRC32(pdesc);
+	status->hwerror =3D (status->crc | status->icv);
+	status->decrypted =3D !GET_RX_DESC_SWDEC(pdesc);
+	status->rate =3D (u8)GET_RX_DESC_RXMCS(pdesc);
+	status->shortpreamble =3D (u16)GET_RX_DESC_SPLCP(pdesc);
+	status->isampdu =3D (bool)(GET_RX_DESC_PAGGR(pdesc) =3D=3D 1);
+	status->isfirst_ampdu =3D (bool)(GET_RX_DESC_PAGGR(pdesc) =3D=3D 1);
+	status->timestamp_low =3D GET_RX_DESC_TSFL(pdesc);
+	status->rx_packet_bw =3D GET_RX_DESC_BW(pdesc);
+	status->macid =3D GET_RX_DESC_MACID(pdesc);
+	status->is_short_gi =3D !(bool)GET_RX_DESC_SPLCP(pdesc);
+	status->is_ht =3D rtl8821ae_get_rxdesc_is_ht(hw, pdesc);
+	status->is_vht =3D rtl8821ae_get_rxdesc_is_vht(hw, pdesc);
+	status->vht_nss =3D rtl8821ae_get_rx_vht_nss(hw, pdesc);
+	status->is_cck =3D RTL8821AE_RX_HAL_IS_CCK_RATE(status->rate);
+
+	RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
+		 "rx_packet_bw=3D%s,is_ht %d, is_vht %d, vht_nss=3D%d,is_short_gi %d=
=2E\n",
+		 (status->rx_packet_bw =3D=3D 2) ? "80M" :
+		 (status->rx_packet_bw =3D=3D 1) ? "40M" : "20M",
+		 status->is_ht, status->is_vht, status->vht_nss,
+		 status->is_short_gi);
+
+	if (GET_RX_STATUS_DESC_RPT_SEL(pdesc))
+		status->packet_report_type =3D C2H_PACKET;
+	else
+		status->packet_report_type =3D NORMAL_RX;
+
+	if (GET_RX_STATUS_DESC_PATTERN_MATCH(pdesc))
+		status->wake_match =3D BIT(2);
+	else if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match =3D BIT(1);
+	else if (GET_RX_STATUS_DESC_UNICAST_MATCH(pdesc))
+		status->wake_match =3D BIT(0);
+	else
+		status->wake_match =3D 0;
+
+	if (status->wake_match)
+		RT_TRACE(rtlpriv, COMP_RXDESC, DBG_LOUD,
+			 "GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch=3D%d\n",
+			 status->wake_match);
+	rx_status->freq =3D hw->conf.chandef.chan->center_freq;
+	rx_status->band =3D hw->conf.chandef.chan->band;
+
+	hdr =3D (struct ieee80211_hdr *)(skb->data +
+	      status->rx_drvinfo_size + status->rx_bufshift);
+
+	if (status->crc)
+		rx_status->flag |=3D RX_FLAG_FAILED_FCS_CRC;
+
+	if (status->rx_packet_bw =3D=3D HT_CHANNEL_WIDTH_20_40)
+		rx_status->flag |=3D RX_FLAG_40MHZ;
+	else if (status->rx_packet_bw =3D=3D HT_CHANNEL_WIDTH_80)
+		rx_status->vht_flag |=3D RX_VHT_FLAG_80MHZ;
+	if (status->is_ht)
+		rx_status->flag |=3D RX_FLAG_HT;
+	if (status->is_vht)
+		rx_status->flag |=3D RX_FLAG_VHT;
+
+	if (status->is_short_gi)
+		rx_status->flag |=3D RX_FLAG_SHORT_GI;
+
+	rx_status->vht_nss =3D status->vht_nss;
+	rx_status->flag |=3D RX_FLAG_MACTIME_START;
+
+	/* hw will set status->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame.
+	 * So hw will not decryption robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it
+	 */
+	if (status->decrypted) {
+		if (!hdr) {
+			WARN_ON_ONCE(true);
+			pr_err("decrypted is true but hdr NULL, from skb %p\n",
+			       rtl_get_hdr(skb));
+			return false;
+		}
+
+		if ((!_ieee80211_is_robust_mgmt_frame(hdr)) &&
+		    (ieee80211_has_protected(hdr->frame_control)))
+			rx_status->flag |=3D RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag &=3D ~RX_FLAG_DECRYPTED;
+	}
+
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)
+	 */
+	rx_status->rate_idx =3D
+	  _rtl8821ae_rate_mapping(hw, status->is_ht,
+				  status->is_vht, status->rate);
+
+	rx_status->mactime =3D status->timestamp_low;
+	if (phystatus) {
+		p_drvinfo =3D (struct rx_fwinfo_8821ae *)(skb->data +
+			    status->rx_bufshift);
+
+		translate_rx_signal_stuff(hw, skb, status, pdesc, p_drvinfo);
+	}
+	rx_status->signal =3D status->recvsignalpower + 10;
+	if (status->packet_report_type =3D=3D TX_REPORT2) {
+		status->macid_valid_entry[0] =3D
+		  GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
+		status->macid_valid_entry[1] =3D
+		  GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
+	}
+	return true;
+}
+
+static u8 rtl8821ae_bw_mapping(struct ieee80211_hw *hw,
+			       struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	u8 bw_setting_of_desc =3D 0;
+
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+		 "rtl8821ae_bw_mapping, current_chan_bw %d, packet_bw %d\n",
+		 rtlphy->current_chan_bw, ptcb_desc->packet_bw);
+
+	if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80) {
+		if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_80)
+			bw_setting_of_desc =3D 2;
+		else if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_20_40)
+			bw_setting_of_desc =3D 1;
+		else
+			bw_setting_of_desc =3D 0;
+	} else if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+		if ((ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_20_40) ||
+		    (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_80))
+			bw_setting_of_desc =3D 1;
+		else
+			bw_setting_of_desc =3D 0;
+	} else {
+		bw_setting_of_desc =3D 0;
+	}
+	return bw_setting_of_desc;
+}
+
+static u8 rtl8821ae_sc_mapping(struct ieee80211_hw *hw,
+			       struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_phy *rtlphy =3D &rtlpriv->phy;
+	struct rtl_mac *mac =3D rtl_mac(rtlpriv);
+	u8 sc_setting_of_desc =3D 0;
+
+	if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_80) {
+		if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_80) {
+			sc_setting_of_desc =3D VHT_DATA_SC_DONOT_CARE;
+		} else if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+			if (mac->cur_80_prime_sc =3D=3D
+			    HAL_PRIME_CHNL_OFFSET_LOWER)
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_40_LOWER_OF_80MHZ;
+			else if (mac->cur_80_prime_sc =3D=3D
+				 HAL_PRIME_CHNL_OFFSET_UPPER)
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_40_UPPER_OF_80MHZ;
+			else
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_LOUD,
+					 "rtl8821ae_sc_mapping: Not Correct Primary40MHz Setting\n");
+		} else {
+			if ((mac->cur_40_prime_sc =3D=3D
+			     HAL_PRIME_CHNL_OFFSET_LOWER) &&
+			    (mac->cur_80_prime_sc  =3D=3D
+			     HAL_PRIME_CHNL_OFFSET_LOWER))
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_LOWEST_OF_80MHZ;
+			else if ((mac->cur_40_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_UPPER) &&
+				 (mac->cur_80_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_LOWER))
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_LOWER_OF_80MHZ;
+			else if ((mac->cur_40_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_LOWER) &&
+				 (mac->cur_80_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_UPPER))
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_UPPER_OF_80MHZ;
+			else if ((mac->cur_40_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_UPPER) &&
+				 (mac->cur_80_prime_sc =3D=3D
+				  HAL_PRIME_CHNL_OFFSET_UPPER))
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_UPPERST_OF_80MHZ;
+			else
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_LOUD,
+					 "rtl8821ae_sc_mapping: Not Correct Primary40MHz Setting\n");
+		}
+	} else if (rtlphy->current_chan_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+		if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_20_40) {
+			sc_setting_of_desc =3D VHT_DATA_SC_DONOT_CARE;
+		} else if (ptcb_desc->packet_bw =3D=3D HT_CHANNEL_WIDTH_20) {
+			if (mac->cur_40_prime_sc =3D=3D
+				HAL_PRIME_CHNL_OFFSET_UPPER) {
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_UPPER_OF_80MHZ;
+			} else if (mac->cur_40_prime_sc =3D=3D
+				HAL_PRIME_CHNL_OFFSET_LOWER){
+				sc_setting_of_desc =3D
+					VHT_DATA_SC_20_LOWER_OF_80MHZ;
+			} else {
+				sc_setting_of_desc =3D VHT_DATA_SC_DONOT_CARE;
+			}
+		}
+	} else {
+		sc_setting_of_desc =3D VHT_DATA_SC_DONOT_CARE;
+	}
+
+	return sc_setting_of_desc;
+}
+
+void rtl8821ae_tx_fill_desc(struct ieee80211_hw *hw,
+			    struct ieee80211_hdr *hdr, u8 *pdesc_tx, u8 *txbd,
+			    struct ieee80211_tx_info *info,
+			    struct ieee80211_sta *sta,
+			    struct sk_buff *skb,
+			    u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal =3D rtl_hal(rtlpriv);
+	u8 *pdesc =3D (u8 *)pdesc_tx;
+	u16 seq_number;
+	__le16 fc =3D hdr->frame_control;
+	unsigned int buf_len =3D 0;
+	unsigned int skb_len =3D skb->len;
+	u8 fw_qsel =3D _rtl8821ae_map_hwqueue_to_fwqueue(skb, hw_queue);
+	bool firstseg =3D ((hdr->seq_ctrl &
+			  cpu_to_le16(IEEE80211_SCTL_FRAG)) =3D=3D 0);
+	bool lastseg =3D ((hdr->frame_control &
+			 cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) =3D=3D 0);
+	dma_addr_t mapping;
+	u8 short_gi =3D 0;
+
+	seq_number =3D (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4=
;
+	rtl_get_tcb_desc(hw, info, sta, skb, ptcb_desc);
+	/* reserve 8 byte for AMPDU early mode */
+	if (rtlhal->earlymode_enable) {
+		skb_push(skb, EM_HDR_LEN);
+		memset(skb->data, 0, EM_HDR_LEN);
+	}
+	buf_len =3D skb->len;
+	mapping =3D pci_map_single(rtlpci->pdev, skb->data, skb->len,
+				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, sizeof(struct tx_desc_8821ae));
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		firstseg =3D true;
+		lastseg =3D true;
+	}
+	if (firstseg) {
+		if (rtlhal->earlymode_enable) {
+			SET_TX_DESC_PKT_OFFSET(pdesc, 1);
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN +
+					   EM_HDR_LEN);
+			if (ptcb_desc->empkt_num) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Insert 8 byte.pTcb->EMPktNum:%d\n",
+					  ptcb_desc->empkt_num);
+				_rtl8821ae_insert_emcontent(ptcb_desc,
+					 (u8 *)(skb->data));
+			}
+		} else {
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+		}
+
+		/* ptcb_desc->use_driver_rate =3D true; */
+		SET_TX_DESC_TX_RATE(pdesc, ptcb_desc->hw_rate);
+		if (ptcb_desc->hw_rate > DESC_RATEMCS0)
+			short_gi =3D (ptcb_desc->use_shortgi) ? 1 : 0;
+		else
+			short_gi =3D (ptcb_desc->use_shortpreamble) ? 1 : 0;
+
+		SET_TX_DESC_DATA_SHORTGI(pdesc, short_gi);
+
+		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+			SET_TX_DESC_AGG_ENABLE(pdesc, 1);
+			SET_TX_DESC_MAX_AGG_NUM(pdesc, 0x1f);
+		}
+		SET_TX_DESC_SEQ(pdesc, seq_number);
+		SET_TX_DESC_RTS_ENABLE(pdesc, ((ptcb_desc->rts_enable &&
+					!ptcb_desc->cts_enable) ? 1 : 0));
+		SET_TX_DESC_HW_RTS_ENABLE(pdesc, 0);
+		SET_TX_DESC_CTS2SELF(pdesc, ((ptcb_desc->cts_enable) ? 1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcb_desc->rts_rate);
+		SET_TX_DESC_RTS_SC(pdesc, ptcb_desc->rts_sc);
+		SET_TX_DESC_RTS_SHORT(pdesc,
+			((ptcb_desc->rts_rate <=3D DESC_RATE54M) ?
+			(ptcb_desc->rts_use_shortpreamble ? 1 : 0) :
+			(ptcb_desc->rts_use_shortgi ? 1 : 0)));
+
+		if (ptcb_desc->tx_enable_sw_calc_duration)
+			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
+
+		SET_TX_DESC_DATA_BW(pdesc,
+			rtl8821ae_bw_mapping(hw, ptcb_desc));
+
+		SET_TX_DESC_TX_SUB_CARRIER(pdesc,
+			rtl8821ae_sc_mapping(hw, ptcb_desc));
+
+		SET_TX_DESC_LINIP(pdesc, 0);
+		SET_TX_DESC_PKT_SIZE(pdesc, (u16)skb_len);
+		if (sta) {
+			u8 ampdu_density =3D sta->ht_cap.ampdu_density;
+
+			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
+		}
+		if (info->control.hw_key) {
+			struct ieee80211_key_conf *keyconf =3D
+				info->control.hw_key;
+			switch (keyconf->cipher) {
+			case WLAN_CIPHER_SUITE_WEP40:
+			case WLAN_CIPHER_SUITE_WEP104:
+			case WLAN_CIPHER_SUITE_TKIP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x1);
+				break;
+			case WLAN_CIPHER_SUITE_CCMP:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x3);
+				break;
+			default:
+				SET_TX_DESC_SEC_TYPE(pdesc, 0x0);
+				break;
+			}
+		}
+
+		SET_TX_DESC_QUEUE_SEL(pdesc, fw_qsel);
+		SET_TX_DESC_DATA_RATE_FB_LIMIT(pdesc, 0x1F);
+		SET_TX_DESC_RTS_RATE_FB_LIMIT(pdesc, 0xF);
+		SET_TX_DESC_DISABLE_FB(pdesc, ptcb_desc->disable_ratefallback ?
+				       1 : 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
+
+		if (ieee80211_is_data_qos(fc)) {
+			if (mac->rdg_en) {
+				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+					 "Enable RDG function.\n");
+				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
+				SET_TX_DESC_HTC(pdesc, 1);
+			}
+		}
+	}
+
+	SET_TX_DESC_FIRST_SEG(pdesc, (firstseg ? 1 : 0));
+	SET_TX_DESC_LAST_SEG(pdesc, (lastseg ? 1 : 0));
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)buf_len);
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+	/* if (rtlpriv->dm.useramask) { */
+	if (1) {
+		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	} else {
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	}
+	if (!ieee80211_is_data_qos(fc))  {
+		SET_TX_DESC_HWSEQ_EN(pdesc, 1);
+		SET_TX_DESC_HWSEQ_SEL(pdesc, 0);
+	}
+	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+		SET_TX_DESC_BMC(pdesc, 1);
+	}
+
+	rtl8821ae_dm_set_tx_ant_by_tx_info(hw, pdesc, ptcb_desc->mac_id);
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
+}
+
+void rtl8821ae_tx_fill_cmddesc(struct ieee80211_hw *hw,
+			       u8 *pdesc, bool firstseg,
+			       bool lastseg, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	u8 fw_queue =3D QSLT_BEACON;
+
+	dma_addr_t mapping =3D pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
+			 "DMA mapping error");
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, TX_DESC_SIZE);
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+
+	SET_TX_DESC_USE_RATE(pdesc, 1);
+	SET_TX_DESC_TX_RATE(pdesc, DESC_RATE1M);
+	SET_TX_DESC_DISABLE_FB(pdesc, 1);
+
+	SET_TX_DESC_DATA_BW(pdesc, 0);
+
+	SET_TX_DESC_HWSEQ_EN(pdesc, 1);
+
+	SET_TX_DESC_QUEUE_SEL(pdesc, fw_queue);
+
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	SET_TX_DESC_MACID(pdesc, 0);
+
+	SET_TX_DESC_OWN(pdesc, 1);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "H2C Tx Cmd Content\n",
+		      pdesc, TX_DESC_SIZE);
+}
+
+void rtl8821ae_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+			bool istx, u8 desc_name, u8 *val)
+{
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			SET_TX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_TX_NEXTDESC_ADDR:
+			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *)val);
+			break;
+		default:
+			RT_ASSERT(false,
+				  "ERR txdesc :%d not process\n", desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_RXOWN:
+			SET_RX_DESC_OWN(pdesc, 1);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			SET_RX_DESC_BUFF_ADDR(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			SET_RX_DESC_PKT_LEN(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXERO:
+			SET_RX_DESC_EOR(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false,
+				  "ERR rxdesc :%d not process\n", desc_name);
+			break;
+		}
+	}
+}
+
+u32 rtl8821ae_get_desc(u8 *pdesc, bool istx, u8 desc_name)
+{
+	u32 ret =3D 0;
+
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret =3D GET_TX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_TXBUFF_ADDR:
+			ret =3D GET_TX_DESC_TX_BUFFER_ADDRESS(pdesc);
+			break;
+		default:
+			RT_ASSERT(false,
+				  "ERR txdesc :%d not process\n", desc_name);
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret =3D GET_RX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			ret =3D GET_RX_DESC_PKT_LEN(pdesc);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret =3D GET_RX_DESC_BUFF_ADDR(pdesc);
+			break;
+		default:
+			RT_ASSERT(false,
+				  "ERR rxdesc :%d not process\n", desc_name);
+			break;
+		}
+	}
+	return ret;
+}
+
+bool rtl8821ae_is_tx_desc_closed(struct ieee80211_hw *hw,
+				 u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring =3D &rtlpci->tx_ring[hw_queue];
+	u8 *entry =3D (u8 *)(&ring->desc[ring->idx]);
+	u8 own =3D (u8)rtl8821ae_get_desc(entry, true, HW_DESC_OWN);
+
+	/**
+	 *beacon packet will only use the first
+	 *descriptor defautly,and the own may not
+	 *be cleared by the hardware
+	 */
+	if (own)
+		return false;
+	return true;
+}
+
+void rtl8821ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (hw_queue =3D=3D BEACON_QUEUE) {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG, BIT(4));
+	} else {
+		rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG,
+			       BIT(0) << (hw_queue));
+	}
+}
+
+u32 rtl8821ae_rx_command_packet(struct ieee80211_hw *hw,
+				struct rtl_stats status,
+				struct sk_buff *skb)
+{
+	u32 result =3D 0;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	switch (status.packet_report_type) {
+	case NORMAL_RX:
+		result =3D 0;
+		break;
+	case C2H_PACKET:
+		rtl8821ae_c2h_packet_handler(hw, skb->data, (u8)skb->len);
+		result =3D 1;
+		RT_TRACE(rtlpriv, COMP_RECV, DBG_LOUD,
+			 "skb->len=3D%d\n\n", skb->len);
+		break;
+	default:
+		RT_TRACE(rtlpriv, COMP_RECV, DBG_LOUD,
+			 "No this packet type!!\n");
+		break;
+	}
+
+	return result;
+}
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/trx.h b/drivers/net=
/wireless/rtlwifi/rtl8821ae/trx.h
new file mode 100644
index 0000000..3140904
--- /dev/null
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/trx.h
@@ -0,0 +1,620 @@
+/*********************************************************************=
*********
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distributio=
n in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Par=
k,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
+ *
+ *********************************************************************=
********/
+
+#ifndef __RTL8821AE_TRX_H__
+#define __RTL8821AE_TRX_H__
+
+#define TX_DESC_SIZE					40
+#define TX_DESC_AGGR_SUBFRAME_SIZE		32
+
+#define RX_DESC_SIZE					32
+#define RX_DRV_INFO_SIZE_UNIT			8
+
+#define	TX_DESC_NEXT_DESC_OFFSET		40
+#define USB_HWDESC_HEADER_LEN			40
+#define CRCLENGTH						4
+
+#define SET_TX_DESC_PKT_SIZE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 16, __val)
+#define SET_TX_DESC_OFFSET(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 16, 8, __val)
+#define SET_TX_DESC_BMC(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
+#define SET_TX_DESC_HTC(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 25, 1, __val)
+#define SET_TX_DESC_LAST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 26, 1, __val)
+#define SET_TX_DESC_FIRST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 27, 1, __val)
+#define SET_TX_DESC_LINIP(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 28, 1, __val)
+#define SET_TX_DESC_NO_ACM(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 29, 1, __val)
+#define SET_TX_DESC_GF(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_TX_DESC_OWN(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_TX_DESC_PKT_SIZE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 16)
+#define GET_TX_DESC_OFFSET(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 8)
+#define GET_TX_DESC_BMC(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 1)
+#define GET_TX_DESC_HTC(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 25, 1)
+#define GET_TX_DESC_LAST_SEG(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_TX_DESC_FIRST_SEG(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_TX_DESC_LINIP(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_TX_DESC_NO_ACM(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_TX_DESC_GF(__pdesc)						\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_TX_DESC_OWN(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_TX_DESC_MACID(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 7, __val)
+#define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
+#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 13, 1, __val)
+#define SET_TX_DESC_LSIG_TXOP_EN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 14, 1, __val)
+#define SET_TX_DESC_PIFS(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 15, 1, __val)
+#define SET_TX_DESC_RATE_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 16, 5, __val)
+#define SET_TX_DESC_EN_DESC_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 21, 1, __val)
+#define SET_TX_DESC_SEC_TYPE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 22, 2, __val)
+#define SET_TX_DESC_PKT_OFFSET(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 5, __val)
+
+#define SET_TX_DESC_PAID(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 9, __val)
+#define SET_TX_DESC_CCA_RTS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 10, 2, __val)
+#define SET_TX_DESC_AGG_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 12, 1, __val)
+#define SET_TX_DESC_RDG_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 13, 1, __val)
+#define SET_TX_DESC_BAR_RTY_TH(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 14, 2, __val)
+#define SET_TX_DESC_AGG_BREAK(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 16, 1, __val)
+#define SET_TX_DESC_MORE_FRAG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 17, 1, __val)
+#define SET_TX_DESC_RAW(__pdesc, __val)				\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 18, 1, __val)
+#define SET_TX_DESC_SPE_RPT(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 19, 1, __val)
+#define SET_TX_DESC_AMPDU_DENSITY(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 20, 3, __val)
+#define SET_TX_DESC_BT_INT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 23, 1, __val)
+#define SET_TX_DESC_GID(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 24, 6, __val)
+
+#define SET_TX_DESC_WHEADER_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 4, __val)
+#define SET_TX_DESC_CHK_EN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 4, 1, __val)
+#define SET_TX_DESC_EARLY_MODE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 5, 1, __val)
+#define SET_TX_DESC_HWSEQ_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 6, 2, __val)
+#define SET_TX_DESC_USE_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 8, 1, __val)
+#define SET_TX_DESC_DISABLE_RTS_FB(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 9, 1, __val)
+#define SET_TX_DESC_DISABLE_FB(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 10, 1, __val)
+#define SET_TX_DESC_CTS2SELF(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 11, 1, __val)
+#define SET_TX_DESC_RTS_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 12, 1, __val)
+#define SET_TX_DESC_HW_RTS_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 13, 1, __val)
+#define SET_TX_DESC_NAV_USE_HDR(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 15, 1, __val)
+#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 16, 1, __val)
+#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 17, 5, __val)
+#define SET_TX_DESC_NDPA(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 22, 2, __val)
+#define SET_TX_DESC_AMPDU_MAX_TIME(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 24, 8, __val)
+#define SET_TX_DESC_TX_ANT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 24, 4, __val)
+
+#define SET_TX_DESC_TX_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 7, __val)
+#define SET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 8, 5, __val)
+#define SET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 13, 4, __val)
+#define SET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 17, 1, __val)
+#define SET_TX_DESC_DATA_RETRY_LIMIT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 18, 6, __val)
+#define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 24, 5, __val)
+
+#define SET_TX_DESC_TX_SUB_CARRIER(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 0, 4, __val)
+#define SET_TX_DESC_DATA_SHORTGI(__pdesc, __val)	\
+	SET_BITS_TO_LE_1BYTE(__pdesc+20, 4, 1, __val)
+#define SET_TX_DESC_DATA_BW(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 5, 2, __val)
+#define SET_TX_DESC_DATA_LDPC(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 7, 1, __val)
+#define SET_TX_DESC_DATA_STBC(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 8, 2, __val)
+#define SET_TX_DESC_CTROL_STBC(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 10, 2, __val)
+#define SET_TX_DESC_RTS_SHORT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 12, 1, __val)
+#define SET_TX_DESC_RTS_SC(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 13, 4, __val)
+
+#define SET_TX_DESC_TX_BUFFER_SIZE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 16, __val)
+
+#define GET_TX_DESC_TX_BUFFER_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 16)
+
+#define SET_TX_DESC_HWSEQ_EN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32, 15, 1, __val)
+
+#define SET_TX_DESC_SEQ(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36, 12, 12, __val)
+
+#define SET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+40, 0, 32, __val)
+
+#define GET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+40, 0, 32)
+
+#define SET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+48, 0, 32, __val)
+
+#define GET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+48, 0, 32)
+
+#define GET_RX_DESC_PKT_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 14)
+#define GET_RX_DESC_CRC32(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 14, 1)
+#define GET_RX_DESC_ICV(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 15, 1)
+#define GET_RX_DESC_DRV_INFO_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 4)
+#define GET_RX_DESC_SECURITY(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 20, 3)
+#define GET_RX_DESC_QOS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 23, 1)
+#define GET_RX_DESC_SHIFT(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 2)
+#define GET_RX_DESC_PHYST(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_RX_DESC_SWDEC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_RX_DESC_LS(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_RX_DESC_FS(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_RX_DESC_EOR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_RX_DESC_OWN(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_RX_DESC_PKT_LEN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
+#define SET_RX_DESC_EOR(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_RX_DESC_OWN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_RX_DESC_MACID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 7)
+#define GET_RX_DESC_TID(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 8, 4)
+#define GET_RX_DESC_AMSDU(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
+#define GET_RX_STATUS_DESC_RXID_MATCH(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_RX_DESC_PAGGR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_RX_DESC_A1_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_RX_DESC_CHKERR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
+#define GET_RX_DESC_IPVER(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
+#define GET_RX_STATUS_DESC_IS_TCPUDP(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 22, 1)
+#define GET_RX_STATUS_DESC_CHK_VLD(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 23, 1)
+#define GET_RX_DESC_PAM(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 1)
+#define GET_RX_DESC_PWR(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 25, 1)
+#define GET_RX_DESC_MD(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+4, 26, 1)
+#define GET_RX_DESC_MF(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+4, 27, 1)
+#define GET_RX_DESC_TYPE(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 28, 2)
+#define GET_RX_DESC_MC(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+4, 30, 1)
+#define GET_RX_DESC_BC(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+4, 31, 1)
+
+#define GET_RX_DESC_SEQ(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 12)
+#define GET_RX_DESC_FRAG(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
+#define GET_RX_STATUS_DESC_RX_IS_QOS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 16, 1)
+#define GET_RX_STATUS_DESC_WLANHD_IV_LEN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+8, 18, 6)
+#define GET_RX_STATUS_DESC_RPT_SEL(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 28, 1)
+
+#define GET_RX_DESC_RXMCS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 7)
+#define GET_RX_DESC_HTC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+12, 10, 1)
+#define GET_RX_STATUS_DESC_EOSP(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 11, 1)
+#define GET_RX_STATUS_DESC_BSSID_FIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 12, 2)
+
+#define GET_RX_STATUS_DESC_PATTERN_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 29, 1)
+#define GET_RX_STATUS_DESC_UNICAST_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 30, 1)
+#define GET_RX_STATUS_DESC_MAGIC_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 31, 1)
+
+#define GET_RX_DESC_SPLCP(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+16, 0, 1)
+#define GET_RX_STATUS_DESC_LDPC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+16, 1, 1)
+#define GET_RX_STATUS_DESC_STBC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+16, 2, 1)
+#define GET_RX_DESC_BW(__pdesc)					\
+	LE_BITS_TO_4BYTE(__pdesc+16, 4, 2)
+
+#define GET_RX_DESC_TSFL(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+20, 0, 32)
+
+#define GET_RX_DESC_BUFF_ADDR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 0, 32)
+#define GET_RX_DESC_BUFF_ADDR64(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 32)
+
+#define SET_RX_DESC_BUFF_ADDR(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 32, __val)
+#define SET_RX_DESC_BUFF_ADDR64(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 32, __val)
+
+/* TX report 2 format in Rx desc*/
+
+#define GET_RX_RPT2_DESC_PKT_LEN(__status)	\
+	LE_BITS_TO_4BYTE(__status, 0, 9)
+#define GET_RX_RPT2_DESC_MACID_VALID_1(__status)	\
+	LE_BITS_TO_4BYTE(__status+16, 0, 32)
+#define GET_RX_RPT2_DESC_MACID_VALID_2(__status)	\
+	LE_BITS_TO_4BYTE(__status+20, 0, 32)
+
+#define SET_EARLYMODE_PKTNUM(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 0, 4, __value)
+#define SET_EARLYMODE_LEN0(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 4, 12, __value)
+#define SET_EARLYMODE_LEN1(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 16, 12, __value)
+#define SET_EARLYMODE_LEN2_1(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr, 28, 4, __value)
+#define SET_EARLYMODE_LEN2_2(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 0, 8, __value)
+#define SET_EARLYMODE_LEN3(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 8, 12, __value)
+#define SET_EARLYMODE_LEN4(__paddr, __value)	\
+	SET_BITS_TO_LE_4BYTE(__paddr+4, 20, 12, __value)
+
+#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
+do {								\
+	if (_size > TX_DESC_NEXT_DESC_OFFSET)			\
+		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
+	else							\
+		memset(__pdesc, 0, _size);			\
+} while (0)
+
+#define RTL8821AE_RX_HAL_IS_CCK_RATE(rxmcs)\
+	(rxmcs =3D=3D DESC_RATE1M ||\
+	 rxmcs =3D=3D DESC_RATE2M ||\
+	 rxmcs =3D=3D DESC_RATE5_5M ||\
+	 rxmcs =3D=3D DESC_RATE11M)
+
+struct phy_rx_agc_info_t {
+	#ifdef __LITTLE_ENDIAN
+		u8	gain:7, trsw:1;
+	#else
+		u8	trsw:1, gain:7;
+	#endif
+};
+
+struct phy_status_rpt {
+	/* DWORD 0 */
+	u8 gain_trsw[2];
+#ifdef __LITTLE_ENDIAN
+	u16 chl_num:10;
+	u16 sub_chnl:4;
+	u16 r_rfmod:2;
+#else	/* _BIG_ENDIAN_ */
+	u16 r_rfmod:2;
+	u16 sub_chnl:4;
+	u16 chl_num:10;
+#endif
+	/* DWORD 1 */
+	u8 pwdb_all;
+	u8 cfosho[4];	/* DW 1 byte 1 DW 2 byte 0 */
+
+	/* DWORD 2 */
+	char cfotail[4];	/* DW 2 byte 1 DW 3 byte 0 */
+
+	/* DWORD 3 */
+	char rxevm[2];	/* DW 3 byte 1 DW 3 byte 2 */
+	char rxsnr[2];	/* DW 3 byte 3 DW 4 byte 0 */
+
+	/* DWORD 4 */
+	u8 pcts_msk_rpt[2];
+	u8 pdsnr[2];	/* DW 4 byte 3 DW 5 Byte 0 */
+
+	/* DWORD 5 */
+	u8 csi_current[2];
+	u8 rx_gain_c;
+
+	/* DWORD 6 */
+	u8 rx_gain_d;
+	u8 sigevm;
+	u8 resvd_0;
+	u8 antidx_anta:3;
+	u8 antidx_antb:3;
+	u8 resvd_1:2;
+} __packed;
+
+struct rx_fwinfo_8821ae {
+	u8 gain_trsw[4];
+	u8 pwdb_all;
+	u8 cfosho[4];
+	u8 cfotail[4];
+	char rxevm[2];
+	char rxsnr[4];
+	u8 pdsnr[2];
+	u8 csi_current[2];
+	u8 csi_target[2];
+	u8 sigevm;
+	u8 max_ex_pwr;
+	u8 ex_intf_flag:1;
+	u8 sgi_en:1;
+	u8 rxsc:2;
+	u8 reserve:4;
+} __packed;
+
+struct tx_desc_8821ae {
+	u32 pktsize:16;
+	u32 offset:8;
+	u32 bmc:1;
+	u32 htc:1;
+	u32 lastseg:1;
+	u32 firstseg:1;
+	u32 linip:1;
+	u32 noacm:1;
+	u32 gf:1;
+	u32 own:1;
+
+	u32 macid:6;
+	u32 rsvd0:2;
+	u32 queuesel:5;
+	u32 rd_nav_ext:1;
+	u32 lsig_txop_en:1;
+	u32 pifs:1;
+	u32 rateid:4;
+	u32 nav_usehdr:1;
+	u32 en_descid:1;
+	u32 sectype:2;
+	u32 pktoffset:8;
+
+	u32 rts_rc:6;
+	u32 data_rc:6;
+	u32 agg_en:1;
+	u32 rdg_en:1;
+	u32 bar_retryht:2;
+	u32 agg_break:1;
+	u32 morefrag:1;
+	u32 raw:1;
+	u32 ccx:1;
+	u32 ampdudensity:3;
+	u32 bt_int:1;
+	u32 ant_sela:1;
+	u32 ant_selb:1;
+	u32 txant_cck:2;
+	u32 txant_l:2;
+	u32 txant_ht:2;
+
+	u32 nextheadpage:8;
+	u32 tailpage:8;
+	u32 seq:12;
+	u32 cpu_handle:1;
+	u32 tag1:1;
+	u32 trigger_int:1;
+	u32 hwseq_en:1;
+
+	u32 rtsrate:5;
+	u32 apdcfe:1;
+	u32 qos:1;
+	u32 hwseq_ssn:1;
+	u32 userrate:1;
+	u32 dis_rtsfb:1;
+	u32 dis_datafb:1;
+	u32 cts2self:1;
+	u32 rts_en:1;
+	u32 hwrts_en:1;
+	u32 portid:1;
+	u32 pwr_status:3;
+	u32 waitdcts:1;
+	u32 cts2ap_en:1;
+	u32 txsc:2;
+	u32 stbc:2;
+	u32 txshort:1;
+	u32 txbw:1;
+	u32 rtsshort:1;
+	u32 rtsbw:1;
+	u32 rtssc:2;
+	u32 rtsstbc:2;
+
+	u32 txrate:6;
+	u32 shortgi:1;
+	u32 ccxt:1;
+	u32 txrate_fb_lmt:5;
+	u32 rtsrate_fb_lmt:4;
+	u32 retrylmt_en:1;
+	u32 txretrylmt:6;
+	u32 usb_txaggnum:8;
+
+	u32 txagca:5;
+	u32 txagcb:5;
+	u32 usemaxlen:1;
+	u32 maxaggnum:5;
+	u32 mcsg1maxlen:4;
+	u32 mcsg2maxlen:4;
+	u32 mcsg3maxlen:4;
+	u32 mcs7sgimaxlen:4;
+
+	u32 txbuffersize:16;
+	u32 sw_offset30:8;
+	u32 sw_offset31:4;
+	u32 rsvd1:1;
+	u32 antsel_c:1;
+	u32 null_0:1;
+	u32 null_1:1;
+
+	u32 txbuffaddr;
+	u32 txbufferaddr64;
+	u32 nextdescaddress;
+	u32 nextdescaddress64;
+
+	u32 reserve_pass_pcie_mm_limit[4];
+} __packed;
+
+struct rx_desc_8821ae {
+	u32 length:14;
+	u32 crc32:1;
+	u32 icverror:1;
+	u32 drv_infosize:4;
+	u32 security:3;
+	u32 qos:1;
+	u32 shift:2;
+	u32 phystatus:1;
+	u32 swdec:1;
+	u32 lastseg:1;
+	u32 firstseg:1;
+	u32 eor:1;
+	u32 own:1;
+
+	u32 macid:6;
+	u32 tid:4;
+	u32 hwrsvd:5;
+	u32 paggr:1;
+	u32 faggr:1;
+	u32 a1_fit:4;
+	u32 a2_fit:4;
+	u32 pam:1;
+	u32 pwr:1;
+	u32 moredata:1;
+	u32 morefrag:1;
+	u32 type:2;
+	u32 mc:1;
+	u32 bc:1;
+
+	u32 seq:12;
+	u32 frag:4;
+	u32 nextpktlen:14;
+	u32 nextind:1;
+	u32 rsvd:1;
+
+	u32 rxmcs:6;
+	u32 rxht:1;
+	u32 amsdu:1;
+	u32 splcp:1;
+	u32 bandwidth:1;
+	u32 htc:1;
+	u32 tcpchk_rpt:1;
+	u32 ipcchk_rpt:1;
+	u32 tcpchk_valid:1;
+	u32 hwpcerr:1;
+	u32 hwpcind:1;
+	u32 iv0:16;
+
+	u32 iv1;
+
+	u32 tsfl;
+
+	u32 bufferaddress;
+	u32 bufferaddress64;
+
+} __packed;
+
+void rtl8821ae_tx_fill_desc(struct ieee80211_hw *hw,
+			    struct ieee80211_hdr *hdr, u8 *pdesc_tx, u8 *txbd,
+			    struct ieee80211_tx_info *info,
+			    struct ieee80211_sta *sta,
+			    struct sk_buff *skb,
+			    u8 hw_queue, struct rtl_tcb_desc *ptcb_desc);
+bool rtl8821ae_rx_query_desc(struct ieee80211_hw *hw,
+			     struct rtl_stats *status,
+			     struct ieee80211_rx_status *rx_status,
+			     u8 *pdesc, struct sk_buff *skb);
+void rtl8821ae_set_desc(struct ieee80211_hw *hw, u8 *pdesc,
+			bool istx, u8 desc_name, u8 *val);
+u32 rtl8821ae_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl8821ae_is_tx_desc_closed(struct ieee80211_hw *hw,
+				 u8 hw_queue, u16 index);
+void rtl8821ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue);
+void rtl8821ae_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			       bool firstseg, bool lastseg,
+			       struct sk_buff *skb);
+u32 rtl8821ae_rx_command_packet(struct ieee80211_hw *hw,
+				struct rtl_stats status,
+				struct sk_buff *skb);
+#endif
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless=
/rtlwifi/wifi.h
index 06b5741..b2a2f51 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -11,10 +11,6 @@
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
  * more details.
  *
- * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
- *
  * The full GNU General Public License is included in this distributio=
n in the
  * file called LICENSE.
  *
@@ -148,6 +144,11 @@
 #define EM_HDR_LEN			8
=20
 #define MAX_TX_COUNT			4
+#define MAX_REGULATION_NUM		4
+#define MAX_RF_PATH_NUM			4
+#define MAX_RATE_SECTION_NUM		6
+#define MAX_2_4G_BANDWITH_NUM		4
+#define MAX_5G_BANDWITH_NUM		4
 #define	MAX_RF_PATH			4
 #define	MAX_CHNL_GROUP_24G		6
 #define	MAX_CHNL_GROUP_5G		14
@@ -249,6 +250,15 @@ enum radio_path {
 	RF90_PATH_D =3D 3,
 };
=20
+enum regulation_txpwr_lmt {
+	TXPWR_LMT_FCC =3D 0,
+	TXPWR_LMT_MKK =3D 1,
+	TXPWR_LMT_ETSI =3D 2,
+	TXPWR_LMT_WW =3D 3,
+
+	TXPWR_LMT_MAX_REGULATION_NUM =3D 4
+};
+
 enum rt_eeprom_type {
 	EEPROM_93C46,
 	EEPROM_93C56,
@@ -376,6 +386,7 @@ enum hw_variables {
 	HW_VAR_DEFAULTKEY2,
 	HW_VAR_DEFAULTKEY3,
 	HW_VAR_SIFS,
+	HW_VAR_R2T_SIFS,
 	HW_VAR_DIFS,
 	HW_VAR_EIFS,
 	HW_VAR_SLOT_TIME,
@@ -427,6 +438,7 @@ enum hw_variables {
 	HW_VAR_H2C_FW_MEDIASTATUSRPT,
 	HW_VAR_H2C_FW_P2P_PS_OFFLOAD,
 	HW_VAR_FW_PSMODE_STATUS,
+	HW_VAR_INIT_RTS_RATE,
 	HW_VAR_RESUME_CLK_ON,
 	HW_VAR_FW_LPS_ACTION,
 	HW_VAR_1X1_RECV_COMBINE,
@@ -789,7 +801,9 @@ enum wireless_mode {
 	WIRELESS_MODE_N_24G =3D 0x10,
 	WIRELESS_MODE_N_5G =3D 0x20,
 	WIRELESS_MODE_AC_5G =3D 0x40,
-	WIRELESS_MODE_AC_24G  =3D 0x80
+	WIRELESS_MODE_AC_24G  =3D 0x80,
+	WIRELESS_MODE_AC_ONLY =3D 0x100,
+	WIRELESS_MODE_MAX =3D 0x800
 };
=20
 #define IS_WIRELESS_MODE_A(wirelessmode)	\
@@ -843,6 +857,22 @@ enum rt_polarity_ctl {
 	RT_POLARITY_HIGH_ACT =3D 1,
 };
=20
+/* After 8188E, we use V2 reason define. 88C/8723A use V1 reason. */
+enum fw_wow_reason_v2 {
+	FW_WOW_V2_PTK_UPDATE_EVENT =3D 0x01,
+	FW_WOW_V2_GTK_UPDATE_EVENT =3D 0x02,
+	FW_WOW_V2_DISASSOC_EVENT =3D 0x04,
+	FW_WOW_V2_DEAUTH_EVENT =3D 0x08,
+	FW_WOW_V2_FW_DISCONNECT_EVENT =3D 0x10,
+	FW_WOW_V2_MAGIC_PKT_EVENT =3D 0x21,
+	FW_WOW_V2_UNICAST_PKT_EVENT =3D 0x22,
+	FW_WOW_V2_PATTERN_PKT_EVENT =3D 0x23,
+	FW_WOW_V2_RTD3_SSID_MATCH_EVENT =3D 0x24,
+	FW_WOW_V2_REALWOW_V2_WAKEUPPKT =3D 0x30,
+	FW_WOW_V2_REALWOW_V2_ACKLOST =3D 0x31,
+	FW_WOW_V2_REASON_MAX =3D 0xff,
+};
+
 enum wolpattern_type {
 	UNICAST_PATTERN =3D 0,
 	MULTICAST_PATTERN =3D 1,
@@ -1182,6 +1212,17 @@ struct rtl_phy {
 	u8 cur_bw20_txpwridx;
 	u8 cur_bw40_txpwridx;
=20
+	char txpwr_limit_2_4g[MAX_REGULATION_NUM]
+			     [MAX_2_4G_BANDWITH_NUM]
+			     [MAX_RATE_SECTION_NUM]
+			     [CHANNEL_MAX_NUMBER_2G]
+			     [MAX_RF_PATH_NUM];
+	char txpwr_limit_5g[MAX_REGULATION_NUM]
+			   [MAX_5G_BANDWITH_NUM]
+			   [MAX_RATE_SECTION_NUM]
+			   [CHANNEL_MAX_NUMBER_5G]
+			   [MAX_RF_PATH_NUM];
+
 	u32 rfreg_chnlval[2];
 	bool apk_done;
 	u32 reg_rf3c[2];	/* pathA / pathB  */
@@ -1425,6 +1466,18 @@ struct rtl_hal {
 	u32 version;		/*version of chip */
 	u8 state;		/*stop 0, start 1 */
 	u8 board_type;
+	u8 external_pa;
+
+	u8 pa_mode;
+	u8 pa_type_2g;
+	u8 pa_type_5g;
+	u8 lna_type_2g;
+	u8 lna_type_5g;
+	u8 external_pa_2g;
+	u8 external_lna_2g;
+	u8 external_pa_5g;
+	u8 external_lna_5g;
+	u8 rfe_type;
=20
 	/*firmware */
 	u32 fwsize;
@@ -1884,12 +1937,14 @@ struct rtl_stats {
 	u16 wakeup:1;
 	u32 timestamp_low;
 	u32 timestamp_high;
+	bool shift;
=20
 	u8 rx_drvinfo_size;
 	u8 rx_bufshift;
 	bool isampdu;
 	bool isfirst_ampdu;
 	bool rx_is40Mhzpacket;
+	u8 rx_packet_bw;
 	u32 rx_pwdb_all;
 	u8 rx_mimo_signalstrength[4];	/*in 0~100 index */
 	s8 rx_mimo_signalquality[4];
@@ -1900,6 +1955,8 @@ struct rtl_stats {
 	s8 rx_mimo_sig_qual[4];
 	u8 rx_pwr[4]; /* per-path's pwdb */
 	u8 rx_snr[4]; /* per-path's SNR */
+	u8 bandwidth;
+	u8 bt_coex_pwr_adjust;
 	bool packet_matchbssid;
 	bool is_cck;
 	bool is_ht;
@@ -1907,6 +1964,10 @@ struct rtl_stats {
 	bool packet_beacon;	/*for rssi */
 	char cck_adc_pwdb[4];	/*for rx path selection */
=20
+	bool is_vht;
+	bool is_short_gi;
+	u8 vht_nss;
+
 	u8 packet_report_type;
=20
 	u32 macid;
@@ -2447,6 +2508,8 @@ struct proxim {
=20
 struct rtl_priv {
 	struct ieee80211_hw *hw;
+	/* Used to load a second firmware */
+	void (*rtl_fw_second_cb)(struct rtl_priv *rtlpriv);
 	struct completion firmware_loading_complete;
 	struct list_head list;
 	struct rtl_priv *buddy_priv;
@@ -2773,6 +2836,26 @@ value to host byte ordering.*/
 	(des)[2] =3D (src)[2], (des)[3] =3D (src)[3],\
 	(des)[4] =3D (src)[4], (des)[5] =3D (src)[5])
=20
+#define	LDPC_HT_ENABLE_RX			BIT(0)
+#define	LDPC_HT_ENABLE_TX			BIT(1)
+#define	LDPC_HT_TEST_TX_ENABLE			BIT(2)
+#define	LDPC_HT_CAP_TX				BIT(3)
+
+#define	STBC_HT_ENABLE_RX			BIT(0)
+#define	STBC_HT_ENABLE_TX			BIT(1)
+#define	STBC_HT_TEST_TX_ENABLE			BIT(2)
+#define	STBC_HT_CAP_TX				BIT(3)
+
+#define	LDPC_VHT_ENABLE_RX			BIT(0)
+#define	LDPC_VHT_ENABLE_TX			BIT(1)
+#define	LDPC_VHT_TEST_TX_ENABLE			BIT(2)
+#define	LDPC_VHT_CAP_TX				BIT(3)
+
+#define	STBC_VHT_ENABLE_RX			BIT(0)
+#define	STBC_VHT_ENABLE_TX			BIT(1)
+#define	STBC_VHT_TEST_TX_ENABLE			BIT(2)
+#define	STBC_VHT_CAP_TX				BIT(3)
+
 static inline u8 rtl_read_byte(struct rtl_priv *rtlpriv, u32 addr)
 {
 	return rtlpriv->io.read8_sync(rtlpriv, addr);
--=20
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
