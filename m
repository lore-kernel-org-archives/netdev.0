From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter : xt_u32 bug correction
Date: Tue, 14 Aug 2007 14:20:24 +0200
Message-ID: <20070814142024.56af05b2.dada1@cosmosbay.com>
References: <20070814141733.1a0e37f8.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jengelh@gmx.de
To: "kaber@trash.net" <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41754 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756832AbXHNMUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 08:20:25 -0400
In-Reply-To: <20070814141733.1a0e37f8.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

This applies to net-2.6 (so should be forwared to Linus for 2.6.23 inclusion ?)
Sorry for the first mail without attachment.

Thank you

[PATCH] netfilter : xt_u32 bug correction

An extraneous ";" makes xt_u32 match useless

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index 04b677a..89b2d5c 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -35,7 +35,7 @@ static bool u32_match_it(const struct xt_u32 *data,
 		at  = 0;
 		pos = ct->location[0].number;
 
-		if (skb->len < 4 || pos > skb->len - 4);
+		if (skb->len < 4 || pos > skb->len - 4)
 			return false;
 
 		ret   = skb_copy_bits(skb, pos, &val, sizeof(val));
