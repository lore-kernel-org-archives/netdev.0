From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/5] ipv6: silence tunnel loading messages
Date: Fri, 29 Aug 2014 00:09:21 -0700
Message-ID: <20140829071031.802063934@networkplumber.org>
References: <20140829070918.508987897@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49931 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728AbaH2HKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 03:10:34 -0400
Received: by mail-pa0-f51.google.com with SMTP id rd3so5785803pab.24
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 00:10:33 -0700 (PDT)
Content-Disposition: inline; filename=ipv6-dbg-msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chatter on boot is not necessary, change it to debug.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv6/ip6_gre.c	2014-08-25 15:06:29.711056058 -0700
+++ b/net/ipv6/ip6_gre.c	2014-08-25 15:06:29.707056037 -0700
@@ -1678,7 +1678,7 @@ static int __init ip6gre_init(void)
 {
 	int err;
 
-	pr_info("GRE over IPv6 tunneling driver\n");
+	pr_debug("GRE over IPv6 tunneling driver\n");
 
 	err = register_pernet_device(&ip6gre_net_ops);
 	if (err < 0)
--- a/net/ipv6/mip6.c	2014-08-25 15:06:29.711056058 -0700
+++ b/net/ipv6/mip6.c	2014-08-25 15:06:29.707056037 -0700
@@ -482,7 +482,7 @@ static const struct xfrm_type mip6_rthdr
 
 static int __init mip6_init(void)
 {
-	pr_info("Mobile IPv6\n");
+	pr_debug("Mobile IPv6\n");
 
 	if (xfrm_register_type(&mip6_destopt_type, AF_INET6) < 0) {
 		pr_info("%s: can't add xfrm type(destopt)\n", __func__);
--- a/net/ipv6/sit.c	2014-08-25 15:06:29.711056058 -0700
+++ b/net/ipv6/sit.c	2014-08-25 15:06:29.707056037 -0700
@@ -1796,7 +1796,7 @@ static int __init sit_init(void)
 {
 	int err;
 
-	pr_info("IPv6 over IPv4 tunneling driver\n");
+	pr_debug("IPv6 over IPv4 tunneling driver\n");
 
 	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
