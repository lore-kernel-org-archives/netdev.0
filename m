From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] ip-link: remove warning message
Date: Thu, 21 Jan 2016 02:23:49 +0000
Message-ID: <1453343029-14580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3370 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060AbcAUCcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:32:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the warning was:
iproute.c:301:12: warning: 'val' may be used uninitialized in this
function [-Wmaybe-uninitialized]
   features &= ~RTAX_FEATURE_ECN;
            ^
iproute.c:575:10: note: 'val' was declared here
   __u32 val;
	  ^

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index d5e3ebe..afe70e1 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -572,7 +572,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			mxlock = *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
 
 		for (i=2; i<= RTAX_MAX; i++) {
-			__u32 val;
+			__u32 val = 0U;
 
 			if (mxrta[i] == NULL)
 				continue;
-- 
1.8.3.1
