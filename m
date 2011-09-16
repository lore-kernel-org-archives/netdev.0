From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Updates
Date: Thu, 15 Sep 2011 21:42:42 -0700
Message-ID: <1316148173-11209-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:25391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109Ab1IPEm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 00:42:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe only.  These are primarily
cleanups of the ixgbe driver.  The first two patches of the series:

  ixgbe: Change default Tx work limit size to 256 buffers
  ixgbe: consolidate all MSI-X ring interrupts and poll routines into one

are re-worked based on previous community feedback (Dave and Ben).

The following are changes since commit 4bc71cb983fd2844e603bf633df2bb53385182d2:
  net: consolidate and fix ethtool_ops->get_settings calling
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (11):
  ixgbe: Change default Tx work limit size to 256 buffers
  v2 ixgbe: consolidate all MSI-X ring interrupts and poll routines
    into one
  ixgbe: cleanup allocation and freeing of IRQ affinity hint
  ixgbe: Use ring->dev instead of adapter->pdev->dev when updating DCA
  ixgbe: commonize ixgbe_map_rings_to_vectors to work for all interrupt
    types
  ixgbe: Drop unnecessary adapter->hw dereference in loopback test
    setup
  ixgbe: combine PCI_VDEVICE and board declaration to same line
  ixgbe: Update TXDCTL configuration to correctly handle WTHRESH
  ixgbe: cleanup reset paths
  ixgbe: cleanup configuration of EITRSEL and VF reset path
  ixgbe: Correctly name and handle MSI-X other interrupt

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c   |   13 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   |   40 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  775 ++++++++--------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c    |   72 +--
 7 files changed, 341 insertions(+), 580 deletions(-)

-- 
1.7.6
