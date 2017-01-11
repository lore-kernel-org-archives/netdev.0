From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Move hwmon support out of switch and into PHYs.
Date: Wed, 11 Jan 2017 02:03:22 +0100
Message-ID: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54670 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932324AbdAKBEa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 20:04:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell Ethernet switches contain temperature sensors. They are inside
the embedded PHYs. Move the code into the PHY driver, so that discrete
PHY drivers also export there temperature sensor.

Andrew Lunn (2):
  phy: marvell: Add support for temperature sensor
  net: dsa: Remove hwmon support

 drivers/net/dsa/mv88e6xxx/chip.c      | 154 ------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  16 --
 drivers/net/phy/marvell.c             | 426 +++++++++++++++++++++++++++++++++-
 include/net/dsa.h                     |   8 -
 net/dsa/Kconfig                       |  11 -
 net/dsa/Makefile                      |   1 -
 net/dsa/dsa.c                         |   4 -
 net/dsa/dsa_priv.h                    |   9 -
 net/dsa/hwmon.c                       | 147 ------------
 9 files changed, 423 insertions(+), 353 deletions(-)
 delete mode 100644 net/dsa/hwmon.c

-- 
2.11.0
