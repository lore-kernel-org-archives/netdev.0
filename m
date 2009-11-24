From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/17] sfc: Remove pointless abstraction of memory BAR
	number (2)
Date: Tue, 24 Nov 2009 02:01:33 +0000
Message-ID: <1259028093.14645.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34514 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757603AbZKXCBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:01:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Finish the job by removing the structure member.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index bb3d258..bc6fb2b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -848,7 +848,6 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 
 /**
  * struct efx_nic_type - Efx device type definition
- * @mem_bar: Memory BAR number
  * @mem_map_size: Memory BAR mapped size
  * @txd_ptr_tbl_base: TX descriptor ring base address
  * @rxd_ptr_tbl_base: RX descriptor ring base address
@@ -863,7 +862,6 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  *	descriptors
  */
 struct efx_nic_type {
-	unsigned int mem_bar;
 	unsigned int mem_map_size;
 	unsigned int txd_ptr_tbl_base;
 	unsigned int rxd_ptr_tbl_base;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

