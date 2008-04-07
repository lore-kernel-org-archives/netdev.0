From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] Fix kernel-doc for skb_segment
Date: Mon, 7 Apr 2008 19:28:45 +0100
Message-ID: <20080407182844.GP21637@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:34851 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750975AbYDGS2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 14:28:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel-doc comment for skb_segment is clearly wrong.  This states what
it actually does.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0d0fd28..6087013 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2131,8 +2131,8 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
  *	@features: features for the output path (see dev->features)
  *
  *	This function performs segmentation on the given skb.  It returns
- *	the segment at the given position.  It returns NULL if there are
- *	no more segments to generate, or when an error is encountered.
+ *	a pointer to the first in a list of new skbs for the segments.
+ *	In case of error it returns ERR_PTR(err).
  */
 struct sk_buff *skb_segment(struct sk_buff *skb, int features)
 {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
