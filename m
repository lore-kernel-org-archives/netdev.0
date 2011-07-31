From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 52/71] korina: Move the IDT driver
Date: Sat, 30 Jul 2011 20:27:11 -0700
Message-ID: <1312082850-24914-53-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	"IDT Inc." <rischelp@idt.com>, Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63626 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752929Ab1GaD23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:29 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IDT driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes

CC: "IDT Inc." <rischelp@idt.com>
CC: Felix Fietkau <nbd@openwrt.org>
CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                 |    7 -------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |    7 +++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/korina.c |    0
 5 files changed, 8 insertions(+), 8 deletions(-)
 rename drivers/net/{ => ethernet}/korina.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d33d965..7022efd 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,13 +237,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config KORINA
-	tristate "Korina (IDT RC32434) Ethernet support"
-	depends on NET_ETHERNET && MIKROTIK_RB532
-	help
-	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
-	  based system say Y. Otherwise say N.
-
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device"
 	depends on MIPS_SIM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 2fb039b..6c17cb6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_EQUALIZER) += eql.o
-obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 72d0f5e..dae10a3 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -45,6 +45,13 @@ config JME
 	  To compile this driver as a module, choose M here. The module
 	  will be called jme.
 
+config KORINA
+	tristate "Korina (IDT RC32434) Ethernet support"
+	depends on MIKROTIK_RB532
+	---help---
+	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
+	  based system say Y. Otherwise say N.
+
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a8d8913..ddf097d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -25,6 +25,7 @@ obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_IP1000) += icplus/
 obj-$(CONFIG_JME) += jme.o
+obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
diff --git a/drivers/net/korina.c b/drivers/net/ethernet/korina.c
similarity index 100%
rename from drivers/net/korina.c
rename to drivers/net/ethernet/korina.c
-- 
1.7.6

