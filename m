From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/3] selinux/nlmsg: add XFRM_MSG_MAPPING
Date: Fri, 10 Apr 2015 16:24:28 +0200
Message-ID: <1428675868-11790-4-git-send-email-nicolas.dichtel@6wind.com>
References: <55267162.7050304@tycho.nsa.gov>
 <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul@paul-moore.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Martin Willi <martin@strongswan.org>
To: davem@davemloft.net, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38465 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934123AbbDJOZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 10:25:38 -0400
In-Reply-To: <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command is missing.

Fixes: 3a2dfbe8acb1 ("xfrm: Notify changes in UDP encapsulation via netlink")
CC: Martin Willi <martin@strongswan.org>
Reported-by: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 9bd7f93109a1..30594bfa5fb1 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -109,6 +109,7 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MAPPING,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_audit_perms[] =
-- 
2.2.2
