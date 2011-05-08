From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 095/115] sysctl: net/ipv4/neigh: create empty dir with register_sysctl_dir
Date: Mon,  9 May 2011 00:39:47 +0200
Message-ID: <1304894407-32201-96-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47346 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932685Ab1EHWmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:42:20 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/route.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 46c7b3d..092f3d1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3151,8 +3151,6 @@ static ctl_table ipv4_route_table[] = {
 	{ }
 };
 
-static struct ctl_table empty[1];
-
 static __net_initdata struct ctl_path ipv4_neigh_path[] = {
 	{ .procname = "net", },
 	{ .procname = "ipv4", },
@@ -3310,6 +3308,6 @@ int __init ip_rt_init(void)
 void __init ip_static_sysctl_init(void)
 {
 	register_sysctl_paths(ipv4_route_path, ipv4_route_table);
-	register_sysctl_paths(ipv4_neigh_path, empty);
+	register_sysctl_dir(ipv4_neigh_path);
 }
 #endif
-- 
1.7.5.134.g1c08b

