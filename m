From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 0/4][pull request] Intel Wired LAN Driver Updates
Date: Fri,  4 May 2012 04:05:00 -0700
Message-ID: <1336129504-29919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56123 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755385Ab2EDLFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 07:05:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes for ixgbe, igb and e1000.

v2: Added e1000 patch to fix sparse warnings and igb/ixgbe to
    correct an issue of calling function to reset Tx queue in
    init path.

The following are changes since commit 5a8887d39e1ba5ee2d4ccb94b14d6f2dce5ddfca:
  sungem: Fix WakeOnLan
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master`

Andrei Emeltchenko (1):
  e1000: Silence sparse warnings by correcting type

Don Skidmore (1):
  ixgbe: fix race condition with shutdown

John Fastabend (2):
  ixgbe: dcb: BIT_APP_UPCHG not set by ixgbe_copy_dcb_cfg()
  igb, ixgbe: netdev_tx_reset_queue incorrectly called from tx init
    path

 drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 +-
 drivers/net/ethernet/intel/igb/igb_main.c        |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c  |   43 ++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   10 +++--
 6 files changed, 32 insertions(+), 34 deletions(-)

-- 
1.7.7.6
