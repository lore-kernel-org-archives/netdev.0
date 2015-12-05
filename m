From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH] net: remove unnecessary semicolon in netdev_alloc_pcpu_stats()
Date: Sat,  5 Dec 2015 13:58:11 +0100
Message-ID: <1449320291-7727-1-git-send-email-nbd@openwrt.org>
Cc: kaloz@openwrt.org, pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.88-198-24-112.clients.your-server.de ([88.198.24.112]:35380
	"EHLO nbd.name" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751469AbbLENIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 08:08:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This semicolon causes a build error if the function call is wrapped in
parentheses.

Fixes: aabc92bbe3cf ("net: add __netdev_alloc_pcpu_stats() to indicate gfp flags")
Reported-by: Imre Kaloz <kaloz@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7d2d1d7..f2f91d9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2103,7 +2103,7 @@ struct pcpu_sw_netstats {
 })
 
 #define netdev_alloc_pcpu_stats(type)					\
-	__netdev_alloc_pcpu_stats(type, GFP_KERNEL);
+	__netdev_alloc_pcpu_stats(type, GFP_KERNEL)
 
 #include <linux/notifier.h>
 
-- 
2.2.2
