From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/5] selinux/nlmsg: add XFRM_MSG_NEWSPDINFO
Date: Wed,  8 Apr 2015 18:36:40 +0200
Message-ID: <1428511002-22329-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34491 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbbDHQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:36:45 -0400
In-Reply-To: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new command is missing.

Fixes: 880a6fab8f6b ("xfrm: configure policy hash table thresholds by netlink")
Reported-by: Christophe Gouault <christophe.gouault@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index c8cee0766b60..4bc90c2aaea2 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -103,6 +103,7 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 };
 
 static struct nlmsg_perm nlmsg_audit_perms[] =
-- 
2.2.2
