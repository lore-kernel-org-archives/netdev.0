From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/5] selinux/nlmsg: add RTM_GETNSID
Date: Wed,  8 Apr 2015 18:36:39 +0200
Message-ID: <1428511002-22329-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34490 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbbDHQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:36:45 -0400
In-Reply-To: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new command is missing.

Fixes: 9a9634545c70 ("netns: notify netns id events")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 91228a730801..c8cee0766b60 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -74,6 +74,7 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_DELMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE  },
 	{ RTM_GETMDB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_NEWNSID,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_DELNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
-- 
2.2.2
