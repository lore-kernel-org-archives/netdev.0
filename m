From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 2/8] net: fec: consistently use lower case chars as hex digits
Date: Mon, 17 Nov 2014 10:51:18 +0100
Message-ID: <1416217884-20911-3-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53265 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbaKQJvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:41 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h |   88 +++++++++++++++++---------=
--------
 1 file changed, 44 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index 3047db4..e778b9e 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -38,9 +38,9 @@
 #define FEC_ADDR_LOW		0x0e4 /* Low 32bits MAC address */
 #define FEC_ADDR_HIGH		0x0e8 /* High 16bits MAC address */
 #define FEC_OPD			0x0ec /* Opcode + Pause duration */
-#define FEC_TXIC0		0xF0  /* Tx Interrupt Coalescing for ring 0 */
-#define FEC_TXIC1		0xF4  /* Tx Interrupt Coalescing for ring 1 */
-#define FEC_TXIC2		0xF8  /* Tx Interrupt Coalescing for ring 2 */
+#define FEC_TXIC0		0x0f0 /* Tx Interrupt Coalescing for ring 0 */
+#define FEC_TXIC1		0x0f4 /* Tx Interrupt Coalescing for ring 1 */
+#define FEC_TXIC2		0x0f8 /* Tx Interrupt Coalescing for ring 2 */
 #define FEC_RXIC0		0x100 /* Rx Interrupt Coalescing for ring 0 */
 #define FEC_RXIC1		0x104 /* Rx Interrupt Coalescing for ring 1 */
 #define FEC_RXIC2		0x108 /* Rx Interrupt Coalescing for ring 2 */
@@ -62,7 +62,7 @@
 #define FEC_R_FIFO_RSEM		0x194 /* Receive FIFO section empty threshold=
 */
 #define FEC_R_FIFO_RAEM		0x198 /* Receive FIFO almost empty threshold =
*/
 #define FEC_R_FIFO_RAFL		0x19c /* Receive FIFO almost full threshold *=
/
-#define FEC_RACC		0x1C4 /* Receive Accelerator function */
+#define FEC_RACC		0x1c4 /* Receive Accelerator function */
 #define FEC_RCMR_1		0x1c8 /* Receive classification match ring 1 */
 #define FEC_RCMR_2		0x1cc /* Receive classification match ring 2 */
 #define FEC_DMA_CFG_1		0x1d8 /* DMA class configuration for ring 1 */
@@ -82,57 +82,57 @@
 #define RMON_T_DROP		0x200 /* Count of frames not cntd correctly */
 #define RMON_T_PACKETS		0x204 /* RMON TX packet count */
 #define RMON_T_BC_PKT		0x208 /* RMON TX broadcast pkts */
-#define RMON_T_MC_PKT		0x20C /* RMON TX multicast pkts */
+#define RMON_T_MC_PKT		0x20c /* RMON TX multicast pkts */
 #define RMON_T_CRC_ALIGN	0x210 /* RMON TX pkts with CRC align err */
 #define RMON_T_UNDERSIZE	0x214 /* RMON TX pkts < 64 bytes, good CRC */
 #define RMON_T_OVERSIZE		0x218 /* RMON TX pkts > MAX_FL bytes good CRC=
 */
-#define RMON_T_FRAG		0x21C /* RMON TX pkts < 64 bytes, bad CRC */
+#define RMON_T_FRAG		0x21c /* RMON TX pkts < 64 bytes, bad CRC */
 #define RMON_T_JAB		0x220 /* RMON TX pkts > MAX_FL bytes, bad CRC */
 #define RMON_T_COL		0x224 /* RMON TX collision count */
 #define RMON_T_P64		0x228 /* RMON TX 64 byte pkts */
-#define RMON_T_P65TO127		0x22C /* RMON TX 65 to 127 byte pkts */
+#define RMON_T_P65TO127		0x22c /* RMON TX 65 to 127 byte pkts */
 #define RMON_T_P128TO255	0x230 /* RMON TX 128 to 255 byte pkts */
 #define RMON_T_P256TO511	0x234 /* RMON TX 256 to 511 byte pkts */
 #define RMON_T_P512TO1023	0x238 /* RMON TX 512 to 1023 byte pkts */
-#define RMON_T_P1024TO2047	0x23C /* RMON TX 1024 to 2047 byte pkts */
+#define RMON_T_P1024TO2047	0x23c /* RMON TX 1024 to 2047 byte pkts */
 #define RMON_T_P_GTE2048	0x240 /* RMON TX pkts > 2048 bytes */
 #define RMON_T_OCTETS		0x244 /* RMON TX octets */
 #define IEEE_T_DROP		0x248 /* Count of frames not counted crtly */
