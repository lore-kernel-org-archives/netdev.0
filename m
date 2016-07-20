From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: mv88e6xxx: rework EEPROM code
Date: Wed, 20 Jul 2016 18:18:33 -0400
Message-ID: <20160720221836.28218-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some switches can access an optional external EEPROM via its registers.

The 88E6352 family of switches have 8-bit address / 16-bit data access.
The new 88E6390 family has 16-bit address / 8-bit data access.

This patchset cleans up the EEPROM code with 16-suffixed Global2 helpers
and makes it easy to add future support for 8-bit data EEPROM access.

It also removes unnecessary mutexes and a few locked access functions.

Changes in v2:
  - add missing Signed-off-by tag

Vivien Didelot (3):
  net: dsa: mv88e6xxx: remove unused phy_mutex
  net: dsa: mv88e6xxx: rework EEPROM access
  net: dsa: mv88e6xxx: kill last locked reg_read

 drivers/net/dsa/mv88e6xxx/chip.c      | 518 ++++++++++++++++------------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  45 ++-
 2 files changed, 258 insertions(+), 305 deletions(-)

-- 
2.9.0
