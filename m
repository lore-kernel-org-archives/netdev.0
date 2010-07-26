From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] genetlink: use genl_register_family_with_ops()
Date: Mon, 26 Jul 2010 17:21:05 +0800
Message-ID: <1280136065-17566-1-git-send-email-xiaosuo@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/netlink/genetlink.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index aa4308a..2a2bcc8 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -873,11 +873,7 @@ static int __init genl_init(void)
 	for (i = 0; i < GENL_FAM_TAB_SIZE; i++)
 		INIT_LIST_HEAD(&family_ht[i]);
 
-	err = genl_register_family(&genl_ctrl);
-	if (err < 0)
-		goto problem;
-
-	err = genl_register_ops(&genl_ctrl, &genl_ctrl_ops);
+	err = genl_register_family_with_ops(&genl_ctrl, &genl_ctrl_ops, 1);
 	if (err < 0)
 		goto problem;
 
