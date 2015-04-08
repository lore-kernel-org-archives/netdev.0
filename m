From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/5] selinux/nlmsg: add XFRM_MSG_[NEW|GET]SADINFO
Date: Wed,  8 Apr 2015 18:36:42 +0200
Message-ID: <1428511002-22329-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34492 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbbDHQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:36:45 -0400
In-Reply-To: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These commands are missing.

Fixes: 28d8909bc790 ("[XFRM]: Export SAD info.")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index d4bccfcfcf2d..4e21b72dd709 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -103,6 +103,8 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 };
-- 
2.2.2
