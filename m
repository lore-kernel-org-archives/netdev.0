From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/10][pull request] Intel Wired LAN Driver Update
Date: Sun, 21 Aug 2011 00:29:11 -0700
Message-ID: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61333 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab1HUH3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe.

The following are changes since commit ca1ba7caa68520864e4b9227e67f3bbc6fed373b:
  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (10):
  ixgbe: Simplify transmit cleanup path
  ixgbe: convert rings from q_vector bit indexed array to linked list
  ixgbe: Drop the TX work limit and instead just leave it to budget
  ixgbe: consolidate all MSI-X ring interrupts and poll routines into
    one
  ixgbe: cleanup allocation and freeing of IRQ affinity hint
  ixgbe: Use ring->dev instead of adapter->pdev->dev when updating DCA
  ixgbe: commonize ixgbe_map_rings_to_vectors to work for all interrupt
    types
  ixgbe: Drop unnecessary adapter->hw dereference in loopback test
    setup
  ixgbe: combine PCI_VDEVICE and board declaration to same line
  ixgbe: Update TXDCTL configuration to correctly handle WTHRESH

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   11 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   25 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  738 +++++++---------------
 3 files changed, 239 insertions(+), 535 deletions(-)

-- 
1.7.6

