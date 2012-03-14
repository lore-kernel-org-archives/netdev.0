From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/7][pull request] Intel Wired LAN Driver Updates
Date: Wed, 14 Mar 2012 00:55:19 -0700
Message-ID: <1331711726-9439-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47737 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab2CNHz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 03:55:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes/cleanups ixgb and ixgbe.  This
series is part two of three to update ixgbe.

The following are changes since commit 3832b26e49ad9e585239b32f763c31679f9e41fe:
  ixgbe: Simplify logic for ethtool loopback frame creation and testing
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  ixgbe: Do not disable read relaxed ordering when DCA is enabled
  ixgbe: Replace eitr_low and eitr_high with static values in
    ixgbe_update_itr

Atita Shirwaikar (1):
  ixgbe: Fix race condition where RX buffer could become corrupted.

Don Skidmore (1):
  ixgbe: fix obvious return value bug.

Jesse Brandeburg (1):
  ixgbe: use typed min/max functions where possible

Joe Perches (1):
  ixgb: Remove unnecessary defines, use pr_debug

John Fastabend (1):
  ixgbe: dcb: use DCB config values for FCoE traffic class on open

 drivers/net/ethernet/intel/ixgb/ixgb.h           |   12 --
 drivers/net/ethernet/intel/ixgb/ixgb_main.c      |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    4 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   32 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c  |   58 ++++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  125 +++++++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |   10 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |    2 +
 11 files changed, 156 insertions(+), 107 deletions(-)

-- 
1.7.7.6
