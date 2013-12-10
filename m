From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 6/6] net_sched: make macro be enclosed in parenthesis
Date: Tue, 10 Dec 2013 20:55:34 +0800
Message-ID: <1386680134-85452-7-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:5192 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab3LJMzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:50 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macros with complex values should be enclosed in parenthesis

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/em_meta.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index e5cef956..852cd62 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -272,10 +272,12 @@ META_COLLECTOR(int_rtiif)
  **************************************************************************/
 
 #define SKIP_NONLOCAL(skb)			\
+({						\
 	if (unlikely(skb->sk == NULL)) {	\
 		*err = -1;			\
 		return;				\
-	}
+	}					\
+})
 
 META_COLLECTOR(int_sk_family)
 {
-- 
1.8.0
