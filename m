From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/17] netfilter: nfnetlink_log: just returns error for unknown command
Date: Fri,  8 Jan 2016 15:02:14 +0100
Message-ID: <1452261737-7475-15-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54138 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755272AbcAHODc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:03:32 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 30127DA893
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1EAFEEBAF3
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:28 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3D7F1EBAF3
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:23 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch stops processing options for unknown command.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 6a57f10..8ca9320 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -888,7 +888,7 @@ static int nfulnl_recv_config(struct net *net, struct sock *ctnl,
 			goto out_put;
 		default:
 			ret = -ENOTSUPP;
-			break;
+			goto out_put;
 		}
 	} else if (!inst) {
 		ret = -ENODEV;
-- 
2.1.4
