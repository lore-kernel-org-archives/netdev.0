From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v3 1/3] net/macb: Fix comments to meet style guidelines
Date: Thu, 15 Jan 2015 15:45:14 -0600
Message-ID: <1421358316-23660-1-git-send-email-xander.huff@ni.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CAC999F@AcuExch.aculab.com>
Cc: netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	brad.mouring@ni.com, linux-kernel@vger.kernel.org,
	cyrille.pitchen@atmel.com, Xander Huff <xander.huff@ni.com>
To: davem@davemloft.net, nicolas.ferre@atmel.com,
	david.light@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAC999F@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change comments to not exceed 80 characters per line.
Update block comments in macb.h to start on the line after /*.

Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/cadence/macb.h | 734 ++++++++++++++----------------------
 1 file changed, 284 insertions(+), 450 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 378b218..31dc080 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -15,471 +15,309 @@
 #define MACB_MAX_QUEUES 8
 
 /* MACB register offsets */
-#define MACB_NCR				0x0000 /* Network Control */
-#define MACB_NCFGR				0x0004 /* Network Config */
-#define MACB_NSR				0x0008 /* Network Status */
-#define MACB_TAR				0x000c /* AT91RM9200 only */
-#define MACB_TCR				0x0010 /* AT91RM9200 only */
-#define MACB_TSR				0x0014 /* Transmit Status */
-#define MACB_RBQP				0x0018 /* RX Q Base Address */
-#define MACB_TBQP				0x001c /* TX Q Base Address */
-#define MACB_RSR				0x0020 /* Receive Status */
-#define MACB_ISR				0x0024 /* Interrupt Status */
-#define MACB_IER				0x0028 /* Interrupt Enable */
-#define MACB_IDR				0x002c /* Interrupt Disable */
-#define MACB_IMR				0x0030 /* Interrupt Mask */
-#define MACB_MAN				0x0034 /* PHY Maintenance */
-#define MACB_PTR				0x0038
-#define MACB_PFR				0x003c
-#define MACB_FTO				0x0040
-#define MACB_SCF				0x0044
-#define MACB_MCF				0x0048
-#define MACB_FRO				0x004c
-#define MACB_FCSE				0x0050
-#define MACB_ALE				0x0054
-#define MACB_DTF				0x0058
-#define MACB_LCOL				0x005c
-#define MACB_EXCOL				0x0060
-#define MACB_TUND				0x0064
-#define MACB_CSE				0x0068
-#define MACB_RRE				0x006c
-#define MACB_ROVR				0x0070
-#define MACB_RSE				0x0074
-#define MACB_ELE				0x0078
-#define MACB_RJA				0x007c
-#define MACB_USF				0x0080
-#define MACB_STE				0x0084
-#define MACB_RLE				0x0088
-#define MACB_TPF				0x008c
-#define MACB_HRB				0x0090
-#define MACB_HRT				0x0094
-#define MACB_SA1B				0x0098
-#define MACB_SA1T				0x009c
-#define MACB_SA2B				0x00a0
-#define MACB_SA2T				0x00a4
-#define MACB_SA3B				0x00a8
-#define MACB_SA3T				0x00ac
-#define MACB_SA4B				0x00b0
-#define MACB_SA4T				0x00b4
-#define MACB_TID				0x00b8
-#define MACB_TPQ				0x00bc
-#define MACB_USRIO				0x00c0
-#define MACB_WOL				0x00c4
-#define MACB_MID				0x00fc
+#define MACB_NCR		0x0000 /* Network Control */
+#define MACB_NCFGR		0x0004 /* Network Config */
+#define MACB_NSR		0x0008 /* Network Status */
+#define MACB_TAR		0x000c /* AT91RM9200 only */
+#define MACB_TCR		0x0010 /* AT91RM9200 only */
+#define MACB_TSR		0x0014 /* Transmit Status */
+#define MACB_RBQP		0x0018 /* RX Q Base Address */
+#define MACB_TBQP		0x001c /* TX Q Base Address */
+#define MACB_RSR		0x0020 /* Receive Status */
+#define MACB_ISR		0x0024 /* Interrupt Status */
+#define MACB_IER		0x0028 /* Interrupt Enable */
+#define MACB_IDR		0x002c /* Interrupt Disable */
+#define MACB_IMR		0x0030 /* Interrupt Mask */
+#define MACB_MAN		0x0034 /* PHY Maintenance */
+#define MACB_PTR		0x0038
+#define MACB_PFR		0x003c
+#define MACB_FTO		0x0040
+#define MACB_SCF		0x0044
+#define MACB_MCF		0x0048
+#define MACB_FRO		0x004c
+#define MACB_FCSE		0x0050
+#define MACB_ALE		0x0054
+#define MACB_DTF		0x0058
+#define MACB_LCOL		0x005c
+#define MACB_EXCOL		0x0060
+#define MACB_TUND		0x0064
+#define MACB_CSE		0x0068
+#define MACB_RRE		0x006c
+#define MACB_ROVR		0x0070
+#define MACB_RSE		0x0074
+#define MACB_ELE		0x0078
+#define MACB_RJA		0x007c
+#define MACB_USF		0x0080
+#define MACB_STE		0x0084
+#define MACB_RLE		0x0088
+#define MACB_TPF		0x008c
+#define MACB_HRB		0x0090
+#define MACB_HRT		0x0094
+#define MACB_SA1B		0x0098
+#define MACB_SA1T		0x009c
+#define MACB_SA2B		0x00a0
+#define MACB_SA2T		0x00a4
+#define MACB_SA3B		0x00a8
+#define MACB_SA3T		0x00ac
+#define MACB_SA4B		0x00b0
+#define MACB_SA4T		0x00b4
+#define MACB_TID		0x00b8
+#define MACB_TPQ		0x00bc
+#define MACB_USRIO		0x00c0
+#define MACB_WOL		0x00c4
+#define MACB_MID		0x00fc
 
 /* GEM register offsets. */