-#define IEEE_T_FRAME_OK		0x24C /* Frames tx'd OK */
+#define IEEE_T_FRAME_OK		0x24c /* Frames tx'd OK */
 #define IEEE_T_1COL		0x250 /* Frames tx'd with single collision */
 #define IEEE_T_MCOL		0x254 /* Frames tx'd with multiple collision */
 #define IEEE_T_DEF		0x258 /* Frames tx'd after deferral delay */
-#define IEEE_T_LCOL		0x25C /* Frames tx'd with late collision */
+#define IEEE_T_LCOL		0x25c /* Frames tx'd with late collision */
 #define IEEE_T_EXCOL		0x260 /* Frames tx'd with excesv collisions */
 #define IEEE_T_MACERR		0x264 /* Frames tx'd with TX FIFO underrun */
 #define IEEE_T_CSERR		0x268 /* Frames tx'd with carrier sense err */
-#define IEEE_T_SQE		0x26C /* Frames tx'd with SQE err */
+#define IEEE_T_SQE		0x26c /* Frames tx'd with SQE err */
 #define IEEE_T_FDXFC		0x270 /* Flow control pause frames tx'd */
 #define IEEE_T_OCTETS_OK	0x274 /* Octet count for frames tx'd w/o err =
*/
 #define RMON_R_PACKETS		0x284 /* RMON RX packet count */
 #define RMON_R_BC_PKT		0x288 /* RMON RX broadcast pkts */
-#define RMON_R_MC_PKT		0x28C /* RMON RX multicast pkts */
+#define RMON_R_MC_PKT		0x28c /* RMON RX multicast pkts */
 #define RMON_R_CRC_ALIGN	0x290 /* RMON RX pkts with CRC alignment err =
*/
 #define RMON_R_UNDERSIZE	0x294 /* RMON RX pkts < 64 bytes, good CRC */
 #define RMON_R_OVERSIZE		0x298 /* RMON RX pkts > MAX_FL bytes good CRC=
 */
-#define RMON_R_FRAG		0x29C /* RMON RX pkts < 64 bytes, bad CRC */
-#define RMON_R_JAB		0x2A0 /* RMON RX pkts > MAX_FL bytes, bad CRC */
-#define RMON_R_RESVD_O		0x2A4 /* Reserved */
-#define RMON_R_P64		0x2A8 /* RMON RX 64 byte pkts */
-#define RMON_R_P65TO127		0x2AC /* RMON RX 65 to 127 byte pkts */
-#define RMON_R_P128TO255	0x2B0 /* RMON RX 128 to 255 byte pkts */
-#define RMON_R_P256TO511	0x2B4 /* RMON RX 256 to 511 byte pkts */
-#define RMON_R_P512TO1023	0x2B8 /* RMON RX 512 to 1023 byte pkts */
-#define RMON_R_P1024TO2047	0x2BC /* RMON RX 1024 to 2047 byte pkts */
-#define RMON_R_P_GTE2048	0x2C0 /* RMON RX pkts > 2048 bytes */
-#define RMON_R_OCTETS		0x2C4 /* RMON RX octets */
-#define IEEE_R_DROP		0x2C8 /* Count frames not counted correctly */
-#define IEEE_R_FRAME_OK		0x2CC /* Frames rx'd OK */
-#define IEEE_R_CRC		0x2D0 /* Frames rx'd with CRC err */
-#define IEEE_R_ALIGN		0x2D4 /* Frames rx'd with alignment err */
-#define IEEE_R_MACERR		0x2D8 /* Receive FIFO overflow count */
-#define IEEE_R_FDXFC		0x2DC /* Flow control pause frames rx'd */
-#define IEEE_R_OCTETS_OK	0x2E0 /* Octet cnt for frames rx'd w/o err */
+#define RMON_R_FRAG		0x29c /* RMON RX pkts < 64 bytes, bad CRC */
+#define RMON_R_JAB		0x2a0 /* RMON RX pkts > MAX_FL bytes, bad CRC */
+#define RMON_R_RESVD_O		0x2a4 /* Reserved */
+#define RMON_R_P64		0x2a8 /* RMON RX 64 byte pkts */
+#define RMON_R_P65TO127		0x2ac /* RMON RX 65 to 127 byte pkts */
+#define RMON_R_P128TO255	0x2b0 /* RMON RX 128 to 255 byte pkts */
+#define RMON_R_P256TO511	0x2b4 /* RMON RX 256 to 511 byte pkts */
+#define RMON_R_P512TO1023	0x2b8 /* RMON RX 512 to 1023 byte pkts */
+#define RMON_R_P1024TO2047	0x2bc /* RMON RX 1024 to 2047 byte pkts */
+#define RMON_R_P_GTE2048	0x2c0 /* RMON RX pkts > 2048 bytes */
+#define RMON_R_OCTETS		0x2c4 /* RMON RX octets */
+#define IEEE_R_DROP		0x2c8 /* Count frames not counted correctly */
+#define IEEE_R_FRAME_OK		0x2cc /* Frames rx'd OK */
+#define IEEE_R_CRC		0x2d0 /* Frames rx'd with CRC err */
+#define IEEE_R_ALIGN		0x2d4 /* Frames rx'd with alignment err */
+#define IEEE_R_MACERR		0x2d8 /* Receive FIFO overflow count */
+#define IEEE_R_FDXFC		0x2dc /* Flow control pause frames rx'd */
+#define IEEE_R_OCTETS_OK	0x2e0 /* Octet cnt for frames rx'd w/o err */
=20
 #else
