From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH V3 net-next 0/5] amd-xgbe: AMD 10Gb Ethernet driver
Date: Thu, 5 Jun 2014 09:14:54 -0500
Message-ID: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jcm@redhat.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0187.outbound.protection.outlook.com ([207.46.163.187]:11142
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751152AbaFEOPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 10:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements support for the new AMD 10Gb Ethernet
driver (amd-xgbe).  It includes the 10Gb Ethernet driver as well as
a 10Gb Ethernet PHY driver.

This patch series is based on net-next.

Changes in V3:
  - Add OF dependency to the phylib driver configuration

Changes in V2:
  - Add phy-mode to the amd-xgbe device bindings
  - Obtain the phy-mode from the device tree
  - Reference ethernet.txt device bindings for phy-handle and phy-mode
  - Connect/disconnect to/from phy during probe/remove, instead of open/close
  - Fixes for jumbo packet support / MTU changes
  - Formatting changes for debug packet dump
  - Free resources in the phylib driver remove function
  - Proper NP NULL message during auto-negotiation

---

Tom Lendacky (5):
      amd-xgbe: AMD 10GbE device bindings documentation
      amd-xgbe: Initial AMD 10GbE platform driver
      amd-xgbe: Initial AMD 10GbE phylib driver
      amd-xgbe: Configuration and build support
      amd-xgbe: Maintainer information


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   17 
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   34 
 MAINTAINERS                                        |    7 
 drivers/net/ethernet/amd/Kconfig                   |   14 
 drivers/net/ethernet/amd/Makefile                  |    1 
 drivers/net/ethernet/amd/xgbe/Makefile             |    6 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        | 1007 +++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c       |  375 +++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  556 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           | 2183 ++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           | 1351 ++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |  510 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  512 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c          |  433 ++++
 drivers/net/ethernet/amd/xgbe/xgbe.h               |  676 ++++++
 drivers/net/phy/Kconfig                            |    6 
 drivers/net/phy/Makefile                           |    1 
 drivers/net/phy/amd-xgbe-phy.c                     | 1357 ++++++++++++
 18 files changed, 9045 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
 create mode 100644 Documentation/devicetree/bindings/net/amd-xgbe.txt
 create mode 100644 drivers/net/ethernet/amd/xgbe/Makefile
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-common.h
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-desc.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-dev.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-drv.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-main.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe.h
 create mode 100644 drivers/net/phy/amd-xgbe-phy.c

-- 
Tom Lendacky
