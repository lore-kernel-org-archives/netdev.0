From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] net/neighbour.h: fix typo
Date: Wed, 30 Jun 2010 20:08:15 +0400
Message-ID: <1277914095-25905-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:38318 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736Ab0F3QhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 12:37:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'Shoul' must be 'should'.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 include/net/neighbour.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index eb21340..242879b 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -151,7 +151,7 @@ struct neigh_table {
 	void			(*proxy_redo)(struct sk_buff *skb);
 	char			*id;
 	struct neigh_parms	parms;
-	/* HACK. gc_* shoul follow parms without a gap! */
+	/* HACK. gc_* should follow parms without a gap! */
 	int			gc_interval;
 	int			gc_thresh1;
 	int			gc_thresh2;
-- 
1.7.0.4

