From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] Intel Wired LAN Driver Update
Date: Tue, 20 Sep 2011 00:11:21 -0700
Message-ID: <1316502690-25488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10470 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab1ITHLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Sep 2011 03:11:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to igb only.  This is a smaller
subset of an earlier push request I sent, minus the problem/dependent
patches.  The missing patches are:
  ixgb: eliminate checkstack warnings (Jesse has a v2 in test now)
  igb: Make Tx budget for NAPI user adjustable (I am reworking)
these patches were not included as well since they were somewhat dependent
on the patch I am currently re-working.
  igb: split buffer_info into tx_buffer_info and rx_buffer_info
  igb: Consolidate creation of Tx context descriptors into a single

The following are changes since commit 765cf9976e937f1cfe9159bf4534967c8bf8eb6d:
  tcp: md5: remove one indirection level in tcp_md5sig_pool
and are available in the git repository at:
  git://github.com/Jkirsher/net-next.git

Alexander Duyck (9):
  igb: Update RXDCTL/TXDCTL configurations
  igb: Update max_frame_size to account for an optional VLAN tag if
    present
  igb: drop support for single buffer mode
  igb: streamline Rx buffer allocation and cleanup
  igb: update ring and adapter structure to improve performance
  igb: Refactor clean_rx_irq to reduce overhead and improve performance
  igb: drop the "adv" off function names relating to descriptors
  igb: Replace E1000_XX_DESC_ADV with IGB_XX_DESC
  igb: Remove multi_tx_table and simplify igb_xmit_frame

 drivers/net/ethernet/intel/igb/igb.h         |  117 +++---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   15 +-
 drivers/net/ethernet/intel/igb/igb_main.c    |  524 ++++++++++++--------------
 3 files changed, 311 insertions(+), 345 deletions(-)

-- 
1.7.6.2
