From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [RFC PATCH net-next 1/3] skbuff: export skb_gro_receive
Date: Wed, 27 Jan 2016 15:06:31 -0200
Message-ID: <c4f95e89023018417b7daf2bcec9db8859b65eaa.1453913331.git.marcelo.leitner@gmail.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, brouer@redhat.com,
	alexander.duyck@gmail.com, alexei.starovoitov@gmail.com,
	borkmann@iogearbox.net, marek@cloudflare.com,
	hannes@stressinduktion.org, fw@strlen.de, pabeni@redhat.com,
	john.r.fastabend@intel.com, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbcA0RGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 12:06:54 -0500
In-Reply-To: <cover.1453913331.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp GSO requires it and sctp can be compiled as a module, so export
this function.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b2df375ec9c2173a8132b8efa1c3062f0510284b..704b69682085dec77f3d0f990aaf0024afd705b9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3312,6 +3312,7 @@ done:
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(skb_gro_receive);
 
 void __init skb_init(void)
 {
-- 
2.5.0
