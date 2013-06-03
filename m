From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next]] icmp: fix icmp_unreach() comment.
Date: Mon,  3 Jun 2013 13:23:25 +0300
Message-ID: <1370255005-3047-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:45374 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab3FCHXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:23:46 -0400
Received: by mail-ea0-f177.google.com with SMTP id j14so920906eak.22
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 00:23:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP_PARAMETERPROB is handled by icmp_unreach(); This patch adds
ICMP_PARAMETERPROB to the list of ICMP message types handled by icmp_unreach().

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/ipv4/icmp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5d0d379..d0c6e70 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -658,7 +658,8 @@ static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
 }
 
 /*
- *	Handle ICMP_DEST_UNREACH, ICMP_TIME_EXCEED, and ICMP_QUENCH.
+ *	Handle ICMP_DEST_UNREACH, ICMP_TIME_EXCEED, ICMP_QUENCH, and
+ *	ICMP_PARAMETERPROB.
  */
 
 static void icmp_unreach(struct sk_buff *skb)
-- 
1.8.1.4
