From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [ambassador] fix <irq> type and printk warning (from Randy Dunlap <rddunlap@osdl.org>)
Date: Sun, 31 Oct 2004 10:52:06 -0500
Message-ID: <200410311552.i9VFq5XQ017682@ginger.cmf.nrl.navy.mil>
References: <rddunlap@osdl.org>
Cc: netdev@oss.sgi.com, "Randy.Dunlap" <rddunlap@osdl.org>, myxie@debian.org,
        gprocida@madge.com, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: Message from "Randy.Dunlap" <rddunlap@osdl.org>
   of "Mon, 11 Oct 2004 12:02:17 PDT." <416AD8B9.9000901@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/31 10:49:16-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [ambassador] fix <irq> type and printk warning (from Randy Dunlap <rddunlap@osdl.org>)
# 
# drivers/atm/ambassador.c
#   2004/10/31 10:49:01-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: [ambassador] fix <irq> type and printk warning (from Randy Dunlap <rddunlap@osdl.org>)
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-10-31 10:50:03 -05:00
+++ b/drivers/atm/ambassador.c	2004-10-31 10:50:03 -05:00
@@ -2261,7 +2261,7 @@
 	int err;
 
 	// read resources from PCI configuration space
-	u8 irq = pci_dev->irq;
+	unsigned int irq = pci_dev->irq;
 
 	if (pci_dev->device == PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD) {
 		PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");
@@ -2270,7 +2270,7 @@
 	}
 
 	PRINTD (DBG_INFO, "found Madge ATM adapter (amb) at"
-		" IO %x, IRQ %u, MEM %p", pci_resource_start(pci_dev, 1),
+		" IO %lx, IRQ %u, MEM %p", pci_resource_start(pci_dev, 1),
 		irq, bus_to_virt(pci_resource_start(pci_dev, 0)));
 
 	// check IO region
