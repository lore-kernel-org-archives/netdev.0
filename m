From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/4] bonding cleaning
Date: Sat, 15 Feb 2014 15:57:03 -0800
Message-ID: <cover.1392508410.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Miscellaneous cleanups

Joe Perches (4):
  bonding: Convert pr_warning to pr_warn, neatening
  bonding: Neaten pr_<level>
  bonding: Convert c99 comments
  bonding: Convert memcpy(foo, bar, ETH_ALEN) to ether_addr_copy(foo, bar)

 drivers/net/bonding/bond_3ad.c     |  19 +--
 drivers/net/bonding/bond_3ad.h     | 175 ++++++++++++++--------------
 drivers/net/bonding/bond_alb.c     |  36 +++---
 drivers/net/bonding/bond_debugfs.c |  10 +-
 drivers/net/bonding/bond_main.c    | 231 ++++++++++++++++++-------------------
 drivers/net/bonding/bond_netlink.c |   6 +-
 drivers/net/bonding/bond_options.c | 102 ++++++++--------
 drivers/net/bonding/bond_procfs.c  |   8 +-
 drivers/net/bonding/bond_sysfs.c   |   8 +-
 9 files changed, 288 insertions(+), 307 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
