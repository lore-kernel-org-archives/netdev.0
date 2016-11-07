From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Subject: [PATCH net-next v2 1/5] net: l2tp: change L2TP_ATTR_UDP_ZERO_CSUM6_{RX,TX} attribute types
Date: Mon,  7 Nov 2016 20:39:24 +0000
Message-ID: <20161107203928.30111-1-asbjorn@asbjorn.st>
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:35029 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752132AbcKGVFN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Nov 2016 16:05:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The attributes L2TP_ATTR_UDP_ZERO_CSUM6_RX and
L2TP_ATTR_UDP_ZERO_CSUM6_TX are used as flags,
but is defined as a u8 in a comment.

This patch redocuments them as flags.

Adding nla_policy entries would break API, so not doing that.

CC: Tom Herbert <therbert@google.com>
Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
---
 include/uapi/linux/l2tp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 4bd27d0..5daa48e 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -124,8 +124,8 @@ enum {
 	L2TP_ATTR_STATS,		/* nested */
 	L2TP_ATTR_IP6_SADDR,		/* struct in6_addr */
 	L2TP_ATTR_IP6_DADDR,		/* struct in6_addr */
-	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* u8 */
-	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* u8 */
+	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* flag */
+	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* flag */
 	L2TP_ATTR_PAD,
 	__L2TP_ATTR_MAX,
 };
-- 
2.10.1
