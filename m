From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 06/15] ipv4: declaring tcp protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:09 +0900
Message-ID: <1344715638-22997-6-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring tcp protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv4/tcp_ipv4.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c660d2c..6f36929 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2635,6 +2635,7 @@ struct proto tcp_prot = {
 	.destroy_cgroup		= tcp_destroy_cgroup,
 	.proto_cgroup		= tcp_proto_cgroup,
 #endif
+	.has_own_proc_entry= 1,
 };
 EXPORT_SYMBOL(tcp_prot);
 
-- 
1.7.11.2
