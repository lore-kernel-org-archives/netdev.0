From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH] ThunderLAN: remove is_eisa flag
Date: Sat, 18 May 2013 23:50:17 +0200
Message-ID: <3469605.xkLC7l46TH@eto>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These 2 places are the only matches for is_eisa in the whole tree.

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
---
 drivers/net/ethernet/ti/tlan.c | 1 -
 drivers/net/ethernet/ti/tlan.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 60c400f..59abfbc 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -533,7 +533,6 @@ static int tlan_probe1(struct pci_dev *pdev, long ioaddr, int irq, int rev,
 		/* This is a hack. We need to know which board structure
 		 * is suited for this adapter */
 		device_id = inw(ioaddr + EISA_ID2);
-		priv->is_eisa = 1;
 		if (device_id == 0x20F1) {
 			priv->adapter = &board_info[13]; /* NetFlex-3/E */
 			priv->adapter_rev = 23;		/* TLAN 2.3 */
diff --git a/drivers/net/ethernet/ti/tlan.h b/drivers/net/ethernet/ti/tlan.h
index 5fc98a8..2eb33a2 100644
--- a/drivers/net/ethernet/ti/tlan.h
+++ b/drivers/net/ethernet/ti/tlan.h
@@ -207,7 +207,6 @@ struct tlan_priv {
 	u8			tlan_full_duplex;
 	spinlock_t		lock;
 	u8			link;
-	u8			is_eisa;
 	struct work_struct			tlan_tqueue;
 	u8			neg_be_verbose;
 };
-- 
1.8.1.4
