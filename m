From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: [PATCH] Kill trailing whitespaces in drivers/net/Kconfig
Date: Sun, 27 May 2007 02:50:00 +0200
Message-ID: <20070527005000.GA19523@datenfreihafen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([62.75.240.18]:47810 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbXE0AuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 May 2007 20:50:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kill all trailing whitespaces in drivers/net/Kconfig.

Signed-off-by: Stefan Schmidt <stefan@datenfreihafen.org>
---
 drivers/net/Kconfig |   48 ++++++++++++++++++++++++------------------------
 1 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 30fd479..d8675f1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -883,12 +883,12 @@ config SMC911X
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
-	  Say Y if you want it compiled into the kernel, 
+	  Say Y if you want it compiled into the kernel,
 	  and read the Ethernet-HOWTO, available from
 	  <http://www.linuxdoc.org/docs.html#howto>.
 
-	  This driver is also available as a module. The module will be 
-	  called smc911x.  If you want to compile it as a module, say M 
+	  This driver is also available as a module. The module will be
+	  called smc911x.  If you want to compile it as a module, say M
 	  here and read <file:Documentation/kbuild/modules.txt>
 
 config NET_VENDOR_RACAL
@@ -1221,7 +1221,7 @@ config IBM_EMAC_RX_SKB_HEADROOM
 	  will always reserve at least 2 bytes to make IP header
 	  aligned, so usually there is no need to add any additional
 	  headroom.
-	  
+
 	  If unsure, set to 0.
 
 config IBM_EMAC_PHY_RX_CLK_FIX
@@ -1229,10 +1229,10 @@ config IBM_EMAC_PHY_RX_CLK_FIX
 	depends on IBM_EMAC && (405EP || 440GX || 440EP || 440GR)
 	help
 	  Enable this if EMAC attached to a PHY which doesn't generate
-	  RX clock if there is no link, if this is the case, you will 
+	  RX clock if there is no link, if this is the case, you will
 	  see "TX disable timeout" or "RX disable timeout" in the system
 	  log.
-	  
+
 	  If unsure, say N.
 
 config IBM_EMAC_DEBUG
@@ -1249,7 +1249,7 @@ config IBM_EMAC_RGMII
 	bool
 	depends on IBM_EMAC && 440GX
 	default y
-		
+
 config IBM_EMAC_TAH
 	bool
 	depends on IBM_EMAC && 440GX
@@ -1482,9 +1482,9 @@ config E100
 	select MII
 	---help---
 	  This driver supports Intel(R) PRO/100 family of adapters.
-	  To verify that your adapter is supported, find the board ID number 
-	  on the adapter. Look for a label that has a barcode and a number 
-	  in the format 123456-001 (six digits hyphen three digits). 
+	  To verify that your adapter is supported, find the board ID number
+	  on the adapter. Look for a label that has a barcode and a number
+	  in the format 123456-001 (six digits hyphen three digits).
 
 	  Use the above information and the Adapter & Driver ID Guide at:
 
@@ -1496,7 +1496,7 @@ config E100
 
 	  <http://appsr.intel.com/scripts-df/support_intel.asp>
 
-	  More specific information on configuring the driver is in 
+	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/e100.txt>.
 
 	  To compile this driver as a module, choose M here and read
@@ -1950,7 +1950,7 @@ config E1000
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-	  adapters.  For more information on how to identify your adapter, go 
+	  adapters.  For more information on how to identify your adapter, go
 	  to the Adapter & Driver ID Guide at:
 
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
@@ -1960,7 +1960,7 @@ config E1000
 
 	  <http://support.intel.com>
 
-	  More specific information on configuring the driver is in 
+	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/e1000.txt>.
 
 	  To compile this driver as a module, choose M here and read
@@ -2074,7 +2074,7 @@ config R8169_VLAN
 	---help---
 	  Say Y here for the r8169 driver to support the functions required
 	  by the kernel 802.1Q code.
-	  
+
 	  If in doubt, say Y.
 
 config SIS190
@@ -2100,7 +2100,7 @@ config SKGE
 	  and related Gigabit Ethernet adapters. It is a new smaller driver
 	  with better performance and more complete ethtool support.
 
-	  It does not support the link failover and network management 
+	  It does not support the link failover and network management
 	  features that "portable" vendor supplied sk98lin driver does.
 
 	  This driver supports adapters based on the original Yukon chipset:
@@ -2201,16 +2201,16 @@ config SK98LIN
 	    - SK-9871 V2.0 Gigabit Ethernet 1000Base-ZX Adapter
 	    - SK-9872 Gigabit Ethernet Server Adapter (SK-NET GE-ZX dual link)
 	    - SMC EZ Card 1000 (SMC9452TXV.2)
-	  
+
 	  The adapters support Jumbo Frames.
 	  The dual link adapters support link-failover and dual port features.
-	  Both Marvell Yukon and SysKonnect SK-98xx/SK-95xx adapters support 
-	  the scatter-gather functionality with sendfile(). Please refer to 
+	  Both Marvell Yukon and SysKonnect SK-98xx/SK-95xx adapters support
+	  the scatter-gather functionality with sendfile(). Please refer to
 	  <file:Documentation/networking/sk98lin.txt> for more information about
 	  optional driver parameters.
 	  Questions concerning this driver may be addressed to:
 	      <linux@syskonnect.de>
-	  
+
 	  If you want to compile this driver as a module ( = code which can be
 	  inserted in and removed from the running kernel whenever you want),
 	  say M here and read <file:Documentation/kbuild/modules.txt>. The module will
@@ -2421,7 +2421,7 @@ config IXGB
 
 	  <http://support.intel.com>
 
-	  More specific information on configuring the driver is in 
+	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/ixgb.txt>.
 
 	  To compile this driver as a module, choose M here and read
@@ -2449,8 +2449,8 @@ config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
 	---help---
-	  This driver supports the 10Gbe XFrame NIC of S2IO. 
-	  More specific information on configuring the driver is in 
+	  This driver supports the 10Gbe XFrame NIC of S2IO.
+	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/s2io.txt>.
 
 config S2IO_NAPI
@@ -2824,9 +2824,9 @@ config PPPOE
 	  Support for PPP over Ethernet.
 
 	  This driver requires the latest version of pppd from the CVS
-	  repository at cvs.samba.org.  Alternatively, see the 
+	  repository at cvs.samba.org.  Alternatively, see the
 	  RoaringPenguin package (<http://www.roaringpenguin.com/pppoe>)
-	  which contains instruction on how to use this driver (under 
+	  which contains instruction on how to use this driver (under
 	  the heading "Kernel mode PPPoE").
 
 config PPPOATM
-- 
1.5.1.4

