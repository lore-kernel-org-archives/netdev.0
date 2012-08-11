From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 09/15] netlink: declaring netlink protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:12 +0900
Message-ID: <1344715638-22997-9-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring netlink protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/netlink/af_netlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5463969..9094be5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -410,6 +410,7 @@ static struct proto netlink_proto = {
 	.name	  = "NETLINK",
 	.owner	  = THIS_MODULE,
 	.obj_size = sizeof(struct netlink_sock),
+	.has_own_proc_entry= 1,
 };
 
 static int __netlink_create(struct net *net, struct socket *sock,
-- 
1.7.11.2
