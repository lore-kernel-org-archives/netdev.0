From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/5] net: Remove linux/prefetch.h include from
 linux/skbuff.h
Date: Sun, 22 May 2011 20:58:23 -0400 (EDT)
Message-ID: <20110522.205823.400172440509453897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab1EWA6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:58:25 -0400
Received: from localhost (cpe-66-108-115-211.nyc.res.rr.com [66.108.115.211])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4N0wNZV005609
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:58:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 09901fd..8cac356 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -28,7 +28,6 @@
 #include <net/checksum.h>
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
-#include <linux/prefetch.h>
 #include <linux/hrtimer.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
-- 
1.7.4.4

