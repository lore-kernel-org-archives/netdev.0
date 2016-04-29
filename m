From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 1/2] skbuff: export skb_gro_receive
Date: Fri, 29 Apr 2016 18:33:32 -0300
Message-ID: <a6c5593e640a07736e094e66ba0e0ee85748ed00.1461965035.git.marcelo.leitner@gmail.com>
References: <cover.1461965035.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbcD2Vdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 17:33:47 -0400
In-Reply-To: <cover.1461965035.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp GSO requires it and sctp can be compiled as a module, so we need to
export this function.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7a1d48983f81e68b42e8beb664db9aef00440f13..1b05114baeb5e3aa4f333dccd24a97aff86892ec 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3435,6 +3435,7 @@ done:
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(skb_gro_receive);
 
 void __init skb_init(void)
 {
-- 
2.5.0
