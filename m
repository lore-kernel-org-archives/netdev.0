From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv3 net-next 0/3] Ethtool support for phy stats
Date: Tue, 29 Dec 2015 20:51:21 +0100
Message-ID: <1451418684-9238-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52191 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753658AbbL2Tvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 14:51:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset add ethtool support for reading statistics from the PHY.
The Marvell and Micrel Phys are then extended to report receiver
packet errors and idle errors.

v2:
  Fix linking when phylib is not enabled.
v3:
  Inline helpers into ethtool.c, so fixing when phylib is a module.
  
Andrew Lunn (3):
  ethtool: Add phy statistics
  phy: marvell: Add ethtool statistics counters
  phy: micrel: Add ethtool statistics counters

 drivers/net/phy/marvell.c    | 135 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/micrel.c     |  96 ++++++++++++++++++++++++++++++
 include/linux/phy.h          |   6 ++
 include/uapi/linux/ethtool.h |   3 +
 net/core/ethtool.c           |  81 +++++++++++++++++++++++++-
 5 files changed, 320 insertions(+), 1 deletion(-)

-- 
2.6.4
