From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: fix the debug information in icmpv6_route_lookup
Date: Fri, 11 Jul 2014 14:34:11 +0800
Message-ID: <1405060451-12633-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:51808 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaGKGeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 02:34:15 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so846035pdb.35
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 23:34:15 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id nz7sm1655280pdb.48.2014.07.10.23.34.13
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 23:34:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

it should be "anycast destination", not "anycast source"

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/icmp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f6c84a6..481fd5a 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -334,7 +334,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net,
 	 * anycast.
 	 */
 	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
-		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast source\n");
+		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast destination\n");
 		dst_release(dst);
 		return ERR_PTR(-EINVAL);
 	}
-- 
1.7.10.4
