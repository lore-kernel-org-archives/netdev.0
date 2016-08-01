From: Harini Katakam <harini.katakam@xilinx.com>
Subject: [RFC PATCH 1/2] net: macb: Correct CAPS mask
Date: Mon, 1 Aug 2016 12:50:22 +0530
Message-ID: <1470036023-22368-1-git-send-email-harinik@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<harinik@xilinx.com>, <punnaia@xilinx.com>, <michals@xilinx.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

USRIO and JUMBO CAPS have the same mask.
Fix the same.

Signed-off-by: Harini Katakam <harinik@xilinx.com>
---
 drivers/net/ethernet/cadence/macb.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 36893d8..b6fcf10 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -403,11 +403,11 @@
 #define MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII	0x00000004
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_USRIO_DISABLED		0x00000010
+#define MACB_CAPS_JUMBO				0x00000020
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
 #define MACB_CAPS_MACB_IS_GEM			0x80000000
-#define MACB_CAPS_JUMBO				0x00000010
 
 /* Bit manipulation macros */
 #define MACB_BIT(name)					\
-- 
2.7.4
