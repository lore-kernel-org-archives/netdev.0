From: roy.qing.li@gmail.com
Subject: [PATCH net-next] Documentation: fix neigh/default/gc_thresh1 default value.
Date: Fri, 15 Mar 2013 16:49:47 +0800
Message-ID: <1363337387-9536-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:49137 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821Ab3COI5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 04:57:03 -0400
Received: by mail-yh0-f53.google.com with SMTP id q3so539919yhf.12
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 01:57:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The default value is 128, not 256
	#grep gc_thresh1 net/ -rI
	net/decnet/dn_neigh.c:	.gc_thresh1 =			128,
	net/ipv6/ndisc.c:	.gc_thresh1 =	 128,
	net/ipv4/arp.c:	.gc_thresh1	= 128,

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 Documentation/networking/ip-sysctl.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1cae6c3..18a24c4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -29,7 +29,7 @@ route/max_size - INTEGER
 neigh/default/gc_thresh1 - INTEGER
 	Minimum number of entries to keep.  Garbage collector will not
 	purge entries if there are fewer than this number.
-	Default: 256
+	Default: 128
 
 neigh/default/gc_thresh3 - INTEGER
 	Maximum number of neighbor entries allowed.  Increase this
-- 
1.7.10.4
