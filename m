From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/22] sfc: Make RX queue descriptor counts
 unsigned for consistency
Date: Mon, 11 Mar 2013 19:56:16 +0000
Message-ID: <1363031776.2608.51.camel@bwh-desktop.uk.solarflarecom.com>
References: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16816 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971Ab3CKT4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 15:56:19 -0400
In-Reply-To: <1363030400.2608.37.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index fc6770e..3fd6dbe 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -272,9 +272,9 @@ struct efx_rx_queue {
 	bool enabled;
 	bool flush_pending;
 
-	int added_count;
-	int notified_count;
-	int removed_count;
+	unsigned int added_count;
+	unsigned int notified_count;
+	unsigned int removed_count;
 	unsigned int max_fill;
 	unsigned int fast_fill_trigger;
 	unsigned int min_fill;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
