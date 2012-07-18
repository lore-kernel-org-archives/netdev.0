From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Jul 2012 19:20:39 -0700
Message-ID: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab2GRCUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe & ixgbevf.

The following are changes since commit 5abf7f7e0f6bdbfcac737f636497d7016d9507eb:
  ipv4: fix rcu splat
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (6):
  ixgbe: Ping the VFs on link status change to trigger link change
  ixgbe: Handle failures in the ixgbe_setup_rx/tx_resources calls
  ixgbe: Move configuration of set_real_num_rx/tx_queues into open
  ixgbe: Update the logic for ixgbe_cache_ring_dcb and DCB RSS
    configuration
  ixgbe: Cleanup logic for MRQC and MTQC configuration
  ixgbevf: Update descriptor macros to accept pointers and drop _ADV
    suffix

 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |  138 ++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  190 +++++++++++++--------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   12 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   18 +-
 4 files changed, 183 insertions(+), 175 deletions(-)

-- 
1.7.10.4
