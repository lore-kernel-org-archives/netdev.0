From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 01/12] net: dst->rt_next is unused.
Date: Wed, 25 Oct 2017 23:02:39 +0900 (KST)
Message-ID: <20171025.230239.1624027675349383840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdJYOCn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:02:43 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id F1613133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:02:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Delete it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 5047e8053d6c..75462861b12f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -100,7 +100,6 @@ struct dst_entry {
 	struct lwtunnel_state   *lwtstate;
 	union {
 		struct dst_entry	*next;
-		struct rtable __rcu	*rt_next;
 		struct rt6_info __rcu	*rt6_next;
 		struct dn_route __rcu	*dn_next;
 	};
-- 
2.13.6
