From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] net: Tyop of sk_filter() comment
Date: Tue, 01 Jul 2008 17:19:21 +0800
Message-ID: <4869F699.8000907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53503 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753451AbYGAJYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2008 05:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parameter "needlock" no long exists.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/net/core/filter.c b/net/core/filter.c
index 4f83697..df37443 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -68,7 +68,6 @@ static inline void *load_pointer(struct sk_buff *skb, int k,
  *	sk_filter - run a packet through a socket filter
  *	@sk: sock associated with &sk_buff
  *	@skb: buffer to filter
- *	@needlock: set to 1 if the sock is not locked by caller.
  *
  * Run the filter code and then cut skb->data to correct size returned by
  * sk_run_filter. If pkt_len is 0 we toss packet. If skb->len is smaller

