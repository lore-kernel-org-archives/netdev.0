From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 12/15] ipv6: declaring udplitev6 protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:15 +0900
Message-ID: <1344715638-22997-12-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring udplitev6 protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv6/udplite.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 1d08e21..9013897 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -57,6 +57,7 @@ struct proto udplitev6_prot = {
 	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
 	.clear_sk	   = sk_prot_clear_portaddr_nulls,
+	.has_own_proc_entry= 1,
 };
 
 static struct inet_protosw udplite6_protosw = {
-- 
1.7.11.2
