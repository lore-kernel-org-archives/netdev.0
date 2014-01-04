From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v5 01/17] pci_regs.h: Add PCI bus link speed and width defines
Date: Fri,  3 Jan 2014 21:56:29 -0800
Message-ID: <1388815005-23166-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	<linux-kernel@vger.kernel.org>, Bjorn Helgaas <bhelgaas@google.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388815005-23166-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing PCI bus link speed 8.0 GT/s and bus link widths of
x1, x2, x4 and x8.

CC: <linux-kernel@vger.kernel.org>
CC: Bjorn Helgaas <bhelgaas@google.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Bjorn Helgaas <bhelgaas@google.com>
---
 include/uapi/linux/pci_regs.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_regs.h
index 4a98e85..c870c2a 100644
--- a/include/uapi/linux/pci_regs.h
+++ b/include/uapi/linux/pci_regs.h
@@ -489,7 +489,12 @@
 #define  PCI_EXP_LNKSTA_CLS	0x000f	/* Current Link Speed */
 #define  PCI_EXP_LNKSTA_CLS_2_5GB 0x0001 /* Current Link Speed 2.5GT/s */
 #define  PCI_EXP_LNKSTA_CLS_5_0GB 0x0002 /* Current Link Speed 5.0GT/s */
+#define  PCI_EXP_LNKSTA_CLS_8_0GB 0x0003 /* Current Link Speed 8.0GT/s */
 #define  PCI_EXP_LNKSTA_NLW	0x03f0	/* Negotiated Link Width */
+#define  PCI_EXP_LNKSTA_NLW_X1	0x0010	/* Current Link Width x1 */
+#define  PCI_EXP_LNKSTA_NLW_X2	0x0020	/* Current Link Width x2 */
+#define  PCI_EXP_LNKSTA_NLW_X4	0x0040	/* Current Link Width x4 */
+#define  PCI_EXP_LNKSTA_NLW_X8	0x0080	/* Current Link Width x8 */
 #define  PCI_EXP_LNKSTA_NLW_SHIFT 4	/* start of NLW mask in link status */
 #define  PCI_EXP_LNKSTA_LT	0x0800	/* Link Training */
 #define  PCI_EXP_LNKSTA_SLC	0x1000	/* Slot Clock Configuration */
-- 
1.8.3.1
