From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCHv2 0/4] Fixed phy support for DSA ports
Date: Sun, 28 Jun 2015 21:49:57 +0200
Message-ID: <1435521001-25195-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58909 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbbF1T4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 15:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset allows fixed-link phys to be used for all DSA ports.
The patch from Florian allows a phy to be identified as a pseudo phy,
used when a MAC connects to a switch, SFP module, etc. The remaining
patches allow fixed phys to be used with all switch ports, including
the CPU port and DSA ports.

This is RFC since net-next is closed during the merge window.
Comments and acked-by, etc, welcome.

Changes since v1:
  Move setting is_pseudo_fixed_link into fixed_phy_register.
  Removed the precursor work for multiple CPU ports.

Andrew Lunn (3):
  dsa: mv88e6xxx: Allow speed/duplex of port to be configured
  net: dsa: Add dsa_is_dsa_port() helper
  net: dsa: Allow configuration of CPU & DSA port speeds/duplex

Florian Fainelli (1):
  net: phy: Allow PHY devices to identify themselves as Ethernet
    switches, etc.

 drivers/net/dsa/mv88e6123_61_65.c |  1 +
 drivers/net/dsa/mv88e6131.c       |  1 +
 drivers/net/dsa/mv88e6171.c       |  1 +
 drivers/net/dsa/mv88e6352.c       |  1 +
 drivers/net/dsa/mv88e6xxx.c       | 61 +++++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h       |  2 ++
 drivers/net/phy/fixed_phy.c       |  1 +
 include/linux/phy.h               | 12 ++++++++
 include/net/dsa.h                 |  5 ++++
 net/dsa/dsa.c                     | 38 ++++++++++++++++++++++++
 10 files changed, 120 insertions(+), 3 deletions(-)

-- 
2.1.4
