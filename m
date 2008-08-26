From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 04/13] ixgbe: do not update stats twice each receive
Date: Tue, 26 Aug 2008 04:27:05 -0700
Message-ID: <20080826112705.15787.94509.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbYHZL1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:06 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:06 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 87ef2db..50737cc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -664,9 +664,6 @@ next_desc:
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
 
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
-
 	rx_ring->total_packets += total_rx_packets;
 	rx_ring->total_bytes += total_rx_bytes;
 	adapter->net_stats.rx_bytes += total_rx_bytes;

