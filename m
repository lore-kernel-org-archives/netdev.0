From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] net: mark netdev_create_hash __net_init
Date: Mon,  3 Jun 2013 09:43:55 +0300
Message-ID: <7cbbda0ef5f9aef68eeb6553761e0b325102547f.1370241801.git.baruch@tkos.co.il>
Cc: Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:51045 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab3FCHDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 03:03:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_create_hash() is only called from netdev_init() which is marked
__net_init.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..36dd48d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6014,7 +6014,7 @@ netdev_features_t netdev_increment_features(netdev_features_t all,
 }
 EXPORT_SYMBOL(netdev_increment_features);
 
-static struct hlist_head *netdev_create_hash(void)
+static struct hlist_head * __net_init netdev_create_hash(void)
 {
 	int i;
 	struct hlist_head *hash;
-- 
1.7.10.4
