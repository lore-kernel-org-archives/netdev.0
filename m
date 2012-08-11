From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 15/15] ipx: declaring ipx protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:18 +0900
Message-ID: <1344715638-22997-15-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring ipx protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipx/af_ipx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index dfd6faa..14be087 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1345,6 +1345,7 @@ static struct proto ipx_proto = {
 	.name	  = "IPX",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct ipx_sock),
+	.has_own_proc_entry= 1,
 };
 
 static int ipx_create(struct net *net, struct socket *sock, int protocol,
-- 
1.7.11.2
