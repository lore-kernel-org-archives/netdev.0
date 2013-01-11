From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] e1000e: cleanup unusual comment placement
Date: Fri, 11 Jan 2013 02:23:47 -0800
Message-ID: <1357899831-4168-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8893 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487Ab3AKKYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:24:06 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e922bba..94312a4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -765,7 +765,7 @@ static void e1000_alloc_jumbo_rx_buffers(struct e1000_ring *rx_ring,
 	struct e1000_buffer *buffer_info;
 	struct sk_buff *skb;
 	unsigned int i;
-	unsigned int bufsz = 256 - 16 /* for skb_reserve */;
+	unsigned int bufsz = 256 - 16;	/* for skb_reserve */
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
-- 
1.7.11.7
