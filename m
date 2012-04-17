From: Tao Ma <tm@tao.ma>
Subject: [PATCH] SFC: Default to 'n' for Solarflare device.
Date: Tue, 17 Apr 2012 15:33:12 +0800
Message-ID: <1334647992-6022-1-git-send-email-tm@tao.ma>
Cc: linux-net-drivers@solarflare.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy8-pub.bluehost.com ([69.89.22.20]:33104 "HELO
	oproxy8-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751203Ab2DQHdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 03:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tao Ma <boyu.mt@taobao.com>

We make oldconfig every time when a new kernel arrives, but
if we don't have such a device(I guess this is the most common
case for a new device), the default value should be 'n' so
that the kernel size we build doesn't grow up too much quickly.
For anyone who has the device, it is OK for them to turn it on
by themselves. And it goes with these Solarflare devices.

Cc: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Tao Ma <boyu.mt@taobao.com>
---
 drivers/net/ethernet/sfc/Kconfig |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index fb3cbc2..bb643c4 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -14,7 +14,6 @@ config SFC
 config SFC_MTD
 	bool "Solarflare SFC4000/SFC9000-family MTD support"
 	depends on SFC && MTD && !(SFC=y && MTD=m)
-	default y
 	---help---
 	  This exposes the on-board flash and/or EEPROM as MTD devices
 	  (e.g. /dev/mtd1).  This is required to update the firmware or
@@ -22,14 +21,12 @@ config SFC_MTD
 config SFC_MCDI_MON
 	bool "Solarflare SFC9000-family hwmon support"
 	depends on SFC && HWMON && !(SFC=y && HWMON=m)
-	default y
 	----help---
 	  This exposes the on-board firmware-managed sensors as a
 	  hardware monitor device.
 config SFC_SRIOV
 	bool "Solarflare SFC9000-family SR-IOV support"
 	depends on SFC && PCI_IOV
-	default y
 	---help---
 	  This enables support for the SFC9000 I/O Virtualization
 	  features, allowing accelerated network performance in
-- 
1.7.6.1
