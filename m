From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Fri,  4 May 2012 03:35:08 -0700
Message-ID: <1336127716-20383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2289 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901Ab2EDKfT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 06:35:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for e1000e and ixgbe.
The e1000e updates the version number and adds support for i217
silicon.  The ixgbe patches are cleanups/re-organizations to
the driver.

The following are changes since commit f19250883fe09dd2b6b5f818d84874837948c546:
  net/niu: remove one superfluous dma mask check
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (6):
  ixgbe: Track instances of buffer available but no DMA resources
    present
  ixgbe: Reorder the ring to q_vector mapping to improve performance
  ixgbe: Make ixgbe_fc_autoneg return void and always set current_mode
  ixgbe: Use __free_pages instead of put_page to release pages
  ixgbe: Reorder link flow control functions in ixgbe_common.c
  ixgbe: Update link flow control to correctly handle multiple packet
    buffer DCB

Bruce Allan (1):
  e1000e: initial support for i217

Matthew Vick (1):
  e1000e: Update driver version number

 drivers/net/ethernet/intel/e1000e/defines.h        |    8 +
 drivers/net/ethernet/intel/e1000e/e1000.h          |    2 +
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   17 +-
 drivers/net/ethernet/intel/e1000e/hw.h             |    9 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |  370 +++++++++++-
 drivers/net/ethernet/intel/e1000e/netdev.c         |   19 +-
 drivers/net/ethernet/intel/e1000e/phy.c            |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |   65 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  631 +++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h    |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   35 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   27 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h      |    5 +-
 14 files changed, 751 insertions(+), 457 deletions(-)

-- 
1.7.7.6
