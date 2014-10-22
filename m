From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net: llc: include linux/errno.h instead of asm/errno.h
Date: Wed, 22 Oct 2014 21:06:26 +0200
Message-ID: <1414004787-7936-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/llc/llc_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/llc/llc_if.c b/net/llc/llc_if.c
index 25c31c0..6daf391 100644
--- a/net/llc/llc_if.c
+++ b/net/llc/llc_if.c
@@ -15,7 +15,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <asm/errno.h>
+#include <linux/errno.h>
 #include <net/llc_if.h>
 #include <net/llc_sap.h>
 #include <net/llc_s_ev.h>
-- 
1.9.1
