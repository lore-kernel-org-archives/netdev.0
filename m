From: Chen Weilong <chenweilong@huawei.com>
Subject: [resend patch net-next v3 7/7] ipv4: ipv4: Cleanup the comments in tcp_yeah.c
Date: Mon, 23 Dec 2013 14:37:32 +0800
Message-ID: <1387780652-16232-8-git-send-email-chenweilong@huawei.com>
References: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>,
	<netfilter@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19818 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703Ab3LWGi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 01:38:56 -0500
In-Reply-To: <1387780652-16232-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

This cleanup the comments in tcp_yeah.c.
1.The old link is dead,use a new one to instead.
2.'lin' add nothing useful,remove it.
3.do not use C99 // comments.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/tcp_yeah.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 20cfaab..8ed96b4 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -3,7 +3,7 @@
  *   YeAH TCP
  *
  * For further details look at:
- *    http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
+ *   https://web.archive.org/web/20080316215752/http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf 
  *
  */
 #include <linux/mm.h>
@@ -15,13 +15,13 @@
 
 #include "tcp_vegas.h"
 
-#define TCP_YEAH_ALPHA       80 //lin number of packets queued at the bottleneck
-#define TCP_YEAH_GAMMA        1 //lin fraction of queue to be removed per rtt
-#define TCP_YEAH_DELTA        3 //log minimum fraction of cwnd to be removed on loss
-#define TCP_YEAH_EPSILON      1 //log maximum fraction to be removed on early decongestion
-#define TCP_YEAH_PHY          8 //lin maximum delta from base
-#define TCP_YEAH_RHO         16 //lin minimum number of consecutive rtt to consider competition on loss
-#define TCP_YEAH_ZETA        50 //lin minimum number of state switchs to reset reno_count
+#define TCP_YEAH_ALPHA       80 /* number of packets queued at the bottleneck */
+#define TCP_YEAH_GAMMA        1 /* fraction of queue to be removed per rtt */
+#define TCP_YEAH_DELTA        3 /* log minimum fraction of cwnd to be removed on loss */
+#define TCP_YEAH_EPSILON      1 /* log maximum fraction to be removed on early decongestion */
+#define TCP_YEAH_PHY          8 /* maximum delta from base */
+#define TCP_YEAH_RHO         16 /* minimum number of consecutive rtt to consider competition on loss */
+#define TCP_YEAH_ZETA        50 /* minimum number of state switches to reset reno_count */
 
 #define TCP_SCALABLE_AI_CNT	 100U
 
-- 
1.7.12
