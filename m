From: "majianpeng" <majianpeng@gmail.com>
Subject: [PATCH] net/core:Remove  memleak reports bykmemeleak_not_leak.
Date: Tue, 17 Apr 2012 13:58:28 +0800
Message-ID: <201204171358252962638@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "davem" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:57886 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815Ab2DQF5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 01:57:32 -0400
Received: by dake40 with SMTP id e40so7898860dak.11
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 22:57:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 40131df5df1850b6d0a653f23698b13047c640ec Mon Sep 17 00:00:00 2001
From: majianpeng <majianpeng@gmail.com>
Date: Tue, 17 Apr 2012 13:55:39 +0800
Subject: [PATCH] net/core:Remove  memleak reports bykmemeleak_not_leak.


Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 net/core/sysctl_net_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0c28508..cee5991 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -256,7 +256,7 @@ static __init int sysctl_core_init(void)
 {
 	static struct ctl_table empty[1];
 
-	register_sysctl_paths(net_core_path, empty);
+	kmemleak_not_leak(register_sysctl_paths(net_core_path, empty));
 	register_net_sysctl_rotable(net_core_path, net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
-- 
1.7.5.4

 				
--------------
majianpeng
2012-04-17
