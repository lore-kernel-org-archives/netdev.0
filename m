From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH 0/3] net/intel: Add missing calls to dma_mapping_error
Date: Sat, 16 Mar 2013 11:32:02 +0100
Message-ID: <1363429925-12724-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51912 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755592Ab3CPKcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 06:32:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dma_map_single/page, dma_mapping_error must be called.

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
1.8.1.227.g44fe835
