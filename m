From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] lwtunnel: export linux/lwtunnel.h to userspace
Date: Thu, 23 Jul 2015 15:43:56 +0200
Message-ID: <1437659036-14282-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49443 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbbGWNoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 09:44:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note also that include/linux/lwtunnel.h is not needed.

CC: Thomas Graf <tgraf@suug.ch>
CC: Roopa Prabhu <roopa@cumulusnetworks.com>
Fixes: 499a24256862 ("lwtunnel: infrastructure for handling light weight tunnels like mpls")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/lwtunnel.h  | 6 ------
 include/uapi/linux/Kbuild | 1 +
 2 files changed, 1 insertion(+), 6 deletions(-)
 delete mode 100644 include/linux/lwtunnel.h

diff --git a/include/linux/lwtunnel.h b/include/linux/lwtunnel.h
deleted file mode 100644
index 97f32f8b4ae1..000000000000
--- a/include/linux/lwtunnel.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _LINUX_LWTUNNEL_H_
-#define _LINUX_LWTUNNEL_H_
-
-#include <uapi/linux/lwtunnel.h>
-
-#endif /* _LINUX_LWTUNNEL_H_ */
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 1ff9942718fe..aafb9937b162 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -243,6 +243,7 @@ header-y += limits.h
 header-y += llc.h
 header-y += loop.h
 header-y += lp.h
+header-y += lwtunnel.h
 header-y += magic.h
 header-y += major.h
 header-y += map_to_7segment.h
-- 
2.4.2
