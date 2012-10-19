From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Fri, 19 Oct 2012 04:45:00 -0700
Message-ID: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758626Ab2JSLpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and igb.

The following are changes since commit db0fe0b2f6bba2fda939737d063db2ae14c58d71:
  Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/linux-merge
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (13):
  ixgbe: Initialize q_vector cpu and affinity masks correctly
  ixgbe: Enable jumbo frames support w/ SR-IOV
  ixgbe: Move message handling routines into their own functions
  ixgbe: Add mailbox API version negotiation support to ixgbe PF
  igb: Split Rx timestamping into two separate functions
  igb: Do not use header split, instead receive all frames into a
    single buffer
  igb: Combine post-processing of skb into a single function
  igb: Map entire page and sync half instead of mapping and unmapping
    half pages
  igb: Move rx_buffer related code in Rx cleanup path into separate
    function
  igb: Lock buffer size at 2K even on systems with larger pages
  igb: Combine q_vector and ring allocation into a single function
  igb: Move the calls to set the Tx and Rx queues into igb_open
  igb: Split igb_update_dca into separate Tx and Rx functions

Tushar Dave (1):
  igb: Correcting and improving small packet check and padding

 drivers/net/ethernet/intel/igb/e1000_82575.h   |    3 +
 drivers/net/ethernet/intel/igb/igb.h           |   70 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c   |   53 +-
 drivers/net/ethernet/intel/igb/igb_main.c      | 1242 +++++++++++++++---------
 drivers/net/ethernet/intel/igb/igb_ptp.c       |   55 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c  |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c   |    7 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |   21 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |  359 ++++---
 11 files changed, 1195 insertions(+), 633 deletions(-)

-- 
1.7.11.7
