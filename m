From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv3 3/9] net: fec: properly parenthesize macro args
Date: Tue, 28 Oct 2014 14:22:58 +0100
Message-ID: <1414502584-10583-4-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
 <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.h |   31 ++++++++++++++++----------=
-----
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/etherne=
t/freescale/fec.h
index e778b9e..27e75cf 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -279,36 +279,37 @@ struct bufdesc_ex {
 #define FEC_ENET_MAX_TX_QS	3
 #define FEC_ENET_MAX_RX_QS	3
=20
-#define FEC_R_DES_START(X)	((X =3D=3D 1) ? FEC_R_DES_START_1 : \
-				((X =3D=3D 2) ? \
+#define FEC_R_DES_START(X)	(((X) =3D=3D 1) ? FEC_R_DES_START_1 : \
+				(((X) =3D=3D 2) ? \
 					FEC_R_DES_START_2 : FEC_R_DES_START_0))
-#define FEC_X_DES_START(X)	((X =3D=3D 1) ? FEC_X_DES_START_1 : \
-				((X =3D=3D 2) ? \
+#define FEC_X_DES_START(X)	(((X) =3D=3D 1) ? FEC_X_DES_START_1 : \
+				(((X) =3D=3D 2) ? \
 					FEC_X_DES_START_2 : FEC_X_DES_START_0))
-#define FEC_R_DES_ACTIVE(X)	((X =3D=3D 1) ? FEC_R_DES_ACTIVE_1 : \
-				((X =3D=3D 2) ? \
+#define FEC_R_DES_ACTIVE(X)	(((X) =3D=3D 1) ? FEC_R_DES_ACTIVE_1 : \
+				(((X) =3D=3D 2) ? \
 				   FEC_R_DES_ACTIVE_2 : FEC_R_DES_ACTIVE_0))
-#define FEC_X_DES_ACTIVE(X)	((X =3D=3D 1) ? FEC_X_DES_ACTIVE_1 : \
-				((X =3D=3D 2) ? \
+#define FEC_X_DES_ACTIVE(X)	(((X) =3D=3D 1) ? FEC_X_DES_ACTIVE_1 : \
+				(((X) =3D=3D 2) ? \
 				   FEC_X_DES_ACTIVE_2 : FEC_X_DES_ACTIVE_0))
=20
-#define FEC_DMA_CFG(X)		((X =3D=3D 2) ? FEC_DMA_CFG_2 : FEC_DMA_CFG_1)
+#define FEC_DMA_CFG(X)		(((X) =3D=3D 2) ? FEC_DMA_CFG_2 : FEC_DMA_CFG_=
1)
=20
 #define DMA_CLASS_EN		(1 << 16)
-#define FEC_RCMR(X)		((X =3D=3D 2) ? FEC_RCMR_2 : FEC_RCMR_1)
+#define FEC_RCMR(X)		(((X) =3D=3D 2) ? FEC_RCMR_2 : FEC_RCMR_1)
 #define IDLE_SLOPE_MASK		0xffff
 #define IDLE_SLOPE_1		0x200 /* BW fraction: 0.5 */
 #define IDLE_SLOPE_2		0x200 /* BW fraction: 0.5 */
-#define IDLE_SLOPE(X)		((X =3D=3D 1) ? (IDLE_SLOPE_1 & IDLE_SLOPE_MASK=
) : \
+#define IDLE_SLOPE(X)		(((X) =3D=3D 1) ?				\
+				(IDLE_SLOPE_1 & IDLE_SLOPE_MASK) :	\
 				(IDLE_SLOPE_2 & IDLE_SLOPE_MASK))
 #define RCMR_MATCHEN		(0x1 << 16)
-#define RCMR_CMP_CFG(v, n)	((v & 0x7) <<  (n << 2))
+#define RCMR_CMP_CFG(v, n)	(((v) & 0x7) <<  (n << 2))
 #define RCMR_CMP_1		(RCMR_CMP_CFG(0, 0) | RCMR_CMP_CFG(1, 1) | \
 				RCMR_CMP_CFG(2, 2) | RCMR_CMP_CFG(3, 3))
 #define RCMR_CMP_2		(RCMR_CMP_CFG(4, 0) | RCMR_CMP_CFG(5, 1) | \
 				RCMR_CMP_CFG(6, 2) | RCMR_CMP_CFG(7, 3))
-#define RCMR_CMP(X)		((X =3D=3D 1) ? RCMR_CMP_1 : RCMR_CMP_2)
-#define FEC_TX_BD_FTYPE(X)	((X & 0xf) << 20)
+#define RCMR_CMP(X)		(((X) =3D=3D 1) ? RCMR_CMP_1 : RCMR_CMP_2)
+#define FEC_TX_BD_FTYPE(X)	(((X) & 0xf) << 20)
=20
 /* The number of Tx and Rx buffers.  These are allocated from the page
  * pool.  The code may assume these are power of two, so it it best
@@ -359,7 +360,7 @@ struct bufdesc_ex {
 /* ENET interrupt coalescing macro define */
 #define FEC_ITR_CLK_SEL		(0x1 << 30)
 #define FEC_ITR_EN		(0x1 << 31)
-#define FEC_ITR_ICFT(X)		((X & 0xff) << 20)
+#define FEC_ITR_ICFT(X)		(((X) & 0xff) << 20)
 #define FEC_ITR_ICTT(X)		((X) & 0xffff)
 #define FEC_ITR_ICFT_DEFAULT	200  /* Set 200 frame count threshold */
 #define FEC_ITR_ICTT_DEFAULT	1000 /* Set 1000us timer threshold */
--=20
1.7.10.4
