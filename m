From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 10/15] ipv6: declaring tcpv6 protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:13 +0900
Message-ID: <1344715638-22997-10-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring tcpv6 protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv6/tcp_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index aa41b0e..741cb3b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2017,6 +2017,7 @@ struct proto tcpv6_prot = {
 #ifdef CONFIG_MEMCG_KMEM
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
+	.has_own_proc_entry= 1,
 };
 
 static const struct inet6_protocol tcpv6_protocol = {
-- 
1.7.11.2
