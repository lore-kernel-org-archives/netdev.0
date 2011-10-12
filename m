From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/5] intel: Logging cleanups
Date: Wed, 12 Oct 2011 09:18:05 -0700
Message-ID: <cover.1318436085.git.joe@perches.com>
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just some conversions of printks to pr_<level>
and some trivial defect corrections.

Joe Perches (5):
  e1000e: Convert printks to pr_<level>
  ixgbevf: Convert printks to pr_<level>
  igbvf: Convert printks to pr_<level>
  igb: Convert printks to pr_<level>
  igb: Convert bare printk to pr_notice

 drivers/net/ethernet/intel/e1000e/netdev.c        |  232 +++++++++------------
 drivers/net/ethernet/intel/igb/e1000_82575.c      |    5 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |  155 +++++++--------
 drivers/net/ethernet/intel/igbvf/netdev.c         |   14 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    6 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   26 ++--
 6 files changed, 201 insertions(+), 237 deletions(-)

-- 
1.7.6.405.gc1be0
