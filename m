From: Dayanidhi Sreenivasan <dayanidhi.sreenivasan@gmail.com>
Subject: [PATCH 1/1] 	r8169: Removed unused macros from r8169.c
Date: Fri, 10 Aug 2012 07:33:11 -0700
Message-ID: <1344609191-5229-1-git-send-email-dayanidhi.sreenivasan@gmail.com>
References: <r8169-Removed-unused-macros-from-r8169.c>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dayanidhi Sreenivasan <dayanidhi.sreenivasan@gmail.com>
To: romieu@fr.zoreil.com, nic_swsd@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <r8169-Removed-unused-macros-from-r8169.c>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Dayanidhi Sreenivasan <dayanidhi.sreenivasan@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b47d5b3..60b45ca 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -78,23 +78,18 @@ static const int multicast_filter_limit = 32;
 
 #define MAX_READ_REQUEST_SHIFT	12
 #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
-#define SafeMtu		0x1c20	/* ... actually life sucks beyond ~7k */
 #define InterFrameGap	0x03	/* 3 means InterFrameGap = the shortest one */
 
 #define R8169_REGS_SIZE		256
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
-#define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
-#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
-#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
-#define RTL_EEPROM_SIG_ADDR	0x0000
 
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
-- 
1.7.5.4
