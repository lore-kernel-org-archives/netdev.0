From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 64/72] at1700: Move the Allied Telesis driver
Date: Sat, 25 Jun 2011 06:59:15 -0700
Message-ID: <1309010363-22750-65-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Donald Becker <becker@scyld.com>,
	Yutaka Tamiya <tamy@flab.fujitsu.co.jp>,
	Rene Schmit <rene@bss.lu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511Ab1FYOAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:37 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Allied Telesis driver into drivers/net/ethernet/ and
made the necessary Kconfig and Makefile changes.

CC: Donald Becker <becker@scyld.com>
CC: Yutaka Tamiya <tamy@flab.fujitsu.co.jp>
CC: Rene Schmit <rene@bss.lu>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                 |   12 ------------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |   13 +++++++++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/at1700.c |    0
 5 files changed, 14 insertions(+), 13 deletions(-)
 rename drivers/net/{ => ethernet}/at1700.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2af125b..5c3505b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -320,18 +320,6 @@ config DNET
 	  To compile this driver as a module, choose M here: the module
 	  will be called dnet.
 
-config AT1700
-	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called at1700.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 13e2499..8504458 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -49,7 +49,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
-obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index bb4b87f..c6d61a01 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -52,6 +52,19 @@ config ARIADNE
 	  will be called ariadne.
 
 source "drivers/net/ethernet/arm/Kconfig"
+
+config AT1700
+	tristate "AT1700/1720 support (EXPERIMENTAL)"
+	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called at1700.
+
 source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/atmel/Kconfig"
 source "drivers/net/ethernet/blackfin/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 37a5d1c..0ad9873 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
+obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_ARIADNE) += ariadne.o
diff --git a/drivers/net/at1700.c b/drivers/net/ethernet/at1700.c
similarity index 100%
rename from drivers/net/at1700.c
rename to drivers/net/ethernet/at1700.c
-- 
1.7.5.4

