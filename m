From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/7] rtnetlink: Add RTM_DELNETCONF
Date: Tue, 28 Mar 2017 14:28:01 -0700
Message-ID: <1490736487-16020-2-git-send-email-dsa@cumulusnetworks.com>
References: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:38113 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752931AbdC1V2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 17:28:14 -0400
Received: by mail-it0-f52.google.com with SMTP id y18so36137743itc.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 14:28:13 -0700 (PDT)
In-Reply-To: <1490736487-16020-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h | 2 ++
 security/selinux/nlmsgtab.c    | 1 +
 2 files changed, 3 insertions(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 3dd72aee4d32..cce061382e40 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -122,6 +122,8 @@ enum {
 
 	RTM_NEWNETCONF = 80,
 #define RTM_NEWNETCONF RTM_NEWNETCONF
+	RTM_DELNETCONF,
+#define RTM_DELNETCONF RTM_DELNETCONF
 	RTM_GETNETCONF = 82,
 #define RTM_GETNETCONF RTM_GETNETCONF
 
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 2ca9cde939d4..8e67bb4c9cab 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -69,6 +69,7 @@ static struct nlmsg_perm nlmsg_route_perms[] =
 	{ RTM_GETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_SETDCB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_NEWNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_DELNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETNETCONF,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_NEWMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_DELMDB,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE  },
-- 
2.1.4
