From: Hanna Linder <hannal@us.ibm.com>
Subject: [PATCH 2.6] fore200e.c replace pci_find_device with pci_get_device (fwd)
Date: Wed, 13 Oct 2004 15:37:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200680000.1097707048@w-hlinder.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



---------- Forwarded Message ----------
Date: Wednesday, October 13, 2004 03:18:30 PM -0700
From: Hanna Linder <hannal@us.ibm.com>
To: lkml <linux-kernel@vger.kernel.org>, kernel-janitors <kernel-janitors@lists.osdl.org>
Cc: Hanna Linder <hannal@us.ibm.com>, greg@kroah.com, chas@cmf.nrl.navy.mil
Subject: [PATCH 2.6] fore200e.c replace pci_find_device with pci_get_device



As pci_find_device is going away soon I have converted this file to use
pci_get_device instead. I have compile tested it. If anyone has this ATM card
and could test it that would be great.

Hanna Linder
IBM Linux Technology Center

Signed-off-by: Hanna Linder <hannal@us.ibm.com>

---
diff -Nrup linux-2.6.9-rc4-mm1cln/drivers/atm/fore200e.c linux-2.6.9-rc4-mm1patch3/drivers/atm/fore200e.c
--- linux-2.6.9-rc4-mm1cln/drivers/atm/fore200e.c	2004-10-12 14:15:10.000000000 -0700
+++ linux-2.6.9-rc4-mm1patch3/drivers/atm/fore200e.c	2004-10-13 13:57:12.000000000 -0700
@@ -644,7 +644,7 @@ fore200e_pca_detect(const struct fore200
     int              count = index;
     
     do {
-	pci_dev = pci_find_device(PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, pci_dev);
+	pci_dev = pci_get_device(PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, pci_dev);
 	if (pci_dev == NULL)
 	    return NULL;
     } while (count--);



---------- End Forwarded Message ----------
