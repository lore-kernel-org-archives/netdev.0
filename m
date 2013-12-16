From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/11] sfc: remove unused 'refcnt' from
 efx_rx_page_state
Date: Mon, 16 Dec 2013 21:33:40 +0000
Message-ID: <1387229620.1799.50.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Andrew Rybchenko" <Andrew.Rybchenko@oktetlabs.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8644 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3LPVdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:33:44 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a0de5c50a0e7..bc1ff36c03e6 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -288,12 +288,9 @@ struct efx_rx_buffer {
  * Used to facilitate sharing dma mappings between recycled rx buffers
  * and those passed up to the kernel.
  *
- * @refcnt: Number of struct efx_rx_buffer's referencing this page.
- *	When refcnt falls to zero, the page is unmapped for dma
  * @dma_addr: The dma address of this page.
  */
 struct efx_rx_page_state {
-	unsigned refcnt;
 	dma_addr_t dma_addr;
 
 	unsigned int __pad[0] ____cacheline_aligned;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
