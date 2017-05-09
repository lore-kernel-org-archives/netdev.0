From: Vladis Dronov <vdronov@redhat.com>
Subject: [PATCH v2 net] ipv4: Fix misplaced EXPORT_SYMBOL_GPL(ping_hash) in net/ipv4/ping.c
Date: Tue,  9 May 2017 11:39:57 +0200
Message-ID: <20170509093957.3258-1-vdronov@redhat.com>
Cc: Vladis Dronov <vdronov@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751095AbdEIJkF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 05:40:05 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 296669D436
        for <netdev@vger.kernel.org>; Tue,  9 May 2017 09:40:05 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vladis Dronov <vdronov@redhat.com>
---
This is quite a smaill patch, please, feel free not to accept in separately,
but use as a part of any patch of yours.

 net/ipv4/ping.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index ccfbce1..19f0b7b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -71,7 +71,6 @@ static inline u32 ping_hashfn(const struct net *net, u32 num, u32 mask)
 	pr_debug("hash(%u) = %u\n", num, res);
 	return res;
 }
-EXPORT_SYMBOL_GPL(ping_hash);
 
 static inline struct hlist_nulls_head *ping_hashslot(struct ping_table *table,
 					     struct net *net, unsigned int num)
@@ -152,6 +151,7 @@ int ping_hash(struct sock *sk)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ping_hash);
 
 void ping_unhash(struct sock *sk)
 {
-- 
2.9.3
