From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/11] drivers/net/tulip/de4x5.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:11 -0800
Message-ID: <594ca287b8d1ad674515eb3c2e35b8d42430eae5.1197671367.git.joe__1971.4425936856$1197671991$gmane$org@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
 <1197671652-32492-6-git-send-email-joe@perches.com>
 <1197671652-32492-7-git-send-email-joe@perches.com>
 <1197671652-32492-8-git-send-email-joe@perches.com>
 <1197671652-32492-9-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	tulip-users@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934844AbXLNWil@vger.kernel.org>
In-Reply-To: <1197671652-32492-9-git-send-email-joe@perches.com>
Message-Id: <594ca287b8d1ad674515eb3c2e35b8d42430eae5.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/de4x5.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 41f34bb..288f994 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5361,14 +5361,11 @@ de4x5_dbg_open(struct net_device *dev)
 {
     struct de4x5_private *lp = netdev_priv(dev);
     int i;
+    DECLARE_MAC_BUF(mac);
 
     if (de4x5_debug & DEBUG_OPEN) {
 	printk("%s: de4x5 opening with irq %d\n",dev->name,dev->irq);
-	printk("\tphysical address: ");
-	for (i=0;i<6;i++) {
-	    printk("%2.2x:",(short)dev->dev_addr[i]);
-	}
-	printk("\n");
+	printk("\tphysical address: %s\n", print_mac(mac, dev->dev_addr));
 	printk("Descriptor head addresses:\n");
 	printk("\t0x%8.8lx  0x%8.8lx\n",(u_long)lp->rx_ring,(u_long)lp->tx_ring);
 	printk("Descriptor addresses:\nRX: ");
-- 
1.5.3.7.949.g2221a6

