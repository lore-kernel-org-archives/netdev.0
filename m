From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] DSA: GPIO to reset switches
Date: Thu, 19 Nov 2015 00:29:23 +0100
Message-ID: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36874 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757337AbbKRX3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 18:29:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches add support for using a GPIO to hard reset a switch
during setup.

Andrew Lunn (2):
  net: dsa: Add support for a switch reset gpio
  dsa: mv88e6xxx.c: Hardware reset the chip if available

 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 +++
 drivers/net/dsa/mv88e6xxx.c                       | 14 ++++++++++++++
 include/net/dsa.h                                 |  9 +++++++++
 net/dsa/dsa.c                                     | 19 +++++++++++++++++++
 4 files changed, 45 insertions(+)

-- 
2.6.2
