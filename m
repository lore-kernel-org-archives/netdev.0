From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/2] forcedeth new device ids
Date: Tue, 23 Oct 2007 17:09:12 -0400
Message-ID: <471E62F8.60707@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020701040107070607080206"
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:4848 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757680AbXJXSac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 14:30:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020701040107070607080206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds new device ids and features for mcp77 devices into the 
forcedeth driver.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

--------------020701040107070607080206
Content-Type: text/plain;
 name="patch-forcedeth-mcp77"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-mcp77"

--- old/drivers/net/forcedeth.c	2007-10-23 16:47:08.000000000 -0400
+++ new/drivers/net/forcedeth.c	2007-10-23 16:47:11.000000000 -0400
@@ -5597,6 +5597,22 @@
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
 	{0,},
 };
 

--------------020701040107070607080206--
