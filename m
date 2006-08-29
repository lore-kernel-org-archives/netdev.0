From: paul.moore@hp.com
Subject: [PATCH 3/6] NetLabel: comment corrections
Date: Tue, 29 Aug 2006 10:42:54 -0400
Message-ID: <20060829144445.819396000@hp.com>
References: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:63182 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965010AbWH2Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:47 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-comments_corrections
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some incorrect comments.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/ss/services.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: net-2.6.19/security/selinux/ss/services.c
===================================================================
--- net-2.6.19.orig/security/selinux/ss/services.c
+++ net-2.6.19/security/selinux/ss/services.c
@@ -2617,7 +2617,7 @@ int selinux_netlbl_sock_rcv_skb(struct s
 }
 
 /**
- * selinux_netlbl_socket_peersid - Return the peer SID of a connected socket
+ * selinux_netlbl_socket_getpeersec_stream - Return the connected peer's SID
  * @sock: the socket
  *
  * Description:

--
paul moore
linux security @ hp
