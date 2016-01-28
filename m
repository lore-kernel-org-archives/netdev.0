From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net 0/2] Part 2 of v4.5-rc1 phylib regression
Date: Thu, 28 Jan 2016 02:30:28 +0100
Message-ID: <1453944630-28585-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	aaro.koskinen@nokia.com, olof@lixom.net,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44319 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936365AbcA1BbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 20:31:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

White list PHY compatible values which indicate PHYs.  Issue a warning
when one is encountered.

Update the documentation to make it clear what is expected in the
compatible string.

v2:
Fix Grammar, reword changelog, add Tested-by and Acked-by.

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
