From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: ipv6: remove 'next' member from inet6_dev
Date: Mon, 20 May 2013 16:53:38 +0200
Message-ID: <1369061618-22650-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757154Ab3ETOxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 10:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next pointer within the inet6_dev structure seems not to be used
anywhere. So just remove it. Tested with allmodconfig on x86_64.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/if_inet6.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 0727d0e..e07feb4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -193,7 +193,6 @@ struct inet6_dev {
 	struct in6_addr		token;
 
 	struct neigh_parms	*nd_parms;
-	struct inet6_dev	*next;
 	struct ipv6_devconf	cnf;
 	struct ipv6_devstat	stats;
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
-- 
1.7.11.7
