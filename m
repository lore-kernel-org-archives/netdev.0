From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/13] e1000: Remove 0x1000 as supported device
Date: Wed, 16 Aug 2006 14:56:24 -0700
Message-ID: <20060816215624.27080.38838.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:56841 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932254AbWHPVsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:35 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove pci ID 8086:1000 from the list fo supported devices. This device
has not functioned with the driver for very long (since v. 5.2.4!)
and we lack the resources to come with a substantial fix. There are only
few cards of this type out there.

Signed-off-by: Jeff Kirsher <Jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ea3d504..bd7770f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -48,7 +48,6 @@ static char e1000_copyright[] = "Copyrig
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
 static struct pci_device_id e1000_pci_tbl[] = {
-	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
 	INTEL_E1000_ETHERNET_DEVICE(0x1004),
 	INTEL_E1000_ETHERNET_DEVICE(0x1008),



--
Auke Kok <auke-jan.h.kok@intel.com>
