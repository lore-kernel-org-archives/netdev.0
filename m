From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next] ipvs: fix the IPVS_CMD_ATTR_MAX definition
Date: Fri, 30 Aug 2013 18:21:56 +0900
Message-ID: <1377854516-24383-2-git-send-email-horms@verge.net.au>
References: <1377854516-24383-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44386 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053Ab3H3JWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 05:22:01 -0400
In-Reply-To: <1377854516-24383-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

It was wrong (bigger) but problem is harmless.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/uapi/linux/ip_vs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
index 2945822..fbcffe8 100644
--- a/include/uapi/linux/ip_vs.h
+++ b/include/uapi/linux/ip_vs.h
@@ -334,7 +334,7 @@ enum {
 	__IPVS_CMD_ATTR_MAX,
 };
 
-#define IPVS_CMD_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)
+#define IPVS_CMD_ATTR_MAX (__IPVS_CMD_ATTR_MAX - 1)
 
 /*
  * Attributes used to describe a service
-- 
1.8.4
