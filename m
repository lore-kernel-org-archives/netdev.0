From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/8] net: dsa: mv88e6xxx: misc probe improvements
Date: Wed,  8 Jun 2016 20:44:48 -0400
Message-ID: <20160609004456.5441-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset cleans a bit both legacy and the new MDIO probing functions by
extracting common code and adding helpers.

Then, thanks to the new probing model allowing switch chips to be true Linux
devices, a device node can explicit the switch model in the tree and thus
allows a more robust probing through the MDIO bus.

Vivien Didelot (8):
  net: dsa: mv88e6xxx: fix style issues
  net: dsa: mv88e6xxx: remove redundant assignments
  net: dsa: mv88e6xxx: use already declared variables
  net: dsa: mv88e6xxx: do not increment bus refcount
  net: dsa: mv88e6xxx: add switch register helpers
  net: dsa: mv88e6xxx: add chip detection helper
  net: dsa: mv88e6xxx: explicit compatible devices
  net: dsa: mv88e6xxx: fail on mismatching probe

 Documentation/devicetree/bindings/net/dsa/dsa.txt  |   6 +-
 .../devicetree/bindings/net/dsa/marvell.txt        |  19 ++-
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts          |   6 +-
 drivers/net/dsa/mv88e6xxx.c                        | 189 +++++++++++++--------
 4 files changed, 140 insertions(+), 80 deletions(-)

-- 
2.8.3
