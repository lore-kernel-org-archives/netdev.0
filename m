From: Joe Perches <joe@perches.com>
Subject: [PATCH 32/59] drivers/net/netxen: Add missing "space"
Date: Mon, 19 Nov 2007 17:48:24 -0800
Message-ID: <1195523331-15303-33-git-send-email-joe@perches.com>
References: 1234567
 <1195523331-15303-1-git-send-email-joe@perches.com>
 <1195523331-15303-2-git-send-email-joe@perches.com>
 <1195523331-15303-3-git-send-email-joe@perches.com>
 <1195523331-15303-4-git-send-email-joe@perches.com>
 <1195523331-15303-5-git-send-email-joe@perches.com>
 <1195523331-15303-6-git-send-email-joe@perches.com>
 <1195523331-15303-7-git-send-email-joe@perches.com>
 <1195523331-15303-8-git-send-email-joe@perches.com>
 <1195523331-15303-9-git-send-email-joe@perches.com>
 <1195523331-15303-10-git-send-email-joe@perches.com>
 <1195523331-15303-11-git-send-email-joe@perches.com>
 <1195523331-15303-12-git-send-email-joe@perches.com>
 <1195523331-15303-13-git-send-email-joe@perches.com>
 <1195523331-15303-14-git-send-email-joe@perches.com>
 <1195523331-15303-15-git-send-email-joe@perches.com>
 <1195523331-15303-16-git-send-email-joe@perches.com>
 <1195523331-15303-17-git-send-email-joe@perches.com>
 <1195523331-15303-18-git-send-email-joe@perches.com>
 <1195523331-15303-19-git-send-email-joe@perches.com>
 <1195523331-15303-20-git-send-email-joe@perches.com>
 <1195523331-15303-21-git-send-email-joe@perches.com>
 <1195523331-15303-22-git-send-email-joe@perches.com>
 <1195523331-15303-23-git-send-email-joe@perches.com>
 <1195523331-15303-24-git-send-email-joe@perches.com>
 <1195523331-15303-25-git-send-email-joe@perches.com>
 <1195523331-15303-26-git-send-email-joe@perches.com>
 <1195523331-15303-27-git-send-email-joe@perches.com>
 <1195523331-15303-28-git-send-email-joe@perches.com>
 <1195523331-15303-29-git-send-email-joe@perches.com>
 <1195523331-15303-30-git-send-email-joe@perches.com>
 <1195523331-15303-31-git-send-email-joe@perches.com>
 <1195523331-15303-32-git-send-email-joe@perches.com>
Cc: "Amit S. Kale" <amitkale@netxen.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2118 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756345AbXKTBtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:49:21 -0500
In-Reply-To: <1195523331-15303-32-git-send-email-joe@perches.com>
Message-Id: <3ed0b0aee275e6a8632b1be454a61f3a2b73639c.1195454435.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    2 +-
 drivers/net/netxen/netxen_nic_init.c |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    6 +++---
 drivers/net/netxen/netxen_nic_niu.c  |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 2c19b8d..8d692e2 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -664,7 +664,7 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F3));
 			break;
 		default:
-			printk(KERN_INFO "Changing the window for PCI function"
+			printk(KERN_INFO "Changing the window for PCI function "
 					"%d\n",	adapter->ahw.pci_func);
 			offset = PCI_OFFSET_SECOND_RANGE(adapter,
 					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 3758926..89d9b53 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1102,8 +1102,8 @@ netxen_process_rcv(struct netxen_adapter *adapter, int ctxid,
 		}
 		if (buffer->lro_current_frags != buffer->lro_expected_frags) {
 			if (buffer->lro_expected_frags != 0) {
-				printk("LRO: (refhandle:%x) recv frag."
-				       "wait for last. flags: %x expected:%d"
+				printk("LRO: (refhandle:%x) recv frag. "
+				       "wait for last. flags: %x expected:%d "
 				       "have:%d\n", index,
 				       netxen_get_sts_desc_lro_last_frag(desc),
 				       buffer->lro_expected_frags,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index a80f0cd..f648d43 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -287,7 +287,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
 
 	if (pdev->class != 0x020000) {
-		printk(KERN_ERR"NetXen function %d, class %x will not"
+		printk(KERN_ERR"NetXen function %d, class %x will not "
 				"be enabled.\n",pci_func_id, pdev->class);
 		return -ENODEV;
 	}
@@ -511,7 +511,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			    vmalloc(RCV_BUFFSIZE);
 
 			if (rcv_desc->rx_buf_arr == NULL) {
-				printk(KERN_ERR "%s: Could not allocate"
+				printk(KERN_ERR "%s: Could not allocate "
 				       "rcv_desc->rx_buf_arr memory:%d\n",
 				       netxen_nic_driver_name,
 				       (int)RCV_BUFFSIZE);
@@ -983,7 +983,7 @@ static int netxen_nic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (frag_count > MAX_BUFFERS_PER_CMD) {
-		printk("%s: %s netxen_nic_xmit_frame: frag_count (%d)"
+		printk("%s: %s netxen_nic_xmit_frame: frag_count (%d) "
 		       "too large, can handle only %d frags\n",
 		       netxen_nic_driver_name, netdev->name,
 		       frag_count, MAX_BUFFERS_PER_CMD);
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index 5b9e1b3..155429d 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -544,8 +544,8 @@ int netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
 								    port,
 								    enable);
 				} else {
-					printk(KERN_ERR PFX "ERROR reading"
-					       "PHY status. Illegal speed.\n");
+					printk(KERN_ERR PFX "ERROR reading "
+					       "PHY status. Invalid speed.\n");
 					result = -1;
 				}
 			} else {
-- 
1.5.3.5.652.gf192c

