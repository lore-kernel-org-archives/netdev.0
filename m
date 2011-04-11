From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH 2/4] net: fix tranmitted/tranmitting typo
Date: Mon, 11 Apr 2011 18:15:57 +0800
Message-ID: <1302516958-9535-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	Lucas De Marchi <lucas.demarchi@profusion.mobi> (commit_signer:1/3=33%),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

replace tranmitted with transmitted.
replace tranmitting with transmitting.

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.h      |    2 +-
 drivers/net/tokenring/3c359.c       |    4 ++--
 drivers/net/tokenring/lanstreamer.c |    2 +-
 drivers/net/tokenring/olympic.c     |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_=
alb.h
index 86861f0..9af19fa 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -75,7 +75,7 @@ struct tlb_client_info {
 				 * gave this entry index.
 				 */
 	u32 tx_bytes;		/* Each Client accumulates the BytesTx that
-				 * were tranmitted to it, and after each
+				 * were transmitted to it, and after each
 				 * CallBack the LoadHistory is divided
 				 * by the balance interval
 				 */
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c35=
9.c
index 8a3b191..ff32bef 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1251,7 +1251,7 @@ static netdev_tx_t xl_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 /*=20
  * The NIC has told us that a packet has been downloaded onto the card=
, we must
  * find out which packet it has done, clear the skb and information fo=
r the packet
- * then advance around the ring for all tranmitted packets
+ * then advance around the ring for all transmitted packets
  */
=20
 static void xl_dn_comp(struct net_device *dev)=20
@@ -1568,7 +1568,7 @@ static void xl_arb_cmd(struct net_device *dev)
 			if (lan_status_diff & LSC_SOFT_ERR)
 					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Ma=
c Frame\n",dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN)=20
-					printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n",dev-=
>name);
+					printk(KERN_INFO "%s: We are transmitting the beacon, aaah\n",dev=
->name);
 			if (lan_status_diff & LSC_SS)=20
 					printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenrin=
g/lanstreamer.c
index 5bd1407..9354ca9 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1675,7 +1675,7 @@ drop_frame:
 			if (lan_status_diff & LSC_SOFT_ERR)
 				printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Mac=
 Frame\n", dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN)
-				printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n", dev-=
>name);
+				printk(KERN_INFO "%s: We are transmitting the beacon, aaah\n", dev=
->name);
 			if (lan_status_diff & LSC_SS)
 				printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/ol=
ympic.c
index 3d2fbe6..2684003 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1500,7 +1500,7 @@ drop_frame:
 			if (lan_status_diff & LSC_SOFT_ERR)
 					printk(KERN_WARNING "%s: Adapter transmitted Soft Error Report Ma=
c Frame\n",dev->name);
 			if (lan_status_diff & LSC_TRAN_BCN)=20
-					printk(KERN_INFO "%s: We are tranmitting the beacon, aaah\n",dev-=
>name);
+					printk(KERN_INFO "%s: We are transmitting the beacon, aaah\n",dev=
->name);
 			if (lan_status_diff & LSC_SS)=20
 					printk(KERN_INFO "%s: Single Station on the ring\n", dev->name);
 			if (lan_status_diff & LSC_RING_REC)
--=20
1.7.4
