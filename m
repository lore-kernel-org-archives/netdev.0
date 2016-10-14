From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next 0/2] net: phy: Add Downshift, FLF2 drivers for Microsemi
Date: Fri, 14 Oct 2016 17:10:31 +0530
Message-ID: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0062.outbound.protection.outlook.com ([104.47.42.62]:8896
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754175AbcJNL4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 07:56:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

This series adds support to the Speed downshift, Fast Link Failure 2,
set drivers for Microsemi PHYs.

Patch 1/4: Link Speed downshift:
        For operation in cabling environments that are incompatible with
        1000BAST-T, VSC8531 device provides an automatic link speed
        downshift operation. When enabled, the device automatically changes
        its 1000BAST-T auto-negotiation to the next slower speed after
        a set number of failed attempts at 1000BAST-T.
        This feature is useful in setting up in networks using older cable
        installations that include only pairs A and B, and not pairs C and D.

Patch 2/4: Fast Link Failure 2:
        VSC8531 Fast Link Failure 2 feature enables the PHY to indicate the
        onset of a potential link failure in < 100 usec for 100BASE-TX
        operation. FLF2 is supported through the MDINT (active low) pin.

All these features tested on Beaglebone Black with VSC 8531 PHY.

Raju Lakkaraju (2):
  net: phy: Add Speed downshift set driver for Microsemi PHYs.
  net: phy: Add Fast Link Failure - 2 set driver for Microsemi PHYs.

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  12 +++
 drivers/net/phy/mscc.c                             | 120 ++++++++++++++++++++-
 2 files changed, 131 insertions(+), 1 deletion(-)

-- 
2.7.4
