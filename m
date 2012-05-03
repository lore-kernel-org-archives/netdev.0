From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates
Date: Thu,  3 May 2012 03:08:35 -0700
Message-ID: <1336039717-12336-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49877 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754622Ab2ECKIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 06:08:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for ixgbe.

The following are changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:
  sungem: Fix WakeOnLan
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master`

Don Skidmore (1):
  ixgbe: fix race condition with shutdown

John Fastabend (1):
  ixgbe: dcb: BIT_APP_UPCHG not set by ixgbe_copy_dcb_cfg()

 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    3 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   43 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 ++-
 3 files changed, 24 insertions(+), 28 deletions(-)

-- 
1.7.7.6
