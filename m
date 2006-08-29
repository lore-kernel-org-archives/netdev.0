From: paul.moore@hp.com
Subject: [PATCH 2/6] NetLabel: remove unused function prototypes
Date: Tue, 29 Aug 2006 10:42:53 -0400
Message-ID: <20060829144445.034768000@hp.com>
References: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:58318 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965006AbWH2Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:47 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-prototypes_unused
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed some older function prototypes for functions that no longer exist.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-2.6.17.i686/include/net/cipso_ipv4.h
===================================================================
--- linux-2.6.17.i686.orig/include/net/cipso_ipv4.h
+++ linux-2.6.17.i686/include/net/cipso_ipv4.h
@@ -200,15 +200,9 @@ static inline int cipso_v4_cache_add(con
 
 #ifdef CONFIG_NETLABEL
 void cipso_v4_error(struct sk_buff *skb, int error, u32 gateway);
-int cipso_v4_socket_setopt(struct socket *sock,
-			   unsigned char *opt,
-			   u32 opt_len);
 int cipso_v4_socket_setattr(const struct socket *sock,
 			    const struct cipso_v4_doi *doi_def,
 			    const struct netlbl_lsm_secattr *secattr);
-int cipso_v4_socket_getopt(const struct socket *sock,
-			   unsigned char **opt,
-			   u32 *opt_len);
 int cipso_v4_socket_getattr(const struct socket *sock,
 			    struct netlbl_lsm_secattr *secattr);
 int cipso_v4_skbuff_getattr(const struct sk_buff *skb,

--
paul moore
linux security @ hp
