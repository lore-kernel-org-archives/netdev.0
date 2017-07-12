From: Alexander Dahl <ada@thorsis.com>
Subject: [RFC 2/3] net: macb: Add buffer descriptor names
Date: Wed, 12 Jul 2017 18:28:11 +0200
Message-ID: <1499876892-14423-3-git-send-email-ada@thorsis.com>
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

Documentation of the EMAC buffer descriptor bitfields. Taken from the
AT91SAM9G20 complete datasheet.

Signed-off-by: Alexander Dahl <ada@thorsis.com>
---
 drivers/net/ethernet/cadence/macb.h | 50 ++++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 8547d92..567c72d 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -566,39 +566,39 @@ struct macb_dma_desc_64 {
 #define MACB_RX_WADDR_OFFSET			2
 #define MACB_RX_WADDR_SIZE			30
 
-#define MACB_RX_FRMLEN_OFFSET			0
+#define MACB_RX_FRMLEN_OFFSET			0  /* Length of frame */
 #define MACB_RX_FRMLEN_SIZE			12
-#define MACB_RX_OFFSET_OFFSET			12
+#define MACB_RX_OFFSET_OFFSET			12 /* Receive buffer offset */
 #define MACB_RX_OFFSET_SIZE			2
-#define MACB_RX_SOF_OFFSET			14
+#define MACB_RX_SOF_OFFSET			14 /* Start of frame */
 #define MACB_RX_SOF_SIZE			1
-#define MACB_RX_EOF_OFFSET			15
+#define MACB_RX_EOF_OFFSET			15 /* End of frame */
 #define MACB_RX_EOF_SIZE			1
-#define MACB_RX_CFI_OFFSET			16
+#define MACB_RX_CFI_OFFSET			16 /* Concatenation format indicator */
 #define MACB_RX_CFI_SIZE			1
-#define MACB_RX_VLAN_PRI_OFFSET			17
+#define MACB_RX_VLAN_PRI_OFFSET			17 /* VLAN priority */
 #define MACB_RX_VLAN_PRI_SIZE			3
-#define MACB_RX_PRI_TAG_OFFSET			20
+#define MACB_RX_PRI_TAG_OFFSET			20 /* Priority tag detected */
 #define MACB_RX_PRI_TAG_SIZE			1
-#define MACB_RX_VLAN_TAG_OFFSET			21
+#define MACB_RX_VLAN_TAG_OFFSET			21 /* VLAN tag detected */
 #define MACB_RX_VLAN_TAG_SIZE			1
-#define MACB_RX_TYPEID_MATCH_OFFSET		22
+#define MACB_RX_TYPEID_MATCH_OFFSET		22 /* Type ID match */
 #define MACB_RX_TYPEID_MATCH_SIZE		1
-#define MACB_RX_SA4_MATCH_OFFSET		23
+#define MACB_RX_SA4_MATCH_OFFSET		23 /* Specific address register 4 match */
 #define MACB_RX_SA4_MATCH_SIZE			1
-#define MACB_RX_SA3_MATCH_OFFSET		24
+#define MACB_RX_SA3_MATCH_OFFSET		24 /* Specific address register 3 match */
 #define MACB_RX_SA3_MATCH_SIZE			1
-#define MACB_RX_SA2_MATCH_OFFSET		25
+#define MACB_RX_SA2_MATCH_OFFSET		25 /* Specific address register 2 match */
 #define MACB_RX_SA2_MATCH_SIZE			1
-#define MACB_RX_SA1_MATCH_OFFSET		26
+#define MACB_RX_SA1_MATCH_OFFSET		26 /* Specific address register 1 match */
 #define MACB_RX_SA1_MATCH_SIZE			1
-#define MACB_RX_EXT_MATCH_OFFSET		28
+#define MACB_RX_EXT_MATCH_OFFSET		28 /* External address match */
 #define MACB_RX_EXT_MATCH_SIZE			1
-#define MACB_RX_UHASH_MATCH_OFFSET		29
+#define MACB_RX_UHASH_MATCH_OFFSET		29 /* Unicast hash match */
 #define MACB_RX_UHASH_MATCH_SIZE		1
-#define MACB_RX_MHASH_MATCH_OFFSET		30
+#define MACB_RX_MHASH_MATCH_OFFSET		30 /* Multicast hash match */
 #define MACB_RX_MHASH_MATCH_SIZE		1
-#define MACB_RX_BROADCAST_OFFSET		31
+#define MACB_RX_BROADCAST_OFFSET		31 /* Global all ones broadcast addr detected */
 #define MACB_RX_BROADCAST_SIZE			1
 
 #define MACB_RX_FRMLEN_MASK			0xFFF
@@ -612,11 +612,11 @@ struct macb_dma_desc_64 {
 #define GEM_RX_CSUM_OFFSET			22
 #define GEM_RX_CSUM_SIZE			2
 
-#define MACB_TX_FRMLEN_OFFSET			0
+#define MACB_TX_FRMLEN_OFFSET			0  /* Length of buffer */
 #define MACB_TX_FRMLEN_SIZE			11
-#define MACB_TX_LAST_OFFSET			15
+#define MACB_TX_LAST_OFFSET			15 /* Last buffer */
 #define MACB_TX_LAST_SIZE			1
-#define MACB_TX_NOCRC_OFFSET			16
+#define MACB_TX_NOCRC_OFFSET			16 /* No CRC */
 #define MACB_TX_NOCRC_SIZE			1
 #define MACB_MSS_MFS_OFFSET			16
 #define MACB_MSS_MFS_SIZE			14
@@ -624,15 +624,15 @@ struct macb_dma_desc_64 {
 #define MACB_TX_LSO_SIZE			2
 #define MACB_TX_TCP_SEQ_SRC_OFFSET		19
 #define MACB_TX_TCP_SEQ_SRC_SIZE		1
-#define MACB_TX_BUF_EXHAUSTED_OFFSET		27
+#define MACB_TX_BUF_EXHAUSTED_OFFSET		27 /* Buffers exhausted in mid frame */
 #define MACB_TX_BUF_EXHAUSTED_SIZE		1
-#define MACB_TX_UNDERRUN_OFFSET			28
+#define MACB_TX_UNDERRUN_OFFSET			28 /* Transmit underrun */
 #define MACB_TX_UNDERRUN_SIZE			1
-#define MACB_TX_ERROR_OFFSET			29
+#define MACB_TX_ERROR_OFFSET			29 /* Retry limit exceeded */
 #define MACB_TX_ERROR_SIZE			1
-#define MACB_TX_WRAP_OFFSET			30
+#define MACB_TX_WRAP_OFFSET			30 /* Wrap */
 #define MACB_TX_WRAP_SIZE			1
-#define MACB_TX_USED_OFFSET			31
+#define MACB_TX_USED_OFFSET			31 /* Used */
 #define MACB_TX_USED_SIZE			1
 
 #define GEM_TX_FRMLEN_OFFSET			0
-- 
2.1.4
