From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/8] ethtool: Define RX n-tuple action to
 clear a rule
Date: Mon, 20 Sep 2010 19:41:47 +0100
Message-ID: <1285008107.2282.104.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7110 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab0ITSlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:41:50 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index b67af60..3350870 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -492,11 +492,12 @@ struct ethtool_rx_ntuple_flow_spec {
 	__u64		data_mask;
 
 	__s32		action;
-#define ETHTOOL_RXNTUPLE_ACTION_DROP -1		/* drop packet */
+#define ETHTOOL_RXNTUPLE_ACTION_DROP	(-1)	/* drop packet */
+#define ETHTOOL_RXNTUPLE_ACTION_CLEAR	(-2)	/* clear filter */
 };
 
 /**
- * struct ethtool_rx_ntuple - command to set RX flow filter
+ * struct ethtool_rx_ntuple - command to set or clear RX flow filter
  * @cmd: Command number - %ETHTOOL_SRXNTUPLE
  * @fs: Flow filter specification
  */
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

