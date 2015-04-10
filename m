From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/3] selinux/nlmsg: add XFRM_MSG_REPORT
Date: Fri, 10 Apr 2015 16:24:26 +0200
Message-ID: <1428675868-11790-2-git-send-email-nicolas.dichtel@6wind.com>
References: <55267162.7050304@tycho.nsa.gov>
 <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul@paul-moore.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38457 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934115AbbDJOZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 10:25:38 -0400
In-Reply-To: <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command is missing.

Fixes: 97a64b4577ae ("[XFRM]: Introduce XFRM_MSG_REPORT.")
Reported-by: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 4e21b72dd709..7d49312b30e1 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -103,6 +103,7 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_REPORT,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-- 
2.2.2
