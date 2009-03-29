From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] skbuff.h: fix missing kernel-doc
Date: Sat, 28 Mar 2009 21:52:27 -0700
Message-ID: <20090328215227.246b8a88.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36496 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbZC2Exc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 00:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Add missing struct field to fix kernel-doc warning:

Warning(include/linux/skbuff.h:182): No description found for parameter 'flags'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/skbuff.h |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.29-git4.orig/include/linux/skbuff.h
+++ linux-2.6.29-git4/include/linux/skbuff.h
@@ -168,6 +168,7 @@ struct skb_shared_hwtstamps {
  * @software:		generate software time stamp
  * @in_progress:	device driver is going to provide
  *			hardware time stamp
+ * @flags:		all shared_tx flags
  *
  * These flags are attached to packets as part of the
  * &skb_shared_info. Use skb_tx() to get a pointer.
