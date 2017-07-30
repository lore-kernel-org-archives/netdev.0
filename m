From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/7] More Marvell PHY refactoring and cleanup
Date: Sun, 30 Jul 2017 22:41:43 +0200
Message-ID: <1501447310-24101-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45269 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754236AbdG3Unq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Jul 2017 16:43:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate more duplicated code into helpers, make use of core
helpers, move code into a helper for later adding functionality to add
marvell PHYs, etc.

Andrew Lunn (7):
  net: phy: marvell: tabification
  net: phy: marvell: Use core genphy_soft_reset()
  net: phy: marvell: consolidate RGMII delay code
  net: phy: marvell: Consolidate setting the phy-mode
  net: phy: marvell: Refactor m88e1121 RGMII delay configuration
  net: phy: marvell: Use the set_polarity helper
  net: phy: marvell: Refactor setting downshift into a helper

 drivers/net/phy/marvell.c | 320 ++++++++++++++++++++++------------------------
 1 file changed, 150 insertions(+), 170 deletions(-)

-- 
2.13.2