-#define GEM_NCFGR				0x0004 /* Network Config */
-#define GEM_USRIO				0x000c /* User IO */
-#define GEM_DMACFG				0x0010 /* DMA Configuration */
-#define GEM_HRB					0x0080 /* Hash Bottom */
-#define GEM_HRT					0x0084 /* Hash Top */
-#define GEM_SA1B				0x0088 /* Specific1 Bottom */
-#define GEM_SA1T				0x008C /* Specific1 Top */
-#define GEM_SA2B				0x0090 /* Specific2 Bottom */
-#define GEM_SA2T				0x0094 /* Specific2 Top */
-#define GEM_SA3B				0x0098 /* Specific3 Bottom */
-#define GEM_SA3T				0x009C /* Specific3 Top */
-#define GEM_SA4B				0x00A0 /* Specific4 Bottom */
-#define GEM_SA4T				0x00A4 /* Specific4 Top */
-#define GEM_OTX					0x0100 /* Octets transmitted */
-#define GEM_OCTTXL				0x0100 /* Octets transmitted
-							* [31:0]
-							*/
-#define GEM_OCTTXH				0x0104 /* Octets transmitted
-							* [47:32]
-							*/
-#define GEM_TXCNT				0x0108 /* Error-free Frames
-							* Transmitted counter
-							*/
-#define GEM_TXBCCNT				0x010c /* Error-free Broadcast
-							* Frames counter
-							*/
-#define GEM_TXMCCNT				0x0110 /* Error-free Multicast
-							* Frames counter
-							*/
-#define GEM_TXPAUSECNT				0x0114 /* Pause Frames
-							* Transmitted Counter
-							*/
-#define GEM_TX64CNT				0x0118 /* Error-free 64 byte
-							* Frames Transmitted
-							* counter
-							*/
-#define GEM_TX65CNT				0x011c /* Error-free 65-127 byte
-							* Frames Transmitted
-							* counter
-							*/
-#define GEM_TX128CNT				0x0120 /* Error-free 128-255
-							* byte Frames
-							* Transmitted counter
-							*/
-#define GEM_TX256CNT				0x0124 /* Error-free 256-511
-							* byte Frames
-							* transmitted counter
-							*/
-#define GEM_TX512CNT				0x0128 /* Error-free 512-1023
-							* byte Frames
-							* transmitted counter
-							*/
-#define GEM_TX1024CNT				0x012c /* Error-free 1024-1518
-							* byte Frames
-							* transmitted counter
-							*/
-#define GEM_TX1519CNT				0x0130 /* Error-free larger than
-							* 1519 byte Frames
-							* tranmitted counter
-							*/
-#define GEM_TXURUNCNT				0x0134 /* TX under run error
-							* counter
-							*/
-#define GEM_SNGLCOLLCNT				0x0138 /* Single Collision Frame
-							* Counter
-							*/
-#define GEM_MULTICOLLCNT			0x013c /* Multiple Collision
-							* Frame Counter
-							*/
-#define GEM_EXCESSCOLLCNT			0x0140 /* Excessive Collision
-							* Frame Counter
-							*/
-#define GEM_LATECOLLCNT				0x0144 /* Late Collision Frame
-							* Counter
-							*/
-#define GEM_TXDEFERCNT				0x0148 /* Deferred Transmission
-							* Frame Counter
-							*/
-#define GEM_TXCSENSECNT				0x014c /* Carrier Sense Error
-							* Counter
-							*/
-#define GEM_ORX					0x0150 /* Octets received */
-#define GEM_OCTRXL				0x0150 /* Octets received
-							* [31:0]
-							*/
-#define GEM_OCTRXH				0x0154 /* Octets received
-							* [47:32]
-							*/
-#define GEM_RXCNT				0x0158 /* Error-free Frames
-							* Received Counter
-							*/
-#define GEM_RXBROADCNT				0x015c /* Error-free Broadcast
-							* Frames Received
-							* Counter
-							*/
-#define GEM_RXMULTICNT				0x0160 /* Error-free Multicast
-							* Frames Received
-							* Counter
-							*/
-#define GEM_RXPAUSECNT				0x0164 /* Error-free Pause
-							* Frames Received
-							* Counter
-							*/
-#define GEM_RX64CNT				0x0168 /* Error-free 64 byte
-							* Frames Received
-							* Counter
-							*/
-#define GEM_RX65CNT				0x016c /* Error-free 65-127 byte
-							* Frames Received
-							* Counter
-							*/
-#define GEM_RX128CNT				0x0170 /* Error-free 128-255
-							* byte Frames Received
-							* Counter
-							*/
-#define GEM_RX256CNT				0x0174 /* Error-free 256-511
-							* byte Frames Received
-							* Counter
-							*/
-#define GEM_RX512CNT				0x0178 /* Error-free 512-1023
-							* byte Frames Received
-							* Counter
-							*/
-#define GEM_RX1024CNT				0x017c /* Error-free 1024-1518
-							* byte Frames Received
-							* Counter
-							*/
-#define GEM_RX1519CNT				0x0180 /* Error-free larger than
-							* 1519 Frames Received
-							* Counter
-							*/
-#define GEM_RXUNDRCNT				0x0184 /* Undersize Frames
-							* Received Counter
-							*/
-#define GEM_RXOVRCNT				0x0188 /* Oversize Frames
-							* Received Counter
-							*/
-#define GEM_RXJABCNT				0x018c /* Jabbers Received
-							* Counter
-							*/
-#define GEM_RXFCSCNT				0x0190 /* Frame Check Sequence
-							* Error Counter
-							*/
-#define GEM_RXLENGTHCNT				0x0194 /* Length Field Error
-							* Counter
-							*/
-#define GEM_RXSYMBCNT				0x0198 /* Symbol Error
-							* Counter
-							*/
-#define GEM_RXALIGNCNT				0x019c /* Alignment Error
-							* Counter
-							*/
-#define GEM_RXRESERRCNT				0x01a0 /* Receive Resource Error
-							* Counter
-							*/
-#define GEM_RXORCNT				0x01a4 /* Receive Overrun
-							* Counter
-							*/
-#define GEM_RXIPCCNT				0x01a8 /* IP header Checksum
-							* Error Counter
-							*/
-#define GEM_RXTCPCCNT				0x01ac /* TCP Checksum Error
-							* Counter
-							*/
-#define GEM_RXUDPCCNT				0x01b0 /* UDP Checksum Error
-							* Counter
-							*/
-#define GEM_DCFG1				0x0280 /* Design Config 1 */
-#define GEM_DCFG2				0x0284 /* Design Config 2 */
-#define GEM_DCFG3				0x0288 /* Design Config 3 */
-#define GEM_DCFG4				0x028c /* Design Config 4 */
-#define GEM_DCFG5				0x0290 /* Design Config 5 */
-#define GEM_DCFG6				0x0294 /* Design Config 6 */
-#define GEM_DCFG7				0x0298 /* Design Config 7 */
-
-#define GEM_ISR(hw_q)				(0x0400 + ((hw_q) << 2))
-#define GEM_TBQP(hw_q)				(0x0440 + ((hw_q) << 2))
-#define GEM_RBQP(hw_q)				(0x0480 + ((hw_q) << 2))
-#define GEM_IER(hw_q)				(0x0600 + ((hw_q) << 2))
-#define GEM_IDR(hw_q)				(0x0620 + ((hw_q) << 2))
-#define GEM_IMR(hw_q)				(0x0640 + ((hw_q) << 2))
+#define GEM_NCFGR		0x0004 /* Network Config */
+#define GEM_USRIO		0x000c /* User IO */
+#define GEM_DMACFG		0x0010 /* DMA Configuration */
+#define GEM_HRB			0x0080 /* Hash Bottom */
+#define GEM_HRT			0x0084 /* Hash Top */
+#define GEM_SA1B		0x0088 /* Specific1 Bottom */
+#define GEM_SA1T		0x008C /* Specific1 Top */
+#define GEM_SA2B		0x0090 /* Specific2 Bottom */
+#define GEM_SA2T		0x0094 /* Specific2 Top */
+#define GEM_SA3B		0x0098 /* Specific3 Bottom */
+#define GEM_SA3T		0x009C /* Specific3 Top */
+#define GEM_SA4B		0x00A0 /* Specific4 Bottom */
+#define GEM_SA4T		0x00A4 /* Specific4 Top */
+#define GEM_OTX			0x0100 /* Octets transmitted */
+#define GEM_OCTTXL		0x0100 /* Octets transmitted [31:0] */
+#define GEM_OCTTXH		0x0104 /* Octets transmitted [47:32] */
+#define GEM_TXCNT		0x0108 /* Frames Transmitted counter */
+#define GEM_TXBCCNT		0x010c /* Broadcast Frames counter */
+#define GEM_TXMCCNT		0x0110 /* Multicast Frames counter */
+#define GEM_TXPAUSECNT		0x0114 /* Pause Frames Transmitted Counter */
+#define GEM_TX64CNT		0x0118 /* 64 byte Frames TX counter */
+#define GEM_TX65CNT		0x011c /* 65-127 byte Frames TX counter */
+#define GEM_TX128CNT		0x0120 /* 128-255 byte Frames TX counter */
+#define GEM_TX256CNT		0x0124 /* 256-511 byte Frames TX counter */
+#define GEM_TX512CNT		0x0128 /* 512-1023 byte Frames TX counter */
+#define GEM_TX1024CNT		0x012c /* 1024-1518 byte Frames TX counter */
+#define GEM_TX1519CNT		0x0130 /* 1519+ byte Frames TX counter */
+#define GEM_TXURUNCNT		0x0134 /* TX under run error counter */
+#define GEM_SNGLCOLLCNT		0x0138 /* Single Collision Frame Counter */
+#define GEM_MULTICOLLCNT	0x013c /* Multiple Collision Frame Counter */
+#define GEM_EXCESSCOLLCNT	0x0140 /* Excessive Collision Frame Counter */
+#define GEM_LATECOLLCNT		0x0144 /* Late Collision Frame Counter */
+#define GEM_TXDEFERCNT		0x0148 /* Deferred Transmission Frame Counter */
+#define GEM_TXCSENSECNT		0x014c /* Carrier Sense Error Counter */
+#define GEM_ORX			0x0150 /* Octets received */
+#define GEM_OCTRXL		0x0150 /* Octets received [31:0] */
+#define GEM_OCTRXH		0x0154 /* Octets received [47:32] */
+#define GEM_RXCNT		0x0158 /* Frames Received Counter */
+#define GEM_RXBROADCNT		0x015c /* Broadcast Frames Received Counter */
+#define GEM_RXMULTICNT		0x0160 /* Multicast Frames Received Counter */
+#define GEM_RXPAUSECNT		0x0164 /* Pause Frames Received Counter */
+#define GEM_RX64CNT		0x0168 /* 64 byte Frames RX Counter */
+#define GEM_RX65CNT		0x016c /* 65-127 byte Frames RX Counter */
+#define GEM_RX128CNT		0x0170 /* 128-255 byte Frames RX Counter */
+#define GEM_RX256CNT		0x0174 /* 256-511 byte Frames RX Counter */
+#define GEM_RX512CNT		0x0178 /* 512-1023 byte Frames RX Counter */
+#define GEM_RX1024CNT		0x017c /* 1024-1518 byte Frames RX Counter */
+#define GEM_RX1519CNT		0x0180 /* 1519+ byte Frames RX Counter */
+#define GEM_RXUNDRCNT		0x0184 /* Undersize Frames Received Counter */
+#define GEM_RXOVRCNT		0x0188 /* Oversize Frames Received Counter */
+#define GEM_RXJABCNT		0x018c /* Jabbers Received Counter */
+#define GEM_RXFCSCNT		0x0190 /* Frame Check Sequence Error Counter */
+#define GEM_RXLENGTHCNT		0x0194 /* Length Field Error Counter */
+#define GEM_RXSYMBCNT		0x0198 /* Symbol Error Counter */
+#define GEM_RXALIGNCNT		0x019c /* Alignment Error Counter */
+#define GEM_RXRESERRCNT		0x01a0 /* Receive Resource Error Counter */
+#define GEM_RXORCNT		0x01a4 /* Receive Overrun Counter */
+#define GEM_RXIPCCNT		0x01a8 /* IP header Checksum Error Counter */
+#define GEM_RXTCPCCNT		0x01ac /* TCP Checksum Error Counter */
+#define GEM_RXUDPCCNT		0x01b0 /* UDP Checksum Error Counter */
+#define GEM_DCFG1		0x0280 /* Design Config 1 */
+#define GEM_DCFG2		0x0284 /* Design Config 2 */
+#define GEM_DCFG3		0x0288 /* Design Config 3 */
+#define GEM_DCFG4		0x028c /* Design Config 4 */
+#define GEM_DCFG5		0x0290 /* Design Config 5 */
+#define GEM_DCFG6		0x0294 /* Design Config 6 */
+#define GEM_DCFG7		0x0298 /* Design Config 7 */
+
+#define GEM_ISR(hw_q)		(0x0400 + ((hw_q) << 2))
+#define GEM_TBQP(hw_q)		(0x0440 + ((hw_q) << 2))
+#define GEM_RBQP(hw_q)		(0x0480 + ((hw_q) << 2))
+#define GEM_IER(hw_q)		(0x0600 + ((hw_q) << 2))
+#define GEM_IDR(hw_q)		(0x0620 + ((hw_q) << 2))
+#define GEM_IMR(hw_q)		(0x0640 + ((hw_q) << 2))
 
 /* Bitfields in NCR */
