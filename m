From: Chen Weilong <chenweilong@huawei.com>
Subject: [PATCH] packet: fix "foo * bar" and "(foo*)" problems
Date: Mon, 23 Dec 2013 11:31:38 +0800
Message-ID: <1387769498-15392-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5787 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab3LWDcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 22:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Cleanup checkpatch errors.Specially,the second changed line
is exactly 80 columns long.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/packet/af_packet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index dd38408..279467b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1356,9 +1356,9 @@ static void __fanout_unlink(struct sock *sk, struct packet_sock *po)
 	spin_unlock(&f->lock);
 }
 
-static bool match_fanout_group(struct packet_type *ptype, struct sock * sk)
+static bool match_fanout_group(struct packet_type *ptype, struct sock *sk)
 {
-	if (ptype->af_packet_priv == (void*)((struct packet_sock *)sk)->fanout)
+	if (ptype->af_packet_priv == (void *)((struct packet_sock *)sk)->fanout)
 		return true;
 
 	return false;
-- 
1.7.12
