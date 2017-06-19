From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/10] net: dsa: Global 2 cosmetics
Date: Mon, 19 Jun 2017 10:55:35 -0400
Message-ID: <20170619145545.26697-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similarly to what has been done for the Port and Global 1 registers,
this patch series prefixes and documents the macros of Global 2.

It brings no functional changes except for 1/10 which fixes the IRL init
for 88E6390 family.

Changes in v2: make *_g2_irl_init_all static inline without
NET_DSA_MV88E6XXX_GLOBAL2 and compile test with and without the symbol.

Vivien Didelot (10):
  net: dsa: mv88e6xxx: add irl_init_all op
  net: dsa: mv88e6xxx: clarify SMI PHY functions
  net: dsa: mv88e6xxx: prefix Global 2 Trunk macros
  net: dsa: mv88e6xxx: prefix Global 2 Device Mapping macros
  net: dsa: mv88e6xxx: prefix Global 2 MGMT macros
  net: dsa: mv88e6xxx: prefix Global 2 PVT macros
  net: dsa: mv88e6xxx: prefix Global 2 EEPROM macros
  net: dsa: mv88e6xxx: prefix Global 2 Switch MAC macros
  net: dsa: mv88e6xxx: prefix Global 2 Watchdog macros
  net: dsa: mv88e6xxx: prefix Global 2 remaining macros

 drivers/net/dsa/mv88e6xxx/chip.c    |  47 ++++
 drivers/net/dsa/mv88e6xxx/chip.h    |  19 +-
 drivers/net/dsa/mv88e6xxx/global2.c | 449 ++++++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/global2.h | 311 ++++++++++++++++---------
 4 files changed, 503 insertions(+), 323 deletions(-)

-- 
2.13.1
