From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] netlink: add missing netlink message types to selinux perm table
Date: Tue,  4 Dec 2012 11:53:28 +0800
Message-ID: <1354593208-21939-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab2LDDx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 22:53:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTM_NEWNETCONF and RTM_GETNETCONF are missing in this table.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index d309e7f..0e7a89b 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -67,6 +67,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_GETADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_NEWNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
