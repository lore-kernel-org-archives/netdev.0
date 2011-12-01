From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH] dsa: Include linux/if_ether.h to fix build error
Date: Thu, 01 Dec 2011 16:07:18 +0800
Message-ID: <1322726838.14554.3.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Include linux/if_ether.h to fix below build errors:

  CC      arch/arm/mach-kirkwood/common.o
In file included from arch/arm/mach-kirkwood/common.c:19:
include/net/dsa.h: In function 'dsa_uses_dsa_tags':
include/net/dsa.h:192: error: 'ETH_P_DSA' undeclared (first use in this function)
include/net/dsa.h:192: error: (Each undeclared identifier is reported only once
include/net/dsa.h:192: error: for each function it appears in.)
include/net/dsa.h: In function 'dsa_uses_trailer_tags':
include/net/dsa.h:197: error: 'ETH_P_TRAILER' undeclared (first use in this function)
make[1]: *** [arch/arm/mach-kirkwood/common.o] Error 1
make: *** [arch/arm/mach-kirkwood] Error 2

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 include/net/dsa.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index b78db3c..7828ebf 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,6 +11,7 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/if_ether.h>
 #include <linux/list.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
-- 
1.7.5.4
