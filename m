From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 19 Jul 2012 18:23:57 -0700
Message-ID: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55809 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752087Ab2GTBYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe.

The following are changes since commit 769162e38b91e1d300752e666260fa6c7b203fbc:
  Merge branch 'net' of git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (9):
  ixgbe: Use VMDq offset to indicate the default pool
  ixgbe: Fix memory leak when SR-IOV VFs are direct assigned
  ixgbe: Drop references to deprecated pci_ DMA api and instead use
    dma_ API
  ixgbe: Cleanup configuration of FCoE registers
  ixgbe: Merge all FCoE percpu values into a single structure
  ixgbe: Make FCoE allocation and configuration closer to how rings
    work
  ixgbe: Correctly set SAN MAC RAR pool to default pool of PF
  ixgbe: Only enable anti-spoof on VF pools
  ixgbe: Enable FCoE FSO and CRC offloads based on CAPABLE instead of
    ENABLED flag

 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |    5 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |    4 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |   45 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c   |  378 ++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.h   |   15 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  117 +++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c  |   20 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |    3 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    4 +
 10 files changed, 344 insertions(+), 248 deletions(-)

-- 
1.7.10.4
