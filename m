From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: Add support for PCI device id 9
Date: Fri, 14 Sep 2007 00:40:14 +0200
Message-ID: <46E9BC4E.4070109@myri.com>
References: <46E9BC1A.5020105@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1801 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753768AbXIMWiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 18:38:24 -0400
In-Reply-To: <46E9BC1A.5020105@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for new Myri-10G boards with PCI device id 9.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-09-11 20:27:17.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-09-14 00:36:36.000000000 +0200
@@ -3094,9 +3094,12 @@
 }
 
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
+#define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9	0x0009
 
 static struct pci_device_id myri10ge_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E)},
+	{PCI_DEVICE
+	 (PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9)},
 	{0},
 };
 


