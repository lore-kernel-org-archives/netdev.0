From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] NET_SB1250_MAC: Rename to SB1250_MAC
Date: Fri, 14 Sep 2007 12:05:00 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709141158010.1926@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759189AbXINLF3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Rename NET_SB1250_MAC to SB1250_MAC to follow the convention.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 The NET prefix seems to be used mainly for device groups (NET_ISA, 
NET_VENDOR_*, etc.) rather than single drivers and adds no information.  I 
suggest it to be removed.

 Depends on "patch-netdev-2.6.23-rc6-20070913-sb1250-mac-kconfig-0".

 Please consider,

  Maciej

patch-netdev-2.6.23-rc6-20070913-sb1250-mac-config-0
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/arch/mips/configs/bigsur_defconfig linux-netdev-2.6.23-rc6-20070913/arch/mips/configs/bigsur_defconfig
--- linux-netdev-2.6.23-rc6-20070913.macro/arch/mips/configs/bigsur_defconfig	2007-09-04 04:55:19.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/arch/mips/configs/bigsur_defconfig	2007-09-14 00:22:18.000000000 +0000
@@ -574,7 +574,7 @@ CONFIG_MII=y
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
-CONFIG_NET_SB1250_MAC=y
+CONFIG_SB1250_MAC=y
 # CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SKY2 is not set
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/arch/mips/configs/sb1250-swarm_defconfig linux-netdev-2.6.23-rc6-20070913/arch/mips/configs/sb1250-swarm_defconfig
--- linux-netdev-2.6.23-rc6-20070913.macro/arch/mips/configs/sb1250-swarm_defconfig	2007-09-04 04:55:19.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/arch/mips/configs/sb1250-swarm_defconfig	2007-09-14 00:22:29.000000000 +0000
@@ -566,7 +566,7 @@ CONFIG_MII=y
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
 # CONFIG_R8169 is not set
-CONFIG_NET_SB1250_MAC=y
+CONFIG_SB1250_MAC=y
 # CONFIG_SIS190 is not set
 # CONFIG_SKGE is not set
 # CONFIG_SKY2 is not set
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Kconfig linux-netdev-2.6.23-rc6-20070913/drivers/net/Kconfig
--- linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Kconfig	2007-09-14 00:02:05.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/drivers/net/Kconfig	2007-09-14 00:21:06.000000000 +0000
@@ -2153,7 +2153,7 @@ config R8169_VLAN
 	  
 	  If in doubt, say Y.
 
-config NET_SB1250_MAC
+config SB1250_MAC
 	tristate "SB1250 Gigabit Ethernet support"
 	depends on SIBYTE_SB1xxx_SOC
 	---help---
diff -up --recursive --new-file linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Makefile linux-netdev-2.6.23-rc6-20070913/drivers/net/Makefile
--- linux-netdev-2.6.23-rc6-20070913.macro/drivers/net/Makefile	2007-09-13 17:27:52.000000000 +0000
+++ linux-netdev-2.6.23-rc6-20070913/drivers/net/Makefile	2007-09-14 00:21:20.000000000 +0000
@@ -107,7 +107,7 @@ obj-$(CONFIG_E2100) += e2100.o 8390.o
 obj-$(CONFIG_ES3210) += es3210.o 8390.o
 obj-$(CONFIG_LNE390) += lne390.o 8390.o
 obj-$(CONFIG_NE3210) += ne3210.o 8390.o
-obj-$(CONFIG_NET_SB1250_MAC) += sb1250-mac.o
+obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_NE_H8300) += ne-h8300.o
