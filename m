From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net/core: include linux/types.h instead of asm/types.h
Date: Mon, 17 Nov 2014 22:08:22 +0100
Message-ID: <1416258502-9001-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/core/link_watch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bd0767e..49a9e3e 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -21,7 +21,7 @@
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
-#include <asm/types.h>
+#include <linux/types.h>
 
 
 enum lw_bits {
-- 
1.9.3
