From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Sat, 14 Jul 2012 16:06:58 -0700
Message-ID: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31575 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839Ab2GNXHZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and ixgbe.

The following are changes since commit 141e369de698f2e17bf716b83fcc647ddcb2220c:
  xfrm: Initialize the struct xfrm_dst behind the dst_enty field
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (5):
  ixgbe: Simplify logic for getting traffic class from user priority
  ixgbe: Cleanup unpacking code for DCB
  ixgbe: Populate the prio_tc_map in ixgbe_setup_tc
  ixgbe: Add function for obtaining FCoE TC based on FCoE user priority
  ixgbe: Merge FCoE set_num and cache_ring calls into RSS/DCB config

Matthew Vick (1):
  e1000e: Program the correct register for ITR when using MSI-X.

Tushar Dave (1):
  e1000e: Cleanup code logic in e1000_check_for_serdes_link_82571()

 drivers/net/ethernet/intel/e1000e/82571.c       |   14 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |    1 +
 drivers/net/ethernet/intel/e1000e/ethtool.c     |    5 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |   32 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c    |   74 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.h    |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   26 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c   |   15 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c    |  260 ++++++++++-------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |   61 ++++--
 11 files changed, 265 insertions(+), 225 deletions(-)

-- 
1.7.10.4
