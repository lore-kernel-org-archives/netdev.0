From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Add support for PHY packet generators
Date: Wed, 17 Feb 2016 21:32:05 +0100
Message-ID: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50607 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965453AbcBQUca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:32:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some Ethernet PHYs contain a simple packet generator. This can be
useful for bringing up new devices, trying to determine if a problem
lies in the MAC-PHY connection or PHY-Socket. Also, the PHY generators
can generate invalid packets, which is hard to do in software.

Add support ethtool(1) and wire up the Marvell PHY packet generator.

Andrew Lunn (2):
  net: ethtool: Add support for PHY packet generators
  phy: marvell: Add support for phy packet generator

 drivers/net/phy/marvell.c    | 92 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h          |  4 ++
 include/uapi/linux/ethtool.h | 26 +++++++++++++
 net/core/ethtool.c           | 22 +++++++++++
 4 files changed, 144 insertions(+)

-- 
2.7.0
