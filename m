From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] net: Delete trailing semi-colon from definition of
 netdev_WARN()
Date: Mon, 14 Oct 2013 21:49:21 +0100
Message-ID: <1381783761.1626.16.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41633 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758293Ab3JNUt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 16:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro definitions should not normally end with a semi-colon, as this
makes it dangerous to use them an if...else statement.  Happily this
has not happened yet.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e53b44..27f62f7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3049,7 +3049,7 @@ do {								\
  * file/line information and a backtrace.
  */
 #define netdev_WARN(dev, format, args...)			\
-	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args);
+	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args)
 
 /* netif printk helpers, similar to netdev_printk */
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
