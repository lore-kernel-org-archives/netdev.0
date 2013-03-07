From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/3] cpsw interrupt pacing and get/set phy setting implementation
Date: Thu, 7 Mar 2013 18:00:18 +0530
Message-ID: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
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

Mugunthan V N (3):
  driver: net: ethernet: cpsw: implement ethtool get/set phy setting
  arm: dts: am33xx: add default ethtool slave to cpsw node
  driver: net: ethernet: cpsw: implement interrupt pacing via ethtool

 Documentation/devicetree/bindings/net/cpsw.txt |    3 +
 arch/arm/boot/dts/am33xx.dtsi                  |    1 +
 drivers/net/ethernet/ti/cpsw.c                 |  127 ++++++++++++++++++++++++
 include/linux/platform_data/cpsw.h             |    1 +
 4 files changed, 132 insertions(+)

-- 
1.7.9.5

