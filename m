From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v1 net-next] net: phy: Add LED mode driver for Microsemi
Date: Wed, 1 Feb 2017 16:22:51 +0530
Message-ID: <1485946372-16926-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0062.outbound.protection.outlook.com ([104.47.37.62]:51840
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751374AbdBAKxB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 05:53:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

LED Mode:
Microsemi PHY support 2 LEDs (LED[0] and LED[1]) to display different
status information that can be selected by setting LED mode.

LED Mode parameter (vsc8531, led-0-mode) and (vsc8531, led-1-mode) get from
Device Tree.

Tested on Beaglebone Black with VSC 8531 PHY.

Change set:
v0:
- Initial version of LED driver for Microsemi PHYs.
v1:
- Update all review comments given by Andrew.
- Add new header file "mscc-phy-vsc8531.h" to define DT macros.
- Add error/range check for DT LED mode input

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Raju Lakkaraju (1):
  net: phy: Add LED mode driver for Microsemi PHYs.

 .../devicetree/bindings/net/mscc-phy-vsc8531.txt   | 10 +++
 drivers/net/phy/mscc.c                             | 85 +++++++++++++++++++++-
 include/dt-bindings/net/mscc-phy-vsc8531.h         | 29 ++++++++
 3 files changed, 123 insertions(+), 1 deletion(-)
 create mode 100644 include/dt-bindings/net/mscc-phy-vsc8531.h

-- 
2.7.4
