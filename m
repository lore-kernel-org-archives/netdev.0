From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 1/2] bridge: update selinux perm table for RTM_NEWMDB and RTM_DELMDB
Date: Sat, 15 Dec 2012 16:09:50 +0800
Message-ID: <1355558992-32285-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54791 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab2LOIjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 03:39:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 security/selinux/nlmsgtab.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 370a646..855e464 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -69,6 +69,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_NEWNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_NEWMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_DELMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE  },
 	{ RTM_GETMDB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
-- 
1.7.7.6
