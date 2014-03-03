From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 -next 1/3] ipxfrm: prepares update of include/linux/xfrm.h
Date: Mon,  3 Mar 2014 15:36:05 +0100
Message-ID: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55421 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057AbaCCOgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:36:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'struct xfrm_filter' is now defined by the kernel API. Let's rename the one
defined in iproute2 to 'struct ipxfrm_filter'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipxfrm.c | 2 +-
 ip/xfrm.h   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index cce51518170c..ff6cb2c2dda5 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -53,7 +53,7 @@
 		} \
 	} while(0);
 
-struct xfrm_filter filter;
+struct ipxfrm_filter filter;
 
 static void usage(void) __attribute__((noreturn));
 
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 773c92e99e9e..31cc89a0f19a 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -74,7 +74,7 @@ struct xfrm_buffer {
 	struct rtnl_handle *rth;
 };
 
-struct xfrm_filter {
+struct ipxfrm_filter {
 	int use;
 
 	struct xfrm_usersa_info xsinfo;
@@ -105,7 +105,7 @@ struct xfrm_filter {
 };
 #define XFRM_FILTER_MASK_FULL (~0)
 
-extern struct xfrm_filter filter;
+extern struct ipxfrm_filter filter;
 
 int xfrm_state_print(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		     void *arg);
-- 
1.8.5.4
