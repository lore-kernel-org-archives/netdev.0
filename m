From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] net: ethernet: Fix double word "the the" in eth.c
Date: Thu,  6 Aug 2015 21:27:54 +0900
Message-ID: <1438864074-3083-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: davem@davemloft.net, trivial@kernel.org, netdev@vger.kernel.org,
	corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35956 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbbHFM1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 08:27:42 -0400
Received: by pacrr5 with SMTP id rr5so26801304pac.3
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 05:27:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix double word "the the" in
Documentation/DocBook/networking/API-eth-get-headlen.html
Documentation/DocBook/networking/netdev.html
Documentation/DocBook/networking.xml

These files are generated from comment in source,
so I have to fix comment in net/ethernet/eth.c.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/ethernet/eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 77e0f0e..217127c 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -114,7 +114,7 @@ int eth_header(struct sk_buff *skb, struct net_device *dev,
 EXPORT_SYMBOL(eth_header);
 
 /**
- * eth_get_headlen - determine the the length of header for an ethernet frame
+ * eth_get_headlen - determine the length of header for an ethernet frame
  * @data: pointer to start of frame
  * @len: total length of frame
  *
-- 
2.5.0
