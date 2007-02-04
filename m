From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH netdev#atl1 3/3] pci_ids: add Attansic vendor id
Date: Sat, 3 Feb 2007 20:26:11 -0600
Message-ID: <20070204022611.GD4063@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf23aec.mail.bellsouth.net ([205.152.59.71]:50484 "EHLO
	imf23aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935AbXBDC0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 21:26:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

pci_ids: add Attansic vendor id

Add Attansic to pci_ids and use the ID in the driver.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    2 +-
 include/linux/pci_ids.h      |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index b037ebc..9a3fb86 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -102,7 +102,7 @@ extern struct ethtool_ops atl1_ethtool_ops;
  * atl1_pci_tbl - PCI Device ID Table
  */
 static const struct pci_device_id atl1_pci_tbl[] = {
-	{PCI_DEVICE(0x1969, 0x1048)},
+	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, 0x1048)},
 	/* required last entry */
 	{0,}
 };
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 3d1d210..68a7be9 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2066,6 +2066,8 @@
 #define PCI_VENDOR_ID_TDI               0x192E
 #define PCI_DEVICE_ID_TDI_EHCI          0x0101
 
+#define PCI_VENDOR_ID_ATTANSIC		0x1969
+
 #define PCI_VENDOR_ID_JMICRON		0x197B
 #define PCI_DEVICE_ID_JMICRON_JMB360	0x2360
 #define PCI_DEVICE_ID_JMICRON_JMB361	0x2361
