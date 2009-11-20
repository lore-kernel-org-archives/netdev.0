From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT] netxen: remove PCI IDs of CNA device
Date: Thu, 19 Nov 2009 17:08:12 -0800
Message-ID: <1258679292-26098-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58403 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757056AbZKTBIH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 20:08:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove PCI vendor and device IDs for QLE8240 and QLE8242
CNA devices. CNA devices will have separate driver.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 12d1037..bfbf75c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -95,11 +95,6 @@ static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
-#define ENTRY2(device) \
-	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
-	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
-
-#define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
 
 static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
@@ -110,7 +105,6 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT),
 	ENTRY(PCI_DEVICE_ID_NX2031_XG_MGMT2),
 	ENTRY(PCI_DEVICE_ID_NX3031),
-	ENTRY2(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	{0,}
 };
 
-- 
1.6.0.2