-#define MACB_LB_OFFSET				0 /* reserved */
-#define MACB_LB_SIZE				1
-#define MACB_LLB_OFFSET				1 /* Loop back local */
-#define MACB_LLB_SIZE				1
-#define MACB_RE_OFFSET				2 /* Receive enable */
-#define MACB_RE_SIZE				1
-#define MACB_TE_OFFSET				3 /* Transmit enable */
-#define MACB_TE_SIZE				1
-#define MACB_MPE_OFFSET				4 /* Management port enable */
-#define MACB_MPE_SIZE				1
-#define MACB_CLRSTAT_OFFSET			5 /* Clear stats regs */
-#define MACB_CLRSTAT_SIZE			1
-#define MACB_INCSTAT_OFFSET			6 /* Incremental stats regs */
-#define MACB_INCSTAT_SIZE			1
-#define MACB_WESTAT_OFFSET			7 /* Write enable stats regs */
-#define MACB_WESTAT_SIZE			1
-#define MACB_BP_OFFSET				8 /* Back pressure */
-#define MACB_BP_SIZE				1
-#define MACB_TSTART_OFFSET			9 /* Start transmission */
-#define MACB_TSTART_SIZE			1
-#define MACB_THALT_OFFSET			10 /* Transmit halt */
-#define MACB_THALT_SIZE				1
-#define MACB_NCR_TPF_OFFSET			11 /* Transmit pause frame */
-#define MACB_NCR_TPF_SIZE			1
-#define MACB_TZQ_OFFSET				12 /* Transmit zero quantum
-						    * pause frame
-						    */
-#define MACB_TZQ_SIZE				1
+#define MACB_LB_OFFSET		0 /* reserved */
+#define MACB_LB_SIZE		1
+#define MACB_LLB_OFFSET		1 /* Loop back local */
+#define MACB_LLB_SIZE		1
+#define MACB_RE_OFFSET		2 /* Receive enable */
+#define MACB_RE_SIZE		1
+#define MACB_TE_OFFSET		3 /* Transmit enable */
+#define MACB_TE_SIZE		1
+#define MACB_MPE_OFFSET		4 /* Management port enable */
+#define MACB_MPE_SIZE		1
+#define MACB_CLRSTAT_OFFSET	5 /* Clear stats regs */
+#define MACB_CLRSTAT_SIZE	1
+#define MACB_INCSTAT_OFFSET	6 /* Incremental stats regs */
+#define MACB_INCSTAT_SIZE	1
+#define MACB_WESTAT_OFFSET	7 /* Write enable stats regs */
+#define MACB_WESTAT_SIZE	1
+#define MACB_BP_OFFSET		8 /* Back pressure */
+#define MACB_BP_SIZE		1
+#define MACB_TSTART_OFFSET	9 /* Start transmission */
+#define MACB_TSTART_SIZE	1
+#define MACB_THALT_OFFSET	10 /* Transmit halt */
+#define MACB_THALT_SIZE		1
+#define MACB_NCR_TPF_OFFSET	11 /* Transmit pause frame */
+#define MACB_NCR_TPF_SIZE	1
+#define MACB_TZQ_OFFSET		12 /* Transmit zero quantum pause frame */
+#define MACB_TZQ_SIZE		1
 
 /* Bitfields in NCFGR */
