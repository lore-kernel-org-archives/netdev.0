From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next 1/4] netlink: fix checkpatch errors space and "foo *bar"
Date: Mon, 17 Feb 2014 16:53:32 +0800
Message-ID: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:1610 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbaBQIyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:54:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>

ERROR: spaces required and "(foo*)" should be "(foo *)"

Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/netlink/af_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index fdf5135..e42214b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1460,7 +1460,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	if (nlk->netlink_bind && nlk->groups[0]) {
 		int i;
 
-		for (i=0; i<nlk->ngroups; i++) {
+		for (i = 0; i < nlk->ngroups; i++) {
 			if (test_bit(i, nlk->groups))
 				nlk->netlink_bind(i);
 		}
@@ -2549,7 +2549,7 @@ __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int fla
 	struct nlmsghdr *nlh;
 	int size = nlmsg_msg_size(len);
 
-	nlh = (struct nlmsghdr*)skb_put(skb, NLMSG_ALIGN(size));
+	nlh = (struct nlmsghdr *)skb_put(skb, NLMSG_ALIGN(size));
 	nlh->nlmsg_type = type;
 	nlh->nlmsg_len = size;
 	nlh->nlmsg_flags = flags;
-- 
1.7.12
