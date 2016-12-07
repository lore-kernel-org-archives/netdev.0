From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net-next 0/2] phy: lan78xx: add phy fixup unregister
 functions & LAN7801 update
Date: Wed, 7 Dec 2016 20:25:50 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4097998F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:45012 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753080AbcLGUZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:25:52 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

V2 patch of adding phy fixup unregister function with use in LAN7801 update.

Woojung Huh (2):
  phy: add phy fixup unregister functions
  net: lan78xx: add LAN7801 support

 Documentation/networking/phy.txt |   9 ++++
 drivers/net/phy/phy_device.c     |  47 +++++++++++++++++
 drivers/net/usb/Kconfig          |   5 ++
 drivers/net/usb/lan78xx.c        | 109 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/usb/lan78xx.h        |  14 +++++
 include/linux/phy.h              |   4 ++
 6 files changed, 186 insertions(+), 2 deletions(-)

-- 
2.7.4
