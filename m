From: Chun Long <long.chun@zte.com.cn>
Subject: [PATCH] tcp_westwood: fix tcp_westwood_info() style mistakes
Date: Tue, 14 Mar 2017 15:26:24 +0800
Message-ID: <1489476384-16892-1-git-send-email-long.chun@zte.com.cn>
Cc: netdev@vger.kernel.org, zhong.weidong@zte.com.cn,
        wang.liang82@zte.com.cn, jiang.biao2@zte.com.cn, cai.qu@zte.com.cn,
        long.chun@zte.com.cn
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.zte.com.cn ([202.103.147.172]:40011 "EHLO out1.zte.com.cn"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750783AbdCNHTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 03:19:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chun Long <long.chun@zte.com.cn>

replace comma to semi colons in tcp_westwood_info().

---
 net/ipv4/tcp_westwood.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index fed66dc..9775453 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -265,8 +265,8 @@ static size_t tcp_westwood_info(struct sock *sk, u32 ext, int *attr,
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
 		info->vegas.tcpv_enabled = 1;
 		info->vegas.tcpv_rttcnt	= 0;
-		info->vegas.tcpv_rtt	= jiffies_to_usecs(ca->rtt),
-		info->vegas.tcpv_minrtt	= jiffies_to_usecs(ca->rtt_min),
+		info->vegas.tcpv_rtt	= jiffies_to_usecs(ca->rtt);
+		info->vegas.tcpv_minrtt	= jiffies_to_usecs(ca->rtt_min);
 
 		*attr = INET_DIAG_VEGASINFO;
 		return sizeof(struct tcpvegas_info);
-- 
1.8.3.1
