From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc2 2/10] tg3: add bcm5752 to tg3_pci_tbl
Date: Wed, 13 Apr 2005 19:38:44 -0400
Message-ID: <04132005193844.8410@laptop>
References: <04132005193843.8351@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <04132005193843.8351@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add hard-coded definition of bcm5752 PCI ID to tg3_pci_tbl.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Next patch will change entry to use pci_ids.h-based definition.

 drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+)

--- bcm5752-support/drivers/net/tg3.c.orig	2005-04-08 17:30:08.886197282 -0400
+++ bcm5752-support/drivers/net/tg3.c	2005-04-08 17:30:17.113065813 -0400
@@ -206,6 +206,8 @@ static struct pci_device_id tg3_pci_tbl[
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5751F,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, 0x1600, /* TIGON3_5752 */
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5753M,
