From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/6] myri10ge - Add missing PCI IDs
Date: Wed, 10 May 2006 23:35:14 +0200
Message-ID: <44625C92.8020209@myri.com>
References: <446259A0.8050504@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:19128 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S964913AbWEJVfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 17:35:24 -0400
To: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
In-Reply-To: <446259A0.8050504@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/6] myri10ge - Add missing PCI IDs

Add nVidia nForce CK804 PCI-E bridge and 
ServerWorks HT2000 PCI-E bridge IDs.
They will be used by the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>

 pci_ids.h |    2 ++
 1 file changed, 2 insertions(+)

--- linux-mm/include/linux/pci_ids.h.old	2006-05-09 03:03:23.000000000 +0200
+++ linux-mm/include/linux/pci_ids.h	2006-05-09 03:05:19.000000000 +0200
@@ -1021,6 +1021,7 @@
 #define PCI_DEVICE_ID_NVIDIA_NVENET_8		0x0056
 #define PCI_DEVICE_ID_NVIDIA_NVENET_9		0x0057
 #define PCI_DEVICE_ID_NVIDIA_CK804_AUDIO	0x0059
+#define PCI_DEVICE_ID_NVIDIA_NFORCE_CK804_PCIE	0x005d
 #define PCI_DEVICE_ID_NVIDIA_NFORCE2_SMBUS	0x0064
 #define PCI_DEVICE_ID_NVIDIA_NFORCE2_IDE	0x0065
 #define PCI_DEVICE_ID_NVIDIA_NVENET_2		0x0066
@@ -1383,6 +1384,7 @@
 #define PCI_DEVICE_ID_SERVERWORKS_LE	  0x0009
 #define PCI_DEVICE_ID_SERVERWORKS_GCNB_LE 0x0017
 #define PCI_DEVICE_ID_SERVERWORKS_EPB	  0x0103
+#define PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE	0x0132
 #define PCI_DEVICE_ID_SERVERWORKS_OSB4	  0x0200
 #define PCI_DEVICE_ID_SERVERWORKS_CSB5	  0x0201
 #define PCI_DEVICE_ID_SERVERWORKS_CSB6    0x0203


