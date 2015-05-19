From: Andy Zhou <azhou@nicira.com>
Subject: [PATCH] ip: remove unused function prototype
Date: Tue, 19 May 2015 12:41:47 -0700
Message-ID: <1432064507-925-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:56309 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750750AbbESUDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:03:12 -0400
Received: by mail-pa0-f50.google.com with SMTP id bw4so37857339pad.0
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 13:03:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_do_nat() function was removed prior to kernel 3.4. Remove the
unnecessary function prototype as well.

Reported-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index cd7a6a4..7921a36 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -110,7 +110,6 @@ int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 		   int (*output)(struct sock *, struct sk_buff *));
-int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
-- 
1.9.1
