From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/2] Set the CMODE for mv88e6390 ports
Date: Sat,  4 Feb 2017 20:02:48 +0100
Message-ID: <1486234970-11300-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55718 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750921AbdBDTEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 14:04:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6390 ports 9 & 10 allow there CMODE to be set. CMODE is part
of what linux defines as phy-mode. Add the needed phy-modes to linux,
and add code which will act upon the phy-mode property to configure
the switch port.

These patches have been posted before as part of a bigger patchset
which has now been broken up. I've added the received reviewed by
tags, and added device tree documentation.

Andrew Lunn (2):
  net: phy: Add 2000base-x, 2500base-x and rxaui modes
  net: dsa: mv88e6xxx: Set the CMODE for mv88e6390 ports 9 & 10

 Documentation/devicetree/bindings/net/ethernet.txt |  3 +
 drivers/net/dsa/mv88e6xxx/chip.c                   |  8 +++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  9 +++
 drivers/net/dsa/mv88e6xxx/port.c                   | 64 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h                   |  3 +
 include/linux/phy.h                                |  9 +++
 6 files changed, 96 insertions(+)

-- 
2.11.0
