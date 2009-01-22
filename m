From: Joe Perches <joe@perches.com>
Subject: [PATCH] sctp/ipv6.c: use ipv6_addr_copy
Date: Thu, 22 Jan 2009 13:08:26 -0800
Message-ID: <1232658506.15489.63.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Networking Team <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2206 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbZAVVHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:07:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index ceaa4aa..7862275 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -97,8 +97,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 		if (addr) {
 			addr->a.v6.sin6_family = AF_INET6;
 			addr->a.v6.sin6_port = 0;
-			memcpy(&addr->a.v6.sin6_addr, &ifa->addr,
-				 sizeof(struct in6_addr));
+			ipv6_addr_copy(&addr->a.v6.sin6_addr, &ifa->addr);
 			addr->a.v6.sin6_scope_id = ifa->idev->dev->ifindex;
 			addr->valid = 1;
 			spin_lock_bh(&sctp_local_addr_lock);


