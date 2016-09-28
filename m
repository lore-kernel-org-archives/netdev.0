From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH net-next 0/2] net: phy: Add WoL and Auto Mdix drivers for Microsemi PHYs.
Date: Wed, 28 Sep 2016 17:31:16 +0530
Message-ID: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0082.outbound.protection.outlook.com ([104.47.36.82]:35551
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753844AbcI1MBw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 08:01:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

This series adds support to the Wake-on-LAN and Auto/Mdi-x set drivers
for Microsemi PHYs.

Patch 1/2:
        Wake-on-LAN (WoL) is an Ethernet networking standard that allows
        a computer/device to be turned on or awakened by a network message.
        VSC8531 PHY can support this feature configure by driver set function.
        WoL status get by driver get function.

Patch 2/2:
        To connect two ports of the same configuration (MDI to MDI or
        MDI-X to MDI-X) with a 10/100/1000 Mbit/s connection, an
        Ethernet crossover cable is needed to cross over the transmit
        and receive signals in the cable, so that they are matched at
        the connector level.
        When connecting an MDI port to an MDI-X port a straight through
        cable is used while to connect two MDI ports or two MDI-X ports
        a crossover cable must be used. Conventionally MDI is used on end
        devices while MDI-X is used on hubs and switches

        Auto MDI-X automatically detects the required cable connection
        type and configures the connection appropriately, removing the
        need for crossover cables to interconnect switches or connecting
        PCs peer-to-peer.

        VSC8531 PHY supports Auto MDI-x, MDI and MDI-X configuraion by
        driver set loopback function.

Tested on Beaglebone Black with VSC 8531 PHY.

Raju Lakkaraju (2):
  net: phy: Add Wake-on-LAN driver for Microsemi PHYs.
  net: phy: Add PHY Auto/Mdi/Mdix set driver for Microsemi PHYs.

 drivers/net/phy/mscc.c | 204 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 202 insertions(+), 2 deletions(-)

-- 
2.7.4
