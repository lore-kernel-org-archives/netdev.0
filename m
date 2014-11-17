From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net/core: include linux/uaccess.h instead of asm/uaccess.h
Date: Mon, 17 Nov 2014 22:10:23 +0100
Message-ID: <1416258624-9577-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/gen_estimator.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 9dfb88a..d654d6f 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -13,7 +13,7 @@
  *              names to make it usable in general net subsystem.
  */
 
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/module.h>
 #include <linux/types.h>
-- 
1.9.3
