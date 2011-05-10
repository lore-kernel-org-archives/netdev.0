From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/10] sctp: Remove rt->rt_src usage in sctp_v4_get_saddr()
Date: Mon, 09 May 2011 22:31:30 -0700 (PDT)
Message-ID: <20110509.223130.179929947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753762Ab1EJFcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:32:02 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B0C7724C089
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Flow key is available, so fetch it from there.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sctp/protocol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4f270ac..4de77cb 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -566,7 +566,7 @@ static void sctp_v4_get_saddr(struct sctp_sock *sk,
 
 	if (rt) {
 		saddr->v4.sin_family = AF_INET;
-		saddr->v4.sin_addr.s_addr = rt->rt_src;
+		saddr->v4.sin_addr.s_addr = fl->u.ip4.saddr;
 	}
 }
 
-- 
1.7.5.1

