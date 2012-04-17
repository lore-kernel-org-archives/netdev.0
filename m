From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.
Date: Tue, 17 Apr 2012 13:33:31 +0800
Message-ID: <201204171333149372727@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "eric.dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:32768 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab2DQFci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 01:32:38 -0400
Received: by pbcun15 with SMTP id un15so7212210pbc.19
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 22:32:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From fe9ae7e12cc7bdc56705eb504facb71aa86dfe65 Mon Sep 17 00:00:00 2001
From: majianpeng <majianpeng@gmail.com>
Date: Tue, 17 Apr 2012 13:29:55 +0800
Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.


Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 167ea10..dd15648 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3505,6 +3505,6 @@ int __init ip_rt_init(void)
  */
 void __init ip_static_sysctl_init(void)
 {
-	register_sysctl_paths(ipv4_path, ipv4_skeleton);
+	kmemleak_not_leak(register_sysctl_paths(ipv4_path, ipv4_skeleton));
 }
 #endif
-- 
1.7.5.4

 				
--------------
majianpeng
2012-04-17
