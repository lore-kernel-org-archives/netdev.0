From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH TRIVIAL] net: Spelling s/transmition/transmission/
Date: Sun, 12 Jan 2014 14:06:16 +0100
Message-ID: <1389531976-6350-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@linux-m68k.org>
To: Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gerard.telenet-ops.be ([195.130.132.48]:32976 "EHLO
	gerard.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaALNGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 08:06:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@linux-m68k.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@linux-m68k.org>
---
 drivers/net/ethernet/tehuti/tehuti.c |    2 +-
 drivers/net/wan/hd64570.h            |    4 ++--
 drivers/net/wan/hd64572.h            |    2 +-
 net/nfc/hci/llc_shdlc.c              |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 4f1d2549130e..2ead87759ab4 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1764,7 +1764,7 @@ static void bdx_tx_cleanup(struct bdx_priv *priv)
 	WRITE_REG(priv, f->m.reg_RPTR, f->m.rptr & TXF_WPTR_WR_PTR);
 
 	/* We reclaimed resources, so in case the Q is stopped by xmit callback,
-	 * we resume the transmition and use tx_lock to synchronize with xmit.*/
+	 * we resume the transmission and use tx_lock to synchronize with xmit.*/
 	spin_lock(&priv->tx_lock);
 	priv->tx_level += tx_level;
 	BDX_ASSERT(priv->tx_level <= 0 || priv->tx_level > BDX_MAX_TX_LEVEL);
diff --git a/drivers/net/wan/hd64570.h b/drivers/net/wan/hd64570.h
index e4f539ad071b..10963e8f4b39 100644
--- a/drivers/net/wan/hd64570.h
+++ b/drivers/net/wan/hd64570.h
@@ -159,7 +159,7 @@ typedef struct {
 /* Packet Descriptor Status bits */
 
 #define ST_TX_EOM     0x80	/* End of frame */
-#define ST_TX_EOT     0x01	/* End of transmition */
+#define ST_TX_EOT     0x01	/* End of transmission */
 
 #define ST_RX_EOM     0x80	/* End of frame */
 #define ST_RX_SHORT   0x40	/* Short frame */
@@ -211,7 +211,7 @@ typedef struct {
 
 #define CTL_NORTS     0x01
 #define CTL_IDLE      0x10	/* Transmit an idle pattern */
-#define CTL_UDRNC     0x20	/* Idle after CRC or FCS+flag transmition */
+#define CTL_UDRNC     0x20	/* Idle after CRC or FCS+flag transmission */
 
 #define ST0_TXRDY     0x02	/* TX ready */
 #define ST0_RXRDY     0x01	/* RX ready */
diff --git a/drivers/net/wan/hd64572.h b/drivers/net/wan/hd64572.h
index 96567c2dc4db..22137ee669cf 100644
--- a/drivers/net/wan/hd64572.h
+++ b/drivers/net/wan/hd64572.h
@@ -218,7 +218,7 @@ typedef struct {
 #define ST_TX_EOM     0x80	/* End of frame */
 #define ST_TX_UNDRRUN 0x08
 #define ST_TX_OWNRSHP 0x02
-#define ST_TX_EOT     0x01	/* End of transmition */
+#define ST_TX_EOT     0x01	/* End of transmission */
 
 #define ST_RX_EOM     0x80	/* End of frame */
 #define ST_RX_SHORT   0x40	/* Short frame */
diff --git a/net/nfc/hci/llc_shdlc.c b/net/nfc/hci/llc_shdlc.c
index 27b313befc35..3e53c1e029dc 100644
--- a/net/nfc/hci/llc_shdlc.c
+++ b/net/nfc/hci/llc_shdlc.c
@@ -300,7 +300,7 @@ static void llc_shdlc_rcv_rej(struct llc_shdlc *shdlc, int y_nr)
 {
 	struct sk_buff *skb;
 
-	pr_debug("remote asks retransmition from frame %d\n", y_nr);
+	pr_debug("remote asks retransmission from frame %d\n", y_nr);
 
 	if (llc_shdlc_x_lteq_y_lt_z(shdlc->dnr, y_nr, shdlc->ns)) {
 		if (shdlc->t2_active) {
-- 
1.7.9.5
