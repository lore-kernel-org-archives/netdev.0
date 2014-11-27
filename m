From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] netpoll: delete defconfig references to obsolete NETPOLL_TRAP
Date: Thu, 27 Nov 2014 10:28:16 -0500
Message-ID: <1417102096-16537-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64927 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaK0P2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 10:28:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 9c62a68d13119a1ca9718381d97b0cb415ff4e9d ("netpoll:
Remove dead packet receive code (CONFIG_NETPOLL_TRAP)") this
Kconfig option was removed.  So remove references to it from
all defconfigs as well.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 arch/arm/configs/davinci_all_defconfig         | 1 -
 arch/powerpc/configs/85xx/ge_imp3a_defconfig   | 1 -
 arch/powerpc/configs/86xx/gef_ppc9a_defconfig  | 1 -
 arch/powerpc/configs/86xx/gef_sbc310_defconfig | 1 -
 arch/powerpc/configs/86xx/gef_sbc610_defconfig | 1 -
 arch/powerpc/configs/86xx/sbc8641d_defconfig   | 1 -
 arch/powerpc/configs/c2k_defconfig             | 1 -
 arch/powerpc/configs/ppc64_defconfig           | 1 -
 arch/powerpc/configs/ppc64e_defconfig          | 1 -
 arch/powerpc/configs/ppc6xx_defconfig          | 1 -
 arch/powerpc/configs/pseries_defconfig         | 1 -
 arch/powerpc/configs/pseries_le_defconfig      | 1 -
 arch/tile/configs/tilegx_defconfig             | 1 -
 arch/tile/configs/tilepro_defconfig            | 1 -
 14 files changed, 14 deletions(-)

diff --git a/arch/arm/configs/davinci_all_defconfig b/arch/arm/configs/davinci_all_defconfig
index f95f72d62db7..759f9b0053e2 100644
--- a/arch/arm/configs/davinci_all_defconfig
+++ b/arch/arm/configs/davinci_all_defconfig
@@ -97,7 +97,6 @@ CONFIG_PPP_ASYNC=m
 CONFIG_PPP_SYNC_TTY=m
 CONFIG_PPP_DEFLATE=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 # CONFIG_INPUT_MOUSEDEV is not set
 CONFIG_INPUT_EVDEV=m
 CONFIG_INPUT_EVBUG=m
diff --git a/arch/powerpc/configs/85xx/ge_imp3a_defconfig b/arch/powerpc/configs/85xx/ge_imp3a_defconfig
index dc939de9b5b0..b4c4b469e320 100644
--- a/arch/powerpc/configs/85xx/ge_imp3a_defconfig
+++ b/arch/powerpc/configs/85xx/ge_imp3a_defconfig
@@ -100,7 +100,6 @@ CONFIG_NETDEVICES=y
 CONFIG_BONDING=m
 CONFIG_DUMMY=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=m
 # CONFIG_NET_VENDOR_3COM is not set
 CONFIG_FS_ENET=y
diff --git a/arch/powerpc/configs/86xx/gef_ppc9a_defconfig b/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
index e5a648115ada..7cb9719abf3d 100644
--- a/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
+++ b/arch/powerpc/configs/86xx/gef_ppc9a_defconfig
@@ -113,7 +113,6 @@ CONFIG_SLIP_COMPRESSED=y
 CONFIG_SLIP_SMART=y
 CONFIG_SLIP_MODE_SLIP6=y
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
 # CONFIG_SERIO is not set
diff --git a/arch/powerpc/configs/86xx/gef_sbc310_defconfig b/arch/powerpc/configs/86xx/gef_sbc310_defconfig
index 8317b6010ba6..ecabf625d249 100644
--- a/arch/powerpc/configs/86xx/gef_sbc310_defconfig
+++ b/arch/powerpc/configs/86xx/gef_sbc310_defconfig
@@ -114,7 +114,6 @@ CONFIG_SLIP_COMPRESSED=y
 CONFIG_SLIP_SMART=y
 CONFIG_SLIP_MODE_SLIP6=y
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
 # CONFIG_SERIO is not set
diff --git a/arch/powerpc/configs/86xx/gef_sbc610_defconfig b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
index 124d66f0282c..4a4a86fb0d3d 100644
--- a/arch/powerpc/configs/86xx/gef_sbc610_defconfig
+++ b/arch/powerpc/configs/86xx/gef_sbc610_defconfig
@@ -165,7 +165,6 @@ CONFIG_SLIP_COMPRESSED=y
 CONFIG_SLIP_SMART=y
 CONFIG_SLIP_MODE_SLIP6=y
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_INPUT_FF_MEMLESS=m
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
diff --git a/arch/powerpc/configs/86xx/sbc8641d_defconfig b/arch/powerpc/configs/86xx/sbc8641d_defconfig
index 1e151594c691..99ea8746bbaf 100644
--- a/arch/powerpc/configs/86xx/sbc8641d_defconfig
+++ b/arch/powerpc/configs/86xx/sbc8641d_defconfig
@@ -167,7 +167,6 @@ CONFIG_SLIP_COMPRESSED=y
 CONFIG_SLIP_SMART=y
 CONFIG_SLIP_MODE_SLIP6=y
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 # CONFIG_INPUT_KEYBOARD is not set
 # CONFIG_INPUT_MOUSE is not set
 # CONFIG_SERIO is not set
diff --git a/arch/powerpc/configs/c2k_defconfig b/arch/powerpc/configs/c2k_defconfig
index 59734916986a..8a08d6dcb0b4 100644
--- a/arch/powerpc/configs/c2k_defconfig
+++ b/arch/powerpc/configs/c2k_defconfig
@@ -211,7 +211,6 @@ CONFIG_MV643XX_ETH=y
 # CONFIG_NETDEV_10000 is not set
 # CONFIG_ATM_DRIVERS is not set
 CONFIG_NETCONSOLE=m
-CONFIG_NETPOLL_TRAP=y
 # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
 CONFIG_INPUT_EVDEV=y
 # CONFIG_INPUT_KEYBOARD is not set
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index 20bc5e2d368d..5830d735c5c3 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -154,7 +154,6 @@ CONFIG_WINDFARM_PM121=y
 CONFIG_BONDING=m
 CONFIG_DUMMY=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=m
 CONFIG_VIRTIO_NET=m
 CONFIG_VHOST_NET=m
diff --git a/arch/powerpc/configs/ppc64e_defconfig b/arch/powerpc/configs/ppc64e_defconfig
index c3a3269b0865..67885b2d70aa 100644
--- a/arch/powerpc/configs/ppc64e_defconfig
+++ b/arch/powerpc/configs/ppc64e_defconfig
@@ -103,7 +103,6 @@ CONFIG_NETDEVICES=y
 CONFIG_BONDING=m
 CONFIG_DUMMY=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=m
 CONFIG_VORTEX=y
 CONFIG_ACENIC=y
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index fec5870f1818..ad6d6b5af7d7 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -629,7 +629,6 @@ CONFIG_SLIP_SMART=y
 CONFIG_NET_FC=y
 CONFIG_NETCONSOLE=m
 CONFIG_NETCONSOLE_DYNAMIC=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_VIRTIO_NET=m
 # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
 CONFIG_INPUT_JOYDEV=m
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index dd2a9cab4b50..1f97364017c7 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -133,7 +133,6 @@ CONFIG_DM_UEVENT=y
 CONFIG_BONDING=m
 CONFIG_DUMMY=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=m
 CONFIG_VIRTIO_NET=m
 CONFIG_VHOST_NET=m
diff --git a/arch/powerpc/configs/pseries_le_defconfig b/arch/powerpc/configs/pseries_le_defconfig
index d2008887eb8c..ac7ca5852827 100644
--- a/arch/powerpc/configs/pseries_le_defconfig
+++ b/arch/powerpc/configs/pseries_le_defconfig
@@ -134,7 +134,6 @@ CONFIG_DM_UEVENT=y
 CONFIG_BONDING=m
 CONFIG_DUMMY=m
 CONFIG_NETCONSOLE=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=m
 CONFIG_VIRTIO_NET=m
 CONFIG_VHOST_NET=m
diff --git a/arch/tile/configs/tilegx_defconfig b/arch/tile/configs/tilegx_defconfig
index 91de7dd7427f..37dc9364c4a1 100644
--- a/arch/tile/configs/tilegx_defconfig
+++ b/arch/tile/configs/tilegx_defconfig
@@ -218,7 +218,6 @@ CONFIG_MACVLAN=m
 CONFIG_MACVTAP=m
 CONFIG_NETCONSOLE=m
 CONFIG_NETCONSOLE_DYNAMIC=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=y
 CONFIG_VETH=m
 CONFIG_NET_DSA_MV88E6060=y
diff --git a/arch/tile/configs/tilepro_defconfig b/arch/tile/configs/tilepro_defconfig
index c7702b7ab7a5..76a2781dec2c 100644
--- a/arch/tile/configs/tilepro_defconfig
+++ b/arch/tile/configs/tilepro_defconfig
@@ -337,7 +337,6 @@ CONFIG_MACVLAN=m
 CONFIG_MACVTAP=m
 CONFIG_NETCONSOLE=m
 CONFIG_NETCONSOLE_DYNAMIC=y
-CONFIG_NETPOLL_TRAP=y
 CONFIG_TUN=y
 CONFIG_VETH=m
 CONFIG_NET_DSA_MV88E6060=y
-- 
1.9.2
