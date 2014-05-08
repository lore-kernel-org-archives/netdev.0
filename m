From: Johan Hovold <jhovold@gmail.com>
Subject: [PATCH 0/5] net: cpsw and mdio-gpio fixes for v3.15-final
Date: Thu,  8 May 2014 09:37:14 +0200
Message-ID: <1399534639-4947-1-git-send-email-jhovold@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Johan Hovold <jhovold@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches against v3.15-rc4 fix a few issues in the cpsw and
mdio-gpio drivers.

Johan


Johan Hovold (5):
  net: mdio-gpio: fix device-tree binding documentation
  net: mdio-gpio: warn about missing bus alias id
  Revert "net: eth: cpsw: Correctly attach to GPIO bitbang MDIO driver"
  net: cpsw: fix null dereference at probe
  net: cpsw: add missing of_node_put

 Documentation/devicetree/bindings/net/mdio-gpio.txt |  2 +-
 drivers/net/ethernet/ti/cpsw.c                      | 17 ++++++-----------
 drivers/net/phy/mdio-gpio.c                         |  4 ++++
 3 files changed, 11 insertions(+), 12 deletions(-)

-- 
1.8.3.2
