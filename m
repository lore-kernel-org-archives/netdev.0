From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH V1 net-next 0/5] AMD 10Gb Ethernet driver
Date: Fri, 30 May 2014 11:10:55 -0500
Message-ID: <20140530161055.31154.97537.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jcm@redhat.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:12561
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964784AbaE3QLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 12:11:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements support for the new AMD 10Gb Ethernet
driver (amd-xgbe).  It includes the 10Gb Ethernet driver as well as
a 10Gb Ethernet PHY driver.

This patch series is based on net-next.

---

Tom Lendacky (5):
      amd-xgbe: AMD 10GbE device bindings documentation
      amd-xgbe: Initial AMD 10GbE platform driver
      amd-xgbe: Initial AMD 10GbE phylib driver
      amd-xgbe: Configuration and build support
      amd-xgbe: Maintainer information


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |   17 
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   32 
 MAINTAINERS                                        |    7 
 drivers/net/ethernet/amd/Kconfig                   |   14 
 drivers/net/ethernet/amd/Makefile                  |    1 
 drivers/net/ethernet/amd/xgbe/Makefile             |    6 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        | 1005 +++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c       |  375 +++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |  556 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           | 2175 ++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           | 1316 ++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |  510 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |  503 +++++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c          |  456 ++++
 drivers/net/ethernet/amd/xgbe/xgbe.h               |  677 ++++++
 drivers/net/phy/Kconfig                            |    5 
 drivers/net/phy/Makefile                           |    1 
 drivers/net/phy/amd-xgbe-phy.c                     | 1309 ++++++++++++
 18 files changed, 8964 insertions(+), 1 deletion(-)
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
