From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 14:58:36 -0400
Message-ID: <20060707185831.GC22636@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3333 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932256AbWGGS6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 14:58:51 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the AMD 8131 bridge to the list of chipsets that reorder writes.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f645921..ce6f3be 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10078,6 +10078,8 @@ static int __devinit tg3_get_invariants(
 	static struct pci_device_id write_reorder_chipsets[] = {
 		{ PCI_DEVICE(PCI_VENDOR_ID_AMD,
 		             PCI_DEVICE_ID_AMD_FE_GATE_700C) },
+		{ PCI_DEVICE(PCI_VENDOR_ID_AMD,
+		             PCI_DEVICE_ID_AMD_8131_BRIDGE) },
 		{ PCI_DEVICE(PCI_VENDOR_ID_VIA,
 			     PCI_DEVICE_ID_VIA_8385_0) },
 		{ },
-- 
John W. Linville
linville@tuxdriver.com
