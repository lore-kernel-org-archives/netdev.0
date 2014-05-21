From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/4] staging: r8192ee: Add the files in the rtl8192ee directory
Date: Wed, 21 May 2014 16:25:35 -0500
Message-ID: <1400707536-3338-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>, zhangfp1@lenovo.com,
	troy_tan@realsil.com.cn
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:52934 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaEUV0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:26:09 -0400
Received: by mail-ob0-f180.google.com with SMTP id va2so2856088obc.39
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 14:26:08 -0700 (PDT)
In-Reply-To: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These files are specific to the RTL8192EE

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8192ee/rtl8192ee/def.h       |  106 +
 drivers/staging/rtl8192ee/rtl8192ee/dm.c        | 1258 +++++++++
 drivers/staging/rtl8192ee/rtl8192ee/dm.h        |  343 +++
 drivers/staging/rtl8192ee/rtl8192ee/fw.c        |  945 +++++++
 drivers/staging/rtl8192ee/rtl8192ee/fw.h        |  213 ++
 drivers/staging/rtl8192ee/rtl8192ee/hw.c        | 2544 ++++++++++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/hw.h        |   67 +
 drivers/staging/rtl8192ee/rtl8192ee/led.c       |  134 +
 drivers/staging/rtl8192ee/rtl8192ee/led.h       |   37 +
 drivers/staging/rtl8192ee/rtl8192ee/phy.c       | 3282 +++++++++++++++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/phy.h       |  154 ++
 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c    |  108 +
 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h    |  355 +++
 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c |  139 +
 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h |   69 +
 drivers/staging/rtl8192ee/rtl8192ee/reg.h       | 2240 ++++++++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/rf.c        |  150 ++
 drivers/staging/rtl8192ee/rtl8192ee/rf.h        |   39 +
 drivers/staging/rtl8192ee/rtl8192ee/sw.c        |  428 +++
 drivers/staging/rtl8192ee/rtl8192ee/sw.h        |   39 +
 drivers/staging/rtl8192ee/rtl8192ee/table.c     |  882 ++++++
 drivers/staging/rtl8192ee/rtl8192ee/table.h     |   48 +
 drivers/staging/rtl8192ee/rtl8192ee/trx.c       | 1286 +++++++++
 drivers/staging/rtl8192ee/rtl8192ee/trx.h       |  877 ++++++
 24 files changed, 15743 insertions(+)
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/def.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/dm.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/dm.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/fw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/fw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/hw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/hw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/led.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/led.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/phy.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/phy.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/reg.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/rf.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/rf.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/sw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/sw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/table.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/table.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/trx.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/trx.h

diff --git a/drivers/staging/rtl8192ee/rtl8192ee/def.h b/drivers/staging/rtl8192ee/rtl8192ee/def.h
new file mode 100644
index 0000000..7566c1e
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/def.h
@@ -0,0 +1,106 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_DEF_H__
+#define __RTL92E_DEF_H__
+
+#define RX_DESC_NUM_92E					512
+
+#define HAL_PRIME_CHNL_OFFSET_DONT_CARE			0
+#define HAL_PRIME_CHNL_OFFSET_LOWER			1
+#define HAL_PRIME_CHNL_OFFSET_UPPER			2
+
+#define RX_MPDU_QUEUE					0
+
+#define IS_HT_RATE(_rate)	\
+	(_rate >= DESC92C_RATEMCS0)
+#define IS_CCK_RATE(_rate)	\
+	(_rate >= DESC92C_RATE1M && _rate <= DESC92C_RATE11M)
+#define IS_OFDM_RATE(_rate)	\
+	(_rate >= DESC92C_RATE6M && _rate <= DESC92C_RATE54M)
+
+
+enum version_8192e {
+	VERSION_TEST_CHIP_2T2R_8192E = 0x0024,
+	VERSION_NORMAL_CHIP_2T2R_8192E = 0x102C,
+	VERSION_UNKNOWN = 0xFF,
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
+enum rtl_desc_qsel {
+	QSLT_BK = 0x2,
+	QSLT_BE = 0x0,
+	QSLT_VI = 0x5,
+	QSLT_VO = 0x7,
+	QSLT_BEACON = 0x10,
+	QSLT_HIGH = 0x11,
+	QSLT_MGNT = 0x12,
+	QSLT_CMD = 0x13,
+};
+
+enum rtl_desc92c_rate {
+	DESC92C_RATE1M = 0x00,
+	DESC92C_RATE2M = 0x01,
+	DESC92C_RATE5_5M = 0x02,
+	DESC92C_RATE11M = 0x03,
+
+	DESC92C_RATE6M = 0x04,
+	DESC92C_RATE9M = 0x05,
+	DESC92C_RATE12M = 0x06,
+	DESC92C_RATE18M = 0x07,
+	DESC92C_RATE24M = 0x08,
+	DESC92C_RATE36M = 0x09,
+	DESC92C_RATE48M = 0x0a,
+	DESC92C_RATE54M = 0x0b,
+
+	DESC92C_RATEMCS0 = 0x0c,
+	DESC92C_RATEMCS1 = 0x0d,
+	DESC92C_RATEMCS2 = 0x0e,
+	DESC92C_RATEMCS3 = 0x0f,
+	DESC92C_RATEMCS4 = 0x10,
+	DESC92C_RATEMCS5 = 0x11,
+	DESC92C_RATEMCS6 = 0x12,
+	DESC92C_RATEMCS7 = 0x13,
+	DESC92C_RATEMCS8 = 0x14,
+	DESC92C_RATEMCS9 = 0x15,
+	DESC92C_RATEMCS10 = 0x16,
+	DESC92C_RATEMCS11 = 0x17,
+	DESC92C_RATEMCS12 = 0x18,
+	DESC92C_RATEMCS13 = 0x19,
+	DESC92C_RATEMCS14 = 0x1a,
+	DESC92C_RATEMCS15 = 0x1b,
+};
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/dm.c b/drivers/staging/rtl8192ee/rtl8192ee/dm.c
new file mode 100644
index 0000000..41c2d98
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/dm.c
@@ -0,0 +1,1258 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
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
+
+struct dig_t dm_dig;
+
+static const u32 ofdmswing_table[OFDM_TABLE_SIZE] = {
+	0x7f8001fe,		/* 0, +6.0dB */
+	0x788001e2,		/* 1, +5.5dB */
+	0x71c001c7,		/* 2, +5.0dB */
+	0x6b8001ae,		/* 3, +4.5dB */
+	0x65400195,		/* 4, +4.0dB */
+	0x5fc0017f,		/* 5, +3.5dB */
+	0x5a400169,		/* 6, +3.0dB */
+	0x55400155,		/* 7, +2.5dB */
+	0x50800142,		/* 8, +2.0dB */
+	0x4c000130,		/* 9, +1.5dB */
+	0x47c0011f,		/* 10, +1.0dB */
+	0x43c0010f,		/* 11, +0.5dB */
+	0x40000100,		/* 12, +0dB */
+	0x3c8000f2,		/* 13, -0.5dB */
+	0x390000e4,		/* 14, -1.0dB */
+	0x35c000d7,		/* 15, -1.5dB */
+	0x32c000cb,		/* 16, -2.0dB */
+	0x300000c0,		/* 17, -2.5dB */
+	0x2d4000b5,		/* 18, -3.0dB */
+	0x2ac000ab,		/* 19, -3.5dB */
+	0x288000a2,		/* 20, -4.0dB */
+	0x26000098,		/* 21, -4.5dB */
+	0x24000090,		/* 22, -5.0dB */
+	0x22000088,		/* 23, -5.5dB */
+	0x20000080,		/* 24, -6.0dB */
+	0x1e400079,		/* 25, -6.5dB */
+	0x1c800072,		/* 26, -7.0dB */
+	0x1b00006c,		/* 27. -7.5dB */
+	0x19800066,		/* 28, -8.0dB */
+	0x18000060,		/* 29, -8.5dB */
+	0x16c0005b,		/* 30, -9.0dB */
+	0x15800056,		/* 31, -9.5dB */
+	0x14400051,		/* 32, -10.0dB */
+	0x1300004c,		/* 33, -10.5dB */
+	0x12000048,		/* 34, -11.0dB */
+	0x11000044,		/* 35, -11.5dB */
+	0x10000040,		/* 36, -12.0dB */
+	0x0f00003c,		/* 37, -12.5dB */
+	0x0e400039,		/* 38, -13.0dB */
+	0x0d800036,		/* 39, -13.5dB */
+	0x0cc00033,		/* 40, -14.0dB */
+	0x0c000030,		/* 41, -14.5dB */
+	0x0b40002d,		/* 42, -15.0dB */
+};
+
+static const u8 cckswing_table_ch1ch13[CCK_TABLE_SIZE][8] = {
+	{0x36, 0x35, 0x2e, 0x25, 0x1c, 0x12, 0x09, 0x04}, /* 0, +0dB */
+	{0x33, 0x32, 0x2b, 0x23, 0x1a, 0x11, 0x08, 0x04}, /* 1, -0.5dB */
+	{0x30, 0x2f, 0x29, 0x21, 0x19, 0x10, 0x08, 0x03}, /* 2, -1.0dB */
+	{0x2d, 0x2d, 0x27, 0x1f, 0x18, 0x0f, 0x08, 0x03}, /* 3, -1.5dB */
+	{0x2b, 0x2a, 0x25, 0x1e, 0x16, 0x0e, 0x07, 0x03}, /* 4, -2.0dB */
+	{0x28, 0x28, 0x22, 0x1c, 0x15, 0x0d, 0x07, 0x03}, /* 5, -2.5dB */
+	{0x26, 0x25, 0x21, 0x1b, 0x14, 0x0d, 0x06, 0x03}, /* 6, -3.0dB */
+	{0x24, 0x23, 0x1f, 0x19, 0x13, 0x0c, 0x06, 0x03}, /* 7, -3.5dB */
+	{0x22, 0x21, 0x1d, 0x18, 0x11, 0x0b, 0x06, 0x02}, /* 8, -4.0dB */
+	{0x20, 0x20, 0x1b, 0x16, 0x11, 0x08, 0x05, 0x02}, /* 9, -4.5dB */
+	{0x1f, 0x1e, 0x1a, 0x15, 0x10, 0x0a, 0x05, 0x02}, /* 10, -5.0dB */
+	{0x1d, 0x1c, 0x18, 0x14, 0x0f, 0x0a, 0x05, 0x02}, /* 11, -5.5dB */
+	{0x1b, 0x1a, 0x17, 0x13, 0x0e, 0x09, 0x04, 0x02}, /* 12, -6.0dB */
+	{0x1a, 0x19, 0x16, 0x12, 0x0d, 0x09, 0x04, 0x02}, /* 13, -6.5dB */
+	{0x18, 0x17, 0x15, 0x11, 0x0c, 0x08, 0x04, 0x02}, /* 14, -7.0dB */
+	{0x17, 0x16, 0x13, 0x10, 0x0c, 0x08, 0x04, 0x02}, /* 15, -7.5dB */
+	{0x16, 0x15, 0x12, 0x0f, 0x0b, 0x07, 0x04, 0x01}, /* 16, -8.0dB */
+	{0x14, 0x14, 0x11, 0x0e, 0x0b, 0x07, 0x03, 0x02}, /* 17, -8.5dB */
+	{0x13, 0x13, 0x10, 0x0d, 0x0a, 0x06, 0x03, 0x01}, /* 18, -9.0dB */
+	{0x12, 0x12, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /* 19, -9.5dB */
+	{0x11, 0x11, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01}, /* 20, -10.0dB */
+	{0x10, 0x10, 0x0e, 0x0b, 0x08, 0x05, 0x03, 0x01}, /* 21, -10.5dB */
+	{0x0f, 0x0f, 0x0d, 0x0b, 0x08, 0x05, 0x03, 0x01}, /* 22, -11.0dB */
+	{0x0e, 0x0e, 0x0c, 0x0a, 0x08, 0x05, 0x02, 0x01}, /* 23, -11.5dB */
+	{0x0d, 0x0d, 0x0c, 0x0a, 0x07, 0x05, 0x02, 0x01}, /* 24, -12.0dB */
+	{0x0d, 0x0c, 0x0b, 0x09, 0x07, 0x04, 0x02, 0x01}, /* 25, -12.5dB */
+	{0x0c, 0x0c, 0x0a, 0x09, 0x06, 0x04, 0x02, 0x01}, /* 26, -13.0dB */
+	{0x0b, 0x0b, 0x0a, 0x08, 0x06, 0x04, 0x02, 0x01}, /* 27, -13.5dB */
+	{0x0b, 0x0a, 0x09, 0x08, 0x06, 0x04, 0x02, 0x01}, /* 28, -14.0dB */
+	{0x0a, 0x0a, 0x09, 0x07, 0x05, 0x03, 0x02, 0x01}, /* 29, -14.5dB */
+	{0x0a, 0x09, 0x08, 0x07, 0x05, 0x03, 0x02, 0x01}, /* 30, -15.0dB */
+	{0x09, 0x09, 0x08, 0x06, 0x05, 0x03, 0x01, 0x01}, /* 31, -15.5dB */
+	{0x09, 0x08, 0x07, 0x06, 0x04, 0x03, 0x01, 0x01}  /* 32, -16.0dB */
+};
+
+static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] = {
+	{0x36, 0x35, 0x2e, 0x1b, 0x00, 0x00, 0x00, 0x00}, /* 0, +0dB */
+	{0x33, 0x32, 0x2b, 0x19, 0x00, 0x00, 0x00, 0x00}, /* 1, -0.5dB */
+	{0x30, 0x2f, 0x29, 0x18, 0x00, 0x00, 0x00, 0x00}, /* 2, -1.0dB */
+	{0x2d, 0x2d, 0x17, 0x17, 0x00, 0x00, 0x00, 0x00}, /* 3, -1.5dB */
+	{0x2b, 0x2a, 0x25, 0x15, 0x00, 0x00, 0x00, 0x00}, /* 4, -2.0dB */
+	{0x28, 0x28, 0x24, 0x14, 0x00, 0x00, 0x00, 0x00}, /* 5, -2.5dB */
+	{0x26, 0x25, 0x21, 0x13, 0x00, 0x00, 0x00, 0x00}, /* 6, -3.0dB */
+	{0x24, 0x23, 0x1f, 0x12, 0x00, 0x00, 0x00, 0x00}, /* 7, -3.5dB */
+	{0x22, 0x21, 0x1d, 0x11, 0x00, 0x00, 0x00, 0x00}, /* 8, -4.0dB */
+	{0x20, 0x20, 0x1b, 0x10, 0x00, 0x00, 0x00, 0x00}, /* 9, -4.5dB */
+	{0x1f, 0x1e, 0x1a, 0x0f, 0x00, 0x00, 0x00, 0x00}, /* 10, -5.0dB */
+	{0x1d, 0x1c, 0x18, 0x0e, 0x00, 0x00, 0x00, 0x00}, /* 11, -5.5dB */
+	{0x1b, 0x1a, 0x17, 0x0e, 0x00, 0x00, 0x00, 0x00}, /* 12, -6.0dB */
+	{0x1a, 0x19, 0x16, 0x0d, 0x00, 0x00, 0x00, 0x00}, /* 13, -6.5dB */
+	{0x18, 0x17, 0x15, 0x0c, 0x00, 0x00, 0x00, 0x00}, /* 14, -7.0dB */
+	{0x17, 0x16, 0x13, 0x0b, 0x00, 0x00, 0x00, 0x00}, /* 15, -7.5dB */
+	{0x16, 0x15, 0x12, 0x0b, 0x00, 0x00, 0x00, 0x00}, /* 16, -8.0dB */
+	{0x14, 0x14, 0x11, 0x0a, 0x00, 0x00, 0x00, 0x00}, /* 17, -8.5dB */
+	{0x13, 0x13, 0x10, 0x0a, 0x00, 0x00, 0x00, 0x00}, /* 18, -9.0dB */
+	{0x12, 0x12, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /* 19, -9.5dB */
+	{0x11, 0x11, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00}, /* 20, -10.0dB */
+	{0x10, 0x10, 0x0e, 0x08, 0x00, 0x00, 0x00, 0x00}, /* 21, -10.5dB */
+	{0x0f, 0x0f, 0x0d, 0x08, 0x00, 0x00, 0x00, 0x00}, /* 22, -11.0dB */
+	{0x0e, 0x0e, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /* 23, -11.5dB */
+	{0x0d, 0x0d, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00}, /* 24, -12.0dB */
+	{0x0d, 0x0c, 0x0b, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 25, -12.5dB */
+	{0x0c, 0x0c, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 26, -13.0dB */
+	{0x0b, 0x0b, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00}, /* 27, -13.5dB */
+	{0x0b, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 28, -14.0dB */
+	{0x0a, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 29, -14.5dB */
+	{0x0a, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 30, -15.0dB */
+	{0x09, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00}, /* 31, -15.5dB */
+	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}  /* 32, -16.0dB */
+};
+
+static void rtl92ee_dm_diginit(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	dm_dig.cur_igvalue = rtl_get_bbreg(hw, DM_REG_IGI_A_11N,
+						DM_BIT_IGI_11N);
+	dm_dig.rssi_lowthresh = DM_DIG_THRESH_LOW;
+	dm_dig.rssi_highthresh = DM_DIG_THRESH_HIGH;
+	dm_dig.fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
+	dm_dig.fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
+	dm_dig.rx_gain_range_max = DM_DIG_MAX;
+	dm_dig.rx_gain_range_min = DM_DIG_MIN;
+	dm_dig.backoff_val = DM_DIG_BACKOFF_DEFAULT;
+	dm_dig.backoff_val_range_max = DM_DIG_BACKOFF_MAX;
+	dm_dig.backoff_val_range_min = DM_DIG_BACKOFF_MIN;
+	dm_dig.pre_cck_cca_thres = 0xff;
+	dm_dig.cur_cck_cca_thres = 0x83;
+	dm_dig.forbidden_igi = DM_DIG_MIN;
+	dm_dig.large_fa_hit = 0;
+	dm_dig.recover_cnt = 0;
+	dm_dig.dig_dynamic_min_0 = DM_DIG_MIN;
+	dm_dig.dig_dynamic_min_1 = DM_DIG_MIN;
+	dm_dig.b_media_connect_0 = false;
+	dm_dig.b_media_connect_1 = false;
+	rtlpriv->dm.b_dm_initialgain_enable = true;
+	dm_dig.bt30_cur_igi = 0x32;
+}
+
+static void rtl92ee_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
+{
+	u32 ret_value;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
+
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_HOLDC_11N, BIT(31), 1);
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTD_11N, BIT(31), 1);
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_OFDM_FA_TYPE1_11N, MASKDWORD);
+	falsealm_cnt->cnt_fast_fsync_fail = (ret_value & 0xffff);
+	falsealm_cnt->cnt_sb_search_fail = ((ret_value & 0xffff0000) >> 16);
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_OFDM_FA_TYPE2_11N, MASKDWORD);
+	falsealm_cnt->cnt_ofdm_cca = (ret_value & 0xffff);
+	falsealm_cnt->cnt_parity_fail = ((ret_value & 0xffff0000) >> 16);
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_OFDM_FA_TYPE3_11N, MASKDWORD);
+	falsealm_cnt->cnt_rate_illegal = (ret_value & 0xffff);
+	falsealm_cnt->cnt_crc8_fail = ((ret_value & 0xffff0000) >> 16);
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_OFDM_FA_TYPE4_11N, MASKDWORD);
+	falsealm_cnt->cnt_mcs_fail = (ret_value & 0xffff);
+
+	falsealm_cnt->cnt_ofdm_fail = falsealm_cnt->cnt_parity_fail +
+				      falsealm_cnt->cnt_rate_illegal +
+				      falsealm_cnt->cnt_crc8_fail +
+				      falsealm_cnt->cnt_mcs_fail +
+				      falsealm_cnt->cnt_fast_fsync_fail +
+				      falsealm_cnt->cnt_sb_search_fail;
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_SC_CNT_11N, MASKDWORD);
+	falsealm_cnt->cnt_bw_lsc = (ret_value & 0xffff);
+	falsealm_cnt->cnt_bw_usc = ((ret_value & 0xffff0000) >> 16);
+
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(12), 1);
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(14), 1);
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_CCK_FA_LSB_11N, MASKBYTE0);
+	falsealm_cnt->cnt_cck_fail = ret_value;
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_CCK_FA_MSB_11N, MASKBYTE3);
+	falsealm_cnt->cnt_cck_fail += (ret_value & 0xff) << 8;
+
+	ret_value = rtl_get_bbreg(hw, DM_REG_CCK_CCA_CNT_11N, MASKDWORD);
+	falsealm_cnt->cnt_cck_cca = ((ret_value & 0xff) << 8) |
+				    ((ret_value & 0xFF00) >> 8);
+
+	falsealm_cnt->cnt_all = falsealm_cnt->cnt_fast_fsync_fail +
+				falsealm_cnt->cnt_sb_search_fail +
+				falsealm_cnt->cnt_parity_fail +
+				falsealm_cnt->cnt_rate_illegal +
+				falsealm_cnt->cnt_crc8_fail +
+				falsealm_cnt->cnt_mcs_fail +
+				falsealm_cnt->cnt_cck_fail;
+
+	falsealm_cnt->cnt_cca_all = falsealm_cnt->cnt_ofdm_cca +
+				    falsealm_cnt->cnt_cck_cca;
+
+	/*reset false alarm counter registers*/
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTC_11N, BIT(31), 1);
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTC_11N, BIT(31), 0);
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTD_11N, BIT(27), 1);
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTD_11N, BIT(27), 0);
+	/*update ofdm counter*/
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_HOLDC_11N, BIT(31), 0);
+	rtl_set_bbreg(hw, DM_REG_OFDM_FA_RSTD_11N, BIT(31), 0);
+	/*reset CCK CCA counter*/
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(13) | BIT(12), 0);
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(13) | BIT(12), 2);
+	/*reset CCK FA counter*/
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(15) | BIT(14), 0);
+	rtl_set_bbreg(hw, DM_REG_CCK_FA_RST_11N, BIT(15) | BIT(14), 2);
+
+
+	RT_TRACE(COMP_DIG, DBG_TRACE,
+		 ("cnt_parity_fail = %d, cnt_rate_illegal = %d, "
+		  "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		  falsealm_cnt->cnt_parity_fail,
+		  falsealm_cnt->cnt_rate_illegal,
+		  falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail));
+
+	RT_TRACE(COMP_DIG, DBG_TRACE,
+		 ("cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
+		  falsealm_cnt->cnt_ofdm_fail,
+		  falsealm_cnt->cnt_cck_fail, falsealm_cnt->cnt_all));
+}
+
+static void rtl92ee_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 cur_cck_cca_thresh;
+	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
+		if (dm_dig.rssi_val_min > 25) {
+			cur_cck_cca_thresh = 0xcd;
+		} else if ((dm_dig.rssi_val_min <= 25) &&
+			   (dm_dig.rssi_val_min > 10)) {
+			cur_cck_cca_thresh = 0x83;
+		} else {
+			if (rtlpriv->falsealm_cnt.cnt_cck_fail > 1000)
+				cur_cck_cca_thresh = 0x83;
+			else
+				cur_cck_cca_thresh = 0x40;
+		}
+	} else {
+		if (rtlpriv->falsealm_cnt.cnt_cck_fail > 1000)
+			cur_cck_cca_thresh = 0x83;
+		else
+			cur_cck_cca_thresh = 0x40;
+	}
+	rtl92ee_dm_write_cck_cca_thres(hw, cur_cck_cca_thresh);
+}
+
+static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	u8 dig_dynamic_min , dig_maxofmin;
+	bool bfirstconnect , bfirstdisconnect;
+	u8 dm_dig_max, dm_dig_min;
+	u8 current_igi = dm_dig.cur_igvalue;
+	u8 offset;
+
+	/* AP, BT */
+	if (mac->act_scanning == true)
+		return;
+
+	dig_dynamic_min = dm_dig.dig_dynamic_min_0;
+	bfirstconnect = (mac->link_state >= MAC80211_LINKED) &&
+			(dm_dig.b_media_connect_0 == false);
+	bfirstdisconnect = (mac->link_state < MAC80211_LINKED) &&
+			   (dm_dig.b_media_connect_0 == true);
+
+	dm_dig_max = 0x5a;
+	dm_dig_min = DM_DIG_MIN;
+	dig_maxofmin = DM_DIG_MAX_AP;
+
+	if (mac->link_state >= MAC80211_LINKED) {
+		if ((dm_dig.rssi_val_min + 10) > dm_dig_max)
+			dm_dig.rx_gain_range_max = dm_dig_max;
+		else if ((dm_dig.rssi_val_min + 10) < dm_dig_min)
+			dm_dig.rx_gain_range_max = dm_dig_min;
+		else
+			dm_dig.rx_gain_range_max = dm_dig.rssi_val_min + 10;
+
+		if (rtlpriv->dm.b_one_entry_only) {
+			offset = 0;
+			if (dm_dig.rssi_val_min - offset < dm_dig_min)
+				dig_dynamic_min = dm_dig_min;
+			else if (dm_dig.rssi_val_min - offset >
+				 dig_maxofmin)
+				dig_dynamic_min = dig_maxofmin;
+			else
+				dig_dynamic_min = dm_dig.rssi_val_min - offset;
+		} else {
+			dig_dynamic_min = dm_dig_min;
+		}
+
+	} else {
+		dm_dig.rx_gain_range_max = dm_dig_max;
+		dig_dynamic_min = dm_dig_min;
+		RT_TRACE(COMP_DIG, DBG_LOUD, ("no link\n"));
+	}
+
+	if (rtlpriv->falsealm_cnt.cnt_all > 10000) {
+		if (dm_dig.large_fa_hit != 3)
+			dm_dig.large_fa_hit++;
+		if (dm_dig.forbidden_igi < current_igi) {
+			dm_dig.forbidden_igi = current_igi;
+			dm_dig.large_fa_hit = 1;
+		}
+
+		if (dm_dig.large_fa_hit >= 3) {
+			if (dm_dig.forbidden_igi + 1 > dm_dig.rx_gain_range_max)
+				dm_dig.rx_gain_range_min =
+						dm_dig.rx_gain_range_max;
+			else
+				dm_dig.rx_gain_range_min =
+						dm_dig.forbidden_igi + 1;
+			dm_dig.recover_cnt = 3600;
+		}
+	} else {
+		if (dm_dig.recover_cnt != 0) {
+			dm_dig.recover_cnt--;
+		} else {
+			if (dm_dig.large_fa_hit < 3) {
+				if ((dm_dig.forbidden_igi - 1) <
+				    dig_dynamic_min) {
+					dm_dig.forbidden_igi = dig_dynamic_min;
+					dm_dig.rx_gain_range_min =
+								dig_dynamic_min;
+				} else {
+					dm_dig.forbidden_igi--;
+					dm_dig.rx_gain_range_min =
+						dm_dig.forbidden_igi + 1;
+				}
+			} else {
+				dm_dig.large_fa_hit = 0;
+			}
+		}
+	}
+
+	if (rtlpriv->dm.dbginfo.num_qry_beacon_pkt < 5)
+		dm_dig.rx_gain_range_min = dm_dig_min;
+
+	if (dm_dig.rx_gain_range_min > dm_dig.rx_gain_range_max)
+		dm_dig.rx_gain_range_min = dm_dig.rx_gain_range_max;
+
+	if (mac->link_state >= MAC80211_LINKED) {
+		if (bfirstconnect) {
+			if (dm_dig.rssi_val_min <= dig_maxofmin)
+				current_igi = dm_dig.rssi_val_min;
+			else
+				current_igi = dig_maxofmin;
+
+			dm_dig.large_fa_hit = 0;
+		} else {
+			if (rtlpriv->falsealm_cnt.cnt_all > DM_DIG_FA_TH2)
+				current_igi += 4;
+			else if (rtlpriv->falsealm_cnt.cnt_all > DM_DIG_FA_TH1)
+				current_igi += 2;
+			else if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH0)
+				current_igi -= 2;
+
+			if (rtlpriv->dm.dbginfo.num_qry_beacon_pkt < 5 &&
+			    rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH1)
+				current_igi = dm_dig.rx_gain_range_min;
+		}
+	} else {
+		if (bfirstdisconnect) {
+			current_igi = dm_dig.rx_gain_range_min;
+		} else {
+			if (rtlpriv->falsealm_cnt.cnt_all > 10000)
+				current_igi += 4;
+			else if (rtlpriv->falsealm_cnt.cnt_all > 8000)
+				current_igi += 2;
+			else if (rtlpriv->falsealm_cnt.cnt_all < 500)
+				current_igi -= 2;
+		}
+	}
+
+	if (current_igi > dm_dig.rx_gain_range_max)
+		current_igi = dm_dig.rx_gain_range_max;
+	if (current_igi < dm_dig.rx_gain_range_min)
+		current_igi = dm_dig.rx_gain_range_min;
+
+	rtl92ee_dm_write_dig(hw , current_igi);
+	dm_dig.b_media_connect_0 = ((mac->link_state >= MAC80211_LINKED) ?
+				   true : false);
+	dm_dig.dig_dynamic_min_0 = dig_dynamic_min;
+}
+
+void rtl92ee_dm_write_cck_cca_thres(struct ieee80211_hw *hw, u8 cur_thres)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	if (dm_dig.cur_cck_cca_thres != cur_thres)
+		rtl_write_byte(rtlpriv, DM_REG_CCK_CCA_11N, cur_thres);
+
+	dm_dig.pre_cck_cca_thres = dm_dig.cur_cck_cca_thres;
+	dm_dig.cur_cck_cca_thres = cur_thres;
+}
+
+void rtl92ee_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	if (dm_dig.stop_dig)
+		return;
+
+	if (dm_dig.cur_igvalue != current_igi) {
+		rtl_set_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f, current_igi);
+		if (rtlpriv->phy.rf_type != RF_1T1R)
+			rtl_set_bbreg(hw, ROFDM0_XBAGCCORE1, 0x7f, current_igi);
+	}
+	dm_dig.pre_igvalue = dm_dig.cur_igvalue;
+	dm_dig.cur_igvalue = current_igi;
+}
+
+static void rtl92ee_rssi_dump_to_register(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	rtl_write_byte(rtlpriv, RA_RSSIDUMP,
+		       rtlpriv->stats.rx_rssi_percentage[0]);
+	rtl_write_byte(rtlpriv, RB_RSSIDUMP,
+		       rtlpriv->stats.rx_rssi_percentage[1]);
+	/*It seems the following values is not initialized.
+	  *According to Windows code,
+	  *these value will only be valid when JAGUAR chips*/
+	/* Rx EVM */
+	rtl_write_byte(rtlpriv, RS1_RXEVMDUMP, rtlpriv->stats.rx_evm_dbm[0]);
+	rtl_write_byte(rtlpriv, RS2_RXEVMDUMP, rtlpriv->stats.rx_evm_dbm[1]);
+	/* Rx SNR */
+	rtl_write_byte(rtlpriv, RA_RXSNRDUMP,
+		       (u8)(rtlpriv->stats.rx_snr_db[0]));
+	rtl_write_byte(rtlpriv, RB_RXSNRDUMP,
+		       (u8)(rtlpriv->stats.rx_snr_db[1]));
+	/* Rx Cfo_Short */
+	rtl_write_word(rtlpriv, RA_CFOSHORTDUMP,
+		       rtlpriv->stats.rx_cfo_short[0]);
+	rtl_write_word(rtlpriv, RB_CFOSHORTDUMP,
+		       rtlpriv->stats.rx_cfo_short[1]);
+	/* Rx Cfo_Tail */
+	rtl_write_word(rtlpriv, RA_CFOLONGDUMP, rtlpriv->stats.rx_cfo_tail[0]);
+	rtl_write_word(rtlpriv, RB_CFOLONGDUMP, rtlpriv->stats.rx_cfo_tail[1]);
+}
+
+static void rtl92ee_dm_find_minimum_rssi(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_dig *rtl_dm_dig = &(rtlpriv->dm.dm_digtable);
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+
+	/* Determine the minimum RSSI  */
+	if ((mac->link_state < MAC80211_LINKED) &&
+	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+		rtl_dm_dig->min_undecorated_pwdb_for_dm = 0;
+		RT_TRACE(COMP_BB_POWERSAVING, DBG_LOUD,
+			 ("Not connected to any\n"));
+	}
+	if (mac->link_state >= MAC80211_LINKED) {
+		if (mac->opmode == NL80211_IFTYPE_AP ||
+		    mac->opmode == NL80211_IFTYPE_ADHOC) {
+			rtl_dm_dig->min_undecorated_pwdb_for_dm =
+				rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			RT_TRACE(COMP_BB_POWERSAVING, DBG_LOUD,
+			      ("AP Client PWDB = 0x%lx\n",
+			       rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb));
+		} else {
+			rtl_dm_dig->min_undecorated_pwdb_for_dm =
+			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			RT_TRACE(COMP_BB_POWERSAVING, DBG_LOUD,
+				("STA Default Port PWDB = 0x%x\n",
+				rtl_dm_dig->min_undecorated_pwdb_for_dm));
+		}
+	} else {
+		rtl_dm_dig->min_undecorated_pwdb_for_dm =
+			rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		RT_TRACE(COMP_BB_POWERSAVING, DBG_LOUD,
+			("AP Ext Port or disconnet PWDB = 0x%x\n",
+			rtl_dm_dig->min_undecorated_pwdb_for_dm));
+	}
+	RT_TRACE(COMP_DIG, DBG_LOUD, ("MinUndecoratedPWDBForDM =%d\n",
+		rtl_dm_dig->min_undecorated_pwdb_for_dm));
+}
+
+static void rtl92ee_dm_check_rssi_monitor(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtlpriv);
+	struct rtl_dm *dm = rtl_dm(rtlpriv);
+	struct rtl_sta_info *drv_priv;
+	u8 h2c[4] = { 0 };
+	long max = 0, min = 0xff;
+	u8 i = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_AP ||
+	    mac->opmode == NL80211_IFTYPE_ADHOC ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
+		/* AP & ADHOC & MESH */
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
+			struct rssi_sta *stat = &(drv_priv->rssi_stat);
+			if (stat->undecorated_smoothed_pwdb < min)
+				min = stat->undecorated_smoothed_pwdb;
+			if (stat->undecorated_smoothed_pwdb > max)
+				max = stat->undecorated_smoothed_pwdb;
+
+			h2c[3] = 0;
+			h2c[2] = (u8) (dm->undecorated_smoothed_pwdb & 0xFF);
+			h2c[1] = 0x20;
+			h2c[0] = ++i;
+			rtl92ee_fill_h2c_cmd(hw, H2C_92E_RSSI_REPORT, 4, h2c);
+		}
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+
+		/* If associated entry is found */
+		if (max != 0) {
+			dm->entry_max_undecoratedsmoothed_pwdb = max;
+			RTPRINT(rtlpriv, FDM, DM_PWDB,
+				"EntryMaxPWDB = 0x%lx(%ld)\n", max, max);
+		} else {
+			dm->entry_max_undecoratedsmoothed_pwdb = 0;
+		}
+		/* If associated entry is found */
+		if (min != 0xff) {
+			dm->entry_min_undecoratedsmoothed_pwdb = min;
+			RTPRINT(rtlpriv, FDM, DM_PWDB,
+				"EntryMinPWDB = 0x%lx(%ld)\n", min, min);
+		} else {
+			dm->entry_min_undecoratedsmoothed_pwdb = 0;
+		}
+	}
+
+	/* Indicate Rx signal strength to FW. */
+	if (dm->b_useramask) {
+		h2c[3] = 0;
+		h2c[2] = (u8) (dm->undecorated_smoothed_pwdb & 0xFF);
+		h2c[1] = 0x20;
+		h2c[0] = 0;
+		rtl92ee_fill_h2c_cmd(hw, H2C_92E_RSSI_REPORT, 4, h2c);
+	} else {
+		rtl_write_byte(rtlpriv, 0x4fe, dm->undecorated_smoothed_pwdb);
+	}
+	rtl92ee_rssi_dump_to_register(hw);
+	rtl92ee_dm_find_minimum_rssi(hw);
+	dm_dig.rssi_val_min = dm->dm_digtable.min_undecorated_pwdb_for_dm;
+}
+
+static void rtl92ee_dm_init_primary_cca_check(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	struct dynamic_primary_cca *primarycca = &(rtlpriv->primarycca);
+
+	rtlhal->rts_en = 0;
+	primarycca->dup_rts_flag = 0;
+	primarycca->intf_flag = 0;
+	primarycca->intf_type = 0;
+	primarycca->monitor_flag = 0;
+	primarycca->ch_offset = 0;
+	primarycca->mf_state = 0;
+}
+
+static bool rtl92ee_dm_is_edca_turbo_disable(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->mac80211.mode == WIRELESS_MODE_B)
+		return true;
+
+	return false;
+}
+
+void rtl92ee_dm_init_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.bcurrent_turbo_edca = false;
+	rtlpriv->dm.bis_cur_rdlstate = false;
+	rtlpriv->dm.bis_any_nonbepkts = false;
+}
+
+static void rtl92ee_dm_check_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	static u64 last_txok_cnt;
+	static u64 last_rxok_cnt;
+	u64 cur_txok_cnt = 0;
+	u64 cur_rxok_cnt = 0;
+	u32 edca_be_ul = 0x5ea42b;
+	u32 edca_be_dl = 0x5ea42b; /*not sure*/
+	u32 edca_be = 0x5ea42b;
+	bool b_is_cur_rdlstate;
+	bool b_edca_turbo_on = false;
+
+	if (rtlpriv->dm.dbginfo.num_non_be_pkt > 0x100)
+		rtlpriv->dm.bis_any_nonbepkts = true;
+	rtlpriv->dm.dbginfo.num_non_be_pkt = 0;
+
+	cur_txok_cnt = rtlpriv->stats.txbytesunicast - last_txok_cnt;
+	cur_rxok_cnt = rtlpriv->stats.rxbytesunicast - last_rxok_cnt;
+
+	/*b_bias_on_rx = false;*/
+	b_edca_turbo_on = ((!rtlpriv->dm.bis_any_nonbepkts) &&
+			   (!rtlpriv->dm.b_disable_framebursting)) ?
+			  true : false;
+
+	if (rtl92ee_dm_is_edca_turbo_disable(hw))
+		goto dm_CheckEdcaTurbo_EXIT;
+
+	if (b_edca_turbo_on) {
+		b_is_cur_rdlstate = (cur_rxok_cnt > cur_txok_cnt * 4) ?
+				    true : false;
+
+		edca_be = b_is_cur_rdlstate ? edca_be_dl : edca_be_ul;
+		rtl_write_dword(rtlpriv , REG_EDCA_BE_PARAM , edca_be);
+		rtlpriv->dm.bis_cur_rdlstate = b_is_cur_rdlstate;
+		rtlpriv->dm.bcurrent_turbo_edca = true;
+	} else {
+		if (rtlpriv->dm.bcurrent_turbo_edca) {
+			u8 tmp = AC0_BE;
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      (u8 *) (&tmp));
+		}
+		rtlpriv->dm.bcurrent_turbo_edca = false;
+	}
+
+dm_CheckEdcaTurbo_EXIT:
+	rtlpriv->dm.bis_any_nonbepkts = false;
+	last_txok_cnt = rtlpriv->stats.txbytesunicast;
+	last_rxok_cnt = rtlpriv->stats.rxbytesunicast;
+}
+
+static void rtl92ee_dm_dynamic_edcca(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 reg_c50 , reg_c58;
+	bool b_fw_current_in_ps_mode = false;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				      (u8 *)(&b_fw_current_in_ps_mode));
+	if (b_fw_current_in_ps_mode)
+		return;
+
+	reg_c50 = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	reg_c58 = rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+
+	if (reg_c50 > 0x28 && reg_c58 > 0x28) {
+		if (!rtlpriv->rtlhal.b_pre_edcca_enable) {
+			rtl_write_byte(rtlpriv, ROFDM0_ECCATHRESHOLD, 0x03);
+			rtl_write_byte(rtlpriv, ROFDM0_ECCATHRESHOLD + 2, 0x00);
+			rtlpriv->rtlhal.b_pre_edcca_enable = true;
+		}
+	} else if (reg_c50 < 0x25 && reg_c58 < 0x25) {
+		if (rtlpriv->rtlhal.b_pre_edcca_enable) {
+			rtl_write_byte(rtlpriv, ROFDM0_ECCATHRESHOLD, 0x7f);
+			rtl_write_byte(rtlpriv, ROFDM0_ECCATHRESHOLD + 2, 0x7f);
+			rtlpriv->rtlhal.b_pre_edcca_enable = false;
+		}
+	}
+}
+
+static void rtl92ee_dm_adaptivity(struct ieee80211_hw *hw)
+{
+	rtl92ee_dm_dynamic_edcca(hw);
+}
+
+static void rtl92ee_dm_write_dynamic_cca(struct ieee80211_hw *hw, u8 cur_mf_state)
+{
+	struct dynamic_primary_cca *primarycca = &(rtl_priv(hw)->primarycca);
+
+	if (primarycca->mf_state != cur_mf_state)
+		rtl_set_bbreg(hw, DM_REG_L1SBD_PD_CH_11N, BIT(8) | BIT(7),
+			      cur_mf_state);
+
+	primarycca->mf_state = cur_mf_state;
+}
+
+static void rtl92ee_dm_dynamic_primary_cca_ckeck(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
+	struct dynamic_primary_cca *primarycca = &(rtlpriv->primarycca);
+	bool is40mhz = false;
+	u64 ofdm_cca, ofdm_fa, bw_usc_cnt, bw_lsc_cnt;
+	u8 sec_ch_offset;
+	u8 cur_mf_state;
+	static u8 count_down = MONITOR_TIME;
+
+	ofdm_cca = falsealm_cnt->cnt_ofdm_cca;
+	ofdm_fa = falsealm_cnt->cnt_ofdm_fail;
+	bw_usc_cnt = falsealm_cnt->cnt_bw_usc;
+	bw_lsc_cnt = falsealm_cnt->cnt_bw_lsc;
+	is40mhz = rtlpriv->mac80211.bw_40;
+	sec_ch_offset = rtlpriv->mac80211.cur_40_prime_sc;
+	/* NIC: 2: sec is below,  1: sec is above */
+
+	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP) {
+		cur_mf_state = MF_USC_LSC;
+		rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+		return;
+	}
+
+	if (rtlpriv->mac80211.link_state < MAC80211_LINKED)
+		return;
+
+	if (is40mhz)
+		return;
+
+	if (primarycca->pricca_flag == 0) {
+		/* Primary channel is above
+		 * NOTE: duplicate CTS can remove this condition*/
+		if (sec_ch_offset == 2) {
+			if ((ofdm_cca > OFDMCCA_TH) &&
+			    (bw_lsc_cnt > (bw_usc_cnt + BW_IND_BIAS)) &&
+			    (ofdm_fa > (ofdm_cca >> 1))) {
+				primarycca->intf_type = 1;
+				primarycca->intf_flag = 1;
+				cur_mf_state = MF_USC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				primarycca->pricca_flag = 1;
+			} else if ((ofdm_cca > OFDMCCA_TH) &&
+				   (bw_lsc_cnt > (bw_usc_cnt + BW_IND_BIAS)) &&
+				   (ofdm_fa < (ofdm_cca >> 1))) {
+				primarycca->intf_type = 2;
+				primarycca->intf_flag = 1;
+				cur_mf_state = MF_USC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				primarycca->pricca_flag = 1;
+				primarycca->dup_rts_flag = 1;
+				rtlpriv->rtlhal.rts_en = 1;
+			} else {
+				primarycca->intf_type = 0;
+				primarycca->intf_flag = 0;
+				cur_mf_state = MF_USC_LSC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				rtlpriv->rtlhal.rts_en = 0;
+				primarycca->dup_rts_flag = 0;
+			}
+		} else if (sec_ch_offset == 1) {
+			if ((ofdm_cca > OFDMCCA_TH) &&
+			    (bw_usc_cnt > (bw_lsc_cnt + BW_IND_BIAS)) &&
+			    (ofdm_fa > (ofdm_cca >> 1))) {
+				primarycca->intf_type = 1;
+				primarycca->intf_flag = 1;
+				cur_mf_state = MF_LSC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				primarycca->pricca_flag = 1;
+			} else if ((ofdm_cca > OFDMCCA_TH) &&
+				   (bw_usc_cnt > (bw_lsc_cnt + BW_IND_BIAS)) &&
+				   (ofdm_fa < (ofdm_cca >> 1))) {
+				primarycca->intf_type = 2;
+				primarycca->intf_flag = 1;
+				cur_mf_state = MF_LSC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				primarycca->pricca_flag = 1;
+				primarycca->dup_rts_flag = 1;
+				rtlpriv->rtlhal.rts_en = 1;
+			} else {
+				primarycca->intf_type = 0;
+				primarycca->intf_flag = 0;
+				cur_mf_state = MF_USC_LSC;
+				rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+				rtlpriv->rtlhal.rts_en = 0;
+				primarycca->dup_rts_flag = 0;
+			}
+		}
+	} else {/* PrimaryCCA->PriCCA_flag == 1 */
+		count_down--;
+		if (count_down == 0) {
+			count_down = MONITOR_TIME;
+			primarycca->pricca_flag = 0;
+			cur_mf_state = MF_USC_LSC;
+			/* default */
+			rtl92ee_dm_write_dynamic_cca(hw, cur_mf_state);
+			rtlpriv->rtlhal.rts_en = 0;
+			primarycca->dup_rts_flag = 0;
+			primarycca->intf_type = 0;
+			primarycca->intf_flag = 0;
+		}
+	}
+}
+
+static void rtl92ee_dm_dynamic_atc_switch(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_dm *rtldm = rtl_dm(rtl_priv(hw));
+	u8 crystal_cap;
+	u32 packet_count;
+	int cfo_khz_a , cfo_khz_b , cfo_ave = 0, adjust_xtal = 0;
+	int cfo_ave_diff;
+
+	if (rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		if (rtldm->atc_status == ATC_STATUS_OFF) {
+			rtl_set_bbreg(hw, ROFDM1_CFOTRACKING, BIT(11),
+				      ATC_STATUS_ON);
+			rtldm->atc_status = ATC_STATUS_ON;
+		}
+		/* Disable CFO tracking for BT */
+		if (rtlpriv->cfg->ops->get_btc_status()) {
+			if (!rtlpriv->btcoexist.btc_ops->btc_is_bt_disabled(rtlpriv)) {
+				RT_TRACE(COMP_BT_COEXIST, DBG_LOUD,
+					("odm_DynamicATCSwitch(): "
+					"Disable CFO tracking for BT!!\n"));
+				return;
+			}
+		}
+		/* Reset Crystal Cap */
+		if (rtldm->crystal_cap != rtlpriv->efuse.crystalcap) {
+			rtldm->crystal_cap = rtlpriv->efuse.crystalcap;
+			crystal_cap = rtldm->crystal_cap & 0x3f;
+			rtl_set_bbreg(hw, REG_MAC_PHY_CTRL, 0xFFF000,
+				      (crystal_cap | (crystal_cap << 6)));
+		}
+	} else {
+		cfo_khz_a = (int)(rtldm->cfo_tail[0] * 3125) / 1280;
+		cfo_khz_b = (int)(rtldm->cfo_tail[1] * 3125) / 1280;
+		packet_count = rtldm->packet_count;
+
+		if (packet_count == rtldm->packet_count_pre)
+			return;
+
+		rtldm->packet_count_pre = packet_count;
+
+		if (rtlpriv->phy.rf_type == RF_1T1R)
+			cfo_ave = cfo_khz_a;
+		else
+			cfo_ave = (int)(cfo_khz_a + cfo_khz_b) >> 1;
+
+		cfo_ave_diff = (rtldm->cfo_ave_pre >= cfo_ave) ?
+			       (rtldm->cfo_ave_pre - cfo_ave) :
+			       (cfo_ave - rtldm->cfo_ave_pre);
+
+		if (cfo_ave_diff > 20 && rtldm->large_cfo_hit == 0) {
+			rtldm->large_cfo_hit = 1;
+			return;
+		} else {
+			rtldm->large_cfo_hit = 0;
+		}
+
+		rtldm->cfo_ave_pre = cfo_ave;
+
+		if (cfo_ave >= -rtldm->cfo_threshold &&
+		    cfo_ave <= rtldm->cfo_threshold && rtldm->is_freeze == 0) {
+			if (rtldm->cfo_threshold == CFO_THRESHOLD_XTAL) {
+				rtldm->cfo_threshold = CFO_THRESHOLD_XTAL + 10;
+				rtldm->is_freeze = 1;
+			} else {
+				rtldm->cfo_threshold = CFO_THRESHOLD_XTAL;
+			}
+		}
+
+		if (cfo_ave > rtldm->cfo_threshold && rtldm->crystal_cap < 0x3f)
+			adjust_xtal = ((cfo_ave - CFO_THRESHOLD_XTAL) >> 2) + 1;
+		else if ((cfo_ave < -rtlpriv->dm.cfo_threshold) &&
+			 rtlpriv->dm.crystal_cap > 0)
+			adjust_xtal = ((cfo_ave + CFO_THRESHOLD_XTAL) >> 2) - 1;
+
+		if (adjust_xtal != 0) {
+			rtldm->is_freeze = 0;
+			rtldm->crystal_cap += adjust_xtal;
+
+			if (rtldm->crystal_cap > 0x3f)
+				rtldm->crystal_cap = 0x3f;
+			else if (rtldm->crystal_cap < 0)
+				rtldm->crystal_cap = 0;
+
+			crystal_cap = rtldm->crystal_cap & 0x3f;
+			rtl_set_bbreg(hw, REG_MAC_PHY_CTRL, 0xFFF000,
+				      (crystal_cap | (crystal_cap << 6)));
+		}
+
+		if (cfo_ave < CFO_THRESHOLD_ATC &&
+		    cfo_ave > -CFO_THRESHOLD_ATC) {
+			if (rtldm->atc_status == ATC_STATUS_ON) {
+				rtl_set_bbreg(hw, ROFDM1_CFOTRACKING, BIT(11),
+					      ATC_STATUS_OFF);
+				rtldm->atc_status = ATC_STATUS_OFF;
+			}
+		} else {
+			if (rtldm->atc_status == ATC_STATUS_OFF) {
+				rtl_set_bbreg(hw, ROFDM1_CFOTRACKING, BIT(11),
+					      ATC_STATUS_ON);
+				rtldm->atc_status = ATC_STATUS_ON;
+			}
+		}
+	}
+}
+
+static void rtl92ee_dm_init_txpower_tracking(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_dm *dm = rtl_dm(rtlpriv);
+	u8 path;
+
+	dm->btxpower_tracking = true;
+	dm->default_ofdm_index = 30;
+	dm->default_cck_index = 20;
+
+	dm->bb_swing_idx_cck_base = dm->default_cck_index;
+	dm->cck_index = dm->default_cck_index;
+
+	for (path = RF90_PATH_A; path < MAX_RF_PATH; path++) {
+		dm->bb_swing_idx_ofdm_base[path] = dm->default_ofdm_index;
+		dm->ofdm_index[path] = dm->default_ofdm_index;
+		dm->delta_power_index[path] = 0;
+		dm->delta_power_index_last[path] = 0;
+		dm->power_index_offset[path] = 0;
+	}
+}
+
+void rtl92ee_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+
+	p_ra->ratr_state = DM_RATR_STA_INIT;
+	p_ra->pre_ratr_state = DM_RATR_STA_INIT;
+
+	if (rtlpriv->dm.dm_type == DM_TYPE_BYDRIVER)
+		rtlpriv->dm.b_useramask = true;
+	else
+		rtlpriv->dm.b_useramask = false;
+
+	p_ra->ldpc_thres = 35;
+	p_ra->use_ldpc = false;
+	p_ra->high_rssi_thresh_for_ra = 50;
+	p_ra->low_rssi_thresh_for_ra = 20;
+
+}
+
+static bool _rtl92ee_dm_ra_state_check(struct ieee80211_hw *hw,
+				      s32 rssi, u8 *ratr_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+	const u8 go_up_gap = 5;
+	u32 high_rssithresh_for_ra = p_ra->high_rssi_thresh_for_ra;
+	u32 low_rssithresh_for_ra = p_ra->low_rssi_thresh_for_ra;
+	u8 state;
+
+	/* Threshold Adjustment:
+	 * when RSSI state trends to go up one or two levels,
+	 * make sure RSSI is high enough.
+	 * Here GoUpGap is added to solve
+	 * the boundary's level alternation issue.
+	 */
+	switch (*ratr_state) {
+	case DM_RATR_STA_INIT:
+	case DM_RATR_STA_HIGH:
+			break;
+
+	case DM_RATR_STA_MIDDLE:
+			high_rssithresh_for_ra += go_up_gap;
+			break;
+
+	case DM_RATR_STA_LOW:
+			high_rssithresh_for_ra += go_up_gap;
+			low_rssithresh_for_ra += go_up_gap;
+			break;
+
+	default:
+			RT_TRACE(COMP_RATR, DBG_DMESG,
+				("wrong rssi level setting %d !", *ratr_state));
+			break;
+	}
+
+	/* Decide RATRState by RSSI. */
+	if (rssi > high_rssithresh_for_ra)
+		state = DM_RATR_STA_HIGH;
+	else if (rssi > low_rssithresh_for_ra)
+		state = DM_RATR_STA_MIDDLE;
+	else
+		state = DM_RATR_STA_LOW;
+
+	if (*ratr_state != state) {
+		*ratr_state = state;
+		return true;
+	}
+
+	return false;
+}
+
+static void rtl92ee_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+	struct ieee80211_sta *sta = NULL;
+
+	if (is_hal_stop(rtlhal)) {
+		RT_TRACE(COMP_RATE, DBG_LOUD,
+			 ("driver is going to unload\n"));
+		return;
+	}
+
+	if (!rtlpriv->dm.b_useramask) {
+		RT_TRACE(COMP_RATE, DBG_LOUD,
+			 ("driver does not control rate adaptive mask\n"));
+		return;
+	}
+
+	if (mac->link_state == MAC80211_LINKED &&
+		mac->opmode == NL80211_IFTYPE_STATION) {
+
+		if (rtlpriv->dm.undecorated_smoothed_pwdb < p_ra->ldpc_thres) {
+			p_ra->use_ldpc = true;
+			p_ra->lower_rts_rate = true;
+		} else if (rtlpriv->dm.undecorated_smoothed_pwdb >
+			   (p_ra->ldpc_thres - 5)) {
+			p_ra->use_ldpc = false;
+			p_ra->lower_rts_rate = false;
+		}
+		if (_rtl92ee_dm_ra_state_check(hw,
+					rtlpriv->dm.undecorated_smoothed_pwdb,
+					&(p_ra->ratr_state))) {
+
+			rcu_read_lock();
+			sta = rtl_find_sta(hw, mac->bssid);
+			if (sta)
+				rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
+							      p_ra->ratr_state);
+			rcu_read_unlock();
+
+			p_ra->pre_ratr_state = p_ra->ratr_state;
+		}
+	}
+}
+
+static void rtl92ee_dm_init_dynamic_atc_switch(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.crystal_cap = rtlpriv->efuse.crystalcap;
+
+	rtlpriv->dm.atc_status = rtl_get_bbreg(hw, ROFDM1_CFOTRACKING, BIT(11));
+	rtlpriv->dm.cfo_threshold = CFO_THRESHOLD_XTAL;
+}
+
+void rtl92ee_dm_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
+
+	rtl92ee_dm_diginit(hw);
+	rtl92ee_dm_init_rate_adaptive_mask(hw);
+	rtl92ee_dm_init_primary_cca_check(hw);
+	rtl92ee_dm_init_edca_turbo(hw);
+	rtl92ee_dm_init_txpower_tracking(hw);
+	rtl92ee_dm_init_dynamic_atc_switch(hw);
+}
+
+static void rtl92ee_dm_common_info_self_update(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 cnt = 0;
+	struct rtl_sta_info *drv_priv;
+
+	rtlpriv->dm.b_one_entry_only = false;
+
+	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_STATION &&
+		rtlpriv->mac80211.link_state >= MAC80211_LINKED) {
+		rtlpriv->dm.b_one_entry_only = true;
+		return;
+	}
+
+	if (rtlpriv->mac80211.opmode == NL80211_IFTYPE_AP ||
+	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC ||
+	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_MESH_POINT) {
+		spin_lock_bh(&rtlpriv->locks.entry_list_lock);
+		list_for_each_entry(drv_priv, &rtlpriv->entry_list, list) {
+			cnt++;
+		}
+		spin_unlock_bh(&rtlpriv->locks.entry_list_lock);
+
+		if (cnt == 1)
+			rtlpriv->dm.b_one_entry_only = true;
+	}
+}
+
+void rtl92ee_dm_dynamic_arfb_select(struct ieee80211_hw *hw,
+				    u8 rate, bool collision_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rate >= DESC92C_RATEMCS8  && rate <= DESC92C_RATEMCS12) {
+		if (collision_state == 1) {
+			if (rate == DESC92C_RATEMCS12) {
+				rtl_write_dword(rtlpriv, REG_DARFRC, 0x0);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x07060501);
+			} else if (rate == DESC92C_RATEMCS11) {
+				rtl_write_dword(rtlpriv, REG_DARFRC, 0x0);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x07070605);
+			} else if (rate == DESC92C_RATEMCS10) {
+				rtl_write_dword(rtlpriv, REG_DARFRC, 0x0);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x08080706);
+			} else if (rate == DESC92C_RATEMCS9) {
+				rtl_write_dword(rtlpriv, REG_DARFRC, 0x0);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x08080707);
+			} else {
+				rtl_write_dword(rtlpriv, REG_DARFRC, 0x0);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x09090808);
+			}
+		} else {   /* collision_state == 0 */
+			if (rate == DESC92C_RATEMCS12) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x05010000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x09080706);
+			} else if (rate == DESC92C_RATEMCS11) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x06050000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x09080807);
+			} else if (rate == DESC92C_RATEMCS10) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x07060000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x0a090908);
+			} else if (rate == DESC92C_RATEMCS9) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x07070000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x0a090808);
+			} else {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x08080000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x0b0a0909);
+			}
+		}
+	} else {  /* MCS13~MCS15,  1SS, G-mode */
+		if (collision_state == 1) {
+			if (rate == DESC92C_RATEMCS15) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x00000000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x05040302);
+			} else if (rate == DESC92C_RATEMCS14) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x00000000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x06050302);
+			} else if (rate == DESC92C_RATEMCS13) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x00000000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x07060502);
+			} else {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x00000000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x06050402);
+			}
+		} else{   /* collision_state == 0 */
+			if (rate == DESC92C_RATEMCS15) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x03020000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x07060504);
+			} else if (rate == DESC92C_RATEMCS14) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x03020000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x08070605);
+			} else if (rate == DESC92C_RATEMCS13) {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x05020000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x09080706);
+			} else {
+				rtl_write_dword(rtlpriv, REG_DARFRC,
+						0x04020000);
+				rtl_write_dword(rtlpriv, REG_DARFRC + 4,
+						0x08070605);
+			}
+		}
+	}
+}
+
+void rtl92ee_dm_watchdog(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	bool b_fw_current_inpsmode = false;
+	bool b_fw_ps_awake = true;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				      (u8 *) (&b_fw_current_inpsmode));
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
+				      (u8 *) (&b_fw_ps_awake));
+	if (ppsc->p2p_ps_info.p2p_ps_mode)
+		b_fw_ps_awake = false;
+
+	if ((ppsc->rfpwr_state == ERFON) &&
+	    ((!b_fw_current_inpsmode) && b_fw_ps_awake) &&
+	    (!ppsc->rfchange_inprogress)) {
+		rtl92ee_dm_common_info_self_update(hw);
+		rtl92ee_dm_false_alarm_counter_statistics(hw);
+		rtl92ee_dm_check_rssi_monitor(hw);
+		rtl92ee_dm_dig(hw);
+		rtl92ee_dm_adaptivity(hw);
+		rtl92ee_dm_cck_packet_detection_thresh(hw);
+		rtl92ee_dm_refresh_rate_adaptive_mask(hw);
+		rtl92ee_dm_check_edca_turbo(hw);
+		rtl92ee_dm_dynamic_atc_switch(hw);
+		rtl92ee_dm_dynamic_primary_cca_ckeck(hw);
+	}
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/dm.h b/drivers/staging/rtl8192ee/rtl8192ee/dm.h
new file mode 100644
index 0000000..30b8fa6
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/dm.h
@@ -0,0 +1,343 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef	__RTL92E_DM_H__
+#define __RTL92E_DM_H__
+
+#define	OFDMCCA_TH				500
+#define	BW_IND_BIAS				500
+#define	MF_USC					2
+#define	MF_LSC					1
+#define	MF_USC_LSC				0
+#define	MONITOR_TIME				30
+
+#define	MAIN_ANT				0
+#define	AUX_ANT					1
+#define	MAIN_ANT_CG_TRX				1
+#define	AUX_ANT_CG_TRX				0
+#define	MAIN_ANT_CGCS_RX			0
+#define	AUX_ANT_CGCS_RX				1
+
+/*RF REG LIST*/
+#define	DM_REG_RF_MODE_11N			0x00
+#define	DM_REG_RF_0B_11N			0x0B
+#define	DM_REG_CHNBW_11N			0x18
+#define	DM_REG_T_METER_11N			0x24
+#define	DM_REG_RF_25_11N			0x25
+#define	DM_REG_RF_26_11N			0x26
+#define	DM_REG_RF_27_11N			0x27
+#define	DM_REG_RF_2B_11N			0x2B
+#define	DM_REG_RF_2C_11N			0x2C
+#define	DM_REG_RXRF_A3_11N			0x3C
+#define	DM_REG_T_METER_92D_11N			0x42
+#define	DM_REG_T_METER_92E_11N			0x42
+
+
+
+/*BB REG LIST*/
+/*PAGE 8 */
+#define	DM_REG_BB_CTRL_11N			0x800
+#define	DM_REG_RF_PIN_11N			0x804
+#define	DM_REG_PSD_CTRL_11N			0x808
+#define	DM_REG_TX_ANT_CTRL_11N			0x80C
+#define	DM_REG_BB_PWR_SAV5_11N			0x818
+#define	DM_REG_CCK_RPT_FORMAT_11N		0x824
+#define	DM_REG_RX_DEFUALT_A_11N			0x858
+#define	DM_REG_RX_DEFUALT_B_11N			0x85A
+#define	DM_REG_BB_PWR_SAV3_11N			0x85C
+#define	DM_REG_ANTSEL_CTRL_11N			0x860
+#define	DM_REG_RX_ANT_CTRL_11N			0x864
+#define	DM_REG_PIN_CTRL_11N			0x870
+#define	DM_REG_BB_PWR_SAV1_11N			0x874
+#define	DM_REG_ANTSEL_PATH_11N			0x878
+#define	DM_REG_BB_3WIRE_11N			0x88C
+#define	DM_REG_SC_CNT_11N			0x8C4
+#define	DM_REG_PSD_DATA_11N			0x8B4
+/*PAGE 9*/
+#define	DM_REG_ANT_MAPPING1_11N			0x914
+#define	DM_REG_ANT_MAPPING2_11N			0x918
+/*PAGE A*/
+#define	DM_REG_CCK_ANTDIV_PARA1_11N		0xA00
+#define	DM_REG_CCK_CCA_11N			0xA0A
+#define	DM_REG_CCK_ANTDIV_PARA2_11N		0xA0C
+#define	DM_REG_CCK_ANTDIV_PARA3_11N		0xA10
+#define	DM_REG_CCK_ANTDIV_PARA4_11N		0xA14
+#define	DM_REG_CCK_FILTER_PARA1_11N		0xA22
+#define	DM_REG_CCK_FILTER_PARA2_11N		0xA23
+#define	DM_REG_CCK_FILTER_PARA3_11N		0xA24
+#define	DM_REG_CCK_FILTER_PARA4_11N		0xA25
+#define	DM_REG_CCK_FILTER_PARA5_11N		0xA26
+#define	DM_REG_CCK_FILTER_PARA6_11N		0xA27
+#define	DM_REG_CCK_FILTER_PARA7_11N		0xA28
+#define	DM_REG_CCK_FILTER_PARA8_11N		0xA29
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
+#define	DM_REG_RSSI_BT_11N			0xB9C
+/*PAGE C */
+#define	DM_REG_OFDM_FA_HOLDC_11N		0xC00
+#define	DM_REG_RX_PATH_11N			0xC04
+#define	DM_REG_TRMUX_11N			0xC08
+#define	DM_REG_OFDM_FA_RSTC_11N			0xC0C
+#define	DM_REG_RXIQI_MATRIX_11N			0xC14
+#define	DM_REG_TXIQK_MATRIX_LSB1_11N		0xC4C
+#define	DM_REG_IGI_A_11N			0xC50
+#define	DM_REG_ANTDIV_PARA2_11N			0xC54
+#define	DM_REG_IGI_B_11N			0xC58
+#define	DM_REG_ANTDIV_PARA3_11N			0xC5C
+#define DM_REG_L1SBD_PD_CH_11N			0XC6C
+#define	DM_REG_BB_PWR_SAV2_11N			0xC70
+#define	DM_REG_RX_OFF_11N			0xC7C
+#define	DM_REG_TXIQK_MATRIXA_11N		0xC80
+#define	DM_REG_TXIQK_MATRIXB_11N		0xC88
+#define	DM_REG_TXIQK_MATRIXA_LSB2_11N		0xC94
+#define	DM_REG_TXIQK_MATRIXB_LSB2_11N		0xC9C
+#define	DM_REG_RXIQK_MATRIX_LSB_11N		0xCA0
+#define	DM_REG_ANTDIV_PARA1_11N			0xCA4
+#define	DM_REG_OFDM_FA_TYPE1_11N		0xCF0
+/*PAGE D */
+#define	DM_REG_OFDM_FA_RSTD_11N			0xD00
+#define	DM_REG_OFDM_FA_TYPE2_11N		0xDA0
+#define	DM_REG_OFDM_FA_TYPE3_11N		0xDA4
+#define	DM_REG_OFDM_FA_TYPE4_11N		0xDA8
+/*PAGE E */
+#define	DM_REG_TXAGC_A_6_18_11N			0xE00
+#define	DM_REG_TXAGC_A_24_54_11N		0xE04
+#define	DM_REG_TXAGC_A_1_MCS32_11N		0xE08
+#define	DM_REG_TXAGC_A_MCS0_3_11N		0xE10
+#define	DM_REG_TXAGC_A_MCS4_7_11N		0xE14
+#define	DM_REG_TXAGC_A_MCS8_11_11N		0xE18
+#define	DM_REG_TXAGC_A_MCS12_15_11N		0xE1C
+#define	DM_REG_FPGA0_IQK_11N			0xE28
+#define	DM_REG_TXIQK_TONE_A_11N			0xE30
+#define	DM_REG_RXIQK_TONE_A_11N			0xE34
+#define	DM_REG_TXIQK_PI_A_11N			0xE38
+#define	DM_REG_RXIQK_PI_A_11N			0xE3C
+#define	DM_REG_TXIQK_11N			0xE40
+#define	DM_REG_RXIQK_11N			0xE44
+#define	DM_REG_IQK_AGC_PTS_11N			0xE48
+#define	DM_REG_IQK_AGC_RSP_11N			0xE4C
+#define	DM_REG_BLUETOOTH_11N			0xE6C
+#define	DM_REG_RX_WAIT_CCA_11N			0xE70
+#define	DM_REG_TX_CCK_RFON_11N			0xE74
+#define	DM_REG_TX_CCK_BBON_11N			0xE78
+#define	DM_REG_OFDM_RFON_11N			0xE7C
+#define	DM_REG_OFDM_BBON_11N			0xE80
+#define		DM_REG_TX2RX_11N		0xE84
+#define	DM_REG_TX2TX_11N			0xE88
+#define	DM_REG_RX_CCK_11N			0xE8C
+#define	DM_REG_RX_OFDM_11N			0xED0
+#define	DM_REG_RX_WAIT_RIFS_11N			0xED4
+#define	DM_REG_RX2RX_11N			0xED8
+#define	DM_REG_STANDBY_11N			0xEDC
+#define	DM_REG_SLEEP_11N			0xEE0
+#define	DM_REG_PMPD_ANAEN_11N			0xEEC
+
+
+/*MAC REG LIST*/
+#define	DM_REG_BB_RST_11N			0x02
+#define	DM_REG_ANTSEL_PIN_11N			0x4C
+#define	DM_REG_EARLY_MODE_11N			0x4D0
+#define	DM_REG_RSSI_MONITOR_11N			0x4FE
+#define	DM_REG_EDCA_VO_11N			0x500
+#define	DM_REG_EDCA_VI_11N			0x504
+#define	DM_REG_EDCA_BE_11N			0x508
+#define	DM_REG_EDCA_BK_11N			0x50C
+#define	DM_REG_TXPAUSE_11N			0x522
+#define	DM_REG_RESP_TX_11N			0x6D8
+#define	DM_REG_ANT_TRAIN_PARA1_11N		0x7b0
+#define	DM_REG_ANT_TRAIN_PARA2_11N		0x7b4
+
+
+/*DIG Related*/
+#define	DM_BIT_IGI_11N				0x0000007F
+
+
+
+#define HAL_DM_DIG_DISABLE			BIT(0)
+#define HAL_DM_HIPWR_DISABLE			BIT(1)
+
+#define OFDM_TABLE_LENGTH			43
+#define CCK_TABLE_LENGTH			33
+
+#define OFDM_TABLE_SIZE				43
+#define CCK_TABLE_SIZE				33
+
+#define BW_AUTO_SWITCH_HIGH_LOW			25
+#define BW_AUTO_SWITCH_LOW_HIGH			30
+
+#define DM_DIG_THRESH_HIGH			40
+#define DM_DIG_THRESH_LOW			35
+
+#define DM_FALSEALARM_THRESH_LOW		400
+#define DM_FALSEALARM_THRESH_HIGH		1000
+
+#define DM_DIG_MAX				0x3e
+#define DM_DIG_MIN				0x1e
+
+#define DM_DIG_MAX_AP				0x32
+#define DM_DIG_MIN_AP				0x20
+
+#define DM_DIG_FA_UPPER				0x3e
+#define DM_DIG_FA_LOWER				0x1e
+#define DM_DIG_FA_TH0				0x200
+#define DM_DIG_FA_TH1				0x300
+#define DM_DIG_FA_TH2				0x400
+
+#define DM_DIG_BACKOFF_MAX			12
+#define DM_DIG_BACKOFF_MIN			-4
+#define DM_DIG_BACKOFF_DEFAULT			10
+
+#define RXPATHSELECTION_SS_TH_lOW		30
+#define RXPATHSELECTION_DIFF_TH			18
+
+#define DM_RATR_STA_INIT			0
+#define DM_RATR_STA_HIGH			1
+#define DM_RATR_STA_MIDDLE			2
+#define DM_RATR_STA_LOW				3
+
+#define CTS2SELF_THVAL				30
+#define REGC38_TH				20
+
+#define WAIOTTHVal				25
+
+#define TXHIGHPWRLEVEL_NORMAL			0
+#define TXHIGHPWRLEVEL_LEVEL1			1
+#define TXHIGHPWRLEVEL_LEVEL2			2
+#define TXHIGHPWRLEVEL_BT1			3
+#define TXHIGHPWRLEVEL_BT2			4
+
+#define DM_TYPE_BYFW				0
+#define DM_TYPE_BYDRIVER			1
+
+#define TX_POWER_NEAR_FIELD_THRESH_LVL2		74
+#define TX_POWER_NEAR_FIELD_THRESH_LVL1		67
+#define TXPWRTRACK_MAX_IDX			6
+
+/* Dynamic ATC switch */
+#define ATC_STATUS_OFF				0x0	/* enable */
+#define	ATC_STATUS_ON				0x1	/* disable */
+#define	CFO_THRESHOLD_XTAL			10	/* kHz */
+#define	CFO_THRESHOLD_ATC			80	/* kHz */
+
+/* RSSI Dump Message */
+#define RA_RSSIDUMP				0xcb0
+#define RB_RSSIDUMP				0xcb1
+#define RS1_RXEVMDUMP				0xcb2
+#define RS2_RXEVMDUMP				0xcb3
+#define RA_RXSNRDUMP				0xcb4
+#define RB_RXSNRDUMP				0xcb5
+#define RA_CFOSHORTDUMP				0xcb6
+#define RB_CFOSHORTDUMP				0xcb8
+#define RA_CFOLONGDUMP				0xcba
+#define RB_CFOLONGDUMP				0xcbc
+
+struct ps_t {
+	u8 pre_ccastate;
+	u8 cur_ccasate;
+	u8 pre_rfstate;
+	u8 cur_rfstate;
+	long rssi_val_min;
+
+};
+
+struct dig_t {
+	u8 dig_enable_flag;
+	u8 dig_ext_port_stage;
+	u32 rssi_lowthresh;
+	u32 rssi_highthresh;
+
+	u32 fa_lowthresh;
+	u32 fa_highthresh;
+
+	u8 cursta_connectctate;
+	u8 presta_connectstate;
+	u8 curmultista_connectstate;
+
+	u8 pre_igvalue;
+	u8 cur_igvalue;
+	u8 backup_igvalue;
+	u8 bt30_cur_igi;
+	u8 stop_dig;
+
+	char backoff_val;
+	char backoff_val_range_max;
+	char backoff_val_range_min;
+	u8 rx_gain_range_max;
+	u8 rx_gain_range_min;
+	u8 rssi_val_min;
+
+	u8 pre_cck_cca_thres;
+	u8 cur_cck_cca_thres;
+	u8 pre_cck_pd_state;
+	u8 cur_cck_pd_state;
+
+	u8 large_fa_hit;
+	u8 forbidden_igi;
+	u32 recover_cnt;
+
+	char th_l2h_ini;
+	char th_edcca_hl_diff;
+	char igi_base;
+	u8 igi_target;
+	bool force_edcca;
+	u8 adapen_rssi;
+
+	u8 dig_dynamic_min_0;
+	u8 dig_dynamic_min_1;
+	bool b_media_connect_0;
+	bool b_media_connect_1;
+
+	u32 antdiv_rssi_max;
+	u32 rssi_max;
+};
+
+enum pwr_track_control_method {
+	BBSWING,
+	TXAGC
+};
+
+extern struct dig_t dm_dig;
+void rtl92ee_dm_init(struct ieee80211_hw *hw);
+void rtl92ee_dm_watchdog(struct ieee80211_hw *hw);
+void rtl92ee_dm_write_cck_cca_thres(struct ieee80211_hw *hw,
+				    u8 cur_thres);
+void rtl92ee_dm_write_dig(struct ieee80211_hw *hw, u8 current_igi);
+void rtl92ee_dm_init_edca_turbo(struct ieee80211_hw *hw);
+void rtl92ee_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
+void rtl92ee_dm_dynamic_arfb_select(struct ieee80211_hw *hw,
+				    u8 rate, bool collision_state);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/fw.c b/drivers/staging/rtl8192ee/rtl8192ee/fw.c
new file mode 100644
index 0000000..ea6cafa
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/fw.c
@@ -0,0 +1,945 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "../base.h"
+#include "reg.h"
+#include "def.h"
+#include "fw.h"
+#include "dm.h"
+
+static void _rtl92ee_enable_fw_download(struct ieee80211_hw *hw, bool enable)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp;
+
+	if (enable) {
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x05);
+
+		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL + 2);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL + 2, tmp & 0xf7);
+	} else {
+
+		tmp = rtl_read_byte(rtlpriv, REG_MCUFWDL);
+		rtl_write_byte(rtlpriv, REG_MCUFWDL, tmp & 0xfe);
+	}
+}
+
+static void _rtl92ee_fw_block_write(struct ieee80211_hw *hw,
+				    const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 blockSize = sizeof(u32);
+	u8 *bufferPtr = (u8 *) buffer;
+	u32 *pu4BytePtr = (u32 *) buffer;
+	u32 i, offset, blockCount, remainSize;
+
+	blockCount = size / blockSize;
+	remainSize = size % blockSize;
+
+	for (i = 0; i < blockCount; i++) {
+		offset = i * blockSize;
+		rtl_write_dword(rtlpriv, (FW_8192C_START_ADDRESS + offset),
+				*(pu4BytePtr + i));
+	}
+
+	if (remainSize) {
+		offset = blockCount * blockSize;
+		bufferPtr += offset;
+		for (i = 0; i < remainSize; i++) {
+			rtl_write_byte(rtlpriv,
+				       (FW_8192C_START_ADDRESS + offset + i),
+				       *(bufferPtr + i));
+		}
+	}
+}
+
+static void _rtl92ee_fw_page_write(struct ieee80211_hw *hw, u32 page,
+				   const u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 value8;
+	u8 u8page = (u8) (page & 0x07);
+
+	value8 = (rtl_read_byte(rtlpriv, REG_MCUFWDL + 2) & 0xF8) | u8page;
+	rtl_write_byte(rtlpriv, (REG_MCUFWDL + 2), value8);
+
+	_rtl92ee_fw_block_write(hw, buffer, size);
+}
+
+static void _rtl92ee_fill_dummy(u8 *pfwbuf, u32 *pfwlen)
+{
+	u32 fwlen = *pfwlen;
+	u8 remain = (u8) (fwlen % 4);
+
+	remain = (remain == 0) ? 0 : (4 - remain);
+
+	while (remain > 0) {
+		pfwbuf[fwlen] = 0;
+		fwlen++;
+		remain--;
+	}
+
+	*pfwlen = fwlen;
+}
+
+static void _rtl92ee_write_fw(struct ieee80211_hw *hw,
+			      enum version_8192e version,
+			      u8 *buffer, u32 size)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 *bufferPtr = (u8 *) buffer;
+	u32 pageNums, remainSize;
+	u32 page, offset;
+
+	RT_TRACE(COMP_FW, DBG_LOUD , ("FW size is %d bytes,\n", size));
+
+	_rtl92ee_fill_dummy(bufferPtr, &size);
+
+	pageNums = size / FW_8192C_PAGE_SIZE;
+	remainSize = size % FW_8192C_PAGE_SIZE;
+
+	if (pageNums > 8) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Page numbers should not greater then 8\n"));
+	}
+
+	for (page = 0; page < pageNums; page++) {
+		offset = page * FW_8192C_PAGE_SIZE;
+		_rtl92ee_fw_page_write(hw, page, (bufferPtr + offset),
+				      FW_8192C_PAGE_SIZE);
+		udelay(2);
+	}
+
+	if (remainSize) {
+		offset = pageNums * FW_8192C_PAGE_SIZE;
+		page = pageNums;
+		_rtl92ee_fw_page_write(hw, page, (bufferPtr + offset),
+				       remainSize);
+	}
+
+}
+
+static int _rtl92ee_fw_free_to_go(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int err = -EIO;
+	u32 counter = 0;
+	u32 value32;
+
+	do {
+		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	} while ((counter++ < FW_8192C_POLLING_TIMEOUT_COUNT) &&
+		 (!(value32 & FWDL_ChkSum_rpt)));
+
+	if (counter >= FW_8192C_POLLING_TIMEOUT_COUNT) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("chksum report faill ! REG_MCUFWDL:0x%08x .\n",
+			  value32));
+		goto exit;
+	}
+
+	RT_TRACE(COMP_FW, DBG_TRACE,
+		 ("Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32));
+
+	value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+	value32 |= MCUFWDL_RDY;
+	value32 &= ~WINTINI_RDY;
+	rtl_write_dword(rtlpriv, REG_MCUFWDL, value32);
+
+	rtl92ee_firmware_selfreset(hw);
+	counter = 0;
+
+	do {
+		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
+		if (value32 & WINTINI_RDY) {
+			RT_TRACE(COMP_FW, DBG_LOUD ,
+				("Polling FW ready success!! REG_MCUFWDL:"
+				"0x%08x. count = %d\n", value32, counter));
+			err = 0;
+			goto exit;
+		}
+
+		udelay(FW_8192C_POLLING_DELAY*10);
+
+	} while (counter++ < FW_8192C_POLLING_TIMEOUT_COUNT);
+
+	RT_TRACE(COMP_ERR, DBG_EMERG,
+		 ("Polling FW ready fail!! REG_MCUFWDL:0x%08x. count = %d\n",
+		 value32, counter));
+
+exit:
+	return err;
+}
+
+int rtl92ee_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl92c_firmware_header *pfwheader;
+	u8 *pfwdata;
+	u32 fwsize;
+	int err;
+	enum version_8192e version = rtlhal->version;
+
+	if (!rtlhal->pfirmware)
+		return 1;
+
+	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
+	rtlhal->fw_version = pfwheader->version;
+	rtlhal->fw_subversion = pfwheader->subversion;
+	pfwdata = (u8 *) rtlhal->pfirmware;
+	fwsize = rtlhal->fwsize;
+	RT_TRACE(COMP_FW, DBG_DMESG,
+		 ("normal Firmware SIZE %d\n" , fwsize));
+
+	if (IS_FW_HEADER_EXIST(pfwheader)) {
+		RT_TRACE(COMP_FW, DBG_DMESG,
+			 ("Firmware Version(%d), Signature(%#x), Size(%d)\n",
+			  pfwheader->version, pfwheader->signature,
+			  (int)sizeof(struct rtl92c_firmware_header)));
+
+		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
+		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
+	} else {
+		RT_TRACE(COMP_FW, DBG_DMESG,
+			 ("Firmware no Header, Signature(%#x)\n",
+			  pfwheader->signature));
+	}
+
+	if (rtlhal->b_mac_func_enable) {
+		if (rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) {
+			rtl_write_byte(rtlpriv, REG_MCUFWDL, 0);
+			rtl92ee_firmware_selfreset(hw);
+		}
+	}
+	_rtl92ee_enable_fw_download(hw, true);
+	_rtl92ee_write_fw(hw, version, pfwdata, fwsize);
+	_rtl92ee_enable_fw_download(hw, false);
+
+	err = _rtl92ee_fw_free_to_go(hw);
+	if (err) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Firmware is not ready to run!\n"));
+	} else {
+		RT_TRACE(COMP_FW, DBG_LOUD ,
+			 ("Firmware is ready to run!\n"));
+	}
+
+	return 0;
+}
+
+static bool _rtl92ee_check_fw_read_last_h2c(struct ieee80211_hw *hw, u8 boxnum)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 val_hmetfr;
+	bool result = false;
+
+	val_hmetfr = rtl_read_byte(rtlpriv, REG_HMETFR);
+	if (((val_hmetfr >> boxnum) & BIT(0)) == 0)
+		result = true;
+	return result;
+}
+
+static void _rtl92ee_fill_h2c_command(struct ieee80211_hw *hw, u8 element_id,
+				      u32 cmd_len, u8 *p_cmdbuffer)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	u8 boxnum;
+	u16 box_reg = 0, box_extreg = 0;
+	u8 u1b_tmp;
+	bool isfw_read = false;
+	u8 buf_index = 0;
+	bool bwrite_sucess = false;
+	u8 wait_h2c_limmit = 100;
+	u8 boxcontent[4], boxextcontent[4];
+	u32 h2c_waitcounter = 0;
+	unsigned long flag;
+	u8 idx;
+
+	if (ppsc->dot11_psmode != EACTIVE ||
+		ppsc->inactive_pwrstate == ERFOFF) {
+		RT_TRACE(COMP_CMD, DBG_LOUD ,
+			("FillH2CCommand8192E(): "
+			"Return because RF is off!!!\n"));
+		return;
+	}
+
+	RT_TRACE(COMP_CMD, DBG_LOUD , ("come in\n"));
+
+	/* 1. Prevent race condition in setting H2C cmd.
+	 * (copy from MgntActSet_RF_State().)
+	 */
+	while (true) {
+		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+		if (rtlhal->b_h2c_setinprogress) {
+			RT_TRACE(COMP_CMD, DBG_LOUD ,
+				 ("H2C set in progress! Wait to set.."
+				  "element_id(%d).\n", element_id));
+
+			while (rtlhal->b_h2c_setinprogress) {
+				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
+						       flag);
+				h2c_waitcounter++;
+				RT_TRACE(COMP_CMD, DBG_LOUD ,
+					 ("Wait 100 us (%d times)...\n",
+					  h2c_waitcounter));
+				udelay(100);
+
+				if (h2c_waitcounter > 1000)
+					return;
+				spin_lock_irqsave(&rtlpriv->locks.h2c_lock,
+						  flag);
+			}
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+		} else {
+			rtlhal->b_h2c_setinprogress = true;
+			spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+			break;
+		}
+	}
+
+	while (!bwrite_sucess) {
+		/*	cosa remove this because never reach this. */
+		/*wait_writeh2c_limmit--;
+		if (wait_writeh2c_limmit == 0) {
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("Write H2C fail because no trigger "
+				  "for FW INT!\n"));
+			break;
+		}
+		*/
+		/* 2. Find the last BOX number which has been writen. */
+		boxnum = rtlhal->last_hmeboxnum;
+		switch (boxnum) {
+		case 0:
+			box_reg = REG_HMEBOX_0;
+			box_extreg = REG_HMEBOX_EXT_0;
+			break;
+		case 1:
+			box_reg = REG_HMEBOX_1;
+			box_extreg = REG_HMEBOX_EXT_1;
+			break;
+		case 2:
+			box_reg = REG_HMEBOX_2;
+			box_extreg = REG_HMEBOX_EXT_2;
+			break;
+		case 3:
+			box_reg = REG_HMEBOX_3;
+			box_extreg = REG_HMEBOX_EXT_3;
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("switch case not process\n"));
+			break;
+		}
+
+		/* 3. Check if the box content is empty. */
+		isfw_read = false;
+		u1b_tmp = rtl_read_byte(rtlpriv, REG_CR);
+
+		if (u1b_tmp != 0xea) {
+			isfw_read = true;
+		} else {
+			if (rtl_read_byte(rtlpriv, REG_TXDMA_STATUS) == 0xea ||
+			    rtl_read_byte(rtlpriv, REG_TXPKT_EMPTY) == 0xea)
+				rtl_write_byte(rtlpriv, REG_SYS_CFG1 + 3, 0xff);
+		}
+
+		if (isfw_read == true) {
+			wait_h2c_limmit = 100;
+			isfw_read = _rtl92ee_check_fw_read_last_h2c(hw, boxnum);
+			while (!isfw_read) {
+				wait_h2c_limmit--;
+				if (wait_h2c_limmit == 0) {
+					RT_TRACE(COMP_CMD, DBG_LOUD ,
+						("Wating too long for FW"
+						"read clear HMEBox(%d)!!!\n",
+						boxnum));
+					break;
+				}
+				udelay(10);
+				isfw_read = _rtl92ee_check_fw_read_last_h2c(hw,
+									boxnum);
+				u1b_tmp = rtl_read_byte(rtlpriv, 0x130);
+				RT_TRACE(COMP_CMD, DBG_LOUD ,
+					 ("Wating for FW read clear HMEBox(%d)!!! 0x130 = %2x\n",
+					 boxnum, u1b_tmp));
+			}
+		}
+
+		/* If Fw has not read the last
+		 H2C cmd, break and give up this H2C. */
+		if (!isfw_read) {
+			RT_TRACE(COMP_CMD, DBG_LOUD ,
+				 ("Write H2C reg BOX[%d] fail, Fw don't read.\n",
+				 boxnum));
+			break;
+		}
+		/* 4. Fill the H2C cmd into box */
+		memset(boxcontent, 0, sizeof(boxcontent));
+		memset(boxextcontent, 0, sizeof(boxextcontent));
+		boxcontent[0] = element_id;
+		RT_TRACE(COMP_CMD, DBG_LOUD ,
+			 ("Write element_id box_reg(%4x) = %2x\n",
+			  box_reg, element_id));
+
+		switch (cmd_len) {
+		case 1:
+		case 2:
+		case 3:
+			/*boxcontent[0] &= ~(BIT(7));*/
+			memcpy((u8 *) (boxcontent) + 1,
+			       p_cmdbuffer + buf_index, cmd_len);
+
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		case 4:
+		case 5:
+		case 6:
+		case 7:
+			/*boxcontent[0] |= (BIT(7));*/
+			memcpy((u8 *) (boxextcontent),
+			       p_cmdbuffer + buf_index+3, cmd_len-3);
+			memcpy((u8 *) (boxcontent) + 1,
+			       p_cmdbuffer + buf_index, 3);
+
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_extreg + idx,
+					       boxextcontent[idx]);
+			}
+
+			for (idx = 0; idx < 4; idx++) {
+				rtl_write_byte(rtlpriv, box_reg + idx,
+					       boxcontent[idx]);
+			}
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("switch case not process\n"));
+			break;
+		}
+
+		bwrite_sucess = true;
+
+		rtlhal->last_hmeboxnum = boxnum + 1;
+		if (rtlhal->last_hmeboxnum == 4)
+			rtlhal->last_hmeboxnum = 0;
+
+		RT_TRACE(COMP_CMD, DBG_LOUD ,
+			 ("pHalData->last_hmeboxnum  = %d\n",
+			  rtlhal->last_hmeboxnum));
+	}
+
+	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
+	rtlhal->b_h2c_setinprogress = false;
+	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
+
+	RT_TRACE(COMP_CMD, DBG_LOUD , ("go out\n"));
+}
+
+void rtl92ee_fill_h2c_cmd(struct ieee80211_hw *hw,
+			 u8 element_id, u32 cmd_len, u8 *p_cmdbuffer)
+{
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u32 tmp_cmdbuf[2];
+
+	if (rtlhal->bfw_ready == false) {
+		RT_ASSERT(false, ("return H2C cmd because of Fw "
+				  "download fail!!!\n"));
+		return;
+	}
+
+	memset(tmp_cmdbuf, 0, 8);
+	memcpy(tmp_cmdbuf, p_cmdbuffer, cmd_len);
+	_rtl92ee_fill_h2c_command(hw, element_id, cmd_len, (u8 *)&tmp_cmdbuf);
+
+	return;
+}
+
+void rtl92ee_firmware_selfreset(struct ieee80211_hw *hw)
+{
+	u8 u1b_tmp;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp & (~BIT(2))));
+
+	udelay(50);
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp | BIT(0)));
+
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp | BIT(2)));
+
+	RT_TRACE(COMP_INIT, DBG_LOUD ,
+		 ("  _8051Reset92E(): 8051 reset success .\n"));
+}
+
+void rtl92ee_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 u1_h2c_set_pwrmode[H2C_92E_PWEMODE_LENGTH] = { 0 };
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	u8 rlbm , power_state = 0;
+	RT_TRACE(COMP_POWER, DBG_LOUD , ("FW LPS mode = %d\n", mode));
+
+	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, ((mode) ? 1 : 0));
+	rlbm = 0;/*YJ, temp, 120316. FW now not support RLBM = 2.*/
+	SET_H2CCMD_PWRMODE_PARM_RLBM(u1_h2c_set_pwrmode, rlbm);
+	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode,
+					 (rtlpriv->mac80211.p2p) ?
+					 ppsc->smart_ps : 1);
+	SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(u1_h2c_set_pwrmode,
+					       ppsc->reg_max_lps_awakeintvl);
+	SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(u1_h2c_set_pwrmode, 0);
+	if (mode == FW_PS_ACTIVE_MODE)
+		power_state |= FW_PWR_STATE_ACTIVE;
+	else
+		power_state |= FW_PWR_STATE_RF_OFF;
+	SET_H2CCMD_PWRMODE_PARM_PWR_STATE(u1_h2c_set_pwrmode, power_state);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
+		      "rtl92c_set_fw_pwrmode(): u1_h2c_set_pwrmode\n",
+		      u1_h2c_set_pwrmode, H2C_92E_PWEMODE_LENGTH);
+	rtl92ee_fill_h2c_cmd(hw, H2C_92E_SETPWRMODE, H2C_92E_PWEMODE_LENGTH,
+			     u1_h2c_set_pwrmode);
+
+}
+
+void rtl92ee_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw, u8 mstatus)
+{
+	u8 parm[3] = { 0 , 0 , 0 };
+	/* parm[0]: bit0 = 0-->Disconnect, bit0 = 1-->Connect
+	 *          bit1 = 0-->update Media Status to MACID
+	 *          bit1 = 1-->update Media Status from MACID to MACID_End
+	 * parm[1]: MACID, if this is INFRA_STA, MacID = 0
+	 * parm[2]: MACID_End*/
+
+	SET_H2CCMD_MSRRPT_PARM_OPMODE(parm, mstatus);
+	SET_H2CCMD_MSRRPT_PARM_MACID_IND(parm, 0);
+
+	rtl92ee_fill_h2c_cmd(hw, H2C_92E_MSRRPT, 3, parm);
+}
+
+static bool _rtl92ee_cmd_send_packet(struct ieee80211_hw *hw,
+				     struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	struct rtl_tx_desc *pdesc;
+	unsigned long flags;
+	struct sk_buff *pskb = NULL;
+
+	ring = &rtlpci->tx_ring[BEACON_QUEUE];
+
+	pskb = __skb_dequeue(&ring->queue);
+	if (pskb)
+		kfree_skb(pskb);
+
+	spin_lock_irqsave(&rtlpriv->locks.irq_th_lock, flags);
+	/*this is wrong, fill_tx_cmddesc needs update*/
+	pdesc = &ring->desc[0];
+
+	rtlpriv->cfg->ops->fill_tx_cmddesc(hw, (u8 *) pdesc, 1, 1, skb);
+
+	__skb_queue_tail(&ring->queue, skb);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
+
+	return true;
+}
+
+#define BEACON_PG		0 /* ->1 */
+#define PSPOLL_PG		2
+#define NULL_PG			3
+#define PROBERSP_PG		4 /* ->5 */
+
+#define TOTAL_RESERVED_PKT_LEN	768
+
+
+
+static u8 reserved_page_packet[TOTAL_RESERVED_PKT_LEN] = {
+	/* page 0 beacon */
+	0x80, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,
+	0xFF, 0xFF, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0xEC, 0x1A, 0x59, 0x0B, 0xAD, 0xD4, 0x20, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x64, 0x00, 0x10, 0x04, 0x00, 0x05, 0x54, 0x65,
+	0x73, 0x74, 0x32, 0x01, 0x08, 0x82, 0x84, 0x0B,
+	0x16, 0x24, 0x30, 0x48, 0x6C, 0x03, 0x01, 0x06,
+	0x06, 0x02, 0x00, 0x00, 0x2A, 0x01, 0x02, 0x32,
+	0x04, 0x0C, 0x12, 0x18, 0x60, 0x2D, 0x1A, 0x6C,
+	0x09, 0x03, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x3D, 0x00, 0xDD, 0x07, 0x00, 0xE0, 0x4C,
+	0x02, 0x02, 0x00, 0x00, 0xDD, 0x18, 0x00, 0x50,
+	0xF2, 0x01, 0x01, 0x00, 0x00, 0x50, 0xF2, 0x04,
+	0x01, 0x00, 0x00, 0x50, 0xF2, 0x04, 0x01, 0x00,
+
+	/* page 1 beacon */
+	0x00, 0x50, 0xF2, 0x02, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x10, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 2  ps-poll */
+	0xA4, 0x10, 0x01, 0xC0, 0xEC, 0x1A, 0x59, 0x0B,
+	0xAD, 0xD4, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x18, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 3  null */
+	0x48, 0x01, 0x00, 0x00, 0xEC, 0x1A, 0x59, 0x0B,
+	0xAD, 0xD4, 0x00, 0xE0, 0x4C, 0x02, 0xB1, 0x78,
+	0xEC, 0x1A, 0x59, 0x0B, 0xAD, 0xD4, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x72, 0x00, 0x28, 0x8C, 0x00, 0x12, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 4  probe_resp */
+	0x50, 0x00, 0x00, 0x00, 0x00, 0x40, 0x10, 0x10,
+	0x00, 0x03, 0x00, 0xE0, 0x4C, 0x76, 0x00, 0x42,
+	0x00, 0x40, 0x10, 0x10, 0x00, 0x03, 0x00, 0x00,
+	0x9E, 0x46, 0x15, 0x32, 0x27, 0xF2, 0x2D, 0x00,
+	0x64, 0x00, 0x00, 0x04, 0x00, 0x0C, 0x6C, 0x69,
+	0x6E, 0x6B, 0x73, 0x79, 0x73, 0x5F, 0x77, 0x6C,
+	0x61, 0x6E, 0x01, 0x04, 0x82, 0x84, 0x8B, 0x96,
+	0x03, 0x01, 0x01, 0x06, 0x02, 0x00, 0x00, 0x2A,
+	0x01, 0x00, 0x32, 0x08, 0x24, 0x30, 0x48, 0x6C,
+	0x0C, 0x12, 0x18, 0x60, 0x2D, 0x1A, 0x6C, 0x18,
+	0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x3D, 0x00, 0xDD, 0x06, 0x00, 0xE0, 0x4C, 0x02,
+	0x01, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+
+	/* page 5  probe_resp */
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
+};
+
+
+
+void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct sk_buff *skb = NULL;
+
+	u32 totalpacketlen;
+	bool rtstatus;
+	u8 u1RsvdPageLoc[5] = { 0 };
+	bool b_dlok = false;
+
+	u8 *beacon;
+	u8 *p_pspoll;
+	u8 *nullfunc;
+	u8 *p_probersp;
+	/*---------------------------------------------------------
+				(1) beacon
+	---------------------------------------------------------*/
+	beacon = &reserved_page_packet[BEACON_PG * 128];
+	SET_80211_HDR_ADDRESS2(beacon, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(beacon, mac->bssid);
+
+	/*-------------------------------------------------------
+				(2) ps-poll
+	--------------------------------------------------------*/
+	p_pspoll = &reserved_page_packet[PSPOLL_PG * 128];
+	SET_80211_PS_POLL_AID(p_pspoll, (mac->assoc_id | 0xc000));
+	SET_80211_PS_POLL_BSSID(p_pspoll, mac->bssid);
+	SET_80211_PS_POLL_TA(p_pspoll, mac->mac_addr);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(u1RsvdPageLoc, PSPOLL_PG);
+
+	/*--------------------------------------------------------
+				(3) null data
+	---------------------------------------------------------*/
+	nullfunc = &reserved_page_packet[NULL_PG * 128];
+	SET_80211_HDR_ADDRESS1(nullfunc, mac->bssid);
+	SET_80211_HDR_ADDRESS2(nullfunc, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(nullfunc, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(u1RsvdPageLoc, NULL_PG);
+
+	/*---------------------------------------------------------
+				(4) probe response
+	----------------------------------------------------------*/
+	p_probersp = &reserved_page_packet[PROBERSP_PG * 128];
+	SET_80211_HDR_ADDRESS1(p_probersp, mac->bssid);
+	SET_80211_HDR_ADDRESS2(p_probersp, mac->mac_addr);
+	SET_80211_HDR_ADDRESS3(p_probersp, mac->bssid);
+
+	SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(u1RsvdPageLoc, PROBERSP_PG);
+
+	totalpacketlen = TOTAL_RESERVED_PKT_LEN;
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD ,
+		      "rtl92ee_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      &reserved_page_packet[0], totalpacketlen);
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD ,
+		      "rtl92ee_set_fw_rsvdpagepkt(): HW_VAR_SET_TX_CMD: ALL\n",
+		      u1RsvdPageLoc, 3);
+
+
+	skb = dev_alloc_skb(totalpacketlen);
+	memcpy((u8 *) skb_put(skb, totalpacketlen),
+	       &reserved_page_packet, totalpacketlen);
+
+	rtstatus = _rtl92ee_cmd_send_packet(hw, skb);
+
+	if (rtstatus)
+		b_dlok = true;
+
+	if (b_dlok) {
+		RT_TRACE(COMP_POWER, DBG_LOUD ,
+			 ("Set RSVD page location to Fw.\n"));
+		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD ,
+			      "H2C_RSVDPAGE:\n", u1RsvdPageLoc, 3);
+		rtl92ee_fill_h2c_cmd(hw, H2C_92E_RSVDPAGE,
+				     sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
+	} else
+		RT_TRACE(COMP_ERR, DBG_WARNING,
+			 ("Set RSVD page location to Fw FAIL!!!!!!.\n"));
+}
+
+/*Shoud check FW support p2p or not.*/
+static void rtl92ee_set_p2p_ctw_period_cmd(struct ieee80211_hw *hw, u8 ctwindow)
+{
+	u8 u1_ctwindow_period[1] = {ctwindow};
+
+	rtl92ee_fill_h2c_cmd(hw, H2C_92E_P2P_PS_CTW_CMD, 1, u1_ctwindow_period);
+
+}
+
+void rtl92ee_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *rtlps = rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_p2p_ps_info *p2pinfo = &(rtlps->p2p_ps_info);
+	struct p2p_ps_offload_t *p2p_ps_offload = &rtlhal->p2p_ps_offload;
+	u8 i;
+	u16 ctwindow;
+	u32 start_time, tsf_low;
+
+	switch (p2p_ps_state) {
+	case P2P_PS_DISABLE:
+		RT_TRACE(COMP_FW, DBG_LOUD , ("P2P_PS_DISABLE\n"));
+		memset(p2p_ps_offload, 0, 1);
+		break;
+	case P2P_PS_ENABLE:
+		RT_TRACE(COMP_FW, DBG_LOUD , ("P2P_PS_ENABLE\n"));
+		/* update CTWindow value. */
+		if (p2pinfo->ctwindow > 0) {
+			p2p_ps_offload->CTWindow_En = 1;
+			ctwindow = p2pinfo->ctwindow;
+			rtl92ee_set_p2p_ctw_period_cmd(hw, ctwindow);
+		}
+		/* hw only support 2 set of NoA */
+		for (i = 0 ; i < p2pinfo->noa_num ; i++) {
+			/* To control the register setting for which NOA*/
+			rtl_write_byte(rtlpriv, 0x5cf, (i << 4));
+			if (i == 0)
+				p2p_ps_offload->NoA0_En = 1;
+			else
+				p2p_ps_offload->NoA1_En = 1;
+			/* config P2P NoA Descriptor Register */
+			rtl_write_dword(rtlpriv, 0x5E0,
+					p2pinfo->noa_duration[i]);
+			rtl_write_dword(rtlpriv, 0x5E4,
+					p2pinfo->noa_interval[i]);
+
+			/*Get Current TSF value */
+			tsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
+
+			start_time = p2pinfo->noa_start_time[i];
+			if (p2pinfo->noa_count_type[i] != 1) {
+				while (start_time <= (tsf_low + (50 * 1024))) {
+					start_time += p2pinfo->noa_interval[i];
+					if (p2pinfo->noa_count_type[i] != 255)
+						p2pinfo->noa_count_type[i]--;
+				}
+			}
+			rtl_write_dword(rtlpriv, 0x5E8, start_time);
+			rtl_write_dword(rtlpriv, 0x5EC,
+					p2pinfo->noa_count_type[i]);
+		}
+		if ((p2pinfo->opp_ps == 1) || (p2pinfo->noa_num > 0)) {
+			/* rst p2p circuit */
+			rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, BIT(4));
+			p2p_ps_offload->Offload_En = 1;
+
+			if (P2P_ROLE_GO == rtlpriv->mac80211.p2p) {
+				p2p_ps_offload->role = 1;
+				p2p_ps_offload->AllStaSleep = 0;
+			} else {
+				p2p_ps_offload->role = 0;
+			}
+			p2p_ps_offload->discovery = 0;
+		}
+		break;
+	case P2P_PS_SCAN:
+		RT_TRACE(COMP_FW, DBG_LOUD , ("P2P_PS_SCAN\n"));
+		p2p_ps_offload->discovery = 1;
+		break;
+	case P2P_PS_SCAN_DONE:
+		RT_TRACE(COMP_FW, DBG_LOUD , ("P2P_PS_SCAN_DONE\n"));
+		p2p_ps_offload->discovery = 0;
+		p2pinfo->p2p_ps_state = P2P_PS_ENABLE;
+		break;
+	default:
+		break;
+	}
+
+	rtl92ee_fill_h2c_cmd(hw, H2C_92E_P2P_PS_OFFLOAD, 1,
+			     (u8 *)p2p_ps_offload);
+
+}
+
+static void _rtl92ee_c2h_ra_report_handler(struct ieee80211_hw *hw,
+					   u8 *cmd_buf, u8 cmd_len)
+{
+	u8 rate = cmd_buf[0] & 0x3F;
+	bool collision_state = cmd_buf[3] & BIT(0);
+
+	rtl92ee_dm_dynamic_arfb_select(hw, rate, collision_state);
+}
+
+static void _rtl92ee_c2h_content_parsing(struct ieee80211_hw *hw, u8 c2h_cmd_id,
+					 u8 c2h_cmd_len, u8 *tmp_buf)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	switch (c2h_cmd_id) {
+	case C2H_8192E_DBG:
+		RT_TRACE(COMP_FW, DBG_TRACE , ("[C2H], C2H_8723BE_DBG!!\n"));
+		break;
+	case C2H_8192E_TXBF:
+		RT_TRACE(COMP_FW, DBG_TRACE , ("[C2H], C2H_8192E_TXBF!!\n"));
+		break;
+	case C2H_8192E_TX_REPORT:
+		RT_TRACE(COMP_FW, DBG_TRACE , ("[C2H], C2H_8723BE_TX_REPORT!\n"));
+		break;
+	case C2H_8192E_BT_INFO:
+		RT_TRACE(COMP_FW, DBG_TRACE , ("[C2H], C2H_8723BE_BT_INFO!!\n"));
+		rtlpriv->btcoexist.btc_ops->btc_btinfo_notify(rtlpriv, tmp_buf,
+							      c2h_cmd_len);
+		break;
+	case C2H_8192E_BT_MP:
+		RT_TRACE(COMP_FW, DBG_TRACE, ("[C2H], C2H_8723BE_BT_MP!!\n"));
+		break;
+	case C2H_8192E_RA_RPT:
+		_rtl92ee_c2h_ra_report_handler(hw, tmp_buf, c2h_cmd_len);
+		break;
+	default:
+		RT_TRACE(COMP_FW, DBG_TRACE,
+			 ("[C2H], Unkown packet!! CmdId(%#X)!\n", c2h_cmd_id));
+		break;
+	}
+}
+
+void rtl92ee_c2h_packet_handler(struct ieee80211_hw *hw, u8 *buffer, u8 len)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 c2h_cmd_id = 0, c2h_cmd_seq = 0, c2h_cmd_len = 0;
+	u8 *tmp_buf = NULL;
+
+	c2h_cmd_id = buffer[0];
+	c2h_cmd_seq = buffer[1];
+	c2h_cmd_len = len - 2;
+	tmp_buf = buffer + 2;
+
+	RT_TRACE(COMP_FW, DBG_TRACE,
+		("[C2H packet], c2hCmdId = 0x%x, c2hCmdSeq = 0x%x, c2hCmdLen =%d\n",
+		c2h_cmd_id, c2h_cmd_seq, c2h_cmd_len));
+
+	RT_PRINT_DATA(rtlpriv, COMP_FW, DBG_TRACE,
+		      "[C2H packet], Content Hex:\n", tmp_buf, c2h_cmd_len);
+
+	_rtl92ee_c2h_content_parsing(hw, c2h_cmd_id, c2h_cmd_len, tmp_buf);
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/fw.h b/drivers/staging/rtl8192ee/rtl8192ee/fw.h
new file mode 100644
index 0000000..143992d
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/fw.h
@@ -0,0 +1,213 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E__FW__H__
+#define __RTL92E__FW__H__
+
+#define FW_8192C_SIZE				0x8000
+#define FW_8192C_START_ADDRESS			0x1000
+#define FW_8192C_END_ADDRESS			0x5FFF
+#define FW_8192C_PAGE_SIZE			4096
+#define FW_8192C_POLLING_DELAY			5
+#define FW_8192C_POLLING_TIMEOUT_COUNT		3000
+
+#define IS_FW_HEADER_EXIST(_pfwhdr)	\
+	((_pfwhdr->signature&0xFFF0) == 0x92E0)
+#define USE_OLD_WOWLAN_DEBUG_FW 0
+
+#define H2C_92E_RSVDPAGE_LOC_LEN		5
+#define H2C_92E_PWEMODE_LENGTH			5
+#define H2C_92E_JOINBSSRPT_LENGTH		1
+#define H2C_92E_AP_OFFLOAD_LENGTH		3
+#define H2C_92E_WOWLAN_LENGTH			3
+#define H2C_92E_KEEP_ALIVE_CTRL_LENGTH		3
+#if (USE_OLD_WOWLAN_DEBUG_FW == 0)
+#define H2C_92E_REMOTE_WAKE_CTRL_LEN		1
+#else
+#define H2C_92E_REMOTE_WAKE_CTRL_LEN		3
+#endif
+#define H2C_92E_AOAC_GLOBAL_INFO_LEN		2
+#define H2C_92E_AOAC_RSVDPAGE_LOC_LEN		7
+
+
+/* Fw PS state for RPWM.
+*BIT[2:0] = HW state
+*BIT[3] = Protocol PS state,  1: register active state, 0: register sleep state
+*BIT[4] = sub-state
+*/
+#define	FW_PS_RF_ON		BIT(2)
+#define	FW_PS_REGISTER_ACTIVE	BIT(3)
+
+#define	FW_PS_ACK		BIT(6)
+#define	FW_PS_TOGGLE		BIT(7)
+
+ /* 92E RPWM value*/
+ /* BIT[0] = 1: 32k, 0: 40M*/
+#define	FW_PS_CLOCK_OFF		BIT(0)		/* 32k */
+#define	FW_PS_CLOCK_ON		0		/* 40M */
+
+#define	FW_PS_STATE_MASK		(0x0F)
+#define	FW_PS_STATE_HW_MASK		(0x07)
+#define	FW_PS_STATE_INT_MASK		(0x3F)
+
+#define	FW_PS_STATE(x)			(FW_PS_STATE_MASK & (x))
+
+#define	FW_PS_STATE_ALL_ON_92E		(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_RF_ON_92E		(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_RF_OFF_92E		(FW_PS_CLOCK_ON)
+#define	FW_PS_STATE_RF_OFF_LOW_PWR	(FW_PS_CLOCK_OFF)
+
+/* For 92E H2C PwrMode Cmd ID 5.*/
+#define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
+#define	FW_PWR_STATE_RF_OFF	0
+
+#define	FW_PS_IS_ACK(x)		((x) & FW_PS_ACK)
+
+#define	IS_IN_LOW_POWER_STATE_92E(FwPSState)		\
+	(FW_PS_STATE(FwPSState) == FW_PS_CLOCK_OFF)
+
+#define	FW_PWR_STATE_ACTIVE	((FW_PS_RF_ON) | (FW_PS_REGISTER_ACTIVE))
+#define	FW_PWR_STATE_RF_OFF	0
+
+struct rtl92c_firmware_header {
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
+enum rtl8192c_h2c_cmd {
+	H2C_92E_RSVDPAGE = 0,
+	H2C_92E_MSRRPT = 1,
+	H2C_92E_SCAN = 2,
+	H2C_92E_KEEP_ALIVE_CTRL = 3,
+	H2C_92E_DISCONNECT_DECISION = 4,
+#if (USE_OLD_WOWLAN_DEBUG_FW == 1)
+	H2C_92E_WO_WLAN = 5,
+#endif
+	H2C_92E_INIT_OFFLOAD = 6,
+#if (USE_OLD_WOWLAN_DEBUG_FW == 1)
+	H2C_92E_REMOTE_WAKE_CTRL = 7,
+#endif
+	H2C_92E_AP_OFFLOAD = 8,
+	H2C_92E_BCN_RSVDPAGE = 9,
+	H2C_92E_PROBERSP_RSVDPAGE = 10,
+
+	H2C_92E_SETPWRMODE = 0x20,
+	H2C_92E_PS_TUNING_PARA = 0x21,
+	H2C_92E_PS_TUNING_PARA2 = 0x22,
+	H2C_92E_PS_LPS_PARA = 0x23,
+	H2C_92E_P2P_PS_OFFLOAD = 024,
+
+#if (USE_OLD_WOWLAN_DEBUG_FW == 0)
+	H2C_92E_WO_WLAN = 0x80,
+	H2C_92E_REMOTE_WAKE_CTRL = 0x81,
+	H2C_92E_AOAC_GLOBAL_INFO = 0x82,
+	H2C_92E_AOAC_RSVDPAGE = 0x83,
+#endif
+	H2C_92E_RA_MASK = 0x40,
+	H2C_92E_RSSI_REPORT = 0x42,
+	H2C_92E_SELECTIVE_SUSPEND_ROF_CMD,
+	H2C_92E_P2P_PS_MODE,
+	H2C_92E_PSD_RESULT,
+	/*Not defined CTW CMD for P2P yet*/
+	H2C_92E_P2P_PS_CTW_CMD,
+	MAX_92E_H2CCMD
+};
+
+enum rtl8192e_c2h_evt {
+	C2H_8192E_DBG = 0,
+	C2H_8192E_LB = 1,
+	C2H_8192E_TXBF = 2,
+	C2H_8192E_TX_REPORT = 3,
+	C2H_8192E_BT_INFO = 9,
+	C2H_8192E_BT_MP = 11,
+	C2H_8192E_RA_RPT = 12,
+	MAX_8192E_C2HEVENT
+};
+
+#define pagenum_128(_len)	\
+	(u32)(((_len) >> 7) + ((_len) & 0x7F ? 1 : 0))
+
+#define SET_H2CCMD_PWRMODE_PARM_MODE(__ph2ccmd, __val)			\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_PWRMODE_PARM_RLBM(__pH2CCmd, __val)			\
+	SET_BITS_TO_LE_1BYTE((__pH2CCmd)+1, 0, 4, __val)
+#define SET_H2CCMD_PWRMODE_PARM_SMART_PS(__pH2CCmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__pH2CCmd)+1, 4, 4, __val)
+#define SET_H2CCMD_PWRMODE_PARM_AWAKE_INTERVAL(__pH2CCmd, __val)	\
+	SET_BITS_TO_LE_1BYTE((__pH2CCmd)+2, 0, 8, __val)
+#define SET_H2CCMD_PWRMODE_PARM_ALL_QUEUE_UAPSD(__pH2CCmd, __val)	\
+	SET_BITS_TO_LE_1BYTE((__pH2CCmd)+3, 0, 8, __val)
+#define SET_H2CCMD_PWRMODE_PARM_PWR_STATE(__pH2CCmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__pH2CCmd)+4, 0, 8, __val)
+#define GET_92E_H2CCMD_PWRMODE_PARM_MODE(__pH2CCmd)			\
+	LE_BITS_TO_1BYTE(__pH2CCmd, 0, 8)
+
+#define SET_H2CCMD_JOINBSSRPT_PARM_OPMODE(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_PROBE_RSP(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE(__ph2ccmd, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_PSPOLL(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+1, 0, 8, __val)
+#define SET_H2CCMD_RSVDPAGE_LOC_NULL_DATA(__ph2ccmd, __val)		\
+	SET_BITS_TO_LE_1BYTE((__ph2ccmd)+2, 0, 8, __val)
+
+/* _MEDIA_STATUS_RPT_PARM_CMD1 */
+#define SET_H2CCMD_MSRRPT_PARM_OPMODE(__pH2CCmd, __Value)		\
+	SET_BITS_TO_LE_1BYTE(__pH2CCmd, 0, 1, __Value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID_IND(__pH2CCmd, __Value)		\
+	SET_BITS_TO_LE_1BYTE(__pH2CCmd, 1, 1, __Value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID(__pH2CCmd, __Value)		\
+	SET_BITS_TO_LE_1BYTE(__pH2CCmd+1, 0, 8, __Value)
+#define SET_H2CCMD_MSRRPT_PARM_MACID_END(__pH2CCmd, __Value)		\
+	SET_BITS_TO_LE_1BYTE(__pH2CCmd+2, 0, 8, __Value)
+
+
+int rtl92ee_download_fw(struct ieee80211_hw *hw, bool buse_wake_on_wlan_fw);
+void rtl92ee_fill_h2c_cmd(struct ieee80211_hw *hw, u8 element_id,
+			  u32 cmd_len, u8 *p_cmdbuffer);
+void rtl92ee_firmware_selfreset(struct ieee80211_hw *hw);
+void rtl92ee_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode);
+void rtl92ee_set_fw_media_status_rpt_cmd(struct ieee80211_hw *hw, u8 mstatus);
+void rtl92ee_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool b_dl_finished);
+void rtl92ee_set_p2p_ps_offload_cmd(struct ieee80211_hw *hw, u8 p2p_ps_state);
+void rtl92ee_c2h_packet_handler(struct ieee80211_hw *hw, u8 *buffer, u8 len);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/hw.c b/drivers/staging/rtl8192ee/rtl8192ee/hw.c
new file mode 100644
index 0000000..26af119
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/hw.c
@@ -0,0 +1,2544 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
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
+#include "pwrseqcmd.h"
+#include "pwrseq.h"
+
+#define LLT_CONFIG	5
+
+static void _rtl92ee_set_bcn_ctrl_reg(struct ieee80211_hw *hw,
+				      u8 set_bits, u8 clear_bits)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpci->reg_bcn_ctrl_val |= set_bits;
+	rtlpci->reg_bcn_ctrl_val &= ~clear_bits;
+
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlpci->reg_bcn_ctrl_val);
+}
+
+static void _rtl92ee_stop_tx_beacon(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp;
+
+	tmp = rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp & (~BIT(6)));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0x64);
+	tmp = rtl_read_byte(rtlpriv, REG_TBTT_PROHIBIT + 2);
+	tmp &= ~(BIT(0));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp);
+}
+
+static void _rtl92ee_resume_tx_beacon(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp;
+
+	tmp = rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp | BIT(6));
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1, 0xff);
+	tmp = rtl_read_byte(rtlpriv, REG_TBTT_PROHIBIT + 2);
+	tmp |= BIT(0);
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 2, tmp);
+}
+
+static void _rtl92ee_enable_bcn_sub_func(struct ieee80211_hw *hw)
+{
+	_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(1));
+}
+
+static void _rtl92ee_return_beacon_queue_skb(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[BEACON_QUEUE];
+
+	while (skb_queue_len(&ring->queue)) {
+		struct rtl_tx_buffer_desc *entry =
+						&ring->buffer_desc[ring->idx];
+		struct sk_buff *skb = __skb_dequeue(&ring->queue);
+
+		pci_unmap_single(rtlpci->pdev,
+				 rtlpriv->cfg->ops->get_desc(
+				 (u8 *) entry, true, HW_DESC_TXBUFF_ADDR),
+				 skb->len, PCI_DMA_TODEVICE);
+		kfree_skb(skb);
+		ring->idx = (ring->idx + 1) % ring->entries;
+	}
+
+}
+static void _rtl92ee_disable_bcn_sub_func(struct ieee80211_hw *hw)
+{
+	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(1), 0);
+}
+
+static void _rtl92ee_set_fw_clock_on(struct ieee80211_hw *hw,
+	u8 rpwm_val, bool b_need_turn_off_ckk)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	bool b_support_remote_wake_up;
+	u32 count = 0 , isr_regaddr , content;
+	bool b_schedule_timer = b_need_turn_off_ckk;
+	rtlpriv->cfg->ops->get_hw_reg(hw, HAL_DEF_WOWLAN,
+				      (u8 *) (&b_support_remote_wake_up));
+
+	if (!rtlhal->bfw_ready)
+		return;
+	if (!rtlpriv->psc.b_fw_current_inpsmode)
+		return;
+
+	while (1) {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (rtlhal->bfw_clk_change_in_progress) {
+			while (rtlhal->bfw_clk_change_in_progress) {
+				spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+				count++;
+				udelay(100);
+				if (count > 1000)
+					return;
+				spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+			}
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		} else {
+			rtlhal->bfw_clk_change_in_progress = false;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			break;
+		}
+	}
+
+	if (IS_IN_LOW_POWER_STATE_92E(rtlhal->fw_ps_state)) {
+		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_SET_RPWM,
+					      (u8 *) (&rpwm_val));
+		if (FW_PS_IS_ACK(rpwm_val)) {
+			isr_regaddr = REG_HISR;
+			content = rtl_read_dword(rtlpriv, isr_regaddr);
+			while (!(content & IMR_CPWM) && (count < 500)) {
+				udelay(50);
+				count++;
+				content = rtl_read_dword(rtlpriv, isr_regaddr);
+			}
+
+			if (content & IMR_CPWM) {
+				rtl_write_word(rtlpriv , isr_regaddr, 0x0100);
+				rtlhal->fw_ps_state = FW_PS_STATE_RF_ON_92E;
+				RT_TRACE(COMP_POWER, DBG_LOUD,
+					 ("Receive CPWM INT!!! PSState = %X\n",
+					 rtlhal->fw_ps_state));
+			}
+		}
+
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		rtlhal->bfw_clk_change_in_progress = false;
+		spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (b_schedule_timer) {
+			mod_timer(&rtlpriv->works.fw_clockoff_timer,
+				  jiffies + MSECS(10));
+		}
+
+	} else  {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		rtlhal->bfw_clk_change_in_progress = false;
+		spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+	}
+
+
+}
+
+static void _rtl92ee_set_fw_clock_off(struct ieee80211_hw *hw, u8 rpwm_val)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring;
+	enum rf_pwrstate rtstate;
+	bool b_schedule_timer = false;
+	u8 queue;
+
+	if (!rtlhal->bfw_ready)
+		return;
+	if (!rtlpriv->psc.b_fw_current_inpsmode)
+		return;
+	if (!rtlhal->ballow_sw_to_change_hwclc)
+		return;
+
+	rtlpriv->cfg->ops->get_hw_reg(hw , HW_VAR_RF_STATE , (u8 *)(&rtstate));
+	if (rtstate == ERFOFF || rtlpriv->psc.inactive_pwrstate == ERFOFF)
+		return;
+
+	for (queue = 0; queue < RTL_PCI_MAX_TX_QUEUE_COUNT; queue++) {
+		ring = &rtlpci->tx_ring[queue];
+		if (skb_queue_len(&ring->queue)) {
+			b_schedule_timer = true;
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
+	if (FW_PS_STATE(rtlhal->fw_ps_state) != FW_PS_STATE_RF_OFF_LOW_PWR) {
+		spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+		if (!rtlhal->bfw_clk_change_in_progress) {
+			rtlhal->bfw_clk_change_in_progress = true;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			rtlhal->fw_ps_state = FW_PS_STATE(rpwm_val);
+			rtl_write_word(rtlpriv, REG_HISR, 0x0100);
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+						      (u8 *) (&rpwm_val));
+			spin_lock_bh(&rtlpriv->locks.fw_ps_lock);
+			rtlhal->bfw_clk_change_in_progress = false;
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+		} else {
+			spin_unlock_bh(&rtlpriv->locks.fw_ps_lock);
+			mod_timer(&rtlpriv->works.fw_clockoff_timer,
+				  jiffies + MSECS(10));
+		}
+	}
+}
+
+static void _rtl92ee_set_fw_ps_rf_on(struct ieee80211_hw *hw)
+{
+	u8 rpwm_val = 0;
+	rpwm_val |= (FW_PS_STATE_RF_OFF_92E | FW_PS_ACK);
+	_rtl92ee_set_fw_clock_on(hw, rpwm_val, true);
+}
+
+static void _rtl92ee_set_fw_ps_rf_off_low_power(struct ieee80211_hw *hw)
+{
+	u8 rpwm_val = 0;
+	rpwm_val |= FW_PS_STATE_RF_OFF_LOW_PWR;
+	_rtl92ee_set_fw_clock_off(hw, rpwm_val);
+}
+void rtl92ee_fw_clk_off_timer_callback(unsigned long data)
+{
+	struct ieee80211_hw *hw = (struct ieee80211_hw *)data;
+
+	_rtl92ee_set_fw_ps_rf_off_low_power(hw);
+}
+
+static void _rtl92ee_fwlps_leave(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	bool b_fw_current_inps = false;
+	u8 rpwm_val = 0, fw_pwrmode = FW_PS_ACTIVE_MODE;
+
+	if (ppsc->b_low_power_enable) {
+		rpwm_val = (FW_PS_STATE_ALL_ON_92E | FW_PS_ACK);/* RF on */
+		_rtl92ee_set_fw_clock_on(hw, rpwm_val, false);
+		rtlhal->ballow_sw_to_change_hwclc = false;
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+					      (u8 *) (&fw_pwrmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+					      (u8 *) (&b_fw_current_inps));
+	} else {
+		rpwm_val = FW_PS_STATE_ALL_ON_92E;	/* RF on */
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+					      (u8 *) (&rpwm_val));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+					      (u8 *) (&fw_pwrmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+					      (u8 *) (&b_fw_current_inps));
+	}
+}
+
+static void _rtl92ee_fwlps_enter(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	bool b_fw_current_inps = true;
+	u8 rpwm_val;
+
+	if (ppsc->b_low_power_enable) {
+		rpwm_val = FW_PS_STATE_RF_OFF_LOW_PWR;	/* RF off */
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+					      (u8 *) (&b_fw_current_inps));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+					      (u8 *) (&ppsc->fwctrl_psmode));
+		rtlhal->ballow_sw_to_change_hwclc = true;
+		_rtl92ee_set_fw_clock_off(hw, rpwm_val);
+	} else {
+		rpwm_val = FW_PS_STATE_RF_OFF_92E;	/* RF off */
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+					      (u8 *) (&b_fw_current_inps));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_H2C_FW_PWRMODE,
+					      (u8 *) (&ppsc->fwctrl_psmode));
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
+					      (u8 *) (&rpwm_val));
+	}
+}
+
+void rtl92ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	switch (variable) {
+	case HW_VAR_RCR:
+		*((u32 *) (val)) = rtlpci->receive_config;
+		break;
+	case HW_VAR_RF_STATE:
+		*((enum rf_pwrstate *)(val)) = ppsc->rfpwr_state;
+		break;
+	case HW_VAR_FWLPS_RF_ON:{
+		enum rf_pwrstate rfState;
+		u32 val_rcr;
+
+		rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_RF_STATE,
+					      (u8 *) (&rfState));
+		if (rfState == ERFOFF) {
+			*((bool *) (val)) = true;
+		} else {
+			val_rcr = rtl_read_dword(rtlpriv, REG_RCR);
+			val_rcr &= 0x00070000;
+			if (val_rcr)
+				*((bool *) (val)) = false;
+			else
+				*((bool *) (val)) = true;
+		}
+		break; }
+	case HW_VAR_FW_PSMODE_STATUS:
+		*((bool *) (val)) = ppsc->b_fw_current_inpsmode;
+		break;
+	case HW_VAR_CORRECT_TSF:{
+		u64 tsf;
+		u32 *ptsf_low = (u32 *) &tsf;
+		u32 *ptsf_high = ((u32 *) &tsf) + 1;
+
+		*ptsf_high = rtl_read_dword(rtlpriv, (REG_TSFTR + 4));
+		*ptsf_low = rtl_read_dword(rtlpriv, REG_TSFTR);
+
+		*((u64 *) (val)) = tsf;
+
+		break; }
+	default:
+		RT_TRACE(COMP_ERR, DBG_LOUD,
+			 ("switch case not process %x\n", variable));
+		break;
+	}
+}
+
+static void _rtl92ee_download_rsvd_page(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 tmp_regcr, tmp_reg422;
+	u8 bcnvalid_reg, txbc_reg;
+	u8 count = 0, dlbcn_count = 0;
+	bool b_recover = false;
+
+	/*Set REG_CR bit 8. DMA beacon by SW.*/
+	tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, tmp_regcr | BIT(0));
+
+	/* Disable Hw protection for a time which revserd for Hw sending beacon.
+	 * Fix download reserved page packet fail
+	 * that access collision with the protection time.
+	 * 2010.05.11. Added by tynli. */
+	_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(3));
+	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(4), 0);
+
+	/* Set FWHW_TXQ_CTRL 0x422[6]= 0 to
+	 * tell Hw the packet is not a real beacon frame.
+	 */
+	tmp_reg422 = rtl_read_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2);
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp_reg422 & (~BIT(6)));
+
+	if (tmp_reg422 & BIT(6))
+		b_recover = true;
+
+	do {
+		/* Clear beacon valid check bit */
+		bcnvalid_reg = rtl_read_byte(rtlpriv, REG_DWBCN0_CTRL + 2);
+		rtl_write_byte(rtlpriv, REG_DWBCN0_CTRL + 2,
+			       bcnvalid_reg | BIT(0));
+
+		/* Return Beacon TCB */
+		_rtl92ee_return_beacon_queue_skb(hw);
+
+		/* download rsvd page */
+		rtl92ee_set_fw_rsvdpagepkt(hw, false);
+
+		txbc_reg = rtl_read_byte(rtlpriv, REG_MGQ_TXBD_NUM + 3);
+		count = 0;
+		while ((txbc_reg & BIT(4)) && count < 20) {
+			count++;
+			udelay(10);
+			txbc_reg = rtl_read_byte(rtlpriv, REG_MGQ_TXBD_NUM + 3);
+		}
+		rtl_write_byte(rtlpriv, REG_MGQ_TXBD_NUM + 3,
+			       txbc_reg | BIT(4));
+
+		/* check rsvd page download OK. */
+		bcnvalid_reg = rtl_read_byte(rtlpriv, REG_DWBCN0_CTRL + 2);
+		count = 0;
+		while (!(bcnvalid_reg & BIT(0)) && count < 20) {
+			count++;
+			udelay(50);
+			bcnvalid_reg = rtl_read_byte(rtlpriv,
+						     REG_DWBCN0_CTRL + 2);
+		}
+
+		if (bcnvalid_reg & BIT(0))
+			rtl_write_byte(rtlpriv, REG_DWBCN0_CTRL + 2, BIT(0));
+
+		dlbcn_count++;
+	} while (!(bcnvalid_reg & BIT(0)) && dlbcn_count < 5);
+
+	if (!(bcnvalid_reg & BIT(0)))
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Download RSVD page failed!\n"));
+
+	/* Enable Bcn */
+	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
+	_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(4));
+
+	if (b_recover)
+		rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 2, tmp_reg422);
+
+	tmp_regcr = rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, tmp_regcr & (~BIT(0)));
+
+}
+
+void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *efuse = rtl_efuse(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	u8 idx;
+
+	switch (variable) {
+	case HW_VAR_ETHER_ADDR:{
+		for (idx = 0; idx < ETH_ALEN; idx++) {
+			rtl_write_byte(rtlpriv, (REG_MACID + idx), val[idx]);
+		}
+		break; }
+	case HW_VAR_BASIC_RATE:{
+		u16 b_rate_cfg = ((u16 *) val)[0];
+		b_rate_cfg = b_rate_cfg & 0x15f;
+		b_rate_cfg |= 0x01;
+		b_rate_cfg = (b_rate_cfg | 0xd) & (~BIT(1));
+		rtl_write_byte(rtlpriv, REG_RRSR, b_rate_cfg & 0xff);
+		rtl_write_byte(rtlpriv, REG_RRSR + 1, (b_rate_cfg >> 8) & 0xff);
+		break; }
+	case HW_VAR_BSSID:
+		for (idx = 0; idx < ETH_ALEN; idx++) {
+			rtl_write_byte(rtlpriv, (REG_BSSID + idx), val[idx]);
+		}
+		break;
+	case HW_VAR_SIFS:
+		rtl_write_byte(rtlpriv, REG_SIFS_CTX + 1, val[0]);
+		rtl_write_byte(rtlpriv, REG_SIFS_TRX + 1, val[1]);
+
+		rtl_write_byte(rtlpriv, REG_SPEC_SIFS + 1, val[0]);
+		rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
+
+		if (!mac->ht_enable)
+			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM, 0x0e0e);
+		else
+			rtl_write_word(rtlpriv, REG_RESP_SIFS_OFDM,
+				       *((u16 *) val));
+		break;
+	case HW_VAR_SLOT_TIME:{
+		u8 e_aci;
+
+		RT_TRACE(COMP_MLME, DBG_TRACE,
+			 ("HW_VAR_SLOT_TIME %x\n", val[0]));
+
+		rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
+
+		for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      (u8 *) (&e_aci));
+		}
+		break; }
+	case HW_VAR_ACK_PREAMBLE:{
+		u8 reg_tmp;
+		u8 short_preamble = (bool) (*(u8 *) val);
+		reg_tmp = (rtlpriv->mac80211.cur_40_prime_sc) << 5;
+		if (short_preamble)
+			reg_tmp |= 0x80;
+		rtl_write_byte(rtlpriv, REG_RRSR + 2, reg_tmp);
+		rtlpriv->mac80211.short_preamble = short_preamble;
+		break; }
+	case HW_VAR_WPA_CONFIG:
+		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *) val));
+		break;
+	case HW_VAR_AMPDU_FACTOR:{
+		u8 regtoset_normal[4] = { 0x41, 0xa8, 0x72, 0xb9 };
+		u8 fac;
+		u8 *reg = NULL;
+		u8 i = 0;
+
+		reg = regtoset_normal;
+
+		fac = *((u8 *) val);
+		if (fac <= 3) {
+			fac = (1 << (fac + 2));
+			if (fac > 0xf)
+				fac = 0xf;
+				for (i = 0; i < 4; i++) {
+				if ((reg[i] & 0xf0) > (fac << 4))
+					reg[i] = (reg[i] & 0x0f) | (fac << 4);
+				if ((reg[i] & 0x0f) > fac)
+					reg[i] = (reg[i] & 0xf0) | fac;
+					rtl_write_byte(rtlpriv,
+						       (REG_AGGLEN_LMT + i),
+						       reg[i]);
+				}
+				RT_TRACE(COMP_MLME, DBG_LOUD,
+					("Set HW_VAR_AMPDU_FACTOR:%#x\n", fac));
+		}
+		break; }
+	case HW_VAR_AC_PARAM:{
+		u8 e_aci = *((u8 *) val);
+
+		if (rtlpci->acm_method != eAcmWay2_SW)
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
+						      (u8 *) (&e_aci));
+		break; }
+	case HW_VAR_ACM_CTRL:{
+		u8 e_aci = *((u8 *) val);
+		union aci_aifsn *aifs = (union aci_aifsn *)(&(mac->ac[0].aifs));
+
+		u8 acm = aifs->f.acm;
+		u8 acm_ctrl = rtl_read_byte(rtlpriv, REG_ACMHWCTRL);
+
+		acm_ctrl = acm_ctrl | ((rtlpci->acm_method == 2) ? 0x0 : 0x1);
+
+		if (acm) {
+			switch (e_aci) {
+			case AC0_BE:
+				acm_ctrl |= AcmHw_BeqEn;
+				break;
+			case AC2_VI:
+				acm_ctrl |= AcmHw_ViqEn;
+				break;
+			case AC3_VO:
+				acm_ctrl |= AcmHw_VoqEn;
+				break;
+			default:
+				RT_TRACE(COMP_ERR, DBG_WARNING,
+					 ("HW_VAR_ACM_CTRL acm set "
+					  "failed: eACI is %d\n", acm));
+				break;
+			}
+		} else {
+			switch (e_aci) {
+			case AC0_BE:
+				acm_ctrl &= (~AcmHw_BeqEn);
+				break;
+			case AC2_VI:
+				acm_ctrl &= (~AcmHw_ViqEn);
+				break;
+			case AC3_VO:
+				acm_ctrl &= (~AcmHw_BeqEn);
+				break;
+			default:
+				RT_TRACE(COMP_ERR, DBG_LOUD,
+					 ("switch case not process \n"));
+				break;
+			}
+		}
+
+		RT_TRACE(COMP_QOS, DBG_TRACE,
+			 ("SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+			  acm_ctrl));
+		rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
+		break; }
+	case HW_VAR_RCR:{
+		rtl_write_dword(rtlpriv, REG_RCR, ((u32 *) (val))[0]);
+		rtlpci->receive_config = ((u32 *) (val))[0];
+		break; }
+	case HW_VAR_RETRY_LIMIT:{
+		u8 retry_limit = ((u8 *) (val))[0];
+
+		rtl_write_word(rtlpriv, REG_RETRY_LIMIT,
+			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
+			       retry_limit << RETRY_LIMIT_LONG_SHIFT);
+		break; }
+	case HW_VAR_DUAL_TSF_RST:
+		rtl_write_byte(rtlpriv, REG_DUAL_TSF_RST, (BIT(0) | BIT(1)));
+		break;
+	case HW_VAR_EFUSE_BYTES:
+		efuse->efuse_usedbytes = *((u16 *) val);
+		break;
+	case HW_VAR_EFUSE_USAGE:
+		efuse->efuse_usedpercentage = *((u8 *) val);
+		break;
+	case HW_VAR_IO_CMD:
+		rtl92ee_phy_set_io_cmd(hw, (*(enum io_type *)val));
+		break;
+	case HW_VAR_SET_RPWM:{
+		u8 rpwm_val;
+
+		rpwm_val = rtl_read_byte(rtlpriv, REG_PCIE_HRPWM);
+		udelay(1);
+
+		if (rpwm_val & BIT(7)) {
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, (*(u8 *) val));
+		} else {
+			rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
+				       ((*(u8 *) val) | BIT(7)));
+		}
+		break; }
+	case HW_VAR_H2C_FW_PWRMODE:
+		rtl92ee_set_fw_pwrmode_cmd(hw, (*(u8 *) val));
+		break;
+	case HW_VAR_FW_PSMODE_STATUS:
+		ppsc->b_fw_current_inpsmode = *((bool *) val);
+		break;
+	case HW_VAR_RESUME_CLK_ON:
+		_rtl92ee_set_fw_ps_rf_on(hw);
+		break;
+	case HW_VAR_FW_LPS_ACTION:{
+		bool b_enter_fwlps = *((bool *) val);
+
+		if (b_enter_fwlps)
+			_rtl92ee_fwlps_enter(hw);
+		else
+			_rtl92ee_fwlps_leave(hw);
+		break; }
+	case HW_VAR_H2C_FW_JOINBSSRPT:{
+		u8 mstatus = (*(u8 *) val);
+
+		if (mstatus == RT_MEDIA_CONNECT) {
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AID, NULL);
+			_rtl92ee_download_rsvd_page(hw);
+		}
+		rtl92ee_set_fw_media_status_rpt_cmd(hw, mstatus);
+		break; }
+	case HW_VAR_H2C_FW_P2P_PS_OFFLOAD:
+		rtl92ee_set_p2p_ps_offload_cmd(hw , (*(u8 *) val));
+		break;
+	case HW_VAR_AID:{
+		u16 u2btmp;
+		u2btmp = rtl_read_word(rtlpriv, REG_BCN_PSR_RPT);
+		u2btmp &= 0xC000;
+		rtl_write_word(rtlpriv, REG_BCN_PSR_RPT,
+			       (u2btmp | mac->assoc_id));
+		break; }
+	case HW_VAR_CORRECT_TSF:{
+		u8 btype_ibss = ((u8 *) (val))[0];
+
+		if (btype_ibss == true)
+			_rtl92ee_stop_tx_beacon(hw);
+
+		_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(3));
+
+		rtl_write_dword(rtlpriv, REG_TSFTR,
+				(u32) (mac->tsf & 0xffffffff));
+		rtl_write_dword(rtlpriv, REG_TSFTR + 4,
+				(u32) ((mac->tsf >> 32) & 0xffffffff));
+
+		_rtl92ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
+
+		if (btype_ibss == true)
+			_rtl92ee_resume_tx_beacon(hw);
+		break; }
+	case HW_VAR_KEEP_ALIVE: {
+		u8 array[2];
+		array[0] = 0xff;
+		array[1] = *((u8 *)val);
+		rtl92ee_fill_h2c_cmd(hw, H2C_92E_KEEP_ALIVE_CTRL, 2, array);
+		break; }
+	default:
+		RT_TRACE(COMP_ERR, DBG_LOUD,
+			 ("switch case not process %x\n", variable));
+		break;
+	}
+}
+
+static bool _rtl92ee_llt_table_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 txpktbuf_bndy;
+	u8 u8tmp, testcnt = 0;
+
+	txpktbuf_bndy = 0xFA;
+
+	rtl_write_dword(rtlpriv, REG_RQPN, 0x80E90808);
+
+	rtl_write_byte(rtlpriv, REG_TRXFF_BNDY, txpktbuf_bndy);
+	rtl_write_word(rtlpriv, REG_TRXFF_BNDY + 2, 0x3d00 - 1);
+
+	rtl_write_byte(rtlpriv, REG_DWBCN0_CTRL + 1, txpktbuf_bndy);
+	rtl_write_byte(rtlpriv, REG_DWBCN1_CTRL + 1, txpktbuf_bndy);
+
+	rtl_write_byte(rtlpriv, REG_BCNQ_BDNY, txpktbuf_bndy);
+	rtl_write_byte(rtlpriv, REG_BCNQ1_BDNY, txpktbuf_bndy);
+
+	rtl_write_byte(rtlpriv, REG_MGQ_BDNY, txpktbuf_bndy);
+	rtl_write_byte(rtlpriv, 0x45D, txpktbuf_bndy);
+
+	rtl_write_byte(rtlpriv, REG_PBP, 0x31);
+	rtl_write_byte(rtlpriv, REG_RX_DRVINFO_SZ, 0x4);
+
+	u8tmp = rtl_read_byte(rtlpriv, REG_AUTO_LLT + 2);
+	rtl_write_byte(rtlpriv, REG_AUTO_LLT + 2, u8tmp | BIT(0));
+
+	while (u8tmp & BIT(0)) {
+		u8tmp = rtl_read_byte(rtlpriv, REG_AUTO_LLT + 2);
+		udelay(10);
+		testcnt++;
+		if (testcnt > 10)
+			break;
+	}
+
+	return true;
+}
+
+static void _rtl92ee_gen_refresh_led_state(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
+
+	if (rtlpriv->rtlhal.up_first_time)
+		return;
+
+	if (ppsc->rfoff_reason == RF_CHANGE_BY_IPS)
+		rtl92ee_sw_led_on(hw, pLed0);
+	else if (ppsc->rfoff_reason == RF_CHANGE_BY_INIT)
+		rtl92ee_sw_led_on(hw, pLed0);
+	else
+		rtl92ee_sw_led_off(hw, pLed0);
+}
+
+static bool _rtl92ee_init_mac(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
+	u8 bytetmp;
+	u16 wordtmp;
+	u32 dwordtmp;
+
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0);
+
+	dwordtmp = rtl_read_dword(rtlpriv, REG_SYS_CFG1);
+	if (dwordtmp & BIT(24)) {
+		rtl_write_byte(rtlpriv, 0x7c, 0xc3);
+	} else {
+		bytetmp = rtl_read_byte(rtlpriv, 0x16);
+		rtl_write_byte(rtlpriv, 0x16, bytetmp | BIT(4) | BIT(6));
+		rtl_write_byte(rtlpriv, 0x7c, 0x83);
+	}
+	/* 1. 40Mhz crystal source*/
+	bytetmp = rtl_read_byte(rtlpriv, REG_AFE_CTRL2);
+	bytetmp &= 0xfb;
+	rtl_write_byte(rtlpriv, REG_AFE_CTRL2, bytetmp);
+
+	dwordtmp = rtl_read_dword(rtlpriv, REG_AFE_CTRL4);
+	dwordtmp &= 0xfffffc7f;
+	rtl_write_dword(rtlpriv, REG_AFE_CTRL4, dwordtmp);
+
+	/* 2. 92E AFE parameter
+	  *MP chip then check version */
+	bytetmp = rtl_read_byte(rtlpriv, REG_AFE_CTRL2);
+	bytetmp &= 0xbf;
+	rtl_write_byte(rtlpriv, REG_AFE_CTRL2, bytetmp);
+
+	dwordtmp = rtl_read_dword(rtlpriv, REG_AFE_CTRL4);
+	dwordtmp &= 0xffdfffff;
+	rtl_write_dword(rtlpriv, REG_AFE_CTRL4, dwordtmp);
+
+	/* HW Power on sequence */
+	if (!rtl92e_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+		PWR_INTF_PCI_MSK, Rtl8192E_NIC_ENABLE_FLOW)) {
+		RT_TRACE(COMP_INIT, DBG_LOUD,
+			 ("init MAC Fail as rtl92e_hal_pwrseqcmdparsing\n"));
+		return false;
+	}
+
+	/* Release MAC IO register reset */
+	bytetmp = rtl_read_byte(rtlpriv, REG_CR);
+	bytetmp = 0xff;
+	rtl_write_byte(rtlpriv, REG_CR, bytetmp);
+	mdelay(2);
+	bytetmp = 0x7f;
+	rtl_write_byte(rtlpriv, REG_HWSEQ_CTRL, bytetmp);
+	mdelay(2);
+
+	/* Add for wakeup online */
+	bytetmp = rtl_read_byte(rtlpriv, REG_SYS_CLKR);
+	rtl_write_byte(rtlpriv, REG_SYS_CLKR, bytetmp | BIT(3));
+	bytetmp = rtl_read_byte(rtlpriv, REG_GPIO_MUXCFG + 1);
+	rtl_write_byte(rtlpriv, REG_GPIO_MUXCFG + 1, bytetmp & (~BIT(4)));
+	/* Release MAC IO register reset */
+	rtl_write_word(rtlpriv, REG_CR, 0x2ff);
+
+	if (!rtlhal->b_mac_func_enable) {
+		if (_rtl92ee_llt_table_init(hw) == false) {
+			RT_TRACE(COMP_INIT, DBG_LOUD,
+				 ("LLT table init fail \n"));
+			return false;
+		}
+	}
+
+	rtl_write_dword(rtlpriv, REG_HISR, 0xffffffff);
+	rtl_write_dword(rtlpriv, REG_HISRE, 0xffffffff);
+
+	wordtmp = rtl_read_word(rtlpriv, REG_TRXDMA_CTRL);
+	wordtmp &= 0xf;
+	wordtmp |= 0xF5B1;
+	rtl_write_word(rtlpriv, REG_TRXDMA_CTRL, wordtmp);
+	/* Reported Tx status from HW for rate adaptive.*/
+	rtl_write_byte(rtlpriv, REG_FWHW_TXQ_CTRL + 1, 0x1F);
+
+	/* Set RCR register */
+	rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
+	rtl_write_word(rtlpriv, REG_RXFLTMAP2, 0xffff);
+
+	/* Set TCR register */
+	rtl_write_dword(rtlpriv, REG_TCR, rtlpci->transmit_config);
+
+	/* Set TX/RX descriptor physical address(from OS API). */
+	rtl_write_dword(rtlpriv, REG_BCNQ_DESA,
+			((u64) rtlpci->tx_ring[BEACON_QUEUE].buffer_desc_dma) &
+			DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_MGQ_DESA,
+			(u64) rtlpci->tx_ring[MGNT_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VOQ_DESA,
+			(u64) rtlpci->tx_ring[VO_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_VIQ_DESA,
+			(u64) rtlpci->tx_ring[VI_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+
+	rtl_write_dword(rtlpriv, REG_BEQ_DESA,
+			(u64) rtlpci->tx_ring[BE_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+
+	dwordtmp = rtl_read_dword(rtlpriv, REG_BEQ_DESA);
+
+	rtl_write_dword(rtlpriv, REG_BKQ_DESA,
+			(u64) rtlpci->tx_ring[BK_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+	rtl_write_dword(rtlpriv, REG_HQ0_DESA,
+			(u64) rtlpci->tx_ring[HIGH_QUEUE].buffer_desc_dma &
+			DMA_BIT_MASK(32));
+
+	rtl_write_dword(rtlpriv, REG_RX_DESA,
+			(u64) rtlpci->rx_ring[RX_MPDU_QUEUE].dma &
+			DMA_BIT_MASK(32));
+
+	/* if we want to support 64 bit DMA, we should set it here,
+	 * but now we do not support 64 bit DMA*/
+
+
+	rtl_write_dword(rtlpriv, REG_TSFTIMER_HCI, 0x3fffffff);
+
+	bytetmp = rtl_read_byte(rtlpriv, REG_PCIE_CTRL_REG + 3);
+	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 3, bytetmp | 0xF7);
+
+	rtl_write_dword(rtlpriv, REG_INT_MIG, 0);
+
+	rtl_write_dword(rtlpriv, REG_MCUTST_1, 0x0);
+
+	rtl_write_word(rtlpriv, REG_MGQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_VOQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_VIQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_BEQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_VOQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_BKQ_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI0Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI1Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI2Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI3Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI4Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI5Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI6Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	rtl_write_word(rtlpriv, REG_HI7Q_TXBD_NUM,
+		       TX_DESC_NUM_92E | ((RTL8192EE_SEG_NUM << 12) & 0x3000));
+	/*Rx*/
+#if (DMA_IS_64BIT == 1)
+	rtl_write_word(rtlpriv, REG_RX_RXBD_NUM,
+		       RX_DESC_NUM_92E |
+		       ((RTL8192EE_SEG_NUM << 13) & 0x6000) | 0x8000);
+#else
+	rtl_write_word(rtlpriv, REG_RX_RXBD_NUM,
+		       RX_DESC_NUM_92E |
+		       ((RTL8192EE_SEG_NUM << 13) & 0x6000) | 0x0000);
+#endif
+
+	rtl_write_dword(rtlpriv, REG_TSFTIMER_HCI, 0XFFFFFFFF);
+
+	_rtl92ee_gen_refresh_led_state(hw);
+	return true;
+}
+
+static void _rtl92ee_hw_configure(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rrsr;
+
+	reg_rrsr = RATE_ALL_CCK | RATE_ALL_OFDM_AG;
+	/* Init value for RRSR. */
+	rtl_write_dword(rtlpriv, REG_RRSR, reg_rrsr);
+
+	/* ARFB table 9 for 11ac 5G 2SS */
+	rtl_write_dword(rtlpriv, REG_ARFR0, 0x00000010);
+	rtl_write_dword(rtlpriv, REG_ARFR0 + 4, 0x3e0ff000);
+
+	/* ARFB table 10 for 11ac 5G 1SS */
+	rtl_write_dword(rtlpriv, REG_ARFR1, 0x00000010);
+	rtl_write_dword(rtlpriv, REG_ARFR1 + 4, 0x000ff000);
+
+	/* Set SLOT time */
+	rtl_write_byte(rtlpriv, REG_SLOT, 0x09);
+
+	/* CF-End setting. */
+	rtl_write_word(rtlpriv, REG_FWHW_TXQ_CTRL, 0x1F80);
+
+	/* Set retry limit */
+	rtl_write_word(rtlpriv, REG_RETRY_LIMIT, 0x0707);
+
+	/* BAR settings */
+	rtl_write_dword(rtlpriv, REG_BAR_MODE_CTRL, 0x0201ffff);
+
+	/* Set Data / Response auto rate fallack retry count */
+	rtl_write_dword(rtlpriv, REG_DARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_DARFRC + 4, 0x07060504);
+	rtl_write_dword(rtlpriv, REG_RARFRC, 0x01000000);
+	rtl_write_dword(rtlpriv, REG_RARFRC + 4, 0x07060504);
+
+	/* Beacon related, for rate adaptive */
+	rtl_write_byte(rtlpriv, REG_ATIMWND, 0x2);
+	rtl_write_byte(rtlpriv, REG_BCN_MAX_ERR, 0xff);
+
+	rtlpci->reg_bcn_ctrl_val = 0x1d;
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, rtlpci->reg_bcn_ctrl_val);
+
+	/* Marked out by Bruce, 2010-09-09.
+	 * This register is configured for the 2nd Beacon (multiple BSSID).
+	 * We shall disable this register if we only support 1 BSSID.
+	 * vivi guess 92d also need this, also 92d now doesnot set this reg
+	 */
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL_1, 0);
+
+	/* TBTT prohibit hold time. Suggested by designer TimChen. */
+	rtl_write_byte(rtlpriv, REG_TBTT_PROHIBIT + 1 , 0xff); /* 8 ms */
+
+	rtl_write_byte(rtlpriv, REG_PIFS, 0);
+	rtl_write_byte(rtlpriv, REG_AGGR_BREAK_TIME, 0x16);
+
+	rtl_write_word(rtlpriv, REG_NAV_PROT_LEN, 0x0040);
+	rtl_write_word(rtlpriv, REG_PROT_MODE_CTRL, 0x08ff);
+
+	/* For Rx TP. Suggested by SD1 Richard. Added by tynli. 2010.04.12.*/
+	rtl_write_dword(rtlpriv, REG_FAST_EDCA_CTRL, 0x03086666);
+
+	/* ACKTO for IOT issue. */
+	rtl_write_byte(rtlpriv, REG_ACKTO, 0x40);
+
+	/* Set Spec SIFS (used in NAV) */
+	rtl_write_word(rtlpriv, REG_SPEC_SIFS, 0x100a);
+	rtl_write_word(rtlpriv, REG_MAC_SPEC_SIFS, 0x100a);
+
+	/* Set SIFS for CCK */
+	rtl_write_word(rtlpriv, REG_SIFS_CTX, 0x100a);
+
+	/* Set SIFS for OFDM */
+	rtl_write_word(rtlpriv, REG_SIFS_TRX, 0x100a);
+
+	/* Note Data sheet don't define */
+	rtl_write_word(rtlpriv, 0x4C7, 0x80);
+
+	rtl_write_byte(rtlpriv, REG_RX_PKT_LIMIT, 0x20);
+
+	rtl_write_word(rtlpriv, REG_MAX_AGGR_NUM, 0x1717);
+
+	/* Set Multicast Address. 2009.01.07. by tynli. */
+	rtl_write_dword(rtlpriv, REG_MAR, 0xffffffff);
+	rtl_write_dword(rtlpriv, REG_MAR + 4, 0xffffffff);
+}
+
+static void _rtl92ee_enable_aspm_back_door(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	u32 tmp32 = 0, count = 0;
+	u8 tmp8 = 0;
+
+	rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0x78);
+	rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x2);
+	tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+	count = 0;
+	while (tmp8 && count < 20) {
+		udelay(10);
+		tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+		count++;
+	}
+
+	if (0 == tmp8) {
+		tmp32 = rtl_read_dword(rtlpriv, REG_BACKDOOR_DBI_RDATA);
+		if ((tmp32 & 0xff00) != 0x2000) {
+			tmp32 &= 0xffff00ff;
+			rtl_write_dword(rtlpriv, REG_BACKDOOR_DBI_WDATA,
+					tmp32 | BIT(13));
+			rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0xf078);
+			rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x1);
+
+			tmp8 = rtl_read_byte(rtlpriv , REG_BACKDOOR_DBI_DATA + 2);
+			count = 0;
+			while (tmp8 && count < 20) {
+				udelay(10);
+				tmp8 = rtl_read_byte(rtlpriv,
+						     REG_BACKDOOR_DBI_DATA + 2);
+				count++;
+			}
+		}
+	}
+
+	rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0x70c);
+	rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x2);
+	tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+	count = 0;
+	while (tmp8 && count < 20) {
+		udelay(10);
+		tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+		count++;
+	}
+	if (0 == tmp8) {
+		tmp32 = rtl_read_dword(rtlpriv, REG_BACKDOOR_DBI_RDATA);
+		rtl_write_dword(rtlpriv, REG_BACKDOOR_DBI_WDATA,
+				tmp32 | BIT(31));
+		rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0xf70c);
+		rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x1);
+	}
+
+	tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+	count = 0;
+	while (tmp8 && count < 20) {
+		udelay(10);
+		tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+		count++;
+	}
+
+
+	rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0x718);
+	rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x2);
+	tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+	count = 0;
+	while (tmp8 && count < 20) {
+		udelay(10);
+		tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+		count++;
+	}
+	if (ppsc->b_support_backdoor || (0 == tmp8)) {
+		tmp32 = rtl_read_dword(rtlpriv, REG_BACKDOOR_DBI_RDATA);
+		rtl_write_dword(rtlpriv, REG_BACKDOOR_DBI_WDATA,
+				tmp32 | BIT(11) | BIT(12));
+		rtl_write_word(rtlpriv, REG_BACKDOOR_DBI_DATA, 0xf718);
+		rtl_write_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2, 0x1);
+	}
+	tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+	count = 0;
+	while (tmp8 && count < 20) {
+		udelay(10);
+		tmp8 = rtl_read_byte(rtlpriv, REG_BACKDOOR_DBI_DATA + 2);
+		count++;
+	}
+}
+
+void rtl92ee_enable_hw_security_config(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 sec_reg_value;
+	u8 tmp;
+
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
+		  rtlpriv->sec.pairwise_enc_algorithm,
+		  rtlpriv->sec.group_enc_algorithm));
+
+	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
+		RT_TRACE(COMP_SEC, DBG_DMESG, ("not open hw encryption\n"));
+		return;
+	}
+
+	sec_reg_value = SCR_TxEncEnable | SCR_RxDecEnable;
+
+	if (rtlpriv->sec.use_defaultkey) {
+		sec_reg_value |= SCR_TxUseDK;
+		sec_reg_value |= SCR_RxUseDK;
+	}
+
+	sec_reg_value |= (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
+
+	tmp = rtl_read_byte(rtlpriv, REG_CR + 1);
+	rtl_write_byte(rtlpriv, REG_CR + 1, tmp | BIT(1));
+
+	RT_TRACE(COMP_SEC, DBG_DMESG,
+		 ("The SECR-value %x \n", sec_reg_value));
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
+
+}
+
+int rtl92ee_hw_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	bool rtstatus = true;
+	int err = 0;
+	u8 tmp_u1b , u1byte;
+	u32 tmp_u4b;
+
+	RT_TRACE(COMP_INIT , DBG_LOUD , (" Rtl8192EE hw init\n"));
+	rtlpriv->rtlhal.being_init_adapter = true;
+	rtlpriv->intf_ops->disable_aspm(hw);
+
+	tmp_u1b = rtl_read_byte(rtlpriv, REG_SYS_CLKR+1);
+	u1byte = rtl_read_byte(rtlpriv, REG_CR);
+	if ((tmp_u1b & BIT(3)) && (u1byte != 0 && u1byte != 0xEA)) {
+		rtlhal->b_mac_func_enable = true;
+	} else {
+		rtlhal->b_mac_func_enable = false;
+		rtlhal->fw_ps_state = FW_PS_STATE_ALL_ON_92E;
+	}
+
+	rtstatus = _rtl92ee_init_mac(hw);
+
+	rtl_write_byte(rtlpriv, 0x577, 0x03);
+
+	/*for Crystal 40 Mhz setting */
+	rtl_write_byte(rtlpriv, REG_AFE_CTRL4, 0x2A);
+	rtl_write_byte(rtlpriv, REG_AFE_CTRL4 + 1, 0x00);
+	rtl_write_byte(rtlpriv, REG_AFE_CTRL2, 0x83);
+
+	/*Forced the antenna b to wifi */
+	if (rtlpriv->btcoexist.btc_info.btcoexist == 1) {
+		rtl_write_byte(rtlpriv, 0x64, 0);
+		rtl_write_byte(rtlpriv, 0x65, 1);
+	}
+	if (rtstatus != true) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("Init MAC failed\n"));
+		err = 1;
+		return err;
+	}
+	rtlhal->rx_tag = 0;
+	rtl_write_word(rtlpriv, REG_PCIE_CTRL_REG, 0x8000);
+	err = rtl92ee_download_fw(hw , false);
+	if (err) {
+		RT_TRACE(COMP_ERR, DBG_WARNING,
+			 ("Failed to download FW. Init HW without FW now..\n"));
+		err = 1;
+		rtlhal->bfw_ready = false;
+		return err;
+	} else {
+		rtlhal->bfw_ready = true;
+	}
+	/*fw related variable initialize */
+	ppsc->b_fw_current_inpsmode = false;
+	rtlhal->fw_ps_state = FW_PS_STATE_ALL_ON_92E;
+	rtlhal->bfw_clk_change_in_progress = false;
+	rtlhal->ballow_sw_to_change_hwclc = false;
+	rtlhal->last_hmeboxnum = 0;
+
+
+	rtl92ee_phy_mac_config(hw);
+
+	rtl92ee_phy_bb_config(hw);
+
+	rtl92ee_phy_rf_config(hw);
+
+	rtlphy->rfreg_chnlval[0] = rtl_get_rfreg(hw, RF90_PATH_A,
+						 RF_CHNLBW, RFREG_OFFSET_MASK);
+	rtlphy->rfreg_chnlval[1] = rtl_get_rfreg(hw, RF90_PATH_B,
+						 RF_CHNLBW, RFREG_OFFSET_MASK);
+	rtlphy->backup_rf_0x1a = (u32) rtl_get_rfreg(hw, RF90_PATH_A, RF_RX_G1,
+						     RFREG_OFFSET_MASK);
+	rtlphy->rfreg_chnlval[0] = (rtlphy->rfreg_chnlval[0] & 0xfffff3ff) |
+				   BIT(10) | BIT(11);
+
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, RFREG_OFFSET_MASK,
+		      rtlphy->rfreg_chnlval[0]);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, RFREG_OFFSET_MASK,
+		      rtlphy->rfreg_chnlval[0]);
+
+	/*---- Set CCK and OFDM Block "ON"----*/
+	rtl_set_bbreg(hw, RFPGA0_RFMOD, BCCKEN, 0x1);
+	rtl_set_bbreg(hw, RFPGA0_RFMOD, BOFDMEN, 0x1);
+
+	/* Must set this,
+	 * otherwise the rx sensitivity will be very pool. Maddest
+	 */
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xB1, RFREG_OFFSET_MASK, 0x54418);
+
+	/*Set Hardware(MAC default setting.)*/
+	_rtl92ee_hw_configure(hw);
+
+	rtlhal->b_mac_func_enable = true;
+
+	stg_rtl_cam_reset_all_entry(hw);
+	rtl92ee_enable_hw_security_config(hw);
+
+	ppsc->rfpwr_state = ERFON;
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR, mac->mac_addr);
+	_rtl92ee_enable_aspm_back_door(hw);
+	rtlpriv->intf_ops->enable_aspm(hw);
+
+	rtl92ee_bt_hw_init(hw);
+
+	rtlpriv->rtlhal.being_init_adapter = false;
+
+	if (ppsc->rfpwr_state == ERFON) {
+		if (rtlphy->iqk_initialized) {
+			rtl92ee_phy_iq_calibrate(hw, true);
+		} else {
+			rtl92ee_phy_iq_calibrate(hw, false);
+			rtlphy->iqk_initialized = true;
+		}
+	}
+
+	rtlphy->rfpath_rx_enable[0] = true;
+	if (rtlphy->rf_type == RF_2T2R)
+		rtlphy->rfpath_rx_enable[1] = true;
+
+	stg_efuse_one_byte_read(hw, 0x1FA, &tmp_u1b);
+	if (!(tmp_u1b & BIT(0))) {
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x15, 0x0F, 0x05);
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("PA BIAS path A\n"));
+	}
+
+	if ((!(tmp_u1b & BIT(1))) && (rtlphy->rf_type == RF_2T2R)) {
+		rtl_set_rfreg(hw, RF90_PATH_B, 0x15, 0x0F, 0x05);
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("PA BIAS path B\n"));
+	}
+
+	rtl_write_byte(rtlpriv, REG_NAV_UPPER, ((30000 + 127) / 128));
+
+	/*Fixed LDPC rx hang issue. */
+	tmp_u4b = rtl_read_dword(rtlpriv, REG_SYS_SWR_CTRL1);
+	rtl_write_byte(rtlpriv, REG_SYS_SWR_CTRL2, 0x75);
+	tmp_u4b =  (tmp_u4b & 0xfff00fff) | (0x7E << 12);
+	rtl_write_dword(rtlpriv, REG_SYS_SWR_CTRL1, tmp_u4b);
+
+	rtl92ee_dm_init(hw);
+
+	rtl_write_dword(rtlpriv, 0x4fc, 0);
+
+	RT_TRACE(COMP_INIT , DBG_LOUD , ("end of Rtl8192EE hw init %x\n" , err));
+	return 0;
+}
+
+static enum version_8192e _rtl92ee_read_chip_version(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	enum version_8192e version = VERSION_UNKNOWN;
+	u32 value32;
+
+	rtlphy->rf_type = RF_2T2R;
+
+	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG1);
+	if (value32 & TRP_VAUX_EN)
+		version = (enum version_8192e) VERSION_TEST_CHIP_2T2R_8192E;
+	else
+		version = (enum version_8192e) VERSION_NORMAL_CHIP_2T2R_8192E;
+
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("Chip RF Type: %s\n", (rtlphy->rf_type == RF_2T2R) ?
+		  "RF_2T2R" : "RF_1T1R"));
+
+	return version;
+}
+
+static int _rtl92ee_set_media_status(struct ieee80211_hw *hw,
+				     enum nl80211_iftype type)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 bt_msr = rtl_read_byte(rtlpriv, MSR);
+	enum led_ctl_mode ledaction = LED_CTL_NO_LINK;
+	u8 mode = MSR_NOLINK;
+	bt_msr &= 0xfc;
+
+	switch (type) {
+	case NL80211_IFTYPE_UNSPECIFIED:
+		mode = MSR_NOLINK;
+		RT_TRACE(COMP_INIT, DBG_TRACE,
+			 ("Set Network type to NO LINK!\n"));
+		break;
+	case NL80211_IFTYPE_ADHOC:
+	case NL80211_IFTYPE_MESH_POINT:
+		mode = MSR_ADHOC;
+		RT_TRACE(COMP_INIT, DBG_TRACE,
+			 ("Set Network type to Ad Hoc!\n"));
+		break;
+	case NL80211_IFTYPE_STATION:
+		mode = MSR_INFRA;
+		ledaction = LED_CTL_LINK;
+		RT_TRACE(COMP_INIT, DBG_TRACE,
+			 ("Set Network type to STA!\n"));
+		break;
+	case NL80211_IFTYPE_AP:
+		mode = MSR_AP;
+		ledaction = LED_CTL_LINK;
+		RT_TRACE(COMP_INIT, DBG_TRACE,
+			 ("Set Network type to AP!\n"));
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Network type %d not support!\n", type));
+		return 1;
+		break;
+	}
+
+	/* MSR_INFRA == Link in infrastructure network;
+	 * MSR_ADHOC == Link in ad hoc network;
+	 * Therefore, check link state is necessary.
+	 *
+	 * MSR_AP == AP mode; link state is not cared here.
+	 */
+	if (mode != MSR_AP && rtlpriv->mac80211.link_state < MAC80211_LINKED) {
+		mode = MSR_NOLINK;
+		ledaction = LED_CTL_NO_LINK;
+	}
+
+	if (mode == MSR_NOLINK || mode == MSR_INFRA) {
+		_rtl92ee_stop_tx_beacon(hw);
+		_rtl92ee_enable_bcn_sub_func(hw);
+	} else if (mode == MSR_ADHOC || mode == MSR_AP) {
+		_rtl92ee_resume_tx_beacon(hw);
+		_rtl92ee_disable_bcn_sub_func(hw);
+	} else {
+		RT_TRACE(COMP_ERR, DBG_WARNING,
+			 ("Set HW_VAR_MEDIA_STATUS: "
+			  "No such media status(%x).\n", mode));
+	}
+
+	rtl_write_byte(rtlpriv, (MSR), bt_msr | mode);
+	rtlpriv->cfg->ops->led_control(hw, ledaction);
+	if (mode == MSR_AP)
+		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x00);
+	else
+		rtl_write_byte(rtlpriv, REG_BCNTCFG + 1, 0x66);
+	return 0;
+}
+
+void rtl92ee_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 reg_rcr = rtlpci->receive_config;
+
+	if (rtlpriv->psc.rfpwr_state != ERFON)
+		return;
+
+	if (check_bssid == true) {
+		reg_rcr |= (RCR_CBSSID_DATA | RCR_CBSSID_BCN);
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
+					      (u8 *) (&reg_rcr));
+		_rtl92ee_set_bcn_ctrl_reg(hw, 0, BIT(4));
+	} else if (check_bssid == false) {
+		reg_rcr &= (~(RCR_CBSSID_DATA | RCR_CBSSID_BCN));
+		_rtl92ee_set_bcn_ctrl_reg(hw, BIT(4), 0);
+		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RCR,
+					      (u8 *) (&reg_rcr));
+	}
+}
+
+int rtl92ee_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (_rtl92ee_set_media_status(hw, type))
+		return -EOPNOTSUPP;
+
+	if (rtlpriv->mac80211.link_state == MAC80211_LINKED) {
+		if (type != NL80211_IFTYPE_AP &&
+		    type != NL80211_IFTYPE_MESH_POINT)
+			rtl92ee_set_check_bssid(hw, true);
+	} else {
+		rtl92ee_set_check_bssid(hw, false);
+	}
+
+	return 0;
+}
+
+/* don't set REG_EDCA_BE_PARAM here because mac80211 will send pkt when scan */
+void rtl92ee_set_qos(struct ieee80211_hw *hw, int aci)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	rtl92ee_dm_init_edca_turbo(hw);
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
+		RT_ASSERT(false, ("invalid aci: %d !\n", aci));
+		break;
+	}
+}
+
+static void rtl92ee_clear_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 tmp;
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISR);
+	rtl_write_dword(rtlpriv, REG_HISR, tmp);
+
+	tmp = rtl_read_dword(rtlpriv, REG_HISRE);
+	rtl_write_dword(rtlpriv, REG_HISRE, tmp);
+
+	tmp = rtl_read_dword(rtlpriv, REG_HSISR);
+	rtl_write_dword(rtlpriv, REG_HSISR, tmp);
+}
+
+void rtl92ee_enable_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	rtl92ee_clear_interrupt(hw);/*clear it here first*/
+
+	rtl_write_dword(rtlpriv, REG_HIMR, rtlpci->irq_mask[0] & 0xFFFFFFFF);
+	rtl_write_dword(rtlpriv, REG_HIMRE, rtlpci->irq_mask[1] & 0xFFFFFFFF);
+	rtlpci->irq_enabled = true;
+}
+
+void rtl92ee_disable_interrupt(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	rtl_write_dword(rtlpriv, REG_HIMR, IMR_DISABLED);
+	rtl_write_dword(rtlpriv, REG_HIMRE, IMR_DISABLED);
+	rtlpci->irq_enabled = false;
+	/*synchronize_irq(rtlpci->pdev->irq);*/
+}
+
+static void _rtl92ee_poweroff_adapter(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 u1b_tmp;
+	rtlhal->b_mac_func_enable = false;
+
+	RT_TRACE(COMP_INIT , DBG_LOUD , ("POWER OFF adapter \n"));
+
+	/* Run LPS WL RFOFF flow */
+	rtl92e_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, Rtl8192E_NIC_LPS_ENTER_FLOW);
+	/* turn off RF */
+	rtl_write_byte(rtlpriv, REG_RF_CTRL, 0x00);
+
+	/* ==== Reset digital sequence   ======  */
+	if ((rtl_read_byte(rtlpriv, REG_MCUFWDL) & BIT(7)) && rtlhal->bfw_ready)
+		rtl92ee_firmware_selfreset(hw);
+
+	/* Reset MCU  */
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_SYS_FUNC_EN + 1);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN + 1, (u1b_tmp & (~BIT(2))));
+
+	/* reset MCU ready status */
+	rtl_write_byte(rtlpriv, REG_MCUFWDL, 0x00);
+
+	/* HW card disable configuration. */
+	rtl92e_hal_pwrseqcmdparsing(rtlpriv, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,
+				 PWR_INTF_PCI_MSK, Rtl8192E_NIC_DISABLE_FLOW);
+
+	/* Reset MCU IO Wrapper */
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp & (~BIT(0))));
+	u1b_tmp = rtl_read_byte(rtlpriv, REG_RSV_CTRL + 1);
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL + 1, (u1b_tmp | BIT(0)));
+
+	/* lock ISO/CLK/Power control register */
+	rtl_write_byte(rtlpriv, REG_RSV_CTRL, 0x0E);
+}
+
+void rtl92ee_card_disable(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	enum nl80211_iftype opmode;
+
+	RT_TRACE(COMP_INIT , DBG_LOUD , ("RTL8192ee card disable\n"));
+
+	RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+
+	mac->link_state = MAC80211_NOLINK;
+	opmode = NL80211_IFTYPE_UNSPECIFIED;
+
+	_rtl92ee_set_media_status(hw, opmode);
+
+	if (rtlpriv->rtlhal.driver_is_goingto_unload ||
+	    ppsc->rfoff_reason > RF_CHANGE_BY_PS)
+		rtlpriv->cfg->ops->led_control(hw, LED_CTL_POWER_OFF);
+
+	_rtl92ee_poweroff_adapter(hw);
+
+	/* after power off we should do iqk again */
+	rtlpriv->phy.iqk_initialized = false;
+}
+
+void rtl92ee_interrupt_recognized(struct ieee80211_hw *hw,
+				  u32 *p_inta, u32 *p_intb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	*p_inta = rtl_read_dword(rtlpriv, ISR) & rtlpci->irq_mask[0];
+	rtl_write_dword(rtlpriv, ISR, *p_inta);
+
+	*p_intb = rtl_read_dword(rtlpriv, REG_HISRE) & rtlpci->irq_mask[1];
+	rtl_write_dword(rtlpriv, REG_HISRE, *p_intb);
+}
+
+void rtl92ee_set_beacon_related_registers(struct ieee80211_hw *hw)
+{
+
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u16 bcn_interval, atim_window;
+
+	bcn_interval = mac->beacon_interval;
+	atim_window = 2;	/*FIX MERGE */
+	rtl92ee_disable_interrupt(hw);
+	rtl_write_word(rtlpriv, REG_ATIMWND, atim_window);
+	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
+	rtl_write_word(rtlpriv, REG_BCNTCFG, 0x660f);
+	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_CCK, 0x18);
+	rtl_write_byte(rtlpriv, REG_RXTSF_OFFSET_OFDM, 0x18);
+	rtl_write_byte(rtlpriv, 0x606, 0x30);
+	rtlpci->reg_bcn_ctrl_val |= BIT(3);
+	rtl_write_byte(rtlpriv, REG_BCN_CTRL, (u8) rtlpci->reg_bcn_ctrl_val);
+}
+
+void rtl92ee_set_beacon_interval(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	u16 bcn_interval = mac->beacon_interval;
+
+	RT_TRACE(COMP_BEACON, DBG_DMESG,
+		 ("beacon_interval:%d\n", bcn_interval));
+	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
+}
+
+void rtl92ee_update_interrupt_mask(struct ieee80211_hw *hw,
+				   u32 add_msr, u32 rm_msr)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	RT_TRACE(COMP_INTR, DBG_LOUD,
+		 ("add_msr:%x, rm_msr:%x\n", add_msr, rm_msr));
+
+	if (add_msr)
+		rtlpci->irq_mask[0] |= add_msr;
+	if (rm_msr)
+		rtlpci->irq_mask[0] &= (~rm_msr);
+	rtl92ee_disable_interrupt(hw);
+	rtl92ee_enable_interrupt(hw);
+}
+
+static u8 _rtl92ee_get_chnl_group(u8 chnl)
+{
+	u8 group = 0;
+
+	if (chnl <= 14) {
+		if (1 <= chnl && chnl <= 2)
+			group = 0;
+		else if (3 <= chnl && chnl <= 5)
+			group = 1;
+		else if (6 <= chnl && chnl <= 8)
+			group = 2;
+		else if (9 <= chnl && chnl <= 11)
+			group = 3;
+		else if (12 <= chnl && chnl <= 14)
+			group = 4;
+	} else {
+		if (36 <= chnl && chnl <= 42)
+			group = 0;
+		else if (44 <= chnl && chnl <= 48)
+			group = 1;
+		else if (50 <= chnl && chnl <= 58)
+			group = 2;
+		else if (60 <= chnl && chnl <= 64)
+			group = 3;
+		else if (100 <= chnl && chnl <= 106)
+			group = 4;
+		else if (108 <= chnl && chnl <= 114)
+			group = 5;
+		else if (116 <= chnl && chnl <= 122)
+			group = 6;
+		else if (124 <= chnl && chnl <= 130)
+			group = 7;
+		else if (132 <= chnl && chnl <= 138)
+			group = 8;
+		else if (140 <= chnl && chnl <= 144)
+			group = 9;
+		else if (149 <= chnl && chnl <= 155)
+			group = 10;
+		else if (157 <= chnl && chnl <= 161)
+			group = 11;
+		else if (165 <= chnl && chnl <= 171)
+			group = 12;
+		else if (173 <= chnl && chnl <= 177)
+			group = 13;
+	}
+	return group;
+}
+
+static void _rtl8192ee_read_power_value_fromprom(struct ieee80211_hw *hw,
+						 struct txpower_info_2g *pwr2g,
+						 struct txpower_info_5g *pwr5g,
+						 bool autoload_fail, u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 rf, addr = EEPROM_TX_PWR_INX, group, i = 0;
+
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("hal_ReadPowerValueFromPROM92E(): PROMContent[0x%x]= 0x%x\n",
+		 (addr + 1), hwinfo[addr + 1]));
+	if (0xFF == hwinfo[addr+1])  /*YJ, add, 120316*/
+		autoload_fail = true;
+
+	if (autoload_fail) {
+		RT_TRACE(COMP_INIT, DBG_LOUD,
+			 ("auto load fail : Use Default value!\n"));
+		for (rf = 0 ; rf < MAX_RF_PATH ; rf++) {
+			/* 2.4G default value */
+			for (group = 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+				pwr2g->index_cck_base[rf][group] = 0x2D;
+				pwr2g->index_bw40_base[rf][group] = 0x2D;
+			}
+			for (i = 0; i < MAX_TX_COUNT; i++) {
+				if (i == 0) {
+					pwr2g->bw20_diff[rf][0] = 0x02;
+					pwr2g->ofdm_diff[rf][0] = 0x04;
+				} else {
+					pwr2g->bw20_diff[rf][i] = 0xFE;
+					pwr2g->bw40_diff[rf][i] = 0xFE;
+					pwr2g->cck_diff[rf][i] = 0xFE;
+					pwr2g->ofdm_diff[rf][i] = 0xFE;
+				}
+			}
+
+			/*5G default value*/
+			for (group = 0 ; group < MAX_CHNL_GROUP_5G; group++)
+				pwr5g->index_bw40_base[rf][group] = 0x2A;
+
+			for (i = 0; i < MAX_TX_COUNT; i++) {
+				if (i == 0) {
+					pwr5g->ofdm_diff[rf][0] = 0x04;
+					pwr5g->bw20_diff[rf][0] = 0x00;
+					pwr5g->bw80_diff[rf][0] = 0xFE;
+					pwr5g->bw160_diff[rf][0] = 0xFE;
+				} else {
+					pwr5g->ofdm_diff[rf][0] = 0xFE;
+					pwr5g->bw20_diff[rf][0] = 0xFE;
+					pwr5g->bw40_diff[rf][0] = 0xFE;
+					pwr5g->bw80_diff[rf][0] = 0xFE;
+					pwr5g->bw160_diff[rf][0] = 0xFE;
+				}
+			}
+		}
+		return;
+	}
+
+	rtl_priv(hw)->efuse.b_txpwr_fromeprom = true;
+
+	for (rf = 0 ; rf < MAX_RF_PATH ; rf++) {
+		/*2.4G default value*/
+		for (group = 0 ; group < MAX_CHNL_GROUP_24G; group++) {
+			pwr2g->index_cck_base[rf][group] = hwinfo[addr++];
+			if (pwr2g->index_cck_base[rf][group] == 0xFF)
+				pwr2g->index_cck_base[rf][group] = 0x2D;
+
+		}
+		for (group = 0 ; group < MAX_CHNL_GROUP_24G - 1; group++) {
+			pwr2g->index_bw40_base[rf][group] = hwinfo[addr++];
+			if (pwr2g->index_bw40_base[rf][group] == 0xFF)
+				pwr2g->index_bw40_base[rf][group] = 0x2D;
+		}
+		for (i = 0; i < MAX_TX_COUNT; i++) {
+			if (i == 0) {
+				pwr2g->bw40_diff[rf][i] = 0;
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->bw20_diff[rf][i] = 0x02;
+				} else {
+					pwr2g->bw20_diff[rf][i] = (hwinfo[addr]
+								   & 0xf0) >> 4;
+					if (pwr2g->bw20_diff[rf][i] & BIT(3))
+						pwr2g->bw20_diff[rf][i] |= 0xF0;
+				}
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->ofdm_diff[rf][i] = 0x04;
+				} else {
+					pwr2g->ofdm_diff[rf][i] = (hwinfo[addr]
+								   & 0x0f);
+					if (pwr2g->ofdm_diff[rf][i] & BIT(3))
+						pwr2g->ofdm_diff[rf][i] |= 0xF0;
+				}
+				pwr2g->cck_diff[rf][i] = 0;
+				addr++;
+			} else {
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->bw40_diff[rf][i] = 0xFE;
+				} else {
+					pwr2g->bw40_diff[rf][i] = (hwinfo[addr]
+								   & 0xf0) >> 4;
+					if (pwr2g->bw40_diff[rf][i] & BIT(3))
+						pwr2g->bw40_diff[rf][i] |= 0xF0;
+				}
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->bw20_diff[rf][i] = 0xFE;
+				} else {
+					pwr2g->bw20_diff[rf][i] = (hwinfo[addr]
+								   & 0x0f);
+					if (pwr2g->bw20_diff[rf][i] & BIT(3))
+						pwr2g->bw20_diff[rf][i] |= 0xF0;
+				}
+				addr++;
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->ofdm_diff[rf][i] = 0xFE;
+				} else {
+					pwr2g->ofdm_diff[rf][i] = (hwinfo[addr]
+								   & 0xf0) >> 4;
+					if (pwr2g->ofdm_diff[rf][i] & BIT(3))
+						pwr2g->ofdm_diff[rf][i] |= 0xF0;
+				}
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr2g->cck_diff[rf][i] = 0xFE;
+				} else {
+					pwr2g->cck_diff[rf][i] = (hwinfo[addr]
+								  & 0x0f);
+					if (pwr2g->cck_diff[rf][i] & BIT(3))
+						pwr2g->cck_diff[rf][i] |= 0xF0;
+				}
+				addr++;
+			}
+		}
+
+		/*5G default value*/
+		for (group = 0 ; group < MAX_CHNL_GROUP_5G; group++) {
+			pwr5g->index_bw40_base[rf][group] = hwinfo[addr++];
+			if (pwr5g->index_bw40_base[rf][group] == 0xFF)
+				pwr5g->index_bw40_base[rf][group] = 0xFE;
+		}
+
+		for (i = 0; i < MAX_TX_COUNT; i++) {
+			if (i == 0) {
+				pwr5g->bw40_diff[rf][i] = 0;
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr5g->bw20_diff[rf][i] = 0;
+				} else {
+					pwr5g->bw20_diff[rf][0] = (hwinfo[addr]
+								   & 0xf0) >> 4;
+					if (pwr5g->bw20_diff[rf][i] & BIT(3))
+						pwr5g->bw20_diff[rf][i] |= 0xF0;
+				}
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr5g->ofdm_diff[rf][i] = 0x04;
+				} else {
+					pwr5g->ofdm_diff[rf][0] = (hwinfo[addr]
+								   & 0x0f);
+					if (pwr5g->ofdm_diff[rf][i] & BIT(3))
+						pwr5g->ofdm_diff[rf][i] |= 0xF0;
+				}
+				addr++;
+			} else {
+				if (hwinfo[addr] == 0xFF) {
+					pwr5g->bw40_diff[rf][i] = 0xFE;
+				} else {
+					pwr5g->bw40_diff[rf][i] = (hwinfo[addr]
+								  & 0xf0) >> 4;
+					if (pwr5g->bw40_diff[rf][i] & BIT(3))
+					pwr5g->bw40_diff[rf][i] |= 0xF0;
+				}
+
+				if (hwinfo[addr] == 0xFF) {
+					pwr5g->bw20_diff[rf][i] = 0xFE;
+				} else {
+					pwr5g->bw20_diff[rf][i] = (hwinfo[addr]
+								   & 0x0f);
+					if (pwr5g->bw20_diff[rf][i] & BIT(3))
+					pwr5g->bw20_diff[rf][i] |= 0xF0;
+				}
+				addr++;
+			}
+		}
+
+		if (hwinfo[addr] == 0xFF) {
+			pwr5g->ofdm_diff[rf][1] = 0xFE;
+			pwr5g->ofdm_diff[rf][2] = 0xFE;
+		} else {
+			pwr5g->ofdm_diff[rf][1] = (hwinfo[addr] & 0xf0) >> 4;
+			pwr5g->ofdm_diff[rf][2] = (hwinfo[addr] & 0x0f);
+		}
+		addr++;
+
+		if (hwinfo[addr] == 0xFF)
+			pwr5g->ofdm_diff[rf][3] = 0xFE;
+		else
+			pwr5g->ofdm_diff[rf][3] = (hwinfo[addr] & 0x0f);
+		addr++;
+
+		for (i = 1; i < MAX_TX_COUNT; i++) {
+			if (pwr5g->ofdm_diff[rf][i] == 0xFF)
+				pwr5g->ofdm_diff[rf][i] = 0xFE;
+			else if (pwr5g->ofdm_diff[rf][i] & BIT(3))
+				pwr5g->ofdm_diff[rf][i] |= 0xF0;
+		}
+
+		for (i = 0; i < MAX_TX_COUNT; i++) {
+			if (hwinfo[addr] == 0xFF) {
+				pwr5g->bw80_diff[rf][i] = 0xFE;
+			} else {
+				pwr5g->bw80_diff[rf][i] = (hwinfo[addr] & 0xf0)
+							  >> 4;
+				if (pwr5g->bw80_diff[rf][i] & BIT(3))
+					pwr5g->bw80_diff[rf][i] |= 0xF0;
+			}
+
+			if (hwinfo[addr] == 0xFF) {
+				pwr5g->bw160_diff[rf][i] = 0xFE;
+			} else {
+				pwr5g->bw160_diff[rf][i] = (hwinfo[addr] & 0x0f);
+				if (pwr5g->bw160_diff[rf][i] & BIT(3))
+					pwr5g->bw160_diff[rf][i] |= 0xF0;
+			}
+			addr++;
+		}
+	}
+}
+static void _rtl92ee_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
+						 bool autoload_fail, u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_efuse *efu = rtl_efuse(rtl_priv(hw));
+	struct txpower_info_2g pwr2g;
+	struct txpower_info_5g pwr5g;
+	u8 channel5g[CHANNEL_MAX_NUMBER_5G] = {
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54,
+		56, 58, 60, 62, 64, 100, 102, 104, 106,
+		108, 110, 112, 114, 116, 118, 120, 122,
+		124, 126, 128, 130, 132, 134, 136, 138,
+		140, 142, 144, 149, 151, 153, 155, 157,
+		159, 161, 163, 165, 167, 168, 169, 171,
+		173, 175, 177};
+	u8 channel5g_80m[CHANNEL_MAX_NUMBER_5G_80M] = {
+		42, 58, 106, 122, 138, 155, 171};
+	u8 rf, idx;
+	u8 i;
+
+	_rtl8192ee_read_power_value_fromprom(hw, &pwr2g, &pwr5g,
+					     autoload_fail, hwinfo);
+
+	for (rf = 0; rf < MAX_RF_PATH; rf++) {
+		for (i = 0; i < 14; i++) {
+			idx = _rtl92ee_get_chnl_group(i + 1);
+
+			if (i == CHANNEL_MAX_NUMBER_2G - 1) {
+				efu->txpwrlevel_cck[rf][i] =
+						pwr2g.index_cck_base[rf][5];
+				efu->txpwrlevel_ht40_1s[rf][i] =
+						pwr2g.index_bw40_base[rf][idx];
+			} else {
+				efu->txpwrlevel_cck[rf][i] =
+						pwr2g.index_cck_base[rf][idx];
+				efu->txpwrlevel_ht40_1s[rf][i] =
+						pwr2g.index_bw40_base[rf][idx];
+			}
+		}
+		for (i = 0; i < CHANNEL_MAX_NUMBER_5G; i++) {
+			idx = _rtl92ee_get_chnl_group(channel5g[i]);
+			efu->txpwr_5g_bw40base[rf][i] =
+					pwr5g.index_bw40_base[rf][idx];
+		}
+		for (i = 0; i < CHANNEL_MAX_NUMBER_5G_80M; i++) {
+			u8 upper, lower;
+			idx = _rtl92ee_get_chnl_group(channel5g_80m[i]);
+			upper = pwr5g.index_bw40_base[rf][idx];
+			lower = pwr5g.index_bw40_base[rf][idx + 1];
+
+			efu->txpwr_5g_bw80base[rf][i] = (upper + lower) / 2;
+		}
+		for (i = 0; i < MAX_TX_COUNT; i++) {
+			efu->txpwr_cckdiff[rf][i] = pwr2g.cck_diff[rf][i];
+			efu->txpwr_legacyhtdiff[rf][i] = pwr2g.ofdm_diff[rf][i];
+			efu->txpwr_ht20diff[rf][i] = pwr2g.bw20_diff[rf][i];
+			efu->txpwr_ht40diff[rf][i] = pwr2g.bw40_diff[rf][i];
+
+			efu->txpwr_5g_ofdmdiff[rf][i] = pwr5g.ofdm_diff[rf][i];
+			efu->txpwr_5g_bw20diff[rf][i] = pwr5g.bw20_diff[rf][i];
+			efu->txpwr_5g_bw40diff[rf][i] = pwr5g.bw40_diff[rf][i];
+			efu->txpwr_5g_bw80diff[rf][i] = pwr5g.bw80_diff[rf][i];
+		}
+	}
+
+	if (!autoload_fail)
+		efu->eeprom_thermalmeter = hwinfo[EEPROM_THERMAL_METER_92E];
+	else
+		efu->eeprom_thermalmeter = EEPROM_DEFAULT_THERMALMETER;
+
+	if (efu->eeprom_thermalmeter == 0xff || autoload_fail) {
+		efu->b_apk_thermalmeterignore = true;
+		efu->eeprom_thermalmeter = EEPROM_DEFAULT_THERMALMETER;
+	}
+
+	efu->thermalmeter[0] = efu->eeprom_thermalmeter;
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"thermalmeter = 0x%x\n", efu->eeprom_thermalmeter);
+
+	if (!autoload_fail) {
+		efu->eeprom_regulatory = hwinfo[EEPROM_RF_BOARD_OPTION_92E]
+					 & 0x07;
+		if (hwinfo[EEPROM_RF_BOARD_OPTION_92E] == 0xFF)
+			efu->eeprom_regulatory = 0;
+	} else {
+		efu->eeprom_regulatory = 0;
+	}
+	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
+		"eeprom_regulatory = 0x%x\n", efu->eeprom_regulatory);
+}
+
+static void _rtl92ee_read_adapter_info(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u16 i, usvalue;
+	u8 hwinfo[HWSET_MAX_SIZE];
+	u16 eeprom_id;
+
+	if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
+		stg_rtl_efuse92e_shadow_map_update(hw);
+
+		memcpy(hwinfo, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
+		       HWSET_MAX_SIZE);
+	} else if (rtlefuse->epromtype == EEPROM_93C46) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("RTL819X Not boot from eeprom, check it !!"));
+		return;
+	}  else {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("boot from neither eeprom nor efuse, check it !!"));
+		return;
+	}
+
+	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD, "MAP \n",
+		      hwinfo, HWSET_MAX_SIZE);
+
+	eeprom_id = *((u16 *) &hwinfo[0]);
+	if (eeprom_id != RTL8192E_EEPROM_ID) {
+		RT_TRACE(COMP_ERR, DBG_WARNING,
+			 ("EEPROM ID(%#x) is invalid!!\n", eeprom_id));
+		rtlefuse->autoload_failflag = true;
+	} else {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		rtlefuse->autoload_failflag = false;
+	}
+
+	if (rtlefuse->autoload_failflag == true)
+		return;
+	/*VID DID SVID SDID*/
+	rtlefuse->eeprom_vid = *(u16 *) &hwinfo[EEPROM_VID];
+	rtlefuse->eeprom_did = *(u16 *) &hwinfo[EEPROM_DID];
+	rtlefuse->eeprom_svid = *(u16 *) &hwinfo[EEPROM_SVID];
+	rtlefuse->eeprom_smid = *(u16 *) &hwinfo[EEPROM_SMID];
+	RT_TRACE(COMP_INIT, DBG_LOUD, ("EEPROMId = 0x%4x\n", eeprom_id));
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid));
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did));
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid));
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid));
+	/*customer ID*/
+	rtlefuse->eeprom_oemid = *(u8 *) &hwinfo[EEPROM_CUSTOMER_ID];
+	if (rtlefuse->eeprom_oemid == 0xFF)
+		rtlefuse->eeprom_oemid = 0;
+
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid));
+	/*EEPROM version*/
+	rtlefuse->eeprom_version = *(u8 *) &hwinfo[EEPROM_VERSION];
+	/*mac address*/
+	for (i = 0; i < 6; i += 2) {
+		usvalue = *(u16 *) &hwinfo[EEPROM_MAC_ADDR + i];
+		*((u16 *) (&rtlefuse->dev_addr[i])) = usvalue;
+	}
+
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("dev_addr: %pM\n", rtlefuse->dev_addr));
+	/*channel plan */
+	rtlefuse->eeprom_channelplan = *(u8 *) &hwinfo[EEPROM_CHANNELPLAN];
+	/* set channel paln to world wide 13 */
+	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
+	/*tx power*/
+	_rtl92ee_read_txpower_info_from_hwpg(hw, rtlefuse->autoload_failflag,
+					     hwinfo);
+
+	rtl92ee_read_bt_coexist_info_from_hwpg(hw, rtlefuse->autoload_failflag,
+					       hwinfo);
+
+	/*board type*/
+	rtlefuse->board_type = (((*(u8 *) &hwinfo[EEPROM_RF_BOARD_OPTION_92E])
+				& 0xE0) >> 5);
+	if ((*(u8 *) &hwinfo[EEPROM_RF_BOARD_OPTION_92E]) == 0xFF)
+		rtlefuse->board_type = 0;
+
+	rtlhal->boad_type = rtlefuse->board_type;
+	/*parse xtal*/
+	rtlefuse->crystalcap = hwinfo[EEPROM_XTAL_92E];
+	if (hwinfo[EEPROM_XTAL_92E] == 0xFF)
+		rtlefuse->crystalcap = 0x20;
+
+	/*antenna diversity*/
+	rtlefuse->antenna_div_type = NO_ANTDIV;
+	rtlefuse->antenna_div_cfg = 0;
+
+	if (rtlhal->oem_id == RT_CID_DEFAULT) {
+		switch (rtlefuse->eeprom_oemid) {
+		case EEPROM_CID_DEFAULT:
+			if (rtlefuse->eeprom_did == 0x818B) {
+				if ((rtlefuse->eeprom_svid == 0x10EC) &&
+				    (rtlefuse->eeprom_smid == 0x001B))
+					rtlhal->oem_id = RT_CID_819x_Lenovo;
+			} else {
+				rtlhal->oem_id = RT_CID_DEFAULT;
+			}
+			break;
+		default:
+			rtlhal->oem_id = RT_CID_DEFAULT;
+			break;
+		}
+	}
+}
+
+static void _rtl92ee_hal_customized_behavior(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
+	pcipriv->ledctl.bled_opendrain = true;
+
+	RT_TRACE(COMP_INIT, DBG_DMESG,
+		 ("RT Customized ID: 0x%02X\n", rtlhal->oem_id));
+}
+
+void rtl92ee_read_eeprom_info(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 tmp_u1b;
+
+	rtlhal->version = _rtl92ee_read_chip_version(hw);
+	if (get_rf_type(rtlphy) == RF_1T1R)
+		rtlpriv->dm.brfpath_rxenable[0] = true;
+	else
+		rtlpriv->dm.brfpath_rxenable[0] =
+		    rtlpriv->dm.brfpath_rxenable[1] = true;
+	RT_TRACE(COMP_INIT, DBG_LOUD, ("VersionID = 0x%4x\n",
+						rtlhal->version));
+	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
+	if (tmp_u1b & BIT(4)) {
+		RT_TRACE(COMP_INIT, DBG_DMESG, ("Boot from EEPROM\n"));
+		rtlefuse->epromtype = EEPROM_93C46;
+	} else {
+		RT_TRACE(COMP_INIT, DBG_DMESG, ("Boot from EFUSE\n"));
+		rtlefuse->epromtype = EEPROM_BOOT_EFUSE;
+	}
+	if (tmp_u1b & BIT(5)) {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		rtlefuse->autoload_failflag = false;
+		_rtl92ee_read_adapter_info(hw);
+	} else {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("Autoload ERR!!\n"));
+	}
+	_rtl92ee_hal_customized_behavior(hw);
+
+	rtlphy->rfpath_rx_enable[0] = true;
+	if (rtlphy->rf_type == RF_2T2R)
+		rtlphy->rfpath_rx_enable[1] = true;
+}
+
+static u8 _rtl92ee_mrate_idx_to_arfr_id(struct ieee80211_hw *hw, u8 rate_index)
+{
+	u8 ret = 0;
+
+	switch (rate_index) {
+	case RATR_INX_WIRELESS_NGB:
+		ret = 0;
+		break;
+	case RATR_INX_WIRELESS_N:
+	case RATR_INX_WIRELESS_NG:
+		ret = 4;
+		break;
+	case RATR_INX_WIRELESS_NB:
+		ret = 2;
+		break;
+	case RATR_INX_WIRELESS_GB:
+		ret = 6;
+		break;
+	case RATR_INX_WIRELESS_G:
+		ret = 7;
+		break;
+	case RATR_INX_WIRELESS_B:
+		ret = 8;
+		break;
+	default:
+		ret = 0;
+		break;
+	}
+	return ret;
+}
+
+static void rtl92ee_update_hal_rate_mask(struct ieee80211_hw *hw,
+					 struct ieee80211_sta *sta,
+					 u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_sta_info *sta_entry = NULL;
+	u32 ratr_bitmap;
+	u8 ratr_index;
+	u8 b_curtxbw_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SUP_WIDTH_20_40)
+			     ? 1 : 0;
+	u8 b_curshortgi_40mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+				1 : 0;
+	u8 b_curshortgi_20mhz = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+				1 : 0;
+	enum wireless_mode wirelessmode = 0;
+	bool b_shortgi = false;
+	u8 rate_mask[7] = {0};
+	u8 macid = 0;
+	/*u8 mimo_ps = IEEE80211_SMPS_OFF;*/
+	sta_entry = (struct rtl_sta_info *) sta->drv_priv;
+	wirelessmode = sta_entry->wireless_mode;
+	if (mac->opmode == NL80211_IFTYPE_STATION ||
+	    mac->opmode == NL80211_IFTYPE_MESH_POINT)
+		b_curtxbw_40mhz = mac->bw_40;
+	else if (mac->opmode == NL80211_IFTYPE_AP ||
+		 mac->opmode == NL80211_IFTYPE_ADHOC)
+		macid = sta->aid + 1;
+
+	ratr_bitmap = sta->supp_rates[0];
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		ratr_bitmap = 0xfff;
+
+	ratr_bitmap |= (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
+
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		ratr_index = RATR_INX_WIRELESS_B;
+		if (ratr_bitmap & 0x0000000c)
+			ratr_bitmap &= 0x0000000d;
+		else
+			ratr_bitmap &= 0x0000000f;
+		break;
+	case WIRELESS_MODE_G:
+		ratr_index = RATR_INX_WIRELESS_GB;
+
+		if (rssi_level == 1)
+			ratr_bitmap &= 0x00000f00;
+		else if (rssi_level == 2)
+			ratr_bitmap &= 0x00000ff0;
+		else
+			ratr_bitmap &= 0x00000ff5;
+		break;
+	case WIRELESS_MODE_N_24G:
+		if (b_curtxbw_40mhz)
+			ratr_index = RATR_INX_WIRELESS_NGB;
+		else
+			ratr_index = RATR_INX_WIRELESS_NB;
+
+		if (rtlphy->rf_type == RF_1T1R) {
+			if (b_curtxbw_40mhz) {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x000f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x000ff000;
+				else
+					ratr_bitmap &= 0x000ff015;
+			} else {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x000f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x000ff000;
+				else
+					ratr_bitmap &= 0x000ff005;
+			}
+		} else {
+			if (b_curtxbw_40mhz) {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x0f8f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0ffff000;
+				else
+					ratr_bitmap &= 0x0ffff015;
+			} else {
+				if (rssi_level == 1)
+					ratr_bitmap &= 0x0f8f0000;
+				else if (rssi_level == 2)
+					ratr_bitmap &= 0x0ffff000;
+				else
+					ratr_bitmap &= 0x0ffff005;
+			}
+		}
+
+		if ((b_curtxbw_40mhz && b_curshortgi_40mhz) ||
+		    (!b_curtxbw_40mhz && b_curshortgi_20mhz)) {
+
+			if (macid == 0)
+				b_shortgi = true;
+			else if (macid == 1)
+				b_shortgi = false;
+		}
+		break;
+	default:
+		ratr_index = RATR_INX_WIRELESS_NGB;
+
+		if (rtlphy->rf_type == RF_1T1R)
+			ratr_bitmap &= 0x000ff0ff;
+		else
+			ratr_bitmap &= 0x0f8ff0ff;
+		break;
+	}
+	ratr_index = _rtl92ee_mrate_idx_to_arfr_id(hw, ratr_index);
+	sta_entry->ratr_index = ratr_index;
+
+	RT_TRACE(COMP_RATR, DBG_DMESG,
+		 ("ratr_bitmap :%x\n", ratr_bitmap));
+	*(u32 *) &rate_mask = (ratr_bitmap & 0x0fffffff) |
+				       (ratr_index << 28);
+	rate_mask[0] = macid;
+	rate_mask[1] = ratr_index | (b_shortgi ? 0x80 : 0x00);
+	rate_mask[2] = b_curtxbw_40mhz;
+	rate_mask[3] = (u8)(ratr_bitmap & 0x000000ff);
+	rate_mask[4] = (u8)((ratr_bitmap & 0x0000ff00) >> 8);
+	rate_mask[5] = (u8)((ratr_bitmap & 0x00ff0000) >> 16);
+	rate_mask[6] = (u8)((ratr_bitmap & 0xff000000) >> 24);
+	RT_TRACE(COMP_RATR, DBG_DMESG,
+		 ("Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x:%x:%x\n",
+		  ratr_index, ratr_bitmap, rate_mask[0], rate_mask[1],
+		  rate_mask[2], rate_mask[3], rate_mask[4],
+		  rate_mask[5], rate_mask[6]));
+	rtl92ee_fill_h2c_cmd(hw, H2C_92E_RA_MASK, 7, rate_mask);
+	_rtl92ee_set_bcn_ctrl_reg(hw, BIT(3), 0);
+}
+
+
+void rtl92ee_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta, u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->dm.b_useramask)
+		rtl92ee_update_hal_rate_mask(hw, sta, rssi_level);
+}
+
+void rtl92ee_update_channel_access_setting(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	u16 sifs_timer;
+
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
+				      (u8 *) &mac->slot_time);
+	if (!mac->ht_enable)
+		sifs_timer = 0x0a0a;
+	else
+		sifs_timer = 0x0e0e;
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SIFS, (u8 *) &sifs_timer);
+}
+
+bool rtl92ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
+{
+	*valid = 1;
+	return true;
+}
+
+void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key_index,
+		     u8 *p_macaddr, bool is_group, u8 enc_algo,
+		     bool is_wepkey, bool clear_all)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u8 *macaddr = p_macaddr;
+	u32 entry_id = 0;
+	bool is_pairwise = false;
+
+	static u8 cam_const_addr[4][6] = {
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x01},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x02},
+		{0x00, 0x00, 0x00, 0x00, 0x00, 0x03}
+	};
+	static u8 cam_const_broad[] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+
+	if (clear_all) {
+		u8 idx = 0;
+		u8 cam_offset = 0;
+		u8 clear_number = 5;
+
+		RT_TRACE(COMP_SEC, DBG_DMESG, ("clear_all\n"));
+
+		for (idx = 0; idx < clear_number; idx++) {
+			stg_rtl_cam_mark_invalid(hw, cam_offset + idx);
+			stg_rtl_cam_empty_entry(hw, cam_offset + idx);
+
+			if (idx < 5) {
+				memset(rtlpriv->sec.key_buf[idx], 0,
+				       MAX_KEY_LEN);
+				rtlpriv->sec.key_len[idx] = 0;
+			}
+		}
+
+	} else {
+		switch (enc_algo) {
+		case WEP40_ENCRYPTION:
+			enc_algo = CAM_WEP40;
+			break;
+		case WEP104_ENCRYPTION:
+			enc_algo = CAM_WEP104;
+			break;
+		case TKIP_ENCRYPTION:
+			enc_algo = CAM_TKIP;
+			break;
+		case AESCCMP_ENCRYPTION:
+			enc_algo = CAM_AES;
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_LOUD,
+				 ("switch case not process \n"));
+			enc_algo = CAM_TKIP;
+			break;
+		}
+
+		if (is_wepkey || rtlpriv->sec.use_defaultkey) {
+			macaddr = cam_const_addr[key_index];
+			entry_id = key_index;
+		} else {
+			if (is_group) {
+				macaddr = cam_const_broad;
+				entry_id = key_index;
+			} else {
+				if (mac->opmode == NL80211_IFTYPE_AP ||
+				    mac->opmode == NL80211_IFTYPE_MESH_POINT) {
+					entry_id = stg_rtl_cam_get_free_entry(hw,
+								     p_macaddr);
+					if (entry_id >=  TOTAL_CAM_ENTRY) {
+						RT_TRACE(COMP_SEC, DBG_EMERG,
+							 ("Can not find free hw security cam entry\n"));
+						return;
+					}
+				} else {
+					entry_id = CAM_PAIRWISE_KEY_POSITION;
+				}
+
+				key_index = PAIRWISE_KEYIDX;
+				is_pairwise = true;
+			}
+		}
+
+		if (rtlpriv->sec.key_len[key_index] == 0) {
+			RT_TRACE(COMP_SEC, DBG_DMESG,
+				 ("delete one entry, entry_id is %d\n",
+				 entry_id));
+			if (mac->opmode == NL80211_IFTYPE_AP ||
+			    mac->opmode == NL80211_IFTYPE_MESH_POINT)
+				stg_rtl_cam_del_entry(hw, p_macaddr);
+			stg_rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
+		} else {
+			RT_TRACE(COMP_SEC, DBG_DMESG, ("add one entry\n"));
+			if (is_pairwise) {
+				RT_TRACE(COMP_SEC, DBG_DMESG,
+					 ("set Pairwiase key\n"));
+
+				stg_rtl_cam_add_one_entry(hw, macaddr, key_index,
+					       entry_id, enc_algo,
+					       CAM_CONFIG_NO_USEDK,
+					       rtlpriv->sec.key_buf[key_index]);
+			} else {
+				RT_TRACE(COMP_SEC, DBG_DMESG,
+					 ("set group key\n"));
+
+				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
+					stg_rtl_cam_add_one_entry(hw,
+						rtlefuse->dev_addr,
+						PAIRWISE_KEYIDX,
+						CAM_PAIRWISE_KEY_POSITION,
+						enc_algo, CAM_CONFIG_NO_USEDK,
+						rtlpriv->sec.key_buf[entry_id]);
+				}
+
+				stg_rtl_cam_add_one_entry(hw, macaddr, key_index,
+						entry_id, enc_algo,
+						CAM_CONFIG_NO_USEDK,
+						rtlpriv->sec.key_buf[entry_id]);
+			}
+		}
+	}
+}
+
+void rtl92ee_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
+					    bool auto_load_fail, u8 *hwinfo)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u8 value;
+
+	if (!auto_load_fail) {
+		value = hwinfo[EEPROM_RF_BOARD_OPTION_92E];
+		if (((value & 0xe0) >> 5) == 0x1)
+			rtlpriv->btcoexist.btc_info.btcoexist = 1;
+		else
+			rtlpriv->btcoexist.btc_info.btcoexist = 0;
+
+		rtlpriv->btcoexist.btc_info.bt_type = BT_RTL8192E;
+		rtlpriv->btcoexist.btc_info.ant_num = ANT_TOTAL_X2;
+	} else {
+		rtlpriv->btcoexist.btc_info.btcoexist = 1;
+		rtlpriv->btcoexist.btc_info.bt_type = BT_RTL8192E;
+		rtlpriv->btcoexist.btc_info.ant_num = ANT_TOTAL_X1;
+	}
+}
+
+void rtl92ee_bt_reg_init(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+
+	/* 0:Low, 1:High, 2:From Efuse. */
+	rtlpcipriv->btcoexist.b_reg_bt_iso = 2;
+	/* 0:Idle, 1:None-SCO, 2:SCO, 3:From Counter. */
+	rtlpcipriv->btcoexist.b_reg_bt_sco = 3;
+	/* 0:Disable BT control A-MPDU, 1:Enable BT control A-MPDU. */
+	rtlpcipriv->btcoexist.b_reg_bt_sco = 0;
+}
+
+void rtl92ee_bt_hw_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->cfg->ops->get_btc_status()) {
+		rtlpriv->btcoexist.btc_ops->btc_init_hw_config(rtlpriv);
+	}
+}
+
+void rtl92ee_suspend(struct ieee80211_hw *hw)
+{
+}
+
+void rtl92ee_resume(struct ieee80211_hw *hw)
+{
+}
+
+/* Turn on AAP (RCR:bit 0) for promicuous mode. */
+void rtl92ee_allow_all_destaddr(struct ieee80211_hw *hw,
+				bool allow_all_da, bool write_into_reg)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	if (allow_all_da)	/* Set BIT0 */
+		rtlpci->receive_config |= RCR_AAP;
+	else			/* Clear BIT0 */
+		rtlpci->receive_config &= ~RCR_AAP;
+
+	if (write_into_reg)
+		rtl_write_dword(rtlpriv, REG_RCR, rtlpci->receive_config);
+
+	RT_TRACE(COMP_TURBO | COMP_INIT, DBG_LOUD,
+		 ("receive_config = 0x%08X, write_into_reg =%d\n",
+		  rtlpci->receive_config, write_into_reg));
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/hw.h b/drivers/staging/rtl8192ee/rtl8192ee/hw.h
new file mode 100644
index 0000000..e99d7bd
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/hw.h
@@ -0,0 +1,67 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_HW_H__
+#define __RTL92E_HW_H__
+
+
+void rtl92ee_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
+void rtl92ee_read_eeprom_info(struct ieee80211_hw *hw);
+void rtl92ee_interrupt_recognized(struct ieee80211_hw *hw,
+				  u32 *p_inta, u32 *p_intb);
+int rtl92ee_hw_init(struct ieee80211_hw *hw);
+void rtl92ee_card_disable(struct ieee80211_hw *hw);
+void rtl92ee_enable_interrupt(struct ieee80211_hw *hw);
+void rtl92ee_disable_interrupt(struct ieee80211_hw *hw);
+int rtl92ee_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type);
+void rtl92ee_set_check_bssid(struct ieee80211_hw *hw, bool check_bssid);
+void rtl92ee_set_qos(struct ieee80211_hw *hw, int aci);
+void rtl92ee_set_beacon_related_registers(struct ieee80211_hw *hw);
+void rtl92ee_set_beacon_interval(struct ieee80211_hw *hw);
+void rtl92ee_update_interrupt_mask(struct ieee80211_hw *hw,
+				   u32 add_msr, u32 rm_msr);
+void rtl92ee_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
+void rtl92ee_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta, u8 rssi_level);
+void rtl92ee_update_channel_access_setting(struct ieee80211_hw *hw);
+bool rtl92ee_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid);
+void rtl92ee_enable_hw_security_config(struct ieee80211_hw *hw);
+void rtl92ee_set_key(struct ieee80211_hw *hw, u32 key_index,
+		     u8 *p_macaddr, bool is_group, u8 enc_algo,
+		     bool is_wepkey, bool clear_all);
+void rtl92ee_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
+					    bool autoload_fail, u8 *hwinfo);
+void rtl92ee_bt_reg_init(struct ieee80211_hw *hw);
+void rtl92ee_bt_hw_init(struct ieee80211_hw *hw);
+void rtl92ee_suspend(struct ieee80211_hw *hw);
+void rtl92ee_resume(struct ieee80211_hw *hw);
+void rtl92ee_allow_all_destaddr(struct ieee80211_hw *hw, bool allow_all_da,
+				bool write_into_reg);
+void rtl92ee_fw_clk_off_timer_callback(unsigned long data);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/led.c b/drivers/staging/rtl8192ee/rtl8192ee/led.c
new file mode 100644
index 0000000..3b459c9
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/led.c
@@ -0,0 +1,134 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "../pci.h"
+#include "led.h"
+#include "reg.h"
+
+static void _rtl92ee_init_led(struct ieee80211_hw *hw,
+			      struct rtl_led *pled, enum rtl_led_pin ledpin)
+{
+	pled->hw = hw;
+	pled->ledpin = ledpin;
+	pled->b_ledon = false;
+}
+
+void rtl92ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	u32 ledcfg;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	RT_TRACE(COMP_LED, DBG_LOUD,
+		 ("LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin));
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg = rtl_read_dword(rtlpriv, REG_GPIO_PIN_CTRL) | BIT(21);
+		ledcfg &= ~BIT(13) & ~BIT(29);
+		rtl_write_dword(rtlpriv, REG_GPIO_PIN_CTRL, ledcfg);
+		break;
+	case LED_PIN_LED1:
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("switch case not process\n"));
+		break;
+	}
+	pled->b_ledon = true;
+}
+
+void rtl92ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 ledcfg;
+
+	RT_TRACE(COMP_LED, DBG_LOUD,
+		 ("LedAddr:%X ledpin =%d\n", REG_LEDCFG2, pled->ledpin));
+
+	switch (pled->ledpin) {
+	case LED_PIN_GPIO0:
+		break;
+	case LED_PIN_LED0:
+		ledcfg = rtl_read_dword(rtlpriv , REG_GPIO_PIN_CTRL) | ~BIT(21);
+		ledcfg &= ~BIT(29);
+		rtl_write_dword(rtlpriv, REG_GPIO_PIN_CTRL, ledcfg);
+		break;
+	case LED_PIN_LED1:
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_LOUD,
+			 ("switch case not process\n"));
+		break;
+	}
+	pled->b_ledon = false;
+}
+
+void rtl92ee_init_sw_leds(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	_rtl92ee_init_led(hw, &(pcipriv->ledctl.sw_led0), LED_PIN_LED0);
+	_rtl92ee_init_led(hw, &(pcipriv->ledctl.sw_led1), LED_PIN_LED1);
+}
+
+static void _rtl92ee_sw_led_control(struct ieee80211_hw *hw,
+				    enum led_ctl_mode ledaction)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_led *pLed0 = &(pcipriv->ledctl.sw_led0);
+	switch (ledaction) {
+	case LED_CTL_POWER_ON:
+	case LED_CTL_LINK:
+	case LED_CTL_NO_LINK:
+		rtl92ee_sw_led_on(hw, pLed0);
+		break;
+	case LED_CTL_POWER_OFF:
+		rtl92ee_sw_led_off(hw, pLed0);
+		break;
+	default:
+		break;
+	}
+}
+
+void rtl92ee_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+
+	if ((ppsc->rfoff_reason > RF_CHANGE_BY_PS) &&
+	    (ledaction == LED_CTL_TX ||
+	     ledaction == LED_CTL_RX ||
+	     ledaction == LED_CTL_SITE_SURVEY ||
+	     ledaction == LED_CTL_LINK ||
+	     ledaction == LED_CTL_NO_LINK ||
+	     ledaction == LED_CTL_START_TO_LINK ||
+	     ledaction == LED_CTL_POWER_ON)) {
+		return;
+	}
+	RT_TRACE(COMP_LED, DBG_TRACE, ("ledaction %d,\n", ledaction));
+	_rtl92ee_sw_led_control(hw, ledaction);
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/led.h b/drivers/staging/rtl8192ee/rtl8192ee/led.h
new file mode 100644
index 0000000..7302eda
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/led.h
@@ -0,0 +1,37 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_LED_H__
+#define __RTL92E_LED_H__
+
+void rtl92ee_init_sw_leds(struct ieee80211_hw *hw);
+void rtl92ee_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl92ee_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled);
+void rtl92ee_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/phy.c b/drivers/staging/rtl8192ee/rtl8192ee/phy.c
new file mode 100644
index 0000000..beef284
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/phy.c
@@ -0,0 +1,3282 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
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
+
+static u32 _rtl92ee_phy_rf_serial_read(struct ieee80211_hw *hw,
+				       enum radio_path rfpath, u32 offset);
+static void _rtl92ee_phy_rf_serial_write(struct ieee80211_hw *hw,
+					 enum radio_path rfpath, u32 offset,
+					 u32 data);
+static u32 _rtl92ee_phy_calculate_bit_shift(u32 bitmask);
+static bool _rtl92ee_phy_bb8192ee_config_parafile(struct ieee80211_hw *hw);
+static bool _rtl92ee_phy_config_mac_with_headerfile(struct ieee80211_hw *hw);
+static bool _rtl92ee_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						   u8 configtype);
+static bool _rtl92ee_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
+						     u8 configtype);
+static void _rtl92ee_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw);
+static bool _rtl92ee_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
+					      u32 cmdtableidx, u32 cmdtablesz,
+					      enum swchnlcmd_id cmdid,
+					      u32 para1, u32 para2,
+					      u32 msdelay);
+static bool _rtl92ee_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					      u8 channel, u8 *stage,
+					      u8 *step, u32 *delay);
+static long _rtl92ee_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					  enum wireless_mode wirelessmode,
+					  u8 txpwridx);
+static void rtl92ee_phy_set_rf_on(struct ieee80211_hw *hw);
+static void rtl92ee_phy_set_io(struct ieee80211_hw *hw);
+
+u32 rtl92ee_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 returnvalue, originalvalue, bitshift;
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), bitmask(%#x)\n", regaddr, bitmask));
+	originalvalue = rtl_read_dword(rtlpriv, regaddr);
+	bitshift = _rtl92ee_phy_calculate_bit_shift(bitmask);
+	returnvalue = (originalvalue & bitmask) >> bitshift;
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("BBR MASK = 0x%x Addr[0x%x]= 0x%x\n",
+		  bitmask, regaddr, originalvalue));
+
+	return returnvalue;
+}
+
+void rtl92ee_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr,
+			    u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 originalvalue, bitshift;
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		  regaddr, bitmask, data));
+
+	if (bitmask != MASKDWORD) {
+		originalvalue = rtl_read_dword(rtlpriv, regaddr);
+		bitshift = _rtl92ee_phy_calculate_bit_shift(bitmask);
+		data = ((originalvalue & (~bitmask)) | (data << bitshift));
+	}
+
+	rtl_write_dword(rtlpriv, regaddr, data);
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		  regaddr, bitmask, data));
+}
+
+u32 rtl92ee_phy_query_rf_reg(struct ieee80211_hw *hw,
+			     enum radio_path rfpath, u32 regaddr, u32 bitmask)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 original_value, readback_value, bitshift;
+	unsigned long flags;
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		  regaddr, rfpath, bitmask));
+
+	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
+
+
+	original_value = _rtl92ee_phy_rf_serial_read(hw , rfpath, regaddr);
+	bitshift = _rtl92ee_phy_calculate_bit_shift(bitmask);
+	readback_value = (original_value & bitmask) >> bitshift;
+
+	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		  regaddr, rfpath, bitmask, original_value));
+
+	return readback_value;
+}
+
+void rtl92ee_phy_set_rf_reg(struct ieee80211_hw *hw,
+			    enum radio_path rfpath,
+			    u32 addr, u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 original_value, bitshift;
+	unsigned long flags;
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		  addr, bitmask, data, rfpath));
+
+	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
+
+	if (bitmask != RFREG_OFFSET_MASK) {
+		original_value = _rtl92ee_phy_rf_serial_read(hw, rfpath, addr);
+		bitshift = _rtl92ee_phy_calculate_bit_shift(bitmask);
+		data = (original_value & (~bitmask)) | (data << bitshift);
+	}
+
+	_rtl92ee_phy_rf_serial_write(hw, rfpath, addr, data);
+
+	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
+
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		  addr, bitmask, data, rfpath));
+}
+
+static u32 _rtl92ee_phy_rf_serial_read(struct ieee80211_hw *hw,
+				       enum radio_path rfpath, u32 offset)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
+	u32 newoffset;
+	u32 tmplong, tmplong2;
+	u8 rfpi_enable = 0;
+	u32 retvalue;
+
+	offset &= 0xff;
+	newoffset = offset;
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("return all one\n"));
+		return 0xFFFFFFFF;
+	}
+	tmplong = rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD);
+	if (rfpath == RF90_PATH_A)
+		tmplong2 = tmplong;
+	else
+		tmplong2 = rtl_get_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD);
+	tmplong2 = (tmplong2 & (~BLSSIREADADDRESS)) |
+		   (newoffset << 23) | BLSSIREADEDGE;
+	rtl_set_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD,
+		      tmplong & (~BLSSIREADEDGE));
+	mdelay(1);
+	rtl_set_bbreg(hw, pphyreg->rfhssi_para2, MASKDWORD, tmplong2);
+	mdelay(1);
+	mdelay(1);
+	if (rfpath == RF90_PATH_A)
+		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER1,
+						 BIT(8));
+	else if (rfpath == RF90_PATH_B)
+		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
+						 BIT(8));
+	if (rfpi_enable)
+		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readbackpi,
+					 BLSSIREADBACKDATA);
+	else
+		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
+					 BLSSIREADBACKDATA);
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("RFR-%d Addr[0x%x]= 0x%x\n",
+		  rfpath, pphyreg->rflssi_readback, retvalue));
+	return retvalue;
+}
+
+static void _rtl92ee_phy_rf_serial_write(struct ieee80211_hw *hw,
+					 enum radio_path rfpath, u32 offset,
+					 u32 data)
+{
+	u32 data_and_addr;
+	u32 newoffset;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
+
+	if (RT_CANNOT_IO(hw)) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("stop\n"));
+		return;
+	}
+	offset &= 0xff;
+	newoffset = offset;
+	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
+	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
+	RT_TRACE(COMP_RF, DBG_TRACE,
+		 ("RFW-%d Addr[0x%x]= 0x%x\n", rfpath,
+		  pphyreg->rf3wire_offset, data_and_addr));
+}
+
+static u32 _rtl92ee_phy_calculate_bit_shift(u32 bitmask)
+{
+	u32 i;
+
+	for (i = 0; i <= 31; i++) {
+		if (((bitmask >> i) & 0x1) == 1)
+			break;
+	}
+	return i;
+}
+
+bool rtl92ee_phy_mac_config(struct ieee80211_hw *hw)
+{
+	bool rtstatus = _rtl92ee_phy_config_mac_with_headerfile(hw);
+
+	return rtstatus;
+}
+
+bool rtl92ee_phy_bb_config(struct ieee80211_hw *hw)
+{
+	bool rtstatus = true;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 regval;
+	u32 tmp;
+	u8 crystal_cap;
+
+	_rtl92ee_phy_init_bb_rf_register_definition(hw);
+	regval = rtl_read_word(rtlpriv, REG_SYS_FUNC_EN);
+	rtl_write_word(rtlpriv, REG_SYS_FUNC_EN,
+		       regval | BIT(13) | BIT(0) | BIT(1));
+
+	rtl_write_byte(rtlpriv, REG_RF_CTRL, RF_EN | RF_RSTB | RF_SDMRSTB);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN,
+		       FEN_PPLL | FEN_PCIEA | FEN_DIO_PCIE |
+		       FEN_BB_GLB_RSTn | FEN_BBRSTB);
+
+	rtl_write_byte(rtlpriv, REG_AFE_XTAL_CTRL + 1, 0x80);
+
+	tmp = rtl_read_dword(rtlpriv, 0x4c);
+	rtl_write_dword(rtlpriv, 0x4c, tmp | BIT(23));
+
+	rtstatus = _rtl92ee_phy_bb8192ee_config_parafile(hw);
+
+	crystal_cap = rtlpriv->efuse.eeprom_crystalcap & 0x3F;
+	rtl_set_bbreg(hw, REG_MAC_PHY_CTRL, 0xFFF000,
+		      (crystal_cap | (crystal_cap << 6)));
+	return rtstatus;
+}
+
+bool rtl92ee_phy_rf_config(struct ieee80211_hw *hw)
+{
+	return rtl92ee_phy_rf6052_config(hw);
+}
+
+static bool _check_condition(struct ieee80211_hw *hw,
+				     const u32  condition)
+{
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	u32 _board = rtlefuse->board_type; /*need efuse define*/
+	u32 _interface = rtlhal->interface;
+	u32 _platform = 0x08;/*SupportPlatform */
+	u32 cond = condition;
+
+	if (condition == 0xCDCDCDCD)
+		return true;
+	cond = condition & 0xFF;
+	if ((_board != cond) && (cond != 0xFF))
+		return false;
+	cond = condition & 0xFF00;
+	cond = cond >> 8;
+	if ((_interface & cond) == 0 && cond != 0x07)
+		return false;
+	cond = condition & 0xFF0000;
+	cond = cond >> 16;
+	if ((_platform & cond) == 0 && cond != 0x0F)
+		return false;
+	return true;
+}
+
+static void _rtl92ee_config_rf_reg(struct ieee80211_hw *hw, u32 addr, u32 data,
+				   enum radio_path rfpath, u32 regaddr)
+{
+	if (addr == 0xfe || addr == 0xffe) {
+		mdelay(50);
+	} else {
+		rtl_set_rfreg(hw, rfpath, regaddr, RFREG_OFFSET_MASK, data);
+		udelay(1);
+
+		if (addr == 0xb6) {
+			u32 getvalue;
+			u8 count = 0;
+			getvalue = rtl_get_rfreg(hw, rfpath, addr, MASKDWORD);
+			udelay(1);
+
+			while ((getvalue >> 8) != (data >> 8)) {
+				count++;
+				rtl_set_rfreg(hw, rfpath, regaddr,
+					      RFREG_OFFSET_MASK, data);
+				udelay(1);
+				getvalue = rtl_get_rfreg(hw, rfpath, addr,
+							 MASKDWORD);
+				if (count > 5)
+					break;
+			}
+		}
+
+		if (addr == 0xb2) {
+			u32 getvalue;
+			u8 count = 0;
+			getvalue = rtl_get_rfreg(hw, rfpath, addr, MASKDWORD);
+
+			udelay(1);
+
+			while (getvalue != data) {
+				count++;
+				rtl_set_rfreg(hw, rfpath, regaddr,
+					      RFREG_OFFSET_MASK, data);
+				udelay(1);
+				rtl_set_rfreg(hw, rfpath, 0x18,
+					      RFREG_OFFSET_MASK, 0x0fc07);
+				udelay(1);
+				getvalue = rtl_get_rfreg(hw, rfpath, addr,
+							 MASKDWORD);
+				if (count > 5)
+					break;
+			}
+		}
+	}
+}
+
+static void _rtl92ee_config_rf_radio_a(struct ieee80211_hw *hw,
+				       u32 addr, u32 data)
+{
+	u32 content = 0x1000; /*RF Content: radio_a_txt*/
+	u32 maskforphyset = (u32)(content & 0xE000);
+
+	_rtl92ee_config_rf_reg(hw, addr, data, RF90_PATH_A,
+			       addr | maskforphyset);
+}
+
+static void _rtl92ee_config_rf_radio_b(struct ieee80211_hw *hw,
+				       u32 addr, u32 data)
+{
+	u32 content = 0x1001; /*RF Content: radio_b_txt*/
+	u32 maskforphyset = (u32)(content & 0xE000);
+
+	_rtl92ee_config_rf_reg(hw, addr, data, RF90_PATH_B,
+			       addr | maskforphyset);
+}
+
+static void _rtl92ee_config_bb_reg(struct ieee80211_hw *hw,
+				   u32 addr, u32 data)
+{
+	if (addr == 0xfe)
+		mdelay(50);
+	else if (addr == 0xfd)
+		mdelay(5);
+	else if (addr == 0xfc)
+		mdelay(1);
+	else if (addr == 0xfb)
+		udelay(50);
+	else if (addr == 0xfa)
+		udelay(5);
+	else if (addr == 0xf9)
+		udelay(1);
+	else
+		rtl_set_bbreg(hw, addr, MASKDWORD , data);
+
+	udelay(1);
+}
+
+static void _rtl92ee_phy_init_tx_power_by_rate(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	u8 band = BAND_ON_2_4G, rf = 0, txnum = 0, sec = 0;
+
+	for (; band <= BAND_ON_5G; ++band)
+		for (; rf < TX_PWR_BY_RATE_NUM_RF; ++rf)
+			for (; txnum < TX_PWR_BY_RATE_NUM_RF; ++txnum)
+				for (; sec < TX_PWR_BY_RATE_NUM_SECTION; ++sec)
+					rtlphy->tx_power_by_rate_offset
+						     [band][rf][txnum][sec] = 0;
+}
+
+static void _rtl92ee_phy_set_txpower_by_rate_base(struct ieee80211_hw *hw,
+						  u8 band, u8 path,
+						  u8 rate_section, u8 txnum, u8 value)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	if (path > RF90_PATH_D) {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Invalid Rf Path %d\n", path));
+		return;
+	}
+	if (band == BAND_ON_2_4G) {
+		switch (rate_section) {
+		case CCK:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][0] = value;
+			break;
+		case OFDM:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][1] = value;
+			break;
+		case HT_MCS0_MCS7:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][2] = value;
+			break;
+		case HT_MCS8_MCS15:
+			rtlphy->txpwr_by_rate_base_24g[path][txnum][3] = value;
+			break;
+		default:
+			RT_TRACE(COMP_INIT, DBG_LOUD,
+				 ("Invalid RateSection %d in 2.4G, Rf %d,%dTx\n",
+				  rate_section, path, txnum));
+			break;
+		};
+	} else {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Invalid Band %d\n", band));
+	}
+}
+
+static u8 _rtl92ee_phy_get_txpower_by_rate_base(struct ieee80211_hw *hw, u8 band,
+						u8 path, u8 txnum, u8 rate_section)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 value = 0;
+	if (path > RF90_PATH_D) {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Invalid Rf Path %d\n", path));
+		return 0;
+	}
+	if (band == BAND_ON_2_4G) {
+		switch (rate_section) {
+		case CCK:
+			value = rtlphy->txpwr_by_rate_base_24g[path][txnum][0];
+			break;
+		case OFDM:
+			value = rtlphy->txpwr_by_rate_base_24g[path][txnum][1];
+			break;
+		case HT_MCS0_MCS7:
+			value = rtlphy->txpwr_by_rate_base_24g[path][txnum][2];
+			break;
+		case HT_MCS8_MCS15:
+			value = rtlphy->txpwr_by_rate_base_24g[path][txnum][3];
+			break;
+		default:
+			RT_TRACE(COMP_INIT, DBG_LOUD,
+				 ("Invalid RateSection %d in 2.4G, Rf %d,%dTx\n",
+				  rate_section, path, txnum));
+			break;
+		};
+	} else {
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Invalid Band %d()\n", band));
+	}
+	return value;
+}
+
+static void _rtl92ee_phy_store_txpower_by_rate_base(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u16 raw = 0;
+	u8 base = 0, path = 0;
+
+	for (path = RF90_PATH_A; path <= RF90_PATH_B; ++path) {
+		if (path == RF90_PATH_A) {
+			raw = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][path][RF_1TX][3] >> 24) & 0xFF;
+			base = (raw >> 4) * 10 + (raw & 0xF);
+			_rtl92ee_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G,
+							      path, CCK, RF_1TX,
+							      base);
+		} else if (path == RF90_PATH_B) {
+			raw = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][path][RF_1TX][3] >> 0) & 0xFF;
+			base = (raw >> 4) * 10 + (raw & 0xF);
+			_rtl92ee_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G,
+							      path, CCK, RF_1TX,
+							      base);
+		}
+		raw = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][path][RF_1TX][1] >> 24) & 0xFF;
+		base = (raw >> 4) * 10 + (raw & 0xF);
+		_rtl92ee_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path,
+						      OFDM, RF_1TX, base);
+
+		raw = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][path][RF_1TX][5] >> 24) & 0xFF;
+		base = (raw >> 4) * 10 + (raw & 0xF);
+		_rtl92ee_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path,
+						      HT_MCS0_MCS7, RF_1TX,
+						      base);
+
+		raw = (u16) (rtlphy->tx_power_by_rate_offset[BAND_ON_2_4G][path][RF_2TX][7] >> 24) & 0xFF;
+		base = (raw >> 4) * 10 + (raw & 0xF);
+		_rtl92ee_phy_set_txpower_by_rate_base(hw, BAND_ON_2_4G, path,
+						      HT_MCS8_MCS15, RF_2TX,
+						      base);
+	}
+}
+
+static void _phy_convert_txpower_dbm_to_relative_value(u32 *data, u8 start,
+						       u8 end, u8 base)
+{
+	char i = 0;
+	u8 tmp = 0;
+	u32 temp_data = 0;
+
+	for (i = 3; i >= 0; --i) {
+		if (i >= start && i <= end) {
+			/* Get the exact value */
+			tmp = (u8) (*data >> (i * 8)) & 0xF;
+			tmp += ((u8) ((*data >> (i * 8 + 4)) & 0xF)) * 10;
+
+			/* Change the value to a relative value */
+			tmp = (tmp > base) ? tmp - base : base - tmp;
+		} else {
+			tmp = (u8) (*data >> (i * 8)) & 0xFF;
+		}
+		temp_data <<= 8;
+		temp_data |= tmp;
+	}
+	*data = temp_data;
+}
+
+static void _rtl92ee_phy_convert_txpower_dbm_to_relative_value(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 base = 0, rf = 0, band = BAND_ON_2_4G;
+
+	for (rf = RF90_PATH_A; rf <= RF90_PATH_B; ++rf) {
+		if (rf == RF90_PATH_A) {
+			base = _rtl92ee_phy_get_txpower_by_rate_base(hw, band,
+								     rf, RF_1TX,
+								     CCK);
+			_phy_convert_txpower_dbm_to_relative_value(
+				&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][2]),
+				1, 1, base);
+			_phy_convert_txpower_dbm_to_relative_value(
+				&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][3]),
+				1, 3, base);
+		} else if (rf == RF90_PATH_B) {
+			base = _rtl92ee_phy_get_txpower_by_rate_base(hw, band,
+								     rf, RF_1TX,
+								     CCK);
+			_phy_convert_txpower_dbm_to_relative_value(
+				&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][3]),
+				0, 0, base);
+			_phy_convert_txpower_dbm_to_relative_value(
+				&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][2]),
+				1, 3, base);
+		}
+		base = _rtl92ee_phy_get_txpower_by_rate_base(hw, band, rf,
+							     RF_1TX, OFDM);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][0]),
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][1]),
+			0, 3, base);
+
+		base = _rtl92ee_phy_get_txpower_by_rate_base(hw, band, rf,
+							     RF_1TX,
+							     HT_MCS0_MCS7);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][4]),
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_1TX][5]),
+			0, 3, base);
+		base = _rtl92ee_phy_get_txpower_by_rate_base(hw, band, rf,
+							     RF_2TX,
+							     HT_MCS8_MCS15);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_2TX][6]),
+			0, 3, base);
+		_phy_convert_txpower_dbm_to_relative_value(
+			&(rtlphy->tx_power_by_rate_offset[band][rf][RF_2TX][7]),
+			0, 3, base);
+	}
+	RT_TRACE(COMP_POWER, DBG_TRACE,
+		 ("<== _rtl92ee_phy_convert_txpower_dbm_to_relative_value()\n"));
+}
+
+static void _rtl92ee_phy_txpower_by_rate_configuration(struct ieee80211_hw *hw)
+{
+	_rtl92ee_phy_store_txpower_by_rate_base(hw);
+	_rtl92ee_phy_convert_txpower_dbm_to_relative_value(hw);
+}
+
+static bool _rtl92ee_phy_bb8192ee_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	bool rtstatus;
+
+	rtstatus = _rtl92ee_phy_config_bb_with_headerfile(hw,
+						       BASEBAND_CONFIG_PHY_REG);
+	if (!rtstatus) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("Write BB Reg Fail!!"));
+		return false;
+	}
+
+	_rtl92ee_phy_init_tx_power_by_rate(hw);
+	if (rtlefuse->autoload_failflag == false) {
+		rtlphy->pwrgroup_cnt = 0;
+		rtstatus = _rtl92ee_phy_config_bb_with_pgheaderfile(hw,
+						       BASEBAND_CONFIG_PHY_REG);
+	}
+	_rtl92ee_phy_txpower_by_rate_configuration(hw);
+	if (!rtstatus) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("BB_PG Reg Fail!!"));
+		return false;
+	}
+	rtstatus = _rtl92ee_phy_config_bb_with_headerfile(hw,
+						       BASEBAND_CONFIG_AGC_TAB);
+	if (!rtstatus) {
+		RT_TRACE(COMP_ERR, DBG_EMERG, ("AGC Table Fail\n"));
+		return false;
+	}
+	rtlphy->bcck_high_power = (bool) (rtl_get_bbreg(hw,
+						       RFPGA0_XA_HSSIPARAMETER2,
+						       0x200));
+
+	return true;
+}
+
+static bool _rtl92ee_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 i;
+	u32 arraylength;
+	u32 *ptrarray;
+
+	RT_TRACE(COMP_INIT, DBG_TRACE, ("Read Rtl8192EMACPHY_Array\n"));
+	arraylength = RTL8192EE_MAC_ARRAY_LEN;
+	ptrarray = RTL8192EE_MAC_ARRAY;
+	RT_TRACE(COMP_INIT, DBG_LOUD,
+		 ("Img:RTL8192EE_MAC_ARRAY LEN %d\n" , arraylength));
+	for (i = 0; i < arraylength; i = i + 2)
+		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
+	return true;
+}
+
+static bool _rtl92ee_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
+						   u8 configtype)
+{
+	#define READ_NEXT_PAIR(v1, v2, i) \
+		do { \
+			i += 2; \
+			v1 = array[i]; \
+			v2 = array[i+1]; \
+		} while (0)
+
+	int i;
+	u32 *array;
+	u16 len;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 v1 = 0, v2 = 0;
+
+	if (configtype == BASEBAND_CONFIG_PHY_REG) {
+		len = RTL8192EE_PHY_REG_ARRAY_LEN;
+		array = RTL8192EE_PHY_REG_ARRAY;
+
+		for (i = 0; i < len; i = i + 2) {
+			v1 = array[i];
+			v2 = array[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl92ee_config_bb_reg(hw, v1, v2);
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= len - 2)
+					break;
+
+				if (!_check_condition(hw , array[i])) {
+					/*Discard the following pairs*/
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2)
+					    READ_NEXT_PAIR(v1, v2, i);
+					i -= 2; /* prevent from for-loop += 2*/
+				} else{/* Configure matched pairs and
+				       * skip to end of if-else. */
+					READ_NEXT_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2) {
+						_rtl92ee_config_bb_reg(hw, v1,
+								       v2);
+						READ_NEXT_PAIR(v1, v2, i);
+					}
+
+					while (v2 != 0xDEAD && i < len - 2)
+						READ_NEXT_PAIR(v1, v2, i);
+				}
+			}
+		}
+	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
+			len = RTL8192EE_AGC_TAB_ARRAY_LEN;
+			array = RTL8192EE_AGC_TAB_ARRAY;
+
+			for (i = 0; i < len; i = i + 2) {
+				v1 = array[i];
+				v2 = array[i+1];
+				if (v1 < 0xCDCDCDCD) {
+					rtl_set_bbreg(hw, array[i], MASKDWORD,
+						      array[i + 1]);
+					udelay(1);
+					continue;
+			    } else{/*This line is the start line of branch.*/
+				  /* to protect READ_NEXT_PAIR not overrun */
+					if (i >= len - 2)
+						break;
+
+					if (!_check_condition(hw , array[i])) {
+						/*Discard the following pairs*/
+						READ_NEXT_PAIR(v1, v2, i);
+						while (v2 != 0xDEAD &&
+						       v2 != 0xCDEF &&
+						       v2 != 0xCDCD &&
+						       i < len - 2)
+						    READ_NEXT_PAIR(v1, v2, i);
+						i -= 2; /* prevent from for-loop += 2*/
+					} else {/* Configure matched pairs and
+					       * skip to end of if-else.*/
+						READ_NEXT_PAIR(v1, v2, i);
+						while (v2 != 0xDEAD &&
+						       v2 != 0xCDEF &&
+						       v2 != 0xCDCD &&
+						       i < len - 2) {
+							rtl_set_bbreg(hw,
+								      array[i],
+								      MASKDWORD,
+								      array[i + 1]);
+							udelay(1);
+							READ_NEXT_PAIR(v1 , v2 , i);
+						}
+
+						while (v2 != 0xDEAD &&
+						       i < len - 2)
+							READ_NEXT_PAIR(v1 , v2 , i);
+					}
+				}
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("The agctab_array_table[0] is %x Rtl818EEPHY_REGArray[1] is %x\n",
+					  array[i],
+					  array[i + 1]));
+		}
+	}
+	return true;
+}
+
+static u8 _rtl92ee_get_rate_section_index(u32 regaddr)
+{
+	u8 index = 0;
+
+	switch (regaddr) {
+	case RTXAGC_A_RATE18_06:
+		index = 0;
+		break;
+	case RTXAGC_A_RATE54_24:
+		index = 1;
+		break;
+	case RTXAGC_A_CCK1_MCS32:
+		index = 2;
+		break;
+	case RTXAGC_B_CCK11_A_CCK2_11:
+		index = 3;
+		break;
+	case RTXAGC_A_MCS03_MCS00:
+		index = 4;
+		break;
+	case RTXAGC_A_MCS07_MCS04:
+		index = 5;
+		break;
+	case RTXAGC_A_MCS11_MCS08:
+		index = 6;
+		break;
+	case RTXAGC_A_MCS15_MCS12:
+		index = 7;
+		break;
+	case RTXAGC_B_RATE18_06:
+		index = 0;
+		break;
+	case RTXAGC_B_RATE54_24:
+		index = 1;
+		break;
+	case RTXAGC_B_CCK1_55_MCS32:
+		index = 2;
+		break;
+	case RTXAGC_B_MCS03_MCS00:
+		index = 4;
+		break;
+	case RTXAGC_B_MCS07_MCS04:
+		index = 5;
+		break;
+	case RTXAGC_B_MCS11_MCS08:
+		index = 6;
+		break;
+	case RTXAGC_B_MCS15_MCS12:
+		index = 7;
+		break;
+	default:
+		regaddr &= 0xFFF;
+		if (regaddr >= 0xC20 && regaddr <= 0xC4C)
+			index = (u8) ((regaddr - 0xC20) / 4);
+		else if (regaddr >= 0xE20 && regaddr <= 0xE4C)
+			index = (u8) ((regaddr - 0xE20) / 4);
+		break;
+	};
+	return index;
+}
+
+static void _rtl92ee_store_tx_power_by_rate(struct ieee80211_hw *hw,
+					    enum band_type band,
+					    enum radio_path rfpath,
+					    u32 txnum, u32 regaddr,
+					    u32 bitmask, u32 data)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 section = _rtl92ee_get_rate_section_index(regaddr);
+
+	if (band != BAND_ON_2_4G && band != BAND_ON_5G) {
+		RT_TRACE(FPHY, PHY_TXPWR, ("Invalid Band %d\n", band));
+		return;
+	}
+
+	if (rfpath > MAX_RF_PATH - 1) {
+		RT_TRACE(FPHY, PHY_TXPWR, ("Invalid RfPath %d\n", rfpath));
+		return;
+	}
+	if (txnum > MAX_RF_PATH - 1) {
+		RT_TRACE(FPHY, PHY_TXPWR, ("Invalid TxNum %d\n", txnum));
+		return;
+	}
+
+	rtlphy->tx_power_by_rate_offset[band][rfpath][txnum][section] = data;
+}
+
+static bool _rtl92ee_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
+						     u8 configtype)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	int i;
+	u32 *phy_regarray_table_pg;
+	u16 phy_regarray_pg_len;
+	u32 v1 = 0, v2 = 0, v3 = 0, v4 = 0, v5 = 0, v6 = 0;
+
+	phy_regarray_pg_len = RTL8192EE_PHY_REG_ARRAY_PG_LEN;
+	phy_regarray_table_pg = RTL8192EE_PHY_REG_ARRAY_PG;
+
+	if (configtype == BASEBAND_CONFIG_PHY_REG) {
+		for (i = 0; i < phy_regarray_pg_len; i = i + 6) {
+			v1 = phy_regarray_table_pg[i];
+			v2 = phy_regarray_table_pg[i+1];
+			v3 = phy_regarray_table_pg[i+2];
+			v4 = phy_regarray_table_pg[i+3];
+			v5 = phy_regarray_table_pg[i+4];
+			v6 = phy_regarray_table_pg[i+5];
+
+			if (v1 < 0xcdcdcdcd) {
+				_rtl92ee_store_tx_power_by_rate(hw, v1, v2, v3,
+								v4, v5, v6);
+				continue;
+			}
+		}
+	} else {
+		RT_TRACE(COMP_SEND, DBG_TRACE,
+			 ("configtype != BaseBand_Config_PHY_REG\n"));
+	}
+	return true;
+}
+
+bool rtl92ee_phy_config_rf_with_headerfile(struct ieee80211_hw  *hw,
+					   enum radio_path rfpath)
+{
+	#define READ_NEXT_RF_PAIR(v1, v2, i) \
+		do { \
+			i += 2; \
+			v1 = array[i]; \
+			v2 = array[i+1]; \
+		} while (0)
+
+	int i;
+	u32 *array;
+	u16 len;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 v1 = 0, v2 = 0;
+
+	switch (rfpath) {
+	case RF90_PATH_A:
+		len = RTL8192EE_RADIOA_ARRAY_LEN;
+		array = RTL8192EE_RADIOA_ARRAY;
+		RT_TRACE(COMP_INIT, DBG_LOUD,
+			 ("Radio_A:RTL8192EE_RADIOA_ARRAY %d\n" , len));
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Radio No %x\n", rfpath));
+		for (i = 0; i < len; i = i + 2) {
+			v1 = array[i];
+			v2 = array[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl92ee_config_rf_radio_a(hw, v1, v2);
+				continue;
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= len - 2)
+					break;
+
+				if (!_check_condition(hw , array[i])) {
+					/*Discard the following pairs*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+					i -= 2; /* prevent from for-loop += 2*/
+				} else {/* Configure matched pairs and
+					 * skip to end of if-else.*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2) {
+						_rtl92ee_config_rf_radio_a(hw,
+									   v1,
+									   v2);
+						READ_NEXT_RF_PAIR(v1, v2, i);
+					}
+
+					while (v2 != 0xDEAD && i < len - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+				}
+			}
+		}
+		break;
+
+	case RF90_PATH_B:
+		len = RTL8192EE_RADIOB_ARRAY_LEN;
+		array = RTL8192EE_RADIOB_ARRAY;
+		RT_TRACE(COMP_INIT, DBG_LOUD,
+			 ("Radio_A:RTL8192EE_RADIOB_ARRAY %d\n" , len));
+		RT_TRACE(COMP_INIT, DBG_LOUD, ("Radio No %x\n", rfpath));
+		for (i = 0; i < len; i = i + 2) {
+			v1 = array[i];
+			v2 = array[i+1];
+			if (v1 < 0xcdcdcdcd) {
+				_rtl92ee_config_rf_radio_b(hw, v1, v2);
+				continue;
+			} else {/*This line is the start line of branch.*/
+				/* to protect READ_NEXT_PAIR not overrun */
+				if (i >= len - 2)
+					break;
+
+				if (!_check_condition(hw , array[i])) {
+					/*Discard the following pairs*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+					i -= 2; /* prevent from for-loop += 2*/
+				} else {/* Configure matched pairs and
+					 * skip to end of if-else.*/
+					READ_NEXT_RF_PAIR(v1, v2, i);
+					while (v2 != 0xDEAD &&
+					       v2 != 0xCDEF &&
+					       v2 != 0xCDCD && i < len - 2) {
+						_rtl92ee_config_rf_radio_b(hw,
+									   v1,
+									   v2);
+						READ_NEXT_RF_PAIR(v1, v2, i);
+					}
+
+					while (v2 != 0xDEAD && i < len - 2)
+						READ_NEXT_RF_PAIR(v1, v2, i);
+				}
+			}
+		}
+		break;
+	case RF90_PATH_C:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("switch case not process\n"));
+		break;
+	case RF90_PATH_D:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("switch case not process\n"));
+		break;
+	}
+	return true;
+}
+
+void rtl92ee_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	rtlphy->default_initialgain[0] =
+		(u8) rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[1] =
+		(u8) rtl_get_bbreg(hw, ROFDM0_XBAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[2] =
+		(u8) rtl_get_bbreg(hw, ROFDM0_XCAGCCORE1, MASKBYTE0);
+	rtlphy->default_initialgain[3] =
+		(u8) rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
+
+	RT_TRACE(COMP_INIT, DBG_TRACE,
+		 ("Default initial gain (c50 = 0x%x, c58 = 0x%x, c60 = 0x%x, c68 = 0x%x\n",
+		  rtlphy->default_initialgain[0],
+		  rtlphy->default_initialgain[1],
+		  rtlphy->default_initialgain[2],
+		  rtlphy->default_initialgain[3]));
+
+	rtlphy->framesync = (u8) rtl_get_bbreg(hw,
+					       ROFDM0_RXDETECTOR3, MASKBYTE0);
+	rtlphy->framesync_c34 = rtl_get_bbreg(hw,
+					      ROFDM0_RXDETECTOR2, MASKDWORD);
+
+	RT_TRACE(COMP_INIT, DBG_TRACE,
+		 ("Default framesync (0x%x) = 0x%x\n",
+		  ROFDM0_RXDETECTOR3, rtlphy->framesync));
+}
+
+static void _rtl92ee_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfs = RFPGA0_XAB_RFINTERFACESW;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfs = RFPGA0_XAB_RFINTERFACESW;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfo = RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfo = RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfintfe = RFPGA0_XA_RFINTERFACEOE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfintfe = RFPGA0_XB_RFINTERFACEOE;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf3wire_offset =
+							RFPGA0_XA_LSSIPARAMETER;
+	rtlphy->phyreg_def[RF90_PATH_B].rf3wire_offset =
+							RFPGA0_XB_LSSIPARAMETER;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rfhssi_para2 = RFPGA0_XA_HSSIPARAMETER2;
+	rtlphy->phyreg_def[RF90_PATH_B].rfhssi_para2 = RFPGA0_XB_HSSIPARAMETER2;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readback =
+							 RFPGA0_XA_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readback =
+							 RFPGA0_XB_LSSIREADBACK;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readbackpi =
+						      TRANSCEIVEA_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readbackpi =
+						      TRANSCEIVEB_HSPI_READBACK;
+}
+
+void rtl92ee_phy_get_txpower_level(struct ieee80211_hw *hw, long *powerlevel)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 txpwr_level;
+	long txpwr_dbm;
+
+	txpwr_level = rtlphy->cur_cck_txpwridx;
+	txpwr_dbm = _rtl92ee_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_B,
+						  txpwr_level);
+	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl92ee_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G, txpwr_level) >
+	    txpwr_dbm)
+		txpwr_dbm = _rtl92ee_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_G,
+							  txpwr_level);
+	txpwr_level = rtlphy->cur_ofdm24g_txpwridx;
+	if (_rtl92ee_phy_txpwr_idx_to_dbm(hw, WIRELESS_MODE_N_24G,
+					  txpwr_level) > txpwr_dbm)
+		txpwr_dbm = _rtl92ee_phy_txpwr_idx_to_dbm(hw,
+							  WIRELESS_MODE_N_24G,
+							  txpwr_level);
+	*powerlevel = txpwr_dbm;
+}
+
+static u8 _rtl92ee_phy_get_ratesection_intxpower_byrate(enum radio_path path,
+							u8 rate)
+{
+	u8 rate_section = 0;
+
+	switch (rate) {
+	case DESC92C_RATE1M:
+		rate_section = 2;
+		break;
+
+	case DESC92C_RATE2M:
+	case DESC92C_RATE5_5M:
+		if (path == RF90_PATH_A)
+			rate_section = 3;
+		else if (path == RF90_PATH_B)
+			rate_section = 2;
+		break;
+
+	case DESC92C_RATE11M:
+		rate_section = 3;
+		break;
+
+	case DESC92C_RATE6M:
+	case DESC92C_RATE9M:
+	case DESC92C_RATE12M:
+	case DESC92C_RATE18M:
+		rate_section = 0;
+		break;
+
+	case DESC92C_RATE24M:
+	case DESC92C_RATE36M:
+	case DESC92C_RATE48M:
+	case DESC92C_RATE54M:
+		rate_section = 1;
+		break;
+
+	case DESC92C_RATEMCS0:
+	case DESC92C_RATEMCS1:
+	case DESC92C_RATEMCS2:
+	case DESC92C_RATEMCS3:
+		rate_section = 4;
+		break;
+
+	case DESC92C_RATEMCS4:
+	case DESC92C_RATEMCS5:
+	case DESC92C_RATEMCS6:
+	case DESC92C_RATEMCS7:
+		rate_section = 5;
+		break;
+
+	case DESC92C_RATEMCS8:
+	case DESC92C_RATEMCS9:
+	case DESC92C_RATEMCS10:
+	case DESC92C_RATEMCS11:
+		rate_section = 6;
+		break;
+
+	case DESC92C_RATEMCS12:
+	case DESC92C_RATEMCS13:
+	case DESC92C_RATEMCS14:
+	case DESC92C_RATEMCS15:
+		rate_section = 7;
+		break;
+
+	default:
+		RT_ASSERT(true, ("Rate_Section is Illegal\n"));
+		break;
+	}
+
+	return rate_section;
+}
+
+static u8 _rtl92ee_get_txpower_by_rate(struct ieee80211_hw *hw,
+				       enum band_type band,
+				       enum radio_path rf, u8 rate)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u8 shift = 0, sec, tx_num;
+	char diff = 0;
+
+	sec = _rtl92ee_phy_get_ratesection_intxpower_byrate(rf, rate);
+	tx_num = RF_TX_NUM_NONIMPLEMENT;
+
+	if (tx_num == RF_TX_NUM_NONIMPLEMENT) {
+		if ((rate >= DESC92C_RATEMCS8 && rate <= DESC92C_RATEMCS15))
+			tx_num = RF_2TX;
+		else
+			tx_num = RF_1TX;
+	}
+
+	switch (rate) {
+	case DESC92C_RATE1M:
+		shift = 0;
+		break;
+	case DESC92C_RATE2M:
+		shift = 8;
+		break;
+	case DESC92C_RATE5_5M:
+		shift = 16;
+		break;
+	case DESC92C_RATE11M:
+		shift = 24;
+		break;
+
+	case DESC92C_RATE6M:
+		shift = 0;
+		break;
+	case DESC92C_RATE9M:
+		shift = 8;
+		break;
+	case DESC92C_RATE12M:
+		shift = 16;
+		break;
+	case DESC92C_RATE18M:
+		shift = 24;
+		break;
+
+	case DESC92C_RATE24M:
+		shift = 0;
+		break;
+	case DESC92C_RATE36M:
+		shift = 8;
+		break;
+	case DESC92C_RATE48M:
+		shift = 16;
+		break;
+	case DESC92C_RATE54M:
+		shift = 24;
+		break;
+
+	case DESC92C_RATEMCS0:
+		shift = 0;
+		break;
+	case DESC92C_RATEMCS1:
+		shift = 8;
+		break;
+	case DESC92C_RATEMCS2:
+		shift = 16;
+		break;
+	case DESC92C_RATEMCS3:
+		shift = 24;
+		break;
+
+	case DESC92C_RATEMCS4:
+		shift = 0;
+		break;
+	case DESC92C_RATEMCS5:
+		shift = 8;
+		break;
+	case DESC92C_RATEMCS6:
+		shift = 16;
+		break;
+	case DESC92C_RATEMCS7:
+		shift = 24;
+		break;
+
+	case DESC92C_RATEMCS8:
+		shift = 0;
+		break;
+	case DESC92C_RATEMCS9:
+		shift = 8;
+		break;
+	case DESC92C_RATEMCS10:
+		shift = 16;
+		break;
+	case DESC92C_RATEMCS11:
+		shift = 24;
+		break;
+
+	case DESC92C_RATEMCS12:
+		shift = 0;
+		break;
+	case DESC92C_RATEMCS13:
+		shift = 8;
+		break;
+	case DESC92C_RATEMCS14:
+		shift = 16;
+		break;
+	case DESC92C_RATEMCS15:
+		shift = 24;
+		break;
+
+	default:
+		RT_ASSERT(true, ("Rate_Section is Illegal\n"));
+		break;
+	}
+
+	diff = (u8) (rtlphy->tx_power_by_rate_offset[band][rf][tx_num][sec] >>
+		     shift) & 0xff;
+
+	return	diff;
+}
+
+static u8 _rtl92ee_get_txpower_index(struct ieee80211_hw *hw,
+				     enum radio_path rfpath, u8 rate,
+				     u8 bw, u8 channel)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtlpriv);
+	u8 index = (channel - 1);
+	u8 tx_power = 0;
+	u8 diff = 0;
+
+	if (channel < 1 || channel > 14) {
+		index = 0;
+		RT_TRACE(COMP_POWER_TRACKING, DBG_DMESG,
+			 ("Illegal channel!!\n"));
+	}
+
+	if (IS_CCK_RATE(rate))
+		tx_power = rtlefuse->txpwrlevel_cck[rfpath][index];
+	else if (DESC92C_RATE6M <= rate)
+		tx_power = rtlefuse->txpwrlevel_ht40_1s[rfpath][index];
+
+	/* OFDM-1T*/
+	if (DESC92C_RATE6M <= rate && rate <= DESC92C_RATE54M &&
+	    !IS_CCK_RATE(rate))
+		tx_power += rtlefuse->txpwr_legacyhtdiff[rfpath][TX_1S];
+
+	/* BW20-1S, BW20-2S */
+	if (bw == HT_CHANNEL_WIDTH_20) {
+		if (DESC92C_RATEMCS0 <= rate && rate <= DESC92C_RATEMCS15)
+			tx_power += rtlefuse->txpwr_ht20diff[rfpath][TX_1S];
+		if (DESC92C_RATEMCS8 <= rate && rate <= DESC92C_RATEMCS15)
+			tx_power += rtlefuse->txpwr_ht20diff[rfpath][TX_2S];
+	} else if (bw == HT_CHANNEL_WIDTH_20_40) {/* BW40-1S, BW40-2S */
+		if (DESC92C_RATEMCS0 <= rate && rate <= DESC92C_RATEMCS15)
+			tx_power += rtlefuse->txpwr_ht40diff[rfpath][TX_1S];
+		if (DESC92C_RATEMCS8 <= rate && rate <= DESC92C_RATEMCS15)
+			tx_power += rtlefuse->txpwr_ht40diff[rfpath][TX_2S];
+	}
+
+	if (rtlefuse->eeprom_regulatory != 2)
+		diff = _rtl92ee_get_txpower_by_rate(hw, BAND_ON_2_4G,
+						    rfpath, rate);
+
+	tx_power += diff;
+
+	if (tx_power > MAX_POWER_INDEX)
+		tx_power = MAX_POWER_INDEX;
+
+	return tx_power;
+}
+
+static void _rtl92ee_set_txpower_index(struct ieee80211_hw *hw, u8 pwr_idx,
+				       enum radio_path rfpath, u8 rate)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rfpath == RF90_PATH_A) {
+		switch (rate) {
+		case DESC92C_RATE1M:
+			rtl_set_bbreg(hw, RTXAGC_A_CCK1_MCS32,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE2M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE5_5M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE11M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATE6M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE18_06,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATE9M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE18_06,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE12M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE18_06,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE18M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE18_06,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATE24M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE54_24,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATE36M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE54_24,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE48M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE54_24,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE54M:
+			rtl_set_bbreg(hw, RTXAGC_A_RATE54_24,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS0:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS1:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS2:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS3:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS03_MCS00,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS4:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS5:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS6:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS7:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS07_MCS04,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS8:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS9:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS10:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS11:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS11_MCS08,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS12:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS13:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS14:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS15:
+			rtl_set_bbreg(hw, RTXAGC_A_MCS15_MCS12,
+				      MASKBYTE3, pwr_idx);
+			break;
+		default:
+			RT_TRACE(COMP_POWER, DBG_LOUD, ("Invalid Rate!!\n"));
+			break;
+		}
+	} else if (rfpath == RF90_PATH_B) {
+		switch (rate) {
+		case DESC92C_RATE1M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE2M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE5_5M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK1_55_MCS32,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATE11M:
+			rtl_set_bbreg(hw, RTXAGC_B_CCK11_A_CCK2_11,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATE6M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE18_06,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATE9M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE18_06,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE12M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE18_06,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE18M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE18_06,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATE24M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE54_24,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATE36M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE54_24,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATE48M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE54_24,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATE54M:
+			rtl_set_bbreg(hw, RTXAGC_B_RATE54_24,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS0:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS1:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS2:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS3:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS03_MCS00,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS4:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS5:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS6:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS7:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS07_MCS04,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS8:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS9:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS10:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS11:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS11_MCS08,
+				      MASKBYTE3, pwr_idx);
+			break;
+		case DESC92C_RATEMCS12:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE0, pwr_idx);
+			break;
+		case DESC92C_RATEMCS13:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE1, pwr_idx);
+			break;
+		case DESC92C_RATEMCS14:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE2, pwr_idx);
+			break;
+		case DESC92C_RATEMCS15:
+			rtl_set_bbreg(hw, RTXAGC_B_MCS15_MCS12,
+				      MASKBYTE3, pwr_idx);
+			break;
+		default:
+			RT_TRACE(COMP_POWER, DBG_LOUD, ("Invalid Rate!!\n"));
+			break;
+		}
+	} else {
+		RT_TRACE(COMP_POWER, DBG_LOUD, ("Invalid RFPath!!\n"));
+	}
+}
+
+static void rtl92ee_phy_set_txpower_index_by_rate_array(struct ieee80211_hw *hw,
+							enum radio_path rfpath, u8 bw,
+							u8 channel, u8 *rates, u8 size)
+{
+	u8 i;
+	u8 power_index;
+	for (i = 0; i < size; i++) {
+		power_index = _rtl92ee_get_txpower_index(hw, rfpath, rates[i],
+							 bw, channel);
+		_rtl92ee_set_txpower_index(hw, power_index, rfpath, rates[i]);
+	}
+}
+
+static void rtl92ee_phy_set_txpower_index_by_rate_section(struct ieee80211_hw *hw,
+							  enum radio_path rfpath,
+							  u8 channel,
+							  enum rate_section section)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	if (section == CCK) {
+		u8 cck_rates[] = {DESC92C_RATE1M, DESC92C_RATE2M,
+				  DESC92C_RATE5_5M, DESC92C_RATE11M};
+		if (rtlhal->current_bandtype == BAND_ON_2_4G)
+			rtl92ee_phy_set_txpower_index_by_rate_array(hw, rfpath,
+							rtlphy->current_chan_bw,
+							channel, cck_rates, 4);
+	} else if (section == OFDM) {
+		u8 ofdm_rates[] = {DESC92C_RATE6M, DESC92C_RATE9M,
+				   DESC92C_RATE12M, DESC92C_RATE18M,
+				   DESC92C_RATE24M, DESC92C_RATE36M,
+				   DESC92C_RATE48M, DESC92C_RATE54M};
+		rtl92ee_phy_set_txpower_index_by_rate_array(hw, rfpath,
+							rtlphy->current_chan_bw,
+							channel, ofdm_rates, 8);
+	} else if (section == HT_MCS0_MCS7) {
+		u8 ht_rates1t[]  = {DESC92C_RATEMCS0, DESC92C_RATEMCS1,
+				    DESC92C_RATEMCS2, DESC92C_RATEMCS3,
+				    DESC92C_RATEMCS4, DESC92C_RATEMCS5,
+				    DESC92C_RATEMCS6, DESC92C_RATEMCS7};
+		rtl92ee_phy_set_txpower_index_by_rate_array(hw, rfpath,
+							rtlphy->current_chan_bw,
+							channel, ht_rates1t, 8);
+	} else if (section == HT_MCS8_MCS15) {
+		u8 ht_rates2t[]  = {DESC92C_RATEMCS8, DESC92C_RATEMCS9,
+				    DESC92C_RATEMCS10, DESC92C_RATEMCS11,
+				    DESC92C_RATEMCS12, DESC92C_RATEMCS13,
+				    DESC92C_RATEMCS14, DESC92C_RATEMCS15};
+		rtl92ee_phy_set_txpower_index_by_rate_array(hw, rfpath,
+							rtlphy->current_chan_bw,
+							channel, ht_rates2t, 8);
+	} else
+		RT_TRACE(FPHY, PHY_TXPWR,
+			 ("Invalid RateSection %d\n", section));
+}
+
+void rtl92ee_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel)
+{
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct rtl_phy *rtlphy = &(rtl_priv(hw)->phy);
+	enum radio_path rfpath;
+
+	if (rtlefuse->b_txpwr_fromeprom == false)
+		return;
+	for (rfpath = RF90_PATH_A; rfpath < rtlphy->num_total_rfpath;
+	     rfpath++) {
+		rtl92ee_phy_set_txpower_index_by_rate_section(hw, rfpath,
+							      channel, CCK);
+		rtl92ee_phy_set_txpower_index_by_rate_section(hw, rfpath,
+							      channel, OFDM);
+		rtl92ee_phy_set_txpower_index_by_rate_section(hw, rfpath,
+							      channel,
+							      HT_MCS0_MCS7);
+		if (rtlphy->num_total_rfpath >= 2)
+			rtl92ee_phy_set_txpower_index_by_rate_section(hw,
+								rfpath, channel,
+								HT_MCS8_MCS15);
+	}
+}
+
+static long _rtl92ee_phy_txpwr_idx_to_dbm(struct ieee80211_hw *hw,
+					  enum wireless_mode wirelessmode,
+					  u8 txpwridx)
+{
+	long offset;
+	long pwrout_dbm;
+
+	switch (wirelessmode) {
+	case WIRELESS_MODE_B:
+		offset = -7;
+		break;
+	case WIRELESS_MODE_G:
+	case WIRELESS_MODE_N_24G:
+		offset = -8;
+		break;
+	default:
+		offset = -8;
+		break;
+	}
+	pwrout_dbm = txpwridx / 2 + offset;
+	return pwrout_dbm;
+}
+
+void rtl92ee_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	enum io_type iotype;
+
+	if (!is_hal_stop(rtlhal)) {
+		switch (operation) {
+		case SCAN_OPT_BACKUP_BAND0:
+			iotype = IO_CMD_PAUSE_BAND0_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+
+			break;
+		case SCAN_OPT_RESTORE:
+			iotype = IO_CMD_RESUME_DM_BY_SCAN;
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_IO_CMD,
+						      (u8 *)&iotype);
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("Unknown Scan Backup operation.\n"));
+			break;
+		}
+	}
+}
+
+void rtl92ee_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	u8 reg_bw_opmode;
+	u8 reg_prsr_rsc;
+
+	RT_TRACE(COMP_SCAN, DBG_TRACE,
+		 ("Switch to %s bandwidth\n",
+		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		  "20MHz" : "40MHz"));
+
+	if (is_hal_stop(rtlhal)) {
+		rtlphy->set_bwmode_inprogress = false;
+		return;
+	}
+
+	reg_bw_opmode = rtl_read_byte(rtlpriv, REG_BWOPMODE);
+	reg_prsr_rsc = rtl_read_byte(rtlpriv, REG_RRSR + 2);
+
+	switch (rtlphy->current_chan_bw) {
+	case HT_CHANNEL_WIDTH_20:
+		reg_bw_opmode |= BW_OPMODE_20MHZ;
+		rtl_write_byte(rtlpriv, REG_BWOPMODE, reg_bw_opmode);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		reg_bw_opmode &= ~BW_OPMODE_20MHZ;
+		rtl_write_byte(rtlpriv, REG_BWOPMODE, reg_bw_opmode);
+		reg_prsr_rsc = (reg_prsr_rsc & 0x90) |
+			       (mac->cur_40_prime_sc << 5);
+		rtl_write_byte(rtlpriv, REG_RRSR + 2, reg_prsr_rsc);
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+		break;
+	}
+
+	switch (rtlphy->current_chan_bw) {
+	case HT_CHANNEL_WIDTH_20:
+		rtl_set_bbreg(hw, RFPGA0_RFMOD, BRFMOD, 0x0);
+		rtl_set_bbreg(hw, RFPGA1_RFMOD, BRFMOD, 0x0);
+		rtl_set_bbreg(hw, ROFDM0_TXPSEUDONOISEWGT,
+			      (BIT(31) | BIT(30)), 0);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		rtl_set_bbreg(hw, RFPGA0_RFMOD, BRFMOD, 0x1);
+		rtl_set_bbreg(hw, RFPGA1_RFMOD, BRFMOD, 0x1);
+		rtl_set_bbreg(hw, RCCK0_SYSTEM, BCCK_SIDEBAND,
+			      (mac->cur_40_prime_sc >> 1));
+		rtl_set_bbreg(hw, ROFDM1_LSTF, 0xC00,
+			      mac->cur_40_prime_sc);
+
+		rtl_set_bbreg(hw, 0x818, (BIT(26) | BIT(27)),
+			      (mac->cur_40_prime_sc ==
+			       HAL_PRIME_CHNL_OFFSET_LOWER) ? 2 : 1);
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+		break;
+	}
+	rtl92ee_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
+	rtlphy->set_bwmode_inprogress = false;
+	RT_TRACE(COMP_SCAN, DBG_LOUD, ("\n"));
+}
+
+void rtl92ee_phy_set_bw_mode(struct ieee80211_hw *hw,
+			     enum nl80211_channel_type ch_type)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	u8 tmp_bw = rtlphy->current_chan_bw;
+
+	if (rtlphy->set_bwmode_inprogress)
+		return;
+	rtlphy->set_bwmode_inprogress = true;
+	if ((!is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
+		rtl92ee_phy_set_bw_mode_callback(hw);
+	} else {
+		RT_TRACE(COMP_ERR, DBG_WARNING,
+			 ("false driver sleep or unload\n"));
+		rtlphy->set_bwmode_inprogress = false;
+		rtlphy->current_chan_bw = tmp_bw;
+	}
+}
+
+void rtl92ee_phy_sw_chnl_callback(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u32 delay;
+
+	RT_TRACE(COMP_SCAN, DBG_TRACE,
+		 ("switch to channel%d\n", rtlphy->current_channel));
+	if (is_hal_stop(rtlhal))
+		return;
+	do {
+		if (!rtlphy->sw_chnl_inprogress)
+			break;
+		if (!_rtl92ee_phy_sw_chnl_step_by_step
+		    (hw, rtlphy->current_channel, &rtlphy->sw_chnl_stage,
+		     &rtlphy->sw_chnl_step, &delay)) {
+			if (delay > 0)
+				mdelay(delay);
+			else
+				continue;
+		} else {
+			rtlphy->sw_chnl_inprogress = false;
+		}
+		break;
+	} while (true);
+	RT_TRACE(COMP_SCAN, DBG_TRACE, ("\n"));
+}
+
+u8 rtl92ee_phy_sw_chnl(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+
+	if (rtlphy->sw_chnl_inprogress)
+		return 0;
+	if (rtlphy->set_bwmode_inprogress)
+		return 0;
+	RT_ASSERT((rtlphy->current_channel <= 14),
+		  ("WIRELESS_MODE_G but channel>14"));
+	rtlphy->sw_chnl_inprogress = true;
+	rtlphy->sw_chnl_stage = 0;
+	rtlphy->sw_chnl_step = 0;
+	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
+		rtl92ee_phy_sw_chnl_callback(hw);
+		RT_TRACE(COMP_CHAN, DBG_LOUD,
+			 ("sw_chnl_inprogress false schdule workitem current channel %d\n",
+			 rtlphy->current_channel));
+		rtlphy->sw_chnl_inprogress = false;
+	} else {
+		RT_TRACE(COMP_CHAN, DBG_LOUD,
+			 ("sw_chnl_inprogress false driver sleep or unload\n"));
+		rtlphy->sw_chnl_inprogress = false;
+	}
+	return 1;
+}
+
+static bool _rtl92ee_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
+					      u8 channel, u8 *stage, u8 *step,
+					      u32 *delay)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct swchnlcmd precommoncmd[MAX_PRECMD_CNT];
+	u32 precommoncmdcnt;
+	struct swchnlcmd postcommoncmd[MAX_POSTCMD_CNT];
+	u32 postcommoncmdcnt;
+	struct swchnlcmd rfdependcmd[MAX_RFDEPENDCMD_CNT];
+	u32 rfdependcmdcnt;
+	struct swchnlcmd *currentcmd = NULL;
+	u8 rfpath;
+	u8 num_total_rfpath = rtlphy->num_total_rfpath;
+
+	precommoncmdcnt = 0;
+	_rtl92ee_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
+					  MAX_PRECMD_CNT,
+					  CMDID_SET_TXPOWEROWER_LEVEL, 0, 0, 0);
+	_rtl92ee_phy_set_sw_chnl_cmdarray(precommoncmd, precommoncmdcnt++,
+					  MAX_PRECMD_CNT, CMDID_END, 0, 0, 0);
+
+	postcommoncmdcnt = 0;
+
+	_rtl92ee_phy_set_sw_chnl_cmdarray(postcommoncmd, postcommoncmdcnt++,
+					  MAX_POSTCMD_CNT, CMDID_END, 0, 0, 0);
+
+	rfdependcmdcnt = 0;
+
+	RT_ASSERT((channel >= 1 && channel <= 14),
+		  ("illegal channel for Zebra: %d\n", channel));
+
+	_rtl92ee_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
+					  MAX_RFDEPENDCMD_CNT,
+					  CMDID_RF_WRITEREG,
+					  RF_CHNLBW, channel, 10);
+
+	_rtl92ee_phy_set_sw_chnl_cmdarray(rfdependcmd, rfdependcmdcnt++,
+					  MAX_RFDEPENDCMD_CNT, CMDID_END,
+					  0, 0, 0);
+
+	do {
+		switch (*stage) {
+		case 0:
+			currentcmd = &precommoncmd[*step];
+			break;
+		case 1:
+			currentcmd = &rfdependcmd[*step];
+			break;
+		case 2:
+			currentcmd = &postcommoncmd[*step];
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("Invalid 'stage' = %d, Check it!\n" ,
+				  *stage));
+			return true;
+			break;
+		}
+
+		if (currentcmd->cmdid == CMDID_END) {
+			if ((*stage) == 2) {
+				return true;
+			} else {
+				(*stage)++;
+				(*step) = 0;
+				continue;
+			}
+		}
+
+		switch (currentcmd->cmdid) {
+		case CMDID_SET_TXPOWEROWER_LEVEL:
+			rtl92ee_phy_set_txpower_level(hw, channel);
+			break;
+		case CMDID_WRITEPORT_ULONG:
+			rtl_write_dword(rtlpriv, currentcmd->para1,
+					currentcmd->para2);
+			break;
+		case CMDID_WRITEPORT_USHORT:
+			rtl_write_word(rtlpriv, currentcmd->para1,
+				       (u16) currentcmd->para2);
+			break;
+		case CMDID_WRITEPORT_UCHAR:
+			rtl_write_byte(rtlpriv, currentcmd->para1,
+				       (u8) currentcmd->para2);
+			break;
+		case CMDID_RF_WRITEREG:
+			for (rfpath = 0; rfpath < num_total_rfpath; rfpath++) {
+				rtlphy->rfreg_chnlval[rfpath] =
+					((rtlphy->rfreg_chnlval[rfpath] &
+					  0xfffff00) | currentcmd->para2);
+
+				rtl_set_rfreg(hw, (enum radio_path)rfpath,
+					      currentcmd->para1,
+					      0x3ff,
+					      rtlphy->rfreg_chnlval[rfpath]);
+			}
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("switch case not process\n"));
+			break;
+		}
+
+		break;
+	} while (true);
+
+	(*delay) = currentcmd->msdelay;
+	(*step)++;
+	return false;
+}
+
+static bool _rtl92ee_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
+					      u32 cmdtableidx, u32 cmdtablesz,
+					      enum swchnlcmd_id cmdid,
+					      u32 para1, u32 para2, u32 msdelay)
+{
+	struct swchnlcmd *pcmd;
+
+	if (cmdtable == NULL) {
+		RT_ASSERT(false, ("cmdtable cannot be NULL.\n"));
+		return false;
+	}
+
+	if (cmdtableidx >= cmdtablesz)
+		return false;
+
+	pcmd = cmdtable + cmdtableidx;
+	pcmd->cmdid = cmdid;
+	pcmd->para1 = para1;
+	pcmd->para2 = para2;
+	pcmd->msdelay = msdelay;
+	return true;
+}
+
+static u8 _rtl92ee_phy_path_a_iqk(struct ieee80211_hw *hw, bool config_pathb)
+{
+	u32 reg_eac, reg_e94, reg_e9c;
+	u8 result = 0x00;
+	/* path-A IQK setting */
+	/* PA/PAD controlled by 0x0 */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x180);
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_A, MASKDWORD, 0x82140303);
+	rtl_set_bbreg(hw, RRx_IQK_PI_A, MASKDWORD, 0x68160000);
+
+	/*LO calibration setting*/
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x00462911);
+
+	/*One shot, path A LOK & IQK*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf9000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	reg_eac = rtl_get_bbreg(hw, 0xeac, MASKDWORD);
+	reg_e94 = rtl_get_bbreg(hw, 0xe94, MASKDWORD);
+	reg_e9c = rtl_get_bbreg(hw, 0xe9c, MASKDWORD);
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42))
+		result |= 0x01;
+	else
+		return result;
+
+	return result;
+}
+
+static u8 _rtl92ee_phy_path_b_iqk(struct ieee80211_hw *hw)
+{
+	u32 reg_eac, reg_eb4, reg_ebc;
+	u8 result = 0x00;
+
+	/* PA/PAD controlled by 0x0 */
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_B, 0xdf, RFREG_OFFSET_MASK, 0x180);
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x00000000);
+	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x80800000);
+
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_B, MASKDWORD, 0x821403e2);
+	rtl_set_bbreg(hw, RRx_IQK_PI_B, MASKDWORD, 0x68160000);
+
+	/* LO calibration setting */
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x00462911);
+
+	/*One shot, path B LOK & IQK*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xfa000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	reg_eac = rtl_get_bbreg(hw, 0xeac, MASKDWORD);
+	reg_eb4 = rtl_get_bbreg(hw, 0xeb4, MASKDWORD);
+	reg_ebc = rtl_get_bbreg(hw, 0xebc, MASKDWORD);
+
+	if (!(reg_eac & BIT(31)) &&
+	    (((reg_eb4 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_ebc & 0x03FF0000) >> 16) != 0x42))
+		result |= 0x01;
+	else
+		return result;
+
+	return result;
+}
+
+static u8 _rtl92ee_phy_path_a_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
+{
+	u32 reg_eac, reg_e94, reg_e9c, reg_ea4 , u32temp;
+	u8 result = 0x00;
+
+	/*Get TXIMR Setting*/
+	/*Modify RX IQK mode table*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf117b);
+
+	/*PA/PAD control by 0x56, and set = 0x0*/
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x980);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x56, RFREG_OFFSET_MASK, 0x51000);
+
+	/*enter IQK mode*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/*IQK Setting*/
+	rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+	/*path a IQK setting*/
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_A, MASKDWORD, 0x82160c1f);
+	rtl_set_bbreg(hw, RRx_IQK_PI_A, MASKDWORD, 0x68160c1f);
+
+	/*LO calibration Setting*/
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x0046a911);
+
+	/*one shot, path A LOK & iqk*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xfa000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRx_Power_After_IQK_A_2, MASKDWORD);
+	reg_e94 = rtl_get_bbreg(hw, RTx_Power_Before_IQK_A, MASKDWORD);
+	reg_e9c = rtl_get_bbreg(hw, RTx_Power_After_IQK_A, MASKDWORD);
+
+	if (!(reg_eac & BIT(28)) &&
+	    (((reg_e94 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_e9c & 0x03FF0000) >> 16) != 0x42)) {
+		result |= 0x01;
+	} else {
+		/*	PA/PAD controlled by 0x0 */
+		rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+		rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x180);
+		return result;
+	}
+
+	u32temp = 0x80007C00 | (reg_e94 & 0x3FF0000)  |
+		  ((reg_e9c & 0x3FF0000) >> 16);
+	rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, u32temp);
+	/*RX IQK*/
+	/*Modify RX IQK mode table*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_A, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7ffa);
+
+	/*PA/PAD control by 0x56, and set = 0x0*/
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x980);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x56, RFREG_OFFSET_MASK, 0x51000);
+
+	/*enter IQK mode*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/*IQK Setting*/
+	rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+	/*path a IQK setting*/
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_A, MASKDWORD, 0x82160c1f);
+	rtl_set_bbreg(hw, RRx_IQK_PI_A, MASKDWORD, 0x28160c1f);
+
+	/*LO calibration Setting*/
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x0046a891);
+	/*one shot, path A LOK & iqk*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xfa000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+	/*Check failed*/
+	reg_eac = rtl_get_bbreg(hw, RRx_Power_After_IQK_A_2, MASKDWORD);
+	reg_ea4 = rtl_get_bbreg(hw, RRx_Power_Before_IQK_A_2, MASKDWORD);
+
+	/*PA/PAD controlled by 0x0*/
+	/*leave IQK mode*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0xdf, RFREG_OFFSET_MASK, 0x180);
+	/*if Tx is OK, check whether Rx is OK*/
+	if (!(reg_eac & BIT(27)) &&
+	    (((reg_ea4 & 0x03FF0000) >> 16) != 0x132) &&
+	    (((reg_eac & 0x03FF0000) >> 16) != 0x36))
+		result |= 0x02;
+
+	return result;
+}
+
+static u8 _rtl92ee_phy_path_b_rx_iqk(struct ieee80211_hw *hw, bool config_pathb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 reg_eac, reg_eb4, reg_ebc, reg_ecc, reg_ec4, u32temp;
+	u8 result = 0x00;
+
+	/*Get TXIMR Setting*/
+	/*Modify RX IQK mode table*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf117b);
+
+	/*PA/PAD all off*/
+	rtl_set_rfreg(hw, RF90_PATH_B, 0xdf, RFREG_OFFSET_MASK, 0x980);
+	rtl_set_rfreg(hw, RF90_PATH_B, 0x56, RFREG_OFFSET_MASK, 0x51000);
+
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/*IQK Setting*/
+	rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+	/*path a IQK setting*/
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x18008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_B, MASKDWORD, 0x82160c1f);
+	rtl_set_bbreg(hw, RRx_IQK_PI_B, MASKDWORD, 0x68160c1f);
+
+	/*LO calibration Setting*/
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x0046a911);
+
+	/*one shot, path A LOK & iqk*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xfa000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+
+	/* Check failed */
+	reg_eac = rtl_get_bbreg(hw, RRx_Power_After_IQK_A_2, MASKDWORD);
+	reg_eb4 = rtl_get_bbreg(hw, RTx_Power_Before_IQK_B, MASKDWORD);
+	reg_ebc = rtl_get_bbreg(hw, RTx_Power_After_IQK_B, MASKDWORD);
+
+	if (!(reg_eac & BIT(31)) &&
+	    (((reg_eb4 & 0x03FF0000) >> 16) != 0x142) &&
+	    (((reg_ebc & 0x03FF0000) >> 16) != 0x42)) {
+		result |= 0x01;
+	} else {
+		/*	PA/PAD controlled by 0x0 */
+		rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+		rtl_set_rfreg(hw, RF90_PATH_B, 0xdf, RFREG_OFFSET_MASK, 0x180);
+		return result;
+	}
+
+	u32temp = 0x80007C00 | (reg_eb4 & 0x3FF0000) |
+		  ((reg_ebc & 0x3FF0000) >> 16);
+	rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, u32temp);
+	/*RX IQK*/
+	/*Modify RX IQK mode table*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_WE_LUT, RFREG_OFFSET_MASK, 0x800a0);
+
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_RCK_OS, RFREG_OFFSET_MASK, 0x30000);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_TXPA_G1, RFREG_OFFSET_MASK, 0x0000f);
+	rtl_set_rfreg(hw, RF90_PATH_B, RF_TXPA_G2, RFREG_OFFSET_MASK, 0xf7ffa);
+
+	/*PA/PAD all off*/
+	rtl_set_rfreg(hw, RF90_PATH_B, 0xdf, RFREG_OFFSET_MASK, 0x980);
+	rtl_set_rfreg(hw, RF90_PATH_B, 0x56, RFREG_OFFSET_MASK, 0x51000);
+
+	/*enter IQK mode*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+
+	/*IQK Setting*/
+	rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+	/*path b IQK setting*/
+	rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RTx_IQK_Tone_B, MASKDWORD, 0x38008c1c);
+	rtl_set_bbreg(hw, RRx_IQK_Tone_B, MASKDWORD, 0x18008c1c);
+
+	rtl_set_bbreg(hw, RTx_IQK_PI_B, MASKDWORD, 0x82160c1f);
+	rtl_set_bbreg(hw, RRx_IQK_PI_B, MASKDWORD, 0x28160c1f);
+
+	/*LO calibration Setting*/
+	rtl_set_bbreg(hw, RIQK_AGC_Rsp, MASKDWORD, 0x0046a891);
+	/*one shot, path A LOK & iqk*/
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xfa000000);
+	rtl_set_bbreg(hw, RIQK_AGC_Pts, MASKDWORD, 0xf8000000);
+
+	mdelay(IQK_DELAY_TIME);
+	/*Check failed*/
+	reg_eac = rtl_get_bbreg(hw, RRx_Power_After_IQK_A_2, MASKDWORD);
+	reg_ec4 = rtl_get_bbreg(hw, RRx_Power_Before_IQK_B_2, MASKDWORD);
+	reg_ecc = rtl_get_bbreg(hw, RRx_Power_After_IQK_B_2, MASKDWORD);
+	/*PA/PAD controlled by 0x0*/
+	/*leave IQK mode*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x00000000);
+	rtl_set_rfreg(hw, RF90_PATH_B, 0xdf, RFREG_OFFSET_MASK, 0x180);
+	/*if Tx is OK, check whether Rx is OK*/
+	if (!(reg_eac & BIT(30)) &&
+	    (((reg_ec4 & 0x03FF0000) >> 16) != 0x132) &&
+	    (((reg_ecc & 0x03FF0000) >> 16) != 0x36))
+		result |= 0x02;
+	else
+		RT_TRACE(COMP_RF, DBG_LOUD, ("Path B Rx IQK fail!!\n"));
+
+	return result;
+}
+
+static void _rtl92ee_phy_path_a_fill_iqk_matrix(struct ieee80211_hw *hw,
+						bool b_iqk_ok, long result[][8],
+						u8 final_candidate,
+						bool btxonly)
+{
+	u32 oldval_0, x, tx0_a, reg;
+	long y, tx0_c;
+
+	if (final_candidate == 0xFF) {
+		return;
+	} else if (b_iqk_ok) {
+		oldval_0 = (rtl_get_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
+					  MASKDWORD) >> 22) & 0x3FF;
+		x = result[final_candidate][0];
+		if ((x & 0x00000200) != 0)
+			x = x | 0xFFFFFC00;
+		tx0_a = (x * oldval_0) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE, 0x3FF, tx0_a);
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(31),
+			      ((x * oldval_0 >> 7) & 0x1));
+		y = result[final_candidate][1];
+		if ((y & 0x00000200) != 0)
+			y = y | 0xFFFFFC00;
+		tx0_c = (y * oldval_0) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XCTXAFE, 0xF0000000,
+			      ((tx0_c & 0x3C0) >> 6));
+		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE, 0x003F0000,
+			      (tx0_c & 0x3F));
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(29),
+			      ((y * oldval_0 >> 7) & 0x1));
+
+		if (btxonly)
+			return;
+
+		reg = result[final_candidate][2];
+		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBALANCE, 0x3FF, reg);
+
+		reg = result[final_candidate][3] & 0x3F;
+		rtl_set_bbreg(hw, ROFDM0_XARXIQIMBALANCE, 0xFC00, reg);
+
+		reg = (result[final_candidate][3] >> 6) & 0xF;
+		rtl_set_bbreg(hw, ROFDM0_RXIQEXTANTA, 0xF0000000, reg);
+	}
+}
+
+static void _rtl92ee_phy_path_b_fill_iqk_matrix(struct ieee80211_hw *hw,
+						bool b_iqk_ok, long result[][8],
+						u8 final_candidate,
+						bool btxonly)
+{
+	u32 oldval_1, x, tx1_a, reg;
+	long y, tx1_c;
+
+	if (final_candidate == 0xFF) {
+		return;
+	} else if (b_iqk_ok) {
+		oldval_1 = (rtl_get_bbreg(hw, ROFDM0_XATXIQIMBALANCE,
+					  MASKDWORD) >> 22) & 0x3FF;
+		x = result[final_candidate][4];
+		if ((x & 0x00000200) != 0)
+			x = x | 0xFFFFFC00;
+		tx1_a = (x * oldval_1) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XATXIQIMBALANCE, 0x3FF, tx1_a);
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(27),
+			      ((x * oldval_1 >> 7) & 0x1));
+		y = result[final_candidate][5];
+		if ((y & 0x00000200) != 0)
+			y = y | 0xFFFFFC00;
+		tx1_c = (y * oldval_1) >> 8;
+		rtl_set_bbreg(hw, ROFDM0_XDTXAFE, 0xF0000000,
+			      ((tx1_c & 0x3C0) >> 6));
+		rtl_set_bbreg(hw, ROFDM0_XBTXIQIMBALANCE, 0x003F0000,
+			      (tx1_c & 0x3F));
+		rtl_set_bbreg(hw, ROFDM0_ECCATHRESHOLD, BIT(25),
+			      ((y * oldval_1 >> 7) & 0x1));
+
+		if (btxonly)
+			return;
+
+		reg = result[final_candidate][6];
+		rtl_set_bbreg(hw, ROFDM0_XBRXIQIMBALANCE, 0x3FF, reg);
+
+		reg = result[final_candidate][7] & 0x3F;
+		rtl_set_bbreg(hw, ROFDM0_XBRXIQIMBALANCE, 0xFC00, reg);
+
+		reg = (result[final_candidate][7] >> 6) & 0xF;
+		rtl_set_bbreg(hw, ROFDM0_AGCRSSITABLE, 0xF0000000, reg);
+	}
+}
+
+static void _rtl92ee_phy_save_adda_registers(struct ieee80211_hw *hw,
+					     u32 *addareg, u32 *addabackup,
+					     u32 registernum)
+{
+	u32 i;
+
+	for (i = 0; i < registernum; i++)
+		addabackup[i] = rtl_get_bbreg(hw, addareg[i], MASKDWORD);
+}
+
+static void _rtl92ee_phy_save_mac_registers(struct ieee80211_hw *hw,
+					    u32 *macreg, u32 *macbackup)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 i;
+
+	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++)
+		macbackup[i] = rtl_read_byte(rtlpriv, macreg[i]);
+
+	macbackup[i] = rtl_read_dword(rtlpriv, macreg[i]);
+}
+
+static void _rtl92ee_phy_reload_adda_registers(struct ieee80211_hw *hw,
+					       u32 *addareg, u32 *addabackup,
+					       u32 regiesternum)
+{
+	u32 i;
+
+	for (i = 0; i < regiesternum; i++)
+		rtl_set_bbreg(hw, addareg[i], MASKDWORD, addabackup[i]);
+}
+
+static void _rtl92ee_phy_reload_mac_registers(struct ieee80211_hw *hw,
+					      u32 *macreg, u32 *macbackup)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 i;
+
+	for (i = 0; i < (IQK_MAC_REG_NUM - 1); i++)
+		rtl_write_byte(rtlpriv, macreg[i], (u8) macbackup[i]);
+	rtl_write_dword(rtlpriv, macreg[i], macbackup[i]);
+}
+
+static void _rtl92ee_phy_path_adda_on(struct ieee80211_hw *hw, u32 *addareg,
+				      bool is_patha_on, bool is2t)
+{
+	u32 pathon;
+	u32 i;
+
+	pathon = is_patha_on ? 0x0fc01616 : 0x0fc01616;
+	if (!is2t) {
+		pathon = 0x0fc01616;
+		rtl_set_bbreg(hw, addareg[0], MASKDWORD, 0x0fc01616);
+	} else {
+		rtl_set_bbreg(hw, addareg[0], MASKDWORD, pathon);
+	}
+
+	for (i = 1; i < IQK_ADDA_REG_NUM; i++)
+		rtl_set_bbreg(hw, addareg[i], MASKDWORD, pathon);
+}
+
+static void _rtl92ee_phy_mac_setting_calibration(struct ieee80211_hw *hw,
+						 u32 *macreg, u32 *macbackup)
+{
+	rtl_set_bbreg(hw, 0x520, 0x00ff0000, 0xff);
+}
+
+static void _rtl92ee_phy_path_a_standby(struct ieee80211_hw *hw)
+{
+	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x0);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0, RFREG_OFFSET_MASK, 0x10000);
+	rtl_set_bbreg(hw, 0xe28, MASKDWORD, 0x80800000);
+}
+
+static bool _rtl92ee_phy_simularity_compare(struct ieee80211_hw *hw,
+					    long result[][8], u8 c1, u8 c2)
+{
+	u32 i, j, diff, simularity_bitmap, bound;
+
+	u8 final_candidate[2] = { 0xFF, 0xFF };
+	bool bresult = true/*, is2t = true*/;
+	s32 tmp1, tmp2;
+
+	bound = 8;
+
+	simularity_bitmap = 0;
+
+	for (i = 0; i < bound; i++) {
+		if ((i == 1) || (i == 3) || (i == 5) || (i == 7)) {
+			if ((result[c1][i] & 0x00000200) != 0)
+				tmp1 = result[c1][i] | 0xFFFFFC00;
+			else
+				tmp1 = result[c1][i];
+
+			if ((result[c2][i] & 0x00000200) != 0)
+				tmp2 = result[c2][i] | 0xFFFFFC00;
+			else
+				tmp2 = result[c2][i];
+		} else {
+			tmp1 = result[c1][i];
+			tmp2 = result[c2][i];
+		}
+
+		diff = (tmp1 > tmp2) ? (tmp1 - tmp2) : (tmp2 - tmp1);
+
+		if (diff > MAX_TOLERANCE) {
+			if ((i == 2 || i == 6) && !simularity_bitmap) {
+				if (result[c1][i] + result[c1][i + 1] == 0)
+					final_candidate[(i / 4)] = c2;
+				else if (result[c2][i] + result[c2][i + 1] == 0)
+					final_candidate[(i / 4)] = c1;
+				else
+					simularity_bitmap |= (1 << i);
+			} else {
+				simularity_bitmap |= (1 << i);
+			}
+		}
+	}
+
+	if (simularity_bitmap == 0) {
+		for (i = 0; i < (bound / 4); i++) {
+			if (final_candidate[i] != 0xFF) {
+				for (j = i * 4; j < (i + 1) * 4 - 2; j++)
+					result[3][j] =
+						result[final_candidate[i]][j];
+				bresult = false;
+			}
+		}
+		return bresult;
+	} else {
+		if (!(simularity_bitmap & 0x03)) {/*path A TX OK*/
+			for (i = 0; i < 2; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0x0c)) {/*path A RX OK*/
+			for (i = 2; i < 4; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0x30)) {/*path B TX OK*/
+			for (i = 4; i < 6; i++)
+				result[3][i] = result[c1][i];
+		}
+		if (!(simularity_bitmap & 0xc0)) {/*path B RX OK*/
+			for (i = 6; i < 8; i++)
+				result[3][i] = result[c1][i];
+		}
+		return false;
+	}
+}
+
+static void _rtl92ee_phy_iq_calibrate(struct ieee80211_hw *hw,
+				      long result[][8], u8 t, bool is2t)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u32 i;
+	u8 patha_ok, pathb_ok;
+	u8 tmp_0xc50 = (u8) rtl_get_bbreg(hw, 0xc50, MASKBYTE0);
+	u8 tmp_0xc58 = (u8) rtl_get_bbreg(hw, 0xc58, MASKBYTE0);
+	u32 adda_reg[IQK_ADDA_REG_NUM] = {
+		0x85c, 0xe6c, 0xe70, 0xe74,
+		0xe78, 0xe7c, 0xe80, 0xe84,
+		0xe88, 0xe8c, 0xed0, 0xed4,
+		0xed8, 0xedc, 0xee0, 0xeec
+	};
+
+	u32 iqk_mac_reg[IQK_MAC_REG_NUM] = {
+		0x522, 0x550, 0x551, 0x040
+	};
+
+	u32 iqk_bb_reg[IQK_BB_REG_NUM] = {
+		ROFDM0_TRXPATHENABLE, ROFDM0_TRMUXPAR,
+		RFPGA0_XCD_RFINTERFACESW, 0xb68, 0xb6c,
+		0x870, 0x860,
+		0x864, 0x800
+	};
+
+	const u32 retrycount = 2;
+
+
+	if (t == 0) {
+		_rtl92ee_phy_save_adda_registers(hw, adda_reg,
+						 rtlphy->adda_backup,
+						 IQK_ADDA_REG_NUM);
+		_rtl92ee_phy_save_mac_registers(hw, iqk_mac_reg,
+						rtlphy->iqk_mac_backup);
+		_rtl92ee_phy_save_adda_registers(hw, iqk_bb_reg,
+						 rtlphy->iqk_bb_backup,
+						 IQK_BB_REG_NUM);
+	}
+
+	_rtl92ee_phy_path_adda_on(hw, adda_reg, true, is2t);
+
+	/*BB setting*/
+	rtl_set_bbreg(hw, RFPGA0_RFMOD, BIT(24), 0x00);
+	rtl_set_bbreg(hw, ROFDM0_TRXPATHENABLE, MASKDWORD, 0x03a05600);
+	rtl_set_bbreg(hw, ROFDM0_TRMUXPAR, MASKDWORD, 0x000800e4);
+	rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW, MASKDWORD, 0x22208200);
+
+	rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BIT(10), 0x01);
+	rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BIT(26), 0x01);
+	rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE, BIT(10), 0x01);
+	rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE, BIT(10), 0x01);
+
+	_rtl92ee_phy_mac_setting_calibration(hw, iqk_mac_reg,
+					     rtlphy->iqk_mac_backup);
+	/* Page B init*/
+	/* IQ calibration setting*/
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+	rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, 0x01007c00);
+	rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+	for (i = 0; i < retrycount; i++) {
+		patha_ok = _rtl92ee_phy_path_a_iqk(hw, is2t);
+
+		if (patha_ok == 0x01) {
+			RT_TRACE(COMP_RF, DBG_LOUD,
+				 ("Path A Tx IQK Success!!\n"));
+			result[t][0] = (rtl_get_bbreg(hw,
+						      RTx_Power_Before_IQK_A,
+						      MASKDWORD) & 0x3FF0000)
+						      >> 16;
+			result[t][1] = (rtl_get_bbreg(hw, RTx_Power_After_IQK_A,
+						      MASKDWORD) & 0x3FF0000)
+						      >> 16;
+			break;
+		} else {
+			RT_TRACE(COMP_RF, DBG_LOUD,
+				 ("Path A Tx IQK Fail!!, ret = 0x%x\n",
+				  patha_ok));
+		}
+	}
+
+	for (i = 0 ; i < retrycount ; i++) {
+		patha_ok = _rtl92ee_phy_path_a_rx_iqk(hw, is2t);
+
+		if (patha_ok == 0x03) {
+			RT_TRACE(COMP_RF, DBG_LOUD,
+				 ("Path A Rx IQK Success!!\n"));
+			result[t][2] = (rtl_get_bbreg(hw,
+						      RRx_Power_Before_IQK_A_2,
+						      MASKDWORD) & 0x3FF0000)
+						      >> 16;
+			result[t][3] = (rtl_get_bbreg(hw,
+						      RRx_Power_After_IQK_A_2,
+						      MASKDWORD) & 0x3FF0000)
+						      >> 16;
+			break;
+		} else {
+			RT_TRACE(COMP_RF, DBG_LOUD,
+				 ("Path A Rx IQK Fail!!, ret = 0x%x\n",
+				  patha_ok));
+		}
+	}
+
+	if (0x00 == patha_ok)
+		RT_TRACE(COMP_RF, DBG_LOUD, ("Path A IQK failed!!, ret = 0\n"));
+
+	if (is2t) {
+		_rtl92ee_phy_path_a_standby(hw);
+		/* Turn Path B ADDA on */
+		_rtl92ee_phy_path_adda_on(hw, adda_reg, false, is2t);
+
+		/* IQ calibration setting */
+		rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0x80800000);
+		rtl_set_bbreg(hw, RTx_IQK, MASKDWORD, 0x01007c00);
+		rtl_set_bbreg(hw, RRx_IQK, MASKDWORD, 0x01004800);
+
+		for (i = 0 ; i < retrycount ; i++) {
+			pathb_ok = _rtl92ee_phy_path_b_iqk(hw);
+			if (pathb_ok == 0x01) {
+				RT_TRACE(COMP_RF, DBG_LOUD,
+					 ("Path B Tx IQK Success!!\n"));
+				result[t][4] = (rtl_get_bbreg(hw,
+							RTx_Power_Before_IQK_B,
+							MASKDWORD) & 0x3FF0000)
+							>> 16;
+				result[t][5] = (rtl_get_bbreg(hw,
+							RTx_Power_After_IQK_B,
+							MASKDWORD) & 0x3FF0000)
+							>> 16;
+				break;
+			} else {
+				RT_TRACE(COMP_RF, DBG_LOUD,
+					 ("Path B Tx IQK Fail!!, ret = 0x%x\n",
+					   pathb_ok));
+			}
+		}
+
+		for (i = 0 ; i < retrycount ; i++) {
+			pathb_ok = _rtl92ee_phy_path_b_rx_iqk(hw, is2t);
+			if (pathb_ok == 0x03) {
+				RT_TRACE(COMP_RF, DBG_LOUD,
+					 ("Path B Rx IQK Success!!\n"));
+				result[t][6] = (rtl_get_bbreg(hw,
+						       RRx_Power_Before_IQK_B_2,
+						       MASKDWORD) & 0x3FF0000)
+						       >> 16;
+				result[t][7] = (rtl_get_bbreg(hw,
+						       RRx_Power_After_IQK_B_2,
+						       MASKDWORD) & 0x3FF0000)
+						       >> 16;
+				break;
+			} else {
+				RT_TRACE(COMP_RF, DBG_LOUD,
+					 ("Path B Rx IQK Fail!!, ret = 0x%x\n",
+					 pathb_ok));
+			}
+		}
+
+		if (0x00 == pathb_ok)
+			RT_TRACE(COMP_RF, DBG_LOUD,
+				 ("Path B IQK failed!!, ret = 0\n"));
+	}
+	/* Back to BB mode, load original value */
+	RT_TRACE(COMP_RF, DBG_LOUD,
+		 ("IQK:Back to BB mode, load original value!\n"));
+	rtl_set_bbreg(hw, RFPGA0_IQK, MASKDWORD, 0);
+
+	if (t != 0) {
+		/* Reload ADDA power saving parameters */
+		_rtl92ee_phy_reload_adda_registers(hw, adda_reg,
+						   rtlphy->adda_backup,
+						   IQK_ADDA_REG_NUM);
+
+		/* Reload MAC parameters */
+		_rtl92ee_phy_reload_mac_registers(hw, iqk_mac_reg,
+						  rtlphy->iqk_mac_backup);
+
+		_rtl92ee_phy_reload_adda_registers(hw, iqk_bb_reg,
+						   rtlphy->iqk_bb_backup,
+						   IQK_BB_REG_NUM);
+
+		/* Restore RX initial gain */
+		rtl_set_bbreg(hw, 0xc50, MASKBYTE0, 0x50);
+		rtl_set_bbreg(hw, 0xc50, MASKBYTE0, tmp_0xc50);
+		if (is2t) {
+			rtl_set_bbreg(hw, 0xc50, MASKBYTE0, 0x50);
+			rtl_set_bbreg(hw, 0xc58, MASKBYTE0, tmp_0xc58);
+		}
+
+		/* load 0xe30 IQC default value */
+		rtl_set_bbreg(hw, RTx_IQK_Tone_A, MASKDWORD, 0x01008c00);
+		rtl_set_bbreg(hw, RRx_IQK_Tone_A, MASKDWORD, 0x01008c00);
+	}
+	RT_TRACE(COMP_RF, DBG_LOUD, ("_rtl92ee_phy_iq_calibrate() <==\n"));
+}
+
+static void _rtl92ee_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
+{
+	u8 tmpreg;
+	u32 rf_a_mode = 0, rf_b_mode = 0, lc_cal;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	tmpreg = rtl_read_byte(rtlpriv, 0xd03);
+
+	if ((tmpreg & 0x70) != 0)
+		rtl_write_byte(rtlpriv, 0xd03, tmpreg & 0x8F);
+	else
+		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
+
+	if ((tmpreg & 0x70) != 0) {
+		rf_a_mode = rtl_get_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS);
+
+		if (is2t)
+			rf_b_mode = rtl_get_rfreg(hw, RF90_PATH_B, 0x00,
+						  MASK12BITS);
+
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS,
+			      (rf_a_mode & 0x8FFFF) | 0x10000);
+
+		if (is2t)
+			rtl_set_rfreg(hw, RF90_PATH_B, 0x00, MASK12BITS,
+				      (rf_b_mode & 0x8FFFF) | 0x10000);
+	}
+	lc_cal = rtl_get_rfreg(hw, RF90_PATH_A, 0x18, MASK12BITS);
+
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x18, MASK12BITS, lc_cal | 0x08000);
+
+	mdelay(100);
+
+	if ((tmpreg & 0x70) != 0) {
+		rtl_write_byte(rtlpriv, 0xd03, tmpreg);
+		rtl_set_rfreg(hw, RF90_PATH_A, 0x00, MASK12BITS, rf_a_mode);
+
+		if (is2t)
+			rtl_set_rfreg(hw, RF90_PATH_B, 0x00, MASK12BITS,
+				      rf_b_mode);
+	} else {
+		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
+	}
+	RT_TRACE(COMP_INIT , DBG_LOUD , ("\n"));
+}
+
+static void _rtl92ee_phy_set_rfpath_switch(struct ieee80211_hw *hw,
+					   bool bmain, bool is2t)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	RT_TRACE(COMP_INIT , DBG_LOUD , ("\n"));
+
+	if (is_hal_stop(rtlhal)) {
+		u8 u1btmp;
+		u1btmp = rtl_read_byte(rtlpriv, REG_LEDCFG0);
+		rtl_write_byte(rtlpriv, REG_LEDCFG0, u1btmp | BIT(7));
+		rtl_set_bbreg(hw, rFPGA0_XAB_RFPARAMETER, BIT(13), 0x01);
+	}
+	if (is2t) {
+		if (bmain)
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(6), 0x1);
+		else
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(6), 0x2);
+	} else {
+		rtl_set_bbreg(hw, RFPGA0_XAB_RFINTERFACESW, BIT(8) | BIT(9), 0);
+		rtl_set_bbreg(hw, 0x914, MASKLWORD, 0x0201);
+
+		/* We use the RF definition of MAIN and AUX,
+		 * left antenna and right antenna repectively.
+		 * Default output at AUX.*/
+		if (bmain) {
+			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
+				      BIT(14) | BIT(13) | BIT(12), 0);
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(4) | BIT(3), 0);
+			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
+				rtl_set_bbreg(hw, rConfig_ram64x16, BIT(31), 0);
+		} else {
+			rtl_set_bbreg(hw, RFPGA0_XA_RFINTERFACEOE,
+				      BIT(14) | BIT(13) | BIT(12), 1);
+			rtl_set_bbreg(hw, RFPGA0_XB_RFINTERFACEOE,
+				      BIT(5) | BIT(4) | BIT(3), 1);
+			if (rtlefuse->antenna_div_type == CGCS_RX_HW_ANTDIV)
+				rtl_set_bbreg(hw, rConfig_ram64x16, BIT(31), 1);
+		}
+	}
+}
+
+#undef IQK_ADDA_REG_NUM
+#undef IQK_DELAY_TIME
+
+static u8 rtl92ee_get_rightchnlplace_for_iqk(u8 chnl)
+{
+	u8 channel_all[59] = {
+		1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
+		36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58,
+		60, 62, 64, 100, 102, 104, 106, 108, 110, 112,
+		114, 116, 118, 120, 122, 124, 126, 128,	130,
+		132, 134, 136, 138, 140, 149, 151, 153, 155,
+		157, 159, 161, 163, 165
+	};
+	u8 place = chnl;
+
+	if (chnl > 14) {
+		for (place = 14; place < sizeof(channel_all); place++) {
+			if (channel_all[place] == chnl)
+				return place - 13;
+		}
+	}
+
+	return 0;
+}
+
+void rtl92ee_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	long result[4][8];
+	u8 i, final_candidate;
+	bool b_patha_ok, b_pathb_ok;
+	long reg_e94, reg_e9c, reg_ea4, reg_eac;
+	long reg_eb4, reg_ebc, reg_ec4, reg_ecc;
+	bool is12simular, is13simular, is23simular;
+	u8 idx;
+	u32 iqk_bb_reg[IQK_BB_REG_NUM] = {
+		ROFDM0_XARXIQIMBALANCE,
+		ROFDM0_XBRXIQIMBALANCE,
+		ROFDM0_ECCATHRESHOLD,
+		ROFDM0_AGCRSSITABLE,
+		ROFDM0_XATXIQIMBALANCE,
+		ROFDM0_XBTXIQIMBALANCE,
+		ROFDM0_XCTXAFE,
+		ROFDM0_XDTXAFE,
+		ROFDM0_RXIQEXTANTA
+	};
+
+	if (b_recovery) {
+		_rtl92ee_phy_reload_adda_registers(hw, iqk_bb_reg,
+						   rtlphy->iqk_bb_backup, 9);
+		return;
+	}
+
+	for (i = 0; i < 8; i++) {
+		result[0][i] = 0;
+		result[1][i] = 0;
+		result[2][i] = 0;
+
+		if ((i == 0) || (i == 2) || (i == 4)  || (i == 6))
+			result[3][i] = 0x100;
+		else
+			result[3][i] = 0;
+	}
+	final_candidate = 0xff;
+	b_patha_ok = false;
+	b_pathb_ok = false;
+	is12simular = false;
+	is23simular = false;
+	is13simular = false;
+	for (i = 0; i < 3; i++) {
+		_rtl92ee_phy_iq_calibrate(hw, result, i, true);
+		if (i == 1) {
+			is12simular = _rtl92ee_phy_simularity_compare(hw,
+								      result,
+								      0, 1);
+			if (is12simular) {
+				final_candidate = 0;
+				break;
+			}
+		}
+
+		if (i == 2) {
+			is13simular = _rtl92ee_phy_simularity_compare(hw,
+								      result,
+								      0, 2);
+			if (is13simular) {
+				final_candidate = 0;
+				break;
+			}
+			is23simular = _rtl92ee_phy_simularity_compare(hw,
+								      result,
+								      1, 2);
+			if (is23simular)
+				final_candidate = 1;
+			else
+				final_candidate = 3;
+		}
+	}
+	for (i = 0; i < 4; i++) {
+		reg_e94 = result[i][0];
+		reg_e9c = result[i][1];
+		reg_ea4 = result[i][2];
+		reg_eac = result[i][3];
+		reg_eb4 = result[i][4];
+		reg_ebc = result[i][5];
+		reg_ec4 = result[i][6];
+		reg_ecc = result[i][7];
+	}
+	if (final_candidate != 0xff) {
+		reg_e94 = result[final_candidate][0];
+		rtlphy->reg_e94 = reg_e94;
+		reg_e9c = result[final_candidate][1];
+		rtlphy->reg_e9c = reg_e9c;
+		reg_ea4 = result[final_candidate][2];
+		reg_eac = result[final_candidate][3];
+		reg_eb4 = result[final_candidate][4];
+		rtlphy->reg_eb4 = reg_eb4;
+		reg_ebc = result[final_candidate][5];
+		rtlphy->reg_ebc = reg_ebc;
+		reg_ec4 = result[final_candidate][6];
+		reg_ecc = result[final_candidate][7];
+		b_patha_ok = true;
+		b_pathb_ok = true;
+	} else {
+		rtlphy->reg_e94 = 0x100;
+		rtlphy->reg_eb4 = 0x100;
+		rtlphy->reg_e9c = 0x0;
+		rtlphy->reg_ebc = 0x0;
+	}
+
+	if (reg_e94 != 0) /*&&(reg_ea4 != 0) */
+		_rtl92ee_phy_path_a_fill_iqk_matrix(hw, b_patha_ok, result,
+						    final_candidate,
+						    (reg_ea4 == 0));
+
+	_rtl92ee_phy_path_b_fill_iqk_matrix(hw, b_pathb_ok, result,
+					    final_candidate,
+					    (reg_ec4 == 0));
+
+	idx = rtl92ee_get_rightchnlplace_for_iqk(rtlphy->current_channel);
+
+	/* To Fix BSOD when final_candidate is 0xff
+	 * by sherry 20120321 */
+	if (final_candidate < 4) {
+		for (i = 0; i < IQK_MATRIX_REG_NUM; i++)
+			rtlphy->iqk_matrix_regsetting[idx].value[0][i] =
+				result[final_candidate][i];
+
+		rtlphy->iqk_matrix_regsetting[idx].b_iqk_done = true;
+	}
+	_rtl92ee_phy_save_adda_registers(hw, iqk_bb_reg,
+					 rtlphy->iqk_bb_backup, 9);
+}
+
+void rtl92ee_phy_lc_calibrate(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_hal *rtlhal = &(rtlpriv->rtlhal);
+	u32 timeout = 2000, timecount = 0;
+
+	while (rtlpriv->mac80211.act_scanning && timecount < timeout) {
+		udelay(50);
+		timecount += 50;
+	}
+
+	rtlphy->lck_inprogress = true;
+	RTPRINT(rtlpriv, FINIT, INIT_IQK,
+		"LCK:Start!!! currentband %x delay %d ms\n",
+		 rtlhal->current_bandtype, timecount);
+
+	_rtl92ee_phy_lc_calibrate(hw, false);
+
+	rtlphy->lck_inprogress = false;
+}
+
+void rtl92ee_phy_ap_calibrate(struct ieee80211_hw *hw, char delta)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	if (rtlphy->b_apk_done)
+		return;
+
+	return;
+}
+
+void rtl92ee_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain)
+{
+	_rtl92ee_phy_set_rfpath_switch(hw, bmain, false);
+}
+
+bool rtl92ee_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	bool b_postprocessing = false;
+
+	RT_TRACE(COMP_CMD, DBG_TRACE,
+		 ("-->IO Cmd(%#x), set_io_inprogress(%d)\n",
+		  iotype, rtlphy->set_io_inprogress));
+	do {
+		switch (iotype) {
+		case IO_CMD_RESUME_DM_BY_SCAN:
+			RT_TRACE(COMP_CMD, DBG_TRACE,
+				 ("[IO CMD] Resume DM after scan.\n"));
+			b_postprocessing = true;
+			break;
+		case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+			RT_TRACE(COMP_CMD, DBG_TRACE,
+				 ("[IO CMD] Pause DM before scan.\n"));
+			b_postprocessing = true;
+			break;
+		default:
+			RT_TRACE(COMP_ERR, DBG_EMERG,
+				 ("switch case not process\n"));
+			break;
+		}
+	} while (false);
+	if (b_postprocessing && !rtlphy->set_io_inprogress) {
+		rtlphy->set_io_inprogress = true;
+		rtlphy->current_io_type = iotype;
+	} else {
+		return false;
+	}
+	rtl92ee_phy_set_io(hw);
+	RT_TRACE(COMP_CMD, DBG_TRACE, ("IO Type(%#x)\n", iotype));
+	return true;
+}
+
+static void rtl92ee_phy_set_io(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	RT_TRACE(COMP_CMD, DBG_TRACE,
+		 ("--->Cmd(%#x), set_io_inprogress(%d)\n",
+		  rtlphy->current_io_type, rtlphy->set_io_inprogress));
+	switch (rtlphy->current_io_type) {
+	case IO_CMD_RESUME_DM_BY_SCAN:
+		rtl92ee_dm_write_dig(hw , rtlphy->initgain_backup.xaagccore1);
+		rtl92ee_dm_write_cck_cca_thres(hw, rtlphy->initgain_backup.cca);
+		RT_TRACE(COMP_CMD, DBG_TRACE , ("no set txpower\n"));
+		rtl92ee_phy_set_txpower_level(hw, rtlphy->current_channel);
+		break;
+	case IO_CMD_PAUSE_BAND0_DM_BY_SCAN:
+		/* 8192eebt */
+		rtlphy->initgain_backup.xaagccore1 = dm_dig.cur_igvalue;
+		rtl92ee_dm_write_dig(hw, 0x17);
+		rtlphy->initgain_backup.cca = dm_dig.cur_cck_cca_thres;
+		rtl92ee_dm_write_cck_cca_thres(hw, 0x40);
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("switch case not process\n"));
+		break;
+	}
+	rtlphy->set_io_inprogress = false;
+	RT_TRACE(COMP_CMD, DBG_TRACE,
+		 ("(%#x)\n", rtlphy->current_io_type));
+}
+
+static void rtl92ee_phy_set_rf_on(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x2b);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
+	/*rtl_write_byte(rtlpriv, REG_APSD_CTRL, 0x00);*/
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
+	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
+}
+
+static void _rtl92ee_phy_set_rf_sleep(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtl_write_byte(rtlpriv, REG_TXPAUSE, 0xFF);
+	rtl_set_rfreg(hw, RF90_PATH_A, 0x00, RFREG_OFFSET_MASK, 0x00);
+
+	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
+	rtl_write_byte(rtlpriv, REG_SPS0_CTRL, 0x22);
+}
+
+static bool _rtl92ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
+					    enum rf_pwrstate rfpwr_state)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	bool bresult = true;
+	u8 i, queue_id;
+	struct rtl8192_tx_ring *ring = NULL;
+
+	switch (rfpwr_state) {
+	case ERFON:
+		if ((ppsc->rfpwr_state == ERFOFF) &&
+		    RT_IN_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC)) {
+			bool rtstatus;
+			u32 init_count = 0;
+			do {
+				init_count++;
+				RT_TRACE(COMP_RF, DBG_DMESG,
+					 ("IPS Set eRf nic enable\n"));
+				rtstatus = stg_rtl_ps_enable_nic(hw);
+			} while (!rtstatus && (init_count < 10));
+			RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+		} else {
+			RT_TRACE(COMP_RF, DBG_DMESG,
+				 ("Set ERFON sleeped:%d ms\n",
+				  jiffies_to_msecs(jiffies -
+						   ppsc->last_sleep_jiffies)));
+			ppsc->last_awake_jiffies = jiffies;
+			rtl92ee_phy_set_rf_on(hw);
+		}
+		if (mac->link_state == MAC80211_LINKED)
+			rtlpriv->cfg->ops->led_control(hw, LED_CTL_LINK);
+		else
+			rtlpriv->cfg->ops->led_control(hw, LED_CTL_NO_LINK);
+		break;
+	case ERFOFF:
+		for (queue_id = 0, i = 0;
+		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
+			ring = &pcipriv->dev.tx_ring[queue_id];
+			if (skb_queue_len(&ring->queue) == 0) {
+				queue_id++;
+				continue;
+			} else {
+				RT_TRACE(COMP_ERR, DBG_WARNING,
+					 ("eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before "
+					  "doze!\n", (i + 1), queue_id,
+					  skb_queue_len(&ring->queue)));
+
+				udelay(10);
+				i++;
+			}
+			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
+				RT_TRACE(COMP_ERR, DBG_WARNING,
+					 ("\n ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+					  MAX_DOZE_WAITING_TIMES_9x,
+					  queue_id,
+					  skb_queue_len(&ring->queue)));
+				break;
+			}
+		}
+
+		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
+			RT_TRACE(COMP_RF, DBG_DMESG,
+				 ("IPS Set eRf nic disable\n"));
+			stg_rtl_ps_disable_nic(hw);
+			RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
+		} else {
+			if (ppsc->rfoff_reason == RF_CHANGE_BY_IPS) {
+				rtlpriv->cfg->ops->led_control(hw,
+							       LED_CTL_NO_LINK);
+			} else {
+				rtlpriv->cfg->ops->led_control(hw,
+							     LED_CTL_POWER_OFF);
+			}
+		}
+		break;
+	case ERFSLEEP:
+		if (ppsc->rfpwr_state == ERFOFF)
+			break;
+		for (queue_id = 0, i = 0;
+		     queue_id < RTL_PCI_MAX_TX_QUEUE_COUNT;) {
+			ring = &pcipriv->dev.tx_ring[queue_id];
+			if (skb_queue_len(&ring->queue) == 0) {
+				queue_id++;
+				continue;
+			} else {
+				RT_TRACE(COMP_ERR, DBG_WARNING,
+					 ("eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					  (i + 1), queue_id,
+					  skb_queue_len(&ring->queue)));
+				udelay(10);
+				i++;
+			}
+			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
+				RT_TRACE(COMP_ERR, DBG_WARNING,
+					 ("\n ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+					  MAX_DOZE_WAITING_TIMES_9x,
+					  queue_id,
+					  skb_queue_len(&ring->queue)));
+				break;
+			}
+		}
+		RT_TRACE(COMP_RF, DBG_DMESG,
+			 ("Set ERFSLEEP awaked:%d ms\n",
+			  jiffies_to_msecs(jiffies -
+					   ppsc->last_awake_jiffies)));
+		ppsc->last_sleep_jiffies = jiffies;
+		_rtl92ee_phy_set_rf_sleep(hw);
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("switch case not process\n"));
+		bresult = false;
+		break;
+	}
+	if (bresult)
+		ppsc->rfpwr_state = rfpwr_state;
+	return bresult;
+}
+
+bool rtl92ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
+				    enum rf_pwrstate rfpwr_state)
+{
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+
+	bool bresult = false;
+
+	if (rfpwr_state == ppsc->rfpwr_state)
+		return bresult;
+	bresult = _rtl92ee_phy_set_rf_power_state(hw, rfpwr_state);
+	return bresult;
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/phy.h b/drivers/staging/rtl8192ee/rtl8192ee/phy.h
new file mode 100644
index 0000000..5be6c48
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/phy.h
@@ -0,0 +1,154 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_PHY_H__
+#define __RTL92E_PHY_H__
+
+/*It must always set to 4, otherwise read efuse table secquence will be wrong.*/
+#define MAX_TX_COUNT				4
+#define TX_1S					0
+#define TX_2S					1
+#define TX_3S					2
+#define TX_4S					3
+
+#define MAX_POWER_INDEX				0x3f
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
+#define IQK_MAC_REG_NUM				4
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
+#define RTL92C_MAX_PATH_NUM			2
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
+enum baseband_config_type {
+	BASEBAND_CONFIG_PHY_REG = 0,
+	BASEBAND_CONFIG_AGC_TAB = 1,
+};
+
+enum ant_div_type {
+	NO_ANTDIV = 0xFF,
+	CG_TRX_HW_ANTDIV = 0x01,
+	CGCS_RX_HW_ANTDIV = 0x02,
+	FIXED_HW_ANTDIV = 0x03,
+	CG_TRX_SMART_ANTDIV = 0x04,
+	CGCS_RX_SW_ANTDIV = 0x05,
+
+};
+extern u32 rtl92ee_phy_query_bb_reg(struct ieee80211_hw *hw,
+				    u32 regaddr, u32 bitmask);
+extern void rtl92ee_phy_set_bb_reg(struct ieee80211_hw *hw,
+				   u32 regaddr, u32 bitmask, u32 data);
+extern u32 rtl92ee_phy_query_rf_reg(struct ieee80211_hw *hw,
+				    enum radio_path rfpath, u32 regaddr,
+				    u32 bitmask);
+extern void rtl92ee_phy_set_rf_reg(struct ieee80211_hw *hw,
+				   enum radio_path rfpath, u32 regaddr,
+				   u32 bitmask, u32 data);
+extern bool rtl92ee_phy_mac_config(struct ieee80211_hw *hw);
+extern bool rtl92ee_phy_bb_config(struct ieee80211_hw *hw);
+extern bool rtl92ee_phy_rf_config(struct ieee80211_hw *hw);
+extern void rtl92ee_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw);
+extern void rtl92ee_phy_get_txpower_level(struct ieee80211_hw *hw,
+					  long *powerlevel);
+extern void rtl92ee_phy_set_txpower_level(struct ieee80211_hw *hw, u8 channel);
+extern void rtl92ee_phy_scan_operation_backup(struct ieee80211_hw *hw,
+					      u8 operation);
+extern void rtl92ee_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+extern void rtl92ee_phy_set_bw_mode(struct ieee80211_hw *hw,
+				    enum nl80211_channel_type ch_type);
+extern void rtl92ee_phy_sw_chnl_callback(struct ieee80211_hw *hw);
+extern u8 rtl92ee_phy_sw_chnl(struct ieee80211_hw *hw);
+extern void rtl92ee_phy_iq_calibrate(struct ieee80211_hw *hw, bool b_recovery);
+void rtl92ee_phy_ap_calibrate(struct ieee80211_hw *hw, char delta);
+void rtl92ee_phy_lc_calibrate(struct ieee80211_hw *hw);
+void rtl92ee_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
+bool rtl92ee_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
+					   enum radio_path rfpath);
+bool rtl92ee_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
+extern bool rtl92ee_phy_set_rf_power_state(struct ieee80211_hw *hw,
+					   enum rf_pwrstate rfpwr_state);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c b/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c
new file mode 100644
index 0000000..08a2df8
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c
@@ -0,0 +1,108 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "pwrseqcmd.h"
+#include "pwrseq.h"
+
+
+/*
+    drivers should parse below arrays and do the corresponding actions
+*/
+/*3 Power on  Array*/
+struct wlan_pwr_cfg rtl8192E_power_on_flow[RTL8192E_TRANS_CARDEMU_TO_ACT_STEPS +
+					   RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_CARDEMU_TO_ACT
+	RTL8192E_TRANS_END
+};
+
+/*3Radio off GPIO Array */
+struct wlan_pwr_cfg rtl8192E_radio_off_flow[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS
+					    + RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_ACT_TO_CARDEMU
+	RTL8192E_TRANS_END
+};
+
+/*3Card Disable Array*/
+struct wlan_pwr_cfg rtl8192E_card_disable_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					 RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_ACT_TO_CARDEMU
+	RTL8192E_TRANS_CARDEMU_TO_CARDDIS
+	RTL8192E_TRANS_END
+};
+
+/*3 Card Enable Array*/
+struct wlan_pwr_cfg rtl8192E_card_enable_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					 RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_CARDDIS_TO_CARDEMU
+	RTL8192E_TRANS_CARDEMU_TO_ACT
+	RTL8192E_TRANS_END
+};
+
+/*3Suspend Array*/
+struct wlan_pwr_cfg rtl8192E_suspend_flow[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					  RTL8192E_TRANS_CARDEMU_TO_SUS_STEPS +
+					  RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_ACT_TO_CARDEMU
+	RTL8192E_TRANS_CARDEMU_TO_SUS
+	RTL8192E_TRANS_END
+};
+
+/*3 Resume Array*/
+struct wlan_pwr_cfg rtl8192E_resume_flow[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_SUS_STEPS +
+					 RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_SUS_TO_CARDEMU
+	RTL8192E_TRANS_CARDEMU_TO_ACT
+	RTL8192E_TRANS_END
+};
+
+/*3HWPDN Array*/
+struct wlan_pwr_cfg rtl8192E_hwpdn_flow[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					RTL8192E_TRANS_END_STEPS] = {
+	RTL8192E_TRANS_ACT_TO_CARDEMU
+	RTL8192E_TRANS_CARDEMU_TO_PDN
+	RTL8192E_TRANS_END
+};
+
+/*3 Enter LPS */
+struct wlan_pwr_cfg rtl8192E_enter_lps_flow[RTL8192E_TRANS_ACT_TO_LPS_STEPS +
+					    RTL8192E_TRANS_END_STEPS] = {
+	/*FW behavior*/
+	RTL8192E_TRANS_ACT_TO_LPS
+	RTL8192E_TRANS_END
+};
+
+/*3 Leave LPS */
+struct wlan_pwr_cfg rtl8192E_leave_lps_flow[RTL8192E_TRANS_LPS_TO_ACT_STEPS +
+					    RTL8192E_TRANS_END_STEPS] = {
+	/*FW behavior*/
+	RTL8192E_TRANS_LPS_TO_ACT
+	RTL8192E_TRANS_END
+};
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h b/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h
new file mode 100644
index 0000000..5288972
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h
@@ -0,0 +1,355 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_PWRSEQ_H__
+#define __RTL92E_PWRSEQ_H__
+
+#include "pwrseqcmd.h"
+/*
+	Check document WM-20110607-Paul-RTL8192E_Power_Architecture-R02.vsd
+	There are 6 HW Power States:
+	0: POFF--Power Off
+	1: PDN--Power Down
+	2: CARDEMU--Card Emulation
+	3: ACT--Active Mode
+	4: LPS--Low Power State
+	5: SUS--Suspend
+
+	The transision from different states are defined below
+	TRANS_CARDEMU_TO_ACT
+	TRANS_ACT_TO_CARDEMU
+	TRANS_CARDEMU_TO_SUS
+	TRANS_SUS_TO_CARDEMU
+	TRANS_CARDEMU_TO_PDN
+	TRANS_ACT_TO_LPS
+	TRANS_LPS_TO_ACT
+
+	TRANS_END
+	PWR SEQ Version: rtl8192E_PwrSeq_V09.h
+*/
+
+#define	RTL8192E_TRANS_CARDEMU_TO_ACT_STEPS	18
+#define	RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS	18
+#define	RTL8192E_TRANS_CARDEMU_TO_SUS_STEPS	18
+#define	RTL8192E_TRANS_SUS_TO_CARDEMU_STEPS	18
+#define	RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS	18
+#define	RTL8192E_TRANS_PDN_TO_CARDEMU_STEPS	18
+#define	RTL8192E_TRANS_ACT_TO_LPS_STEPS		23
+#define	RTL8192E_TRANS_LPS_TO_ACT_STEPS		23
+#define	RTL8192E_TRANS_END_STEPS		1
+
+
+#define RTL8192E_TRANS_CARDEMU_TO_ACT					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/* disable HWPDN 0x04[15]=0*/					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(7), 0},			\
+	/* disable SW LPS 0x04[10]=0*/					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(2), 0},			\
+	/* disable WL suspend*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, (BIT(4)|BIT(3)), 0},		\
+	/* wait till 0x04[17] = 1    power ready*/			\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/* release WLON reset  0x04[16]=1*/				\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/* polling until return 0*/					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/**/								\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, BIT(0), 0},
+
+
+#define RTL8192E_TRANS_ACT_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*0x1F[7:0] = 0 turn off RF*/					\
+	{0x001F, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0},			\
+	/*0x4C[23]=0x4E[7]=0, switch DPDT_SEL_P output from register 0x65[2] */\
+	{0x004E, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(7), 0},			\
+	/*0x04[9] = 1 turn off MAC by HW state machine*/		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*wait till 0x04[9] = 0 polling until return 0 to disable*/	\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, BIT(1), 0},
+
+
+#define RTL8192E_TRANS_CARDEMU_TO_SUS					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(4) | BIT(3), (BIT(4) | BIT(3))},\
+	/*0x04[12:11] = 2b'01 enable WL suspend*/			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK | PWR_INTF_SDIO_MSK, PWR_BASEADDR_MAC,	\
+	 PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},				\
+	/*0x04[12:11] = 2b'11 enable WL suspend for PCIe*/		\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(3) | BIT(4), BIT(3) | BIT(4)},\
+	/*Set SDIO suspend local register*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	 /*wait power state to suspend*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_POLLING, BIT(1), 0},
+
+
+#define RTL8192E_TRANS_SUS_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*Set SDIO suspend local register*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_WRITE, BIT(0), 0},			\
+	/*wait power state to suspend*/					\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/*0x04[12:11] = 2b'01enable WL suspend*/			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(3) | BIT(4), 0},
+
+
+#define RTL8192E_TRANS_CARDEMU_TO_CARDDIS				\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*0x07=0x20 , SOP option to disable BG/MB*/			\
+	{0x0007, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0x20},			\
+	/*Unlock small LDO Register*/					\
+	{0x00CC, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(2), BIT(2)},		\
+	/*Disable small LDO*/						\
+	{0x0011, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), 0},			\
+	/*0x04[12:11] = 2b'01 enable WL suspend*/			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK,			\
+	 PWR_INTF_USB_MSK|PWR_INTF_SDIO_MSK,PWR_BASEADDR_MAC,		\
+	 PWR_CMD_WRITE, BIT(3)|BIT(4), BIT(3)},				\
+	/*0x04[10] = 1, enable SW LPS*/					\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(2), BIT(2)},		\
+	/*Set SDIO suspend local register*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*wait power state to suspend*/					\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_POLLING, BIT(1), 0},
+
+
+#define RTL8192E_TRANS_CARDDIS_TO_CARDEMU				\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*Set SDIO suspend local register*/				\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_WRITE, BIT(0), 0},			\
+	/*wait power state to suspend*/					\
+	{0x0086, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_POLLING, BIT(1), BIT(1)},		\
+	/*Enable small LDO*/						\
+	{0x0011, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), BIT(0)},		\
+	/*Lock small LDO Register*/					\
+	{0x00CC, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(2), 0},			\
+	/*0x04[12:11] = 2b'01enable WL suspend*/			\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(3) | BIT(4), 0},
+
+
+#define RTL8192E_TRANS_CARDEMU_TO_PDN					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/* 0x04[16] = 0*/						\
+	{0x0006, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), 0},			\
+	/* 0x04[15] = 1*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(7), BIT(7)},
+
+
+#define RTL8192E_TRANS_PDN_TO_CARDEMU					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/* 0x04[15] = 0*/						\
+	{0x0005, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(7), 0},
+
+
+#define RTL8192E_TRANS_ACT_TO_LPS					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*PCIe DMA stop*/						\
+	{0x0301, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/*Tx Pause*/							\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/*Should be zero if no packet is transmitting*/			\
+	{0x05F8, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
+	{0x05F9, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
+	{0x05FA, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, 0xFF, 0},			\
+	/*Should be zero if no packet is transmitting*/			\
+	{0x05FB, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, 0xFF, 0},			\
+	/*CCK and OFDM are disabled,and clock are gated*/		\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(0), 0},			\
+	/*Delay 1us*/							\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_DELAY, 0, PWRSEQ_DELAY_US},		\
+	/*Whole BB is reset*/						\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(1), 0},			\
+	/*Reset MAC TRX*/						\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0x03},			\
+	/*check if removed later*/					\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(1), 0},			\
+	/*When driver enter Sus/ Disable, enable LOP for BT*/		\
+	{0x0093, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0x00},			\
+	/*Respond TxOK to scheduler*/					\
+	{0x0553, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(5), BIT(5)},
+
+
+#define RTL8192E_TRANS_LPS_TO_ACT					\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	/*SDIO RPWM, For Repeatly In and out, Taggle bit should be changed*/\
+	{0x0080, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_SDIO_MSK,	\
+	 PWR_BASEADDR_SDIO , PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*USB RPWM*/							\
+	{0xFE58, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_USB_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*PCIe RPWM*/							\
+	{0x0361, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_PCI_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0x84},			\
+	/*Delay*/							\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_DELAY, 0, PWRSEQ_DELAY_MS},		\
+	/*0x08[4] = 0 switch TSF to 40M*/				\
+	{0x0008, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(4), 0},			\
+	/*Polling 0x109[7]=0  TSF in 40M*/				\
+	{0x0109, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_POLLING, BIT(7), 0},			\
+	/*0x101[1] = 1*/						\
+	{0x0101, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(1), BIT(1)},		\
+	/*0x100[7:0] = 0xFF  enable WMAC TRX*/				\
+	{0x0100, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0xFF},			\
+	/* 0x02[1:0] = 2b'11 enable BB macro*/				\
+	{0x0002, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, BIT(1) | BIT(0), BIT(1) | BIT(0)},\
+	/*0x522 = 0*/							\
+	{0x0522, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0},			\
+	/*Clear ISR*/							\
+	{0x013D, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 PWR_BASEADDR_MAC , PWR_CMD_WRITE, 0xFF, 0xFF},
+
+
+#define RTL8192E_TRANS_END						\
+	/* format */							\
+	/* comments here */						\
+	/* { offset, cut_msk, fab_msk|interface_msk, base|cmd, msk, value },*/\
+	{0xFFFF, PWR_CUT_ALL_MSK, PWR_FAB_ALL_MSK, PWR_INTF_ALL_MSK,	\
+	 0, PWR_CMD_END, 0, 0},
+
+extern struct wlan_pwr_cfg rtl8192E_power_on_flow
+					[RTL8192E_TRANS_CARDEMU_TO_ACT_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_radio_off_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_card_disable_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_card_enable_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_suspend_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_SUS_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_resume_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_SUS_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_hwpdn_flow
+					[RTL8192E_TRANS_ACT_TO_CARDEMU_STEPS +
+					 RTL8192E_TRANS_CARDEMU_TO_PDN_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_enter_lps_flow
+					[RTL8192E_TRANS_ACT_TO_LPS_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+extern struct wlan_pwr_cfg rtl8192E_leave_lps_flow
+					[RTL8192E_TRANS_LPS_TO_ACT_STEPS +
+					 RTL8192E_TRANS_END_STEPS];
+
+
+/* RTL8192EE Power Configuration CMDs for PCIe interface */
+#define Rtl8192E_NIC_PWR_ON_FLOW	rtl8192E_power_on_flow
+#define Rtl8192E_NIC_RF_OFF_FLOW	rtl8192E_radio_off_flow
+#define Rtl8192E_NIC_DISABLE_FLOW	rtl8192E_card_disable_flow
+#define Rtl8192E_NIC_ENABLE_FLOW	rtl8192E_card_enable_flow
+#define Rtl8192E_NIC_SUSPEND_FLOW	rtl8192E_suspend_flow
+#define Rtl8192E_NIC_RESUME_FLOW	rtl8192E_resume_flow
+#define Rtl8192E_NIC_PDN_FLOW		rtl8192E_hwpdn_flow
+#define Rtl8192E_NIC_LPS_ENTER_FLOW	rtl8192E_enter_lps_flow
+#define Rtl8192E_NIC_LPS_LEAVE_FLOW	rtl8192E_leave_lps_flow
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c b/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c
new file mode 100644
index 0000000..efb00f6
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c
@@ -0,0 +1,139 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "pwrseq.h"
+
+
+/*
+*	Description:
+*		This routine deal with the Power Configuration CMDs
+*		 parsing for RTL8723/RTL8188E Series IC.
+*	Assumption:
+*		We should follow specific format which was released from HW SD.
+*
+*	2011.07.07, added by Roger.
+*/
+bool rtl92e_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			       u8 fab_version, u8 interface_type,
+			       struct wlan_pwr_cfg pwrcfgcmd[])
+
+{
+	struct wlan_pwr_cfg pwr_cfg_cmd = {0};
+	bool b_polling_bit = false;
+	u32 ary_idx = 0;
+	u8 value = 0;
+	u32 offset = 0;
+	u32 polling_count = 0;
+	u32 max_polling_cnt = 5000;
+
+	do {
+		pwr_cfg_cmd = pwrcfgcmd[ary_idx];
+		RT_TRACE(COMP_INIT, DBG_TRACE,
+			 ("offset(%#x), cut_msk(%#x), fab_msk(%#x), interface_msk(%#x), base(%#x), cmd(%#x), msk(%#x), value(%#x)\n",
+			  GET_PWR_CFG_OFFSET(pwr_cfg_cmd),
+			  GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd),
+			  GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd),
+			  GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd),
+			  GET_PWR_CFG_BASE(pwr_cfg_cmd),
+			  GET_PWR_CFG_CMD(pwr_cfg_cmd),
+			  GET_PWR_CFG_MASK(pwr_cfg_cmd),
+			  GET_PWR_CFG_VALUE(pwr_cfg_cmd)));
+
+		if ((GET_PWR_CFG_FAB_MASK(pwr_cfg_cmd)&fab_version) &&
+		    (GET_PWR_CFG_CUT_MASK(pwr_cfg_cmd)&cut_version) &&
+		    (GET_PWR_CFG_INTF_MASK(pwr_cfg_cmd)&interface_type)) {
+			switch (GET_PWR_CFG_CMD(pwr_cfg_cmd)) {
+			case PWR_CMD_READ:
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("PWR_CMD_READ\n"));
+				break;
+
+			case PWR_CMD_WRITE:
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("PWR_CMD_WRITE\n"));
+				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
+
+				/*Read the value from system register*/
+				value = rtl_read_byte(rtlpriv, offset);
+				value &= (~(GET_PWR_CFG_MASK(pwr_cfg_cmd)));
+				value |= (GET_PWR_CFG_VALUE(pwr_cfg_cmd) &
+					  GET_PWR_CFG_MASK(pwr_cfg_cmd));
+
+				/*Write value back to sytem register*/
+				rtl_write_byte(rtlpriv, offset, value);
+				break;
+
+			case PWR_CMD_POLLING:
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("PWR_CMD_POLLING\n"));
+				b_polling_bit = false;
+				offset = GET_PWR_CFG_OFFSET(pwr_cfg_cmd);
+
+				do {
+					value = rtl_read_byte(rtlpriv, offset);
+
+					value &= GET_PWR_CFG_MASK(pwr_cfg_cmd);
+					if (value ==
+					    (GET_PWR_CFG_VALUE(pwr_cfg_cmd) &
+					     GET_PWR_CFG_MASK(pwr_cfg_cmd)))
+						b_polling_bit = true;
+					else
+						udelay(10);
+
+					if (polling_count++ > max_polling_cnt) {
+						RT_TRACE(COMP_INIT, DBG_LOUD,
+							 ("polling fail\n"));
+						return false;
+					}
+				} while (!b_polling_bit);
+
+				break;
+
+			case PWR_CMD_DELAY:
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("PWR_CMD_DELAY\n"));
+				if (GET_PWR_CFG_VALUE(pwr_cfg_cmd) ==
+				    PWRSEQ_DELAY_US)
+					udelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
+				else
+					mdelay(GET_PWR_CFG_OFFSET(pwr_cfg_cmd));
+				break;
+
+			case PWR_CMD_END:
+				RT_TRACE(COMP_INIT, DBG_TRACE,
+					 ("PWR_CMD_END\n"));
+				return true;
+				break;
+
+			default:
+				RT_ASSERT(false, ("Unknown CMD!!\n"));
+				break;
+			}
+		}
+
+		ary_idx++;
+	} while (1);
+	return true;
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h b/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h
new file mode 100644
index 0000000..ec40ea8
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h
@@ -0,0 +1,69 @@
+#ifndef __RTL92E_PWRSEQCMD_H__
+#define __RTL92E_PWRSEQCMD_H__
+
+#include "../wifi.h"
+/*---------------------------------------------*/
+/* The value of cmd: 4 bits */
+/*---------------------------------------------*/
+#define	PWR_CMD_READ		0x00
+#define PWR_CMD_WRITE		0x01
+#define PWR_CMD_POLLING		0x02
+#define PWR_CMD_DELAY		0x03
+#define PWR_CMD_END		0x04
+
+/* define the base address of each block */
+#define PWR_BASEADDR_MAC	0x00
+#define PWR_BASEADDR_USB	0x01
+#define PWR_BASEADDR_PCIE	0x02
+#define PWR_BASEADDR_SDIO	0x03
+
+#define	PWR_INTF_SDIO_MSK	BIT(0)
+#define	PWR_INTF_USB_MSK	BIT(1)
+#define	PWR_INTF_PCI_MSK	BIT(2)
+#define	PWR_INTF_ALL_MSK	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
+
+#define	PWR_FAB_TSMC_MSK	BIT(0)
+#define	PWR_FAB_UMC_MSK		BIT(1)
+#define	PWR_FAB_ALL_MSK		(BIT(0) | BIT(1) | BIT(2) | BIT(3))
+
+#define	PWR_CUT_TESTCHIP_MSK	BIT(0)
+#define	PWR_CUT_A_MSK		BIT(1)
+#define	PWR_CUT_B_MSK		BIT(2)
+#define	PWR_CUT_C_MSK		BIT(3)
+#define	PWR_CUT_D_MSK		BIT(4)
+#define	PWR_CUT_E_MSK		BIT(5)
+#define	PWR_CUT_F_MSK		BIT(6)
+#define	PWR_CUT_G_MSK		BIT(7)
+#define	PWR_CUT_ALL_MSK		0xFF
+
+
+enum pwrseq_delay_unit {
+	PWRSEQ_DELAY_US,
+	PWRSEQ_DELAY_MS,
+};
+
+struct wlan_pwr_cfg {
+	u16 offset;
+	u8 cut_msk;
+	u8 fab_msk:4;
+	u8 interface_msk:4;
+	u8 base:4;
+	u8 cmd:4;
+	u8 msk;
+	u8 value;
+};
+
+#define	GET_PWR_CFG_OFFSET(__PWR_CMD)		__PWR_CMD.offset
+#define	GET_PWR_CFG_CUT_MASK(__PWR_CMD)		__PWR_CMD.cut_msk
+#define	GET_PWR_CFG_FAB_MASK(__PWR_CMD)		__PWR_CMD.fab_msk
+#define	GET_PWR_CFG_INTF_MASK(__PWR_CMD)	__PWR_CMD.interface_msk
+#define	GET_PWR_CFG_BASE(__PWR_CMD)		__PWR_CMD.base
+#define	GET_PWR_CFG_CMD(__PWR_CMD)		__PWR_CMD.cmd
+#define	GET_PWR_CFG_MASK(__PWR_CMD)		__PWR_CMD.msk
+#define	GET_PWR_CFG_VALUE(__PWR_CMD)		__PWR_CMD.value
+
+bool rtl92e_hal_pwrseqcmdparsing(struct rtl_priv *rtlpriv, u8 cut_version,
+			      u8 fab_version, u8 interface_type,
+			      struct wlan_pwr_cfg pwrcfgcmd[]);
+
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/reg.h b/drivers/staging/rtl8192ee/rtl8192ee/reg.h
new file mode 100644
index 0000000..08c0757
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/reg.h
@@ -0,0 +1,2240 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_REG_H__
+#define __RTL92E_REG_H__
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
+#define REG_SYS_SWR_CTRL1			0x0010
+#define REG_SPS0_CTRL				0x0011
+#define REG_SYS_SWR_CTRL2			0x0014
+#define REG_SYS_SWR_CTRL3			0x0018
+#define REG_RSV_CTRL				0x001C
+#define REG_RF_CTRL				0x001F
+#define REG_LPLDO_CTRL				0x0023
+#define REG_AFE_CTRL1				0x0024
+#define REG_AFE_XTAL_CTRL			0x0024
+#define REG_AFE_CTRL2				0x0028
+#define REG_MAC_PHY_CTRL			0x002c
+#define REG_AFE_CTRL3				0x002c
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
+#define REG_SDIO_CTRL				0x0070
+#define REG_OPT_CTRL				0x0074
+#define REG_GPIO_OUTPUT				0x006c
+#define REG_AFE_CTRL4				0x0078
+#define REG_MCUFWDL				0x0080
+
+#define REG_HIMR				0x00B0
+#define REG_HISR				0x00B4
+#define REG_HIMRE				0x00B8
+#define REG_HISRE				0x00BC
+
+#define REG_EFUSE_ACCESS			0x00CF
+#define REG_HPON_FSM				0x00EC
+#define REG_SYS_CFG1				0x00F0
+#define REG_SYS_CFG2				0x00FC
+
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
+#define REG_PKTBUF_DBG_CTRL			0x0140
+#define REG_RXPKTBUF_CTRL			0x0142
+#define REG_PKTBUF_DBG_DATA_L			0x0144
+#define REG_PKTBUF_DBG_DATA_H			0x0148
+
+#define REG_TC0_CTRL				0x0150
+#define REG_TC1_CTRL				0x0154
+#define REG_TC2_CTRL				0x0158
+#define REG_TC3_CTRL				0x015C
+#define REG_TC4_CTRL				0x0160
+#define REG_TCUNIT_BASE				0x0164
+#define REG_RSVD3				0x0168
+#define REG_C2HEVT_MSG_NORMAL			0x01A0
+#define REG_C2HEVT_CLEAR			0x01AF
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
+
+#define REG_HMEBOX_EXT_0			0x01F0
+#define REG_HMEBOX_EXT_1			0x01F4
+#define REG_HMEBOX_EXT_2			0x01F8
+#define REG_HMEBOX_EXT_3			0x01FC
+
+/*-----------------------------------------------------
+ *
+ *	0x0200h ~ 0x027Fh	TXDMA Configuration
+ *
+ *-----------------------------------------------------*/
+#define REG_RQPN				0x0200
+#define REG_FIFOPAGE				0x0204
+#define REG_DWBCN0_CTRL				0x0208
+#define REG_TXDMA_OFFSET_CHK			0x020C
+#define REG_TXDMA_STATUS			0x0210
+#define REG_RQPN_NPQ				0x0214
+#define REG_AUTO_LLT				0x0224
+#define REG_DWBCN1_CTRL				0x0228
+
+/*-----------------------------------------------------
+ *
+ *	0x0280h ~ 0x02FFh	RXDMA Configuration
+ *
+ *-----------------------------------------------------*/
+#define REG_RXDMA_AGG_PG_TH			0x0280
+#define REG_FW_UPD_RDPTR			0x0284
+#define REG_RXDMA_CONTROL			0x0286
+#define REG_RXPKT_NUM				0x0287
+#define REG_RXDMA_STATUS			0x0288
+#define REG_RXDMA_PRO				0x0290
+#define REG_EARLY_MODE_CONTROL			0x02BC
+#define REG_RSVD5				0x02F0
+#define REG_RSVD6				0x02F4
+
+/*-----------------------------------------------------
+ *
+ *	0x0300h ~ 0x03FFh	PCIe
+ *
+ *-----------------------------------------------------*/
+#define	REG_PCIE_CTRL_REG			0x0300
+#define	REG_INT_MIG				0x0304
+#define	REG_BCNQ_DESA				0x0308
+#define	REG_MGQ_DESA				0x0310
+#define	REG_VOQ_DESA				0x0318
+#define	REG_VIQ_DESA				0x0320
+#define	REG_BEQ_DESA				0x0328
+#define	REG_BKQ_DESA				0x0330
+#define	REG_RX_DESA				0x0338
+#define	REG_HQ0_DESA				0x0340
+#define	REG_HQ1_DESA				0x0348
+#define	REG_HQ2_DESA				0x0350
+#define	REG_HQ3_DESA				0x0358
+#define	REG_HQ4_DESA				0x0360
+#define	REG_HQ5_DESA				0x0368
+#define	REG_HQ6_DESA				0x0370
+#define	REG_HQ7_DESA				0x0378
+#define	REG_MGQ_TXBD_NUM			0x0380
+#define	REG_RX_RXBD_NUM				0x0382
+#define	REG_VOQ_TXBD_NUM			0x0384
+#define	REG_VIQ_TXBD_NUM			0x0386
+#define	REG_BEQ_TXBD_NUM			0x0388
+#define	REG_BKQ_TXBD_NUM			0x038A
+#define	REG_HI0Q_TXBD_NUM			0x038C
+#define	REG_HI1Q_TXBD_NUM			0x038E
+#define	REG_HI2Q_TXBD_NUM			0x0390
+#define	REG_HI3Q_TXBD_NUM			0x0392
+#define	REG_HI4Q_TXBD_NUM			0x0394
+#define	REG_HI5Q_TXBD_NUM			0x0396
+#define	REG_HI6Q_TXBD_NUM			0x0398
+#define	REG_HI7Q_TXBD_NUM			0x039A
+#define	REG_TSFTIMER_HCI			0x039C
+/*Read Write Point*/
+#define	REG_VOQ_TXBD_IDX			0x03A0
+#define	REG_VIQ_TXBD_IDX			0x03A4
+#define	REG_BEQ_TXBD_IDX			0x03A8
+#define	REG_BKQ_TXBD_IDX			0x03AC
+#define	REG_MGQ_TXBD_IDX			0x03B0
+#define	REG_RXQ_TXBD_IDX			0x03B4
+
+#define	REG_HI0Q_TXBD_IDX			0x03B8
+#define	REG_HI1Q_TXBD_IDX			0x03BC
+#define	REG_HI2Q_TXBD_IDX			0x03C0
+#define	REG_HI3Q_TXBD_IDX			0x03C4
+
+#define	REG_HI4Q_TXBD_IDX			0x03C8
+#define	REG_HI5Q_TXBD_IDX			0x03CC
+#define	REG_HI6Q_TXBD_IDX			0x03D0
+#define	REG_HI7Q_TXBD_IDX			0x03D4
+#define	REG_PCIE_HCPWM				0x03D8
+#define	REG_PCIE_CTRL2				0x03DB
+#define	REG_PCIE_HRPWM				0x03DC
+#define	REG_H2C_MSG_DRV2FW_INFO			0x03E0
+#define	REG_PCIE_C2H_MSG_REQUEST		0x03E4
+#define	REG_BACKDOOR_DBI_WDATA			0x03E8
+#define	REG_BACKDOOR_DBI_RDATA			0x03EC
+#define	REG_BACKDOOR_DBI_DATA			0x03F0
+#define	REG_MDIO				0x03F4
+#define	REG_MDIO_DATA				0x03F8
+
+#define	REG_HDAQ_DESA_NODEF			0x0000
+#define	REG_CMDQ_DESA_NODEF			0x0000
+/* spec version 11
+ *-----------------------------------------------------
+ *
+ *	0x0400h ~ 0x047Fh	Protocol Configuration
+ *
+ *-----------------------------------------------------*/
+#define REG_VOQ_INFORMATION			0x0400
+#define REG_VIQ_INFORMATION			0x0404
+#define REG_BEQ_INFORMATION			0x0408
+#define REG_BKQ_INFORMATION			0x040C
+#define REG_MGQ_INFORMATION			0x0410
+#define REG_HGQ_INFORMATION			0x0414
+#define REG_BCNQ_INFORMATION			0x0418
+#define REG_TXPKT_EMPTY				0x041A
+
+
+#define REG_FWHW_TXQ_CTRL			0x0420
+#define REG_HWSEQ_CTRL				0x0423
+#define REG_BCNQ_BDNY				0x0424
+#define REG_MGQ_BDNY				0x0425
+#define REG_LIFECTRL_CTRL			0x0426
+#define REG_MULTI_BCNQ_OFFSET			0x0427
+#define REG_SPEC_SIFS				0x0428
+#define REG_RETRY_LIMIT				0x042A
+#define REG_TXBF_CTRL				0x042C
+#define REG_DARFRC				0x0430
+#define REG_RARFRC				0x0438
+#define REG_RRSR				0x0440
+#define REG_ARFR0				0x0444
+#define REG_ARFR1				0x044C
+#define REG_AMPDU_MAX_TIME			0x0456
+#define REG_BCNQ1_BDNY				0x0457
+#define REG_AGGLEN_LMT				0x0458
+#define REG_AMPDU_MIN_SPACE			0x045C
+#define REG_TXPKTBUF_WMAC_LBK_BF_HD		0x045D
+#define REG_NDPA_OPT_CTRL			0x045F
+#define REG_FAST_EDCA_CTRL			0x0460
+#define REG_RD_RESP_PKT_TH			0x0463
+#define REG_POWER_STAGE1			0x04B4
+#define REG_POWER_STAGE2			0x04B8
+#define REG_AMPDU_BURST_MODE			0x04BC
+#define REG_PKT_VO_VI_LIFE_TIME			0x04C0
+#define REG_PKT_BE_BK_LIFE_TIME			0x04C2
+#define REG_STBC_SETTING			0x04C4
+#define REG_PROT_MODE_CTRL			0x04C8
+#define REG_MAX_AGGR_NUM			0x04CA
+#define REG_RTS_MAX_AGGR_NUM			0x04CB
+#define REG_BAR_MODE_CTRL			0x04CC
+#define REG_RA_TRY_RATE_AGG_LMT			0x04CF
+#define REG_MACID_PKT_DROP0			0x04D0
+
+/*-----------------------------------------------------
+ *
+ *	0x0500h ~ 0x05FFh	EDCA Configuration
+ *
+ *-----------------------------------------------------*/
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
+
+#define REG_TBTT_PROHIBIT			0x0540
+#define REG_RD_NAV_NXT				0x0544
+#define REG_NAV_PROT_LEN			0x0546
+#define REG_BCN_CTRL				0x0550
+#define REG_BCN_CTRL_1				0x0551
+#define REG_MBID_NUM				0x0552
+#define REG_DUAL_TSF_RST			0x0553
+#define REG_BCN_INTERVAL			0x0554
+#define REG_DRVERLYINT				0x0558
+#define REG_BCNDMATIM				0x0559
+#define REG_ATIMWND				0x055A
+#define REG_BCN_MAX_ERR				0x055D
+#define REG_RXTSF_OFFSET_CCK			0x055E
+#define REG_RXTSF_OFFSET_OFDM			0x055F
+#define REG_TSFTR				0x0560
+#define REG_CTWND				0x0572
+#define REG_PSTIMER				0x0580
+#define REG_TIMER0				0x0584
+#define REG_TIMER1				0x0588
+#define REG_BCN_PREDL_ITV			0x058F
+#define REG_ACMHWCTRL				0x05C0
+
+/*-----------------------------------------------------
+ *
+ *	0x0600h ~ 0x07FFh	WMAC Configuration
+ *
+ *-----------------------------------------------------*/
+#define REG_MAC_CR				0x0600
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
+#define	REG_NAV_UPPER				0x0652
+
+/* Security*/
+#define REG_CAMCMD				0x0670
+#define REG_CAMWRITE				0x0674
+#define REG_CAMREAD				0x0678
+#define REG_CAMDBG				0x067C
+#define REG_SECCFG				0x0680
+
+/* Power*/
+#define REG_WOW_CTRL				0x0690
+#define REG_PS_RX_INFO				0x0692
+#define REG_UAPSD_TID				0x0693
+#define REG_WKFMCAM_NUM				0x0698
+#define REG_WKFMCAM_RWD				0x069C
+#define REG_RXFLTMAP0				0x06A0
+#define REG_RXFLTMAP1				0x06A2
+#define REG_RXFLTMAP2				0x06A4
+#define REG_BCN_PSR_RPT				0x06A8
+#define REG_BT_COEX_TABLE			0x06C0
+#define REG_BFMER0_INFO				0x06E4
+#define REG_BFMER1_INFO				0x06EC
+#define REG_CSI_RPT_PARAM_BW20			0x06F4
+#define REG_CSI_RPT_PARAM_BW40			0x06F8
+#define REG_CSI_RPT_PARAM_BW80			0x06FC
+/* Hardware Port 2*/
+#define REG_MACID1				0x0700
+#define REG_BSSID1				0x0708
+#define REG_BFMEE_SEL				0x0714
+#define REG_SND_PTCL_CTRL			0x0718
+
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
+#define	AUTOLOAD_EEPROM				(CMDEEPROM_EN | CMDEEPROM_SEL)
+#define	AUTOLOAD_EFUSE				CMDEEPROM_EN
+
+#define	GPIOSEL_GPIO				0
+#define	GPIOSEL_ENBT				BIT(5)
+
+#define	GPIO_IN					REG_GPIO_PIN_CTRL
+#define	GPIO_OUT				(REG_GPIO_PIN_CTRL + 1)
+#define	GPIO_IO_SEL				(REG_GPIO_PIN_CTRL + 2)
+#define	GPIO_MOD				(REG_GPIO_PIN_CTRL + 3)
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
+				 RATR_24M | RATR_36M | RATR_48M | RATR_54M)
+#define	RATE_ALL_OFDM_1SS	(RATR_MCS0 | RATR_MCS1 | RATR_MCS2 |\
+				 RATR_MCS3 | RATR_MCS4 | RATR_MCS5 |\
+				 RATR_MCS6 | RATR_MCS7)
+#define	RATE_ALL_OFDM_2SS	(RATR_MCS8 | RATR_MCS9 | RATR_MCS10 |\
+				 RATR_MCS11 | RATR_MCS12 | RATR_MCS13 |\
+				 RATR_MCS14 | RATR_MCS15)
+
+#define	BW_OPMODE_20MHZ				BIT(2)
+#define	BW_OPMODE_5G				BIT(1)
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
+
+/*********************************************
+*       8192EE IMR/ISR bits
+**********************************************/
+#define	IMR_DISABLED				0x0
+/* IMR DW0(0x0060-0063) Bit 0-31 */
+#define	IMR_TIMER2				BIT(31)
+#define	IMR_TIMER1				BIT(30)
+#define	IMR_PSTIMEOUT				BIT(29)
+#define	IMR_GTINT4				BIT(28)
+#define	IMR_GTINT3				BIT(27)
+#define	IMR_TBDER				BIT(26)
+#define	IMR_TBDOK				BIT(25)
+#define	IMR_TSF_BIT32_TOGGLE			BIT(24)
+#define	IMR_BCNDMAINT0				BIT(20)
+#define	IMR_BCNDOK0				BIT(16)
+#define	IMR_BCNDMAINT_E				BIT(14)
+#define	IMR_ATIMEND				BIT(12)
+#define	IMR_HISR1_IND_INT			BIT(11)
+#define	IMR_C2HCMD				BIT(10)
+#define	IMR_CPWM2				BIT(9)
+#define	IMR_CPWM				BIT(8)
+#define	IMR_HIGHDOK				BIT(7)
+#define	IMR_MGNTDOK				BIT(6)
+#define	IMR_BKDOK				BIT(5)
+#define	IMR_BEDOK				BIT(4)
+#define	IMR_VIDOK				BIT(3)
+#define	IMR_VODOK				BIT(2)
+#define	IMR_RDU					BIT(1)
+#define	IMR_ROK					BIT(0)
+
+/* IMR DW1(0x00B4-00B7) Bit 0-31 */
+#define	IMR_MCUERR				BIT(28)
+#define	IMR_BCNDMAINT7				BIT(27)
+#define	IMR_BCNDMAINT6				BIT(26)
+#define	IMR_BCNDMAINT5				BIT(25)
+#define	IMR_BCNDMAINT4				BIT(24)
+#define	IMR_BCNDMAINT3				BIT(23)
+#define	IMR_BCNDMAINT2				BIT(22)
+#define	IMR_BCNDMAINT1				BIT(21)
+#define	IMR_BCNDOK7				BIT(20)
+#define	IMR_BCNDOK6				BIT(19)
+#define	IMR_BCNDOK5				BIT(18)
+#define	IMR_BCNDOK4				BIT(17)
+#define	IMR_BCNDOK3				BIT(16)
+#define	IMR_BCNDOK2				BIT(15)
+#define	IMR_BCNDOK1				BIT(14)
+#define	IMR_ATIMEND_E				BIT(13)
+#define	IMR_TXERR				BIT(11)
+#define	IMR_RXERR				BIT(10)
+#define	IMR_TXFOVW				BIT(9)
+#define	IMR_RXFOVW				BIT(8)
+
+
+#define	HWSET_MAX_SIZE				512
+#define EFUSE_MAX_SECTION			64
+#define EFUSE_REAL_CONTENT_LEN			256
+#define EFUSE_OOB_PROTECT_BYTES			18
+
+
+#define	EEPROM_DEFAULT_TSSI			0x0
+#define EEPROM_DEFAULT_TXPOWERDIFF		0x0
+#define EEPROM_DEFAULT_CRYSTALCAP		0x5
+#define EEPROM_DEFAULT_BOARDTYPE		0x02
+#define EEPROM_DEFAULT_TXPOWER			0x1010
+#define	EEPROM_DEFAULT_HT2T_TXPWR		0x10
+
+#define	EEPROM_DEFAULT_LEGACYHTTXPOWERDIFF	0x3
+#define	EEPROM_DEFAULT_THERMALMETER		0x1A
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
+#define RF_OPTION4				0x7C
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
+#define	RTL8192E_EEPROM_ID			0x8129
+
+#define EEPROM_HPON				0x02
+#define EEPROM_CLK				0x06
+#define EEPROM_TESTR				0x08
+
+
+#define EEPROM_TXPOWERCCK			0x10
+#define	EEPROM_TXPOWERHT40_1S			0x16
+#define EEPROM_TXPOWERHT20DIFF			0x1B
+#define EEPROM_TXPOWER_OFDMDIFF			0x1B
+
+
+
+#define	EEPROM_TX_PWR_INX			0x10
+
+#define	EEPROM_CHANNELPLAN			0xB8
+#define	EEPROM_XTAL_92E				0xB9
+#define	EEPROM_THERMAL_METER_92E		0xBA
+#define	EEPROM_IQK_LCK_92E			0xBB
+
+#define	EEPROM_RF_BOARD_OPTION_92E		0xC1
+#define	EEPROM_RF_FEATURE_OPTION_92E		0xC2
+#define	EEPROM_RF_BT_SETTING_92E		0xC3
+#define	EEPROM_VERSION				0xC4
+#define	EEPROM_CUSTOMER_ID			0xC5
+#define	EEPROM_RF_ANTENNA_OPT_92E		0xC9
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
+#define FEN_BB_GLB_RSTn				BIT(1)
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
+#define EnPDN					BIT(4)
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
+#define Timer_EN				BIT(4)
+
+#define TRSW0EN					BIT(2)
+#define TRSW1EN					BIT(3)
+#define EROM_EN					BIT(4)
+#define EnBT					BIT(5)
+#define EnUart					BIT(8)
+#define Uart_910				BIT(9)
+#define EnPMAC					BIT(10)
+#define SIC_SWRST				BIT(11)
+#define EnSIC					BIT(12)
+#define SIC_23					BIT(13)
+#define EnHDP					BIT(14)
+#define SIC_LBK					BIT(15)
+
+#define LED0PL					BIT(4)
+#define LED1PL					BIT(12)
+#define LED0DIS					BIT(7)
+
+#define MCUFWDL_EN				BIT(0)
+#define MCUFWDL_RDY				BIT(1)
+#define FWDL_ChkSum_rpt				BIT(2)
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
+#define GET_RX_PAGE_SIZE(value)			((value) & 0xF)
+#define GET_TX_PAGE_SIZE(value)			(((value) & 0xF0) >> 4)
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
+#define _LLT_OP(x)					(((x) & 0x3) << 30)
+#define _LLT_OP_VALUE(x)			(((x) >> 30) & 0x3)
+
+#define BB_WRITE_READ_MASK			(BIT(31) | BIT(30))
+#define BB_WRITE_EN				BIT(30)
+#define BB_READ_EN				BIT(31)
+
+#define _HPQ(x)					((x) & 0xFF)
+#define _LPQ(x)					(((x) & 0xFF) << 8)
+#define _PUBQ(x)				(((x) & 0xFF) << 16)
+#define _NPQ(x)					((x) & 0xFF)
+
+#define HPQ_PUBLIC_DIS				BIT(24)
+#define LPQ_PUBLIC_DIS				BIT(25)
+#define LD_RQPN					BIT(31)
+
+#define BCN_VALID				BIT(16)
+#define BCN_HEAD(x)				(((x) & 0xFF) << 8)
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
+#define	RETRY_LIMIT_SHORT_SHIFT			8
+#define	RETRY_LIMIT_LONG_SHIFT			0
+
+#define _DARF_RC1(x)				((x) & 0x1F)
+#define _DARF_RC2(x)				(((x) & 0x1F) << 8)
+#define _DARF_RC3(x)				(((x) & 0x1F) << 16)
+#define _DARF_RC4(x)				(((x) & 0x1F) << 24)
+#define _DARF_RC5(x)				((x) & 0x1F)
+#define _DARF_RC6(x)				(((x) & 0x1F) << 8)
+#define _DARF_RC7(x)				(((x) & 0x1F) << 16)
+#define _DARF_RC8(x)				(((x) & 0x1F) << 24)
+
+#define _RARF_RC1(x)				((x) & 0x1F)
+#define _RARF_RC2(x)				(((x) & 0x1F) << 8)
+#define _RARF_RC3(x)				(((x) & 0x1F) << 16)
+#define _RARF_RC4(x)				(((x) & 0x1F) << 24)
+#define _RARF_RC5(x)				((x) & 0x1F)
+#define _RARF_RC6(x)				(((x) & 0x1F) << 8)
+#define _RARF_RC7(x)				(((x) & 0x1F) << 16)
+#define _RARF_RC8(x)				(((x) & 0x1F) << 24)
+
+#define AC_PARAM_TXOP_LIMIT_OFFSET		16
+#define AC_PARAM_ECW_MAX_OFFSET			12
+#define AC_PARAM_ECW_MIN_OFFSET			8
+#define AC_PARAM_AIFS_OFFSET			0
+
+#define _AIFS(x)				(x)
+#define _ECW_MAX_MIN(x)				((x) << 8)
+#define _TXOP_LIMIT(x)				((x) << 16)
+
+#define _BCNIFS(x)				((x) & 0xFF)
+#define _BCNECW(x)				((((x) & 0xF)) << 8)
+
+#define _LRL(x)					((x) & 0x3F)
+#define _SRL(x)					(((x) & 0x3F) << 8)
+
+#define _SIFS_CCK_CTX(x)			((x) & 0xFF)
+#define _SIFS_CCK_TRX(x)			(((x) & 0xFF) << 8);
+
+#define _SIFS_OFDM_CTX(x)			((x) & 0xFF)
+#define _SIFS_OFDM_TRX(x)			(((x) & 0xFF) << 8);
+
+#define _TBTT_PROHIBIT_HOLD(x)			(((x) & 0xFF) << 8)
+
+#define DIS_EDCA_CNT_DWN			BIT(11)
+
+#define EN_MBSSID				BIT(1)
+#define EN_TXBCN_RPT				BIT(2)
+#define	EN_BCN_FUNCTION				BIT(3)
+
+#define TSFTR_RST				BIT(0)
+#define TSFTR1_RST				BIT(1)
+
+#define STOP_BCNQ				BIT(6)
+
+#define	DIS_TSF_UDT0_NORMAL_CHIP		BIT(4)
+#define	DIS_TSF_UDT0_TEST_CHIP			BIT(5)
+
+#define	AcmHw_HwEn				BIT(0)
+#define	AcmHw_BeqEn				BIT(1)
+#define	AcmHw_ViqEn				BIT(2)
+#define	AcmHw_VoqEn				BIT(3)
+#define	AcmHw_BeqStatus				BIT(4)
+#define	AcmHw_ViqStatus				BIT(5)
+#define	AcmHw_VoqStatus				BIT(6)
+
+#define APSDOFF					BIT(6)
+#define APSDOFF_STATUS				BIT(7)
+
+#define BW_20MHZ				BIT(2)
+
+#define RATE_BITMAP_ALL				0xFFFFF
+
+#define RATE_RRSR_CCK_ONLY_1M			0xFFFF1
+
+#define TSFRST					BIT(0)
+#define DIS_GCLK				BIT(1)
+#define PAD_SEL					BIT(2)
+#define PWR_ST					BIT(6)
+#define PWRBIT_OW_EN				BIT(7)
+#define ACRC					BIT(8)
+#define CFENDFORM				BIT(9)
+#define ICV					BIT(10)
+
+#define AAP					BIT(0)
+#define APM					BIT(1)
+#define AM					BIT(2)
+#define AB					BIT(3)
+#define ADD3					BIT(4)
+#define APWRMGT					BIT(5)
+#define CBSSID					BIT(6)
+#define CBSSID_DATA				BIT(6)
+#define CBSSID_BCN				BIT(7)
+#define ACRC32					BIT(8)
+#define AICV					BIT(9)
+#define ADF					BIT(11)
+#define ACF					BIT(12)
+#define AMF					BIT(13)
+#define HTC_LOC_CTRL				BIT(14)
+#define UC_DATA_EN				BIT(16)
+#define BM_DATA_EN				BIT(17)
+#define MFBEN					BIT(22)
+#define LSIGEN					BIT(23)
+#define EnMBID					BIT(24)
+#define APP_BASSN				BIT(27)
+#define APP_PHYSTS				BIT(28)
+#define APP_ICV					BIT(29)
+#define APP_MIC					BIT(30)
+#define APP_FCS					BIT(31)
+
+#define _MIN_SPACE(x)				((x) & 0x7)
+#define _SHORT_GI_PADDING(x)			(((x) & 0x1F) << 3)
+
+#define RXERR_TYPE_OFDM_PPDU			0
+#define RXERR_TYPE_OFDM_FALSE_ALARM		1
+#define	RXERR_TYPE_OFDM_MPDU_OK			2
+#define RXERR_TYPE_OFDM_MPDU_FAIL		3
+#define RXERR_TYPE_CCK_PPDU			4
+#define RXERR_TYPE_CCK_FALSE_ALARM		5
+#define RXERR_TYPE_CCK_MPDU_OK			6
+#define RXERR_TYPE_CCK_MPDU_FAIL		7
+#define RXERR_TYPE_HT_PPDU			8
+#define RXERR_TYPE_HT_FALSE_ALARM		9
+#define RXERR_TYPE_HT_MPDU_TOTAL		10
+#define RXERR_TYPE_HT_MPDU_OK			11
+#define RXERR_TYPE_HT_MPDU_FAIL			12
+#define RXERR_TYPE_RX_FULL_DROP			15
+
+#define RXERR_COUNTER_MASK			0xFFFFF
+#define RXERR_RPT_RST				BIT(27)
+#define _RXERR_RPT_SEL(type)			((type) << 28)
+
+#define	SCR_TxUseDK				BIT(0)
+#define	SCR_RxUseDK				BIT(1)
+#define	SCR_TxEncEnable				BIT(2)
+#define	SCR_RxDecEnable				BIT(3)
+#define	SCR_SKByA2				BIT(4)
+#define	SCR_NoSKMC				BIT(5)
+#define SCR_TXBCUSEDK				BIT(6)
+#define SCR_RXBCUSEDK				BIT(7)
+
+#define USB_IS_HIGH_SPEED			0
+#define USB_IS_FULL_SPEED			1
+#define USB_SPEED_MASK				BIT(5)
+
+#define USB_NORMAL_SIE_EP_MASK			0xF
+#define USB_NORMAL_SIE_EP_SHIFT			4
+
+#define USB_TEST_EP_MASK			0x30
+#define USB_TEST_EP_SHIFT			4
+
+#define USB_AGG_EN				BIT(3)
+
+#define MAC_ADDR_LEN				6
+#define LAST_ENTRY_OF_TX_PKT_BUFFER		175
+
+#define POLLING_LLT_THRESHOLD			20
+#define POLLING_READY_TIMEOUT_COUNT		3000
+
+#define	MAX_MSS_DENSITY_2T			0x13
+#define	MAX_MSS_DENSITY_1T			0x0A
+
+#define EPROM_CMD_OPERATING_MODE_MASK		((1 << 7) | (1 << 6))
+#define EPROM_CMD_CONFIG			0x3
+#define EPROM_CMD_LOAD				1
+
+#define	HWSET_MAX_SIZE_92S			HWSET_MAX_SIZE
+
+#define	HAL_8192C_HW_GPIO_WPS_BIT		BIT(2)
+
+#define	RPMAC_RESET				0x100
+#define	RPMAC_TXSTART				0x104
+#define	RPMAC_TXLEGACYSIG			0x108
+#define	RPMAC_TXHTSIG1				0x10c
+#define	RPMAC_TXHTSIG2				0x110
+#define	RPMAC_PHYDEBUG				0x114
+#define	RPMAC_TXPACKETNUM			0x118
+#define	RPMAC_TXIDLE				0x11c
+#define	RPMAC_TXMACHEADER0			0x120
+#define	RPMAC_TXMACHEADER1			0x124
+#define	RPMAC_TXMACHEADER2			0x128
+#define	RPMAC_TXMACHEADER3			0x12c
+#define	RPMAC_TXMACHEADER4			0x130
+#define	RPMAC_TXMACHEADER5			0x134
+#define	RPMAC_TXDADATYPE			0x138
+#define	RPMAC_TXRANDOMSEED			0x13c
+#define	RPMAC_CCKPLCPPREAMBLE			0x140
+#define	RPMAC_CCKPLCPHEADER			0x144
+#define	RPMAC_CCKCRC16				0x148
+#define	RPMAC_OFDMRXCRC32OK			0x170
+#define	RPMAC_OFDMRXCRC32Er			0x174
+#define	RPMAC_OFDMRXPARITYER			0x178
+#define	RPMAC_OFDMRXCRC8ER			0x17c
+#define	RPMAC_CCKCRXRC16ER			0x180
+#define	RPMAC_CCKCRXRC32ER			0x184
+#define	RPMAC_CCKCRXRC32OK			0x188
+#define	RPMAC_TXSTATUS				0x18c
+
+#define	RFPGA0_RFMOD				0x800
+
+#define	RFPGA0_TXINFO				0x804
+#define	RFPGA0_PSDFUNCTION			0x808
+
+#define	RFPGA0_TXGAINSTAGE			0x80c
+
+#define	RFPGA0_RFTIMING1			0x810
+#define	RFPGA0_RFTIMING2			0x814
+
+#define	RFPGA0_XA_HSSIPARAMETER1		0x820
+#define	RFPGA0_XA_HSSIPARAMETER2		0x824
+#define	RFPGA0_XB_HSSIPARAMETER1		0x828
+#define	RFPGA0_XB_HSSIPARAMETER2		0x82c
+
+#define	RFPGA0_XA_LSSIPARAMETER			0x840
+#define	RFPGA0_XB_LSSIPARAMETER			0x844
+
+#define	RFPGA0_RFWAKEUPPARAMETER		0x850
+#define	RFPGA0_RFSLEEPUPPARAMETER		0x854
+
+#define	RFPGA0_XAB_SWITCHCONTROL		0x858
+#define	RFPGA0_XCD_SWITCHCONTROL		0x85c
+
+#define	RFPGA0_XA_RFINTERFACEOE			0x860
+#define	RFPGA0_XB_RFINTERFACEOE			0x864
+
+#define	RFPGA0_XAB_RFINTERFACESW		0x870
+#define	RFPGA0_XCD_RFINTERFACESW		0x874
+
+#define	rFPGA0_XAB_RFPARAMETER			0x878
+#define	rFPGA0_XCD_RFPARAMETER			0x87c
+
+#define	RFPGA0_ANALOGPARAMETER1			0x880
+#define	RFPGA0_ANALOGPARAMETER2			0x884
+#define	RFPGA0_ANALOGPARAMETER3			0x888
+#define	RFPGA0_ANALOGPARAMETER4			0x88c
+
+#define	RFPGA0_XA_LSSIREADBACK			0x8a0
+#define	RFPGA0_XB_LSSIREADBACK			0x8a4
+#define	RFPGA0_XC_LSSIREADBACK			0x8a8
+#define	RFPGA0_XD_LSSIREADBACK			0x8ac
+
+#define	RFPGA0_PSDREPORT			0x8b4
+#define	TRANSCEIVEA_HSPI_READBACK		0x8b8
+#define	TRANSCEIVEB_HSPI_READBACK		0x8bc
+#define	REG_SC_CNT				0x8c4
+#define	RFPGA0_XAB_RFINTERFACERB		0x8e0
+#define	RFPGA0_XCD_RFINTERFACERB		0x8e4
+
+#define	RFPGA1_RFMOD				0x900
+
+#define	RFPGA1_TXBLOCK				0x904
+#define	RFPGA1_DEBUGSELECT			0x908
+#define	RFPGA1_TXINFO				0x90c
+
+#define	RCCK0_SYSTEM				0xa00
+
+#define	RCCK0_AFESETTING			0xa04
+#define	RCCK0_CCA				0xa08
+
+#define	RCCK0_RXAGC1				0xa0c
+#define	RCCK0_RXAGC2				0xa10
+
+#define	RCCK0_RXHP				0xa14
+
+#define	RCCK0_DSPPARAMETER1			0xa18
+#define	RCCK0_DSPPARAMETER2			0xa1c
+
+#define	RCCK0_TXFILTER1				0xa20
+#define	RCCK0_TXFILTER2				0xa24
+#define	RCCK0_DEBUGPORT				0xa28
+#define	RCCK0_FALSEALARMREPORT			0xa2c
+#define	RCCK0_TRSSIREPORT			0xa50
+#define	RCCK0_RXREPORT				0xa54
+#define	RCCK0_FACOUNTERLOWER			0xa5c
+#define	RCCK0_FACOUNTERUPPER			0xa58
+#define	RCCK0_CCA_CNT				0xa60
+
+
+/* PageB(0xB00) */
+#define	rPdp_AntA				0xb00
+#define	rPdp_AntA_4				0xb04
+#define	rPdp_AntA_8				0xb08
+#define	rPdp_AntA_C				0xb0c
+#define	rPdp_AntA_10				0xb10
+#define	rPdp_AntA_14				0xb14
+#define	rPdp_AntA_18				0xb18
+#define	rPdp_AntA_1C				0xb1c
+#define	rPdp_AntA_20				0xb20
+#define	rPdp_AntA_24				0xb24
+
+#define	rConfig_Pmpd_AntA			0xb28
+#define	rConfig_ram64x16			0xb2c
+
+#define	rBndA					0xb30
+#define	rHssiPar				0xb34
+
+#define	rConfig_AntA				0xb68
+#define	rConfig_AntB				0xb6c
+
+#define	rPdp_AntB				0xb70
+#define	rPdp_AntB_4				0xb74
+#define	rPdp_AntB_8				0xb78
+#define	rPdp_AntB_C				0xb7c
+#define	rPdp_AntB_10				0xb80
+#define	rPdp_AntB_14				0xb84
+#define	rPdp_AntB_18				0xb88
+#define	rPdp_AntB_1C				0xb8c
+#define	rPdp_AntB_20				0xb90
+#define	rPdp_AntB_24				0xb94
+
+#define	rConfig_Pmpd_AntB			0xb98
+
+#define	rBndB					0xba0
+
+#define	rAPK					0xbd8
+#define	rPm_Rx0_AntA				0xbdc
+#define	rPm_Rx1_AntA				0xbe0
+#define	rPm_Rx2_AntA				0xbe4
+#define	rPm_Rx3_AntA				0xbe8
+#define	rPm_Rx0_AntB				0xbec
+#define	rPm_Rx1_AntB				0xbf0
+#define	rPm_Rx2_AntB				0xbf4
+#define	rPm_Rx3_AntB				0xbf8
+
+/*Page C*/
+#define	ROFDM0_LSTF				0xc00
+
+#define	ROFDM0_TRXPATHENABLE			0xc04
+#define	ROFDM0_TRMUXPAR				0xc08
+#define	ROFDM0_TRSWISOLATION			0xc0c
+
+#define	ROFDM0_XARXAFE				0xc10
+#define	ROFDM0_XARXIQIMBALANCE			0xc14
+#define	ROFDM0_XBRXAFE				0xc18
+#define	ROFDM0_XBRXIQIMBALANCE			0xc1c
+#define	ROFDM0_XCRXAFE				0xc20
+#define	ROFDM0_XCRXIQIMBANLANCE			0xc24
+#define	ROFDM0_XDRXAFE				0xc28
+#define	ROFDM0_XDRXIQIMBALANCE			0xc2c
+
+#define	ROFDM0_RXDETECTOR1			0xc30
+#define	ROFDM0_RXDETECTOR2			0xc34
+#define	ROFDM0_RXDETECTOR3			0xc38
+#define	ROFDM0_RXDETECTOR4			0xc3c
+
+#define	ROFDM0_RXDSP				0xc40
+#define	ROFDM0_CFOANDDAGC			0xc44
+#define	ROFDM0_CCADROPTHRESHOLD			0xc48
+#define	ROFDM0_ECCATHRESHOLD			0xc4c
+
+#define	ROFDM0_XAAGCCORE1			0xc50
+#define	ROFDM0_XAAGCCORE2			0xc54
+#define	ROFDM0_XBAGCCORE1			0xc58
+#define	ROFDM0_XBAGCCORE2			0xc5c
+#define	ROFDM0_XCAGCCORE1			0xc60
+#define	ROFDM0_XCAGCCORE2			0xc64
+#define	ROFDM0_XDAGCCORE1			0xc68
+#define	ROFDM0_XDAGCCORE2			0xc6c
+
+#define	ROFDM0_AGCPARAMETER1			0xc70
+#define	ROFDM0_AGCPARAMETER2			0xc74
+#define	ROFDM0_AGCRSSITABLE			0xc78
+#define	ROFDM0_HTSTFAGC				0xc7c
+
+#define	ROFDM0_XATXIQIMBALANCE			0xc80
+#define	ROFDM0_XATXAFE				0xc84
+#define	ROFDM0_XBTXIQIMBALANCE			0xc88
+#define	ROFDM0_XBTXAFE				0xc8c
+#define	ROFDM0_XCTXIQIMBALANCE			0xc90
+#define	ROFDM0_XCTXAFE				0xc94
+#define	ROFDM0_XDTXIQIMBALANCE			0xc98
+#define	ROFDM0_XDTXAFE				0xc9c
+
+#define ROFDM0_RXIQEXTANTA			0xca0
+#define	ROFDM0_TXCOEFF1				0xca4
+#define	ROFDM0_TXCOEFF2				0xca8
+#define	ROFDM0_TXCOEFF3				0xcac
+#define	ROFDM0_TXCOEFF4				0xcb0
+#define	ROFDM0_TXCOEFF5				0xcb4
+#define	ROFDM0_TXCOEFF6				0xcb8
+
+#define	ROFDM0_RXHPPARAMETER			0xce0
+#define	ROFDM0_TXPSEUDONOISEWGT			0xce4
+#define	ROFDM0_FRAMESYNC			0xcf0
+#define	ROFDM0_DFSREPORT			0xcf4
+
+
+#define	ROFDM1_LSTF				0xd00
+#define	ROFDM1_TRXPATHENABLE			0xd04
+
+#define	ROFDM1_CF0				0xd08
+#define	ROFDM1_CSI1				0xd10
+#define	ROFDM1_SBD				0xd14
+#define	ROFDM1_CSI2				0xd18
+#define	ROFDM1_CFOTRACKING			0xd2c
+#define	ROFDM1_TRXMESAURE1			0xd34
+#define	ROFDM1_INTFDET				0xd3c
+#define	ROFDM1_PSEUDONOISESTATEAB		0xd50
+#define	ROFDM1_PSEUDONOISESTATECD		0xd54
+#define	ROFDM1_RXPSEUDONOISEWGT			0xd58
+
+#define	ROFDM_PHYCOUNTER1			0xda0
+#define	ROFDM_PHYCOUNTER2			0xda4
+#define	ROFDM_PHYCOUNTER3			0xda8
+
+#define	ROFDM_SHORTCFOAB			0xdac
+#define	ROFDM_SHORTCFOCD			0xdb0
+#define	ROFDM_LONGCFOAB				0xdb4
+#define	ROFDM_LONGCFOCD				0xdb8
+#define	ROFDM_TAILCF0AB				0xdbc
+#define	ROFDM_TAILCF0CD				0xdc0
+#define	ROFDM_PWMEASURE1			0xdc4
+#define	ROFDM_PWMEASURE2			0xdc8
+#define	ROFDM_BWREPORT				0xdcc
+#define	ROFDM_AGCREPORT				0xdd0
+#define	ROFDM_RXSNR				0xdd4
+#define	ROFDM_RXEVMCSI				0xdd8
+#define	ROFDM_SIGREPORT				0xddc
+
+#define	RTXAGC_A_RATE18_06			0xe00
+#define	RTXAGC_A_RATE54_24			0xe04
+#define	RTXAGC_A_CCK1_MCS32			0xe08
+#define	RTXAGC_A_MCS03_MCS00			0xe10
+#define	RTXAGC_A_MCS07_MCS04			0xe14
+#define	RTXAGC_A_MCS11_MCS08			0xe18
+#define	RTXAGC_A_MCS15_MCS12			0xe1c
+
+#define	RTXAGC_B_RATE18_06			0x830
+#define	RTXAGC_B_RATE54_24			0x834
+#define	RTXAGC_B_CCK1_55_MCS32			0x838
+#define	RTXAGC_B_MCS03_MCS00			0x83c
+#define	RTXAGC_B_MCS07_MCS04			0x848
+#define	RTXAGC_B_MCS11_MCS08			0x84c
+#define	RTXAGC_B_MCS15_MCS12			0x868
+#define	RTXAGC_B_CCK11_A_CCK2_11		0x86c
+
+#define	RFPGA0_IQK				0xe28
+#define	RTx_IQK_Tone_A				0xe30
+#define	RRx_IQK_Tone_A				0xe34
+#define	RTx_IQK_PI_A				0xe38
+#define	RRx_IQK_PI_A				0xe3c
+
+#define	RTx_IQK					0xe40
+#define	RRx_IQK					0xe44
+#define	RIQK_AGC_Pts				0xe48
+#define	RIQK_AGC_Rsp				0xe4c
+#define	RTx_IQK_Tone_B				0xe50
+#define	RRx_IQK_Tone_B				0xe54
+#define	RTx_IQK_PI_B				0xe58
+#define	RRx_IQK_PI_B				0xe5c
+#define	RIQK_AGC_Cont				0xe60
+
+#define	RBlue_Tooth				0xe6c
+#define	RRx_Wait_CCA				0xe70
+#define	RTx_CCK_RFON				0xe74
+#define	RTx_CCK_BBON				0xe78
+#define	RTx_OFDM_RFON				0xe7c
+#define	RTx_OFDM_BBON				0xe80
+#define	RTx_To_Rx				0xe84
+#define	RTx_To_Tx				0xe88
+#define	RRx_CCK					0xe8c
+
+#define	RTx_Power_Before_IQK_A			0xe94
+#define	RTx_Power_After_IQK_A			0xe9c
+
+#define	RRx_Power_Before_IQK_A			0xea0
+#define	RRx_Power_Before_IQK_A_2		0xea4
+#define	RRx_Power_After_IQK_A			0xea8
+#define	RRx_Power_After_IQK_A_2			0xeac
+
+#define	RTx_Power_Before_IQK_B			0xeb4
+#define	RTx_Power_After_IQK_B			0xebc
+
+#define	RRx_Power_Before_IQK_B			0xec0
+#define	RRx_Power_Before_IQK_B_2		0xec4
+#define	RRx_Power_After_IQK_B			0xec8
+#define	RRx_Power_After_IQK_B_2			0xecc
+
+#define	RRx_OFDM				0xed0
+#define	RRx_Wait_RIFS				0xed4
+#define	RRx_TO_Rx				0xed8
+#define	RStandby				0xedc
+#define	RSleep					0xee0
+#define	RPMPD_ANAEN				0xeec
+
+#define	RZEBRA1_HSSIENABLE			0x0
+#define	RZEBRA1_TRXENABLE1			0x1
+#define	RZEBRA1_TRXENABLE2			0x2
+#define	RZEBRA1_AGC				0x4
+#define	RZEBRA1_CHARGEPUMP			0x5
+#define	RZEBRA1_CHANNEL				0x7
+
+#define	RZEBRA1_TXGAIN				0x8
+#define	RZEBRA1_TXLPF				0x9
+#define	RZEBRA1_RXLPF				0xb
+#define	RZEBRA1_RXHPFCORNER			0xc
+
+#define	RGLOBALCTRL				0
+#define	RRTL8256_TXLPF				19
+#define	RRTL8256_RXLPF				11
+#define	RRTL8258_TXLPF				0x11
+#define	RRTL8258_RXLPF				0x13
+#define	RRTL8258_RSSILPF			0xa
+
+#define	RF_AC					0x00
+
+#define	RF_IQADJ_G1				0x01
+#define	RF_IQADJ_G2				0x02
+#define	RF_POW_TRSW				0x05
+
+#define	RF_GAIN_RX				0x06
+#define	RF_GAIN_TX				0x07
+
+#define	RF_TXM_IDAC				0x08
+#define	RF_BS_IQGEN				0x0F
+
+#define	RF_MODE1				0x10
+#define	RF_MODE2				0x11
+
+#define	RF_RX_AGC_HP				0x12
+#define	RF_TX_AGC				0x13
+#define	RF_BIAS					0x14
+#define	RF_IPA					0x15
+#define	RF_POW_ABILITY				0x17
+#define	RF_MODE_AG				0x18
+#define	RRFCHANNEL				0x18
+#define	RF_CHNLBW				0x18
+#define	RF_TOP					0x19
+
+#define	RF_RX_G1				0x1A
+#define	RF_RX_G2				0x1B
+
+#define	RF_RX_BB2				0x1C
+#define	RF_RX_BB1				0x1D
+
+#define	RF_RCK1					0x1E
+#define	RF_RCK2					0x1F
+
+#define	RF_TX_G1				0x20
+#define	RF_TX_G2				0x21
+#define	RF_TX_G3				0x22
+
+#define	RF_TX_BB1				0x23
+#define	RF_T_METER				0x42
+
+#define	RF_SYN_G1				0x25
+#define	RF_SYN_G2				0x26
+#define	RF_SYN_G3				0x27
+#define	RF_SYN_G4				0x28
+#define	RF_SYN_G5				0x29
+#define	RF_SYN_G6				0x2A
+#define	RF_SYN_G7				0x2B
+#define	RF_SYN_G8				0x2C
+
+#define	RF_RCK_OS				0x30
+#define	RF_TXPA_G1				0x31
+#define	RF_TXPA_G2				0x32
+#define	RF_TXPA_G3				0x33
+
+#define	RF_TX_BIAS_A				0x35
+#define	RF_TX_BIAS_D				0x36
+#define	RF_LOBF_9				0x38
+#define	RF_RXRF_A3				0x3C
+#define	RF_TRSW					0x3F
+
+#define	RF_TXRF_A2				0x41
+#define	RF_TXPA_G4				0x46
+#define	RF_TXPA_A4				0x4B
+
+#define	RF_WE_LUT				0xEF
+
+#define	BBBRESETB				0x100
+#define	BGLOBALRESETB				0x200
+#define	BOFDMTXSTART				0x4
+#define	BCCKTXSTART				0x8
+#define	BCRC32DEBUG				0x100
+#define	BPMACLOOPBACK				0x10
+#define	BTXLSIG					0xffffff
+#define	BOFDMTXRATE				0xf
+#define	BOFDMTXRESERVED				0x10
+#define	BOFDMTXLENGTH				0x1ffe0
+#define	BOFDMTXPARITY				0x20000
+#define	BTXHTSIG1				0xffffff
+#define	BTXHTMCSRATE				0x7f
+#define	BTXHTBW					0x80
+#define	BTXHTLENGTH				0xffff00
+#define	BTXHTSIG2				0xffffff
+#define	BTXHTSMOOTHING				0x1
+#define	BTXHTSOUNDING				0x2
+#define	BTXHTRESERVED				0x4
+#define	BTXHTAGGREATION				0x8
+#define	BTXHTSTBC				0x30
+#define	BTXHTADVANCECODING			0x40
+#define	BTXHTSHORTGI				0x80
+#define	BTXHTNUMBERHT_LTF			0x300
+#define	BTXHTCRC8				0x3fc00
+#define	BCOUNTERRESET				0x10000
+#define	BNUMOFOFDMTX				0xffff
+#define	BNUMOFCCKTX				0xffff0000
+#define	BTXIDLEINTERVAL				0xffff
+#define	BOFDMSERVICE				0xffff0000
+#define	BTXMACHEADER				0xffffffff
+#define	BTXDATAINIT				0xff
+#define	BTXHTMODE				0x100
+#define	BTXDATATYPE				0x30000
+#define	BTXRANDOMSEED				0xffffffff
+#define	BCCKTXPREAMBLE				0x1
+#define	BCCKTXSFD				0xffff0000
+#define	BCCKTXSIG				0xff
+#define	BCCKTXSERVICE				0xff00
+#define	BCCKLENGTHEXT				0x8000
+#define	BCCKTXLENGHT				0xffff0000
+#define	BCCKTXCRC16				0xffff
+#define	BCCKTXSTATUS				0x1
+#define	BOFDMTXSTATUS				0x2
+#define IS_BB_REG_OFFSET_92S(_Offset)	\
+	((_Offset >= 0x800) && (_Offset <= 0xfff))
+
+#define	BRFMOD					0x1
+#define	BJAPANMODE				0x2
+#define	BCCKTXSC				0x30
+#define	BCCKEN					0x1000000
+#define	BOFDMEN					0x2000000
+
+#define	BOFDMRXADCPHASE				0x10000
+#define	BOFDMTXDACPHASE				0x40000
+#define	BXATXAGC				0x3f
+
+#define	BXBTXAGC				0xf00
+#define	BXCTXAGC				0xf000
+#define	BXDTXAGC				0xf0000
+
+#define	BPASTART				0xf0000000
+#define	BTRSTART				0x00f00000
+#define	BRFSTART				0x0000f000
+#define	BBBSTART				0x000000f0
+#define	BBBCCKSTART				0x0000000f
+#define	BPAEND					0xf
+#define	BTREND					0x0f000000
+#define	BRFEND					0x000f0000
+#define	BCCAMASK				0x000000f0
+#define	BR2RCCAMASK				0x00000f00
+#define	BHSSI_R2TDELAY				0xf8000000
+#define	BHSSI_T2RDELAY				0xf80000
+#define	BCONTXHSSI				0x400
+#define	BIGFROMCCK				0x200
+#define	BAGCADDRESS				0x3f
+#define	BRXHPTX					0x7000
+#define	BRXHP2RX				0x38000
+#define	BRXHPCCKINI				0xc0000
+#define	BAGCTXCODE				0xc00000
+#define	BAGCRXCODE				0x300000
+
+#define	B3WIREDATALENGTH			0x800
+#define	B3WIREADDREAALENGTH			0x400
+
+#define	B3WIRERFPOWERDOWN			0x1
+#define	B5GPAPEPOLARITY				0x40000000
+#define	B2GPAPEPOLARITY				0x80000000
+#define	BRFSW_TXDEFAULTANT			0x3
+#define	BRFSW_TXOPTIONANT			0x30
+#define	BRFSW_RXDEFAULTANT			0x300
+#define	BRFSW_RXOPTIONANT			0x3000
+#define	BRFSI_3WIREDATA				0x1
+#define	BRFSI_3WIRECLOCK			0x2
+#define	BRFSI_3WIRELOAD				0x4
+#define	BRFSI_3WIRERW				0x8
+#define	BRFSI_3WIRE				0xf
+
+#define	BRFSI_RFENV				0x10
+
+#define	BRFSI_TRSW				0x20
+#define	BRFSI_TRSWB				0x40
+#define	BRFSI_ANTSW				0x100
+#define	BRFSI_ANTSWB				0x200
+#define	BRFSI_PAPE				0x400
+#define	BRFSI_PAPE5G				0x800
+#define	BBANDSELECT				0x1
+#define	BHTSIG2_GI				0x80
+#define	BHTSIG2_SMOOTHING			0x01
+#define	BHTSIG2_SOUNDING			0x02
+#define	BHTSIG2_AGGREATON			0x08
+#define	BHTSIG2_STBC				0x30
+#define	BHTSIG2_ADVCODING			0x40
+#define	BHTSIG2_NUMOFHTLTF			0x300
+#define	BHTSIG2_CRC8				0x3fc
+#define	BHTSIG1_MCS				0x7f
+#define	BHTSIG1_BANDWIDTH			0x80
+#define	BHTSIG1_HTLENGTH			0xffff
+#define	BLSIG_RATE				0xf
+#define	BLSIG_RESERVED				0x10
+#define	BLSIG_LENGTH				0x1fffe
+#define	BLSIG_PARITY				0x20
+#define	BCCKRXPHASE				0x4
+
+#define	BLSSIREADADDRESS			0x7f800000
+#define	BLSSIREADEDGE				0x80000000
+
+#define	BLSSIREADBACKDATA			0xfffff
+
+#define	BLSSIREADOKFLAG				0x1000
+#define	BCCKSAMPLERATE				0x8
+#define	BREGULATOR0STANDBY			0x1
+#define	BREGULATORPLLSTANDBY			0x2
+#define	BREGULATOR1STANDBY			0x4
+#define	BPLLPOWERUP				0x8
+#define	BDPLLPOWERUP				0x10
+#define	BDA10POWERUP				0x20
+#define	BAD7POWERUP				0x200
+#define	BDA6POWERUP				0x2000
+#define	BXTALPOWERUP				0x4000
+#define	B40MDCLKPOWERUP				0x8000
+#define	BDA6DEBUGMODE				0x20000
+#define	BDA6SWING				0x380000
+
+#define	BADCLKPHASE				0x4000000
+#define	B80MCLKDELAY				0x18000000
+#define	BAFEWATCHDOGENABLE			0x20000000
+
+#define	BXTALCAP01				0xc0000000
+#define	BXTALCAP23				0x3
+#define	BXTALCAP92X				0x0f000000
+#define BXTALCAP				0x0f000000
+
+#define	BINTDIFCLKENABLE			0x400
+#define	BEXTSIGCLKENABLE			0x800
+#define	BBANDGAP_MBIAS_POWERUP			0x10000
+#define	BAD11SH_GAIN				0xc0000
+#define	BAD11NPUT_RANGE				0x700000
+#define	BAD110P_CURRENT				0x3800000
+#define	BLPATH_LOOPBACK				0x4000000
+#define	BQPATH_LOOPBACK				0x8000000
+#define	BAFE_LOOPBACK				0x10000000
+#define	BDA10_SWING				0x7e0
+#define	BDA10_REVERSE				0x800
+#define	BDA_CLK_SOURCE				0x1000
+#define	BDA7INPUT_RANGE				0x6000
+#define	BDA7_GAIN				0x38000
+#define	BDA7OUTPUT_CM_MODE			0x40000
+#define	BDA7INPUT_CM_MODE			0x380000
+#define	BDA7CURRENT				0xc00000
+#define	BREGULATOR_ADJUST			0x7000000
+#define	BAD11POWERUP_ATTX			0x1
+#define	BDA10PS_ATTX				0x10
+#define	BAD11POWERUP_ATRX			0x100
+#define	BDA10PS_ATRX				0x1000
+#define	BCCKRX_AGC_FORMAT			0x200
+#define	BPSDFFT_SAMPLE_POINT			0xc000
+#define	BPSD_AVERAGE_NUM			0x3000
+#define	BIQPATH_CONTROL				0xc00
+#define	BPSD_FREQ				0x3ff
+#define	BPSD_ANTENNA_PATH			0x30
+#define	BPSD_IQ_SWITCH				0x40
+#define	BPSD_RX_TRIGGER				0x400000
+#define	BPSD_TX_TRIGGER				0x80000000
+#define	BPSD_SINE_TONE_SCALE			0x7f000000
+#define	BPSD_REPORT				0xffff
+
+#define	BOFDM_TXSC				0x30000000
+#define	BCCK_TXON				0x1
+#define	BOFDM_TXON				0x2
+#define	BDEBUG_PAGE				0xfff
+#define	BDEBUG_ITEM				0xff
+#define	BANTL					0x10
+#define	BANT_NONHT				0x100
+#define	BANT_HT1				0x1000
+#define	BANT_HT2				0x10000
+#define	BANT_HT1S1				0x100000
+#define	BANT_NONHTS1				0x1000000
+
+#define	BCCK_BBMODE				0x3
+#define	BCCK_TXPOWERSAVING			0x80
+#define	BCCK_RXPOWERSAVING			0x40
+
+#define	BCCK_SIDEBAND				0x10
+
+#define	BCCK_SCRAMBLE				0x8
+#define	BCCK_ANTDIVERSITY			0x8000
+#define	BCCK_CARRIER_RECOVERY			0x4000
+#define	BCCK_TXRATE				0x3000
+#define	BCCK_DCCANCEL				0x0800
+#define	BCCK_ISICANCEL				0x0400
+#define	BCCK_MATCH_FILTER			0x0200
+#define	BCCK_EQUALIZER				0x0100
+#define	BCCK_PREAMBLE_DETECT			0x800000
+#define	BCCK_FAST_FALSECCA			0x400000
+#define	BCCK_CH_ESTSTART			0x300000
+#define	BCCK_CCA_COUNT				0x080000
+#define	BCCK_CS_LIM				0x070000
+#define	BCCK_BIST_MODE				0x80000000
+#define	BCCK_CCAMASK				0x40000000
+#define	BCCK_TX_DAC_PHASE			0x4
+#define	BCCK_RX_ADC_PHASE			0x20000000
+#define	BCCKR_CP_MODE				0x0100
+#define	BCCK_TXDC_OFFSET			0xf0
+#define	BCCK_RXDC_OFFSET			0xf
+#define	BCCK_CCA_MODE				0xc000
+#define	BCCK_FALSECS_LIM			0x3f00
+#define	BCCK_CS_RATIO				0xc00000
+#define	BCCK_CORGBIT_SEL			0x300000
+#define	BCCK_PD_LIM				0x0f0000
+#define	BCCK_NEWCCA				0x80000000
+#define	BCCK_RXHP_OF_IG				0x8000
+#define	BCCK_RXIG				0x7f00
+#define	BCCK_LNA_POLARITY			0x800000
+#define	BCCK_RX1ST_BAIN				0x7f0000
+#define	BCCK_RF_EXTEND				0x20000000
+#define	BCCK_RXAGC_SATLEVEL			0x1f000000
+#define	BCCK_RXAGC_SATCOUNT			0xe0
+#define	bCCKRxRFSettle				0x1f
+#define	BCCK_FIXED_RXAGC			0x8000
+#define	BCCK_ANTENNA_POLARITY			0x2000
+#define	BCCK_TXFILTER_TYPE			0x0c00
+#define	BCCK_RXAGC_REPORTTYPE			0x0300
+#define	BCCK_RXDAGC_EN				0x80000000
+#define	BCCK_RXDAGC_PERIOD			0x20000000
+#define	BCCK_RXDAGC_SATLEVEL			0x1f000000
+#define	BCCK_TIMING_RECOVERY			0x800000
+#define	BCCK_TXC0				0x3f0000
+#define	BCCK_TXC1				0x3f000000
+#define	BCCK_TXC2				0x3f
+#define	BCCK_TXC3				0x3f00
+#define	BCCK_TXC4				0x3f0000
+#define	BCCK_TXC5				0x3f000000
+#define	BCCK_TXC6				0x3f
+#define	BCCK_TXC7				0x3f00
+#define	BCCK_DEBUGPORT				0xff0000
+#define	BCCK_DAC_DEBUG				0x0f000000
+#define	BCCK_FALSEALARM_ENABLE			0x8000
+#define	BCCK_FALSEALARM_READ			0x4000
+#define	BCCK_TRSSI				0x7f
+#define	BCCK_RXAGC_REPORT			0xfe
+#define	BCCK_RXREPORT_ANTSEL			0x80000000
+#define	BCCK_RXREPORT_MFOFF			0x40000000
+#define	BCCK_RXREPORT_SQLOSS			0x20000000
+#define	BCCK_RXREPORT_PKTLOSS			0x10000000
+#define	BCCK_RXREPORT_LOCKEDBIT			0x08000000
+#define	BCCK_RXREPORT_RATEERROR			0x04000000
+#define	BCCK_RXREPORT_RXRATE			0x03000000
+#define	BCCK_RXFA_COUNTER_LOWER			0xff
+#define	BCCK_RXFA_COUNTER_UPPER			0xff000000
+#define	BCCK_RXHPAGC_START			0xe000
+#define	BCCK_RXHPAGC_FINAL			0x1c00
+#define	BCCK_RXFALSEALARM_ENABLE		0x8000
+#define	BCCK_FACOUNTER_FREEZE			0x4000
+#define	BCCK_TXPATH_SEL				0x10000000
+#define	BCCK_DEFAULT_RXPATH			0xc000000
+#define	BCCK_OPTION_RXPATH			0x3000000
+
+#define	BNUM_OFSTF				0x3
+#define	BSHIFT_L				0xc0
+#define	BGI_TH					0xc
+#define	BRXPATH_A				0x1
+#define	BRXPATH_B				0x2
+#define	BRXPATH_C				0x4
+#define	BRXPATH_D				0x8
+#define	BTXPATH_A				0x1
+#define	BTXPATH_B				0x2
+#define	BTXPATH_C				0x4
+#define	BTXPATH_D				0x8
+#define	BTRSSI_FREQ				0x200
+#define	BADC_BACKOFF				0x3000
+#define	BDFIR_BACKOFF				0xc000
+#define	BTRSSI_LATCH_PHASE			0x10000
+#define	BRX_LDC_OFFSET				0xff
+#define	BRX_QDC_OFFSET				0xff00
+#define	BRX_DFIR_MODE				0x1800000
+#define	BRX_DCNF_TYPE				0xe000000
+#define	BRXIQIMB_A				0x3ff
+#define	BRXIQIMB_B				0xfc00
+#define	BRXIQIMB_C				0x3f0000
+#define	BRXIQIMB_D				0xffc00000
+#define	BDC_DC_NOTCH				0x60000
+#define	BRXNB_NOTCH				0x1f000000
+#define	BPD_TH					0xf
+#define	BPD_TH_OPT2				0xc000
+#define	BPWED_TH				0x700
+#define	BIFMF_WIN_L				0x800
+#define	BPD_OPTION				0x1000
+#define	BMF_WIN_L				0xe000
+#define	BBW_SEARCH_L				0x30000
+#define	BWIN_ENH_L				0xc0000
+#define	BBW_TH					0x700000
+#define	BED_TH2					0x3800000
+#define	BBW_OPTION				0x4000000
+#define	BRADIO_TH				0x18000000
+#define	BWINDOW_L				0xe0000000
+#define	BSBD_OPTION				0x1
+#define	BFRAME_TH				0x1c
+#define	BFS_OPTION				0x60
+#define	BDC_SLOPE_CHECK				0x80
+#define	BFGUARD_COUNTER_DC_L			0xe00
+#define	BFRAME_WEIGHT_SHORT			0x7000
+#define	BSUB_TUNE				0xe00000
+#define	BFRAME_DC_LENGTH			0xe000000
+#define	BSBD_START_OFFSET			0x30000000
+#define	BFRAME_TH_2				0x7
+#define	BFRAME_GI2_TH				0x38
+#define	BGI2_SYNC_EN				0x40
+#define	BSARCH_SHORT_EARLY			0x300
+#define	BSARCH_SHORT_LATE			0xc00
+#define	BSARCH_GI2_LATE				0x70000
+#define	BCFOANTSUM				0x1
+#define	BCFOACC					0x2
+#define	BCFOSTARTOFFSET				0xc
+#define	BCFOLOOPBACK				0x70
+#define	BCFOSUMWEIGHT				0x80
+#define	BDAGCENABLE				0x10000
+#define	BTXIQIMB_A				0x3ff
+#define	BTXIQIMB_b				0xfc00
+#define	BTXIQIMB_C				0x3f0000
+#define	BTXIQIMB_D				0xffc00000
+#define	BTXIDCOFFSET				0xff
+#define	BTXIQDCOFFSET				0xff00
+#define	BTXDFIRMODE				0x10000
+#define	BTXPESUDO_NOISEON			0x4000000
+#define	BTXPESUDO_NOISE_A			0xff
+#define	BTXPESUDO_NOISE_B			0xff00
+#define	BTXPESUDO_NOISE_C			0xff0000
+#define	BTXPESUDO_NOISE_D			0xff000000
+#define	BCCA_DROPOPTION				0x20000
+#define	BCCA_DROPTHRES				0xfff00000
+#define	BEDCCA_H				0xf
+#define	BEDCCA_L				0xf0
+#define	BLAMBDA_ED				0x300
+#define	BRX_INITIALGAIN				0x7f
+#define	BRX_ANTDIV_EN				0x80
+#define	BRX_AGC_ADDRESS_FOR_LNA			0x7f00
+#define	BRX_HIGHPOWER_FLOW			0x8000
+#define	BRX_AGC_FREEZE_THRES			0xc0000
+#define	BRX_FREEZESTEP_AGC1			0x300000
+#define	BRX_FREEZESTEP_AGC2			0xc00000
+#define	BRX_FREEZESTEP_AGC3			0x3000000
+#define	BRX_FREEZESTEP_AGC0			0xc000000
+#define	BRXRSSI_CMP_EN				0x10000000
+#define	BRXQUICK_AGCEN				0x20000000
+#define	BRXAGC_FREEZE_THRES_MODE		0x40000000
+#define	BRX_OVERFLOW_CHECKTYPE			0x80000000
+#define	BRX_AGCSHIFT				0x7f
+#define	BTRSW_TRI_ONLY				0x80
+#define	BPOWER_THRES				0x300
+#define	BRXAGC_EN				0x1
+#define	BRXAGC_TOGETHER_EN			0x2
+#define	BRXAGC_MIN				0x4
+#define	BRXHP_INI				0x7
+#define	BRXHP_TRLNA				0x70
+#define	BRXHP_RSSI				0x700
+#define	BRXHP_BBP1				0x7000
+#define	BRXHP_BBP2				0x70000
+#define	BRXHP_BBP3				0x700000
+#define	BRSSI_H					0x7f0000
+#define	BRSSI_GEN				0x7f000000
+#define	BRXSETTLE_TRSW				0x7
+#define	BRXSETTLE_LNA				0x38
+#define	BRXSETTLE_RSSI				0x1c0
+#define	BRXSETTLE_BBP				0xe00
+#define	BRXSETTLE_RXHP				0x7000
+#define	BRXSETTLE_ANTSW_RSSI			0x38000
+#define	BRXSETTLE_ANTSW				0xc0000
+#define	BRXPROCESS_TIME_DAGC			0x300000
+#define	BRXSETTLE_HSSI				0x400000
+#define	BRXPROCESS_TIME_BBPPW			0x800000
+#define	BRXANTENNA_POWER_SHIFT			0x3000000
+#define	BRSSI_TABLE_SELECT			0xc000000
+#define	BRXHP_FINAL				0x7000000
+#define	BRXHPSETTLE_BBP				0x7
+#define	BRXHTSETTLE_HSSI			0x8
+#define	BRXHTSETTLE_RXHP			0x70
+#define	BRXHTSETTLE_BBPPW			0x80
+#define	BRXHTSETTLE_IDLE			0x300
+#define	BRXHTSETTLE_RESERVED			0x1c00
+#define	BRXHT_RXHP_EN				0x8000
+#define	BRXAGC_FREEZE_THRES			0x30000
+#define	BRXAGC_TOGETHEREN			0x40000
+#define	BRXHTAGC_MIN				0x80000
+#define	BRXHTAGC_EN				0x100000
+#define	BRXHTDAGC_EN				0x200000
+#define	BRXHT_RXHP_BBP				0x1c00000
+#define	BRXHT_RXHP_FINAL			0xe0000000
+#define	BRXPW_RADIO_TH				0x3
+#define	BRXPW_RADIO_EN				0x4
+#define	BRXMF_HOLD				0x3800
+#define	BRXPD_DELAY_TH1				0x38
+#define	BRXPD_DELAY_TH2				0x1c0
+#define	BRXPD_DC_COUNT_MAX			0x600
+#define	BRXPD_DELAY_TH				0x8000
+#define	BRXPROCESS_DELAY			0xf0000
+#define	BRXSEARCHRANGE_GI2_EARLY		0x700000
+#define	BRXFRAME_FUARD_COUNTER_L		0x3800000
+#define	BRXSGI_GUARD_L				0xc000000
+#define	BRXSGI_SEARCH_L				0x30000000
+#define	BRXSGI_TH				0xc0000000
+#define	BDFSCNT0				0xff
+#define	BDFSCNT1				0xff00
+#define	BDFSFLAG				0xf0000
+#define	BMF_WEIGHT_SUM				0x300000
+#define	BMINIDX_TH				0x7f000000
+#define	BDAFORMAT				0x40000
+#define	BTXCH_EMU_ENABLE			0x01000000
+#define	BTRSW_ISOLATION_A			0x7f
+#define	BTRSW_ISOLATION_B			0x7f00
+#define	BTRSW_ISOLATION_C			0x7f0000
+#define	BTRSW_ISOLATION_D			0x7f000000
+#define	BEXT_LNA_GAIN				0x7c00
+
+#define	BSTBC_EN				0x4
+#define	BANTENNA_MAPPING			0x10
+#define	BNSS					0x20
+#define	BCFO_ANTSUM_ID				0x200
+#define	BPHY_COUNTER_RESET			0x8000000
+#define	BCFO_REPORT_GET				0x4000000
+#define	BOFDM_CONTINUE_TX			0x10000000
+#define	BOFDM_SINGLE_CARRIER			0x20000000
+#define	BOFDM_SINGLE_TONE			0x40000000
+#define	BHT_DETECT				0x100
+#define	BCFOEN					0x10000
+#define	BCFOVALUE				0xfff00000
+#define	BSIGTONE_RE				0x3f
+#define	BSIGTONE_IM				0x7f00
+#define	BCOUNTER_CCA				0xffff
+#define	BCOUNTER_PARITYFAIL			0xffff0000
+#define	BCOUNTER_RATEILLEGAL			0xffff
+#define	BCOUNTER_CRC8FAIL			0xffff0000
+#define	BCOUNTER_MCSNOSUPPORT			0xffff
+#define	BCOUNTER_FASTSYNC			0xffff
+#define	BSHORTCFO				0xfff
+#define	BSHORTCFOT_LENGTH			12
+#define	BSHORTCFOF_LENGTH			11
+#define	BLONGCFO				0x7ff
+#define	BLONGCFOT_LENGTH			11
+#define	BLONGCFOF_LENGTH			11
+#define	BTAILCFO				0x1fff
+#define	BTAILCFOT_LENGTH			13
+#define	BTAILCFOF_LENGTH			12
+#define	BNOISE_EN_PWDB				0xffff
+#define	BCC_POWER_DB				0xffff0000
+#define	BMOISE_PWDB				0xffff
+#define	BPOWERMEAST_LENGTH			10
+#define	BPOWERMEASF_LENGTH			3
+#define	BRX_HT_BW				0x1
+#define	BRXSC					0x6
+#define	BRX_HT					0x8
+#define	BNB_INTF_DET_ON				0x1
+#define	BINTF_WIN_LEN_CFG			0x30
+#define	BNB_INTF_TH_CFG				0x1c0
+#define	BRFGAIN					0x3f
+#define	BTABLESEL				0x40
+#define	BTRSW					0x80
+#define	BRXSNR_A				0xff
+#define	BRXSNR_B				0xff00
+#define	BRXSNR_C				0xff0000
+#define	BRXSNR_D				0xff000000
+#define	BSNR_EVMT_LENGTH			8
+#define	BSNR_EVMF_LENGTH			1
+#define	BCSI1ST					0xff
+#define	BCSI2ND					0xff00
+#define	BRXEVM1ST				0xff0000
+#define	BRXEVM2ND				0xff000000
+#define	BSIGEVM					0xff
+#define	BPWDB					0xff00
+#define	BSGIEN					0x10000
+
+#define	BSFACTOR_QMA1				0xf
+#define	BSFACTOR_QMA2				0xf0
+#define	BSFACTOR_QMA3				0xf00
+#define	BSFACTOR_QMA4				0xf000
+#define	BSFACTOR_QMA5				0xf0000
+#define	BSFACTOR_QMA6				0xf0000
+#define	BSFACTOR_QMA7				0xf00000
+#define	BSFACTOR_QMA8				0xf000000
+#define	BSFACTOR_QMA9				0xf0000000
+#define	BCSI_SCHEME				0x100000
+
+#define	BNOISE_LVL_TOP_SET			0x3
+#define	BCHSMOOTH				0x4
+#define	BCHSMOOTH_CFG1				0x38
+#define	BCHSMOOTH_CFG2				0x1c0
+#define	BCHSMOOTH_CFG3				0xe00
+#define	BCHSMOOTH_CFG4				0x7000
+#define	BMRCMODE				0x800000
+#define	BTHEVMCFG				0x7000000
+
+#define	BLOOP_FIT_TYPE				0x1
+#define	BUPD_CFO				0x40
+#define	BUPD_CFO_OFFDATA			0x80
+#define	BADV_UPD_CFO				0x100
+#define	BADV_TIME_CTRL				0x800
+#define	BUPD_CLKO				0x1000
+#define	BFC					0x6000
+#define	BTRACKING_MODE				0x8000
+#define	BPHCMP_ENABLE				0x10000
+#define	BUPD_CLKO_LTF				0x20000
+#define	BCOM_CH_CFO				0x40000
+#define	BCSI_ESTI_MODE				0x80000
+#define	BADV_UPD_EQZ				0x100000
+#define	BUCHCFG					0x7000000
+#define	BUPDEQZ					0x8000000
+
+#define	BRX_PESUDO_NOISE_ON			0x20000000
+#define	BRX_PESUDO_NOISE_A			0xff
+#define	BRX_PESUDO_NOISE_B			0xff00
+#define	BRX_PESUDO_NOISE_C			0xff0000
+#define	BRX_PESUDO_NOISE_D			0xff000000
+#define	BRX_PESUDO_NOISESTATE_A			0xffff
+#define	BRX_PESUDO_NOISESTATE_B			0xffff0000
+#define	BRX_PESUDO_NOISESTATE_C			0xffff
+#define	BRX_PESUDO_NOISESTATE_D			0xffff0000
+
+#define	BZEBRA1_HSSIENABLE			0x8
+#define	BZEBRA1_TRXCONTROL			0xc00
+#define	BZEBRA1_TRXGAINSETTING			0x07f
+#define	BZEBRA1_RXCOUNTER			0xc00
+#define	BZEBRA1_TXCHANGEPUMP			0x38
+#define	BZEBRA1_RXCHANGEPUMP			0x7
+#define	BZEBRA1_CHANNEL_NUM			0xf80
+#define	BZEBRA1_TXLPFBW				0x400
+#define	BZEBRA1_RXLPFBW				0x600
+
+#define	BRTL8256REG_MODE_CTRL1			0x100
+#define	BRTL8256REG_MODE_CTRL0			0x40
+#define	BRTL8256REG_TXLPFBW			0x18
+#define	BRTL8256REG_RXLPFBW			0x600
+
+#define	BRTL8258_TXLPFBW			0xc
+#define	BRTL8258_RXLPFBW			0xc00
+#define	BRTL8258_RSSILPFBW			0xc0
+
+#define	BBYTE0					0x1
+#define	BBYTE1					0x2
+#define	BBYTE2					0x4
+#define	BBYTE3					0x8
+#define	BWORD0					0x3
+#define	BWORD1					0xc
+#define	BWORD					0xf
+
+#define	MASKBYTE0				0xff
+#define	MASKBYTE1				0xff00
+#define	MASKBYTE2				0xff0000
+#define	MASKBYTE3				0xff000000
+#define	MASKHWORD				0xffff0000
+#define	MASKLWORD				0x0000ffff
+#define	MASKDWORD				0xffffffff
+#define	MASK12BITS				0xfff
+#define	MASKH4BITS				0xf0000000
+#define MASKOFDM_D				0xffc00000
+#define	MASKCCK					0x3f3f3f3f
+
+#define	MASK4BITS				0x0f
+#define	MASK20BITS				0xfffff
+#define RFREG_OFFSET_MASK			0xfffff
+
+#define	BENABLE					0x1
+#define	BDISABLE				0x0
+
+#define	LEFT_ANTENNA				0x0
+#define	RIGHT_ANTENNA				0x1
+
+#define	TCHECK_TXSTATUS				500
+#define	TUPDATE_RXCOUNTER			100
+
+#define	REG_UN_used_register			0x01bf
+
+/* WOL bit information */
+#define	HAL92C_WOL_PTK_UPDATE_EVENT		BIT(0)
+#define	HAL92C_WOL_GTK_UPDATE_EVENT		BIT(1)
+#define	HAL92C_WOL_DISASSOC_EVENT		BIT(2)
+#define	HAL92C_WOL_DEAUTH_EVENT			BIT(3)
+#define	HAL92C_WOL_FW_DISCONNECT_EVENT		BIT(4)
+
+#define WOL_REASON_PTK_UPDATE			BIT(0)
+#define WOL_REASON_GTK_UPDATE			BIT(1)
+#define WOL_REASON_DISASSOC			BIT(2)
+#define WOL_REASON_DEAUTH			BIT(3)
+#define WOL_REASON_FW_DISCONNECT		BIT(4)
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/rf.c b/drivers/staging/rtl8192ee/rtl8192ee/rf.c
new file mode 100644
index 0000000..4f5a49e
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/rf.c
@@ -0,0 +1,150 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "rf.h"
+#include "dm.h"
+
+static bool _rtl92ee_phy_rf6052_config_parafile(struct ieee80211_hw *hw);
+
+void rtl92ee_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	switch (bandwidth) {
+	case HT_CHANNEL_WIDTH_20:
+		rtlphy->rfreg_chnlval[0] = ((rtlphy->rfreg_chnlval[0] &
+					     0xfffff3ff) | BIT(10) | BIT(11));
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		break;
+	case HT_CHANNEL_WIDTH_20_40:
+		rtlphy->rfreg_chnlval[0] = ((rtlphy->rfreg_chnlval[0] &
+					     0xfffff3ff) | BIT(10));
+		rtl_set_rfreg(hw, RF90_PATH_A, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		rtl_set_rfreg(hw, RF90_PATH_B, RF_CHNLBW, RFREG_OFFSET_MASK,
+			      rtlphy->rfreg_chnlval[0]);
+		break;
+	default:
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("unknown bandwidth: %#X\n", bandwidth));
+		break;
+	}
+}
+
+bool rtl92ee_phy_rf6052_config(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+
+	if (rtlphy->rf_type == RF_1T1R)
+		rtlphy->num_total_rfpath = 1;
+	else
+		rtlphy->num_total_rfpath = 2;
+	return _rtl92ee_phy_rf6052_config_parafile(hw);
+}
+
+static bool _rtl92ee_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	u32 u4_regvalue = 0;
+	u8 rfpath;
+	bool rtstatus = true;
+	struct bb_reg_def *pphyreg;
+
+	for (rfpath = 0; rfpath < rtlphy->num_total_rfpath; rfpath++) {
+		pphyreg = &rtlphy->phyreg_def[rfpath];
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+		case RF90_PATH_C:
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
+						    BRFSI_RFENV);
+			break;
+		case RF90_PATH_B:
+		case RF90_PATH_D:
+			u4_regvalue = rtl_get_bbreg(hw, pphyreg->rfintfs,
+						    BRFSI_RFENV << 16);
+			break;
+		}
+
+		rtl_set_bbreg(hw, pphyreg->rfintfe, BRFSI_RFENV << 16, 0x1);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfintfo, BRFSI_RFENV, 0x1);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfhssi_para2,
+			      B3WIREADDREAALENGTH, 0x0);
+		udelay(1);
+
+		rtl_set_bbreg(hw, pphyreg->rfhssi_para2, B3WIREDATALENGTH, 0x0);
+		udelay(1);
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+			rtstatus = rtl92ee_phy_config_rf_with_headerfile(hw,
+						       (enum radio_path)rfpath);
+			break;
+		case RF90_PATH_B:
+			rtstatus = rtl92ee_phy_config_rf_with_headerfile(hw,
+						       (enum radio_path)rfpath);
+			break;
+		case RF90_PATH_C:
+			break;
+		case RF90_PATH_D:
+			break;
+		}
+
+		switch (rfpath) {
+		case RF90_PATH_A:
+		case RF90_PATH_C:
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV, u4_regvalue);
+			break;
+		case RF90_PATH_B:
+		case RF90_PATH_D:
+			rtl_set_bbreg(hw, pphyreg->rfintfs,
+				      BRFSI_RFENV << 16, u4_regvalue);
+			break;
+		}
+		if (!rtstatus) {
+			RT_TRACE(COMP_INIT, DBG_TRACE,
+				 ("Radio[%d] Fail!!", rfpath));
+			return false;
+		}
+	}
+
+	RT_TRACE(COMP_INIT, DBG_TRACE, ("\n"));
+	return rtstatus;
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/rf.h b/drivers/staging/rtl8192ee/rtl8192ee/rf.h
new file mode 100644
index 0000000..5bc394a
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/rf.h
@@ -0,0 +1,39 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_RF_H__
+#define __RTL92E_RF_H__
+
+#define RF6052_MAX_TX_PWR		0x3F
+#define RF6052_MAX_REG			0x3F
+
+extern void rtl92ee_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw,
+					     u8 bandwidth);
+extern bool rtl92ee_phy_rf6052_config(struct ieee80211_hw *hw);
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/sw.c b/drivers/staging/rtl8192ee/rtl8192ee/sw.c
new file mode 100644
index 0000000..f9c5729
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/sw.c
@@ -0,0 +1,428 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include <linux/vmalloc.h>
+#include <linux/module.h>
+
+#include "../wifi.h"
+#include "../core.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "dm.h"
+#include "hw.h"
+#include "sw.h"
+#include "fw.h"
+#include "trx.h"
+#include "led.h"
+#include "table.h"
+
+#include "../btcoexist/rtl_btc.h"
+
+
+static void rtl92ee_init_aspm_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+
+	/*close ASPM for AMD defaultly */
+	rtlpci->const_amdpci_aspm = 0;
+
+	/*
+	 * ASPM PS mode.
+	 * 0 - Disable ASPM,
+	 * 1 - Enable ASPM without Clock Req,
+	 * 2 - Enable ASPM with Clock Req,
+	 * 3 - Alwyas Enable ASPM with Clock Req,
+	 * 4 - Always Enable ASPM without Clock Req.
+	 * set defult to RTL8192CE:3 RTL8192E:2
+	 * */
+	rtlpci->const_pci_aspm = 3;
+
+	/*Setting for PCI-E device */
+	rtlpci->const_devicepci_aspm_setting = 0x03;
+
+	/*Setting for PCI-E bridge */
+	rtlpci->const_hostpci_aspm_setting = 0x02;
+
+	/*
+	 * In Hw/Sw Radio Off situation.
+	 * 0 - Default,
+	 * 1 - From ASPM setting without low Mac Pwr,
+	 * 2 - From ASPM setting with low Mac Pwr,
+	 * 3 - Bus D3
+	 * set default to RTL8192CE:0 RTL8192SE:2
+	 */
+	rtlpci->const_hwsw_rfoff_d3 = 0;
+
+	/*
+	 * This setting works for those device with
+	 * backdoor ASPM setting such as EPHY setting.
+	 * 0 - Not support ASPM,
+	 * 1 - Support ASPM,
+	 * 2 - According to chipset.
+	 */
+	rtlpci->const_support_pciaspm = 1;
+}
+
+int rtl92ee_init_sw_vars(struct ieee80211_hw *hw)
+{
+	int err = 0;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	const struct firmware *firmware;
+	char *fw_name = NULL;
+
+	rtl92ee_bt_reg_init(hw);
+
+	rtlpci->msi_support = true;
+	rtlpriv->btcoexist.btc_ops = stg_rtl_btc_get_ops_pointer();
+
+	rtlpriv->dm.b_dm_initialgain_enable = 1;
+	rtlpriv->dm.dm_flag = 0;
+	rtlpriv->dm.b_disable_framebursting = 0;
+	/*rtlpriv->dm.thermalvalue = 0;*/
+	rtlpci->transmit_config = CFENDFORM | BIT(15);
+
+	/*just 2.4G band*/
+	rtlpriv->rtlhal.current_bandtype = BAND_ON_2_4G;
+	rtlpriv->rtlhal.bandset = BAND_ON_2_4G;
+	rtlpriv->rtlhal.macphymode = SINGLEMAC_SINGLEPHY;
+
+	rtlpci->receive_config = (RCR_APPFCS			|
+				  RCR_APP_MIC			|
+				  RCR_APP_ICV			|
+				  RCR_APP_PHYST_RXFF		|
+				  RCR_HTC_LOC_CTRL		|
+				  RCR_AMF			|
+				  RCR_ACF			|
+				  RCR_ADF			|
+				  RCR_AICV			|
+				  RCR_ACRC32			|
+				  RCR_AB			|
+				  RCR_AM			|
+				  RCR_APM			|
+				  0);
+
+	rtlpci->irq_mask[0] = (u32) (IMR_PSTIMEOUT		|
+				/*   IMR_TBDER			|
+				     IMR_TBDOK			|
+				     IMR_BCNDMAINT0		|*/
+				     IMR_C2HCMD			|
+				     IMR_HIGHDOK		|
+				     IMR_MGNTDOK		|
+				     IMR_BKDOK			|
+				     IMR_BEDOK			|
+				     IMR_VIDOK			|
+				     IMR_VODOK			|
+				     IMR_RDU			|
+				     IMR_ROK			|
+				     0);
+	rtlpci->irq_mask[1] = (u32) (IMR_RXFOVW | 0);
+
+	/* for debug level */
+	rtlpriv->dbg.global_debuglevel = rtlpriv->cfg->mod_params->debug;
+	/* for LPS & IPS */
+	rtlpriv->psc.b_inactiveps = rtlpriv->cfg->mod_params->b_inactiveps;
+	rtlpriv->psc.b_swctrl_lps = rtlpriv->cfg->mod_params->b_swctrl_lps;
+	rtlpriv->psc.b_fwctrl_lps = rtlpriv->cfg->mod_params->b_fwctrl_lps;
+	rtlpriv->psc.b_reg_fwctrl_lps = 3;
+	rtlpriv->psc.reg_max_lps_awakeintvl = 5;
+	/* for ASPM, you can close aspm through
+	 * set const_support_pciaspm = 0 */
+	rtl92ee_init_aspm_vars(hw);
+
+	if (rtlpriv->psc.b_reg_fwctrl_lps == 1)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_MIN_MODE;
+	else if (rtlpriv->psc.b_reg_fwctrl_lps == 2)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_MAX_MODE;
+	else if (rtlpriv->psc.b_reg_fwctrl_lps == 3)
+		rtlpriv->psc.fwctrl_psmode = FW_PS_DTIM_MODE;
+
+	/* for early mode */
+	rtlpriv->rtlhal.b_earlymode_enable = false;
+
+	/*low power */
+	rtlpriv->psc.b_low_power_enable = false;
+
+
+	/* for firmware buf */
+	rtlpriv->rtlhal.pfirmware = vmalloc(0x8000);
+	if (!rtlpriv->rtlhal.pfirmware) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Can't alloc buffer for fw.\n"));
+		return 1;
+	}
+
+	fw_name = "rtlwifi/rtl8192eefw.bin";
+	err = request_firmware(&firmware, fw_name, rtlpriv->io.dev);
+
+	if (err) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Failed to request firmware!\n"));
+		return 1;
+	}
+	if (firmware->size > 0x8000) {
+		RT_TRACE(COMP_ERR, DBG_EMERG,
+			 ("Firmware is too big!\n"));
+		release_firmware(firmware);
+		return 1;
+	}
+	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
+	rtlpriv->rtlhal.fwsize = firmware->size;
+	release_firmware(firmware);
+
+	return err;
+}
+
+void rtl92ee_deinit_sw_vars(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	if (rtlpriv->rtlhal.pfirmware) {
+		vfree(rtlpriv->rtlhal.pfirmware);
+		rtlpriv->rtlhal.pfirmware = NULL;
+	}
+}
+
+/* get bt coexist status */
+bool rtl92ee_get_btc_status(void)
+{
+	return true;
+}
+
+
+static struct rtl_hal_ops rtl8192ee_hal_ops = {
+	.init_sw_vars = rtl92ee_init_sw_vars,
+	.deinit_sw_vars = rtl92ee_deinit_sw_vars,
+	.read_eeprom_info = rtl92ee_read_eeprom_info,
+	.interrupt_recognized = rtl92ee_interrupt_recognized,/*need check*/
+	.hw_init = rtl92ee_hw_init,
+	.hw_disable = rtl92ee_card_disable,
+	.hw_suspend = rtl92ee_suspend,
+	.hw_resume = rtl92ee_resume,
+	.enable_interrupt = rtl92ee_enable_interrupt,
+	.disable_interrupt = rtl92ee_disable_interrupt,
+	.set_network_type = rtl92ee_set_network_type,
+	.set_chk_bssid = rtl92ee_set_check_bssid,
+	.set_qos = rtl92ee_set_qos,
+	.set_bcn_reg = rtl92ee_set_beacon_related_registers,
+	.set_bcn_intv = rtl92ee_set_beacon_interval,
+	.update_interrupt_mask = rtl92ee_update_interrupt_mask,
+	.get_hw_reg = rtl92ee_get_hw_reg,
+	.set_hw_reg = rtl92ee_set_hw_reg,
+	.update_rate_tbl = rtl92ee_update_hal_rate_tbl,
+	.pre_fill_tx_bd_desc = rtl92ee_pre_fill_tx_bd_desc,
+	.rx_desc_buff_remained_cnt = rtl92ee_rx_desc_buff_remained_cnt,
+	.rx_check_dma_ok = rtl92ee_rx_check_dma_ok,
+	.fill_tx_desc = rtl92ee_tx_fill_desc,
+	.fill_tx_cmddesc = rtl92ee_tx_fill_cmddesc,
+	.query_rx_desc = rtl92ee_rx_query_desc,
+	.set_channel_access = rtl92ee_update_channel_access_setting,
+	.radio_onoff_checking = rtl92ee_gpio_radio_on_off_checking,
+	.set_bw_mode = rtl92ee_phy_set_bw_mode,
+	.switch_channel = rtl92ee_phy_sw_chnl,
+	.dm_watchdog = rtl92ee_dm_watchdog,
+	.scan_operation_backup = rtl92ee_phy_scan_operation_backup,
+	.set_rf_power_state = rtl92ee_phy_set_rf_power_state,
+	.led_control = rtl92ee_led_control,
+	.set_desc = rtl92ee_set_desc,
+	.get_desc = rtl92ee_get_desc,
+	.is_tx_desc_closed = rtl92ee_is_tx_desc_closed,
+	.enable_hw_sec = rtl92ee_enable_hw_security_config,
+	.set_key = rtl92ee_set_key,
+	.init_sw_leds = rtl92ee_init_sw_leds,
+	.allow_all_destaddr = rtl92ee_allow_all_destaddr,
+	.get_bbreg = rtl92ee_phy_query_bb_reg,
+	.set_bbreg = rtl92ee_phy_set_bb_reg,
+	.get_rfreg = rtl92ee_phy_query_rf_reg,
+	.set_rfreg = rtl92ee_phy_set_rf_reg,
+	.fill_h2c_cmd = rtl92ee_fill_h2c_cmd,
+	.get_btc_status = rtl92ee_get_btc_status,
+	.rx_command_packet = rtl92ee_rx_command_packet,
+};
+
+static struct rtl_mod_params rtl92ee_mod_params = {
+	.sw_crypto = false,
+	.b_inactiveps = true,
+	.b_swctrl_lps = false,
+	.b_fwctrl_lps = true,
+	.debug = DBG_EMERG,
+};
+
+static struct rtl_hal_cfg rtl92ee_hal_cfg = {
+	.bar_id = 2,
+	.write_readback = true,
+	.name = "rtl92ee_pci",
+	.fw_name = "rtlwifi/rtl8192eefw.bin",
+	.ops = &rtl8192ee_hal_ops,
+	.mod_params = &rtl92ee_mod_params,
+
+	.maps[SYS_ISO_CTRL] = REG_SYS_ISO_CTRL,
+	.maps[SYS_FUNC_EN] = REG_SYS_FUNC_EN,
+	.maps[SYS_CLK] = REG_SYS_CLKR,
+	.maps[MAC_RCR_AM] = AM,
+	.maps[MAC_RCR_AB] = AB,
+	.maps[MAC_RCR_ACRC32] = ACRC32,
+	.maps[MAC_RCR_ACF] = ACF,
+	.maps[MAC_RCR_AAP] = AAP,
+	.maps[MAC_HIMR] = REG_HIMR,
+	.maps[MAC_HIMRE] = REG_HIMRE,
+
+	.maps[EFUSE_ACCESS] = REG_EFUSE_ACCESS,
+
+	.maps[EFUSE_TEST] = REG_EFUSE_TEST,
+	.maps[EFUSE_CTRL] = REG_EFUSE_CTRL,
+	.maps[EFUSE_CLK] = 0,
+	.maps[EFUSE_CLK_CTRL] = REG_EFUSE_CTRL,
+	.maps[EFUSE_PWC_EV12V] = PWC_EV12V,
+	.maps[EFUSE_FEN_ELDR] = FEN_ELDR,
+	.maps[EFUSE_LOADER_CLK_EN] = LOADER_CLK_EN,
+	.maps[EFUSE_ANA8M] = ANA8M,
+	.maps[EFUSE_HWSET_MAX_SIZE] = HWSET_MAX_SIZE,
+	.maps[EFUSE_MAX_SECTION_MAP] = EFUSE_MAX_SECTION,
+	.maps[EFUSE_REAL_CONTENT_SIZE] = EFUSE_REAL_CONTENT_LEN,
+	.maps[EFUSE_OOB_PROTECT_BYTES_LEN] = EFUSE_OOB_PROTECT_BYTES,
+
+	.maps[RWCAM] = REG_CAMCMD,
+	.maps[WCAMI] = REG_CAMWRITE,
+	.maps[RCAMO] = REG_CAMREAD,
+	.maps[CAMDBG] = REG_CAMDBG,
+	.maps[SECR] = REG_SECCFG,
+	.maps[SEC_CAM_NONE] = CAM_NONE,
+	.maps[SEC_CAM_WEP40] = CAM_WEP40,
+	.maps[SEC_CAM_TKIP] = CAM_TKIP,
+	.maps[SEC_CAM_AES] = CAM_AES,
+	.maps[SEC_CAM_WEP104] = CAM_WEP104,
+
+	.maps[RTL_IMR_BCNDMAINT6] = IMR_BCNDMAINT6,
+	.maps[RTL_IMR_BCNDMAINT5] = IMR_BCNDMAINT5,
+	.maps[RTL_IMR_BCNDMAINT4] = IMR_BCNDMAINT4,
+	.maps[RTL_IMR_BCNDMAINT3] = IMR_BCNDMAINT3,
+	.maps[RTL_IMR_BCNDMAINT2] = IMR_BCNDMAINT2,
+	.maps[RTL_IMR_BCNDMAINT1] = IMR_BCNDMAINT1,
+/*	.maps[RTL_IMR_BCNDOK8] = IMR_BCNDOK8,     */   /*need check*/
+	.maps[RTL_IMR_BCNDOK7] = IMR_BCNDOK7,
+	.maps[RTL_IMR_BCNDOK6] = IMR_BCNDOK6,
+	.maps[RTL_IMR_BCNDOK5] = IMR_BCNDOK5,
+	.maps[RTL_IMR_BCNDOK4] = IMR_BCNDOK4,
+	.maps[RTL_IMR_BCNDOK3] = IMR_BCNDOK3,
+	.maps[RTL_IMR_BCNDOK2] = IMR_BCNDOK2,
+	.maps[RTL_IMR_BCNDOK1] = IMR_BCNDOK1,
+/*	.maps[RTL_IMR_TIMEOUT2] = IMR_TIMEOUT2,*/
+/*	.maps[RTL_IMR_TIMEOUT1] = IMR_TIMEOUT1,*/
+
+	.maps[RTL_IMR_TXFOVW] = IMR_TXFOVW,
+	.maps[RTL_IMR_PSTIMEOUT] = IMR_PSTIMEOUT,
+	.maps[RTL_IMR_BcnInt] = IMR_BCNDMAINT0,
+	.maps[RTL_IMR_RXFOVW] = IMR_RXFOVW,
+	.maps[RTL_IMR_RDU] = IMR_RDU,
+	.maps[RTL_IMR_ATIMEND] = IMR_ATIMEND,
+	.maps[RTL_IMR_BDOK] = IMR_BCNDOK0,
+	.maps[RTL_IMR_MGNTDOK] = IMR_MGNTDOK,
+	.maps[RTL_IMR_TBDER] = IMR_TBDER,
+	.maps[RTL_IMR_HIGHDOK] = IMR_HIGHDOK,
+	.maps[RTL_IMR_TBDOK] = IMR_TBDOK,
+	.maps[RTL_IMR_BKDOK] = IMR_BKDOK,
+	.maps[RTL_IMR_BEDOK] = IMR_BEDOK,
+	.maps[RTL_IMR_VIDOK] = IMR_VIDOK,
+	.maps[RTL_IMR_VODOK] = IMR_VODOK,
+	.maps[RTL_IMR_ROK] = IMR_ROK,
+	.maps[RTL_IBSS_INT_MASKS] = (IMR_BCNDMAINT0 | IMR_TBDOK | IMR_TBDER),
+
+	.maps[RTL_RC_CCK_RATE1M] = DESC92C_RATE1M,
+	.maps[RTL_RC_CCK_RATE2M] = DESC92C_RATE2M,
+	.maps[RTL_RC_CCK_RATE5_5M] = DESC92C_RATE5_5M,
+	.maps[RTL_RC_CCK_RATE11M] = DESC92C_RATE11M,
+	.maps[RTL_RC_OFDM_RATE6M] = DESC92C_RATE6M,
+	.maps[RTL_RC_OFDM_RATE9M] = DESC92C_RATE9M,
+	.maps[RTL_RC_OFDM_RATE12M] = DESC92C_RATE12M,
+	.maps[RTL_RC_OFDM_RATE18M] = DESC92C_RATE18M,
+	.maps[RTL_RC_OFDM_RATE24M] = DESC92C_RATE24M,
+	.maps[RTL_RC_OFDM_RATE36M] = DESC92C_RATE36M,
+	.maps[RTL_RC_OFDM_RATE48M] = DESC92C_RATE48M,
+	.maps[RTL_RC_OFDM_RATE54M] = DESC92C_RATE54M,
+
+	.maps[RTL_RC_HT_RATEMCS7] = DESC92C_RATEMCS7,
+	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
+};
+
+static struct pci_device_id rtl92ee_pci_ids[] = {
+	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x818B, rtl92ee_hal_cfg)},
+	{},
+};
+
+MODULE_DEVICE_TABLE(pci, rtl92ee_pci_ids);
+
+MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com>");
+MODULE_AUTHOR("Larry Finger	<Larry.Finger@lwfinger.net>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Realtek 8192E 802.11n PCI wireless");
+MODULE_FIRMWARE("rtlwifi/rtl8192eefw.bin");
+
+module_param_named(swenc, rtl92ee_mod_params.sw_crypto, bool, 0444);
+module_param_named(debug, rtl92ee_mod_params.debug, int, 0444);
+module_param_named(ips, rtl92ee_mod_params.b_inactiveps, bool, 0444);
+module_param_named(swlps, rtl92ee_mod_params.b_swctrl_lps, bool, 0444);
+module_param_named(fwlps, rtl92ee_mod_params.b_fwctrl_lps, bool, 0444);
+MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
+MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
+MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
+MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
+
+static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, stg_rtl_pci_suspend,
+			 stg_rtl_pci_resume);
+
+static struct pci_driver rtl92ee_driver = {
+	.name = KBUILD_MODNAME,
+	.id_table = rtl92ee_pci_ids,
+	.probe = stg_rtl_pci_probe,
+	.remove = stg_rtl_pci_disconnect,
+
+	.driver.pm = &rtlwifi_pm_ops,
+};
+
+static int __init rtl92ee_module_init(void)
+{
+	int ret;
+	ret = rtl_core_module_init();
+	if (ret)
+		return ret;
+
+	ret = pci_register_driver(&rtl92ee_driver);
+	if (ret)
+		RT_ASSERT(false, (": No device found\n"));
+
+	return ret;
+}
+
+static void __exit rtl92ee_module_exit(void)
+{
+	pci_unregister_driver(&rtl92ee_driver);
+	rtl_core_module_exit();
+}
+
+module_init(rtl92ee_module_init);
+module_exit(rtl92ee_module_exit);
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/sw.h b/drivers/staging/rtl8192ee/rtl8192ee/sw.h
new file mode 100644
index 0000000..0170257
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/sw.h
@@ -0,0 +1,39 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_SW_H__
+#define __RTL92E_SW_H__
+
+int rtl92ee_init_sw_vars(struct ieee80211_hw *hw);
+void rtl92ee_deinit_sw_vars(struct ieee80211_hw *hw);
+bool rtl92ee_get_btc_status(void);
+int rtl_core_module_init(void);
+void rtl_core_module_exit(void);
+
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/table.c b/drivers/staging/rtl8192ee/rtl8192ee/table.c
new file mode 100644
index 0000000..c7eb9be
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/table.c
@@ -0,0 +1,882 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "table.h"
+u32 RTL8192EE_PHY_REG_ARRAY[] = {
+		0x800, 0x80040000,
+		0x804, 0x00000003,
+		0x808, 0x0000FC00,
+		0x80C, 0x0000000A,
+		0x810, 0x10001331,
+		0x814, 0x020C3D10,
+		0x818, 0x02220385,
+		0x81C, 0x00000000,
+		0x820, 0x01000100,
+		0x824, 0x00390204,
+		0x828, 0x01000100,
+		0x82C, 0x00390204,
+		0x830, 0x32323232,
+		0x834, 0x30303030,
+		0x838, 0x30303030,
+		0x83C, 0x30303030,
+		0x840, 0x00010000,
+		0x844, 0x00010000,
+		0x848, 0x28282828,
+		0x84C, 0x28282828,
+		0x850, 0x00000000,
+		0x854, 0x00000000,
+		0x858, 0x009A009A,
+		0x85C, 0x01000014,
+		0x860, 0x66F60000,
+		0x864, 0x061F0000,
+		0x868, 0x30303030,
+		0x86C, 0x30303030,
+		0x870, 0x00000000,
+		0x874, 0x55004200,
+		0x878, 0x08080808,
+		0x87C, 0x00000000,
+		0x880, 0xB0000C1C,
+		0x884, 0x00000001,
+		0x888, 0x00000000,
+		0x88C, 0xCC0000C0,
+		0x890, 0x00000800,
+		0x894, 0xFFFFFFFE,
+		0x898, 0x40302010,
+		0x900, 0x00000000,
+		0x904, 0x00000023,
+		0x908, 0x00000000,
+		0x90C, 0x81121313,
+		0x910, 0x806C0001,
+		0x914, 0x00000001,
+		0x918, 0x00000000,
+		0x91C, 0x00010000,
+		0x924, 0x00000001,
+		0x928, 0x00000000,
+		0x92C, 0x00000000,
+		0x930, 0x00000000,
+		0x934, 0x00000000,
+		0x938, 0x00000000,
+		0x93C, 0x00000000,
+		0x940, 0x00000000,
+		0x944, 0x00000000,
+		0x94C, 0x00000008,
+		0xA00, 0x00D0C7C8,
+		0xA04, 0x81FF000C,
+		0xA08, 0x8C838300,
+		0xA0C, 0x2E68120F,
+		0xA10, 0x95009B78,
+		0xA14, 0x1114D028,
+		0xA18, 0x00881117,
+		0xA1C, 0x89140F00,
+		0xA20, 0x1A1B0000,
+		0xA24, 0x090E1317,
+		0xA28, 0x00000204,
+		0xA2C, 0x00D30000,
+		0xA70, 0x101FBF00,
+		0xA74, 0x00000007,
+		0xA78, 0x00000900,
+		0xA7C, 0x225B0606,
+		0xA80, 0x218075B1,
+		0xB38, 0x00000000,
+		0xC00, 0x48071D40,
+		0xC04, 0x03A05633,
+		0xC08, 0x000000E4,
+		0xC0C, 0x6C6C6C6C,
+		0xC10, 0x08800000,
+		0xC14, 0x40000100,
+		0xC18, 0x08800000,
+		0xC1C, 0x40000100,
+		0xC20, 0x00000000,
+		0xC24, 0x00000000,
+		0xC28, 0x00000000,
+		0xC2C, 0x00000000,
+		0xC30, 0x69E9AC47,
+		0xC34, 0x469652AF,
+		0xC38, 0x49795994,
+		0xC3C, 0x0A97971C,
+		0xC40, 0x1F7C403F,
+		0xC44, 0x000100B7,
+		0xC48, 0xEC020107,
+		0xC4C, 0x007F037F,
+	0xFF010718, 0xABCD,
+		0xC50, 0x00340220,
+	0xCDCDCDCD, 0xCDCD,
+		0xC50, 0x00340020,
+	0xFF010718, 0xDEAD,
+		0xC54, 0x0080801F,
+	0xFF010718, 0xABCD,
+		0xC58, 0x00000220,
+	0xCDCDCDCD, 0xCDCD,
+		0xC58, 0x00000020,
+	0xFF010718, 0xDEAD,
+		0xC5C, 0x00248492,
+		0xC60, 0x00000000,
+		0xC64, 0x7112848B,
+		0xC68, 0x47C00BFF,
+		0xC6C, 0x00000036,
+		0xC70, 0x00000600,
+		0xC74, 0x02013169,
+		0xC78, 0x0000001F,
+		0xC7C, 0x00B91612,
+	0xFF010718, 0xABCD,
+		0xC80, 0x2D4000B5,
+	0xCDCDCDCD, 0xCDCD,
+		0xC80, 0x40000100,
+	0xFF010718, 0xDEAD,
+		0xC84, 0x21F60000,
+	0xFF010718, 0xABCD,
+		0xC88, 0x2D4000B5,
+	0xCDCDCDCD, 0xCDCD,
+		0xC88, 0x40000100,
+	0xFF010718, 0xDEAD,
+		0xC8C, 0xA0E40000,
+		0xC90, 0x00121820,
+		0xC94, 0x00000000,
+		0xC98, 0x00121820,
+		0xC9C, 0x00007F7F,
+		0xCA0, 0x00000000,
+		0xCA4, 0x000300A0,
+		0xCA8, 0x00000000,
+		0xCAC, 0x00000000,
+		0xCB0, 0x00000000,
+		0xCB4, 0x00000000,
+		0xCB8, 0x00000000,
+		0xCBC, 0x28000000,
+		0xCC0, 0x00000000,
+		0xCC4, 0x00000000,
+		0xCC8, 0x00000000,
+		0xCCC, 0x00000000,
+		0xCD0, 0x00000000,
+		0xCD4, 0x00000000,
+		0xCD8, 0x64B22427,
+		0xCDC, 0x00766932,
+		0xCE0, 0x00222222,
+		0xCE4, 0x00040000,
+		0xCE8, 0x77644302,
+		0xCEC, 0x2F97D40C,
+		0xD00, 0x00080740,
+		0xD04, 0x00020403,
+		0xD08, 0x0000907F,
+		0xD0C, 0x20010201,
+		0xD10, 0xA0633333,
+		0xD14, 0x3333BC43,
+		0xD18, 0x7A8F5B6B,
+		0xD1C, 0x0000007F,
+		0xD2C, 0xCC979975,
+		0xD30, 0x00000000,
+		0xD34, 0x80608000,
+		0xD38, 0x00000000,
+		0xD3C, 0x00127353,
+		0xD40, 0x00000000,
+		0xD44, 0x00000000,
+		0xD48, 0x00000000,
+		0xD4C, 0x00000000,
+		0xD50, 0x6437140A,
+		0xD54, 0x00000000,
+		0xD58, 0x00000282,
+		0xD5C, 0x30032064,
+		0xD60, 0x4653DE68,
+		0xD64, 0x04518A3C,
+		0xD68, 0x00002101,
+		0xD6C, 0x2A201C16,
+		0xD70, 0x1812362E,
+		0xD74, 0x322C2220,
+		0xD78, 0x000E3C24,
+		0xD80, 0x01081008,
+		0xD84, 0x00000800,
+		0xD88, 0xF0B50000,
+		0xE00, 0x30303030,
+		0xE04, 0x30303030,
+		0xE08, 0x03903030,
+		0xE10, 0x30303030,
+		0xE14, 0x30303030,
+		0xE18, 0x30303030,
+		0xE1C, 0x30303030,
+		0xE28, 0x00000000,
+		0xE30, 0x1000DC1F,
+		0xE34, 0x10008C1F,
+		0xE38, 0x02140102,
+		0xE3C, 0x681604C2,
+		0xE40, 0x01007C00,
+		0xE44, 0x01004800,
+		0xE48, 0xFB000000,
+		0xE4C, 0x000028D1,
+		0xE50, 0x1000DC1F,
+		0xE54, 0x10008C1F,
+		0xE58, 0x02140102,
+		0xE5C, 0x28160D05,
+		0xE60, 0x00000008,
+		0xE68, 0x0FC05656,
+		0xE6C, 0x03C09696,
+		0xE70, 0x03C09696,
+		0xE74, 0x0C005656,
+		0xE78, 0x0C005656,
+		0xE7C, 0x0C005656,
+		0xE80, 0x0C005656,
+		0xE84, 0x03C09696,
+		0xE88, 0x0C005656,
+		0xE8C, 0x03C09696,
+		0xED0, 0x03C09696,
+		0xED4, 0x03C09696,
+		0xED8, 0x03C09696,
+		0xEDC, 0x0000D6D6,
+		0xEE0, 0x0000D6D6,
+		0xEEC, 0x0FC01616,
+		0xEE4, 0xB0000C1C,
+		0xEE8, 0x00000001,
+		0xF14, 0x00000003,
+		0xF4C, 0x00000000,
+		0xF00, 0x00000300,
+};
+
+u32 RTL8192EE_PHY_REG_ARRAY_PG[] = {
+	0, 0, 0, 0x00000e08, 0x0000ff00, 0x00003200,
+	0, 0, 1, 0x00000e08, 0x0000ff00, 0x00003200,
+	0, 0, 0, 0x0000086c, 0xffffff00, 0x32323200,
+	0, 0, 1, 0x0000086c, 0xffffff00, 0x32323200,
+	0, 0, 0, 0x00000e00, 0xffffffff, 0x34343636,
+	0, 0, 1, 0x00000e00, 0xffffffff, 0x34343636,
+	0, 0, 0, 0x00000e04, 0xffffffff, 0x28283032,
+	0, 0, 1, 0x00000e04, 0xffffffff, 0x28283032,
+	0, 0, 0, 0x00000e10, 0xffffffff, 0x34363840,
+	0, 0, 1, 0x00000e10, 0xffffffff, 0x34363840,
+	0, 0, 0, 0x00000e14, 0xffffffff, 0x26283032,
+	0, 0, 1, 0x00000e14, 0xffffffff, 0x26283032,
+	0, 0, 1, 0x00000e18, 0xffffffff, 0x36384040,
+	0, 0, 1, 0x00000e1c, 0xffffffff, 0x24262832,
+	0, 1, 0, 0x00000838, 0xffffff00, 0x32323200,
+	0, 1, 1, 0x00000838, 0xffffff00, 0x32323200,
+	0, 1, 0, 0x0000086c, 0x000000ff, 0x00000032,
+	0, 1, 1, 0x0000086c, 0x000000ff, 0x00000032,
+	0, 1, 0, 0x00000830, 0xffffffff, 0x34343636,
+	0, 1, 1, 0x00000830, 0xffffffff, 0x34343636,
+	0, 1, 0, 0x00000834, 0xffffffff, 0x28283032,
+	0, 1, 1, 0x00000834, 0xffffffff, 0x28283032,
+	0, 1, 0, 0x0000083c, 0xffffffff, 0x34363840,
+	0, 1, 1, 0x0000083c, 0xffffffff, 0x34363840,
+	0, 1, 0, 0x00000848, 0xffffffff, 0x26283032,
+	0, 1, 1, 0x00000848, 0xffffffff, 0x26283032,
+	0, 1, 1, 0x0000084c, 0xffffffff, 0x36384040,
+	0, 1, 1, 0x00000868, 0xffffffff, 0x24262832
+};
+
+u32 RTL8192EE_RADIOA_ARRAY[] = {
+		0x07F, 0x00000082,
+		0x081, 0x0003FC00,
+		0x000, 0x00030000,
+		0x008, 0x00008400,
+		0x018, 0x00000407,
+		0x019, 0x00000012,
+		0x01B, 0x00000064,
+		0x01E, 0x00080009,
+		0x01F, 0x00000880,
+		0x02F, 0x0001A060,
+		0x03F, 0x00000000,
+		0x042, 0x000060C0,
+		0x057, 0x000D0000,
+		0x058, 0x000BE180,
+		0x067, 0x00001552,
+		0x083, 0x00000000,
+		0x0B0, 0x000FF9F1,
+		0x0B1, 0x00055418,
+		0x0B2, 0x0008CC00,
+		0x0B4, 0x00043083,
+		0x0B5, 0x00008166,
+		0x0B6, 0x0000803E,
+		0x0B7, 0x0001C69F,
+		0x0B8, 0x0000407F,
+		0x0B9, 0x00080001,
+		0x0BA, 0x00040001,
+		0x0BB, 0x00000400,
+		0x0BF, 0x000C0000,
+		0x0C2, 0x00002400,
+		0x0C3, 0x00000009,
+		0x0C4, 0x00040C91,
+		0x0C5, 0x00099999,
+		0x0C6, 0x000000A3,
+		0x0C7, 0x00088820,
+		0x0C8, 0x00076C06,
+		0x0C9, 0x00000000,
+		0x0CA, 0x00080000,
+		0x0DF, 0x00000180,
+		0x0EF, 0x000001A0,
+		0x051, 0x00069545,
+		0x052, 0x0007E45E,
+		0x053, 0x00000071,
+		0x056, 0x00051FF3,
+		0x035, 0x000000A8,
+		0x035, 0x000001E2,
+		0x035, 0x000002A8,
+		0x036, 0x00001C24,
+		0x036, 0x00009C24,
+		0x036, 0x00011C24,
+		0x036, 0x00019C24,
+		0x018, 0x00000C07,
+		0x05A, 0x00048000,
+		0x019, 0x000739D0,
+	0xFF010718, 0xABCD,
+		0x034, 0x0000A093,
+		0x034, 0x0000908F,
+		0x034, 0x0000808C,
+		0x034, 0x0000704D,
+		0x034, 0x0000604A,
+		0x034, 0x00005047,
+		0x034, 0x0000400A,
+		0x034, 0x00003007,
+		0x034, 0x00002004,
+		0x034, 0x00001001,
+		0x034, 0x00000000,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000ADD7,
+		0x034, 0x00009DD4,
+		0x034, 0x00008DD1,
+		0x034, 0x00007DCE,
+		0x034, 0x00006DCB,
+		0x034, 0x00005DC8,
+		0x034, 0x00004DC5,
+		0x034, 0x000034CC,
+		0x034, 0x0000244F,
+		0x034, 0x0000144C,
+		0x034, 0x00000014,
+	0xFF010718, 0xDEAD,
+		0x000, 0x00030159,
+		0x084, 0x00068180,
+		0x086, 0x0000014E,
+		0x087, 0x00048E00,
+		0x08E, 0x00065540,
+		0x08F, 0x00088000,
+		0x0EF, 0x000020A0,
+	0xFF010718, 0xABCD,
+		0x03B, 0x000F07B0,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x000F02B0,
+	0xFF010718, 0xDEAD,
+		0x03B, 0x000EF7B0,
+		0x03B, 0x000D4FB0,
+		0x03B, 0x000CF060,
+		0x03B, 0x000B0090,
+		0x03B, 0x000A0080,
+		0x03B, 0x00090080,
+		0x03B, 0x0008F780,
+	0xFF010718, 0xABCD,
+		0x03B, 0x000787B0,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x00078730,
+	0xFF010718, 0xDEAD,
+		0x03B, 0x00060FB0,
+		0x03B, 0x0005FFA0,
+		0x03B, 0x00040620,
+		0x03B, 0x00037090,
+		0x03B, 0x00020080,
+		0x03B, 0x0001F060,
+		0x03B, 0x0000FFB0,
+		0x0EF, 0x000000A0,
+		0x0FE, 0x00000000,
+		0x018, 0x0000FC07,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x01E, 0x00000001,
+		0x01F, 0x00080000,
+		0x000, 0x00033E70,
+};
+
+u32 RTL8192EE_RADIOB_ARRAY[] = {
+		0x07F, 0x00000082,
+		0x081, 0x0003FC00,
+		0x000, 0x00030000,
+		0x008, 0x00008400,
+		0x018, 0x00000407,
+		0x019, 0x00000012,
+		0x01B, 0x00000064,
+		0x01E, 0x00080009,
+		0x01F, 0x00000880,
+		0x02F, 0x0001A060,
+		0x03F, 0x00000000,
+		0x042, 0x000060C0,
+		0x057, 0x000D0000,
+		0x058, 0x000BE180,
+		0x067, 0x00001552,
+		0x07F, 0x00000082,
+		0x081, 0x0003F000,
+		0x083, 0x00000000,
+		0x0DF, 0x00000180,
+		0x0EF, 0x000001A0,
+		0x051, 0x00069545,
+		0x052, 0x0007E42E,
+		0x053, 0x00000071,
+		0x056, 0x00051FF3,
+		0x035, 0x000000A8,
+		0x035, 0x000001E0,
+		0x035, 0x000002A8,
+		0x036, 0x00001CA8,
+		0x036, 0x00009C24,
+		0x036, 0x00011C24,
+		0x036, 0x00019C24,
+		0x018, 0x00000C07,
+		0x05A, 0x00048000,
+		0x019, 0x000739D0,
+	0xFF010718, 0xABCD,
+		0x034, 0x0000A093,
+		0x034, 0x0000908F,
+		0x034, 0x0000808C,
+		0x034, 0x0000704D,
+		0x034, 0x0000604A,
+		0x034, 0x00005047,
+		0x034, 0x0000400A,
+		0x034, 0x00003007,
+		0x034, 0x00002004,
+		0x034, 0x00001001,
+		0x034, 0x00000000,
+	0xCDCDCDCD, 0xCDCD,
+		0x034, 0x0000ADD7,
+		0x034, 0x00009DD4,
+		0x034, 0x00008DD1,
+		0x034, 0x00007DCE,
+		0x034, 0x00006DCB,
+		0x034, 0x00005DC8,
+		0x034, 0x00004DC5,
+		0x034, 0x000034CC,
+		0x034, 0x0000244F,
+		0x034, 0x0000144C,
+		0x034, 0x00000014,
+	0xFF010718, 0xDEAD,
+		0x000, 0x00030159,
+		0x084, 0x00068180,
+		0x086, 0x000000CE,
+		0x087, 0x00048A00,
+		0x08E, 0x00065540,
+		0x08F, 0x00088000,
+		0x0EF, 0x000020A0,
+	0xFF010718, 0xABCD,
+		0x03B, 0x000F07B0,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x000F02B0,
+	0xFF010718, 0xDEAD,
+		0x03B, 0x000EF7B0,
+		0x03B, 0x000D4FB0,
+		0x03B, 0x000CF060,
+		0x03B, 0x000B0090,
+		0x03B, 0x000A0080,
+		0x03B, 0x00090080,
+		0x03B, 0x0008F780,
+	0xFF010718, 0xABCD,
+		0x03B, 0x000787B0,
+	0xCDCDCDCD, 0xCDCD,
+		0x03B, 0x00078730,
+	0xFF010718, 0xDEAD,
+		0x03B, 0x00060FB0,
+		0x03B, 0x0005FFA0,
+		0x03B, 0x00040620,
+		0x03B, 0x00037090,
+		0x03B, 0x00020080,
+		0x03B, 0x0001F060,
+		0x03B, 0x0000FFB0,
+		0x0EF, 0x000000A0,
+		0x000, 0x00010159,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x0FE, 0x00000000,
+		0x01E, 0x00000001,
+		0x01F, 0x00080000,
+		0x000, 0x00033E70,
+};
+
+u32 RTL8192EE_MAC_ARRAY[] = {
+		0x011, 0x000000EB,
+		0x012, 0x00000007,
+		0x014, 0x00000075,
+		0x303, 0x000000A7,
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
+		0x540, 0x00000012,
+		0x541, 0x00000064,
+		0x550, 0x00000010,
+		0x551, 0x00000010,
+		0x559, 0x00000002,
+		0x55C, 0x00000050,
+		0x55D, 0x000000FF,
+		0x605, 0x00000030,
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
+};
+
+u32 RTL8192EE_AGC_TAB_ARRAY[] = {
+	0xFF010718, 0xABCD,
+		0xC78, 0xFA000001,
+		0xC78, 0xF9010001,
+		0xC78, 0xF8020001,
+		0xC78, 0xF7030001,
+		0xC78, 0xF6040001,
+		0xC78, 0xF5050001,
+		0xC78, 0xF4060001,
+		0xC78, 0xF3070001,
+		0xC78, 0xF2080001,
+		0xC78, 0xF1090001,
+		0xC78, 0xF00A0001,
+		0xC78, 0xEF0B0001,
+		0xC78, 0xEE0C0001,
+		0xC78, 0xED0D0001,
+		0xC78, 0xEC0E0001,
+		0xC78, 0xEB0F0001,
+		0xC78, 0xEA100001,
+		0xC78, 0xE9110001,
+		0xC78, 0xE8120001,
+		0xC78, 0xE7130001,
+		0xC78, 0xE6140001,
+		0xC78, 0xE5150001,
+		0xC78, 0xE4160001,
+		0xC78, 0xE3170001,
+		0xC78, 0xE2180001,
+		0xC78, 0xE1190001,
+		0xC78, 0x8A1A0001,
+		0xC78, 0x891B0001,
+		0xC78, 0x881C0001,
+		0xC78, 0x871D0001,
+		0xC78, 0x861E0001,
+		0xC78, 0x851F0001,
+		0xC78, 0x84200001,
+		0xC78, 0x83210001,
+		0xC78, 0x82220001,
+		0xC78, 0x6A230001,
+		0xC78, 0x69240001,
+		0xC78, 0x68250001,
+		0xC78, 0x67260001,
+		0xC78, 0x66270001,
+		0xC78, 0x65280001,
+		0xC78, 0x64290001,
+		0xC78, 0x632A0001,
+		0xC78, 0x622B0001,
+		0xC78, 0x612C0001,
+		0xC78, 0x602D0001,
+		0xC78, 0x472E0001,
+		0xC78, 0x462F0001,
+		0xC78, 0x45300001,
+		0xC78, 0x44310001,
+		0xC78, 0x43320001,
+		0xC78, 0x42330001,
+		0xC78, 0x41340001,
+		0xC78, 0x40350001,
+		0xC78, 0x40360001,
+		0xC78, 0x40370001,
+		0xC78, 0x40380001,
+		0xC78, 0x40390001,
+		0xC78, 0x403A0001,
+		0xC78, 0x403B0001,
+		0xC78, 0x403C0001,
+		0xC78, 0x403D0001,
+		0xC78, 0x403E0001,
+		0xC78, 0x403F0001,
+	0xCDCDCDCD, 0xCDCD,
+		0xC78, 0xFB000001,
+		0xC78, 0xFB010001,
+		0xC78, 0xFB020001,
+		0xC78, 0xFB030001,
+		0xC78, 0xFB040001,
+		0xC78, 0xFB050001,
+		0xC78, 0xFA060001,
+		0xC78, 0xF9070001,
+		0xC78, 0xF8080001,
+		0xC78, 0xF7090001,
+		0xC78, 0xF60A0001,
+		0xC78, 0xF50B0001,
+		0xC78, 0xF40C0001,
+		0xC78, 0xF30D0001,
+		0xC78, 0xF20E0001,
+		0xC78, 0xF10F0001,
+		0xC78, 0xF0100001,
+		0xC78, 0xEF110001,
+		0xC78, 0xEE120001,
+		0xC78, 0xED130001,
+		0xC78, 0xEC140001,
+		0xC78, 0xEB150001,
+		0xC78, 0xEA160001,
+		0xC78, 0xE9170001,
+		0xC78, 0xE8180001,
+		0xC78, 0xE7190001,
+		0xC78, 0xC81A0001,
+		0xC78, 0xC71B0001,
+		0xC78, 0xC61C0001,
+		0xC78, 0x071D0001,
+		0xC78, 0x061E0001,
+		0xC78, 0x051F0001,
+		0xC78, 0x04200001,
+		0xC78, 0x03210001,
+		0xC78, 0xAA220001,
+		0xC78, 0xA9230001,
+		0xC78, 0xA8240001,
+		0xC78, 0xA7250001,
+		0xC78, 0xA6260001,
+		0xC78, 0x85270001,
+		0xC78, 0x84280001,
+		0xC78, 0x83290001,
+		0xC78, 0x252A0001,
+		0xC78, 0x242B0001,
+		0xC78, 0x232C0001,
+		0xC78, 0x222D0001,
+		0xC78, 0x672E0001,
+		0xC78, 0x662F0001,
+		0xC78, 0x65300001,
+		0xC78, 0x64310001,
+		0xC78, 0x63320001,
+		0xC78, 0x62330001,
+		0xC78, 0x61340001,
+		0xC78, 0x45350001,
+		0xC78, 0x44360001,
+		0xC78, 0x43370001,
+		0xC78, 0x42380001,
+		0xC78, 0x41390001,
+		0xC78, 0x403A0001,
+		0xC78, 0x403B0001,
+		0xC78, 0x403C0001,
+		0xC78, 0x403D0001,
+		0xC78, 0x403E0001,
+		0xC78, 0x403F0001,
+	0xFF010718, 0xDEAD,
+	0xFF010718, 0xABCD,
+		0xC78, 0xFA400001,
+		0xC78, 0xF9410001,
+		0xC78, 0xF8420001,
+		0xC78, 0xF7430001,
+		0xC78, 0xF6440001,
+		0xC78, 0xF5450001,
+		0xC78, 0xF4460001,
+		0xC78, 0xF3470001,
+		0xC78, 0xF2480001,
+		0xC78, 0xF1490001,
+		0xC78, 0xF04A0001,
+		0xC78, 0xEF4B0001,
+		0xC78, 0xEE4C0001,
+		0xC78, 0xED4D0001,
+		0xC78, 0xEC4E0001,
+		0xC78, 0xEB4F0001,
+		0xC78, 0xEA500001,
+		0xC78, 0xE9510001,
+		0xC78, 0xE8520001,
+		0xC78, 0xE7530001,
+		0xC78, 0xE6540001,
+		0xC78, 0xE5550001,
+		0xC78, 0xE4560001,
+		0xC78, 0xE3570001,
+		0xC78, 0xE2580001,
+		0xC78, 0xE1590001,
+		0xC78, 0x8A5A0001,
+		0xC78, 0x895B0001,
+		0xC78, 0x885C0001,
+		0xC78, 0x875D0001,
+		0xC78, 0x865E0001,
+		0xC78, 0x855F0001,
+		0xC78, 0x84600001,
+		0xC78, 0x83610001,
+		0xC78, 0x82620001,
+		0xC78, 0x6A630001,
+		0xC78, 0x69640001,
+		0xC78, 0x68650001,
+		0xC78, 0x67660001,
+		0xC78, 0x66670001,
+		0xC78, 0x65680001,
+		0xC78, 0x64690001,
+		0xC78, 0x636A0001,
+		0xC78, 0x626B0001,
+		0xC78, 0x616C0001,
+		0xC78, 0x606D0001,
+		0xC78, 0x476E0001,
+		0xC78, 0x466F0001,
+		0xC78, 0x45700001,
+		0xC78, 0x44710001,
+		0xC78, 0x43720001,
+		0xC78, 0x42730001,
+		0xC78, 0x41740001,
+		0xC78, 0x40750001,
+		0xC78, 0x40760001,
+		0xC78, 0x40770001,
+		0xC78, 0x40780001,
+		0xC78, 0x40790001,
+		0xC78, 0x407A0001,
+		0xC78, 0x407B0001,
+		0xC78, 0x407C0001,
+		0xC78, 0x407D0001,
+		0xC78, 0x407E0001,
+		0xC78, 0x407F0001,
+		0xC50, 0x00040222,
+		0xC50, 0x00040220,
+	0xCDCDCDCD, 0xCDCD,
+		0xC78, 0xFB400001,
+		0xC78, 0xFB410001,
+		0xC78, 0xFB420001,
+		0xC78, 0xFB430001,
+		0xC78, 0xFB440001,
+		0xC78, 0xFB450001,
+		0xC78, 0xFA460001,
+		0xC78, 0xF9470001,
+		0xC78, 0xF8480001,
+		0xC78, 0xF7490001,
+		0xC78, 0xF64A0001,
+		0xC78, 0xF54B0001,
+		0xC78, 0xF44C0001,
+		0xC78, 0xF34D0001,
+		0xC78, 0xF24E0001,
+		0xC78, 0xF14F0001,
+		0xC78, 0xF0500001,
+		0xC78, 0xEF510001,
+		0xC78, 0xEE520001,
+		0xC78, 0xED530001,
+		0xC78, 0xEC540001,
+		0xC78, 0xEB550001,
+		0xC78, 0xEA560001,
+		0xC78, 0xE9570001,
+		0xC78, 0xE8580001,
+		0xC78, 0xE7590001,
+		0xC78, 0xE65A0001,
+		0xC78, 0xE55B0001,
+		0xC78, 0xE45C0001,
+		0xC78, 0xE35D0001,
+		0xC78, 0xE25E0001,
+		0xC78, 0xE15F0001,
+		0xC78, 0x8A600001,
+		0xC78, 0x89610001,
+		0xC78, 0x88620001,
+		0xC78, 0x87630001,
+		0xC78, 0x86640001,
+		0xC78, 0x85650001,
+		0xC78, 0x84660001,
+		0xC78, 0x83670001,
+		0xC78, 0x82680001,
+		0xC78, 0x6B690001,
+		0xC78, 0x6A6A0001,
+		0xC78, 0x696B0001,
+		0xC78, 0x686C0001,
+		0xC78, 0x676D0001,
+		0xC78, 0x666E0001,
+		0xC78, 0x656F0001,
+		0xC78, 0x64700001,
+		0xC78, 0x63710001,
+		0xC78, 0x62720001,
+		0xC78, 0x61730001,
+		0xC78, 0x49740001,
+		0xC78, 0x48750001,
+		0xC78, 0x47760001,
+		0xC78, 0x46770001,
+		0xC78, 0x45780001,
+		0xC78, 0x44790001,
+		0xC78, 0x437A0001,
+		0xC78, 0x427B0001,
+		0xC78, 0x417C0001,
+		0xC78, 0x407D0001,
+		0xC78, 0x407E0001,
+		0xC78, 0x407F0001,
+		0xC50, 0x00040022,
+		0xC50, 0x00040020,
+	0xFF010718, 0xDEAD,
+};
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/table.h b/drivers/staging/rtl8192ee/rtl8192ee/table.h
new file mode 100644
index 0000000..e0f4198
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/table.h
@@ -0,0 +1,48 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Created on  2010/ 5/18,  1:41
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_TABLE__H_
+#define __RTL92E_TABLE__H_
+
+#include <linux/types.h>
+#define RTL8192EE_PHY_REG_ARRAY_LEN	448
+extern u32 RTL8192EE_PHY_REG_ARRAY[];
+#define RTL8192EE_PHY_REG_ARRAY_PG_LEN	168
+extern u32 RTL8192EE_PHY_REG_ARRAY_PG[];
+#define	RTL8192EE_RADIOA_ARRAY_LEN	238
+extern u32 RTL8192EE_RADIOA_ARRAY[];
+#define	RTL8192EE_RADIOB_ARRAY_LEN	198
+extern u32 RTL8192EE_RADIOB_ARRAY[];
+#define RTL8192EE_MAC_ARRAY_LEN		202
+extern u32 RTL8192EE_MAC_ARRAY[];
+#define RTL8192EE_AGC_TAB_ARRAY_LEN	532
+extern u32 RTL8192EE_AGC_TAB_ARRAY[];
+#endif
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/trx.c b/drivers/staging/rtl8192ee/rtl8192ee/trx.c
new file mode 100644
index 0000000..c930f52
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/trx.c
@@ -0,0 +1,1286 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
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
+#include "fw.h"
+
+static u8 _rtl92ee_map_hwqueue_to_fwqueue(struct sk_buff *skb, u8 hw_queue)
+{
+	__le16 fc = rtl_get_fc(skb);
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
+ * 2.4G band:rx_status->band == IEEE80211_BAND_2GHZ
+ *
+ * B/G rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE1M-->DESC92C_RATE54M ==> idx is 0-->11,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ *
+ * 5G band:rx_status->band == IEEE80211_BAND_5GHZ
+ * A rate:
+ * (rx_status->flag & RX_FLAG_HT) = 0,
+ * DESC92C_RATE6M-->DESC92C_RATE54M ==> idx is 0-->7,
+ *
+ * N rate:
+ * (rx_status->flag & RX_FLAG_HT) = 1,
+ * DESC92C_RATEMCS0-->DESC92C_RATEMCS15 ==> idx is 0-->15
+ */
+static int _rtl92ee_rate_mapping(struct ieee80211_hw *hw,
+				 bool isht, u8 desc_rate)
+{
+	int rate_idx;
+
+	if (!false) {
+		if (IEEE80211_BAND_2GHZ == hw->conf.chandef.chan->band) {
+			switch (desc_rate) {
+			case DESC92C_RATE1M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE2M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE5_5M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE11M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE6M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 7;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 8;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 9;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 10;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 11;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		} else {
+			switch (desc_rate) {
+			case DESC92C_RATE6M:
+				rate_idx = 0;
+				break;
+			case DESC92C_RATE9M:
+				rate_idx = 1;
+				break;
+			case DESC92C_RATE12M:
+				rate_idx = 2;
+				break;
+			case DESC92C_RATE18M:
+				rate_idx = 3;
+				break;
+			case DESC92C_RATE24M:
+				rate_idx = 4;
+				break;
+			case DESC92C_RATE36M:
+				rate_idx = 5;
+				break;
+			case DESC92C_RATE48M:
+				rate_idx = 6;
+				break;
+			case DESC92C_RATE54M:
+				rate_idx = 7;
+				break;
+			default:
+				rate_idx = 0;
+				break;
+			}
+		}
+	} else {
+		switch (desc_rate) {
+		case DESC92C_RATEMCS0:
+			rate_idx = 0;
+			break;
+		case DESC92C_RATEMCS1:
+			rate_idx = 1;
+			break;
+		case DESC92C_RATEMCS2:
+			rate_idx = 2;
+			break;
+		case DESC92C_RATEMCS3:
+			rate_idx = 3;
+			break;
+		case DESC92C_RATEMCS4:
+			rate_idx = 4;
+			break;
+		case DESC92C_RATEMCS5:
+			rate_idx = 5;
+			break;
+		case DESC92C_RATEMCS6:
+			rate_idx = 6;
+			break;
+		case DESC92C_RATEMCS7:
+			rate_idx = 7;
+			break;
+		case DESC92C_RATEMCS8:
+			rate_idx = 8;
+			break;
+		case DESC92C_RATEMCS9:
+			rate_idx = 9;
+			break;
+		case DESC92C_RATEMCS10:
+			rate_idx = 10;
+			break;
+		case DESC92C_RATEMCS11:
+			rate_idx = 11;
+			break;
+		case DESC92C_RATEMCS12:
+			rate_idx = 12;
+			break;
+		case DESC92C_RATEMCS13:
+			rate_idx = 13;
+			break;
+		case DESC92C_RATEMCS14:
+			rate_idx = 14;
+			break;
+		case DESC92C_RATEMCS15:
+			rate_idx = 15;
+			break;
+		default:
+			rate_idx = 0;
+			break;
+		}
+	}
+	return rate_idx;
+}
+
+static void _rtl92ee_query_rxphystatus(struct ieee80211_hw *hw,
+				       struct rtl_stats *pstatus, u8 *pdesc,
+				       struct rx_fwinfo *p_drvinfo,
+				       bool bpacket_match_bssid,
+				       bool bpacket_toself,
+				       bool b_packet_beacon)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct phy_status_rpt *p_phystrpt = (struct phy_status_rpt *)p_drvinfo;
+	char rx_pwr_all = 0, rx_pwr[4];
+	u8 rf_rx_num = 0, evm, pwdb_all;
+	u8 i, max_spatial_stream;
+	u32 rssi, total_rssi = 0;
+	bool b_is_cck = pstatus->b_is_cck;
+	u8 lan_idx , vga_idx;
+
+	/* Record it for next packet processing */
+	pstatus->b_packet_matchbssid = bpacket_match_bssid;
+	pstatus->b_packet_toself = bpacket_toself;
+	pstatus->b_packet_beacon = b_packet_beacon;
+	pstatus->rx_mimo_signalquality[0] = -1;
+	pstatus->rx_mimo_signalquality[1] = -1;
+
+	if (b_is_cck) {
+		u8 cck_highpwr;
+		u8 cck_agc_rpt;
+		/* CCK Driver info Structure is not the same as OFDM packet. */
+		cck_agc_rpt = p_phystrpt->cck_agc_rpt_ofdm_cfosho_a;
+
+		/* (1)Hardware does not provide RSSI for CCK */
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive) */
+		cck_highpwr = (u8) rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2,
+						 BIT(9));
+
+		lan_idx = ((cck_agc_rpt & 0xE0) >> 5);
+		vga_idx = (cck_agc_rpt & 0x1f);
+		switch (lan_idx) {
+		case 7: /*VGA_idx = 27~2*/
+				if (vga_idx <= 27)
+					rx_pwr_all = -100 + 2 * (27 - vga_idx);
+				else
+					rx_pwr_all = -100;
+				break;
+		case 6: /*VGA_idx = 2~0*/
+				rx_pwr_all = -48 + 2 * (2 - vga_idx);
+				break;
+		case 5: /*VGA_idx = 7~5*/
+				rx_pwr_all = -42 + 2 * (7 - vga_idx);
+				break;
+		case 4: /*VGA_idx = 7~4*/
+				rx_pwr_all = -36 + 2 * (7 - vga_idx);
+				break;
+		case 3: /*VGA_idx = 7~0*/
+				rx_pwr_all = -24 + 2 * (7 - vga_idx);
+				break;
+		case 2: /*VGA_idx = 5~0*/
+				if (cck_highpwr)
+					rx_pwr_all = -12 + 2 * (5 - vga_idx);
+				else
+					rx_pwr_all = -6 + 2 * (5 - vga_idx);
+				break;
+		case 1:
+				rx_pwr_all = 8 - 2 * vga_idx;
+				break;
+		case 0:
+				rx_pwr_all = 14 - 2 * vga_idx;
+				break;
+		default:
+				break;
+		}
+		rx_pwr_all += 16;
+		pwdb_all = stg_rtl_query_rxpwrpercentage(rx_pwr_all);
+
+		if (!cck_highpwr) {
+			if (pwdb_all >= 80)
+				pwdb_all = ((pwdb_all - 80) << 1) +
+					   ((pwdb_all - 80) >> 1) + 80;
+			else if ((pwdb_all <= 78) && (pwdb_all >= 20))
+				pwdb_all += 3;
+			if (pwdb_all > 100)
+				pwdb_all = 100;
+		}
+
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->bt_rx_rssi_percentage = pwdb_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3) Get Signal Quality (EVM) */
+		if (bpacket_match_bssid) {
+			u8 sq, sq_rpt;
+
+			if (pstatus->rx_pwdb_all > 40) {
+				sq = 100;
+			} else {
+				sq_rpt = p_phystrpt->cck_sig_qual_ofdm_pwdb_all;
+				if (sq_rpt > 64)
+					sq = 0;
+				else if (sq_rpt < 20)
+					sq = 100;
+				else
+					sq = ((64 - sq_rpt) * 100) / 44;
+			}
+
+			pstatus->signalquality = sq;
+			pstatus->rx_mimo_signalquality[0] = sq;
+			pstatus->rx_mimo_signalquality[1] = -1;
+		}
+	} else {
+		/* (1)Get RSSI for HT rate */
+		for (i = RF90_PATH_A; i < RF6052_MAX_PATH; i++) {
+			/* we will judge RF RX path now. */
+			if (rtlpriv->dm.brfpath_rxenable[i])
+				rf_rx_num++;
+
+			rx_pwr[i] = ((p_phystrpt->path_agc[i].gain & 0x3f) * 2)
+				    - 110;
+
+			pstatus->rx_pwr[i] = rx_pwr[i];
+			/* Translate DBM to percentage. */
+			rssi = stg_rtl_query_rxpwrpercentage(rx_pwr[i]);
+			total_rssi += rssi;
+
+			pstatus->rx_mimo_signalstrength[i] = (u8)rssi;
+		}
+
+		/* (2)PWDB, Average PWDB cacluated by
+		 * hardware (for rate adaptive) */
+		rx_pwr_all = ((p_phystrpt->cck_sig_qual_ofdm_pwdb_all >> 1)
+			      & 0x7f) - 110;
+
+		pwdb_all = stg_rtl_query_rxpwrpercentage(rx_pwr_all);
+		pstatus->rx_pwdb_all = pwdb_all;
+		pstatus->bt_rx_rssi_percentage = pwdb_all;
+		pstatus->rxpower = rx_pwr_all;
+		pstatus->recvsignalpower = rx_pwr_all;
+
+		/* (3)EVM of HT rate */
+		if (pstatus->rate >= DESC92C_RATEMCS8 &&
+		    pstatus->rate <= DESC92C_RATEMCS15)
+			max_spatial_stream = 2;
+		else
+			max_spatial_stream = 1;
+
+		for (i = 0; i < max_spatial_stream; i++) {
+			evm = stg_rtl_evm_db_to_percentage(
+						p_phystrpt->stream_rxevm[i]);
+
+			if (bpacket_match_bssid) {
+				/* Fill value in RFD, Get the first
+				 * spatial stream only */
+				if (i == 0)
+					pstatus->signalquality = (u8)(evm &
+								      0xff);
+				pstatus->rx_mimo_signalquality[i] = (u8)(evm &
+									 0xff);
+			}
+		}
+
+		if (bpacket_match_bssid) {
+			for (i = RF90_PATH_A; i <= RF90_PATH_B; i++)
+				rtl_priv(hw)->dm.cfo_tail[i] =
+					(int)p_phystrpt->path_cfotail[i];
+
+			if (rtl_priv(hw)->dm.packet_count == 0xffffffff)
+				rtl_priv(hw)->dm.packet_count = 0;
+			else
+				rtl_priv(hw)->dm.packet_count++;
+		}
+	}
+
+	/* UI BSS List signal strength(in percentage),
+	 * make it good looking, from 0~100. */
+	if (b_is_cck)
+		pstatus->signalstrength = (u8)(stg_rtl_signal_scale_mapping(hw,
+								     pwdb_all));
+	else if (rf_rx_num != 0)
+		pstatus->signalstrength = (u8)(stg_rtl_signal_scale_mapping(hw,
+						      total_rssi /= rf_rx_num));
+}
+
+static void _rtl92ee_translate_rx_signal_stuff(struct ieee80211_hw *hw,
+					       struct sk_buff *skb,
+					       struct rtl_stats *pstatus,
+					       u8 *pdesc,
+					       struct rx_fwinfo *p_drvinfo)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
+	struct ieee80211_hdr *hdr;
+	u8 *tmp_buf;
+	u8 *praddr;
+	u8 *psaddr;
+	__le16 fc;
+	u16 cpu_fc, type;
+	bool b_packet_matchbssid, b_packet_toself, b_packet_beacon;
+
+	tmp_buf = skb->data + pstatus->rx_drvinfo_size +
+		  pstatus->rx_bufshift + 24;
+
+	hdr = (struct ieee80211_hdr *)tmp_buf;
+	fc = hdr->frame_control;
+	cpu_fc = le16_to_cpu(fc);
+	type = WLAN_FC_GET_TYPE(fc);
+	praddr = hdr->addr1;
+	psaddr = ieee80211_get_SA(hdr);
+	ether_addr_copy(pstatus->psaddr, psaddr);
+
+	b_packet_matchbssid = ((IEEE80211_FTYPE_CTL != type) &&
+			       (ether_addr_equal(mac->bssid,
+						(cpu_fc & IEEE80211_FCTL_TODS) ?
+						hdr->addr1 :
+						(cpu_fc & IEEE80211_FCTL_FROMDS) ?
+						hdr->addr2 : hdr->addr3)) &&
+				(!pstatus->b_hwerror) && (!pstatus->b_crc) &&
+				(!pstatus->b_icv));
+
+	b_packet_toself = b_packet_matchbssid &&
+			 (ether_addr_equal(praddr, rtlefuse->dev_addr));
+
+	if (ieee80211_is_beacon(fc))
+		b_packet_beacon = true;
+	else
+		b_packet_beacon = false;
+
+	if (b_packet_beacon && b_packet_matchbssid)
+		rtl_priv(hw)->dm.dbginfo.num_qry_beacon_pkt++;
+
+	if (b_packet_matchbssid && ieee80211_is_data_qos(fc) &&
+	    !is_multicast_ether_addr(ieee80211_get_DA(hdr))) {
+		struct ieee80211_qos_hdr *hdr_qos =
+					    (struct ieee80211_qos_hdr *)tmp_buf;
+		u16 tid = le16_to_cpu(hdr_qos->qos_ctrl) & 0xf;
+		if (tid != 0 && tid != 3)
+			rtl_priv(hw)->dm.dbginfo.num_non_be_pkt++;
+	}
+	_rtl92ee_query_rxphystatus(hw, pstatus, pdesc, p_drvinfo,
+				   b_packet_matchbssid, b_packet_toself,
+				   b_packet_beacon);
+	stg_rtl_process_phyinfo(hw, tmp_buf, pstatus);
+}
+
+static void _rtl92ee_insert_emcontent(struct rtl_tcb_desc *ptcb_desc,
+				      u8 *virtualaddress)
+{
+	u32 dwtmp = 0;
+	memset(virtualaddress, 0, 8);
+
+	SET_EARLYMODE_PKTNUM(virtualaddress, ptcb_desc->empkt_num);
+	if (ptcb_desc->empkt_num == 1) {
+		dwtmp = ptcb_desc->empkt_len[0];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[0];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[1];
+	}
+	SET_EARLYMODE_LEN0(virtualaddress, dwtmp);
+
+	if (ptcb_desc->empkt_num <= 3) {
+		dwtmp = ptcb_desc->empkt_len[2];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[2];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[3];
+	}
+	SET_EARLYMODE_LEN1(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 5) {
+		dwtmp = ptcb_desc->empkt_len[4];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[4];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[5];
+	}
+	SET_EARLYMODE_LEN2_1(virtualaddress, dwtmp & 0xF);
+	SET_EARLYMODE_LEN2_2(virtualaddress, dwtmp >> 4);
+	if (ptcb_desc->empkt_num <= 7) {
+		dwtmp = ptcb_desc->empkt_len[6];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[6];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[7];
+	}
+	SET_EARLYMODE_LEN3(virtualaddress, dwtmp);
+	if (ptcb_desc->empkt_num <= 9) {
+		dwtmp = ptcb_desc->empkt_len[8];
+	} else {
+		dwtmp = ptcb_desc->empkt_len[8];
+		dwtmp += ((dwtmp % 4) ? (4 - dwtmp % 4) : 0) + 4;
+		dwtmp += ptcb_desc->empkt_len[9];
+	}
+	SET_EARLYMODE_LEN4(virtualaddress, dwtmp);
+}
+
+bool rtl92ee_rx_query_desc(struct ieee80211_hw *hw,
+			   struct rtl_stats *status,
+			   struct ieee80211_rx_status *rx_status,
+			   u8 *pdesc, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rx_fwinfo *p_drvinfo;
+	struct ieee80211_hdr *hdr;
+
+	u32 phystatus = GET_RX_DESC_PHYST(pdesc);
+	status->length = (u16) GET_RX_DESC_PKT_LEN(pdesc);
+	status->rx_drvinfo_size = (u8) GET_RX_DESC_DRV_INFO_SIZE(pdesc) *
+				  RX_DRV_INFO_SIZE_UNIT;
+	status->rx_bufshift = (u8)(GET_RX_DESC_SHIFT(pdesc) & 0x03);
+	status->b_icv = (u16) GET_RX_DESC_ICV(pdesc);
+	status->b_crc = (u16) GET_RX_DESC_CRC32(pdesc);
+	status->b_hwerror = (status->b_crc | status->b_icv);
+	status->decrypted = !GET_RX_DESC_SWDEC(pdesc);
+	status->rate = (u8) GET_RX_DESC_RXMCS(pdesc);
+	status->b_isampdu = (bool)(GET_RX_DESC_PAGGR(pdesc) == 1);
+		status->timestamp_low = GET_RX_DESC_TSFL(pdesc);
+	status->b_is_cck = RX_HAL_IS_CCK_RATE(status->rate);
+
+	status->macid = GET_RX_DESC_MACID(pdesc);
+	if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(2);
+	else if (GET_RX_STATUS_DESC_MAGIC_MATCH(pdesc))
+		status->wake_match = BIT(1);
+	else if (GET_RX_STATUS_DESC_UNICAST_MATCH(pdesc))
+		status->wake_match = BIT(0);
+	else
+		status->wake_match = 0;
+	if (status->wake_match)
+		RT_TRACE(COMP_RXDESC , DBG_LOUD,
+			 ("GGGGGGGGGGGGGet Wakeup Packet!! WakeMatch =%d\n",
+			 status->wake_match));
+	rx_status->freq = hw->conf.chandef.chan->center_freq;
+	rx_status->band = hw->conf.chandef.chan->band;
+
+	hdr = (struct ieee80211_hdr *)(skb->data + status->rx_drvinfo_size +
+				       status->rx_bufshift + 24);
+
+	if (status->b_crc)
+		rx_status->flag |= RX_FLAG_FAILED_FCS_CRC;
+
+	if (status->rx_is40Mhzpacket)
+		rx_status->flag |= RX_FLAG_40MHZ;
+
+	if (status->b_is_ht)
+		rx_status->flag |= RX_FLAG_HT;
+
+	rx_status->flag |= RX_FLAG_MACTIME_MPDU;
+
+	/* hw will set status->decrypted true, if it finds the
+	 * frame is open data frame or mgmt frame. */
+	/* So hw will not decryption robust managment frame
+	 * for IEEE80211w but still set status->decrypted
+	 * true, so here we should set it back to undecrypted
+	 * for IEEE80211w frame, and mac80211 sw will help
+	 * to decrypt it */
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
+			rx_status->flag |= RX_FLAG_DECRYPTED;
+		else
+			rx_status->flag &= ~RX_FLAG_DECRYPTED;
+	}
+
+	/* rate_idx: index of data rate into band's
+	 * supported rates or MCS index if HT rates
+	 * are use (RX_FLAG_HT)*/
+	/* Notice: this is diff with windows define */
+	rx_status->rate_idx = _rtl92ee_rate_mapping(hw,
+						    status->b_is_ht,
+						    status->rate);
+
+	rx_status->mactime = status->timestamp_low;
+	if (phystatus) {
+		p_drvinfo = (struct rx_fwinfo *)(skb->data +
+						 status->rx_bufshift + 24);
+
+		_rtl92ee_translate_rx_signal_stuff(hw, skb, status, pdesc,
+						   p_drvinfo);
+	}
+
+	/*rx_status->qual = status->signal; */
+	rx_status->signal = status->recvsignalpower + 10;
+	/*rx_status->noise = -status->noise; */
+	if (status->packet_report_type == TX_REPORT2) {
+		status->macid_valid_entry[0] =
+			GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
+		status->macid_valid_entry[1] =
+			GET_RX_RPT2_DESC_MACID_VALID_2(pdesc);
+	}
+	return true;
+}
+
+/*in Windows, this == Rx_92EE_Interrupt*/
+void rtl92ee_rx_check_dma_ok(struct ieee80211_hw *hw, u8 *header_desc,
+			     u8 queue_index)
+{
+	u8 first_seg;
+	u8 last_seg;
+	u16 total_len;
+	u16 read_cnt = 0;
+	if (header_desc == NULL)
+		return;
+
+	total_len = (u16)GET_RX_BUFFER_DESC_TOTAL_LENGTH(header_desc);
+
+	first_seg = (u8)GET_RX_BUFFER_DESC_FS(header_desc);
+
+	last_seg = (u8)GET_RX_BUFFER_DESC_LS(header_desc);
+
+	while (total_len == 0 && first_seg == 0 && last_seg == 0) {
+		read_cnt++;
+		total_len = (u16)GET_RX_BUFFER_DESC_TOTAL_LENGTH(header_desc);
+		first_seg = (u8)GET_RX_BUFFER_DESC_FS(header_desc);
+		last_seg = (u8)GET_RX_BUFFER_DESC_LS(header_desc);
+
+		if (read_cnt > 20)
+			break;
+	}
+}
+
+u16 rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw , u8 queue_index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 read_point = 0 , write_point = 0 , remind_cnt = 0;
+	u32 tmp_4byte = 0;
+	static u16 last_read_point;
+	static bool start_rx;
+
+	tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
+	read_point = (u16)((tmp_4byte>>16) & 0x7ff);
+	write_point = (u16)(tmp_4byte & 0x7ff);
+
+	if (write_point != rtlpci->rx_ring[queue_index].next_rx_rp) {
+		RT_TRACE(COMP_RXDESC, DBG_DMESG,
+			 ("!!!write point is 0x%x, reg 0x3B4 value is 0x%x\n",
+			  write_point, tmp_4byte));
+		tmp_4byte = rtl_read_dword(rtlpriv, REG_RXQ_TXBD_IDX);
+		read_point = (u16)((tmp_4byte>>16) & 0x7ff);
+		write_point = (u16)(tmp_4byte & 0x7ff);
+	}
+
+	if (read_point > 0)
+		start_rx = true;
+	if (!start_rx)
+		return 0;
+
+	if ((last_read_point > (RX_DESC_NUM_92E / 2)) &&
+	    (read_point <= (RX_DESC_NUM_92E / 2))) {
+		remind_cnt = RX_DESC_NUM_92E - write_point;
+	} else {
+		remind_cnt = (read_point >= write_point) ?
+			     (read_point - write_point) :
+			     (RX_DESC_NUM_92E - write_point + read_point);
+	}
+
+	if (remind_cnt == 0)
+		return 0;
+
+	rtlpci->rx_ring[queue_index].next_rx_rp = write_point;
+
+	last_read_point = read_point;
+	return remind_cnt;
+}
+
+static u16 get_desc_addr_fr_q(u16 queue_index)
+{
+	u16 desc_address = REG_BEQ_TXBD_IDX;
+
+	switch (queue_index) {
+	case BK_QUEUE:
+			desc_address = REG_BKQ_TXBD_IDX;
+			break;
+	case BE_QUEUE:
+			desc_address = REG_BEQ_TXBD_IDX;
+			break;
+	case VI_QUEUE:
+			desc_address = REG_VIQ_TXBD_IDX;
+			break;
+	case VO_QUEUE:
+			desc_address = REG_VOQ_TXBD_IDX;
+			break;
+	case BEACON_QUEUE:
+			desc_address = REG_BEQ_TXBD_IDX;
+			break;
+	case TXCMD_QUEUE:
+			desc_address = REG_BEQ_TXBD_IDX;
+			break;
+	case MGNT_QUEUE:
+			desc_address = REG_MGQ_TXBD_IDX;
+			break;
+	case HIGH_QUEUE:
+			desc_address = REG_HI0Q_TXBD_IDX;
+			break;
+	case HCCA_QUEUE:
+			desc_address = REG_BEQ_TXBD_IDX;
+			break;
+	default:
+			break;
+	}
+	return desc_address;
+}
+
+void rtl92ee_get_available_desc(struct ieee80211_hw *hw , u8 q_idx)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 point_diff = 0;
+	u16 current_tx_read_point = 0, current_tx_write_point = 0;
+	u32 tmp_4byte;
+	tmp_4byte = rtl_read_dword(rtlpriv,
+				   get_desc_addr_fr_q(q_idx));
+	current_tx_read_point = (u16)((tmp_4byte >> 16) & 0x0fff);
+	current_tx_write_point = (u16)((tmp_4byte) & 0x0fff);
+
+	point_diff = ((current_tx_read_point > current_tx_write_point) ?
+		      (current_tx_read_point - current_tx_write_point) :
+		      (TX_DESC_NUM_92E - current_tx_write_point +
+		       current_tx_read_point));
+
+	rtlpci->tx_ring[q_idx].avl_desc = point_diff;
+}
+
+void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
+				 u8 *tx_bd_desc, u8 *desc, u8 queue_index,
+				 struct sk_buff *skb, dma_addr_t addr)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u32 pkt_len = skb->len;
+	u16 desc_size = 40; /*tx desc size*/
+	u32 psblen = 0;
+	u16 tx_page_size = 0;
+	u32 total_packet_size = 0;
+	u16 current_bd_desc;
+	u8 i = 0;
+	u16 real_desc_size = 0x28;
+	u16	append_early_mode_size = 0;
+#if (RTL8192EE_SEG_NUM == 0)
+	u8 segmentnum = 2;
+#elif (RTL8192EE_SEG_NUM == 1)
+	u8 segmentnum = 4;
+#elif (RTL8192EE_SEG_NUM == 2)
+	u8 segmentnum = 8;
+#endif
+
+	tx_page_size = 2;
+	current_bd_desc = rtlpci->tx_ring[queue_index].cur_tx_wp;
+
+
+	total_packet_size = desc_size+pkt_len;
+
+	if (rtlpriv->rtlhal.b_earlymode_enable)	{
+		if (queue_index < BEACON_QUEUE) {
+			append_early_mode_size = 8;
+			total_packet_size += append_early_mode_size;
+		}
+	}
+
+	if (tx_page_size > 0) {
+		psblen = (pkt_len + real_desc_size + append_early_mode_size) /
+			 (tx_page_size * 128);
+
+		if (psblen * (tx_page_size * 128) < total_packet_size)
+			psblen += 1;
+	}
+
+	/* Reset */
+	SET_TX_BUFF_DESC_LEN_0(tx_bd_desc , 0);
+	SET_TX_BUFF_DESC_PSB(tx_bd_desc , 0);
+	SET_TX_BUFF_DESC_OWN(tx_bd_desc , 0);
+
+	for (i = 1; i < segmentnum; i++) {
+		SET_TXBUFFER_DESC_LEN_WITH_OFFSET(tx_bd_desc, i, 0);
+		SET_TXBUFFER_DESC_AMSDU_WITH_OFFSET(tx_bd_desc, i, 0);
+		SET_TXBUFFER_DESC_ADD_LOW_WITH_OFFSET(tx_bd_desc, i, 0);
+#if (DMA_IS_64BIT == 1)
+		SET_TXBUFFER_DESC_ADD_HIGT_WITH_OFFSET(tx_bd_desc, i, 0);
+#endif
+	}
+	SET_TX_BUFF_DESC_LEN_1(tx_bd_desc, 0);
+	SET_TX_BUFF_DESC_AMSDU_1(tx_bd_desc, 0);
+
+	SET_TX_BUFF_DESC_LEN_2(tx_bd_desc, 0);
+	SET_TX_BUFF_DESC_AMSDU_2(tx_bd_desc, 0);
+	SET_TX_BUFF_DESC_LEN_3(tx_bd_desc, 0);
+	SET_TX_BUFF_DESC_AMSDU_3(tx_bd_desc, 0);
+	/* Clear all status */
+	CLEAR_PCI_TX_DESC_CONTENT(desc, TX_DESC_SIZE);
+
+	if (rtlpriv->rtlhal.b_earlymode_enable) {
+		if (queue_index < BEACON_QUEUE) {
+			/* These macros need braces */
+			SET_TX_BUFF_DESC_LEN_0(tx_bd_desc , desc_size + 8);
+		} else {
+			SET_TX_BUFF_DESC_LEN_0(tx_bd_desc , desc_size);
+		}
+	} else {
+		SET_TX_BUFF_DESC_LEN_0(tx_bd_desc , desc_size);
+	}
+	SET_TX_BUFF_DESC_PSB(tx_bd_desc , psblen);
+	SET_TX_BUFF_DESC_ADDR_LOW_0(tx_bd_desc,
+				    rtlpci->tx_ring[queue_index].dma +
+				    (current_bd_desc * TX_DESC_SIZE));
+
+	SET_TXBUFFER_DESC_LEN_WITH_OFFSET(tx_bd_desc, 1, pkt_len);
+	/* don't using extendsion mode. */
+	SET_TXBUFFER_DESC_AMSDU_WITH_OFFSET(tx_bd_desc, 1, 0);
+	SET_TXBUFFER_DESC_ADD_LOW_WITH_OFFSET(tx_bd_desc, 1, addr);
+
+	SET_TX_DESC_PKT_SIZE(desc, (u16)(pkt_len));
+	SET_TX_DESC_TX_BUFFER_SIZE(desc, (u16)(pkt_len));
+}
+
+void rtl92ee_tx_fill_desc(struct ieee80211_hw *hw,
+			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			  u8 *pbd_desc_tx,
+			  struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
+			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
+	u8 *pdesc = (u8 *)pdesc_tx;
+	u16 seq_number;
+	__le16 fc = hdr->frame_control;
+	unsigned int buf_len = 0;
+	u8 fw_qsel = _rtl92ee_map_hwqueue_to_fwqueue(skb, hw_queue);
+	bool b_firstseg = ((hdr->seq_ctrl &
+			    cpu_to_le16(IEEE80211_SCTL_FRAG)) == 0);
+	bool b_lastseg = ((hdr->frame_control &
+			   cpu_to_le16(IEEE80211_FCTL_MOREFRAGS)) == 0);
+	dma_addr_t mapping;
+	u8 bw_40 = 0;
+	u8 short_gi = 0;
+
+	if (mac->opmode == NL80211_IFTYPE_STATION) {
+		bw_40 = mac->bw_40;
+	} else if (mac->opmode == NL80211_IFTYPE_AP ||
+		   mac->opmode == NL80211_IFTYPE_ADHOC) {
+		if (sta)
+			bw_40 = sta->ht_cap.cap &
+				IEEE80211_HT_CAP_SUP_WIDTH_20_40;
+	}
+	seq_number = (le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_SEQ) >> 4;
+	stg_rtl_get_tcb_desc(hw, info, sta, skb, ptcb_desc);
+	/* reserve 8 byte for AMPDU early mode */
+	if (rtlhal->b_earlymode_enable) {
+		skb_push(skb, EM_HDR_LEN);
+		memset(skb->data, 0, EM_HDR_LEN);
+	}
+	buf_len = skb->len;
+	mapping = pci_map_single(rtlpci->pdev, skb->data, skb->len,
+				 PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(COMP_SEND, DBG_TRACE,
+			 ("DMA mapping error"));
+		return;
+	}
+	if (pbd_desc_tx != NULL)
+		rtl92ee_pre_fill_tx_bd_desc(hw, pbd_desc_tx, pdesc, hw_queue,
+					    skb, mapping);
+
+	if (ieee80211_is_nullfunc(fc) || ieee80211_is_ctl(fc)) {
+		b_firstseg = true;
+		b_lastseg = true;
+	}
+	if (b_firstseg) {
+		if (rtlhal->b_earlymode_enable) {
+			SET_TX_DESC_PKT_OFFSET(pdesc, 1);
+			SET_TX_DESC_OFFSET(pdesc,
+					   USB_HWDESC_HEADER_LEN + EM_HDR_LEN);
+			if (ptcb_desc->empkt_num) {
+				RT_TRACE(COMP_SEND, DBG_TRACE,
+					 ("Insert 8 byte.pTcb->EMPktNum:%d\n",
+					  ptcb_desc->empkt_num));
+				_rtl92ee_insert_emcontent(ptcb_desc,
+							  (u8 *)(skb->data));
+			}
+		} else {
+			SET_TX_DESC_OFFSET(pdesc, USB_HWDESC_HEADER_LEN);
+		}
+
+		SET_TX_DESC_TX_RATE(pdesc, ptcb_desc->hw_rate);
+
+		if (ieee80211_is_mgmt(fc)) {
+			ptcb_desc->use_driver_rate = true;
+		} else {
+			if (rtlpriv->ra.is_special_data) {
+				ptcb_desc->use_driver_rate = true;
+				SET_TX_DESC_TX_RATE(pdesc, DESC92C_RATE11M);
+			} else {
+				ptcb_desc->use_driver_rate = false;
+			}
+		}
+
+		if (ptcb_desc->hw_rate > DESC92C_RATEMCS0)
+			short_gi = (ptcb_desc->use_shortgi) ? 1 : 0;
+		else
+			short_gi = (ptcb_desc->use_shortpreamble) ? 1 : 0;
+
+		if (info->flags & IEEE80211_TX_CTL_AMPDU) {
+			SET_TX_DESC_AGG_ENABLE(pdesc, 1);
+			SET_TX_DESC_MAX_AGG_NUM(pdesc, 0x14);
+		}
+		SET_TX_DESC_SEQ(pdesc, seq_number);
+		SET_TX_DESC_RTS_ENABLE(pdesc,
+				       ((ptcb_desc->b_rts_enable &&
+					 !ptcb_desc->b_cts_enable) ? 1 : 0));
+		SET_TX_DESC_HW_RTS_ENABLE(pdesc , 0);
+		SET_TX_DESC_CTS2SELF(pdesc,
+				     ((ptcb_desc->b_cts_enable) ? 1 : 0));
+
+		SET_TX_DESC_RTS_RATE(pdesc, ptcb_desc->rts_rate);
+		SET_TX_DESC_RTS_SC(pdesc, ptcb_desc->rts_sc);
+		SET_TX_DESC_RTS_SHORT(pdesc,
+				((ptcb_desc->rts_rate <= DESC92C_RATE54M) ?
+				 (ptcb_desc->b_rts_use_shortpreamble ? 1 : 0) :
+				 (ptcb_desc->b_rts_use_shortgi ? 1 : 0)));
+
+		if (ptcb_desc->btx_enable_sw_calc_duration)
+			SET_TX_DESC_NAV_USE_HDR(pdesc, 1);
+
+		if (bw_40) {
+			if (ptcb_desc->packet_bw == HT_CHANNEL_WIDTH_20_40) {
+				SET_TX_DESC_DATA_BW(pdesc, 1);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc, 3);
+			} else {
+				SET_TX_DESC_DATA_BW(pdesc, 0);
+				SET_TX_DESC_TX_SUB_CARRIER(pdesc,
+							   mac->cur_40_prime_sc);
+			}
+		} else {
+			SET_TX_DESC_DATA_BW(pdesc, 0);
+			SET_TX_DESC_TX_SUB_CARRIER(pdesc, 0);
+		}
+
+		SET_TX_DESC_LINIP(pdesc, 0);
+		if (sta) {
+			u8 ampdu_density = sta->ht_cap.ampdu_density;
+			SET_TX_DESC_AMPDU_DENSITY(pdesc, ampdu_density);
+		}
+		if (info->control.hw_key) {
+			struct ieee80211_key_conf *key = info->control.hw_key;
+			switch (key->cipher) {
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
+		SET_TX_DESC_DISABLE_FB(pdesc,
+				       ptcb_desc->disable_ratefallback ? 1 : 0);
+		SET_TX_DESC_USE_RATE(pdesc, ptcb_desc->use_driver_rate ? 1 : 0);
+
+		/*SET_TX_DESC_PWR_STATUS(pdesc, pwr_status);*/
+		/* Set TxRate and RTSRate in TxDesc  */
+		/* This prevent Tx initial rate of new-coming packets */
+		/* from being overwritten by retried  packet rate.*/
+		if (!ptcb_desc->use_driver_rate) {
+			/*SET_TX_DESC_RTS_RATE(pdesc, 0x08); */
+			/* SET_TX_DESC_TX_RATE(pdesc, 0x0b); */
+		}
+		if (ieee80211_is_data_qos(fc)) {
+			if (mac->rdg_en) {
+				RT_TRACE(COMP_SEND, DBG_TRACE,
+					 ("Enable RDG function.\n"));
+				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
+				SET_TX_DESC_HTC(pdesc, 1);
+			}
+		}
+	}
+
+	SET_TX_DESC_FIRST_SEG(pdesc, (b_firstseg ? 1 : 0));
+	SET_TX_DESC_LAST_SEG(pdesc, (b_lastseg ? 1 : 0));
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+	if (rtlpriv->dm.b_useramask) {
+		SET_TX_DESC_RATE_ID(pdesc, ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->mac_id);
+	} else {
+		SET_TX_DESC_RATE_ID(pdesc, 0xC + ptcb_desc->ratr_index);
+		SET_TX_DESC_MACID(pdesc, ptcb_desc->ratr_index);
+	}
+
+	SET_TX_DESC_MORE_FRAG(pdesc, (b_lastseg ? 0 : 1));
+	if (is_multicast_ether_addr(ieee80211_get_DA(hdr)) ||
+	    is_broadcast_ether_addr(ieee80211_get_DA(hdr))) {
+		SET_TX_DESC_BMC(pdesc, 1);
+	}
+	RT_TRACE(COMP_SEND, DBG_TRACE, ("\n"));
+}
+
+void rtl92ee_tx_fill_cmddesc(struct ieee80211_hw *hw,
+			     u8 *pdesc, bool b_firstseg,
+			     bool b_lastseg, struct sk_buff *skb)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	u8 fw_queue = QSLT_BEACON;
+
+	dma_addr_t mapping = pci_map_single(rtlpci->pdev,
+					    skb->data, skb->len,
+					    PCI_DMA_TODEVICE);
+
+
+	u8 txdesc_len = 40;
+
+	if (pci_dma_mapping_error(rtlpci->pdev, mapping)) {
+		RT_TRACE(COMP_SEND, DBG_TRACE,
+			 ("DMA mapping error"));
+		return;
+	}
+	CLEAR_PCI_TX_DESC_CONTENT(pdesc, txdesc_len);
+
+	if (b_firstseg)
+		SET_TX_DESC_OFFSET(pdesc, txdesc_len);
+
+	SET_TX_DESC_TX_RATE(pdesc, DESC92C_RATE1M);
+
+	SET_TX_DESC_SEQ(pdesc, 0);
+
+	SET_TX_DESC_LINIP(pdesc, 0);
+
+	SET_TX_DESC_QUEUE_SEL(pdesc, fw_queue);
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
+
+	SET_TX_DESC_RATE_ID(pdesc, 7);
+	SET_TX_DESC_MACID(pdesc, 0);
+
+	SET_TX_DESC_OWN(pdesc, 1);
+
+	SET_TX_DESC_PKT_SIZE((u8 *)pdesc, (u16)(skb->len));
+
+	SET_TX_DESC_FIRST_SEG(pdesc, 1);
+	SET_TX_DESC_LAST_SEG(pdesc, 1);
+
+	SET_TX_DESC_OFFSET(pdesc, 40);
+
+	SET_TX_DESC_USE_RATE(pdesc, 1);
+
+	RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_LOUD,
+		      "H2C Tx Cmd Content\n", pdesc, txdesc_len);
+}
+
+
+void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
+		      u8 desc_name, u8 *val)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 cur_tx_rp = 0;
+	u16 cur_tx_wp = 0;
+	static u16 last_txw_point;
+	static bool over_run;
+	u32 tmp = 0;
+	u8 q_idx = *val;
+
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_TX_NEXTDESC_ADDR:
+			SET_TX_DESC_NEXT_DESC_ADDRESS(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_OWN:{
+			struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+			struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[q_idx];
+			u16 max_tx_desc = ring->entries;
+			if (q_idx == BEACON_QUEUE) {
+				ring->cur_tx_wp = 0;
+				ring->cur_tx_rp = 0;
+				SET_TX_BUFF_DESC_OWN(pdesc, 1);
+				return;
+			}
+			ring->cur_tx_wp = ((ring->cur_tx_wp + 1) % max_tx_desc);
+
+			if (over_run) {
+				ring->cur_tx_wp = 0;
+				over_run = false;
+			}
+			if (ring->avl_desc > 1) {
+				ring->avl_desc--;
+
+				rtl_write_word(rtlpriv,
+					       get_desc_addr_fr_q(q_idx),
+				       ring->cur_tx_wp);
+
+				if (q_idx == 1)
+					last_txw_point = cur_tx_wp;
+			}
+
+			if (ring->avl_desc < (max_tx_desc - 15)) {
+				u16 point_diff = 0;
+				tmp = rtl_read_dword(rtlpriv,
+						     get_desc_addr_fr_q(q_idx));
+				cur_tx_rp = (u16)((tmp >> 16) & 0x0fff);
+				cur_tx_wp = (u16)(tmp & 0x0fff);
+
+				ring->cur_tx_wp = cur_tx_wp;
+				ring->cur_tx_rp = cur_tx_rp;
+				point_diff = ((cur_tx_rp > cur_tx_wp) ?
+					      (cur_tx_rp - cur_tx_wp) :
+					      (TX_DESC_NUM_92E - 1 -
+					       cur_tx_wp + cur_tx_rp));
+
+				ring->avl_desc = point_diff;
+			}
+		}
+		break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_RX_PREPARE:
+			SET_RX_BUFFER_DESC_LS(pdesc , 0);
+			SET_RX_BUFFER_DESC_FS(pdesc , 0);
+			SET_RX_BUFFER_DESC_TOTAL_LENGTH(pdesc , 0);
+
+			SET_RX_BUFFER_DESC_DATA_LENGTH(pdesc,
+						       MAX_RECEIVE_BUFFER_SIZE +
+						       RX_DESC_SIZE);
+
+			SET_RX_BUFFER_PHYSICAL_LOW(pdesc, *(u32 *)val);
+			break;
+		case HW_DESC_RXERO:
+			SET_RX_DESC_EOR(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false,
+				  ("ERR rxdesc :%d not process\n", desc_name));
+			break;
+		}
+	}
+}
+
+u32 rtl92ee_get_desc(u8 *pdesc, bool istx, u8 desc_name)
+{
+	u32 ret = 0;
+
+	if (istx) {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_TX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_TXBUFF_ADDR:
+			ret = GET_TXBUFFER_DESC_ADDR_LOW(pdesc, 1);
+			break;
+		default:
+			RT_ASSERT(false,
+				  ("ERR txdesc :%d not process\n", desc_name));
+			break;
+		}
+	} else {
+		switch (desc_name) {
+		case HW_DESC_OWN:
+			ret = GET_RX_DESC_OWN(pdesc);
+			break;
+		case HW_DESC_RXPKT_LEN:
+			ret = GET_RX_DESC_PKT_LEN(pdesc);
+			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret = GET_RX_DESC_BUFF_ADDR(pdesc);
+			break;
+		default:
+			RT_ASSERT(false,
+				  ("ERR rxdesc :%d not process\n", desc_name));
+			break;
+		}
+	}
+	return ret;
+}
+
+bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
+{
+	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u16 read_point, write_point, available_desc_num;
+	bool ret = false;
+	static u8 stop_report_cnt;
+	struct rtl8192_tx_ring *ring = &rtlpci->tx_ring[hw_queue];
+
+	/*checking Read/Write Point each interrupt wastes CPU utilization.*/
+	if (stop_report_cnt > 15 || !rtlpriv->link_info.b_busytraffic) {
+		u16 point_diff = 0;
+		u16 cur_tx_rp, cur_tx_wp;
+		u32 tmpu32;
+
+		tmpu32 = rtl_read_dword(rtlpriv, get_desc_addr_fr_q(hw_queue));
+		cur_tx_rp = (u16)((tmpu32 >> 16) & 0x0fff);
+		cur_tx_wp = (u16)(tmpu32 & 0x0fff);
+
+		ring->cur_tx_wp = cur_tx_wp;
+		ring->cur_tx_rp = cur_tx_rp;
+		point_diff = ((cur_tx_rp > cur_tx_wp) ?
+			      (cur_tx_rp - cur_tx_wp) :
+			      (TX_DESC_NUM_92E - cur_tx_wp + cur_tx_rp));
+
+		ring->avl_desc = point_diff;
+	}
+
+	read_point = ring->cur_tx_rp;
+	write_point = ring->cur_tx_wp;
+	available_desc_num = ring->avl_desc;
+
+	if (write_point > read_point) {
+		if (index < write_point && index >= read_point)
+			ret = false;
+		else
+			ret = true;
+	} else if (write_point < read_point) {
+		if (index > write_point && index < read_point)
+			ret = true;
+		else
+			ret = false;
+	} else {
+		if (index != read_point)
+			ret = true;
+	}
+
+	if (hw_queue == BEACON_QUEUE)
+		ret = true;
+
+	if (rtlpriv->rtlhal.driver_is_goingto_unload ||
+	    rtlpriv->psc.rfoff_reason > RF_CHANGE_BY_PS)
+		ret = true;
+
+	if (hw_queue < BEACON_QUEUE) {
+		if (!ret)
+			stop_report_cnt++;
+		else
+			stop_report_cnt = 0;
+	}
+
+	return ret;
+}
+
+u32 rtl92ee_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb)
+{
+	u32 result = 0;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	switch (status.packet_report_type) {
+	case NORMAL_RX:
+		result = 0;
+		break;
+	case C2H_PACKET:
+		rtl92ee_c2h_packet_handler(hw, skb->data, (u8) skb->len);
+		result = 1;
+		break;
+	default:
+		RT_TRACE(COMP_RECV, DBG_TRACE, ("No this packet type!!\n"));
+		break;
+	}
+
+	return result;
+}
diff --git a/drivers/staging/rtl8192ee/rtl8192ee/trx.h b/drivers/staging/rtl8192ee/rtl8192ee/trx.h
new file mode 100644
index 0000000..c2cd581
--- /dev/null
+++ b/drivers/staging/rtl8192ee/rtl8192ee/trx.h
@@ -0,0 +1,877 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2010  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL92E_TRX_H__
+#define __RTL92E_TRX_H__
+
+
+
+#if (DMA_IS_64BIT == 1)
+#if (RTL8192EE_SEG_NUM == 2)
+#define TX_BD_DESC_SIZE					128
+#elif (RTL8192EE_SEG_NUM == 1)
+#define TX_BD_DESC_SIZE					64
+#elif (RTL8192EE_SEG_NUM == 0)
+#define TX_BD_DESC_SIZE					32
+#endif
+#else
+#if (RTL8192EE_SEG_NUM == 2)
+#define TX_BD_DESC_SIZE					64
+#elif (RTL8192EE_SEG_NUM == 1)
+#define TX_BD_DESC_SIZE					32
+#elif (RTL8192EE_SEG_NUM == 0)
+#define TX_BD_DESC_SIZE					16
+#endif
+#endif
+
+#define TX_DESC_SIZE					64
+
+#define RX_DRV_INFO_SIZE_UNIT				8
+
+#define	TX_DESC_NEXT_DESC_OFFSET			40
+#define USB_HWDESC_HEADER_LEN				40
+
+#define RX_DESC_SIZE					24
+#define MAX_RECEIVE_BUFFER_SIZE				8192
+
+#define SET_TX_DESC_PKT_SIZE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 16, __val)
+#define SET_TX_DESC_OFFSET(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 16, 8, __val)
+#define SET_TX_DESC_BMC(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 24, 1, __val)
+#define SET_TX_DESC_HTC(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 25, 1, __val)
+#define SET_TX_DESC_LAST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 26, 1, __val)
+#define SET_TX_DESC_FIRST_SEG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 27, 1, __val)
+#define SET_TX_DESC_LINIP(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 28, 1, __val)
+#define SET_TX_DESC_NO_ACM(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 29, 1, __val)
+#define SET_TX_DESC_GF(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_TX_DESC_OWN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_TX_DESC_PKT_SIZE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 16)
+#define GET_TX_DESC_OFFSET(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 8)
+#define GET_TX_DESC_BMC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 1)
+#define GET_TX_DESC_HTC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 25, 1)
+#define GET_TX_DESC_LAST_SEG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_TX_DESC_FIRST_SEG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_TX_DESC_LINIP(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_TX_DESC_NO_ACM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_TX_DESC_GF(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_TX_DESC_OWN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_TX_DESC_MACID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 7, __val)
+#define SET_TX_DESC_QUEUE_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 8, 5, __val)
+#define SET_TX_DESC_RDG_NAV_EXT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 13, 1, __val)
+#define SET_TX_DESC_LSIG_TXOP_EN(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 14, 1, __val)
+#define SET_TX_DESC_PIFS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 15, 1, __val)
+#define SET_TX_DESC_RATE_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 16, 5, __val)
+#define SET_TX_DESC_EN_DESC_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 21, 1, __val)
+#define SET_TX_DESC_SEC_TYPE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 22, 2, __val)
+#define SET_TX_DESC_PKT_OFFSET(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 24, 5, __val)
+#define SET_TX_DESC_MORE_DATA(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 29, 1, __val)
+#define SET_TX_DESC_TXOP_PS_CAP(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 30, 1, __val)
+#define SET_TX_DESC_TXOP_PS_MODE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 31, 1, __val)
+
+
+#define GET_TX_DESC_MACID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 5)
+#define GET_TX_DESC_AGG_ENABLE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 5, 1)
+#define GET_TX_DESC_AGG_BREAK(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 6, 1)
+#define GET_TX_DESC_RDG_ENABLE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 7, 1)
+#define GET_TX_DESC_QUEUE_SEL(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 8, 5)
+#define GET_TX_DESC_RDG_NAV_EXT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
+#define GET_TX_DESC_LSIG_TXOP_EN(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_TX_DESC_PIFS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_TX_DESC_RATE_ID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_TX_DESC_NAV_USE_HDR(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
+#define GET_TX_DESC_EN_DESC_ID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
+#define GET_TX_DESC_SEC_TYPE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 22, 2)
+#define GET_TX_DESC_PKT_OFFSET(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 5)
+
+#define SET_TX_DESC_PAID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 9, __val)
+#define SET_TX_DESC_CCA_RTS(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 10, 2, __val)
+#define SET_TX_DESC_AGG_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 12, 1, __val)
+#define SET_TX_DESC_RDG_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 13, 1, __val)
+#define SET_TX_DESC_NULL_0(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 14, 1, __val)
+#define SET_TX_DESC_NULL_1(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 15, 1, __val)
+#define SET_TX_DESC_BK(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 16, 1, __val)
+#define SET_TX_DESC_MORE_FRAG(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 17, 1, __val)
+#define SET_TX_DESC_RAW(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 18, 1, __val)
+#define SET_TX_DESC_SPE_RPT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 19, 1, __val)
+#define SET_TX_DESC_AMPDU_DENSITY(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 20, 3, __val)
+#define SET_TX_DESC_BT_NULL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 23, 1, __val)
+#define SET_TX_DESC_GID(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 24, 6, __val)
+
+#define SET_TX_DESC_WHEADER_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 4, __val)
+#define SET_TX_DESC_CHK_EN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 4, 1, __val)
+#define SET_TX_DESC_EARLY_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 5, 1, __val)
+#define SET_TX_DESC_HWSEQ_SEL(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 6, 2, __val)
+#define SET_TX_DESC_USE_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 8, 1, __val)
+#define SET_TX_DESC_DISABLE_RTS_FB(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 9, 1, __val)
+#define SET_TX_DESC_DISABLE_FB(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 10, 1, __val)
+#define SET_TX_DESC_CTS2SELF(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 11, 1, __val)
+#define SET_TX_DESC_RTS_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 12, 1, __val)
+#define SET_TX_DESC_HW_RTS_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 13, 1, __val)
+#define SET_TX_DESC_HW_PORT_ID(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 14, 1, __val)
+#define SET_TX_DESC_NAV_USE_HDR(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 15, 1, __val)
+#define SET_TX_DESC_USE_MAX_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 16, 1, __val)
+#define SET_TX_DESC_MAX_AGG_NUM(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 17, 5, __val)
+#define SET_TX_DESC_NDPA(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 22, 2, __val)
+#define SET_TX_DESC_AMPDU_MAX_TIME(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 24, 8, __val)
+
+
+/* Dword 4 */
+#define SET_TX_DESC_TX_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 7, __val)
+#define SET_TX_DESC_TRY_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 7, 1, __val)
+#define SET_TX_DESC_DATA_RATE_FB_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 8, 5, __val)
+#define SET_TX_DESC_RTS_RATE_FB_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 13, 4, __val)
+#define SET_TX_DESC_RETRY_LIMIT_ENABLE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 17, 1, __val)
+#define SET_TX_DESC_DATA_RETRY_LIMIT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 18, 6, __val)
+#define SET_TX_DESC_RTS_RATE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 24, 5, __val)
+#define SET_TX_DESC_PCTS_ENABLE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 29, 1, __val)
+#define SET_TX_DESC_PCTS_MASK_IDX(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 30, 2, __val)
+
+
+/* Dword 5 */
+#define SET_TX_DESC_TX_SUB_CARRIER(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 0, 4, __val)
+#define SET_TX_DESC_DATA_SHORT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 4, 1, __val)
+#define SET_TX_DESC_DATA_BW(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 5, 2, __val)
+#define SET_TX_DESC_DATA_LDPC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 7, 1, __val)
+#define SET_TX_DESC_DATA_STBC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 8, 2, __val)
+#define SET_TX_DESC_VCS_STBC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 10, 2, __val)
+#define SET_TX_DESC_RTS_SHORT(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 12, 1, __val)
+#define SET_TX_DESC_RTS_SC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 13, 4, __val)
+#define SET_TX_DESC_TX_ANT(__pdesc , __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 24, 4, __val)
+#define SET_TX_DESC_TX_POWER_0_PSET(__pdesc , __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 28, 3, __val)
+
+/* Dword 6 */
+#define SET_TX_DESC_SW_DEFINE(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 12, __val)
+#define SET_TX_DESC_ANTSEL_A(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 16, 3, __val)
+#define SET_TX_DESC_ANTSEL_B(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 19, 3, __val)
+#define SET_TX_DESC_ANTSEL_C(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 22, 3, __val)
+#define SET_TX_DESC_ANTSEL_D(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 25, 3, __val)
+
+/* Dword 7 */
+#define SET_TX_DESC_TX_BUFFER_SIZE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 16, __val)
+#define SET_TX_DESC_USB_TXAGG_NUM(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 24, 8, __val)
+
+/* Dword 8 */
+#define SET_TX_DESC_RTS_RC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 0 , 6 , __val)
+#define SET_TX_DESC_BAR_RTY_TH(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 6 , 2 , __val)
+#define SET_TX_DESC_DATA_RC(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 8 , 6 , __val)
+#define SET_TX_DESC_ENABLE_HW_SELECT(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 15 , 1 , __val)
+#define SET_TX_DESC_NEXT_HEAD_PAGE(__pdesc , __val)(__pdesc, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 16 , 8 , __val)
+#define SET_TX_DESC_TAIL_PAGE(__pdesc , __val)(__pdesc, __val)\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32 , 24 , 8 , __val)
+
+/* Dword 9 */
+#define SET_TX_DESC_PADDING_LENGTH(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36 , 0 , 11 , __val)
+#define SET_TX_DESC_TXBF_PATH(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36 , 11 , 1 , __val)
+#define SET_TX_DESC_SEQ(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36 , 12 , 12 , __val)
+#define SET_TX_DESC_FINAL_DATA_RATE(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36 , 24 , 8 , __val)
+
+/* Dword 10 */
+#define SET_TX_DESC_TX_BUFFER_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+40 , 0 , 32 , __val)
+
+
+/* Dword 11*/
+#define SET_TX_DESC_NEXT_DESC_ADDRESS(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+48 , 0 , 32 , __val)
+
+
+#define SET_EARLYMODE_PKTNUM(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr , 0 , 4 , __val)
+#define SET_EARLYMODE_LEN0(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr , 4 , 15 , __val)
+#define SET_EARLYMODE_LEN1(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr , 16 , 2 , __val)
+#define SET_EARLYMODE_LEN1_1(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr , 19 , 13 , __val)
+#define SET_EARLYMODE_LEN1_2(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr+4 , 0 , 2 , __val)
+#define SET_EARLYMODE_LEN2(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr+4 , 2 , 15 ,  __val)
+#define SET_EARLYMODE_LEN2_1(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr , 2 , 4 ,  __val)
+#define SET_EARLYMODE_LEN2_2(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr+4 , 0 , 8 ,  __val)
+#define SET_EARLYMODE_LEN3(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr+4 , 17 , 15, __val)
+#define SET_EARLYMODE_LEN4(__paddr , __val)		\
+	SET_BITS_TO_LE_4BYTE(__paddr+4 , 20 , 12 , __val)
+
+
+/* TX/RX buffer descriptor */
+
+#define SET_TX_EXTBUFF_DESC_LEN(__pdesc, __val, __set)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__set*16) , 0 , 16 , __val)
+#define SET_TX_EXTBUFF_DESC_ADDR_LOW(__pdesc, __val, __set)\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__set*16)+4 , 0 , 32 , __val)
+#define SET_TX_EXTBUFF_DESC_ADDR_HIGH(__pdesc, __val , __set)\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__set*16)+8 , 0 , 32 , __val)
+
+
+
+/* for Txfilldescroptor92ee, fill the desc content. */
+#if (DMA_IS_64BIT == 1)
+#define SET_TXBUFFER_DESC_LEN_WITH_OFFSET(__pdesc, __offset, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*16), 0, 16, __val)
+#define SET_TXBUFFER_DESC_AMSDU_WITH_OFFSET(__pdesc, __offset, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*16), 31, 1, __val)
+#define SET_TXBUFFER_DESC_ADD_LOW_WITH_OFFSET(__pdesc, __offset, __val) \
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*16)+4, 0, 32, __val)
+#define SET_TXBUFFER_DESC_ADD_HIGT_WITH_OFFSET(__pdesc, __offset, __val)\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*16)+8, 0, 32, __val)
+#define GET_TXBUFFER_DESC_ADDR_LOW(__pdesc, __offset)			\
+	LE_BITS_TO_4BYTE(__pdesc+(__offset*16)+4, 0, 32)
+#else
+#define SET_TXBUFFER_DESC_LEN_WITH_OFFSET(__pdesc, __offset, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*8), 0, 16, __val)
+#define SET_TXBUFFER_DESC_AMSDU_WITH_OFFSET(__pdesc, __offset, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*8), 31, 1, __val)
+#define SET_TXBUFFER_DESC_ADD_LOW_WITH_OFFSET(__pdesc, __offset, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+(__offset*8)+4, 0, 32, __val)
+#define SET_TXBUFFER_DESC_ADD_HIGT_WITH_OFFSET(__pdesc, __offset, __val)
+#define GET_TXBUFFER_DESC_ADDR_LOW(__pdesc, __offset)			\
+	LE_BITS_TO_4BYTE(__pdesc+(__offset*8)+4, 0, 32)
+#endif
+
+/* Dword 0 */
+#define SET_TX_BUFF_DESC_LEN_0(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
+#define SET_TX_BUFF_DESC_PSB(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 16, 15, __val)
+#define SET_TX_BUFF_DESC_OWN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+/* Dword 1 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_0(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+4, 0, 32, __val)
+#if (DMA_IS_64BIT == 1)
+/* Dword 2 */
+#define SET_TX_BUFF_DESC_ADDR_HIGH_0(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 32, __val)
+/* Dword 3 / RESERVED 0 */
+/* Dword 4 */
+#define SET_TX_BUFF_DESC_LEN_1(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_1(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 31, 1, __val)
+/* Dword 5 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_1(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 0, 32, __val)
+/* Dword 6 */
+#define SET_TX_BUFF_DESC_ADDR_HIGH_1(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 32, __val)
+/* Dword 7 / RESERVED 0 */
+/* Dword 8 */
+#define SET_TX_BUFF_DESC_LEN_2(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_2(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+32, 31, 1, __val)
+/* Dword 9 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_2(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+36, 0, 32, __val)
+/* Dword 10 */
+#define SET_TX_BUFF_DESC_ADDR_HIGH_2(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+40, 0, 32, __val)
+/* Dword 11 / RESERVED 0 */
+/* Dword 12 */
+#define SET_TX_BUFF_DESC_LEN_3(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+48, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_3(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+48, 31, 1, __val)
+/* Dword 13 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_3(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+52, 0, 32, __val)
+/* Dword 14 */
+#define SET_TX_BUFF_DESC_ADDR_HIGH_3(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+56, 0, 32, __val)
+/* Dword 15 / RESERVED 0 */
+#else
+#define SET_TX_BUFF_DESC_ADDR_HIGH_0(__pdesc, __val)
+/* Dword 2 */
+#define SET_TX_BUFF_DESC_LEN_1(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_1(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+8, 31, 1, __val)
+/* Dword 3 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_1(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+12, 0, 32, __val)
+#define SET_TX_BUFF_DESC_ADDR_HIGH_1(__pdesc, __val)
+/* Dword 4 */
+#define SET_TX_BUFF_DESC_LEN_2(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_2(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+16, 31, 1, __val)
+/* Dword 5 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_2(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+20, 0, 32, __val)
+#define SET_TX_BUFF_DESC_ADDR_HIGH_2(__pdesc, __val)
+/* Dword 6 */
+#define SET_TX_BUFF_DESC_LEN_3(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 16, __val)
+#define SET_TX_BUFF_DESC_AMSDU_3(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 31, 1, __val)
+/* Dword 7 */
+#define SET_TX_BUFF_DESC_ADDR_LOW_3(__pdesc, __val)	\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 32, __val)
+#define SET_TX_BUFF_DESC_ADDR_HIGH_3(__pdesc, __val)
+#endif
+
+/* RX buffer  */
+
+/* DWORD 0 */
+#define SET_RX_BUFFER_DESC_DATA_LENGTH(__pRxStatusDesc , __val)	\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc , 0, 14, __val)
+#define SET_RX_BUFFER_DESC_LS(__pRxStatusDesc , __val)		\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc , 15, 1, __val)
+#define SET_RX_BUFFER_DESC_FS(__pRxStatusDesc , __val)		\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc , 16, 1, __val)
+#define SET_RX_BUFFER_DESC_TOTAL_LENGTH(__pRxStatusDesc , __val)	\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc , 16, 15, __val)
+
+#define GET_RX_BUFFER_DESC_OWN(__pRxStatusDesc)			\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc , 31, 1)
+#define GET_RX_BUFFER_DESC_LS(__pRxStatusDesc)			\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc , 15, 1)
+#define GET_RX_BUFFER_DESC_FS(__pRxStatusDesc)			\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc , 16, 1)
+#define GET_RX_BUFFER_DESC_TOTAL_LENGTH(__pRxStatusDesc)	\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc , 16, 15)
+
+
+/* DWORD 1 */
+#define SET_RX_BUFFER_PHYSICAL_LOW(__pRxStatusDesc , __val)	\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc+4, 0, 32, __val)
+
+/* DWORD 2 */
+#define SET_RX_BUFFER_PHYSICAL_HIGH(__pRxStatusDesc , __val)	\
+	SET_BITS_TO_LE_4BYTE(__pRxStatusDesc+8, 0, 32, __val)
+
+#define GET_RX_DESC_PKT_LEN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 0, 14)
+#define GET_RX_DESC_CRC32(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 14, 1)
+#define GET_RX_DESC_ICV(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 15, 1)
+#define GET_RX_DESC_DRV_INFO_SIZE(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc, 16, 4)
+#define GET_RX_DESC_SECURITY(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 20, 3)
+#define GET_RX_DESC_QOS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 23, 1)
+#define GET_RX_DESC_SHIFT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 24, 2)
+#define GET_RX_DESC_PHYST(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 26, 1)
+#define GET_RX_DESC_SWDEC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 27, 1)
+#define GET_RX_DESC_LS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 28, 1)
+#define GET_RX_DESC_FS(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc, 29, 1)
+#define GET_RX_DESC_EOR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 30, 1)
+#define GET_RX_DESC_OWN(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc, 31, 1)
+
+#define SET_RX_DESC_PKT_LEN(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 0, 14, __val)
+#define SET_RX_DESC_EOR(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 30, 1, __val)
+#define SET_RX_DESC_OWN(__pdesc, __val)			\
+	SET_BITS_TO_LE_4BYTE(__pdesc, 31, 1, __val)
+
+#define GET_RX_DESC_MACID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 0, 7)
+#define GET_RX_DESC_TID(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 8, 4)
+#define GET_RX_DESC_MACID_VLD(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 12, 1)
+#define GET_RX_DESC_AMSDU(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 13, 1)
+#define GET_RX_DESC_RXID_MATCH(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 14, 1)
+#define GET_RX_DESC_PAGGR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 15, 1)
+#define GET_RX_DESC_A1_FIT(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 16, 4)
+#define GET_RX_DESC_TCPOFFLOAD_CHKERR(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 20, 1)
+#define GET_RX_DESC_TCPOFFLOAD_IPVER(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 21, 1)
+#define GET_RX_DESC_TCPOFFLOAD_IS_TCPUDP(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+4, 22, 1)
+#define GET_RX_DESC_TCPOFFLOAD_CHK_VLD(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+4, 23, 1)
+#define GET_RX_DESC_PAM(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 24, 1)
+#define GET_RX_DESC_PWR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 25, 1)
+#define GET_RX_DESC_MD(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 26, 1)
+#define GET_RX_DESC_MF(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 27, 1)
+#define GET_RX_DESC_TYPE(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+4, 28, 2)
+#define GET_RX_DESC_MC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 30, 1)
+#define GET_RX_DESC_BC(__pdesc)				\
+	LE_BITS_TO_4BYTE(__pdesc+4, 31, 1)
+#define GET_RX_DESC_SEQ(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 0, 12)
+#define GET_RX_DESC_FRAG(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 12, 4)
+#define GET_RX_DESC_RX_IS_QOS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+8, 16, 1)
+
+#define GET_RX_DESC_RXMCS(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 0, 7)
+#define GET_RX_DESC_HTC(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+12, 10, 1)
+#define GET_RX_STATUS_DESC_EOSP(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 11, 1)
+#define GET_RX_STATUS_DESC_BSSID_FIT(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 12, 2)
+#define GET_RX_STATUS_DESC_DMA_AGG_NUM(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 16, 8)
+#define GET_RX_STATUS_DESC_PATTERN_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 29, 1)
+#define GET_RX_STATUS_DESC_UNICAST_MATCH(__pdesc)	\
+	LE_BITS_TO_4BYTE(__pdesc+12, 30, 1)
+#define GET_RX_STATUS_DESC_MAGIC_MATCH(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+12, 31, 1)
+
+
+#define GET_RX_DESC_TSFL(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+20, 0, 32)
+
+#define GET_RX_DESC_BUFF_ADDR(__pdesc)			\
+	LE_BITS_TO_4BYTE(__pdesc+24, 0, 32)
+#define GET_RX_DESC_BUFF_ADDR64(__pdesc)		\
+	LE_BITS_TO_4BYTE(__pdesc+28, 0, 32)
+
+#define SET_RX_DESC_BUFF_ADDR(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+24, 0, 32, __val)
+#define SET_RX_DESC_BUFF_ADDR64(__pdesc, __val)		\
+	SET_BITS_TO_LE_4BYTE(__pdesc+28, 0, 32, __val)
+
+
+/* TX report 2 format in Rx desc*/
+
+#define GET_RX_RPT2_DESC_PKT_LEN(__pRxStatusDesc)	\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc , 0, 9)
+#define GET_RX_RPT2_DESC_MACID_VALID_1(__pRxStatusDesc)	\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc+16, 0, 32)
+#define GET_RX_RPT2_DESC_MACID_VALID_2(__pRxStatusDesc)	\
+	LE_BITS_TO_4BYTE(__pRxStatusDesc+20, 0, 32)
+
+
+#define CLEAR_PCI_TX_DESC_CONTENT(__pdesc, _size)		\
+do {								\
+	if (_size > TX_DESC_NEXT_DESC_OFFSET)			\
+		memset(__pdesc, 0, TX_DESC_NEXT_DESC_OFFSET);	\
+	else							\
+		memset(__pdesc, 0, _size);			\
+} while (0)
+
+#define RX_HAL_IS_CCK_RATE(rxmcs)\
+	(rxmcs == DESC92C_RATE1M ||\
+	 rxmcs == DESC92C_RATE2M ||\
+	 rxmcs == DESC92C_RATE5_5M ||\
+	 rxmcs == DESC92C_RATE11M)
+
+#define IS_LITTLE_ENDIAN	1
+
+struct phy_rx_agc_info_t {
+	#if IS_LITTLE_ENDIAN
+		u8 gain:7 , trsw:1;
+	#else
+		u8 trsw:1 , gain:7;
+	#endif
+};
+struct phy_status_rpt {
+	struct phy_rx_agc_info_t path_agc[2];
+	u8 ch_corr[2];
+	u8 cck_sig_qual_ofdm_pwdb_all;
+	u8 cck_agc_rpt_ofdm_cfosho_a;
+	u8 cck_rpt_b_ofdm_cfosho_b;
+	u8 rsvd_1;
+	u8 noise_power_db_msb;
+	u8 path_cfotail[2];
+	u8 pcts_mask[2];
+	u8 stream_rxevm[2];
+	u8 path_rxsnr[2];
+	u8 noise_power_db_lsb;
+	u8 rsvd_2[3];
+	u8 stream_csi[2];
+	u8 stream_target_csi[2];
+	u8 sig_evm;
+	u8 rsvd_3;
+#if IS_LITTLE_ENDIAN
+	u8 antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
+	u8 sgi_en:1;
+	u8 rxsc:2;
+	u8 idle_long:1;
+	u8 r_ant_train_en:1;
+	u8 ant_sel_b:1;
+	u8 ant_sel:1;
+#else	/* _BIG_ENDIAN_	*/
+	u8 ant_sel:1;
+	u8 ant_sel_b:1;
+	u8 r_ant_train_en:1;
+	u8 idle_long:1;
+	u8 rxsc:2;
+	u8 sgi_en:1;
+	u8 antsel_rx_keep_2:1;	/*ex_intf_flg:1;*/
+#endif
+} __packed;
+
+struct rx_fwinfo {
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
+struct tx_desc {
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
+struct rx_desc {
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
+void rtl92ee_rx_check_dma_ok(struct ieee80211_hw *hw, u8 *header_desc,
+			     u8 queue_index);
+u16	rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw,
+					  u8 queue_index);
+void rtl92ee_get_available_desc(struct ieee80211_hw *hw , u8 queue_index);
+void rtl92ee_pre_fill_tx_bd_desc(struct ieee80211_hw *hw,
+				 u8 *tx_bd_desc, u8 *desc, u8 queue_index,
+				 struct sk_buff *skb, dma_addr_t addr);
+
+
+void rtl92ee_tx_fill_desc(struct ieee80211_hw *hw,
+			  struct ieee80211_hdr *hdr, u8 *pdesc_tx,
+			  u8 *pbd_desc_tx,
+			  struct ieee80211_tx_info *info,
+			  struct ieee80211_sta *sta,
+			  struct sk_buff *skb,
+			  u8 hw_queue, struct rtl_tcb_desc *ptcb_desc);
+bool rtl92ee_rx_query_desc(struct ieee80211_hw *hw,
+			   struct rtl_stats *status,
+			   struct ieee80211_rx_status *rx_status,
+			   u8 *pdesc, struct sk_buff *skb);
+void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
+		      u8 desc_name, u8 *val);
+
+u32 rtl92ee_get_desc(u8 *pdesc, bool istx, u8 desc_name);
+bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index);
+void rtl92ee_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
+			     bool b_firstseg, bool b_lastseg,
+			     struct sk_buff *skb);
+u32 rtl92ee_rx_command_packet(struct ieee80211_hw *hw,
+			      struct rtl_stats status,
+			      struct sk_buff *skb);
+#endif
-- 
1.8.4.5
