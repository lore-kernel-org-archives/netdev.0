From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net 0/2] Part 2 of v4.5-rc1 phylib regression
Date: Wed, 27 Jan 2016 01:11:37 +0100
Message-ID: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43332 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbcA0ALs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 19:11:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

White list PHY compatible values which indicate PHYs.  Issue a warning
when one is encountered.

Update the documentation to make it clear what is expected in the
compatible string.

Andrew Lunn (2):
  of: of_mdio: Add a whitelist of PHY compatibilities.
  DT: phy.txt: Clarify expected compatible values

 .../devicetree/bindings/net/brcm,bcmgenet.txt      |  4 ++--
 .../devicetree/bindings/net/mdio-mux-gpio.txt      |  8 -------
 Documentation/devicetree/bindings/net/mdio-mux.txt |  8 -------
 Documentation/devicetree/bindings/net/phy.txt      |  6 +++--
 drivers/of/of_mdio.c                               | 27 ++++++++++++++++++++++
 5 files changed, 33 insertions(+), 20 deletions(-)

-- 
2.7.0
