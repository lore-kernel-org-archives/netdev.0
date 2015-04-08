From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/5] selinux/nlmsg: add RTM_NEWNSID and RTM_GETNSID
Date: Wed,  8 Apr 2015 18:36:38 +0200
Message-ID: <1428511002-22329-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34489 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515AbbDHQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:36:45 -0400
In-Reply-To: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These new commands are missing.

Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 2df7b900e259..91228a730801 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -73,6 +73,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_NEWMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_DELMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE  },
 	{ RTM_GETMDB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_NEWNSID,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
-- 
2.2.2
