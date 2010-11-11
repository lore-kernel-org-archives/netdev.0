From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] net: Kconfig whitespace cleanup
Date: Thu, 11 Nov 2010 23:31:21 +0100
Message-ID: <1289514681-3940-1-git-send-email-phdm@macqel.be>
Cc: Philippe De Muyter <phdm@macqel.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:55039 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752464Ab0KKWcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 17:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

scripts/checkpatch.pl complained loudly about a patch candidate of mine.
Fixing it led me, amongst other problems, to the patch below

Philippe

---
Many lines in Kconfig start withe 8 spaces instead of a TAB, and even
sometimes with 7 spaces.  Replace 10 or 9 spaces, or TAB + 1 space,
by TAB + 2 spaces, and 8 or 7 spaces by TAB.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>
---
 drivers/net/Kconfig |  224 +++++++++++++++++++++++++-------------------------
 1 files changed, 112 insertions(+), 112 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f6668cd..805cf5d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1533,7 +1533,7 @@ config E100
 
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
 
-          to identify the adapter.
+	  to identify the adapter.
 
 	  For the latest Intel PRO/100 network driver for Linux, see:
 
@@ -1786,17 +1786,17 @@ config KS8842
 	tristate "Micrel KSZ8841/42 with generic bus interface"
 	depends on HAS_IOMEM && DMA_ENGINE
 	help
-	 This platform driver is for KSZ8841(1-port) / KS8842(2-port)
-	 ethernet switch chip (managed, VLAN, QoS) from Micrel or
-	 Timberdale(FPGA).
+	  This platform driver is for KSZ8841(1-port) / KS8842(2-port)
+	  ethernet switch chip (managed, VLAN, QoS) from Micrel or
+	  Timberdale(FPGA).
 
 config KS8851
-       tristate "Micrel KS8851 SPI"
-       depends on SPI
-       select MII
+	tristate "Micrel KS8851 SPI"
+	depends on SPI
+	select MII
 	select CRC32
-       help
-         SPI driver for Micrel KS8851 SPI attached network chip.
+	help
+	  SPI driver for Micrel KS8851 SPI attached network chip.
 
 config KS8851_MLL
 	tristate "Micrel KS8851 MLL"
@@ -2133,25 +2133,25 @@ config IP1000
 	  will be called ipg.  This is recommended.
 
 config IGB
-       tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
-       depends on PCI
-       ---help---
-         This driver supports Intel(R) 82575/82576 gigabit ethernet family of
-         adapters.  For more information on how to identify your adapter, go
-         to the Adapter & Driver ID Guide at:
+	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
+	depends on PCI
+	---help---
+	  This driver supports Intel(R) 82575/82576 gigabit ethernet family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
 
-         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
 
-         For general information and support, go to the Intel support
-         website at:
+	  For general information and support, go to the Intel support
+	  website at:
 
-         <http://support.intel.com>
+	  <http://support.intel.com>
 
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/e1000.txt>.
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e1000.txt>.
 
-         To compile this driver as a module, choose M here. The module
-         will be called igb.
+	  To compile this driver as a module, choose M here. The module
+	  will be called igb.
 
 config IGB_DCA
 	bool "Direct Cache Access (DCA) Support"
@@ -2163,25 +2163,25 @@ config IGB_DCA
 	  is used, with the intent of lessening the impact of cache misses.
 
 config IGBVF
-       tristate "Intel(R) 82576 Virtual Function Ethernet support"
-       depends on PCI
-       ---help---
-         This driver supports Intel(R) 82576 virtual functions.  For more
-         information on how to identify your adapter, go to the Adapter &
-         Driver ID Guide at:
+	tristate "Intel(R) 82576 Virtual Function Ethernet support"
+	depends on PCI
+	---help---
+	  This driver supports Intel(R) 82576 virtual functions.  For more
+	  information on how to identify your adapter, go to the Adapter &
+	  Driver ID Guide at:
 
-         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
 
-         For general information and support, go to the Intel support
-         website at:
+	  For general information and support, go to the Intel support
+	  website at:
 
-         <http://support.intel.com>
+	  <http://support.intel.com>
 
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/e1000.txt>.
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e1000.txt>.
 
-         To compile this driver as a module, choose M here. The module
-         will be called igbvf.
+	  To compile this driver as a module, choose M here. The module
+	  will be called igbvf.
 
 source "drivers/net/ixp2000/Kconfig"
 
@@ -2300,14 +2300,14 @@ config SKGE
 	  will be called skge.  This is recommended.
 
 config SKGE_DEBUG
-       bool "Debugging interface"
-       depends on SKGE && DEBUG_FS
-       help
-	 This option adds the ability to dump driver state for debugging.
-	 The file /sys/kernel/debug/skge/ethX displays the state of the internal
-	 transmit and receive rings.
+	bool "Debugging interface"
+	depends on SKGE && DEBUG_FS
+	help
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/skge/ethX displays the state of the internal
+	  transmit and receive rings.
 
-	 If unsure, say N.
+	  If unsure, say N.
 
 config SKY2
 	tristate "SysKonnect Yukon2 support"
@@ -2326,14 +2326,14 @@ config SKY2
 	  will be called sky2.  This is recommended.
 
 config SKY2_DEBUG
-       bool "Debugging interface"
-       depends on SKY2 && DEBUG_FS
-       help
-	 This option adds the ability to dump driver state for debugging.
-	 The file /sys/kernel/debug/sky2/ethX displays the state of the internal
-	 transmit and receive rings.
+	bool "Debugging interface"
+	depends on SKY2 && DEBUG_FS
+	help
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/sky2/ethX displays the state of the internal
+	  transmit and receive rings.
 
