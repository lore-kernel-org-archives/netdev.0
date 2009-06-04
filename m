From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/3] forcedeth: addition of new mcp89 device id
Date: Wed, 03 Jun 2009 21:05:35 -0400
Message-ID: <4A271DDF.1030604@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070109030403030109050304"
To: Manfred Spraul <manfred@colorfullife.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:3800 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbZFDGhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 02:37:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070109030403030109050304
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a new device id for mcp89 chipset.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070109030403030109050304
Content-Type: text/plain;
 name="patch-forcedeth-add-mcp89"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-add-mcp89"

--- old/drivers/net/forcedeth.c	2009-06-03 20:48:27.000000000 -0400
+++ new/drivers/net/forcedeth.c	2009-06-03 20:55:16.000000000 -0400
@@ -6345,6 +6345,10 @@
 		PCI_DEVICE(0x10DE, 0x0AB3),
 		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_NEED_TX_LIMIT2|DEV_HAS_GEAR_MODE|DEV_NEED_PHY_INIT_FIX|DEV_NEED_MSI_FIX,
 	},
+	{	/* MCP89 Ethernet Controller */
+		PCI_DEVICE(0x10DE, 0x0D7D),
+		.driver_data = DEV_NEED_LINKTIMER|DEV_HAS_LARGEDESC|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX_V3|DEV_HAS_STATISTICS_V3|DEV_HAS_TEST_EXTENDED|DEV_HAS_CORRECT_MACADDR|DEV_HAS_COLLISION_FIX|DEV_HAS_GEAR_MODE|DEV_NEED_PHY_INIT_FIX,
+	},
 	{0,},
 };
 

--------------070109030403030109050304--
