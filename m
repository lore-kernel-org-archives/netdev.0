From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth: add support for new device ids
Date: Thu, 25 May 2006 13:10:54 -0400
Message-ID: <4475E51E.8040605@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020608070304050400060403"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:9752 "EHLO
	HQEMGATE01.nvidia.com") by vger.kernel.org with ESMTP
	id S1030395AbWEYUHC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 16:07:02 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020608070304050400060403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds support for the new chips MCP61 and MCP65.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------020608070304050400060403
Content-Type: text/plain;
 name="patch-forcedeth-057-mcp61-mcp65"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-057-mcp61-mcp65"

--- orig-2.6/drivers/net/forcedeth.c	2006-05-25 13:01:03.000000000 -0400
+++ new-2.6/drivers/net/forcedeth.c	2006-05-25 13:02:23.000000000 -0400
@@ -109,6 +109,7 @@
  *	0.54: 21 Mar 2006: Fix spin locks for multi irqs and cleanup.
  *	0.55: 22 Mar 2006: Add flow control (pause frame).
  *	0.56: 22 Mar 2006: Additional ethtool and moduleparam support.
+ *	0.57: 25 May 2006: Support for MCP61 and MCP65 added.
  *
  * Known bugs:
  * We suspect that on some hardware no TX done interrupts are generated.
@@ -120,7 +121,7 @@
  * DEV_NEED_TIMERIRQ will not harm you on sane hardware, only generating a few
  * superfluous timer interrupts from the nic.
  */
-#define FORCEDETH_VERSION		"0.56"
+#define FORCEDETH_VERSION		"0.57"
 #define DRV_NAME			"forcedeth"
 
 #include <linux/module.h>
@@ -4677,6 +4678,38 @@
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_15),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_VLAN|DEV_HAS_MSI|DEV_HAS_MSI_X|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
 	},
+	{	/* MCP61 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_16),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP61 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_17),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP61 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_18),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP61 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_19),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP65 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_20),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP65 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_21),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP65 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_22),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
+	{	/* MCP65 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_23),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS|DEV_HAS_TEST_EXTENDED,
+	},
 	{0,},
 };
 

--------------020608070304050400060403--
