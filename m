From: Hanna Linder <hannal@us.ibm.com>
Subject: [PATCH 2.6] ambassador.c replace pci_find_device with pci_get_device (fwd)
Date: Wed, 13 Oct 2004 15:37:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200150000.1097707023@w-hlinder.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



---------- Forwarded Message ----------
Date: Wednesday, October 13, 2004 03:15:59 PM -0700
From: Hanna Linder <hannal@us.ibm.com>
To: lkml <linux-kernel@vger.kernel.org>, kernel-janitors <kernel-janitors@lists.osdl.org>
Cc: greg@kroah.com, hannal@us.ibm.com, chas@cmf.nrl.navy.mil
Subject: [PATCH 2.6] ambassador.c replace pci_find_device with pci_get_device


As pci_find_device is going away soon I have converted this file to use
pci_get_device instead. I have compile tested it. If anyone has this ATM card
and could test it that would be great.

Hanna Linder
IBM Linux Technology Center

Signed-off-by: Hanna Linder <hannal@us.ibm.com>

---

diff -Nrup linux-2.6.9-rc4-mm1cln/drivers/atm/ambassador.c linux-2.6.9-rc4-mm1patch/drivers/atm/ambassador.c
--- linux-2.6.9-rc4-mm1cln/drivers/atm/ambassador.c	2004-10-12 14:15:10.000000000 -0700
+++ linux-2.6.9-rc4-mm1patch/drivers/atm/ambassador.c	2004-10-13 13:50:30.070951672 -0700
@@ -2378,7 +2378,7 @@ static int __init amb_probe (void) {
   
   devs = 0;
   pci_dev = NULL;
-  while ((pci_dev = pci_find_device
+  while ((pci_dev = pci_get_device
           (PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR, pci_dev)
           )) {
 	if (do_pci_device(pci_dev) == 0)
@@ -2387,7 +2387,7 @@ static int __init amb_probe (void) {
 
   
   pci_dev = NULL;
-  while ((pci_dev = pci_find_device
+  while ((pci_dev = pci_get_device
           (PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD, pci_dev)
           ))
     PRINTK (KERN_ERR, "skipped broken (PLX rev 2) card");



---------- End Forwarded Message ----------