-#define MACB_SPD_OFFSET				0 /* Speed */
-#define MACB_SPD_SIZE				1
-#define MACB_FD_OFFSET				1 /* Full duplex */
-#define MACB_FD_SIZE				1
-#define MACB_BIT_RATE_OFFSET			2 /* Discard non-VLAN frames */
-#define MACB_BIT_RATE_SIZE			1
-#define MACB_JFRAME_OFFSET			3 /* reserved */
-#define MACB_JFRAME_SIZE			1
-#define MACB_CAF_OFFSET				4 /* Copy all frames */
-#define MACB_CAF_SIZE				1
-#define MACB_NBC_OFFSET				5 /* No broadcast */
-#define MACB_NBC_SIZE				1
-#define MACB_NCFGR_MTI_OFFSET			6 /* Multicast hash enable */
-#define MACB_NCFGR_MTI_SIZE			1
-#define MACB_UNI_OFFSET				7 /* Unicast hash enable */
-#define MACB_UNI_SIZE				1
-#define MACB_BIG_OFFSET				8 /* Receive 1536 byte frames */
-#define MACB_BIG_SIZE				1
-#define MACB_EAE_OFFSET				9 /* External address match
-						   * enable
-						   */
-#define MACB_EAE_SIZE				1
-#define MACB_CLK_OFFSET				10
-#define MACB_CLK_SIZE				2
-#define MACB_RTY_OFFSET				12 /* Retry test */
-#define MACB_RTY_SIZE				1
-#define MACB_PAE_OFFSET				13 /* Pause enable */
-#define MACB_PAE_SIZE				1
-#define MACB_RM9200_RMII_OFFSET			13 /* AT91RM9200 only */
-#define MACB_RM9200_RMII_SIZE			1  /* AT91RM9200 only */
-#define MACB_RBOF_OFFSET			14 /* Receive buffer offset */
-#define MACB_RBOF_SIZE				2
-#define MACB_RLCE_OFFSET			16 /* Length field error frame
-						    * discard
-						    */
-#define MACB_RLCE_SIZE				1
-#define MACB_DRFCS_OFFSET			17 /* FCS remove */
-#define MACB_DRFCS_SIZE				1
-#define MACB_EFRHD_OFFSET			18
-#define MACB_EFRHD_SIZE				1
-#define MACB_IRXFCS_OFFSET			19
-#define MACB_IRXFCS_SIZE			1
+#define MACB_SPD_OFFSET		0 /* Speed */
+#define MACB_SPD_SIZE		1
+#define MACB_FD_OFFSET		1 /* Full duplex */
+#define MACB_FD_SIZE		1
+#define MACB_BIT_RATE_OFFSET	2 /* Discard non-VLAN frames */
+#define MACB_BIT_RATE_SIZE	1
+#define MACB_JFRAME_OFFSET	3 /* reserved */
+#define MACB_JFRAME_SIZE	1
+#define MACB_CAF_OFFSET		4 /* Copy all frames */
+#define MACB_CAF_SIZE		1
+#define MACB_NBC_OFFSET		5 /* No broadcast */
+#define MACB_NBC_SIZE		1
+#define MACB_NCFGR_MTI_OFFSET	6 /* Multicast hash enable */
+#define MACB_NCFGR_MTI_SIZE	1
+#define MACB_UNI_OFFSET		7 /* Unicast hash enable */
+#define MACB_UNI_SIZE		1
+#define MACB_BIG_OFFSET		8 /* Receive 1536 byte frames */
+#define MACB_BIG_SIZE		1
+#define MACB_EAE_OFFSET		9 /* External address match enable */
+#define MACB_EAE_SIZE		1
+#define MACB_CLK_OFFSET		10
+#define MACB_CLK_SIZE		2
+#define MACB_RTY_OFFSET		12 /* Retry test */
+#define MACB_RTY_SIZE		1
+#define MACB_PAE_OFFSET		13 /* Pause enable */
+#define MACB_PAE_SIZE		1
+#define MACB_RM9200_RMII_OFFSET	13 /* AT91RM9200 only */
+#define MACB_RM9200_RMII_SIZE	1  /* AT91RM9200 only */
+#define MACB_RBOF_OFFSET	14 /* Receive buffer offset */
+#define MACB_RBOF_SIZE		2
+#define MACB_RLCE_OFFSET	16 /* Length field error frame discard */
+#define MACB_RLCE_SIZE		1
+#define MACB_DRFCS_OFFSET	17 /* FCS remove */
+#define MACB_DRFCS_SIZE		1
+#define MACB_EFRHD_OFFSET	18
+#define MACB_EFRHD_SIZE		1
+#define MACB_IRXFCS_OFFSET	19
+#define MACB_IRXFCS_SIZE	1
 
 /* GEM specific NCFGR bitfields. */
