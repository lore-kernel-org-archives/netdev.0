From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 0/4] net: dsa: lan9303: Fix MDIO issues.
Date: Sun, 30 Jul 2017 19:58:52 +0200
Message-ID: <20170730175856.4784-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series fix the MDIO interface for the lan9303 DSA driver.
Bugs found after testing on actual HW.

This series is extracted from the first patch of my first large
series. Significant changes from that version are:
 - use mdiobus_write_nested, mdiobus_read_nested.
 - EXPORT lan9303_indirect_phy_ops

Unfortunately I do not have access to i2c based system for
testing.

Changes from first version:
 - Change EXPORT_SYMBOL to EXPORT_SYMBOL_GPL


Egil Hjelmeland (4):
  net: dsa: lan9303: Fix lan9303_detect_phy_setup() for MDIO
  net: dsa: lan9303: Multiply by 4 to get MDIO register
  net: dsa: lan9303: Renamed indirect phy access functions
  net: dsa: lan9303: MDIO access phy registers directly

 drivers/net/dsa/lan9303-core.c | 43 +++++++++++++++++++++++++++---------------
 drivers/net/dsa/lan9303.h      | 11 +++++++++++
 drivers/net/dsa/lan9303_i2c.c  |  2 ++
 drivers/net/dsa/lan9303_mdio.c | 23 ++++++++++++++++++++++
 4 files changed, 64 insertions(+), 15 deletions(-)

-- 
2.11.0
