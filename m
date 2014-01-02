From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu,  2 Jan 2014 01:33:32 -0800
Message-ID: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49542 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707AbaABJdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 04:33:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, e1000e and igb.

Most notably is Mark Rustad's ixgbe patches to add the Live Error
Recovery option to ixgbe as well as additional cleanups to the driver.

The following are changes since commit fbe4d4565badba393a94927e16ae66654a025dca:
  tun, rfs: fix the incorrect hash value
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jeff Kirsher (1):
  igb: make local functions static and remove dead code

Mark Rustad (6):
  ixgbe: Use static inlines instead of macros
  ixgbe: Make ethtool register test use accessors
  ixgbe: Check register reads for adapter removal
  ixgbe: Check for adapter removal on register writes
  ixgbe: Additional adapter removal checks
  ixgbe: Add Live Error Recovery configuration option

Tom Herbert (2):
  net: e1000e calls skb_set_hash
  net: igb calls skb_set_hash

 drivers/net/ethernet/intel/Kconfig               |  11 +++
 drivers/net/ethernet/intel/e1000e/netdev.c       |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c     |   4 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h     |   2 -
 drivers/net/ethernet/intel/igb/e1000_i210.c      |  20 +++--
 drivers/net/ethernet/intel/igb/e1000_i210.h      |   9 --
 drivers/net/ethernet/intel/igb/e1000_phy.c       |  71 ----------------
 drivers/net/ethernet/intel/igb/e1000_phy.h       |   1 -
 drivers/net/ethernet/intel/igb/igb.h             |   2 -
 drivers/net/ethernet/intel/igb/igb_main.c        |   4 +-
 drivers/net/ethernet/intel/igb/igb_ptp.c         |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |  11 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |  58 ++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 102 +++++++++++++----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  66 +++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c     |   3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c     |   2 +-
 17 files changed, 213 insertions(+), 161 deletions(-)

-- 
1.8.3.1
