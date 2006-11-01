From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 07/18] e1000: reorder pci-e infor struct
Date: Wed, 01 Nov 2006 09:51:44 -0800
Message-ID: <20061101175144.2356.5690.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:18960 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946969AbWKARoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:38 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Order pci-e capability struct according to bus/pci bus width ordering
preserving the hard pci spec numbers.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.h |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 31bea32..f247f26 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -128,11 +128,13 @@ typedef enum {
 /* PCI bus widths */
 typedef enum {
     e1000_bus_width_unknown = 0,
+    /* These PCIe values should literally match the possible return values
+     * from config space */
+    e1000_bus_width_pciex_1 = 1,
+    e1000_bus_width_pciex_2 = 2,
+    e1000_bus_width_pciex_4 = 4,
     e1000_bus_width_32,
     e1000_bus_width_64,
-    e1000_bus_width_pciex_1,
-    e1000_bus_width_pciex_2,
-    e1000_bus_width_pciex_4,
     e1000_bus_width_reserved
 } e1000_bus_width;
 



---
Auke Kok <auke-jan.h.kok@intel.com>
