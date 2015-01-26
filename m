From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/5] PCI: Add defines for max read request sizes
Date: Mon, 26 Jan 2015 18:05:22 +0100
Message-ID: <1422291922-12324-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	Bradley Grove <linuxdrivers@attotech.com>,
	linux-scsi@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are few drivers using magic numbers when operating with PCIe
capabilities and PCI_EXP_DEVCTL_READRQ. Define known values to allow
cleaning their code a bit.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 include/uapi/linux/pci_regs.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/uapi/linux/pci_regs.h b/include/uapi/linux/pci_reg=
s.h
index 4a1d0cc..efe3443 100644
--- a/include/uapi/linux/pci_regs.h
+++ b/include/uapi/linux/pci_regs.h
@@ -451,6 +451,10 @@
 #define  PCI_EXP_DEVCTL_AUX_PME	0x0400	/* Auxiliary Power PM Enable */
 #define  PCI_EXP_DEVCTL_NOSNOOP_EN 0x0800  /* Enable No Snoop */
 #define  PCI_EXP_DEVCTL_READRQ	0x7000	/* Max_Read_Request_Size */
+#define  PCI_EXP_DEVCTL_READRQ_128B  0x0000 /* 128 Bytes */
+#define  PCI_EXP_DEVCTL_READRQ_256B  0x1000 /* 256 Bytes */
+#define  PCI_EXP_DEVCTL_READRQ_512B  0x2000 /* 512 Bytes */
+#define  PCI_EXP_DEVCTL_READRQ_1024B 0x3000 /* 1024 Bytes */
 #define  PCI_EXP_DEVCTL_BCR_FLR 0x8000  /* Bridge Configuration Retry =
/ FLR */
 #define PCI_EXP_DEVSTA		10	/* Device Status */
 #define  PCI_EXP_DEVSTA_CED	0x0001	/* Correctable Error Detected */
--=20
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
