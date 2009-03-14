From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 6/6] netxen: update version to 4.0.30
Date: Fri, 13 Mar 2009 17:52:06 -0700
Message-ID: <1236991926-17892-7-git-send-email-dhananjay@netxen.com>
References: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47275 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760919AbZCNAwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:52:15 -0400
In-Reply-To: <1236991926-17892-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To mark all features and bugfixes submitted since 4.0.11.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 595171d..2544129 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -66,8 +66,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 11
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.11"
+#define _NETXEN_NIC_LINUX_SUBVERSION 30
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.30"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 274d1e0..1fb9bcf 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -910,9 +910,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
 
-	if (pci_func_id == 0)
-		printk(KERN_INFO "%s\n", netxen_nic_driver_string);
-
 	if (pdev->class != 0x020000) {
 		printk(KERN_DEBUG "NetXen function %d, class %x will not "
 				"be enabled.\n",pci_func_id, pdev->class);
@@ -1750,6 +1747,8 @@ static struct pci_driver netxen_driver = {
 
 static int __init netxen_init_module(void)
 {
+	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
+
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
 		return -ENOMEM;
 
-- 
1.6.0.2

