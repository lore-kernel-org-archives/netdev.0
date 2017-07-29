From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 6/6] net: moxa: Add spaces preferred around that '{+,-}'
Date: Sat, 29 Jul 2017 18:42:39 +0800
Message-ID: <20170729104239.14999-7-sz.lin@moxa.com>
References: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729104239.14999-1-sz.lin@moxa.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes all checkpatch occurences of
"CHECK: spaces preferred around that '{+,-}' (ctx:VxV)"
in moxart_ether code.

Signed-off-by: SZ Lin <sz.lin@moxa.com>
---
 drivers/net/ethernet/moxa/moxart_ether.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index 686b8957d5cf..bee608b547d1 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -55,17 +55,17 @@
 #define RX_DESC2_ADDRESS_VIRT	4
 
 #define TX_DESC_NUM		64
-#define TX_DESC_NUM_MASK	(TX_DESC_NUM-1)
+#define TX_DESC_NUM_MASK	(TX_DESC_NUM - 1)
 #define TX_NEXT(N)		(((N) + 1) & (TX_DESC_NUM_MASK))
 #define TX_BUF_SIZE		1600
-#define TX_BUF_SIZE_MAX		(TX_DESC1_BUF_SIZE_MASK+1)
+#define TX_BUF_SIZE_MAX		(TX_DESC1_BUF_SIZE_MASK + 1)
 #define TX_WAKE_THRESHOLD	16
 
 #define RX_DESC_NUM		64
-#define RX_DESC_NUM_MASK	(RX_DESC_NUM-1)
+#define RX_DESC_NUM_MASK	(RX_DESC_NUM - 1)
 #define RX_NEXT(N)		(((N) + 1) & (RX_DESC_NUM_MASK))
 #define RX_BUF_SIZE		1600
-#define RX_BUF_SIZE_MAX		(RX_DESC1_BUF_SIZE_MASK+1)
+#define RX_BUF_SIZE_MAX		(RX_DESC1_BUF_SIZE_MASK + 1)
 
 #define REG_INTERRUPT_STATUS	0
 #define REG_INTERRUPT_MASK	4
-- 
2.13.3
