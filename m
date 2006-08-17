From: Jesse Huang <jesse@icplus.com.tw>
Subject: [PATCH 1/6] IP100A, add end of pci id table
Date: Thu, 17 Aug 2006 15:00:47 -0400
Message-ID: <1155841247.4532.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr49.hinet.net ([168.95.4.149]:46532 "EHLO msr49.hinet.net")
	by vger.kernel.org with ESMTP id S1751212AbWHQHNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 03:13:23 -0400
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, jesse@icplus.com.tw
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesse Huang <jesse@icplus.com.tw>

Add "0," and "NULL," to sundance_pci_tbl and pci_id_table.

Change Logs:
    Add "0," and "NULL," to sundance_pci_tbl and pci_id_table.

---

 drivers/net/sundance.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

9ef94f8b85a0070e49bb1883a9f124be1711761d
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index ac17377..eb81d91 100755
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -21,8 +21,8 @@
 */
 
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.1"
-#define DRV_RELDATE	"27-Jun-2006"
+#define DRV_VERSION	"1.2"
+#define DRV_RELDATE	"03-Aug-2006"
 
 
 /* The user-configurable values.
@@ -212,7 +212,7 @@ static const struct pci_device_id sundan
 	{ 0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
 	{ 0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
 	{ 0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
-	{ }
+	{ 0,}
 };
 MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
 
@@ -231,7 +231,7 @@ static const struct pci_id_info pci_id_t
 	{"D-Link DL10050-based FAST Ethernet Adapter"},
 	{"Sundance Technology Alta"},
 	{"IC Plus Corporation IP100A FAST Ethernet Adapter"},
-	{ }	/* terminate list. */
+	{ NULL,}	/* terminate list. */
 };
 
 /* This driver was written to use PCI memory space, however x86-oriented
-- 
1.3.GIT



