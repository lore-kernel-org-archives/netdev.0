From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] PHY Kconfig and Makefile cleanup
Date: Thu, 18 Aug 2016 23:56:04 +0200
Message-ID: <1471557366-21672-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38661 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754050AbcHSBzO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:55:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Ethernet PHY directory has slowly been getting more entries.
Split the entries in the Makefile and Kconfig into MDIO bus drivers
and PHYs. Within these two groups, sort them. This should reduce merge
conflicts and aid finding what one searches for.

The Kconfig text contains redundant "Driver for" and "Support for"
which add little value, make the vendor less obvious, and defeat the
shortcut key in the menu. Remove such text.

Andrew Lunn (2):
  net: phy: Sort Makefile and Kconfig
  net: phy: Kconfig: Remove redundant "Support for"

 drivers/net/phy/Kconfig  | 439 ++++++++++++++++++++++++-----------------------
 drivers/net/phy/Makefile |  76 ++++----
 2 files changed, 259 insertions(+), 256 deletions(-)

-- 
2.8.1