-#define GEM_GBE_OFFSET				10 /* Gigabit mode enable */
-#define GEM_GBE_SIZE				1
-#define GEM_CLK_OFFSET				18 /* MDC clock division */
-#define GEM_CLK_SIZE				3
-#define GEM_DBW_OFFSET				21 /* Data bus width */
-#define GEM_DBW_SIZE				2
-#define GEM_RXCOEN_OFFSET			24
-#define GEM_RXCOEN_SIZE				1
+#define GEM_GBE_OFFSET		10 /* Gigabit mode enable */
+#define GEM_GBE_SIZE		1
+#define GEM_CLK_OFFSET		18 /* MDC clock division */
+#define GEM_CLK_SIZE		3
+#define GEM_DBW_OFFSET		21 /* Data bus width */
+#define GEM_DBW_SIZE		2
+#define GEM_RXCOEN_OFFSET	24
+#define GEM_RXCOEN_SIZE		1
 
 /* Constants for data bus width. */
-#define GEM_DBW32				0 /* 32 bit AMBA AHB data bus
-						   * width
-						   */
-#define GEM_DBW64				1 /* 64 bit AMBA AHB data bus
-						   * width
-						   */
-#define GEM_DBW128				2 /* 128 bit AMBA AHB data bus
-						   * width
-						   */
+#define GEM_DBW32		0 /* 32 bit AMBA AHB data bus width */
+#define GEM_DBW64		1 /* 64 bit AMBA AHB data bus width */
+#define GEM_DBW128		2 /* 128 bit AMBA AHB data bus width */
 
 /* Bitfields in DMACFG. */
