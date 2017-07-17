From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 00/12] net: dsa: mv88e6xxx: cleanup capabilities
Date: Mon, 17 Jul 2017 13:03:34 -0400
Message-ID: <20170717170346.19555-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series removes the remaining capabilities as well as the
flags bitmap in the info structures. Most of them are turned into ops,
or new info members.

There is no mv88e6xxx_cap enum or bitmap flags anymore, only
mv88e6xxx_info and mv88e6xxx_ops structures.

While reviewing and documenting the related G2 registers, fix a few
inconsistencies: 88E6185 has no interrupt in G2 and 88E6390 has a POT.

Except these two adjustments, there is no functional changes.

Vivien Didelot (12):
  net: dsa: mv88e6xxx: remove unneeded dsa header
  net: dsa: mv88e6xxx: remove LED control register
  net: dsa: mv88e6xxx: fix 88E6321 family comment
  net: dsa: mv88e6xxx: remove unused capabilities
  net: dsa: mv88e6xxx: remove 88E6185 G2 interrupt
  net: dsa: mv88e6xxx: add number of Global 2 IRQs
  net: dsa: mv88e6xxx: distinguish Global 2 Rsvd2CPU
  net: dsa: mv88e6xxx: add POT flag to 88E6390
  net: dsa: mv88e6xxx: add POT operation
  net: dsa: mv88e6xxx: add a global2_addr info flag
  net: dsa: mv88e6xxx: add Energy Detect ops
  net: dsa: mv88e6xxx: add a multi_chip info flag

 drivers/net/dsa/mv88e6xxx/chip.c    | 291 ++++++++++++++++++++++++------------
 drivers/net/dsa/mv88e6xxx/chip.h    | 152 +++----------------
 drivers/net/dsa/mv88e6xxx/global2.c | 104 +++++++++----
 drivers/net/dsa/mv88e6xxx/global2.h |  41 ++++-
 drivers/net/dsa/mv88e6xxx/phy.c     |  97 +++++++++++-
 drivers/net/dsa/mv88e6xxx/phy.h     |  22 +++
 drivers/net/dsa/mv88e6xxx/port.c    |  17 +++
 drivers/net/dsa/mv88e6xxx/port.h    |   6 +-
 8 files changed, 460 insertions(+), 270 deletions(-)

-- 
2.13.2
