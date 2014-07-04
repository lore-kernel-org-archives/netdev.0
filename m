From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] appletalk: fix a coccinella warning in net/appletalk/ddp.c
Date: Fri, 4 Jul 2014 15:29:48 +0800
Message-ID: <53B657EC.6060105@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: <acme@ghostprotocols.net>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:2568 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbaGDH37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 03:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This warning is introduced by commit 7b30600cc6 ("appletalk:
fix checkpatch error with indent"), So fix it.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/appletalk/ddp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 01a1082..8ceabc0 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1808,7 +1808,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		long amount = 0;
 
 		if (skb)
-		amount = skb->len - sizeof(struct ddpehdr);
+			amount = skb->len - sizeof(struct ddpehdr);
 		rc = put_user(amount, (int __user *)argp);
 		break;
 	}
-- 
1.7.12