-#define GEM_FBLDO_OFFSET			0 /* AHB fixed burst length for
-						   * DMA data operations
-						   */
-#define GEM_FBLDO_SIZE				5
-#define GEM_ENDIA_OFFSET			7 /* AHB endian swap mode enable
-						   * for packet data accesses
-						   */
-#define GEM_ENDIA_SIZE				1
-#define GEM_RXBMS_OFFSET			8 /* Receiver packet buffer
-						   * memory size select
-						   */
-#define GEM_RXBMS_SIZE				2
-#define GEM_TXPBMS_OFFSET			10 /* Transmitter packet buffer
-						    * memory size select
-						    */
-#define GEM_TXPBMS_SIZE				1
-#define GEM_TXCOEN_OFFSET			11 /* Transmitter IP, TCP and
-						    * UDP checksum generation
-						    * offload enable
-						    */
-#define GEM_TXCOEN_SIZE				1
-#define GEM_RXBS_OFFSET				16 /* DMA receive buffer size in
-						    * AHB system memory
-						    */
-#define GEM_RXBS_SIZE				8
-#define GEM_DDRP_OFFSET				24 /* disc_when_no_ahb */
-#define GEM_DDRP_SIZE				1
+#define GEM_FBLDO_OFFSET	0 /* fixed burst length for DMA */
+#define GEM_FBLDO_SIZE		5
+#define GEM_ENDIA_OFFSET	7 /* endian swap mode for packet data access */
+#define GEM_ENDIA_SIZE		1
+#define GEM_RXBMS_OFFSET	8 /* RX packet buffer memory size select */
+#define GEM_RXBMS_SIZE		2
+#define GEM_TXPBMS_OFFSET	10 /* TX packet buffer memory size select */
+#define GEM_TXPBMS_SIZE		1
+#define GEM_TXCOEN_OFFSET	11 /* TX IP/TCP/UDP checksum gen offload */
+#define GEM_TXCOEN_SIZE		1
+#define GEM_RXBS_OFFSET		16 /* DMA receive buffer size */
+#define GEM_RXBS_SIZE		8
+#define GEM_DDRP_OFFSET		24 /* disc_when_no_ahb */
+#define GEM_DDRP_SIZE		1
 
 
 /* Bitfields in NSR */
