From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xfrm_algo: drop an unnecessary inclusion
Date: Tue, 15 May 2012 13:00:44 +0100
Message-ID: <4FB2618C0200007800083C99@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:56241 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757851Ab2EOMAS convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:2:2>);
	Tue, 15 May 2012 08:00:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For several releases, this has not been needed anymore, as no helper
functions declared in net/ah.h get implemented by xfrm_algo.c anymore.

Signed-off-by: Jan Beulich <jbeulich@suse.com>

---
 net/xfrm/xfrm_algo.c |    3 ---
 1 file changed, 3 deletions(-)

--- 3.4-rc7/net/xfrm/xfrm_algo.c
+++ 3.4-rc7-xfrm-algo-module/net/xfrm/xfrm_algo.c
@@ -15,9 +15,6 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <net/xfrm.h>
-#if defined(CONFIG_INET_AH) || defined(CONFIG_INET_AH_MODULE) || defined(CONFIG_INET6_AH) || defined(CONFIG_INET6_AH_MODULE)
-#include <net/ah.h>
-#endif
 #if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
 #include <net/esp.h>
 #endif
