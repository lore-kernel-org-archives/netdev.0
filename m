From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] unsigned long => __be32 in icmp_redirect()
Date: Sun, 28 May 2006 01:29:25 +0400
Message-ID: <20060527212925.GC7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:13527 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964929AbWE0V3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 17:29:00 -0400
Received: by nf-out-0910.google.com with SMTP id o25so12067nfa
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 14:28:59 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_rt_redirect() expects __be32 as second arg, so...

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipv4/icmp.c
+++ 1/net/ipv4/icmp.c
@@ -730,7 +730,7 @@ out_err:
 static void icmp_redirect(struct sk_buff *skb)
 {
 	struct iphdr *iph;
-	unsigned long ip;
+	__be32 ip;
 
 	if (skb->len < sizeof(struct iphdr))
 		goto out_err;

