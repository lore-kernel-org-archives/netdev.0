From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 4/6] [IPV6]: Reorganize strut ipv6_mc_socklist to save 8 bytes
Date: Thu, 31 Jan 2008 16:31:42 -0200
Message-ID: <1201804304-28777-5-git-send-email-acme@redhat.com>
References: y
 <1201804304-28777-1-git-send-email-acme@redhat.com>
 <1201804304-28777-2-git-send-email-acme@redhat.com>
 <1201804304-28777-3-git-send-email-acme@redhat.com>
 <1201804304-28777-4-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:64553 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763457AbYAaScV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:32:21 -0500
Received: by nf-out-0910.google.com with SMTP id g13so137989nfb.21
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 10:32:20 -0800 (PST)
In-Reply-To: <1201804304-28777-4-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/home/acme/git/net-2.6/net/dccp/ipv6.c:
  struct ipv6_mc_socklist |   -8
 1 struct changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/if_inet6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b0b882e..b2509d4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -82,9 +82,9 @@ struct ipv6_mc_socklist
 {
 	struct in6_addr		addr;
 	int			ifindex;
+	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ipv6_mc_socklist *next;
 	rwlock_t		sflock;
-	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip6_sf_socklist	*sflist;
 };
 
-- 
1.5.3.8

