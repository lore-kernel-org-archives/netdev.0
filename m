From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/5 v4] netlink: Fix portid type in netlink_notify
Date: Mon, 13 Apr 2015 00:52:35 +0200
Message-ID: <1428879159-19237-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sigma-star.at ([95.130.255.111]:14385 "EHLO
	mail.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbDLWws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 18:52:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
