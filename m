From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 07/72] intel: Move the Intel wired LAN drivers
Date: Sat, 25 Jun 2011 06:58:18 -0700
Message-ID: <1309010363-22750-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45980 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605Ab1FYN7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:36 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Intel wired LAN drivers into drivers/net/ethernet/intel/ and
the necessary Kconfig and Makefile changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |   11 +-
 drivers/net/Kconfig                                |  200 ------------------
 drivers/net/Makefile                               |    8 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/intel/Kconfig                 |  216 ++++++++++++++++++++
 drivers/net/ethernet/intel/Makefile                |   12 +
 drivers/net/{ => ethernet/intel}/e100.c            |    0
 drivers/net/{ => ethernet/intel}/e1000/Makefile    |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000.h     |    0
 .../net/{ => ethernet/intel}/e1000/e1000_ethtool.c |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000_hw.c  |    0
 drivers/net/{ => ethernet/intel}/e1000/e1000_hw.h  |    0
 .../net/{ => ethernet/intel}/e1000/e1000_main.c    |    0
 .../net/{ => ethernet/intel}/e1000/e1000_osdep.h   |    0
 .../net/{ => ethernet/intel}/e1000/e1000_param.c   |    0
 .../intel/e1000e/80003es2lan.c}                    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/82571.c    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/Makefile   |    4 +-
 drivers/net/{ => ethernet/intel}/e1000e/defines.h  |    0
 .../e1000.h => ethernet/intel/e1000e/e1000e.h}     |    0
 .../intel/e1000e/e1000e_main.c}                    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/ethtool.c  |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/hw.h       |    0
 drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c  |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/lib.c      |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/param.c    |    2 +-
 drivers/net/{ => ethernet/intel}/e1000e/phy.c      |    2 +-
 drivers/net/{ => ethernet/intel}/igb/Makefile      |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_82575.c |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_82575.h |    0
 .../net/{ => ethernet/intel}/igb/e1000_defines.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_hw.h    |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mac.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mac.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mbx.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_mbx.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_nvm.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_nvm.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_phy.c   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_phy.h   |    0
 drivers/net/{ => ethernet/intel}/igb/e1000_regs.h  |    0
 drivers/net/{ => ethernet/intel}/igb/igb.h         |    0
 drivers/net/{ => ethernet/intel}/igb/igb_ethtool.c |    0
 drivers/net/{ => ethernet/intel}/igb/igb_main.c    |    0
 drivers/net/{ => ethernet/intel}/igbvf/Makefile    |    0
 drivers/net/{ => ethernet/intel}/igbvf/defines.h   |    0
 drivers/net/{ => ethernet/intel}/igbvf/ethtool.c   |    0
 drivers/net/{ => ethernet/intel}/igbvf/igbvf.h     |    0
 drivers/net/{ => ethernet/intel}/igbvf/mbx.c       |    0
 drivers/net/{ => ethernet/intel}/igbvf/mbx.h       |    0
 drivers/net/{ => ethernet/intel}/igbvf/netdev.c    |    0
 drivers/net/{ => ethernet/intel}/igbvf/regs.h      |    0
 drivers/net/{ => ethernet/intel}/igbvf/vf.c        |    0
 drivers/net/{ => ethernet/intel}/igbvf/vf.h        |    0
 drivers/net/{ => ethernet/intel}/ixgb/Makefile     |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb.h       |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.c    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.h    |    0
 .../net/{ => ethernet/intel}/ixgb/ixgb_ethtool.c   |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.c    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.h    |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_ids.h   |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_main.c  |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_osdep.h |    0
 drivers/net/{ => ethernet/intel}/ixgb/ixgb_param.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/Makefile    |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe.h     |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_82598.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_82599.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_common.c  |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_common.h  |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.h |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.c   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.h   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.c   |    0
 .../{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.h   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_nl.c  |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_ethtool.c |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.c    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.h    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_main.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.h |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.c |    0
 drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.h |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.c   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.h   |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_type.h    |    0
 .../net/{ => ethernet/intel}/ixgbe/ixgbe_x540.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/Makefile  |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/defines.h |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/ethtool.c |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf.h |    0
 .../{ => ethernet/intel}/ixgbevf/ixgbevf_main.c    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/mbx.c     |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/mbx.h     |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/regs.h    |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/vf.c      |    0
 drivers/net/{ => ethernet/intel}/ixgbevf/vf.h      |    0
 101 files changed, 242 insertions(+), 227 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/Kconfig
 create mode 100644 drivers/net/ethernet/intel/Makefile
 rename drivers/net/{ => ethernet/intel}/e100.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_hw.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_osdep.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000/e1000_param.c (100%)
 rename drivers/net/{e1000e/es2lan.c => ethernet/intel/e1000e/80003es2lan.c} (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/82571.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/Makefile (92%)
 rename drivers/net/{ => ethernet/intel}/e1000e/defines.h (100%)
 rename drivers/net/{e1000e/e1000.h => ethernet/intel/e1000e/e1000e.h} (100%)
 rename drivers/net/{e1000e/netdev.c => ethernet/intel/e1000e/e1000e_main.c} (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ethtool.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/e1000e/ich8lan.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/lib.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/param.c (99%)
 rename drivers/net/{ => ethernet/intel}/e1000e/phy.c (99%)
 rename drivers/net/{ => ethernet/intel}/igb/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_82575.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_82575.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mac.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mac.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_nvm.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_nvm.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_phy.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_phy.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/e1000_regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb.h (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/igb/igb_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/igbvf.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/netdev.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/vf.c (100%)
 rename drivers/net/{ => ethernet/intel}/igbvf/vf.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ee.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_hw.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_ids.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_osdep.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgb/ixgb_param.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_82598.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_82599.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_common.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_common.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82598.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_82599.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_dcb_nl.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_fcoe.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_phy.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_sriov.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_type.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbe/ixgbe_x540.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/Makefile (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/defines.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ethtool.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/ixgbevf_main.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/mbx.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/mbx.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/regs.h (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/vf.c (100%)
 rename drivers/net/{ => ethernet/intel}/ixgbevf/vf.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 816bab8..ed7cce6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3308,7 +3308,7 @@ M:	Bruce Allan <bruce.w.allan@intel.com>
 M:	Carolyn Wyborny <carolyn.wyborny@intel.com>
 M:	Don Skidmore <donald.c.skidmore@intel.com>
 M:	Greg Rose <gregory.v.rose@intel.com>
-M:	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
+M:	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
 M:	Alex Duyck <alexander.h.duyck@intel.com>
 M:	John Ronciak <john.ronciak@intel.com>
 L:	e1000-devel@lists.sourceforge.net
@@ -3324,14 +3324,7 @@ F:	Documentation/networking/igbvf.txt
 F:	Documentation/networking/ixgb.txt
 F:	Documentation/networking/ixgbe.txt
 F:	Documentation/networking/ixgbevf.txt
-F:	drivers/net/e100.c
-F:	drivers/net/e1000/
-F:	drivers/net/e1000e/
-F:	drivers/net/igb/
-F:	drivers/net/igbvf/
-F:	drivers/net/ixgb/
-F:	drivers/net/ixgbe/
-F:	drivers/net/ixgbevf/
+F:	drivers/net/ethernet/intel/
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
 L:	linux-wireless@vger.kernel.org
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3e1b8bc..5bb247f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1029,32 +1029,6 @@ config TC35815
 	depends on NET_PCI && PCI && MIPS
 	select PHYLIB
 
-config E100
-	tristate "Intel(R) PRO/100+ support"
-	depends on NET_PCI && PCI
-	select MII
-	---help---
-	  This driver supports Intel(R) PRO/100 family of adapters.
-	  To verify that your adapter is supported, find the board ID number 
-	  on the adapter. Look for a label that has a barcode and a number 
-	  in the format 123456-001 (six digits hyphen three digits). 
-
-	  Use the above information and the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  to identify the adapter.
-
-	  For the latest Intel PRO/100 network driver for Linux, see:
-
-	  <http://www.intel.com/p/en_US/support/highlights/network/pro100plus>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/e100.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e100.
-
 config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on NET_PCI && PCI
@@ -1494,47 +1468,6 @@ config DL2K
 	  To compile this driver as a module, choose M here: the
 	  module will be called dl2k.
 
-config E1000
-	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-	  adapters.  For more information on how to identify your adapter, go 
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/e1000.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e1000.
-
-config E1000E
-	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
-	depends on PCI && (!SPARC32 || BROKEN)
-	select CRC32
-	---help---
-	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
-	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
-	  use the regular e1000 driver For more information on how to
-	  identify your adapter, go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e1000e.
-
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
@@ -1545,57 +1478,6 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
-config IGB
-	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) 82575/82576 gigabit ethernet family of
-	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/e1000.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called igb.
-
-config IGB_DCA
-	bool "Direct Cache Access (DCA) Support"
-	default y
-	depends on IGB && DCA && !(IGB=y && DCA=m)
-	---help---
-	  Say Y here if you want to use Direct Cache Access (DCA) in the
-	  driver.  DCA is a method for warming the CPU cache before data
-	  is used, with the intent of lessening the impact of cache misses.
-
-config IGBVF
-	tristate "Intel(R) 82576 Virtual Function Ethernet support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) 82576 virtual functions.  For more
-	  information on how to identify your adapter, go to the Adapter &
-	  Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/e1000.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called igbvf.
-
 source "drivers/net/ixp2000/Kconfig"
 
 config NS83820
@@ -1953,88 +1835,6 @@ config ENIC
 	help
 	  This enables the support for the Cisco VIC Ethernet card.
 
-config IXGBE
-	tristate "Intel(R) 10GbE PCI Express adapters support"
-	depends on PCI && INET
-	select MDIO
-	---help---
-	  This driver supports Intel(R) 10GbE PCI Express family of
-	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ixgbe.
-
-config IXGBE_DCA
-	bool "Direct Cache Access (DCA) Support"
-	default y
-	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
-	---help---
-	  Say Y here if you want to use Direct Cache Access (DCA) in the
-	  driver.  DCA is a method for warming the CPU cache before data
-	  is used, with the intent of lessening the impact of cache misses.
-
-config IXGBE_DCB
-	bool "Data Center Bridging (DCB) Support"
-	default n
-	depends on IXGBE && DCB
-	---help---
-	  Say Y here if you want to use Data Center Bridging (DCB) in the
-	  driver.
-
-	  If unsure, say N.
-
-config IXGBEVF
-	tristate "Intel(R) 82599 Virtual Function Ethernet support"
-	depends on PCI_MSI
-	---help---
-	  This driver supports Intel(R) 82599 virtual functions.  For more
-	  information on how to identify your adapter, go to the Adapter &
-	  Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/sb/CS-008441.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/ixgbevf.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ixgbevf.  MSI-X interrupt support is required
-	  for this driver to work correctly.
-
-config IXGB
-	tristate "Intel(R) PRO/10GbE support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) PRO/10GbE family of adapters for
-	  PCI-X type cards. For PCI-E type cards, use the "ixgbe" driver
-	  instead. For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/ixgb.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ixgb.
-
 config S2IO
 	tristate "Exar Xframe 10Gb Ethernet Adapter"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 395878f..b2e5b93 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -10,14 +10,7 @@ obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 
-obj-$(CONFIG_E1000) += e1000/
-obj-$(CONFIG_E1000E) += e1000e/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
-obj-$(CONFIG_IGB) += igb/
-obj-$(CONFIG_IGBVF) += igbvf/
-obj-$(CONFIG_IXGBE) += ixgbe/
-obj-$(CONFIG_IXGBEVF) += ixgbevf/
-obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
@@ -61,7 +54,6 @@ obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
-obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
 obj-$(CONFIG_SMSC9420) += smsc9420.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 69d6403..a2fd385 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -16,5 +16,6 @@ source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
+source "drivers/net/ethernet/intel/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 470e5d8..5265271 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,3 +7,4 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
+obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
new file mode 100644
index 0000000..83089e4
--- /dev/null
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -0,0 +1,216 @@
+#
+# Intel network device configuration
+#
+
+config NET_VENDOR_INTEL
+	bool "Intel devices"
+	depends on PCI || PCI_MSI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Intel cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config E100
+	tristate "Intel(R) PRO/100+ support"
+	depends on NET_VENDOR_INTEL && PCI
+	select MII
+	---help---
+	  This driver supports Intel(R) PRO/100 family of adapters.
+	  To verify that your adapter is supported, find the board ID number
+	  on the adapter. Look for a label that has a barcode and a number
+	  in the format 123456-001 (six digits hyphen three digits).
+
+	  Use the above information and the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  to identify the adapter.
+
+	  For the latest Intel PRO/100 network driver for Linux, see:
+
+	  <http://www.intel.com/p/en_US/support/highlights/network/pro100plus>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e100.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e100.
+
+config E1000
+	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
+	depends on NET_VENDOR_INTEL && PCI
+	---help---
+	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e1000.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e1000.
+
+config E1000E
+	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
+	depends on NET_VENDOR_INTEL && PCI && (!SPARC32 || BROKEN)
+	select CRC32
+	---help---
+	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
+	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
+	  use the regular e1000 driver For more information on how to
+	  identify your adapter, go to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e1000e.
+
+config IGB
+	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
+	depends on NET_VENDOR_INTEL && PCI
+	---help---
+	  This driver supports Intel(R) 82575/82576 gigabit ethernet family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e1000.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called igb.
+
+config IGB_DCA
+	bool "Direct Cache Access (DCA) Support"
+	default y
+	depends on IGB && DCA && !(IGB=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
+
+config IGBVF
+	tristate "Intel(R) 82576 Virtual Function Ethernet support"
+	depends on NET_VENDOR_INTEL && PCI
+	---help---
+	  This driver supports Intel(R) 82576 virtual functions.  For more
+	  information on how to identify your adapter, go to the Adapter &
+	  Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/e1000.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called igbvf.
+
+config IXGB
+	tristate "Intel(R) PRO/10GbE support"
+	depends on NET_VENDOR_INTEL && PCI
+	---help---
+	  This driver supports Intel(R) PRO/10GbE family of adapters for
+	  PCI-X type cards. For PCI-E type cards, use the "ixgbe" driver
+	  instead. For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/ixgb.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgb.
+
+config IXGBE
+	tristate "Intel(R) 10GbE PCI Express adapters support"
+	depends on NET_VENDOR_INTEL && PCI && INET
+	select MDIO
+	---help---
+	  This driver supports Intel(R) 10GbE PCI Express family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgbe.
+
+config IXGBE_DCA
+	bool "Direct Cache Access (DCA) Support"
+	default y
+	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
+
+config IXGBE_DCB
+	bool "Data Center Bridging (DCB) Support"
+	default n
+	depends on IXGBE && DCB
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
+
+	  If unsure, say N.
+
+config IXGBEVF
+	tristate "Intel(R) 82599 Virtual Function Ethernet support"
+	depends on NET_VENDOR_INTEL && PCI_MSI
+	---help---
+	  This driver supports Intel(R) 82599 virtual functions.  For more
+	  information on how to identify your adapter, go to the Adapter &
+	  Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/sb/CS-008441.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/ixgbevf.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgbevf.  MSI-X interrupt support is required
+	  for this driver to work correctly.
diff --git a/drivers/net/ethernet/intel/Makefile b/drivers/net/ethernet/intel/Makefile
new file mode 100644
index 0000000..c8210e6
--- /dev/null
+++ b/drivers/net/ethernet/intel/Makefile
@@ -0,0 +1,12 @@
+#
+# Makefile for the Intel network device drivers.
+#
+
+obj-$(CONFIG_E100) += e100.o
+obj-$(CONFIG_E1000) += e1000/
+obj-$(CONFIG_E1000E) += e1000e/
+obj-$(CONFIG_IGB) += igb/
+obj-$(CONFIG_IGBVF) += igbvf/
+obj-$(CONFIG_IXGBE) += ixgbe/
+obj-$(CONFIG_IXGBEVF) += ixgbevf/
+obj-$(CONFIG_IXGB) += ixgb/
diff --git a/drivers/net/e100.c b/drivers/net/ethernet/intel/e100.c
similarity index 100%
rename from drivers/net/e100.c
rename to drivers/net/ethernet/intel/e100.c
diff --git a/drivers/net/e1000/Makefile b/drivers/net/ethernet/intel/e1000/Makefile
similarity index 100%
rename from drivers/net/e1000/Makefile
rename to drivers/net/ethernet/intel/e1000/Makefile
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
similarity index 100%
rename from drivers/net/e1000/e1000.h
rename to drivers/net/ethernet/intel/e1000/e1000.h
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
similarity index 100%
rename from drivers/net/e1000/e1000_ethtool.c
rename to drivers/net/ethernet/intel/e1000/e1000_ethtool.c
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
similarity index 100%
rename from drivers/net/e1000/e1000_hw.c
rename to drivers/net/ethernet/intel/e1000/e1000_hw.c
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/ethernet/intel/e1000/e1000_hw.h
similarity index 100%
rename from drivers/net/e1000/e1000_hw.h
rename to drivers/net/ethernet/intel/e1000/e1000_hw.h
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
similarity index 100%
rename from drivers/net/e1000/e1000_main.c
rename to drivers/net/ethernet/intel/e1000/e1000_main.c
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/ethernet/intel/e1000/e1000_osdep.h
similarity index 100%
rename from drivers/net/e1000/e1000_osdep.h
rename to drivers/net/ethernet/intel/e1000/e1000_osdep.h
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
similarity index 100%
rename from drivers/net/e1000/e1000_param.c
rename to drivers/net/ethernet/intel/e1000/e1000_param.c
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
similarity index 99%
rename from drivers/net/e1000e/es2lan.c
rename to drivers/net/ethernet/intel/e1000e/80003es2lan.c
index c0ecb2d..5631dfd 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -31,7 +31,7 @@
  * 80003ES2LAN Gigabit Ethernet Controller (Serdes)
  */
 
-#include "e1000.h"
+#include "e1000e.h"
 
 #define E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL	 0x00
 #define E1000_KMRNCTRLSTA_OFFSET_INB_CTRL	 0x02
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
similarity index 99%
rename from drivers/net/e1000e/82571.c
rename to drivers/net/ethernet/intel/e1000e/82571.c
index 8295f21..228b532 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -43,7 +43,7 @@
  * 82583V Gigabit Network Connection
  */
 
-#include "e1000.h"
+#include "e1000e.h"
 
 #define ID_LED_RESERVED_F746 0xF746
 #define ID_LED_DEFAULT_82573 ((ID_LED_DEF1_DEF2 << 12) | \
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/ethernet/intel/e1000e/Makefile
similarity index 92%
rename from drivers/net/e1000e/Makefile
rename to drivers/net/ethernet/intel/e1000e/Makefile
index 28519ac..3c749b3 100644
--- a/drivers/net/e1000e/Makefile
+++ b/drivers/net/ethernet/intel/e1000e/Makefile
@@ -32,6 +32,6 @@
 
 obj-$(CONFIG_E1000E) += e1000e.o
 
-e1000e-objs := 82571.o ich8lan.o es2lan.o \
-	       lib.o phy.o param.o ethtool.o netdev.o
+e1000e-objs := 82571.o ich8lan.o 80003es2lan.o \
+	       lib.o phy.o param.o ethtool.o e1000e_main.o
 
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
similarity index 100%
rename from drivers/net/e1000e/defines.h
rename to drivers/net/ethernet/intel/e1000e/defines.h
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000e.h
similarity index 100%
rename from drivers/net/e1000e/e1000.h
rename to drivers/net/ethernet/intel/e1000e/e1000e.h
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/e1000e_main.c
similarity index 99%
rename from drivers/net/e1000e/netdev.c
rename to drivers/net/ethernet/intel/e1000e/e1000e_main.c
index 3bf5249..4ade2d8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/e1000e_main.c
@@ -52,7 +52,7 @@
 #include <linux/aer.h>
 #include <linux/prefetch.h>
 
-#include "e1000.h"
+#include "e1000e.h"
 
 #define DRV_EXTRAVERSION "-k"
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
similarity index 99%
rename from drivers/net/e1000e/ethtool.c
rename to drivers/net/ethernet/intel/e1000e/ethtool.c
index cb1a362..7943908 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -35,7 +35,7 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 
-#include "e1000.h"
+#include "e1000e.h"
 
 enum {NETDEV_STATS, E1000_STATS};
 
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
similarity index 100%
rename from drivers/net/e1000e/hw.h
rename to drivers/net/ethernet/intel/e1000e/hw.h
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
similarity index 99%
rename from drivers/net/e1000e/ich8lan.c
rename to drivers/net/ethernet/intel/e1000e/ich8lan.c
index c175212..e725001 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -56,7 +56,7 @@
  * 82579V Gigabit Network Connection
  */
 
-#include "e1000.h"
+#include "e1000e.h"
 
 #define ICH_FLASH_GFPREG		0x0000
 #define ICH_FLASH_HSFSTS		0x0004
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/ethernet/intel/e1000e/lib.c
similarity index 99%
rename from drivers/net/e1000e/lib.c
rename to drivers/net/ethernet/intel/e1000e/lib.c
index dd8ab05..20e8d25 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/ethernet/intel/e1000e/lib.c
@@ -26,7 +26,7 @@
 
 *******************************************************************************/
 
-#include "e1000.h"
+#include "e1000e.h"
 
 enum e1000_mng_mode {
 	e1000_mng_mode_none = 0,
diff --git a/drivers/net/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
similarity index 99%
rename from drivers/net/e1000e/param.c
rename to drivers/net/ethernet/intel/e1000e/param.c
index 4dd9b63..1f4202c 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -29,7 +29,7 @@
 #include <linux/netdevice.h>
 #include <linux/pci.h>
 
-#include "e1000.h"
+#include "e1000e.h"
 
 /*
  * This is the only thing that needs to be changed to adjust the
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
similarity index 99%
rename from drivers/net/e1000e/phy.c
rename to drivers/net/ethernet/intel/e1000e/phy.c
index 2a6ee13..4ba763b 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -28,7 +28,7 @@
 
 #include <linux/delay.h>
 
-#include "e1000.h"
+#include "e1000e.h"
 
 static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
diff --git a/drivers/net/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
similarity index 100%
rename from drivers/net/igb/Makefile
rename to drivers/net/ethernet/intel/igb/Makefile
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
similarity index 100%
rename from drivers/net/igb/e1000_82575.c
rename to drivers/net/ethernet/intel/igb/e1000_82575.c
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
similarity index 100%
rename from drivers/net/igb/e1000_82575.h
rename to drivers/net/ethernet/intel/igb/e1000_82575.h
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
similarity index 100%
rename from drivers/net/igb/e1000_defines.h
rename to drivers/net/ethernet/intel/igb/e1000_defines.h
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/ethernet/intel/igb/e1000_hw.h
similarity index 100%
rename from drivers/net/igb/e1000_hw.h
rename to drivers/net/ethernet/intel/igb/e1000_hw.h
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
similarity index 100%
rename from drivers/net/igb/e1000_mac.c
rename to drivers/net/ethernet/intel/igb/e1000_mac.c
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/ethernet/intel/igb/e1000_mac.h
similarity index 100%
rename from drivers/net/igb/e1000_mac.h
rename to drivers/net/ethernet/intel/igb/e1000_mac.h
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/ethernet/intel/igb/e1000_mbx.c
similarity index 100%
rename from drivers/net/igb/e1000_mbx.c
rename to drivers/net/ethernet/intel/igb/e1000_mbx.c
diff --git a/drivers/net/igb/e1000_mbx.h b/drivers/net/ethernet/intel/igb/e1000_mbx.h
similarity index 100%
rename from drivers/net/igb/e1000_mbx.h
rename to drivers/net/ethernet/intel/igb/e1000_mbx.h
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
similarity index 100%
rename from drivers/net/igb/e1000_nvm.c
rename to drivers/net/ethernet/intel/igb/e1000_nvm.c
diff --git a/drivers/net/igb/e1000_nvm.h b/drivers/net/ethernet/intel/igb/e1000_nvm.h
similarity index 100%
rename from drivers/net/igb/e1000_nvm.h
rename to drivers/net/ethernet/intel/igb/e1000_nvm.h
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
similarity index 100%
rename from drivers/net/igb/e1000_phy.c
rename to drivers/net/ethernet/intel/igb/e1000_phy.c
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
similarity index 100%
rename from drivers/net/igb/e1000_phy.h
rename to drivers/net/ethernet/intel/igb/e1000_phy.h
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
similarity index 100%
rename from drivers/net/igb/e1000_regs.h
rename to drivers/net/ethernet/intel/igb/e1000_regs.h
diff --git a/drivers/net/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
similarity index 100%
rename from drivers/net/igb/igb.h
rename to drivers/net/ethernet/intel/igb/igb.h
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
similarity index 100%
rename from drivers/net/igb/igb_ethtool.c
rename to drivers/net/ethernet/intel/igb/igb_ethtool.c
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
similarity index 100%
rename from drivers/net/igb/igb_main.c
rename to drivers/net/ethernet/intel/igb/igb_main.c
diff --git a/drivers/net/igbvf/Makefile b/drivers/net/ethernet/intel/igbvf/Makefile
similarity index 100%
rename from drivers/net/igbvf/Makefile
rename to drivers/net/ethernet/intel/igbvf/Makefile
diff --git a/drivers/net/igbvf/defines.h b/drivers/net/ethernet/intel/igbvf/defines.h
similarity index 100%
rename from drivers/net/igbvf/defines.h
rename to drivers/net/ethernet/intel/igbvf/defines.h
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
similarity index 100%
rename from drivers/net/igbvf/ethtool.c
rename to drivers/net/ethernet/intel/igbvf/ethtool.c
diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/ethernet/intel/igbvf/igbvf.h
similarity index 100%
rename from drivers/net/igbvf/igbvf.h
rename to drivers/net/ethernet/intel/igbvf/igbvf.h
diff --git a/drivers/net/igbvf/mbx.c b/drivers/net/ethernet/intel/igbvf/mbx.c
similarity index 100%
rename from drivers/net/igbvf/mbx.c
rename to drivers/net/ethernet/intel/igbvf/mbx.c
diff --git a/drivers/net/igbvf/mbx.h b/drivers/net/ethernet/intel/igbvf/mbx.h
similarity index 100%
rename from drivers/net/igbvf/mbx.h
rename to drivers/net/ethernet/intel/igbvf/mbx.h
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
similarity index 100%
rename from drivers/net/igbvf/netdev.c
rename to drivers/net/ethernet/intel/igbvf/netdev.c
diff --git a/drivers/net/igbvf/regs.h b/drivers/net/ethernet/intel/igbvf/regs.h
similarity index 100%
rename from drivers/net/igbvf/regs.h
rename to drivers/net/ethernet/intel/igbvf/regs.h
diff --git a/drivers/net/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
similarity index 100%
rename from drivers/net/igbvf/vf.c
rename to drivers/net/ethernet/intel/igbvf/vf.c
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/ethernet/intel/igbvf/vf.h
similarity index 100%
rename from drivers/net/igbvf/vf.h
rename to drivers/net/ethernet/intel/igbvf/vf.h
diff --git a/drivers/net/ixgb/Makefile b/drivers/net/ethernet/intel/ixgb/Makefile
similarity index 100%
rename from drivers/net/ixgb/Makefile
rename to drivers/net/ethernet/intel/ixgb/Makefile
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ethernet/intel/ixgb/ixgb.h
similarity index 100%
rename from drivers/net/ixgb/ixgb.h
rename to drivers/net/ethernet/intel/ixgb/ixgb.h
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_ee.c
rename to drivers/net/ethernet/intel/ixgb/ixgb_ee.c
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ethernet/intel/ixgb/ixgb_ee.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_ee.h
rename to drivers/net/ethernet/intel/ixgb/ixgb_ee.h
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_ethtool.c
rename to drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_hw.c
rename to drivers/net/ethernet/intel/ixgb/ixgb_hw.c
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_hw.h
rename to drivers/net/ethernet/intel/ixgb/ixgb_hw.h
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ethernet/intel/ixgb/ixgb_ids.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_ids.h
rename to drivers/net/ethernet/intel/ixgb/ixgb_ids.h
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_main.c
rename to drivers/net/ethernet/intel/ixgb/ixgb_main.c
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ethernet/intel/ixgb/ixgb_osdep.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_osdep.h
rename to drivers/net/ethernet/intel/ixgb/ixgb_osdep.h
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ethernet/intel/ixgb/ixgb_param.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_param.c
rename to drivers/net/ethernet/intel/ixgb/ixgb_param.c
diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
similarity index 100%
rename from drivers/net/ixgbe/Makefile
rename to drivers/net/ethernet/intel/ixgbe/Makefile
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe.h
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_82598.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_82599.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_common.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_common.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82598.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82598.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82599.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82599.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_nl.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_ethtool.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_fcoe.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_fcoe.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_main.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_mbx.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_mbx.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_phy.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_phy.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_sriov.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_sriov.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_type.h
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_x540.c
rename to drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
diff --git a/drivers/net/ixgbevf/Makefile b/drivers/net/ethernet/intel/ixgbevf/Makefile
similarity index 100%
rename from drivers/net/ixgbevf/Makefile
rename to drivers/net/ethernet/intel/ixgbevf/Makefile
diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ethernet/intel/ixgbevf/defines.h
similarity index 100%
rename from drivers/net/ixgbevf/defines.h
rename to drivers/net/ethernet/intel/ixgbevf/defines.h
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
similarity index 100%
rename from drivers/net/ixgbevf/ethtool.c
rename to drivers/net/ethernet/intel/ixgbevf/ethtool.c
diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
similarity index 100%
rename from drivers/net/ixgbevf/ixgbevf.h
rename to drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
similarity index 100%
rename from drivers/net/ixgbevf/ixgbevf_main.c
rename to drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
similarity index 100%
rename from drivers/net/ixgbevf/mbx.c
rename to drivers/net/ethernet/intel/ixgbevf/mbx.c
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
similarity index 100%
rename from drivers/net/ixgbevf/mbx.h
rename to drivers/net/ethernet/intel/ixgbevf/mbx.h
diff --git a/drivers/net/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
similarity index 100%
rename from drivers/net/ixgbevf/regs.h
rename to drivers/net/ethernet/intel/ixgbevf/regs.h
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
similarity index 100%
rename from drivers/net/ixgbevf/vf.c
rename to drivers/net/ethernet/intel/ixgbevf/vf.c
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
similarity index 100%
rename from drivers/net/ixgbevf/vf.h
rename to drivers/net/ethernet/intel/ixgbevf/vf.h
-- 
1.7.5.4

