From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 096/115] sysctl: net/ipv6/neigh: create empty dir with register_sysctl_dir
Date: Mon,  9 May 2011 00:39:48 +0200
Message-ID: <1304894407-32201-97-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv6/sysctl_net_ipv6.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 1d2d8c7..bb57ab4 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,8 +15,6 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-static struct ctl_table empty[1];
-
 static ctl_table ipv6_bindv6only_template[] = {
 	{
 		.procname	= "bindv6only",
@@ -173,7 +171,7 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_neigh_path, empty);
+	ip6_base = register_sysctl_dir(net_ipv6_neigh_path);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
-- 
1.7.5.134.g1c08b
