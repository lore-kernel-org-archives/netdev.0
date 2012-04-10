From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] net/ipv6/ipv6_sockglue.c: Removed redundant extern
Date: Tue, 10 Apr 2012 20:51:27 +0200
Message-ID: <1334083887-5375-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

extern int sysctl_mld_max_msf is already defined in linux/ipv6.h.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/ipv6_sockglue.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 63dd1f8..ca1af07 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -678,7 +678,6 @@ done:
 	}
 	case MCAST_MSFILTER:
 	{
-		extern int sysctl_mld_max_msf;
 		struct group_filter *gsf;
 
 		if (optlen < GROUP_FILTER_SIZE(0))
-- 
1.7.9.5
