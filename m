From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/5] Add Myricom PCI vendor ID to pci_ids.h
Date: Tue, 23 May 2006 03:10:23 -0400
Message-ID: <20060523071022.GC30499@myri.com>
References: <20060523070919.GB30499@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gallatin@myri.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:30679 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932074AbWEWHKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 03:10:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060523070919.GB30499@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 1/5] Add Myricom PCI vendor ID to pci_ids.h

Add PCI_VENDOR_ID_MYRICOM to pci_ids.h so that the myri10ge driver
and any other driver for Myricom hardware may use it.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>

 include/linux/pci_ids.h |    1 +
 1 file changed, 1 insertion(+)

--- linux-mm/include/linux/pci_ids.h.old	2006-05-19 04:34:30.000000000 +0200
+++ linux-mm/include/linux/pci_ids.h	2006-05-16 01:42:49.000000000 +0200
@@ -1841,6 +1841,7 @@
 
 #define PCI_VENDOR_ID_SAMSUNG		0x144d
 
+#define PCI_VENDOR_ID_MYRICOM		0x14c1
 
 #define PCI_VENDOR_ID_TITAN		0x14D2
 #define PCI_DEVICE_ID_TITAN_010L	0x8001
