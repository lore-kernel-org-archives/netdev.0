From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Wed, 27 Mar 2013 04:05:30 -0700
Message-ID: <1364382333-14721-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8713 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879Ab3C0LFm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 07:05:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, ixgb and e1000e for Christoph.

Christoph provides 3 patches to resolve missing dma_error_call's to
provided Intel drivers which did not have this fix.

The following are changes since commit b175293ccc98ab84e93d25472d7422b4a897614b:
  
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Christoph Paasch (3):
  e1000: ethtool: Add missing dma_mapping_error-call in
    e1000_setup_desc_rings
  ixgb: Add missing dma_mapping_error-call in ixgb_alloc_rx_buffers
  e1000e: Add missing dma_mapping_error-call in
    e1000_alloc_jumbo_rx_buffers

 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 14 +++++++++++---
 drivers/net/ethernet/intel/e1000e/netdev.c       |  7 ++++++-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c      |  7 ++++++-
 3 files changed, 23 insertions(+), 5 deletions(-)

-- 
1.7.11.7
