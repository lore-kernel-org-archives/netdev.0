From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 2/7] skbuff: export skb_gro_receive
Date: Tue, 31 May 2016 15:55:45 -0300
Message-ID: <880a6436917d7c8c20314085fa773c04500bb73c.1464718103.git.marcelo.leitner@gmail.com>
References: <cover.1464718103.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755337AbcEaS4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 14:56:16 -0400
In-Reply-To: <cover.1464718103.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp GSO requires it and sctp can be compiled as a module, so we need to
export this function.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/skbuff.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f2b77e549c03a771909cd9c87c40ec2b7826cd31..4724bcf9b0cae1cecbe5bc2c04e308bb70b3232a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3438,6 +3438,7 @@ done:
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(skb_gro_receive);
 
 void __init skb_init(void)
 {
-- 
2.5.5