-	 If unsure, say N.
+	  If unsure, say N.
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
@@ -2573,32 +2573,32 @@ config MDIO
 	tristate
 
 config CHELSIO_T1
-        tristate "Chelsio 10Gb Ethernet support"
-        depends on PCI
+	tristate "Chelsio 10Gb Ethernet support"
+	depends on PCI
 	select CRC32
 	select MDIO
-        help
-          This driver supports Chelsio gigabit and 10-gigabit
-          Ethernet cards. More information about adapter features and
+	help
+	  This driver supports Chelsio gigabit and 10-gigabit
+	  Ethernet cards. More information about adapter features and
 	  performance tuning is in <file:Documentation/networking/cxgb.txt>.
 
-          For general information about Chelsio and our products, visit
-          our website at <http://www.chelsio.com>.
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
 
-          For customer support, please visit our customer support page at
-          <http://www.chelsio.com/support.html>.
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
 
-          Please send feedback to <linux-bugs@chelsio.com>.
+	  Please send feedback to <linux-bugs@chelsio.com>.
 
-          To compile this driver as a module, choose M here: the module
-          will be called cxgb.
+	  To compile this driver as a module, choose M here: the module
+	  will be called cxgb.
 
 config CHELSIO_T1_1G
-        bool "Chelsio gigabit Ethernet support"
-        depends on CHELSIO_T1
-        help
-          Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
-          are using only 10G cards say 'N' here.
+	bool "Chelsio gigabit Ethernet support"
+	depends on CHELSIO_T1
+	help
+	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
+	  are using only 10G cards say 'N' here.
 
 config CHELSIO_T3_DEPENDS
 	tristate
@@ -2728,26 +2728,26 @@ config IXGBE_DCB
 	  If unsure, say N.
 
 config IXGBEVF
-       tristate "Intel(R) 82599 Virtual Function Ethernet support"
-       depends on PCI_MSI
-       ---help---
-         This driver supports Intel(R) 82599 virtual functions.  For more
-         information on how to identify your adapter, go to the Adapter &
-         Driver ID Guide at:
+	tristate "Intel(R) 82599 Virtual Function Ethernet support"
+	depends on PCI_MSI
+	---help---
+	  This driver supports Intel(R) 82599 virtual functions.  For more
+	  information on how to identify your adapter, go to the Adapter &
+	  Driver ID Guide at:
 
-         <http://support.intel.com/support/network/sb/CS-008441.htm>
+	  <http://support.intel.com/support/network/sb/CS-008441.htm>
 
-         For general information and support, go to the Intel support
-         website at:
+	  For general information and support, go to the Intel support
+	  website at:
 
-         <http://support.intel.com>
+	  <http://support.intel.com>
 
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/ixgbevf.txt>.
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/ixgbevf.txt>.
 
-         To compile this driver as a module, choose M here. The module
-         will be called ixgbevf.  MSI-X interrupt support is required
-         for this driver to work correctly.
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgbevf.  MSI-X interrupt support is required
+	  for this driver to work correctly.
 
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
@@ -2906,18 +2906,18 @@ config QLGE
 	  will be called qlge.
 
 config BNA
-        tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
-        depends on PCI
-        ---help---
-          This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
-          cards.
-          To compile this driver as a module, choose M here: the module
-          will be called bna.
+	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+	depends on PCI
+	---help---
+	  This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
+	  cards.
+	  To compile this driver as a module, choose M here: the module
+	  will be called bna.
 
-          For general information and support, go to the Brocade support
-          website at:
+	  For general information and support, go to the Brocade support
+	  website at:
 
-          <http://support.brocade.com>
+	  <http://support.brocade.com>
 
 source "drivers/net/sfc/Kconfig"
 
@@ -3227,18 +3227,18 @@ config PPP_BSDCOMP
 	  modules once you have said "make modules". If unsure, say N.
 
 config PPP_MPPE
-       tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
-       depends on PPP && EXPERIMENTAL
-       select CRYPTO
-       select CRYPTO_SHA1
-       select CRYPTO_ARC4
-       select CRYPTO_ECB
-       ---help---
-         Support for the MPPE Encryption protocol, as employed by the
-	 Microsoft Point-to-Point Tunneling Protocol.
-
-	 See http://pptpclient.sourceforge.net/ for information on
-	 configuring PPTP clients and servers to utilize this method.
+	tristate "PPP MPPE compression (encryption) (EXPERIMENTAL)"
+	depends on PPP && EXPERIMENTAL
+	select CRYPTO
+	select CRYPTO_SHA1
+	select CRYPTO_ARC4
+	select CRYPTO_ECB
+	---help---
+	  Support for the MPPE Encryption protocol, as employed by the
+	  Microsoft Point-to-Point Tunneling Protocol.
+
+	  See http://pptpclient.sourceforge.net/ for information on
+	  configuring PPTP clients and servers to utilize this method.
 
 config PPPOE
 	tristate "PPP over Ethernet (EXPERIMENTAL)"
@@ -3397,14 +3397,14 @@ config VIRTIO_NET
 	depends on EXPERIMENTAL && VIRTIO
 	---help---
 	  This is the virtual network driver for virtio.  It can be used with
-          lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
+	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
 
 config VMXNET3
-       tristate "VMware VMXNET3 ethernet driver"
-       depends on PCI && INET
-       help
-         This driver supports VMware's vmxnet3 virtual ethernet NIC.
-         To compile this driver as a module, choose M here: the
-         module will be called vmxnet3.
+	tristate "VMware VMXNET3 ethernet driver"
+	depends on PCI && INET
+	help
+	  This driver supports VMware's vmxnet3 virtual ethernet NIC.
+	  To compile this driver as a module, choose M here: the
+	  module will be called vmxnet3.
 
 endif # NETDEVICES
-- 
1.7.1

