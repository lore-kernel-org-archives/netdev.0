From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] xfrm: add missing xfrm message types to selinux perm table
Date: Wed,  5 Dec 2012 15:42:48 +0800
Message-ID: <1354693368-19494-1-git-send-email-amwang@redhat.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224Ab2LEHnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 02:43:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SElinux perm table is not up-to-date.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index d309e7f..cc191bc 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -93,6 +93,13 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_REPORT,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MIGRATE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MAPPING,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_audit_perms[] =
