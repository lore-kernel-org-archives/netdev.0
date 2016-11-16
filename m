From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 0/3] net: phy: fix of_node and device leaks
Date: Wed, 16 Nov 2016 15:20:35 +0100
Message-ID: <1479306038-27211-1-git-send-email-johan@kernel.org>
Cc: Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix a couple of of_node leaks in the fixed-link code and a
device reference leak in a phy helper.

Johan


Johan Hovold (3):
  of_mdio: fix node leak in of_phy_register_fixed_link error path
  of_mdio: fix device reference leak in of_phy_find_device
  net: phy: fixed_phy: fix of_node leak in fixed_phy_unregister

 drivers/net/phy/fixed_phy.c | 2 +-
 drivers/of/of_mdio.c        | 6 +++++-
 2 files changed, 6 insertions(+), 2 deletions(-)

-- 
2.7.3
