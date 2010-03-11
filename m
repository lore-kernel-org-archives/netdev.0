From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 4/4] AM3517 defconfig update : enable EMAC support
Date: Thu, 11 Mar 2010 20:43:42 +0530
Message-ID: <1268320422-32656-5-git-send-email-srk@ti.com>
References: <1268320422-32656-1-git-send-email-srk@ti.com>
 <1268320422-32656-2-git-send-email-srk@ti.com>
 <1268320422-32656-3-git-send-email-srk@ti.com>
 <1268320422-32656-4-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:44885 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675Ab0CKPNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 10:13:50 -0500
In-Reply-To: <1268320422-32656-4-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the default configuration for AM3517EVM to enable
support for EMAC peripheral.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 arch/arm/configs/am3517_evm_defconfig |   70 ++++++++++++++++++++++++++++++++-
 1 files changed, 69 insertions(+), 1 deletions(-)

diff --git a/arch/arm/configs/am3517_evm_defconfig b/arch/arm/configs/am3517_evm_defconfig
index 66a10b5..8d79b20 100644
--- a/arch/arm/configs/am3517_evm_defconfig
+++ b/arch/arm/configs/am3517_evm_defconfig
@@ -517,7 +517,75 @@ CONFIG_SCSI_LOWLEVEL=y
 # CONFIG_SCSI_OSD_INITIATOR is not set
 # CONFIG_ATA is not set
 # CONFIG_MD is not set
-# CONFIG_NETDEVICES is not set
+CONFIG_NETDEVICES=y
+# CONFIG_DUMMY is not set
+# CONFIG_BONDING is not set
+# CONFIG_MACVLAN is not set
+# CONFIG_EQUALIZER is not set
+# CONFIG_TUN is not set
+# CONFIG_VETH is not set
+CONFIG_PHYLIB=y
+
+#
+# MII PHY device drivers
+#
+# CONFIG_MARVELL_PHY is not set
+# CONFIG_DAVICOM_PHY is not set
+# CONFIG_QSEMI_PHY is not set
+# CONFIG_LXT_PHY is not set
+# CONFIG_CICADA_PHY is not set
+# CONFIG_VITESSE_PHY is not set
+# CONFIG_SMSC_PHY is not set
+# CONFIG_BROADCOM_PHY is not set
+# CONFIG_ICPLUS_PHY is not set
+# CONFIG_REALTEK_PHY is not set
+# CONFIG_NATIONAL_PHY is not set
+# CONFIG_STE10XP is not set
+# CONFIG_LSI_ET1011C_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
+CONFIG_NET_ETHERNET=y
+# CONFIG_MII is not set
+# CONFIG_AX88796 is not set
+# CONFIG_SMC91X is not set
+CONFIG_TI_DAVINCI_EMAC=y
+# CONFIG_DM9000 is not set
+# CONFIG_ETHOC is not set
+# CONFIG_SMC911X is not set
+# CONFIG_SMSC911X is not set
+# CONFIG_DNET is not set
+# CONFIG_IBM_NEW_EMAC_ZMII is not set
+# CONFIG_IBM_NEW_EMAC_RGMII is not set
+# CONFIG_IBM_NEW_EMAC_TAH is not set
+# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
+# CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL is not set
+# CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT is not set
+# CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR is not set
+# CONFIG_B44 is not set
+# CONFIG_KS8842 is not set
+# CONFIG_KS8851_MLL is not set
+# CONFIG_NETDEV_1000 is not set
+# CONFIG_NETDEV_10000 is not set
+# CONFIG_WLAN is not set
+
+#
+# Enable WiMAX (Networking options) to see the WiMAX drivers
+#
+
+#
+# USB Network Adapters
+#
+# CONFIG_USB_CATC is not set
+# CONFIG_USB_KAWETH is not set
+# CONFIG_USB_PEGASUS is not set
+# CONFIG_USB_RTL8150 is not set
+# CONFIG_USB_USBNET is not set
+# CONFIG_WAN is not set
+# CONFIG_PPP is not set
+# CONFIG_SLIP is not set
+# CONFIG_NETCONSOLE is not set
+# CONFIG_NETPOLL is not set
+# CONFIG_NET_POLL_CONTROLLER is not set
 # CONFIG_ISDN is not set
 # CONFIG_PHONE is not set
 
-- 
1.6.2.4

