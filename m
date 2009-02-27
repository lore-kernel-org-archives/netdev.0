From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] skbuff.h: fix timestamps kernel-doc
Date: Fri, 27 Feb 2009 10:46:38 -0800
Message-ID: <20090227104638.5b4f8f6e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43064 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138AbZB0Sps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 13:45:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix skbuff.h kernel-doc for timestamps: must include "struct" keyword,
otherwise there are kernel-doc errors:

Error(linux-next-20090227//include/linux/skbuff.h:161): cannot understand prototype: 'struct skb_shared_hwtstamps '
Error(linux-next-20090227//include/linux/skbuff.h:177): cannot understand prototype: 'union skb_shared_tx '

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- linux-next-20090227.orig/include/linux/skbuff.h
+++ linux-next-20090227/include/linux/skbuff.h
@@ -135,8 +135,7 @@ struct skb_frag_struct {
 #define HAVE_HW_TIME_STAMP
 
 /**
- * skb_shared_hwtstamps - hardware time stamps
- *
+ * struct skb_shared_hwtstamps - hardware time stamps
  * @hwtstamp:	hardware time stamp transformed into duration
  *		since arbitrary point in time
  * @syststamp:	hwtstamp transformed to system time base
@@ -164,8 +163,7 @@ struct skb_shared_hwtstamps {
 };
 
 /**
- * skb_shared_tx - instructions for time stamping of outgoing packets
- *
+ * struct skb_shared_tx - instructions for time stamping of outgoing packets
  * @hardware:		generate hardware time stamp
  * @software:		generate software time stamp
  * @in_progress:	device driver is going to provide
