From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] cxgb4: Simplify the return expression
Date: Sat, 20 Aug 2016 15:32:41 +0000
Message-ID: <1471707161-29982-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netdev@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34495 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753048AbcHTPcq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 11:32:46 -0400
Received: by mail-pf0-f194.google.com with SMTP id g202so3215718pfb.1
        for <netdev@vger.kernel.org>; Sat, 20 Aug 2016 08:32:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the return expression.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2bb804c..5a82eea 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2922,7 +2922,6 @@ EXPORT_SYMBOL(cxgb4_create_server_filter);
 int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 		unsigned int queue, bool ipv6)
 {
-	int ret;
 	struct filter_entry *f;
 	struct adapter *adap;
 
@@ -2936,11 +2935,7 @@ int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 	/* Unlock the filter */
 	f->locked = 0;
 
-	ret = delete_filter(adap, stid);
-	if (ret)
-		return ret;
-
-	return 0;
+	return delete_filter(adap, stid);
 }
 EXPORT_SYMBOL(cxgb4_remove_server_filter);
 
