From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 02/15] ipv4: declaring udp protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:05 +0900
Message-ID: <1344715638-22997-2-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-176.catv01.itscom.jp ([219.110.95.176]:49265 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754789Ab2HKUcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 16:32:31 -0400
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Declaring udp protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv4/udp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index b4c3582..a16c4fa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1963,6 +1963,7 @@ struct proto udp_prot = {
 	.compat_getsockopt = compat_udp_getsockopt,
 #endif
 	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.has_own_proc_entry= 1,
 };
 EXPORT_SYMBOL(udp_prot);
 
-- 
1.7.11.2
