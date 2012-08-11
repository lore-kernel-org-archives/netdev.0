From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 11/15] ipv6: declaring udpv6 protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:14 +0900
Message-ID: <1344715638-22997-11-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-176.catv01.itscom.jp ([219.110.95.176]:49265 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754950Ab2HKUcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 16:32:36 -0400
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declaring udpv6 protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv6/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 99d0077..1b28eaf 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1537,6 +1537,7 @@ struct proto udpv6_prot = {
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
 	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.has_own_proc_entry= 1,
 };
 
 static struct inet_protosw udpv6_protosw = {
-- 
1.7.11.2
