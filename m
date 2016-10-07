From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v9 0/1] net: phy: Cleanup the Edge-Rate feature in Microsemi PHYs
Date: Fri, 7 Oct 2016 10:28:23 +0200
Message-ID: <1475828904-13839-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0064.outbound.protection.outlook.com ([104.47.40.64]:26432
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750976AbcJGIoS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 04:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew (and other),

Raju and I have been going through all the comments received on the edge-rate
feature, and tried to address them (once again...).

The patch is rebased to fit on top of net-next (it depends on a4cc96d1f).

Following initiatives is covered:

- Updated device tree bindings documentation for edge-rate
- The edge-rate is now specified as a "slowdown", meaning that it is now
  being specified as positive values instead of negative (both
  documentation and implementation wise).
- Only explicitly documented values for "vsc8531,vddmac" and
  "vsc8531,edge-slowdown" are accepted by the device driver.
- Deleting include/dt-bindings/net/mscc-phy-vsc8531.h as it was not needed.
- Initialize to default values when CONFIG_OF_MDIO is not defined
- Using ARRAY_SIZE when iterating through an array.

Please review.

Best regards
Allan W. Nielsen
