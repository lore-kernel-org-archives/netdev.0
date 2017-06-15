From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/8] net: dsa: prefix Global macros
Date: Thu, 15 Jun 2017 12:13:58 -0400
Message-ID: <20170615161406.20546-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is the 2/3 step of the register definitions cleanup.
It brings no functional changes.

It prefixes and documents all Global (1) registers with MV88E6XXX_G1_
(or a specific model like MV88E6352_G1_STS_PPU_STATE), and prefers a
16-bit hexadecimal representation of the Marvell registers layout.

The next and last patchset will prefix the Global 2 registers.

Vivien Didelot (8):
  net: dsa: mv88e6xxx: prefix Global Status macros
  net: dsa: mv88e6xxx: prefix Global Switch MAC macros
  net: dsa: mv88e6xxx: prefix Global ATU macros
  net: dsa: mv88e6xxx: prefix Global VTU macros
  net: dsa: mv88e6xxx: prefix Global Control macros
  net: dsa: mv88e6xxx: prefix Global Monitor Control macros
  net: dsa: mv88e6xxx: prefix Global Stats macros
  net: dsa: mv88e6xxx: prefix Global Prio and Tag macros

 drivers/net/dsa/mv88e6xxx/chip.c        | 118 +++++------
 drivers/net/dsa/mv88e6xxx/chip.h        |   4 +-
 drivers/net/dsa/mv88e6xxx/global1.c     | 168 ++++++++++------
 drivers/net/dsa/mv88e6xxx/global1.h     | 343 +++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1_atu.c |  56 +++---
 drivers/net/dsa/mv88e6xxx/global1_vtu.c |  62 +++---
 drivers/net/dsa/mv88e6xxx/global2.c     |   4 +-
 7 files changed, 428 insertions(+), 327 deletions(-)

-- 
2.13.1
