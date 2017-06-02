From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/5] net: dsa: mv88e6xxx: move registers macros
Date: Fri,  2 Jun 2017 17:06:14 -0400
Message-ID: <20170602210619.26837-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset brings no functional changes.

It is the first step of a cleanup renaming the chip header file and
moving the Register definitions _as is_ in their proper header files.

A following patchset will prefix them with the appropriate model
(MV88E6XXX_ or e.g. MV88E6390_) to respect an implicit namespace and
easily identify model subtleties in registers layout, as correctly done
in the newly added serdes.h header.

Vivien Didelot (5):
  net: dsa: mv88e6xxx: rename chip header
  net: dsa: mv88e6xxx: move PHY macros
  net: dsa: mv88e6xxx: move the Port macros
  net: dsa: mv88e6xxx: move the Global 1 macros
  net: dsa: mv88e6xxx: move the Global 2 macros

 drivers/net/dsa/mv88e6xxx/chip.c        |   2 +-
 drivers/net/dsa/mv88e6xxx/chip.h        | 522 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global1.c     |   2 +-
 drivers/net/dsa/mv88e6xxx/global1.h     | 143 ++++-
 drivers/net/dsa/mv88e6xxx/global1_atu.c |   2 +-
 drivers/net/dsa/mv88e6xxx/global1_vtu.c |   2 +-
 drivers/net/dsa/mv88e6xxx/global2.c     |   6 +-
 drivers/net/dsa/mv88e6xxx/global2.h     | 105 +++-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   | 927 --------------------------------
 drivers/net/dsa/mv88e6xxx/phy.c         |   2 +-
 drivers/net/dsa/mv88e6xxx/phy.h         |   3 +
 drivers/net/dsa/mv88e6xxx/port.c        |   3 +-
 drivers/net/dsa/mv88e6xxx/port.h        | 162 +++++-
 drivers/net/dsa/mv88e6xxx/serdes.c      |   2 +-
 drivers/net/dsa/mv88e6xxx/serdes.h      |   2 +-
 15 files changed, 944 insertions(+), 941 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/chip.h
 delete mode 100644 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h

-- 
2.13.0
