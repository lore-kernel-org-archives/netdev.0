From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 2/3] Incomplete type for struct in6_addr
Date: Wed,  7 Oct 2009 23:34:41 +0200
Message-ID: <1254951282-5056-3-git-send-email-hagen@jauu.net>
References: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35217 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753774AbZJGVod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 17:44:33 -0400
In-Reply-To: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if_tunnel.h defines a new struct consisting of struct in6_addr,
but the definition is defined in linux/in6.h - so we must
include them beforehand.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/linux/if_tunnel.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index c53c8e0..8d76cb4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -5,6 +5,7 @@
 
 #ifdef __KERNEL__
 #include <linux/ip.h>
+#include <linux/in6.h>
 #endif
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
-- 
1.6.3.GIT

