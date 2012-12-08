From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] rtnetlink: add missing message types to selinux perm table
Date: Sat,  8 Dec 2012 12:59:48 +0800
Message-ID: <1354942788-15208-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539Ab2LHF0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Dec 2012 00:26:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Rebased on the latest net-next tree.

RTM_NEWNETCONF and RTM_GETNETCONF are missing in this table.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 163aaa7..370a646 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -67,6 +67,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_GETADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_NEWNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETMDB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 };
 
