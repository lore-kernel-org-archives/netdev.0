From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] net: Remove bogus dependencies on INET
Date: Fri, 16 Nov 2012 22:47:39 +0000
Message-ID: <1353106059.2743.56.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23236 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753465Ab2KPWrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 17:47:42 -0500
In-Reply-To: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various drivers depend on INET because they used to select INET_LRO,
but they have all been converted to use GRO which has no such
dependency.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Compile-tested with INET disabled.

Ben.

 drivers/net/ethernet/chelsio/Kconfig      |    4 ++--
 drivers/net/ethernet/cisco/Kconfig        |    2 +-
 drivers/net/ethernet/cisco/enic/Kconfig   |    2 +-
 drivers/net/ethernet/emulex/Kconfig       |    2 +-
 drivers/net/ethernet/emulex/benet/Kconfig |    2 +-
 drivers/net/ethernet/intel/Kconfig        |    2 +-
 drivers/net/ethernet/mellanox/Kconfig     |    2 +-
 drivers/net/ethernet/neterion/Kconfig     |    2 +-
 drivers/net/ethernet/sfc/Kconfig          |    2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 2de50f9..a71c0f3 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_CHELSIO
 	bool "Chelsio devices"
 	default y
-	depends on PCI || INET
+	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -48,7 +48,7 @@ config CHELSIO_T1_1G
 
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI && INET
+	depends on PCI
 	select FW_LOADER
 	select MDIO
 	---help---
diff --git a/drivers/net/ethernet/cisco/Kconfig b/drivers/net/ethernet/cisco/Kconfig
index 94606f7..1c7b884 100644
--- a/drivers/net/ethernet/cisco/Kconfig
+++ b/drivers/net/ethernet/cisco/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_CISCO
 	bool "Cisco devices"
 	default y
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/cisco/enic/Kconfig b/drivers/net/ethernet/cisco/enic/Kconfig
index 9cc706a..b63f8d8 100644
--- a/drivers/net/ethernet/cisco/enic/Kconfig
+++ b/drivers/net/ethernet/cisco/enic/Kconfig
@@ -4,6 +4,6 @@
 
 config ENIC
 	tristate "Cisco VIC Ethernet NIC Support"
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  This enables the support for the Cisco VIC Ethernet card.
diff --git a/drivers/net/ethernet/emulex/Kconfig b/drivers/net/ethernet/emulex/Kconfig
index 7a28a64..1b8d638 100644
--- a/drivers/net/ethernet/emulex/Kconfig
+++ b/drivers/net/ethernet/emulex/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_EMULEX
 	bool "Emulex devices"
 	default y
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/emulex/benet/Kconfig b/drivers/net/ethernet/emulex/benet/Kconfig
index 804db04..231129d 100644
--- a/drivers/net/ethernet/emulex/benet/Kconfig
+++ b/drivers/net/ethernet/emulex/benet/Kconfig
@@ -1,6 +1,6 @@
 config BE2NET
 	tristate "ServerEngines' 10Gbps NIC - BladeEngine"
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  This driver implements the NIC functionality for ServerEngines'
 	  10Gbps network adapter - BladeEngine.
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 73d28d5..ddee406 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -166,7 +166,7 @@ config IXGB
 
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
-	depends on PCI && INET
+	depends on PCI
 	select MDIO
 	select PTP_1588_CLOCK
 	---help---
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
index d8099a7..bcdbc14 100644
--- a/drivers/net/ethernet/mellanox/Kconfig
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_MELLANOX
 	bool "Mellanox devices"
 	default y
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/neterion/Kconfig b/drivers/net/ethernet/neterion/Kconfig
index ff26b54..87abb4f 100644
--- a/drivers/net/ethernet/neterion/Kconfig
+++ b/drivers/net/ethernet/neterion/Kconfig
@@ -32,7 +32,7 @@ config S2IO
 
 config VXGE
 	tristate "Exar X3100 Series 10GbE PCIe Server Adapter"
-	depends on PCI && INET
+	depends on PCI
 	---help---
 	  This driver supports Exar Corp's X3100 Series 10 GbE PCIe
 	  I/O Virtualized Server Adapter.
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index fb3cbc2..059e5e9 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -1,6 +1,6 @@
 config SFC
 	tristate "Solarflare SFC4000/SFC9000-family support"
-	depends on PCI && INET
+	depends on PCI
 	select MDIO
 	select CRC32
 	select I2C
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
