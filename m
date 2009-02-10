From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net: Kill skbuff macros from the stone ages.
Date: Tue, 10 Feb 2009 00:06:30 -0800 (PST)
Message-ID: <20090210.000630.194774286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59357
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751387AbZBJIGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:06:36 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DEBDFC8D94E
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:06:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've commited the following to net-next-2.6

net: Kill skbuff macros from the stone ages.

This kills of HAVE_ALLOC_SKB and HAVE_ALIGNABLE_SKB.

Nothing in-tree uses them and nothing in-tree has used them
since 2.0.x times.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5eba400..9247008 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,9 +29,6 @@
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
 
-#define HAVE_ALLOC_SKB		/* For the drivers to know */
-#define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
-
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
 #define CHECKSUM_UNNECESSARY 1
-- 
1.6.1.2.253.ga34a

