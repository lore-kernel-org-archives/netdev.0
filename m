From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net-next v6 1/2] pci: Add Cavium PCI vendor id
Date: Tue, 26 May 2015 19:20:14 -0700
Message-ID: <1432693228-5554-2-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1432693228-5554-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>, linux-pci@vger.kernel.org,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Sunil Goutham <sgoutham@cavium.com>,
 linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1432693228-5554-1-git-send-email-aleksey.makarov@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This vendor id will be used by network (vNIC), USB (xHCI),
SATA (AHCI), GPIO, I2C, MMC and maybe other drivers
for ThunderX SoC.

Acked-by: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 include/linux/pci_ids.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 1fa99a3..80bd333 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2324,6 +2324,8 @@
 #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
 #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
 
+#define PCI_VENDOR_ID_CAVIUM		0x177d
+
 #define PCI_VENDOR_ID_BELKIN		0x1799
 #define PCI_DEVICE_ID_BELKIN_F5D7010V7	0x701f
 
-- 
2.4.1
