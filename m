From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] TCP: removal of unused label
Date: Mon, 5 Jun 2006 21:55:49 +0200
Message-ID: <20060605195549.GA14942@electric-eye.fr.zoreil.com>
References: <20060605110331.0f058738@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63625 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751344AbWFET4u
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 15:56:50 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060605110331.0f058738@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/net/ipv4/tcp_compound.c b/net/ipv4/tcp_compound.c
index bc54f7e..a3c36c0 100644
--- a/net/ipv4/tcp_compound.c
+++ b/net/ipv4/tcp_compound.c
@@ -401,6 +401,7 @@ static void tcp_compound_cong_avoid(stru
 static void tcp_compound_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct compound *ca = inet_csk_ca(sk);
+
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
 		struct tcpvegas_info *info;
 
@@ -411,7 +412,6 @@ static void tcp_compound_get_info(struct
 		info->tcpv_rttcnt = ca->cntRTT;
 		info->tcpv_rtt = ca->baseRTT;
 		info->tcpv_minrtt = ca->minRTT;
-	rtattr_failure:;
 	}
 }
 
