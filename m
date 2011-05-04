From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/8] dccp: Use flowi4->saddr in dccp_v4_connect()
Date: Wed, 04 May 2011 10:14:46 -0700 (PDT)
Message-ID: <20110504.101446.104063820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49225
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754727Ab1EDRPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:15:19 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id CD13824C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 10:14:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f4254bb..36700a4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -86,7 +86,7 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		daddr = fl4.daddr;
 
 	if (inet->inet_saddr == 0)
-		inet->inet_saddr = rt->rt_src;
+		inet->inet_saddr = fl4.saddr;
 	inet->inet_rcv_saddr = inet->inet_saddr;
 
 	inet->inet_dport = usin->sin_port;
-- 
1.7.4.5

