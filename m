From: "Stanley.Miao" <stanley.miao@windriver.com>
Subject: [PATCH 8/8] arm: update omap_ldp defconfig to use smsc911x
Date: Wed, 21 Jan 2009 11:06:10 +0800
Message-ID: <1232507170-18401-2-git-send-email-stanley.miao@windriver.com>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
 <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Cc: linux@arm.linux.org.uk, davem@davemloft.net,
	netdev@vger.kernel.org, steve.glendinning@smsc.com
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58164 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbZAUC5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 21:57:37 -0500
In-Reply-To: <1232507170-18401-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
---
 arch/arm/configs/omap_ldp_defconfig |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/arch/arm/configs/omap_ldp_defconfig b/arch/arm/configs/omap_ldp_defconfig
index d88e6d7..64db3b1 100644
--- a/arch/arm/configs/omap_ldp_defconfig
+++ b/arch/arm/configs/omap_ldp_defconfig
@@ -489,14 +489,34 @@ CONFIG_NETDEVICES=y
 # CONFIG_EQUALIZER is not set
 # CONFIG_TUN is not set
 # CONFIG_VETH is not set
-# CONFIG_PHYLIB is not set
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
+CONFIG_SMSC_PHY=y
+# CONFIG_BROADCOM_PHY is not set
+# CONFIG_ICPLUS_PHY is not set
+# CONFIG_REALTEK_PHY is not set
+# CONFIG_NATIONAL_PHY is not set
+# CONFIG_STE10XP is not set
+# CONFIG_LSI_ET1011C_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
 # CONFIG_AX88796 is not set
 # CONFIG_SMC91X is not set
 # CONFIG_DM9000 is not set
 # CONFIG_ENC28J60 is not set
-CONFIG_SMC911X=y
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
-- 
1.5.6.3

