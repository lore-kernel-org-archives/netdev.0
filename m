From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Work around missing PHY prodcut ID in mv88e6390
Date: Wed, 25 Jan 2017 02:55:12 +0100
Message-ID: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44696 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbdAYBzj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 20:55:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
ID is zero. Work around this by trapping reads to the ID, and if it is
zero, return the MV88E6390 family ID.

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
  net: phy: Marvell: Add mv88e6390 internal PHY

 drivers/net/dsa/mv88e6xxx/global2.c | 16 +++++++++++++++-
 drivers/net/phy/marvell.c           | 20 ++++++++++++++++++++
 include/linux/marvell_phy.h         |  6 ++++++
 3 files changed, 41 insertions(+), 1 deletion(-)

-- 
2.11.0
