From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: mv88e6xxx: improve ATU move operations
Date: Fri,  4 Sep 2015 14:34:09 -0400
Message-ID: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

This patchset completes the set of available Address Translation Unit
operations.

These Marvell switches have 4 operations to flush or (re)move, all or
only non-static MAC addresses, from the entire set of databases or from
just a particular one.

The first 3 patches introduce a generic _mv88e6xxx_atu_flush_move
function. The 4 remaining patches update a few FID operations in the
driver on setup, when a port join or leave a VLAN, or change state.

This is a step forward improving the hardware bridging support in DSA
and 88E6352-compatible switches.

Cheers,
-v

Vivien Didelot (7):
  net: dsa: mv88e6xxx: extract FID write from ATU command
  net: dsa: mv88e6xxx: extract ATU data write access
  net: dsa: mv88e6xxx: rework ATU Flush operation
  net: dsa: mv88e6xxx: flush ATU on initial setup
  net: dsa: mv88e6xxx: flush all addresses when adding a VLAN
  net: dsa: mv88e6xxx: remove addresses when a port leaves a VLAN
  net: dsa: mv88e6xxx: remove all MACs when disabling a port

 drivers/net/dsa/mv88e6xxx.c | 153 ++++++++++++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx.h |   8 +--
 2 files changed, 123 insertions(+), 38 deletions(-)

-- 
2.5.1
