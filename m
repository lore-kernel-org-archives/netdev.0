From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] net: Fix definition of netif_vdbg() when VERBOSE_DEBUG is
 not defined
Date: Tue, 18 May 2010 17:56:32 +0100
Message-ID: <1274201792.2113.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:16677 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab0ERQ4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:56:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c1b2341..667c2a8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2314,7 +2314,7 @@ do {								\
 #define netif_vdbg(priv, type, dev, format, args...)		\
 ({								\
 	if (0)							\
-		netif_printk(KERN_DEBUG, dev, format, ##args);	\
+		netif_printk(priv, type, KERN_DEBUG, dev, format, ##args); \
 	0;							\
 })
 #endif
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

