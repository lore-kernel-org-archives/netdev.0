From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 2/4] net: thunderx: Fix incorrect subsystem devid of VF on pass2 silicon
Date: Fri, 23 Oct 2015 17:14:08 -0700
Message-ID: <1445645650-17328-3-git-send-email-ddaney.cavm@gmail.com>
References: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index b63e579..a937772 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -29,7 +29,7 @@
 static const struct pci_device_id nicvf_id_table[] = {
 	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
 			 PCI_DEVICE_ID_THUNDER_NIC_VF,
-			 PCI_VENDOR_ID_CAVIUM, 0xA11E) },
+			 PCI_VENDOR_ID_CAVIUM, 0xA134) },
 	{ PCI_DEVICE_SUB(PCI_VENDOR_ID_CAVIUM,
 			 PCI_DEVICE_ID_THUNDER_PASS1_NIC_VF,
 			 PCI_VENDOR_ID_CAVIUM, 0xA11E) },
-- 
1.8.3.1
