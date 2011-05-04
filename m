From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 0/9][pull request] Intel Wired LAN Driver Update
Date: Wed,  4 May 2011 12:30:32 -0700
Message-ID: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755389Ab1EDTao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e100, igb, igbvf, ixgb and ixgbe.

The following are changes since commit e67f88dd12f610da98ca838822f2c9b4e7c6100e:
  net: dont hold rtnl mutex during netlink dump callbacks
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Carolyn Wyborny (1):
  igb: Add check for invalid size to igb_get_invariants_82575()

Don Skidmore (2):
  ixgbe: fix typo error with software defined pins on 82599
  ixgbe: Cleanup PCIe bus speed info

Emil Tantilov (4):
  e100: fix build warning
  ixgbe: Use function pointer for ixgbe_acquire/release_swfw_sync()
  ixgbe: fix sparse warning
  ixgbe: improve EEPROM read/write operations

Jeff Kirsher (1):
  ixgb: convert to set_phys_id

stephen hemminger (1):
  igbvf: remove bogus phys_id

 drivers/net/e100.c                |    2 +-
 drivers/net/igb/e1000_82575.c     |    8 +
 drivers/net/igbvf/ethtool.c       |    6 -
 drivers/net/ixgb/ixgb.h           |    3 -
 drivers/net/ixgb/ixgb_ethtool.c   |   46 +---
 drivers/net/ixgbe/ixgbe_82598.c   |    1 +
 drivers/net/ixgbe/ixgbe_82599.c   |   38 +++-
 drivers/net/ixgbe/ixgbe_common.c  |  440 +++++++++++++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_common.h  |    8 +
 drivers/net/ixgbe/ixgbe_ethtool.c |  115 ++++++-----
 drivers/net/ixgbe/ixgbe_main.c    |    7 +-
 drivers/net/ixgbe/ixgbe_phy.c     |   10 +-
 drivers/net/ixgbe/ixgbe_type.h    |    7 +
 drivers/net/ixgbe/ixgbe_x540.c    |   69 ++++++-
 14 files changed, 559 insertions(+), 201 deletions(-)

-- 
1.7.4.4

