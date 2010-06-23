From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 4/5] sfc: Disable setting feature flags that
 are not implemented
Date: Wed, 23 Jun 2010 22:30:35 +0100
Message-ID: <1277328635.2101.11.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18571 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0FWVai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:30:38 -0400
In-Reply-To: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 53f3eb2..dde21a8 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -888,7 +888,6 @@ const struct ethtool_ops efx_ethtool_ops = {
 	/* Need to enable/disable TSO-IPv6 too */
 	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
-	.set_flags		= ethtool_op_set_flags,
 	.get_sset_count		= efx_ethtool_get_sset_count,
 	.self_test		= efx_ethtool_self_test,
 	.get_strings		= efx_ethtool_get_strings,
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

