From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ambassador] remove warnings related to unused variables
Date: Thu, 23 Sep 2004 14:43:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409231843.i8NIh9sm018124@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

please apply to 2.x.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 10:37:44-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [ambassador] remove warnings related to unused variables
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-09-23 14:38:52 -04:00
+++ b/drivers/atm/ambassador.c	2004-09-23 14:38:52 -04:00
@@ -2291,11 +2291,10 @@
 
 	// read resources from PCI configuration space
 	u8 irq = pci_dev->irq;
-	u32 * membase = bus_to_virt (pci_resource_start (pci_dev, 0));
-	u32 iobase = pci_resource_start (pci_dev, 1);
 
 	PRINTD (DBG_INFO, "found Madge ATM adapter (amb) at"
-		" IO %x, IRQ %u, MEM %p", iobase, irq, membase);
+		" IO %x, IRQ %u, MEM %p", pci_resource_start(pci_dev, 1),
+		irq, bus_to_virt(pci_resource_start(pci_dev, 0)));
 
 	// check IO region
 	err = pci_request_region(pci_dev, 1, DEV_LABEL);