-#define MACB_NSR_LINK_OFFSET			0 /* pcs_link_state */
-#define MACB_NSR_LINK_SIZE			1
-#define MACB_MDIO_OFFSET			1 /* status of the mdio_in
-						   * pin
-						   */
-#define MACB_MDIO_SIZE				1
-#define MACB_IDLE_OFFSET			2 /* The PHY management logic is
-						   * idle (i.e. has completed)
-						   */
-#define MACB_IDLE_SIZE				1
+#define MACB_NSR_LINK_OFFSET	0 /* pcs_link_state */
+#define MACB_NSR_LINK_SIZE	1
+#define MACB_MDIO_OFFSET	1 /* status of the mdio_in pin */
+#define MACB_MDIO_SIZE		1
+#define MACB_IDLE_OFFSET	2 /* The PHY management logic is idle */
+#define MACB_IDLE_SIZE		1
 
 /* Bitfields in TSR */
-#define MACB_UBR_OFFSET				0 /* Used bit read */
-#define MACB_UBR_SIZE				1
-#define MACB_COL_OFFSET				1 /* Collision occurred */
-#define MACB_COL_SIZE				1
-#define MACB_TSR_RLE_OFFSET			2 /* Retry limit exceeded */
-#define MACB_TSR_RLE_SIZE			1
-#define MACB_TGO_OFFSET				3 /* Transmit go */
-#define MACB_TGO_SIZE				1
-#define MACB_BEX_OFFSET				4 /* Transmit frame corruption
-						   * due to AHB error
-						   */
-#define MACB_BEX_SIZE				1
-#define MACB_RM9200_BNQ_OFFSET			4 /* AT91RM9200 only */
-#define MACB_RM9200_BNQ_SIZE			1 /* AT91RM9200 only */
-#define MACB_COMP_OFFSET			5 /* Trnasmit complete */
-#define MACB_COMP_SIZE				1
-#define MACB_UND_OFFSET				6 /* Trnasmit under run */
-#define MACB_UND_SIZE				1
+#define MACB_UBR_OFFSET		0 /* Used bit read */
+#define MACB_UBR_SIZE		1
+#define MACB_COL_OFFSET		1 /* Collision occurred */
+#define MACB_COL_SIZE		1
+#define MACB_TSR_RLE_OFFSET	2 /* Retry limit exceeded */
+#define MACB_TSR_RLE_SIZE	1
+#define MACB_TGO_OFFSET		3 /* Transmit go */
+#define MACB_TGO_SIZE		1
+#define MACB_BEX_OFFSET		4 /* TX frame corruption due to AHB error */
+#define MACB_BEX_SIZE		1
+#define MACB_RM9200_BNQ_OFFSET	4 /* AT91RM9200 only */
+#define MACB_RM9200_BNQ_SIZE	1 /* AT91RM9200 only */
+#define MACB_COMP_OFFSET	5 /* Trnasmit complete */
+#define MACB_COMP_SIZE		1
+#define MACB_UND_OFFSET		6 /* Trnasmit under run */
+#define MACB_UND_SIZE		1
 
 /* Bitfields in RSR */
-#define MACB_BNA_OFFSET				0 /* Buffer not available */
-#define MACB_BNA_SIZE				1
-#define MACB_REC_OFFSET				1 /* Frame received */
-#define MACB_REC_SIZE				1
-#define MACB_OVR_OFFSET				2 /* Receive overrun */
-#define MACB_OVR_SIZE				1
+#define MACB_BNA_OFFSET		0 /* Buffer not available */
+#define MACB_BNA_SIZE		1
+#define MACB_REC_OFFSET		1 /* Frame received */
+#define MACB_REC_SIZE		1
+#define MACB_OVR_OFFSET		2 /* Receive overrun */
+#define MACB_OVR_SIZE		1
 
 /* Bitfields in ISR/IER/IDR/IMR */
