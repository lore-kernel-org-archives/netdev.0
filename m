From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: mv88e6xxx: 88E6390 ATU/VTU
Date: Thu, 16 Feb 2017 22:29:25 -0500
Message-ID: <20170217032931.15002-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds support to 88E6390 for the ATU (MAC address databases)
and VTU (VLAN databases), as well as providing a cleaner API for both.

The 6390 family of Marvell switch chip handles the ATU Move operation
differently and has a different usage of the VTU Data registers.

Vivien Didelot (6):
  net: dsa: mv88e6xxx: add port mask helper
  net: dsa: mv88e6xxx: move ATU code in its own file
  net: dsa: mv88e6xxx: add support for 6390 ATU Move
  net: dsa: mv88e6xxx: move VTU code to its own file
  net: dsa: mv88e6xxx: add VTU ops
  net: dsa: mv88e6xxx: add support for 6390 VTU

 drivers/net/dsa/mv88e6xxx/Makefile      |   2 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 859 ++++++++------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  23 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 251 ++++++++++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 493 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  26 +-
 drivers/net/dsa/mv88e6xxx/port.c        |   2 +-
 7 files changed, 1006 insertions(+), 650 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_atu.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c

-- 
2.11.1
