From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 12/18] ipw2200: version string rework
Date: Thu, 13 Apr 2006 17:20:34 +0800
Message-ID: <20060413092034.GA28787@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:33485 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964852AbWDMJ1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:27:45 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added version string fields so the version string indicates what is
configured (ie, you'll see 1.1.1kpmd if you are using a GIT snapshot
(Kernel.. previously -git), promiscuous (p), monitor (m), debug (d) build.

Signed-off-by: James Ketrenos <jketreno@linux.intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   39 ++++++++++++++++++++++++++++++++++++++-
 1 files changed, 38 insertions(+), 1 deletions(-)

c6f5917d6d8a5a5c44d1386a5ca52b1670ba09cb
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index bbf17f6..8b20d6c 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -33,7 +33,44 @@
 #include "ipw2200.h"
 #include <linux/version.h>
 
-#define IPW2200_VERSION "git-1.1.1"
+
+#ifndef KBUILD_EXTMOD
+#define VK "k"
+#else
+#define VK
+#endif
+
+#ifdef CONFIG_IPW2200_DEBUG
+#define VD "d"
+#else
+#define VD
+#endif
+
+#ifdef CONFIG_IPW2200_MONITOR
+#define VM "m"
+#else
+#define VM
+#endif
+
+#ifdef CONFIG_IPW2200_PROMISCUOUS
+#define VP "p"
+#else
+#define VP
+#endif
+
+#ifdef CONFIG_IEEE80211_RADIOTAP
+#define VR "r"
+#else
+#define VR
+#endif
+
+#ifdef CONFIG_IPW2200_QOS
+#define VQ "q"
+#else
+#define VQ
+#endif
+
+#define IPW2200_VERSION "1.1.1" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
-- 
1.2.6

