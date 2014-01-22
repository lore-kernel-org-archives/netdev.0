From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] uapi: netfilter_arp: use __u8 instead of u_int8_t
Date: Tue, 21 Jan 2014 21:40:14 -0500
Message-ID: <1390358414-8844-1-git-send-email-vapier@gentoo.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46867 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690AbaAVCkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 21:40:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly, the u_int8_t type is non-standard and not defined.  Change
it to use __u8 like the rest of the netfilter headers.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 include/uapi/linux/netfilter_arp/arpt_mangle.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter_arp/arpt_mangle.h b/include/uapi/linux/netfilter_arp/arpt_mangle.h
index 250f502..8c2b16a 100644
--- a/include/uapi/linux/netfilter_arp/arpt_mangle.h
+++ b/include/uapi/linux/netfilter_arp/arpt_mangle.h
@@ -13,7 +13,7 @@ struct arpt_mangle
 	union {
 		struct in_addr tgt_ip;
 	} u_t;
-	u_int8_t flags;
+	__u8 flags;
 	int target;
 };
 
-- 
1.8.4.3
