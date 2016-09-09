From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 8/8] xfrm: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:20 -0400
Message-ID: <1473425000-9782-9-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

---

 net/xfrm/xfrm_algo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 250e567ba3d6..44ac85fe2bc9 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -17,7 +17,7 @@
 #include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <net/xfrm.h>
-#if defined(CONFIG_INET_ESP) || defined(CONFIG_INET_ESP_MODULE) || defined(CONFIG_INET6_ESP) || defined(CONFIG_INET6_ESP_MODULE)
+#if IS_ENABLED(CONFIG_INET_ESP) || IS_ENABLED(CONFIG_INET6_ESP)
 #include <net/esp.h>
 #endif
 
-- 
2.7.4
