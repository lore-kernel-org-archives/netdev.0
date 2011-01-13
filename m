From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sched: remove unused backlog in RED stats
Date: Wed, 12 Jan 2011 17:42:32 -0800
Message-ID: <20110112174232.05d9429d@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38292 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756582Ab1AMBmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 20:42:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RED statistics structure includes backlog field which is not
set or used by any code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/red.h	2011-01-12 15:04:13.146731266 -0800
+++ b/include/net/red.h	2011-01-12 15:04:19.050731266 -0800
@@ -97,7 +97,6 @@ struct red_stats {
 	u32		forced_mark;	/* Forced marks, qavg > max_thresh */
 	u32		pdrop;          /* Drops due to queue limits */
 	u32		other;          /* Drops due to drop() calls */
-	u32		backlog;
 };
 
 struct red_parms {
