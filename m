From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] ethtool: Add space between obsolete operations and later
	additions
Date: Thu, 01 Oct 2009 20:37:21 +0100
Message-ID: <1254425841.2735.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57444 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbZJAThT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 15:37:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 15e4eb7..9cbe5f3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -499,6 +499,7 @@ struct ethtool_ops {
 	/* the following hooks are obsolete */
 	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
+
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

