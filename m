From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 00/13] net: dsa: mv88e6xxx: port macros cosmetics
Date: Mon, 12 Jun 2017 12:37:32 -0400
Message-ID: <20170612163745.16868-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series brings no functional changes.

It prefixes all common port registers macros with MV88E6XXX_PORT.
If registers or some bits differs between switch models, a reference
model is chosen (e.g. MV88E6390_PORT_MAC_CTL_SPEED_10000.)

The register names are documented as found in the datasheets.

Avoid BIT() and shifts defines and prefer a better representation of the
Marvell switch registers with ordered, hexadecimal, 16-bit values.

Vivien Didelot (13):
  net: dsa: mv88e6xxx: prefix Port Status macros
  net: dsa: mv88e6xxx: prefix Port MAC Control macros
  net: dsa: mv88e6xxx: prefix Port Jamming macros
  net: dsa: mv88e6xxx: prefix Port Switch ID macros
  net: dsa: mv88e6xxx: prefix Port Control macros
  net: dsa: mv88e6xxx: prefix Port Control 1 macros
  net: dsa: mv88e6xxx: prefix Port Based VLAN macros
  net: dsa: mv88e6xxx: prefix Port Default VLAN macros
  net: dsa: mv88e6xxx: prefix Port Control 2 macros
  net: dsa: mv88e6xxx: prefix Port Egress Rate Control macros
  net: dsa: mv88e6xxx: prefix Port Association Vector macros
  net: dsa: mv88e6xxx: prefix Port IEEE Priority mapping macros
  net: dsa: mv88e6xxx: prefix remaining port macros

 drivers/net/dsa/mv88e6xxx/chip.c   |  90 ++++-----
 drivers/net/dsa/mv88e6xxx/port.c   | 336 ++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/port.h   | 379 +++++++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/serdes.c |  38 ++--
 4 files changed, 462 insertions(+), 381 deletions(-)

-- 
2.13.1
