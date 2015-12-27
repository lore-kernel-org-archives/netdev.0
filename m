From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Sun, 27 Dec 2015 12:58:25 +0100
Message-ID: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50861 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003AbbL0L7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2015 06:59:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset add ethtool support for reading statistics from the PHY.
The Marvell and Micrel Phys are then extended to report receiver
packet errors and idle errors.

v2:
  Fix linking when phylib is not enabled.

Andrew Lunn (3):
  ethtool: Add phy statistics
  phy: marvell: Add ethtool statistics counters
  phy: micrel: Add ethtool statistics counters

 drivers/net/phy/marvell.c    | 135 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/micrel.c     |  96 ++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c        |  35 +++++++++++
 include/linux/phy.h          |  11 +++-
 include/uapi/linux/ethtool.h |   3 +
 net/core/ethtool.c           |  57 +++++++++++++++++-
 6 files changed, 335 insertions(+), 2 deletions(-)

-- 
2.6.4
