From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] net/apne: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Fri, 11 Apr 2014 16:37:37 +0800
Message-ID: <1397205457-24287-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Duan Jiong <duanj.fnst@cn.fujitsu.com>
To: <davem@davemloft.net>, <tedheadster@gmail.com>,
	<geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:47904 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750817AbaDKIjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 04:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes coccinelle error regarding usage of IS_ERR and
PTR_ERR instead of PTR_ERR_OR_ZERO.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 drivers/net/ethernet/8390/apne.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
index 30104b6..c56ac9e 100644
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -560,9 +560,7 @@ static struct net_device *apne_dev;
 static int __init apne_module_init(void)
 {
 	apne_dev = apne_probe(-1);
-	if (IS_ERR(apne_dev))
-		return PTR_ERR(apne_dev);
-	return 0;
+	return PTR_ERR_OR_ZERO(apne_dev);
 }
 
 static void __exit apne_module_exit(void)
-- 
1.8.3.1
