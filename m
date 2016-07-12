From: weiyj_lk@163.com
Subject: [PATCH -next] net: dsa: Fix non static symbol warning
Date: Tue, 12 Jul 2016 15:24:10 +0000
Message-ID: <1468337050-10866-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:48519 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932428AbcGLPY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 11:24:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warning:

net/dsa/dsa2.c:680:6: warning:
 symbol '_dsa_unregister_switch' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/dsa/dsa2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 78e4c01..f30bad9 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -677,7 +677,7 @@ int dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 }
 EXPORT_SYMBOL_GPL(dsa_register_switch);
 
-void _dsa_unregister_switch(struct dsa_switch *ds)
+static void _dsa_unregister_switch(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
 
