From: Hanna Linder <hannal@us.ibm.com>
Subject: [PATCH 2.6] firestream.c replace pci_find_device with pci_get_device (fwd)
Date: Wed, 13 Oct 2004 15:37:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410000.1097707039@w-hlinder.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



---------- Forwarded Message ----------
Date: Wednesday, October 13, 2004 03:17:23 PM -0700
From: Hanna Linder <hannal@us.ibm.com>
To: lkml <linux-kernel@vger.kernel.org>, kernel-janitors <kernel-janitors@lists.osdl.org>
Cc: Hanna Linder <hannal@us.ibm.com>, greg@kroah.com, chas@cmf.nrl.navy.mil
Subject: [PATCH 2.6] firestream.c replace pci_find_device with pci_get_device


As pci_find_device is going away soon I have converted this file to use
pci_get_device instead. I have compile tested it. If anyone has this ATM card
and could test it that would be great.

Hanna Linder
IBM Linux Technology Center

Signed-off-by: Hanna Linder <hannal@us.ibm.com>

---
diff -Nrup linux-2.6.9-rc4-mm1cln/drivers/atm/firestream.c linux-2.6.9-rc4-mm1patch2/drivers/atm/firestream.c
--- linux-2.6.9-rc4-mm1cln/drivers/atm/firestream.c	2004-10-12 14:15:10.000000000 -0700
+++ linux-2.6.9-rc4-mm1patch2/drivers/atm/firestream.c	2004-10-13 13:51:35.570994152 -0700
@@ -2021,7 +2021,7 @@ int __init fs_detect(void)
 
 	func_enter ();
 	pci_dev = NULL;
-	while ((pci_dev = pci_find_device(PCI_VENDOR_ID_FUJITSU_ME,
+	while ((pci_dev = pci_get_device(PCI_VENDOR_ID_FUJITSU_ME,
 					  PCI_DEVICE_ID_FUJITSU_FS50, 
 					  pci_dev))) {
 		if (fs_register_and_init (pci_dev, &fs_pci_tbl[0]))
@@ -2029,7 +2029,7 @@ int __init fs_detect(void)
 		devs++;
 	}
 
-	while ((pci_dev = pci_find_device(PCI_VENDOR_ID_FUJITSU_ME,
+	while ((pci_dev = pci_get_device(PCI_VENDOR_ID_FUJITSU_ME,
 					  PCI_DEVICE_ID_FUJITSU_FS155, 
 					  pci_dev))) {
 		if (fs_register_and_init (pci_dev, FS_IS155)) 



---------- End Forwarded Message ----------