=20
@@ -170,16 +170,16 @@
 /* Not existed in real chip
  * Just for pass build.
  */
-#define FEC_RCMR_1		0xFFF
-#define FEC_RCMR_2		0xFFF
-#define FEC_DMA_CFG_1		0xFFF
-#define FEC_DMA_CFG_2		0xFFF
-#define FEC_TXIC0		0xFFF
-#define FEC_TXIC1		0xFFF
-#define FEC_TXIC2		0xFFF
-#define FEC_RXIC0		0xFFF
-#define FEC_RXIC1		0xFFF
-#define FEC_RXIC2		0xFFF
+#define FEC_RCMR_1		0xfff
+#define FEC_RCMR_2		0xfff
+#define FEC_DMA_CFG_1		0xfff
+#define FEC_DMA_CFG_2		0xfff
+#define FEC_TXIC0		0xfff
+#define FEC_TXIC1		0xfff
+#define FEC_TXIC2		0xfff
+#define FEC_RXIC0		0xfff
+#define FEC_RXIC1		0xfff
+#define FEC_RXIC2		0xfff
 #endif /* CONFIG_M5272 */
=20
=20
@@ -296,7 +296,7 @@ struct bufdesc_ex {
=20
 #define DMA_CLASS_EN		(1 << 16)
 #define FEC_RCMR(X)		((X =3D=3D 2) ? FEC_RCMR_2 : FEC_RCMR_1)
-#define IDLE_SLOPE_MASK		0xFFFF
+#define IDLE_SLOPE_MASK		0xffff
 #define IDLE_SLOPE_1		0x200 /* BW fraction: 0.5 */
 #define IDLE_SLOPE_2		0x200 /* BW fraction: 0.5 */
 #define IDLE_SLOPE(X)		((X =3D=3D 1) ? (IDLE_SLOPE_1 & IDLE_SLOPE_MASK=
) : \
@@ -308,7 +308,7 @@ struct bufdesc_ex {
 #define RCMR_CMP_2		(RCMR_CMP_CFG(4, 0) | RCMR_CMP_CFG(5, 1) | \
 				RCMR_CMP_CFG(6, 2) | RCMR_CMP_CFG(7, 3))
 #define RCMR_CMP(X)		((X =3D=3D 1) ? RCMR_CMP_1 : RCMR_CMP_2)
-#define FEC_TX_BD_FTYPE(X)	((X & 0xF) << 20)
+#define FEC_TX_BD_FTYPE(X)	((X & 0xf) << 20)
=20
 /* The number of Tx and Rx buffers.  These are allocated from the page
  * pool.  The code may assume these are power of two, so it it best
@@ -359,8 +359,8 @@ struct bufdesc_ex {
 /* ENET interrupt coalescing macro define */
 #define FEC_ITR_CLK_SEL		(0x1 << 30)
 #define FEC_ITR_EN		(0x1 << 31)
-#define FEC_ITR_ICFT(X)		((X & 0xFF) << 20)
-#define FEC_ITR_ICTT(X)		((X) & 0xFFFF)
+#define FEC_ITR_ICFT(X)		((X & 0xff) << 20)
+#define FEC_ITR_ICTT(X)		((X) & 0xffff)
 #define FEC_ITR_ICFT_DEFAULT	200  /* Set 200 frame count threshold */
 #define FEC_ITR_ICTT_DEFAULT	1000 /* Set 1000us timer threshold */
=20
--=20
1.7.10.4
