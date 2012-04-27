From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2 0/5] MIPS: OCTEON: Convert some device to use Device Tree.
Date: Thu, 26 Apr 2012 18:20:25 -0700
Message-ID: <1335489630-27017-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	" David S. Miller" <davem@davemloft.net>,
	"Jean Delvare (PC drivers, core)" <khali@linux-fr.org>,
	"Ben Dooks (embedded platforms)" <ben-linux@fluff.org>,
	"Wolfram Sang (embedded platforms)" <w.sang@pengutronix.de>,
	linux-i2c@vger.kernel.org
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

This patch set depends on the previous set to add Device Tree to
OCTEON.  That set can be found among other places here:

http://marc.info/?l=linux-kernel&m=133548781607480

For v2:

No functional changes, but minor clean-ups to use some new device tree
helper functions.

Some Acked-bys added.

I am suggesting that all these go via Ralf's linux-mips.org tree as
they depend on other patches in that tree.

>From v1:

The patches are for drivers scattered throughout the tree, but there
is an order dependency as well as the dependency mentioned above, so
it may be preferable to merge them all via Ralf's linux-mips.org tree
rather that separately via the various device sub-system maintainers.

The mdio-octeon.c and octeon_mgmt patches were already Acked-by davem.

The i2c has been seen before, but to my knowledge was never acked.

The octeon_ethernet patch is in staging and has also been seen before.

The serial patch is new.


David Daney (5):
  i2c: Convert i2c-octeon.c to use device tree.
  netdev: mdio-octeon.c: Convert to use device tree.
  netdev: octeon_mgmt: Convert to use device tree.
  staging: octeon_ethernet: Convert to use device tree.
  MIPS: Octeon: Use device tree to register serial ports.

 arch/mips/cavium-octeon/octeon-irq.c      |    8 -
 arch/mips/cavium-octeon/octeon-platform.c |  176 ----------------
 arch/mips/cavium-octeon/serial.c          |  134 +++++--------
 arch/mips/include/asm/octeon/octeon.h     |    5 -
 drivers/i2c/busses/i2c-octeon.c           |   92 +++++----
 drivers/net/ethernet/octeon/octeon_mgmt.c |  312 +++++++++++++++++++----------
 drivers/net/phy/mdio-octeon.c             |   92 ++++++---
 drivers/staging/octeon/ethernet-mdio.c    |   28 ++--
 drivers/staging/octeon/ethernet.c         |  153 +++++++++-----
 drivers/staging/octeon/octeon-ethernet.h  |    3 +
 10 files changed, 484 insertions(+), 519 deletions(-)

Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc:  David S. Miller <davem@davemloft.net>
Cc: "Jean Delvare (PC drivers, core)" <khali@linux-fr.org>
Cc: "Ben Dooks (embedded platforms)" <ben-linux@fluff.org>
Cc: "Wolfram Sang (embedded platforms)" <w.sang@pengutronix.de>
Cc: linux-i2c@vger.kernel.org
-- 
1.7.2.3
