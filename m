From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH net-next 2/4] ipv6: fix checkpatch errors with brace and "foo *bar"
Date: Mon, 17 Feb 2014 16:53:33 +0800
Message-ID: <1392627215-12804-2-git-send-email-wangyufen@huawei.com>
References: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:1203 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaBQIxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:53:55 -0500
In-Reply-To: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/addrlabel.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index b30ad37..86829d3 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -28,8 +28,7 @@
 /*
  * Policy Table
  */
-struct ip6addrlbl_entry
-{
+struct ip6addrlbl_entry {
 #ifdef CONFIG_NET_NS
 	struct net *lbl_net;
 #endif
@@ -527,7 +526,7 @@ static inline int ip6addrlbl_msgsize(void)
 		+ nla_total_size(4);	/* IFAL_LABEL */
 }
 
-static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh)
+static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrlblmsg *ifal;
-- 
1.7.12
