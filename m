From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/10] sfc: Remove efx_channel::last_eventq_read_ptr
Date: Sat, 10 Mar 2012 00:52:12 +0000
Message-ID: <1331340732.2537.19.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51302 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755217Ab2CJAwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:52:15 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This member has never been used in a production version of the driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 27fe85f..f0385e1 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -324,7 +324,6 @@ enum efx_rx_alloc_method {
  * @eventq: Event queue buffer
  * @eventq_mask: Event queue pointer mask
  * @eventq_read_ptr: Event queue read pointer
- * @last_eventq_read_ptr: Last event queue read pointer value.
  * @event_test_cpu: Last CPU to handle interrupt or test event for this channel
  * @irq_count: Number of IRQs since last adaptive moderation decision
  * @irq_mod_score: IRQ moderation score
@@ -355,7 +354,6 @@ struct efx_channel {
 	struct efx_special_buffer eventq;
 	unsigned int eventq_mask;
 	unsigned int eventq_read_ptr;
-	unsigned int last_eventq_read_ptr;
 	int event_test_cpu;
 
 	unsigned int irq_count;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
