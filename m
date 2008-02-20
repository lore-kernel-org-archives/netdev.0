From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] sungem: remove superfluous variable
Date: Wed, 20 Feb 2008 12:37:47 +0100
Message-ID: <1203507467.17534.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60441 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646AbYBTScm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 13:32:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to have two variables called 'i' when one
suffices.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/sungem.c |    1 -
 1 file changed, 1 deletion(-)

--- everything.orig/drivers/net/sungem.c	2008-02-20 12:35:12.000000000 +0100
+++ everything/drivers/net/sungem.c	2008-02-20 12:35:15.000000000 +0100
@@ -1831,7 +1831,6 @@ static u32 gem_setup_multicast(struct ge
 		u16 hash_table[16];
 		u32 crc;
 		struct dev_mc_list *dmi = gp->dev->mc_list;
-		int i;
 
 		for (i = 0; i < 16; i++)
 			hash_table[i] = 0;


