From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] neigh: remove next ptr from struct neigh_table
Date: Tue, 23 Dec 2014 17:50:37 +0100
Message-ID: <1419353437-4213-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35934 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754789AbaLWQup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 11:50:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit
d7480fd3b173 ("neigh: remove dynamic neigh table registration support"),
this field is not used anymore.

CC: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/neighbour.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index eb070b3674a1..76f708486aae 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -190,7 +190,6 @@ struct neigh_hash_table {
 
 
 struct neigh_table {
-	struct neigh_table	*next;
 	int			family;
 	int			entry_size;
 	int			key_len;
-- 
2.1.0
