From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/5 v2] netlink: Fix portid type in netlink_notify
Date: Thu,  9 Apr 2015 23:57:13 +0200
Message-ID: <1428616637-21690-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

portid is an unsigned integer. Fix netlink_notify to
match all other portid user in the kernel.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 include/linux/netlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 02fc86d..6835c12 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -134,7 +134,7 @@ struct netlink_callback {
 
 struct netlink_notify {
 	struct net *net;
-	int portid;
+	u32 portid;
 	int protocol;
 };
 
-- 
1.8.4.5
