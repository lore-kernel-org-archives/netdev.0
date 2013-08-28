From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/16] sfc: Rename EFX_PAGE_BLOCK_SIZE to
 EFX_VI_PAGE_SIZE and adjust comments
Date: Wed, 28 Aug 2013 16:20:30 +0100
Message-ID: <1377703230.2264.33.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17277 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab3H1PUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:20:34 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/io.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index 39f6098..19e8b95 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -204,12 +204,12 @@ static inline void efx_reado_table(struct efx_nic *efx, efx_oword_t *value,
 	efx_reado(efx, value, reg + index * sizeof(efx_oword_t));
 }
 
-/* Page-mapped register block size */
-#define EFX_PAGE_BLOCK_SIZE 0x2000
+/* Page size used as step between per-VI registers */
+#define EFX_VI_PAGE_SIZE 0x2000
 
-/* Calculate offset to page-mapped register block */
+/* Calculate offset to page-mapped register */
 #define EFX_PAGED_REG(page, reg) \
-	((page) * EFX_PAGE_BLOCK_SIZE + (reg))
+	((page) * EFX_VI_PAGE_SIZE + (reg))
 
 /* Write the whole of RX_DESC_UPD or TX_DESC_UPD */
 static inline void _efx_writeo_page(struct efx_nic *efx, efx_oword_t *value,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
