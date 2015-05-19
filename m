From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next v4 1/2] pci: Add Cavium PCI vendor id
Date: Mon, 18 May 2015 18:59:14 -0700
Message-ID: <1432000757-28700-2-git-send-email-aleksey.makarov@auriga.com>
References: <1432000757-28700-1-git-send-email-aleksey.makarov@auriga.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@auriga.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432000757-28700-1-git-send-email-aleksey.makarov@auriga.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This vendor id will be used by network (vNIC), USB (xHCI),
SATA (AHCI), GPIO, I2C, MMC and maybe other drivers
for ThunderX SoC.

Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@auriga.com>
---
 include/linux/pci_ids.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index e63c02a..3633cc6 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2327,6 +2327,8 @@
 #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
 #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
 
+#define PCI_VENDOR_ID_CAVIUM		0x177d
+
 #define PCI_VENDOR_ID_BELKIN		0x1799
 #define PCI_DEVICE_ID_BELKIN_F5D7010V7	0x701f
 
-- 
2.4.0
