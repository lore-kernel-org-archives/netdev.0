From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Remove bogus barrier() in dst_allfrag().
Date: Tue, 08 Feb 2011 15:34:16 -0800 (PST)
Message-ID: <20110208.153416.179933668.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755786Ab1BHXdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 18:33:41 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id D22BD24C088
	for <netdev@vger.kernel.org>; Tue,  8 Feb 2011 15:34:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I simply missed this one when modifying the other dst
metric interfaces earlier.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Committed to net-next-2.6

 include/net/dst.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e550195..e01855d 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -220,8 +220,6 @@ static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {
 	int ret = dst_feature(dst,  RTAX_FEATURE_ALLFRAG);
-	/* Yes, _exactly_. This is paranoia. */
-	barrier();
 	return ret;
 }
 
-- 
1.7.4

