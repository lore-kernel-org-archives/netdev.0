From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: Allocate NVRAM partition ID range for
 PHY images
Date: Fri, 30 Aug 2013 04:43:14 +0100
Message-ID: <1377834194.2552.39.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35071 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab3H3DnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:43:18 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 9e824f7..b5cf624 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -3799,6 +3799,10 @@
 #define          NVRAM_PARTITION_TYPE_DUMP                 0x800
 /* enum: Application license key storage partition */
 #define          NVRAM_PARTITION_TYPE_LICENSE              0x900
+/* enum: Start of range used for PHY partitions (low 8 bits are the PHY ID) */
+#define          NVRAM_PARTITION_TYPE_PHY_MIN              0xa00
+/* enum: End of range used for PHY partitions (low 8 bits are the PHY ID) */
+#define          NVRAM_PARTITION_TYPE_PHY_MAX              0xaff
 /* enum: Start of reserved value range (firmware may use for any purpose) */
 #define          NVRAM_PARTITION_TYPE_RESERVED_VALUES_MIN  0xff00
 /* enum: End of reserved value range (firmware may use for any purpose) */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
