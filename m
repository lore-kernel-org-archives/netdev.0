From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 0/5] cpsw interrupt pacing and get/set phy setting implementation
Date: Tue, 12 Mar 2013 14:46:33 +0530
Message-ID: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch serires implements the following features in CPSW driver
* get/set phy link settings
* interrupt pacing
* get phy id via ioctl cmd SIOCGMIIPHY

Changes from initial version
* Made active-slave common for cpts, ethtool and SIOCGMIIPHY ioctl
* Cleaned CPSW DT binding documentation by seperating slave nodes
  under sub-section
* implemented get phy id via ioctl cmd SIOCGMIIPHY

Mugunthan V N (5):
  documentation: dt: bindings: cpsw: cleanup documentation
  drivers: net: ethernet: cpsw: change cpts_active_slave to
    active_slave
  driver: net: ethernet: cpsw: implement ethtool get/set phy setting
  driver: net: ethernet: cpsw: implement interrupt pacing via ethtool
  drivers: net: ethernet: cpsw: implement get phy_id via ioctl

 Documentation/devicetree/bindings/net/cpsw.txt |   16 ++-
 arch/arm/boot/dts/am33xx.dtsi                  |    2 +-
 drivers/net/ethernet/ti/cpsw.c                 |  159 ++++++++++++++++++++++--
 include/linux/platform_data/cpsw.h             |    2 +-
 4 files changed, 165 insertions(+), 14 deletions(-)

-- 
1.7.9.5

