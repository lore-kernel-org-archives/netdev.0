From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Wed, 18 Jul 2012 13:31:47 -0700
Message-ID: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896Ab2GRUb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbevf & ixgbe.

The following are changes since commit ddbe503203855939946430e39bae58de11b70b69:
  ipv6: add ipv6_addr_hash() helper
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (8):
  ixgbevf: Do not rewind the Rx ring before bumping tail
  ixgbevf: Add netdev to ring structure
  ixgbevf: Consolidate Tx context descriptor creation code
  ixgbevf: Fix multiple issues in ixgbevf_get/set_ringparam
  ixgbe: Update configure virtualization to allow for multiple PF pools
  ixgbe: Add support for SR-IOV w/ DCB or RSS
  ixgbe: Retire RSS enabled and capable flags
  ixgbe: Cleanup holes in flags after removing several of them

Pascal Bouchareine (1):
  ixgbevf: fix VF untagging when 802.1 prio is set

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   56 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  |    4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c      |  387 ++++++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   90 +++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |   52 ++-
 drivers/net/ethernet/intel/ixgbevf/defines.h      |    1 +
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  159 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  405 ++++++++++-----------
 9 files changed, 745 insertions(+), 411 deletions(-)

-- 
1.7.10.4
