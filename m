From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] 6lowpan: Remove __init tag from
 lowpan_netlink_fini().
Date: Wed, 06 Feb 2013 15:55:25 -0500 (EST)
Message-ID: <20130206.155525.2250746566057016668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab3BFUz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:55:26 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id D01E858435C
	for <netdev@vger.kernel.org>; Wed,  6 Feb 2013 12:55:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's called from both __init and __exit code, so neither
tag is appropriate.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ieee802154/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 09cba81..f62c3b9 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1267,7 +1267,7 @@ static inline int __init lowpan_netlink_init(void)
 	return rtnl_link_register(&lowpan_link_ops);
 }
 
-static inline void __init lowpan_netlink_fini(void)
+static inline void lowpan_netlink_fini(void)
 {
 	rtnl_link_unregister(&lowpan_link_ops);
 }
-- 
1.7.11.7
