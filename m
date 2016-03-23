From: Maxim Zhukov <mussitantesmortem@gmail.com>
Subject: [PATCH 2/2] drivers: net: ethernet: dlink: dl2k: fix indent
Date: Wed, 23 Mar 2016 17:36:40 +0300
Message-ID: <1458743800-30606-2-git-send-email-mussitantesmortem@gmail.com>
References: <1458743800-30606-1-git-send-email-mussitantesmortem@gmail.com>
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Maxim Zhukov <mussitantesmortem@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458743800-30606-1-git-send-email-mussitantesmortem@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit fixed indent in file. Labels must be start of the line

Signed-off-by: Maxim Zhukov <mussitantesmortem@gmail.com>
---
 drivers/net/ethernet/dlink/dl2k.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index d128306..e635b1e 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -98,7 +98,7 @@ static const struct ethtool_ops ethtool_ops;
 
 static const struct net_device_ops netdev_ops = {
 	.ndo_open		= rio_open,
-	.ndo_start_xmit	= start_xmit,
+	.ndo_start_xmit		= start_xmit,
 	.ndo_stop		= rio_close,
 	.ndo_get_stats		= get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -174,7 +174,7 @@ rio_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 			    strcmp(media[card_idx], "0") == 0) {
 				np->an_enable = 2;
 			} else if (strcmp(media[card_idx], "100mbps_fd") == 0 ||
-			    strcmp(media[card_idx], "4") == 0) {
+				   strcmp(media[card_idx], "4") == 0) {
 				np->speed = 100;
 				np->full_duplex = 1;
 			} else if (strcmp(media[card_idx], "100mbps_hd") == 0 ||
@@ -190,11 +190,11 @@ rio_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 				np->speed = 10;
 				np->full_duplex = 0;
 			} else if (strcmp(media[card_idx], "1000mbps_fd") == 0 ||
-				 strcmp(media[card_idx], "6") == 0) {
+				  strcmp(media[card_idx], "6") == 0) {
 				np->speed = 1000;
 				np->full_duplex = 1;
 			} else if (strcmp(media[card_idx], "1000mbps_hd") == 0 ||
-				 strcmp(media[card_idx], "5") == 0) {
+				  strcmp(media[card_idx], "5") == 0) {
 				np->speed = 1000;
 				np->full_duplex = 0;
 			} else {
@@ -210,7 +210,7 @@ rio_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 				dev->mtu = mtu[card_idx];
 		}
 		np->vlan = (vlan[card_idx] > 0 && vlan[card_idx] < 4096) ?
-		    vlan[card_idx] : 0;
+			    vlan[card_idx] : 0;
 		if (rx_coalesce > 0 && rx_timeout > 0) {
 			np->rx_coalesce = rx_coalesce;
 			np->rx_timeout = rx_timeout;
@@ -278,12 +278,12 @@ rio_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->name, np->name, dev->dev_addr, irq);
 	if (tx_coalesce > 1)
 		printk(KERN_INFO "tx_coalesce:\t%d packets\n",
-				tx_coalesce);
+				 tx_coalesce);
 	if (np->coalesce)
 		printk(KERN_INFO
 		       "rx_coalesce:\t%d packets\n"
 		       "rx_timeout: \t%d ns\n",
-				np->rx_coalesce, np->rx_timeout * 640);
+		       np->rx_coalesce, np->rx_timeout * 640);
 	if (np->vlan)
 		printk(KERN_INFO "vlan(id):\t%d\n", np->vlan);
 	return 0;
@@ -1470,7 +1470,7 @@ mii_read(struct net_device *dev, int phy_addr, int reg_num)
 	mii_getbit(dev);
 	return (retval >> 1) & 0xffff;
 
-      err_out:
+err_out:
 	return 0;
 }
 static int
-- 
2.7.1.1.g3617aa0
