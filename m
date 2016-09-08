From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 0/2] net: phy: Add Edge-rate, MAC-IF driver for Microsemi PHYs
Date: Thu, 8 Sep 2016 14:47:20 +0530
Message-ID: <1473326242-4198-1-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <20160824125934.GC13406@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0067.outbound.protection.outlook.com ([104.47.32.67]:54736
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751979AbcIHJcc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 05:32:32 -0400
In-Reply-To: <20160824125934.GC13406@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2:

This is Edge rate control feature.
As system and networking speeds increase, a signal's output transition,
also know as the edge rate or slew rate (V/ns), takes on greater importance
because high-speed signals come with a price. That price is an assortment of
interference problems like ringing on the line, signal overshoot and
undershoot, extended signal settling times, crosstalk noise, transmission line
reflections, false signal detection by the receiving device and electromagnetic
interference (EMI) -- all of which can negate the potential gains designers are
seeking when they try to increase system speeds through the use of higher
performance logic devices. The fact is, faster signaling edge rates can cause
a higher level of electrical noise or other type of interference that can
actually lead to slower line speeds and lower maximum system frequencies.

Microsemi PHY have the provision to configure the edge rate. Edge-rate function
program the right value based on Device Tree configuration.

Tested on Beaglebone Black with VSC 8531 PHY.

Patch 2/2:

This is MAC interface feature.
Microsemi PHY can support RGMII, RMII or GMII/MII interface between MAC and PHY.
MAC-IF function program the right value based on Device tree configuration.

Tested on Beaglebone Black with VSC 8531 PHY.

Raju Lakkaraju (2):
  net: phy: Add Edge-rate driver for Microsemi PHYs.
  net: phy: Add MAC-IF driver for Microsemi PHYs.

 drivers/net/phy/mscc.c | 136 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 136 insertions(+)

-- 
2.7.4
