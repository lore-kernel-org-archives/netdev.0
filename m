From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2 5/5] sctp: fix checkpatch errors with //commen
Date: Mon, 23 Dec 2013 12:16:54 +0800
Message-ID: <1387772214-26068-6-git-send-email-wangweidong1@huawei.com>
References: <1387772214-26068-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29083 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689Ab3LWERc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 23:17:32 -0500
In-Reply-To: <1387772214-26068-1-git-send-email-wangweidong1@huawei.com>
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
