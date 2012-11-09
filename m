From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] isdn: Fix typo in drivers/isdn
Date: Sat, 10 Nov 2012 00:02:49 +0900
Message-ID: <1352473369-13613-1-git-send-email-standby24x7@gmail.com>
Cc: davem@davemloft.net, Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, trivial@kernel.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo in printk within drivers/isdn

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcpci.c    | 2 +-
 drivers/isdn/hardware/mISDN/mISDNisar.c | 2 +-
 drivers/isdn/hisax/callc.c              | 2 +-
 drivers/isdn/hisax/hfc_pci.c            | 2 +-
 drivers/isdn/hisax/hfc_sx.c             | 2 +-
 drivers/isdn/pcbit/layer2.c             | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 81363ff..6e99d73 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -490,7 +490,7 @@ receive_dmsg(struct hfc_pci *hc)
 		    (df->data[le16_to_cpu(zp->z1)])) {
 			if (dch->debug & DEBUG_HW)
 				printk(KERN_DEBUG
-				       "empty_fifo hfcpci paket inv. len "
+				       "empty_fifo hfcpci packet inv. len "
 				       "%d or crc %d\n",
 				       rcnt,
 				       df->data[le16_to_cpu(zp->z1)]);
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index 182ecf0..feafa91 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1302,7 +1302,7 @@ modeisar(struct isar_ch *ch, u32 bprotocol)
 						   &ch->is->Flags))
 				ch->dpath = 1;
 			else {
-				pr_info("modeisar both pathes in use\n");
+				pr_info("modeisar both paths in use\n");
 				return -EBUSY;
 			}
 			if (bprotocol == ISDN_P_B_HDLC)
diff --git a/drivers/isdn/hisax/callc.c b/drivers/isdn/hisax/callc.c
index a47637b..ddec47a 100644
--- a/drivers/isdn/hisax/callc.c
+++ b/drivers/isdn/hisax/callc.c
@@ -35,7 +35,7 @@ static int chancount;
 /* experimental REJECT after ALERTING for CALLBACK to beat the 4s delay */
 #define ALERT_REJECT 0
 
-/* Value to delay the sending of the first B-channel paket after CONNECT
+/* Value to delay the sending of the first B-channel packet after CONNECT
  * here is no value given by ITU, but experience shows that 300 ms will
  * work on many networks, if you or your other side is behind local exchanges
  * a greater value may be recommented. If the delay is to short the first paket
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 334fa90..f60d4be 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -354,7 +354,7 @@ receive_dmsg(struct IsdnCardState *cs)
 		if ((rcnt > MAX_DFRAME_LEN + 3) || (rcnt < 4) ||
 		    (df->data[zp->z1])) {
 			if (cs->debug & L1_DEB_WARN)
-				debugl1(cs, "empty_fifo hfcpci paket inv. len %d or crc %d", rcnt, df->data[zp->z1]);
+				debugl1(cs, "empty_fifo hfcpci packet inv. len %d or crc %d", rcnt, df->data[zp->z1]);
 #ifdef ERROR_STATISTIC
 			cs->err_rx++;
 #endif
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 4db846b..4ec279c 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -270,7 +270,7 @@ read_fifo(struct IsdnCardState *cs, u_char fifo, int trans_max)
 
 		if ((count > fifo_size) || (count < 4)) {
 			if (cs->debug & L1_DEB_WARN)
-				debugl1(cs, "hfcsx_read_fifo %d paket inv. len %d ", fifo , count);
+				debugl1(cs, "hfcsx_read_fifo %d packet inv. len %d ", fifo , count);
 			while (count) {
 				count--; /* empty fifo */
 				Read_hfc(cs, HFCSX_FIF_DRD);
diff --git a/drivers/isdn/pcbit/layer2.c b/drivers/isdn/pcbit/layer2.c
index a18e639..42ecfef 100644
--- a/drivers/isdn/pcbit/layer2.c
+++ b/drivers/isdn/pcbit/layer2.c
@@ -508,7 +508,7 @@ pcbit_irq_handler(int interrupt, void *devptr)
 		return IRQ_NONE;
 	}
 	if (dev->interrupt) {
-		printk(KERN_DEBUG "pcbit: reentering interrupt hander\n");
+		printk(KERN_DEBUG "pcbit: reentering interrupt handler\n");
 		return IRQ_HANDLED;
 	}
 	dev->interrupt = 1;
-- 
1.8.0.rc3.16.g8ead1bf
