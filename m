From: auke-jan.h.kok@intel.com (Auke-Jan H Kok)
Subject: [PATCH] e1000: revert 'e1000: Remove 0x1000 as supported device'
Date: Tue, 12 Sep 2006 10:46:15 -0700 (PDT)
Message-ID: <20060912174615.5DA961AB2A1@ahkok-mobl.jf.intel.com>
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	auke@foo-projects.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49324 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1030301AbWILRsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 13:48:01 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The commit 'e1000: Remove 0x1000 as supported device' (Jeff Kirsher,
673a052fde79ab5e9dce569b0336358812ddba2d) Removes PIC device ID 8086:1000
from the list of supported devices. A fix was submitted for the original
issue (commit 6a9516989f94df10d9a27ba543c6b53b3e69c84a).

This commit reverts commit 673a052fde79ab5e9dce569b0336358812ddba2d and
re-enables 82542rev3 chips completely.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1d7c999..a8d724e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -48,6 +48,7 @@ static char e1000_copyright[] = "Copyrig
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
 static struct pci_device_id e1000_pci_tbl[] = {
+	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
 	INTEL_E1000_ETHERNET_DEVICE(0x1004),
 	INTEL_E1000_ETHERNET_DEVICE(0x1008),
