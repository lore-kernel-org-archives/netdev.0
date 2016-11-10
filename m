From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] net: bpqether.h: remove if_ether.h guard
Date: Thu, 10 Nov 2016 13:21:42 +0200
Message-ID: <da8a959ec7a821eb179e5e5b40eff669daf9a338.1478776902.git.baruch@tkos.co.il>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        Baruch Siach <baruch@tkos.co.il>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:53501 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754788AbcKJLWV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 06:22:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__LINUX_IF_ETHER_H is not defined anywhere, and if_ether.h can keep itself from
double inclusion, though it uses a single underscore prefix.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 include/uapi/linux/bpqether.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/uapi/linux/bpqether.h b/include/uapi/linux/bpqether.h
index a6c35e1a89ad..05865edaefda 100644
--- a/include/uapi/linux/bpqether.h
+++ b/include/uapi/linux/bpqether.h
@@ -5,9 +5,7 @@
  * 	Defines for the BPQETHER pseudo device driver
  */
 
-#ifndef __LINUX_IF_ETHER_H
 #include <linux/if_ether.h>
-#endif
 
 #define SIOCSBPQETHOPT		(SIOCDEVPRIVATE+0)	/* reserved */
 #define SIOCSBPQETHADDR		(SIOCDEVPRIVATE+1)
-- 
2.10.2
