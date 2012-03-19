From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Updates
Date: Mon, 19 Mar 2012 14:22:28 -0700
Message-ID: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:5166 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028Ab2CSVWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains fixes/cleanups for ixgbe.  This
series completes the cleanup work from Alex for ixgbe.

The following are changes since commit 4da0bd736552e6377b407b3c3d3ae518ebbdd269:
  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (9):
  ixgbe: Store Tx flags and protocol information to tx_buffer sooner
  ixgbe: Update layout of ixgbe_ring structure to improve cache
    performance
  ixgbe: cleanup logic for the service timer and VF hang detection
  ixgbe: Move poll routine in order to improve readability
  ixgbe: drop err_eeprom tag which is at same location as err_sw_init
  ixgbe: Two minor fixes for RSS and FDIR set queues functions
  ixgbe: Whitespace cleanups
  ixgbe: Add support for enabling UDP RSS via the ethtool rx-flow-hash
    command
  ixgbe: Correct flag values set by ixgbe_fix_features

Jeff Kirsher (1):
  ixgbe: fix namespace issues when FCoE/DCB is not enabled

 drivers/net/ethernet/intel/ixgbe/Makefile        |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   31 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  191 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c    |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |  929 ++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 1452 ++++------------------
 6 files changed, 1399 insertions(+), 1219 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c

-- 
1.7.7.6
