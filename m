From: David Miller <davem@davemloft.net>
Subject: [PATCH 05/16] net: Kill set_dst_metric_rtt().
Date: Tue, 10 Jul 2012 08:07:19 -0700 (PDT)
Message-ID: <20120710.080719.568924863515679282.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab2GJPHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:20 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 547C3586620
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index b2634e4..5161046 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -209,12 +209,6 @@ static inline unsigned long dst_metric_rtt(const struct dst_entry *dst, int metr
 	return msecs_to_jiffies(dst_metric(dst, metric));
 }
 
-static inline void set_dst_metric_rtt(struct dst_entry *dst, int metric,
-				      unsigned long rtt)
-{
-	dst_metric_set(dst, metric, jiffies_to_msecs(rtt));
-}
-
 static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {
-- 
1.7.10.4
