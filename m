From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Sat, 19 Jan 2013 05:14:49 -0800
Message-ID: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39020 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab3ASNPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe, ixgbevf and igb.

The following are changes since commit 1ad759d8479b4b28f2a6c874d380066cf987b341:
  ipv6: remove unneeded check to pskb_may_pull in ipip6_rcv
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G. Abodunrin (1):
  igb: Copyright string update to year 2013

Alexander Duyck (5):
  ixgbe: Make TSO check for CHECKSUM_PARTIAL to avoid skb_is_gso check
  ixgbe: Always use context 0, even for FCoE and TSO
  ixgbe: Update ixgbe Tx flags to improve code efficiency
  ixgbe: Improve performance and reduce size of ixgbe_tx_map
  igb: Replace rmb in Tx cleanup with read_barrier_depends

Greg Rose (3):
  ixgbevf: Synch out of tree and in tree mailbox interrupt handlers
  ixgbevf: Fix link up messages
  ixgbevf: Fix statistics corruption

John Fastabend (1):
  ixgbe: SR-IOV: dynamic IEEE DCBx default priority changes

 drivers/net/ethernet/intel/igb/Makefile           |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c      |   2 +-
 drivers/net/ethernet/intel/igb/e1000_82575.h      |   2 +-
 drivers/net/ethernet/intel/igb/e1000_defines.h    |   2 +-
 drivers/net/ethernet/intel/igb/e1000_hw.h         |   2 +-
 drivers/net/ethernet/intel/igb/e1000_i210.c       |   2 +-
 drivers/net/ethernet/intel/igb/e1000_i210.h       |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mac.h        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.c        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_mbx.h        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.h        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h        |   2 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h       |   2 +-
 drivers/net/ethernet/intel/igb/igb.h              |   2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c      |   2 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c        |   2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  27 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c   |  40 ++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c     |   7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 135 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |   9 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   8 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  41 ++++++-
 27 files changed, 186 insertions(+), 126 deletions(-)

-- 
1.7.11.7
