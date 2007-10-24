From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make tcp_match_skb_to_sack() static
Date: Wed, 24 Oct 2007 18:23:58 +0200
Message-ID: <20071024162358.GA30533@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33363 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759094AbXJXQX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 12:23:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcp_match_skb_to_sack() can become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
b734b439219a6251b7deb65dad2307f9c891f680 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9288220..603400d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1204,8 +1204,8 @@ static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
  * which may fail and creates some hassle (caller must handle error case
  * returns).
  */
-int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
-			  u32 start_seq, u32 end_seq)
+static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
+				 u32 start_seq, u32 end_seq)
 {
 	int in_sack, err;
 	unsigned int pkt_len;

