From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/5] DSA cleanup and fixes
Date: Sat, 12 Mar 2016 00:01:35 +0100
Message-ID: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55209 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbcCKXC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:02:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFC patchset for re-architecturing DSA probing contains a few
standalone patches, either clean up or fixes. This pulls them out for
submission.

Andrew Lunn (5):
  dsa: Rename mv88e6123_61_65 to mv88e6123 to be consistent
  dsa: slave: Don't reference NULL pointer during phy_disconnect
  dsa: Destroy fixed link phys after the phy has been disconnected
  dsa: dsa: Fix freeing of fixed-phys from user ports.
  phy: fixed: Fix removal of phys.

 arch/arm/configs/multi_v5_defconfig |   2 +-
 arch/arm/configs/mvebu_v5_defconfig |   2 +-
 arch/arm/configs/orion5x_defconfig  |   2 +-
 arch/tile/configs/tilegx_defconfig  |   2 +-
 arch/tile/configs/tilepro_defconfig |   2 +-
 drivers/net/dsa/Kconfig             |   2 +-
 drivers/net/dsa/Makefile            |   4 +-
 drivers/net/dsa/mv88e6123.c         | 124 ++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6123_61_65.c   | 124 ------------------------------------
 drivers/net/dsa/mv88e6xxx.c         |   8 +--
 drivers/net/dsa/mv88e6xxx.h         |   2 +-
 drivers/net/phy/fixed_phy.c         |  11 +++-
 include/linux/phy_fixed.h           |   5 +-
 net/dsa/dsa.c                       |  27 ++++----
 net/dsa/slave.c                     |  12 ++--
 15 files changed, 167 insertions(+), 162 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6123.c
 delete mode 100644 drivers/net/dsa/mv88e6123_61_65.c

-- 
2.7.0
