From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 20/21] e1000: add ich8lan device ID's
Date: Wed, 21 Jun 2006 22:20:51 -0700
Message-ID: <20060622052051.25497.17123.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:65288 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932814AbWFVFOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:53 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add the device ID's of the supported ICH8 LAN devices.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 95f4435..4fdc564 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -73,6 +73,11 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x1026),
 	INTEL_E1000_ETHERNET_DEVICE(0x1027),
 	INTEL_E1000_ETHERNET_DEVICE(0x1028),
+	INTEL_E1000_ETHERNET_DEVICE(0x1049),
+	INTEL_E1000_ETHERNET_DEVICE(0x104A),
+	INTEL_E1000_ETHERNET_DEVICE(0x104B),
+	INTEL_E1000_ETHERNET_DEVICE(0x104C),
+	INTEL_E1000_ETHERNET_DEVICE(0x104D),
 	INTEL_E1000_ETHERNET_DEVICE(0x105E),
 	INTEL_E1000_ETHERNET_DEVICE(0x105F),
 	INTEL_E1000_ETHERNET_DEVICE(0x1060),
@@ -96,6 +101,8 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x109A),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B9),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BA),
+	INTEL_E1000_ETHERNET_DEVICE(0x10BB),
 	/* required last entry */
 	{0,}
 };



--
Auke Kok <auke-jan.h.kok@intel.com>
