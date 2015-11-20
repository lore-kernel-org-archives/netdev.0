From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/2] DSA: GPIO to reset switches
Date: Fri, 20 Nov 2015 03:56:22 +0100
Message-ID: <1447988184-9562-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, preid@electromag.com.au,
	Neil Armstrong <narmstrong@baylibre.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37955 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964794AbbKTC4s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 21:56:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches add support for using a GPIO to hard reset a switch
during reset.

v2:

Thanks to a clue from Neil Armstrong, i figured out how to convert the
gpio into a gpiod, while keeping the ACTIVE_LOW flag, so simplifiying
the set/reset code.

I have not included the Tested-by: from Phil Reid, since i made a lot
of changes.

Andrew Lunn (2):
  net: dsa: Add support for a switch reset gpio
  dsa: mv88e6xxx.c: Hardware reset the chip if available

 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 +++
 drivers/net/dsa/mv88e6xxx.c                       | 10 ++++++++++
 include/net/dsa.h                                 |  8 ++++++++
 net/dsa/dsa.c                                     | 17 +++++++++++++++++
 4 files changed, 38 insertions(+)

-- 
2.6.2
