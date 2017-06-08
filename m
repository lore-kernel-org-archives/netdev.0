From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: ops cosmetics
Date: Thu,  8 Jun 2017 18:34:07 -0400
Message-ID: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset brings no functional changes. It is a first step in a
bigger cosmetics change to the driver. It simplifies print messages and
polishes data types and chip operations.

The next patchs will only prefix and document the port registers macros.

Changes in v2:
  - KISS and simply use dev_* since chip->ds may not be initialized
  - add reviewers tags

Vivien Didelot (7):
  net: dsa: mv888e6xxx: do not use netdev printing
  net: dsa: mv88e6xxx: add egress mode enumeration
  net: dsa: mv88e6xxx: use bridge state values
  net: dsa: mv88e6xxx: do not prefix ops with g1
  net: dsa: mv88e6xxx: rework pause limit operation
  net: dsa: mv88e6xxx: rework jumbo size operation
  net: dsa: mv88e6xxx: prefix PHY macros

 drivers/net/dsa/mv88e6xxx/chip.c | 259 ++++++++++++++++++---------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  17 ++-
 drivers/net/dsa/mv88e6xxx/phy.c  |  11 +-
 drivers/net/dsa/mv88e6xxx/phy.h  |   4 +-
 drivers/net/dsa/mv88e6xxx/port.c | 105 +++++++++++-----
 drivers/net/dsa/mv88e6xxx/port.h |  12 +-
 6 files changed, 224 insertions(+), 184 deletions(-)

-- 
2.13.1
