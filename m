From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: do not export skb_gro_receive()
Date: Thu, 02 Oct 2014 07:38:46 -0700
Message-ID: <1412260726.16704.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38256 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbaJBOiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 10:38:52 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so2134653igc.0
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 07:38:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_gro_receive() is only called from tcp_gro_receive() which is
not in a module.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f77e64873caf..a1925c727c67 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3241,7 +3241,6 @@ done:
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(skb_gro_receive);
 
 void __init skb_init(void)
 {
