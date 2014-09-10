From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/25] uapi: netfilter_arp: use __u8 instead of u_int8_t
Date: Wed, 10 Sep 2014 17:10:18 +0200
Message-ID: <1410361842-4656-2-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55759 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbaIJPJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 11:09:54 -0400
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>

Similarly, the u_int8_t type is non-standard and not defined.  Change
it to use __u8 like the rest of the netfilter headers.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter_arp/arpt_mangle.h |    2 +-
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
1.7.10.4
