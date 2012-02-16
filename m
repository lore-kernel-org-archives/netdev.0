From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/19] sfc: Make buffer table indices and counts
 consistently unsigned
Date: Thu, 16 Feb 2012 00:49:56 +0000
Message-ID: <1329353396.2565.40.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27679 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754733Ab2BPAt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:49:59 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    4 ++--
 drivers/net/ethernet/sfc/nic.c        |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f526877..59c0583 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -81,8 +81,8 @@ struct efx_special_buffer {
 	void *addr;
 	dma_addr_t dma_addr;
 	unsigned int len;
-	int index;
-	int entries;
+	unsigned int index;
+	unsigned int entries;
 };
 
 /**
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 1bb41ff..2bdfb63 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -192,7 +192,7 @@ static void
 efx_init_special_buffer(struct efx_nic *efx, struct efx_special_buffer *buffer)
 {
 	efx_qword_t buf_desc;
-	int index;
+	unsigned int index;
 	dma_addr_t dma_addr;
 	int i;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
