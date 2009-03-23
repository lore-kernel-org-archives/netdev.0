From: Oskar Schirmer <os@emlix.com>
Subject: [patch 3/3] xtensa: enable s6gmac in s6105_defconfig
Date: Mon, 23 Mar 2009 15:13:20 +0100
Message-ID: <1237817600-29471-3-git-send-email-os@emlix.com>
References: <1237817600-29471-1-git-send-email-os@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	=?utf-8?q?Daniel=20Gl=C3=B6ckner?= <dg@emlix.com>
To: Jeff Garzik <jgarzik@pobox.com>, Chris Zankel <chris@zankel.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.emlix.com ([193.175.82.87]:54682 "EHLO mx1.emlix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755559AbZCWOMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 10:12:25 -0400
In-Reply-To: <1237817600-29471-1-git-send-email-os@emlix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Gl=C3=B6ckner <dg@emlix.com>

Signed-off-by: Daniel Gl=C3=B6ckner <dg@emlix.com>
---
 arch/xtensa/configs/s6105_defconfig |   49 +++++++++++++++++++++++++++=
+++++++-
 1 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/arch/xtensa/configs/s6105_defconfig b/arch/xtensa/configs/=
s6105_defconfig
index 6e1deff..a130c8d 100644
--- a/arch/xtensa/configs/s6105_defconfig
+++ b/arch/xtensa/configs/s6105_defconfig
@@ -264,7 +264,54 @@ CONFIG_HAVE_IDE=3Dy
 # CONFIG_SCSI_NETLINK is not set
 # CONFIG_ATA is not set
 # CONFIG_MD is not set
-# CONFIG_NETDEVICES is not set
+CONFIG_NETDEVICES=3Dy
+# CONFIG_DUMMY is not set
+# CONFIG_BONDING is not set
+# CONFIG_MACVLAN is not set
+# CONFIG_EQUALIZER is not set
+# CONFIG_TUN is not set
+# CONFIG_VETH is not set
+CONFIG_PHYLIB=3Dy
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
+CONFIG_SMSC_PHY=3Dy
+# CONFIG_BROADCOM_PHY is not set
+# CONFIG_ICPLUS_PHY is not set
+# CONFIG_REALTEK_PHY is not set
+# CONFIG_NATIONAL_PHY is not set
+# CONFIG_STE10XP is not set
+# CONFIG_LSI_ET1011C_PHY is not set
+# CONFIG_FIXED_PHY is not set
+# CONFIG_MDIO_BITBANG is not set
+# CONFIG_NET_ETHERNET is not set
+CONFIG_NETDEV_1000=3Dy
+CONFIG_S6GMAC=3Dy
+# CONFIG_NETDEV_10000 is not set
+
+#
+# Wireless LAN
+#
+# CONFIG_WLAN_PRE80211 is not set
+# CONFIG_WLAN_80211 is not set
+# CONFIG_IWLWIFI_LEDS is not set
+
+#
+# Enable WiMAX (Networking options) to see the WiMAX drivers
+#
+# CONFIG_WAN is not set
+# CONFIG_PPP is not set
+# CONFIG_SLIP is not set
+# CONFIG_NETCONSOLE is not set
+# CONFIG_NETPOLL is not set
+# CONFIG_NET_POLL_CONTROLLER is not set
 # CONFIG_ISDN is not set
 # CONFIG_PHONE is not set
=20
--=20
1.6.2.107.ge47ee

