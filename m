From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 0/4] Adding PHY MDI(X) support
Date: Tue, 29 Nov 2016 15:16:45 +0530
Message-ID: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0043.outbound.protection.outlook.com ([104.47.37.43]:30848
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751195AbcK2KSq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:18:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I updated all review comments which were given by Andrew and Florian.

This series add support for PHY MDI(X), and implement it for MSCC phys.

Tested on Beaglebone Black with VSC 8531 PHY.

Please review.

Thanks and regards
Raju.

---
Change set:
v1:
- Initial patch submit the WoL and MDI-X in single set of patches

v2:
- Split the mdi(x) as signal set of patches.
- Remove the out_unlock as suggested by Andrew.
- Add mdix_ctrl parameter in "phy_device" to handle the user configure
  mdi(x). Proposed implementation accepted by Florian.
- phydev->mdix_ctrl initialize with ETH_TP_MDI_AUTO. Ethernet controller
  never initialize this parameter. 
- Fix the mdix changes in marvell and microchip driver.

Raju Lakkaraju (4):
  net: phy: add mdix_ctrl to hold the user configuration.
  net: phy: update the mdix_ctrl with correct value.
  net: phy: Add mdi(x) support in Microsemi PHYs driver
  net: phy: Fix the mdix_ctrl changes

 drivers/net/phy/marvell.c   |   4 +-
 drivers/net/phy/microchip.c |   2 +-
 drivers/net/phy/mscc.c      | 105 ++++++++++++++++++++++++++++++++++++++++----
 drivers/net/phy/phy.c       |  10 +++--
 include/linux/phy.h         |   1 +
 5 files changed, 107 insertions(+), 15 deletions(-)

-- 
2.7.4
