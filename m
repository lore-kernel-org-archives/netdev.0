From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/16] batman-adv: checkpatch - comparison to NULL could be rewritten
Date: Fri, 29 May 2015 11:05:24 +0200
Message-ID: <1432890328-8247-13-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:2784 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754162AbbE2JUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:20:05 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 9426b83..50cf722 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -818,7 +818,7 @@ static int batadv_softif_slave_add(struct net_device *dev,
 	int ret = -EINVAL;
 
 	hard_iface = batadv_hardif_get_by_netdev(slave_dev);
-	if (!hard_iface || hard_iface->soft_iface != NULL)
+	if (!hard_iface || hard_iface->soft_iface)
 		goto out;
 
 	ret = batadv_hardif_enable_interface(hard_iface, dev->name);
-- 
2.4.2
