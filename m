From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 0/3] fec: ethtool: move to new api {get|set}_link_ksettings
Date: Fri, 15 Apr 2016 00:34:58 +0200
Message-ID: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, decot@googlers.com, f.fainelli@gmail.com,
	fugang.duan@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethtool has a new api {get|set}_link_ksettings that deprecate
the old api {get|set}_settings. We update the fec driver to use
this new ethtool api.

For this first version, I've converted old u32 value in phy structure
to link_modes structure. Another way would be to replace u32 in
phy structure to use DECLARE_LINK_MODE_MASK for advertising, ....


Philippe Reynes (3):
  net: ethtool: export conversion function between u32 and link mode
  phy: add generic function to support ksetting support
  fec: move to new ethtool api {get|set}_link_ksettings

 drivers/net/ethernet/freescale/fec_main.c |   16 +++---
 drivers/net/phy/phy.c                     |   81 +++++++++++++++++++++++++++++
 include/linux/ethtool.h                   |    7 +++
 include/linux/phy.h                       |    4 ++
 net/core/ethtool.c                        |   21 ++++---
 5 files changed, 112 insertions(+), 17 deletions(-)

-- 
1.7.4.4
