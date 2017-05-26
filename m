From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: mv88e6xxx: PHY nitpicks
Date: Fri, 26 May 2017 18:03:04 -0400
Message-ID: <20170526220307.23503-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset isolates more PPU code into phy.c and makes distinction
between PHY Registers read and write implementations vs. generic PHY
routines.

Vivien Didelot (3):
  net: dsa: mv88e6xxx: provide a PHY setup helper
  net: dsa: mv88e6xxx: rename PHY PPU accessors
  net: dsa: mv88e6xxx: rename PHY PPU functions

 drivers/net/dsa/mv88e6xxx/chip.c | 27 +++++++++++-------------
 drivers/net/dsa/mv88e6xxx/phy.c  | 45 ++++++++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/phy.h  | 13 +++++++-----
 3 files changed, 45 insertions(+), 40 deletions(-)

-- 
2.13.0
