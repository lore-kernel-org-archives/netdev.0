From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 3/4] ipv6: fix checkpatch errors with space required or prohibited
Date: Mon, 17 Feb 2014 16:53:34 +0800
Message-ID: <1392627215-12804-3-git-send-email-wangyufen@huawei.com>
References: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:3354 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbaBQIzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:55:55 -0500
In-Reply-To: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/addrlabel.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 86829d3..d702406 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -6,7 +6,7 @@
  */
 /*
  * Author:
- * 	YOSHIFUJI Hideaki @ USAGI/WIDE Project <yoshfuji@linux-ipv6.org>
+ *	YOSHIFUJI Hideaki @ USAGI/WIDE Project <yoshfuji@linux-ipv6.org>
  */
 
 #include <linux/kernel.h>
@@ -22,7 +22,7 @@
 #if 0
 #define ADDRLABEL(x...) printk(x)
 #else
-#define ADDRLABEL(x...) do { ; } while(0)
+#define ADDRLABEL(x...) do { ; } while (0)
 #endif
 
 /*
@@ -87,39 +87,39 @@ static const __net_initconst struct ip6addrlbl_init_table
 	{	/* ::/0 */
 		.prefix = &in6addr_any,
 		.label = 1,
-	},{	/* fc00::/7 */
-		.prefix = &(struct in6_addr){{{ 0xfc }}},
+	}, {	/* fc00::/7 */
+		.prefix = &(struct in6_addr){ { { 0xfc } } } ,
 		.prefixlen = 7,
 		.label = 5,
-	},{	/* fec0::/10 */
-		.prefix = &(struct in6_addr){{{ 0xfe, 0xc0 }}},
+	}, {	/* fec0::/10 */
+		.prefix = &(struct in6_addr){ { { 0xfe, 0xc0 } } },
 		.prefixlen = 10,
 		.label = 11,
-	},{	/* 2002::/16 */
-		.prefix = &(struct in6_addr){{{ 0x20, 0x02 }}},
+	}, {	/* 2002::/16 */
+		.prefix = &(struct in6_addr){ { { 0x20, 0x02 } } },
 		.prefixlen = 16,
 		.label = 2,
-	},{	/* 3ffe::/16 */
-		.prefix = &(struct in6_addr){{{ 0x3f, 0xfe }}},
+	}, {	/* 3ffe::/16 */
+		.prefix = &(struct in6_addr){ { { 0x3f, 0xfe } } },
 		.prefixlen = 16,
 		.label = 12,
-	},{	/* 2001::/32 */
-		.prefix = &(struct in6_addr){{{ 0x20, 0x01 }}},
+	}, {	/* 2001::/32 */
+		.prefix = &(struct in6_addr){ { { 0x20, 0x01 } } },
 		.prefixlen = 32,
 		.label = 6,
-	},{	/* 2001:10::/28 */
-		.prefix = &(struct in6_addr){{{ 0x20, 0x01, 0x00, 0x10 }}},
+	}, {	/* 2001:10::/28 */
+		.prefix = &(struct in6_addr){ { { 0x20, 0x01, 0x00, 0x10 } } },
 		.prefixlen = 28,
 		.label = 7,
-	},{	/* ::ffff:0:0 */
-		.prefix = &(struct in6_addr){{{ [10] = 0xff, [11] = 0xff }}},
+	}, {	/* ::ffff:0:0 */
+		.prefix = &(struct in6_addr){ { { [10] = 0xff, [11] = 0xff } } },
 		.prefixlen = 96,
 		.label = 4,
-	},{	/* ::/96 */
+	}, {	/* ::/96 */
 		.prefix = &in6addr_any,
 		.prefixlen = 96,
 		.label = 3,
-	},{	/* ::1/128 */
+	}, {	/* ::1/128 */
 		.prefix = &in6addr_loopback,
 		.prefixlen = 128,
 		.label = 0,
@@ -440,7 +440,7 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (label == IPV6_ADDR_LABEL_DEFAULT)
 		return -EINVAL;
 
-	switch(nlh->nlmsg_type) {
+	switch (nlh->nlmsg_type) {
 	case RTM_NEWADDRLABEL:
 		if (ifal->ifal_index &&
 		    !__dev_get_by_index(net, ifal->ifal_index))
-- 
1.7.12
