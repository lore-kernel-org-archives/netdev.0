From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 4/44] [XFRM]: Expand XFRM_MAX_DEPTH for route optimization.
Date: Thu, 24 Aug 2006 00:02:05 +0900
Message-ID: <11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:55944 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964910AbWHWPCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:49 -0400
To: davem@davemloft.net
In-Reply-To: <1156345365325-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

XFRM_MAX_DEPTH is a limit of transformation states to be applied to the same
flow. Two more extension headers are used by Mobile IPv6 transformation.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 2ad9c1a..c36d603 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -315,7 +315,7 @@ struct xfrm_tmpl
 	__u32			calgos;
 };
 
-#define XFRM_MAX_DEPTH		4
+#define XFRM_MAX_DEPTH		6
 
 struct xfrm_policy
 {
-- 
1.4.0

