From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/6] gianfar: Remove 'Interrupt problem!' warning
Date: Wed, 11 Nov 2009 03:11:03 +0300
Message-ID: <20091111001103.GB8817@oksana.dev.rtsoft.ru>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, Jon Loeliger <jdl@jdl.com>,
	Kumar Gopalpet-B05799 <B05799@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:1561 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751849AbZKKAK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 19:10:58 -0500
Content-Disposition: inline
In-Reply-To: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is OK to poll with disabled IRQs, so remove the warning.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 197b358..79c28f5 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2504,8 +2504,6 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				skb_put(skb, pkt_len);
 				dev->stats.rx_bytes += pkt_len;
 
-				if (in_irq() || irqs_disabled())
-					printk("Interrupt problem!\n");
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
-- 
1.6.3.3

