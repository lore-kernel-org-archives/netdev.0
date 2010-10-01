From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] selinux: add dcbnl netlink messages to selinux
Date: Fri, 01 Oct 2010 10:07:50 -0700
Message-ID: <20101001170750.20327.16643.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jmorris@namei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add DCBNL netlink msg support to selinux. Without this
'unrecognized netlink message' warnings may be seen.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 security/selinux/nlmsgtab.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 75ec0c6..8b02b21 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -65,6 +65,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_NEWADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_DELADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETADDRLABEL,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_GETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 };
 
 static struct nlmsg_perm nlmsg_firewall_perms[] =
