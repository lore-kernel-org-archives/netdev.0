From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] bridge: use MDBA_SET_ENTRY_MAX for maxtype in nlmsg_parse()
Date: Thu, 15 Jan 2015 16:29:12 +0100
Message-ID: <1421335752-25204-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49217 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821AbbAOP3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 10:29:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is just a cleanup, because in the current code MDBA_SET_ENTRY_MAX ==
MDBA_SET_ENTRY.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/bridge/br_mdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 5df05269d17a..fed61c971b17 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -276,7 +276,7 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net_device *dev;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*bpm), tb, MDBA_SET_ENTRY, NULL);
+	err = nlmsg_parse(nlh, sizeof(*bpm), tb, MDBA_SET_ENTRY_MAX, NULL);
 	if (err < 0)
 		return err;
 
-- 
2.2.2
