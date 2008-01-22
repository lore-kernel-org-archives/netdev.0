From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/12 net-2.6.25] [IPV4]: Declarations cleanup in ip_fib.h.
Date: Tue, 22 Jan 2008 18:59:18 +0300
Message-ID: <1201017566-16985-1-git-send-email-den@openvz.org>
References: <479612BE.8030409@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53749 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752873AbYAVP7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 10:59:24 -0500
In-Reply-To: <479612BE.8030409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small issues fixed:
- fib_select_multipath is exported from fib_semantics.c rather than from
  fib_frontend.c. So, move the declaration below appropriate comment.
- struct rt_entry declaration is not used. Drop it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ip_fib.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index a859124..be70b33 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -222,15 +222,13 @@ extern const struct nla_policy rtm_ipv4_policy[];
 extern void		ip_fib_init(void);
 extern int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			       struct net_device *dev, __be32 *spec_dst, u32 *itag);
-extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
-
-struct rtentry;
 
 /* Exported by fib_semantics.c */
 extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
 extern int fib_sync_down(__be32 local, struct net_device *dev, int force);
 extern int fib_sync_up(struct net_device *dev);
 extern __be32  __fib_res_prefsrc(struct fib_result *res);
+extern void fib_select_multipath(const struct flowi *flp, struct fib_result *res);
 
 /* Exported by fib_{hash|trie}.c */
 extern void fib_hash_init(void);
-- 
1.5.3.rc5

