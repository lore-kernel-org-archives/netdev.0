From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/3] selinux/nlmsg: add XFRM_MSG_MIGRATE
Date: Fri, 10 Apr 2015 16:24:27 +0200
Message-ID: <1428675868-11790-3-git-send-email-nicolas.dichtel@6wind.com>
References: <55267162.7050304@tycho.nsa.gov>
 <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul@paul-moore.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, sds@tycho.nsa.gov
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This command is missing.

Fixes: 5c79de6e79cd ("[XFRM]: User interface for handling XFRM_MSG_MIGRATE")
Reported-by: Stephen Smalley <sds@tycho.nsa.gov>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 security/selinux/nlmsgtab.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 7d49312b30e1..9bd7f93109a1 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -104,6 +104,7 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
 	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_REPORT,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MIGRATE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
 	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
 	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-- 
2.2.2
