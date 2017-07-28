From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/4] net: dsa: lan9303: Fix MDIO issues.
Date: Fri, 28 Jul 2017 17:11:53 +0200
Message-ID: <20170728151157.28983-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:54734 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752477AbdG1PMg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 11:12:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fix the MDIO interface for the lan9303 DSA driver.
Bugs found after testing on actual HW.

This series is extracted from the first patch of my first large
series. Significant changes from that version are:
 - use mdiobus_write_nested, mdiobus_read_nested.
 - EXPORT lan9303_indirect_phy_ops

Unfortunately I do not have access to i2c based system for
testing.

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
