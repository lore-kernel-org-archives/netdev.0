From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 5/5] sctp: fix checkpatch errors with //commen
Date: Thu, 19 Dec 2013 14:52:02 +0800
Message-ID: <1387435922-24152-6-git-send-email-wangweidong1@huawei.com>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:35358 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab3LSGxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 01:53:13 -0500
In-Reply-To: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2df5564..adc5e37 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3924,7 +3924,7 @@ static int sctp_init_sock(struct sock *sk)
 	 */
 	sp->hbinterval  = net->sctp.hb_interval;
 	sp->pathmaxrxt  = net->sctp.max_retrans_path;
-	sp->pathmtu     = 0; // allow default discovery
+	sp->pathmtu     = 0; /* allow default discovery */
 	sp->sackdelay   = net->sctp.sack_timeout;
 	sp->sackfreq	= 2;
 	sp->param_flags = SPP_HB_ENABLE |
-- 
1.7.12
