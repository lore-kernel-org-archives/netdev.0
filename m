From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: phy: Support "internal" PHY interface
Date: Fri, 23 Jun 2017 10:33:12 -0700
Message-ID: <20170623173316.23017-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        devicetree@vger.kernel.org (open list:OPEN FIRMWARE AND FLATTENED
        DEVICE TREE BINDINGS), linux-kernel@vger.kernel.org (open list),
        david.wu@rock-chips.com, opendmb@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This makes the "internal" phy-mode property generally available and
documented and this allows us to remove some custom parsing code
we had for bcmgenet and bcm_sf2 which both used that specific value.

Florian Fainelli (4):
  dt-bindings: Add "internal" as a valid 'phy-mode' property
  net: phy: Support "internal" PHY interface
  net: bcmgenet: Remove special handling of "internal" phy-mode
  net: dsa: bcm_sf2: Remove special handling of "internal" phy-mode

 Documentation/devicetree/bindings/net/ethernet.txt |  1 +
 drivers/net/dsa/bcm_sf2.c                          | 16 +++++----------
 drivers/net/ethernet/broadcom/genet/bcmmii.c       | 24 ++++++++--------------
 include/linux/phy.h                                |  3 +++
 4 files changed, 17 insertions(+), 27 deletions(-)

-- 
2.9.3
