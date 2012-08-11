From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 14/15] ax25: declaring ax25 protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:17 +0900
Message-ID: <1344715638-22997-14-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring ax25 protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ax25/af_ax25.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 779095d..ff23c8a 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -803,6 +803,7 @@ static struct proto ax25_proto = {
 	.name	  = "AX25",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct sock),
+	.has_own_proc_entry= 1,
 };
 
 static int ax25_create(struct net *net, struct socket *sock, int protocol,
-- 
1.7.11.2
