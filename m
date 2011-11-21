From: Feng King <kinwin2008@gmail.com>
Subject: [PATCH] net: correct comments of skb_shift
Date: Mon, 21 Nov 2011 19:47:11 +0800
Message-ID: <1321876031-2543-1-git-send-email-kinwin2008@gmail.com>
Cc: netdev@vger.kernel.org, Feng King <kinwin2008@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58647 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab1KULrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 06:47:20 -0500
Received: by iage36 with SMTP id e36so7168378iag.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 03:47:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when skb_shift, we want to shift paged data from skb to tgt frag area.
Original comments revert the shift order

Signed-off-by: Feng King <kinwin2008@gmail.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 387703f..ed6e992 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2211,7 +2211,7 @@ static int skb_prepare_for_shift(struct sk_buff *skb)
  * @shiftlen: shift up to this many bytes
  *
  * Attempts to shift up to shiftlen worth of bytes, which may be less than
- * the length of the skb, from tgt to skb. Returns number bytes shifted.
+ * the length of the skb, from skb to tgt. Returns number bytes shifted.
  * It's up to caller to free skb if everything was shifted.
  *
  * If @tgt runs out of frags, the whole operation is aborted.
-- 
1.7.1
