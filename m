From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 01/11] net/can/mscan: move defines into .h file
Date: Mon, 16 Nov 2009 23:57:44 +0100
Message-ID: <1258412274-14686-2-git-send-email-w.sang@pengutronix.de>
References: <1258412274-14686-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1258412274-14686-1-git-send-email-w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 drivers/net/can/mscan/mscan.c |   29 -----------------------------
 drivers/net/can/mscan/mscan.h |   29 +++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 49542ca..2539ebe 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -35,31 +35,6 @@
 
 #include "mscan.h"
 
-#define MSCAN_NORMAL_MODE	0
-#define MSCAN_SLEEP_MODE	MSCAN_SLPRQ
-#define MSCAN_INIT_MODE		(MSCAN_INITRQ | MSCAN_SLPRQ)
-#define MSCAN_POWEROFF_MODE	(MSCAN_CSWAI | MSCAN_SLPRQ)
-#define MSCAN_SET_MODE_RETRIES	255
-#define MSCAN_ECHO_SKB_MAX	3
-
-#define BTR0_BRP_MASK		0x3f
-#define BTR0_SJW_SHIFT		6
-#define BTR0_SJW_MASK		(0x3 << BTR0_SJW_SHIFT)
-
-#define BTR1_TSEG1_MASK 	0xf
-#define BTR1_TSEG2_SHIFT	4
-#define BTR1_TSEG2_MASK 	(0x7 << BTR1_TSEG2_SHIFT)
-#define BTR1_SAM_SHIFT  	7
-
-#define BTR0_SET_BRP(brp)	(((brp) - 1) & BTR0_BRP_MASK)
-#define BTR0_SET_SJW(sjw)	((((sjw) - 1) << BTR0_SJW_SHIFT) & \
-				 BTR0_SJW_MASK)
-
-#define BTR1_SET_TSEG1(tseg1)	(((tseg1) - 1) &  BTR1_TSEG1_MASK)
-#define BTR1_SET_TSEG2(tseg2)	((((tseg2) - 1) << BTR1_TSEG2_SHIFT) & \
-				 BTR1_TSEG2_MASK)
-#define BTR1_SET_SAM(sam)	((sam) ? 1 << BTR1_SAM_SHIFT : 0)
-
 static struct can_bittiming_const mscan_bittiming_const = {
 	.name = "mscan",
 	.tseg1_min = 4,
@@ -78,10 +53,6 @@ struct mscan_state {
 	u8 cantier;
 };
 
-#define F_RX_PROGRESS	0
-#define F_TX_PROGRESS	1
-#define F_TX_WAIT_ALL	2
-
 static enum can_state state_map[] = {
 	CAN_STATE_ERROR_ACTIVE,
 	CAN_STATE_ERROR_WARNING,
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 57820f5..76a8abf 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -226,6 +226,35 @@ struct mscan_regs {
 #undef _MSCAN_RESERVED_
 #define MSCAN_REGION 	sizeof(struct mscan)
 
+#define MSCAN_NORMAL_MODE	0
+#define MSCAN_SLEEP_MODE	MSCAN_SLPRQ
+#define MSCAN_INIT_MODE		(MSCAN_INITRQ | MSCAN_SLPRQ)
+#define MSCAN_POWEROFF_MODE	(MSCAN_CSWAI | MSCAN_SLPRQ)
+#define MSCAN_SET_MODE_RETRIES	255
+#define MSCAN_ECHO_SKB_MAX	3
+
+#define BTR0_BRP_MASK		0x3f
+#define BTR0_SJW_SHIFT		6
+#define BTR0_SJW_MASK		(0x3 << BTR0_SJW_SHIFT)
+
+#define BTR1_TSEG1_MASK 	0xf
+#define BTR1_TSEG2_SHIFT	4
+#define BTR1_TSEG2_MASK 	(0x7 << BTR1_TSEG2_SHIFT)
+#define BTR1_SAM_SHIFT  	7
+
+#define BTR0_SET_BRP(brp)	(((brp) - 1) & BTR0_BRP_MASK)
+#define BTR0_SET_SJW(sjw)	((((sjw) - 1) << BTR0_SJW_SHIFT) & \
+				 BTR0_SJW_MASK)
+
+#define BTR1_SET_TSEG1(tseg1)	(((tseg1) - 1) &  BTR1_TSEG1_MASK)
+#define BTR1_SET_TSEG2(tseg2)	((((tseg2) - 1) << BTR1_TSEG2_SHIFT) & \
+				 BTR1_TSEG2_MASK)
+#define BTR1_SET_SAM(sam)	((sam) ? 1 << BTR1_SAM_SHIFT : 0)
+
+#define F_RX_PROGRESS	0
+#define F_TX_PROGRESS	1
+#define F_TX_WAIT_ALL	2
+
 #define TX_QUEUE_SIZE	3
 
 struct tx_queue_entry {
-- 
1.6.3.3
