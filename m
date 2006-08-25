From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] tcp_lp: use BUILD_BUG_ON
Date: Fri, 25 Aug 2006 05:08:31 +0400
Message-ID: <20060825010831.GL5204@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:32876 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1030493AbWHYBIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 21:08:36 -0400
Received: by ug-out-1314.google.com with SMTP id m3so685875ugc
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 18:08:35 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/tcp_lp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -321,7 +321,7 @@ static struct tcp_congestion_ops tcp_lp 
 
 static int __init tcp_lp_register(void)
 {
-	BUG_ON(sizeof(struct lp) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct lp) > ICSK_CA_PRIV_SIZE);
 	return tcp_register_congestion_control(&tcp_lp);
 }
 