-#define MACB_MFD_OFFSET				0 /* Management frame sent */
-#define MACB_MFD_SIZE				1
-#define MACB_RCOMP_OFFSET			1 /* Receive complete */
-#define MACB_RCOMP_SIZE				1
-#define MACB_RXUBR_OFFSET			2 /* RX used bit read */
-#define MACB_RXUBR_SIZE				1
-#define MACB_TXUBR_OFFSET			3 /* TX used bit read */
-#define MACB_TXUBR_SIZE				1
-#define MACB_ISR_TUND_OFFSET			4 /* Enable trnasmit buffer
-						   * under run interrupt
-						   */
-#define MACB_ISR_TUND_SIZE			1
-#define MACB_ISR_RLE_OFFSET			5 /* Enable retry limit exceeded
-						   * or late collision interrupt
-						   */
-#define MACB_ISR_RLE_SIZE			1
-#define MACB_TXERR_OFFSET			6 /* Enable transmit frame
-						   * corruption due to AHB error
-						   * interrupt
-						   */
-#define MACB_TXERR_SIZE				1
-#define MACB_TCOMP_OFFSET			7 /* Enable transmit complete
-						   * interrupt
-						   */
-#define MACB_TCOMP_SIZE				1
-#define MACB_ISR_LINK_OFFSET			9 /* Enable link change
-						   * interrupt
-						   */
-#define MACB_ISR_LINK_SIZE			1
-#define MACB_ISR_ROVR_OFFSET			10 /* Enable receive overrun
-						    * interrupt
-						    */
-#define MACB_ISR_ROVR_SIZE			1
-#define MACB_HRESP_OFFSET			11 /* Enable hrsep not OK
-						    * interrupt
-						    */
-#define MACB_HRESP_SIZE				1
-#define MACB_PFR_OFFSET				12 /* Enable pause frame with
-						    * non-zero pause quantum
-						    * interrupt
-						    */
-#define MACB_PFR_SIZE				1
-#define MACB_PTZ_OFFSET				13 /* Enable pause time zero
-						    * interrupt
-						    */
-#define MACB_PTZ_SIZE				1
+#define MACB_MFD_OFFSET		0 /* Management frame sent */
+#define MACB_MFD_SIZE		1
+#define MACB_RCOMP_OFFSET	1 /* Receive complete */
+#define MACB_RCOMP_SIZE		1
+#define MACB_RXUBR_OFFSET	2 /* RX used bit read */
+#define MACB_RXUBR_SIZE		1
+#define MACB_TXUBR_OFFSET	3 /* TX used bit read */
+#define MACB_TXUBR_SIZE		1
+#define MACB_ISR_TUND_OFFSET	4 /* Enable TX buffer under run interrupt */
+#define MACB_ISR_TUND_SIZE	1
+#define MACB_ISR_RLE_OFFSET	5 /* EN retry exceeded/late coll interrupt */
+#define MACB_ISR_RLE_SIZE	1
+#define MACB_TXERR_OFFSET	6 /* EN TX frame corrupt from error interrupt */
+#define MACB_TXERR_SIZE		1
+#define MACB_TCOMP_OFFSET	7 /* Enable transmit complete interrupt */
+#define MACB_TCOMP_SIZE		1
+#define MACB_ISR_LINK_OFFSET	9 /* Enable link change interrupt */
+#define MACB_ISR_LINK_SIZE	1
+#define MACB_ISR_ROVR_OFFSET	10 /* Enable receive overrun interrupt */
+#define MACB_ISR_ROVR_SIZE	1
+#define MACB_HRESP_OFFSET	11 /* Enable hrsep not OK interrupt */
+#define MACB_HRESP_SIZE		1
+#define MACB_PFR_OFFSET		12 /* Enable pause frame w/ quantum interrupt */
+#define MACB_PFR_SIZE		1
+#define MACB_PTZ_OFFSET		13 /* Enable pause time zero interrupt */
+#define MACB_PTZ_SIZE		1
 
 /* Bitfields in MAN */
-#define MACB_DATA_OFFSET			0 /* data */
-#define MACB_DATA_SIZE				16
-#define MACB_CODE_OFFSET			16 /* Must be written to 10 */
-#define MACB_CODE_SIZE				2
-#define MACB_REGA_OFFSET			18 /* Register address */
-#define MACB_REGA_SIZE				5
-#define MACB_PHYA_OFFSET			23 /* PHY address */
-#define MACB_PHYA_SIZE				5
-#define MACB_RW_OFFSET				28 /* Operation. 10 is read. 01
-						    * is write.
-						    */
-#define MACB_RW_SIZE				2
-#define MACB_SOF_OFFSET				30 /* Must be written to 1 for
-						    * Clause 22 operation
-						    */
-#define MACB_SOF_SIZE				2
+#define MACB_DATA_OFFSET	0 /* data */
+#define MACB_DATA_SIZE		16
+#define MACB_CODE_OFFSET	16 /* Must be written to 10 */
+#define MACB_CODE_SIZE		2
+#define MACB_REGA_OFFSET	18 /* Register address */
+#define MACB_REGA_SIZE		5
+#define MACB_PHYA_OFFSET	23 /* PHY address */
+#define MACB_PHYA_SIZE		5
+#define MACB_RW_OFFSET		28 /* Operation. 10 is read. 01 is write. */
+#define MACB_RW_SIZE		2
+#define MACB_SOF_OFFSET		30 /* Must be written to 1 for Clause 22 */
+#define MACB_SOF_SIZE		2
 
 /* Bitfields in USRIO (AVR32) */
 #define MACB_MII_OFFSET				0
@@ -597,8 +435,7 @@
 #define queue_writel(queue, reg, value)			\
 	__raw_writel((value), (queue)->bp->regs + (queue)->reg)
 
-/*
- * Conditional GEM/MACB macros.  These perform the operation to the correct
+/* Conditional GEM/MACB macros.  These perform the operation to the correct
  * register dependent on whether the device is a GEM or a MACB.  For registers
  * and bitfields that are common across both devices, use macb_{read,write}l
  * to avoid the cost of the conditional.
@@ -621,8 +458,7 @@
 		__v; \
 	})
 
-/**
- * struct macb_dma_desc - Hardware DMA descriptor
+/* struct macb_dma_desc - Hardware DMA descriptor
  * @addr: DMA address of data buffer
  * @ctrl: Control and status bits
  */
@@ -711,8 +547,7 @@ struct macb_dma_desc {
 /* limit RX checksum offload to TCP and UDP packets */
 #define GEM_RX_CSUM_CHECKED_MASK		2
 
-/**
- * struct macb_tx_skb - data about an skb which is being transmitted
+/* struct macb_tx_skb - data about an skb which is being transmitted
  * @skb: skb currently being transmitted, only set for the last buffer
  *       of the frame
  * @mapping: DMA address of the skb's fragment buffer
@@ -727,8 +562,7 @@ struct macb_tx_skb {
 	bool			mapped_as_page;
 };
 
-/*
- * Hardware-collected statistics. Used when updating the network
+/* Hardware-collected statistics. Used when updating the network
  * device stats by a periodic timer.
  */
 struct macb_stats {
-- 
1.9.1
