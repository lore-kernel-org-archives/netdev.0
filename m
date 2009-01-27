From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 08/10] arm: update pcm037 defconfig to use smsc911x
Date: Tue, 27 Jan 2009 16:51:16 +0000
Message-ID: <1233075077-17205-9-git-send-email-steve.glendinning@smsc.com>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-2-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-3-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-4-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-5-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-6-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-7-git-send-email-steve.glendinning@smsc.com>
 <1233075077-17205-8-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.114] ([86.54.240.114]:53200 "EHLO
	kensington.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756164AbZA0Qv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 11:51:27 -0500
In-Reply-To: <1233075077-17205-8-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
Acked-by: Sascha Hauer <s.hauer@pengutronix.de>
Tested-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 arch/arm/configs/pcm037_defconfig |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/arch/arm/configs/pcm037_defconfig b/arch/arm/configs/pcm037_defconfig
index 6274745..6e37c77 100644
--- a/arch/arm/configs/pcm037_defconfig
+++ b/arch/arm/configs/pcm037_defconfig
@@ -465,12 +465,33 @@ CONFIG_NETDEVICES=y
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
 CONFIG_SMC91X=y
 # CONFIG_DM9000 is not set
+# CONFIG_SMC911X is not set
+CONFIG_SMSC911X=y
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
 # CONFIG_IBM_NEW_EMAC_TAH is not set
-- 
1.6.0.6

