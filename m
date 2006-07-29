From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 13/23] [PATCH] [XFRM]: Expand XFRM_MAX_DEPTH for routing header and destination options header.
Date: Sat, 29 Jul 2006 18:30:36 +0900
Message-ID: <1154165436814-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:24195 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S932602AbWG2Jah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:37 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XFRM_MAX_DEPTH is a limit of transformation states to be applied to the same
flow. Two extension headers are used by Mobile IPv6 transformation.
Based on MIPL2 kernel patch.
---
 include/net/xfrm.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index de62a8f..67fe834 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -327,7 +327,11 @@ struct xfrm_tmpl
 	__u32			calgos;
 };
 
+#ifdef CONFIG_XFRM_ADVANCED
+#define XFRM_MAX_DEPTH		6
+#else
 #define XFRM_MAX_DEPTH		4
+#endif
 
 struct xfrm_policy
 {
-- 
1.4.1

