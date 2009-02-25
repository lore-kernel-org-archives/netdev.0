From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] llc: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:42:22 +0800
Message-ID: <49A5208E.3050302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52994 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756796AbZBYKnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:43:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/llc/llc_conn.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 5c6d89c..3477624 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -332,8 +332,7 @@ int llc_conn_remove_acked_pdus(struct sock *sk, u8 nr, u16 *how_many_unacked)
 
 	for (i = 0; i < pdu_pos && i < q_len; i++) {
 		skb = skb_dequeue(&llc->pdu_unack_q);
-		if (skb)
-			kfree_skb(skb);
+		kfree_skb(skb);
 		nbr_acked++;
 	}
 out:
-- 
1.5.3.8




