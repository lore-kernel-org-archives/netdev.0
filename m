From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 03/15] ipv4: declaring icmp protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:06 +0900
Message-ID: <1344715638-22997-3-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring icmp protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv4/ping.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 6232d47..c4bb504 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -748,6 +748,7 @@ struct proto ping_prot = {
 	.unhash =	ping_v4_unhash,
 	.get_port =	ping_v4_get_port,
 	.obj_size =	sizeof(struct inet_sock),
+	.has_own_proc_entry= 1,
 };
 EXPORT_SYMBOL(ping_prot);
 
-- 
1.7.11.2
