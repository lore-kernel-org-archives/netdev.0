From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Fix error in comment on net_device_ops::ndo_get_stats
Date: Mon, 14 Jun 2010 16:19:41 +0100
Message-ID: <1276528781.2074.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16816 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab0FNPTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 11:19:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_get_stats still returns struct net_device_stats *; there is
no struct net_device_stats64.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d85a38e..4164285 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -671,7 +671,7 @@ struct netdev_rx_queue {
  *	1. Define @ndo_get_stats64 to update a rtnl_link_stats64 structure
  *	   (which should normally be dev->stats64) and return a ponter to
  *	   it. The structure must not be changed asynchronously.
- *	2. Define @ndo_get_stats to update a net_device_stats64 structure
+ *	2. Define @ndo_get_stats to update a net_device_stats structure
  *	   (which should normally be dev->stats) and return a pointer to
  *	   it. The structure may be changed asynchronously only if each
  *	   field is written atomically.
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

