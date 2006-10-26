From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: ServerWorks HT2000 PCI id is already defined in
 pci_ids.h
Date: Thu, 26 Oct 2006 22:51:33 +0200
Message-ID: <45411FD5.3050408@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:61896 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1423648AbWJZUwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 16:52:34 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] myri10ge: ServerWorks HT2000 PCI id is already defined in pci_ids.h

No need to keep defining PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE
in the driver code since it is now defined in pci_ids.h.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    1 -
 1 file changed, 1 deletion(-)



Please apply for 2.6.19 since PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE has been
added to pci_ids.h in -rc1 (commit 6397c75cbc4d7dbc3d07278b57c82a47dafb21b5).

Thanks,
Brice



Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-10-26 22:18:53.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-10-26 22:19:05.000000000 +0200
@@ -2410,7 +2410,6 @@
  * firmware image, and set tx.boundary to 4KB.
  */
 
-#define PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE	0x0132
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
 


