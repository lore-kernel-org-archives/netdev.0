From: Alexander Dahl <ada@thorsis.com>
Subject: [RFC 1/3] net: macb: Add register descriptions
Date: Wed, 12 Jul 2017 18:28:10 +0200
Message-ID: <1499876892-14423-2-git-send-email-ada@thorsis.com>
References: <1499876892-14423-1-git-send-email-ada@thorsis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1499876892-14423-1-git-send-email-ada@thorsis.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Analog to the already present long register names for GEM, add those for
MACB. Taken from the AT91SAM9G20 complete datasheet.

Signed-off-by: Alexander Dahl <ada@thorsis.com>
---
 drivers/net/ethernet/cadence/macb.h | 66 ++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index ec037b0..8547d92 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -31,41 +31,41 @@
 #define MACB_IDR		0x002c /* Interrupt Disable */
 #define MACB_IMR		0x0030 /* Interrupt Mask */
 #define MACB_MAN		0x0034 /* PHY Maintenance */
-#define MACB_PTR		0x0038
-#define MACB_PFR		0x003c
-#define MACB_FTO		0x0040
-#define MACB_SCF		0x0044
-#define MACB_MCF		0x0048
-#define MACB_FRO		0x004c
-#define MACB_FCSE		0x0050
-#define MACB_ALE		0x0054
-#define MACB_DTF		0x0058
-#define MACB_LCOL		0x005c
-#define MACB_EXCOL		0x0060
-#define MACB_TUND		0x0064
-#define MACB_CSE		0x0068
-#define MACB_RRE		0x006c
-#define MACB_ROVR		0x0070
-#define MACB_RSE		0x0074
-#define MACB_ELE		0x0078
-#define MACB_RJA		0x007c
-#define MACB_USF		0x0080
-#define MACB_STE		0x0084
-#define MACB_RLE		0x0088
+#define MACB_PTR		0x0038 /* Pause Time */
+#define MACB_PFR		0x003c /* Pause Frames Received */
+#define MACB_FTO		0x0040 /* Frames Transmitted Ok */
+#define MACB_SCF		0x0044 /* Single Collision Frames */
+#define MACB_MCF		0x0048 /* Multiple Collision Frames */
+#define MACB_FRO		0x004c /* Frames Received Ok */
+#define MACB_FCSE		0x0050 /* Frame Check Sequence Errors */
+#define MACB_ALE		0x0054 /* Alignment Errors */
+#define MACB_DTF		0x0058 /* Deferred Transmission Frames */
+#define MACB_LCOL		0x005c /* Late Collisions */
+#define MACB_EXCOL		0x0060 /* Excessive Collisions */
+#define MACB_TUND		0x0064 /* Transmit Underrun Errors */
+#define MACB_CSE		0x0068 /* Carrier Sense Errors */
+#define MACB_RRE		0x006c /* Receive Resource Errors */
+#define MACB_ROVR		0x0070 /* Receive Overrun Errors */
+#define MACB_RSE		0x0074 /* Receive Symbol Errors */
+#define MACB_ELE		0x0078 /* Excessive Length Errors */
+#define MACB_RJA		0x007c /* Receive Jabbers */
+#define MACB_USF		0x0080 /* Undersize Frames */
+#define MACB_STE		0x0084 /* SQE Test Errors */
+#define MACB_RLE		0x0088 /* Received Length Field Mismatch */
 #define MACB_TPF		0x008c
-#define MACB_HRB		0x0090
-#define MACB_HRT		0x0094
-#define MACB_SA1B		0x0098
-#define MACB_SA1T		0x009c
-#define MACB_SA2B		0x00a0
-#define MACB_SA2T		0x00a4
-#define MACB_SA3B		0x00a8
-#define MACB_SA3T		0x00ac
-#define MACB_SA4B		0x00b0
-#define MACB_SA4T		0x00b4
-#define MACB_TID		0x00b8
+#define MACB_HRB		0x0090 /* Hash Register Bottom [31:0] */
+#define MACB_HRT		0x0094 /* Hash Register Top [63:32] */
+#define MACB_SA1B		0x0098 /* Specific Address 1 Bottom */
+#define MACB_SA1T		0x009c /* Specific Address 1 Top */
+#define MACB_SA2B		0x00a0 /* Specific Address 2 Bottom */
+#define MACB_SA2T		0x00a4 /* Specific Address 2 Top */
+#define MACB_SA3B		0x00a8 /* Specific Address 3 Bottom */
+#define MACB_SA3T		0x00ac /* Specific Address 3 Top */
+#define MACB_SA4B		0x00b0 /* Specific Address 4 Bottom */
+#define MACB_SA4T		0x00b4 /* Specific Address 4 Top */
+#define MACB_TID		0x00b8 /* Type ID Checking */
 #define MACB_TPQ		0x00bc
-#define MACB_USRIO		0x00c0
+#define MACB_USRIO		0x00c0 /* User Input/Output */
 #define MACB_WOL		0x00c4
 #define MACB_MID		0x00fc
 #define MACB_TBQPH		0x04C8
-- 
2.1.4
