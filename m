From: "Daniel 'NebuchadnezzaR' Dehennin" <nebuchadnezzar@nerim.net>
Subject: [PATCH 2] 2.4.x USAGI unused variables in mipv6_ha_ipsec.c
Date: Fri, 01 Aug 2003 20:09:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87fzklgsh6.fsf@zion.matrix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Networking List <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello again ;-),

A patch to remove unused variables :
mipv6_ha_ipsec.c: In function `__mipv6_mn_change_tunnel_ipsec_by_proto':
mipv6_ha_ipsec.c:216: warning: unused variable `ret'
mipv6_ha_ipsec.c: In function `__mipv6_ha_change_tunnel_ipsec_by_proto':
mipv6_ha_ipsec.c:338: warning: unused variable `ret'

See you.

--- linux-2.4.21/net/ipv6/mobile_ip6/mipv6_ha_ipsec.c.orig	2003-08-01 20:06:15.000000000 +0200
+++ linux-2.4.21/net/ipv6/mobile_ip6/mipv6_ha_ipsec.c	2003-08-01 20:06:42.000000000 +0200
@@ -213,7 +213,6 @@ int __mipv6_mn_change_tunnel_ipsec_by_pr
 	struct in6_addr dst;
 	struct in6_addr src;
 	struct in6_addr *coa = &entry->coa;
-	int ret = 0;
 
 	/*
 	 * Phase 1: Change the following SA/SPD
@@ -335,7 +334,6 @@ int __mipv6_ha_change_tunnel_ipsec_by_pr
 	struct in6_addr dst;
 	struct in6_addr src;
 	struct in6_addr *coa = &entry->coa;
-	int ret = 0;
 
 	/*
 	 * Phase 1: Change the following SA/SPD

-- 
Daniel 'NebuchadnezzaR' Dehennin
