From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 1/2] ip: include libc headers first
Date: Mon, 22 May 2017 16:27:53 +0300
Message-ID: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:41566 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759594AbdEVN2G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 09:28:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Including libc headers first helps as a workaround to redefinition of struct
ethhdr with a suitably patched musl libc that suppresses the kernel
if_ether.h.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 ip/iplink_bridge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 818b43c89b5b..cccdec1c203a 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -13,9 +13,9 @@
 #include <stdlib.h>
 #include <string.h>
 #include <netinet/in.h>
+#include <netinet/ether.h>
 #include <linux/if_link.h>
 #include <linux/if_bridge.h>
-#include <netinet/ether.h>
 #include <net/if.h>
 
 #include "rt_names.h"
-- 
2.11.0
