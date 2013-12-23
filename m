From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next v2 7/7] ipv4: ERROR: do not use C99 // comments
Date: Mon, 23 Dec 2013 10:14:16 +0800
Message-ID: <1387764856-13948-8-git-send-email-chenweilong@huawei.com>
References: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<pablo@netfilter.org>, <kadlec@blackhole.kfki.hu>,
	<steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45882 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756899Ab3LWCPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 21:15:31 -0500
In-Reply-To: <1387764856-13948-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/ipv4/tcp_yeah.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 20cfaab..aeeae9e 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -15,13 +15,13 @@
 
 #include "tcp_vegas.h"
 
-#define TCP_YEAH_ALPHA       80 //lin number of packets queued at the bottleneck
-#define TCP_YEAH_GAMMA        1 //lin fraction of queue to be removed per rtt
-#define TCP_YEAH_DELTA        3 //log minimum fraction of cwnd to be removed on loss
-#define TCP_YEAH_EPSILON      1 //log maximum fraction to be removed on early decongestion
-#define TCP_YEAH_PHY          8 //lin maximum delta from base
-#define TCP_YEAH_RHO         16 //lin minimum number of consecutive rtt to consider competition on loss
-#define TCP_YEAH_ZETA        50 //lin minimum number of state switchs to reset reno_count
+#define TCP_YEAH_ALPHA       80 /* lin number of packets queued at the bottleneck */
+#define TCP_YEAH_GAMMA        1 /* lin fraction of queue to be removed per rtt */
+#define TCP_YEAH_DELTA        3 /* log minimum fraction of cwnd to be removed on loss */
+#define TCP_YEAH_EPSILON      1 /* log maximum fraction to be removed on early decongestion */
+#define TCP_YEAH_PHY          8 /* lin maximum delta from base */
+#define TCP_YEAH_RHO         16 /* lin minimum number of consecutive rtt to consider competition on loss */
+#define TCP_YEAH_ZETA        50 /* lin minimum number of state switchs to reset reno_count */
 
 #define TCP_SCALABLE_AI_CNT	 100U
 
-- 
1.7.12
