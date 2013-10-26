From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 1/5] 6lowpan: remove unnecessary ret variable
Date: Sat, 26 Oct 2013 15:53:58 +0200
Message-ID: <1382795642-12501-2-git-send-email-alex.aring@gmail.com>
References: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	dbaryshkov@gmail.com, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:33187 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab3JZNyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 09:54:19 -0400
Received: by mail-ea0-f177.google.com with SMTP id f15so1264854eak.36
        for <netdev@vger.kernel.org>; Sat, 26 Oct 2013 06:54:18 -0700 (PDT)
In-Reply-To: <1382795642-12501-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reviewed-by: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index ff41b4d..d288035 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1120,7 +1120,7 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 			int mlen, int plen, int offset, int type)
 {
 	struct sk_buff *frag;
-	int hlen, ret;
+	int hlen;
 
 	hlen = (type == LOWPAN_DISPATCH_FRAG1) ?
 			LOWPAN_FRAG1_HEAD_SIZE : LOWPAN_FRAGN_HEAD_SIZE;
@@ -1145,9 +1145,7 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 	lowpan_raw_dump_table(__func__, " raw fragment dump", frag->data,
 								frag->len);
 
-	ret = dev_queue_xmit(frag);
-
-	return ret;
+	return dev_queue_xmit(frag);
 }
 
 static int
-- 
1.8.4.1
