From: akpm@osdl.org
Subject: [patch 10/18] gcc-35: drivers/net/wan/lmc
Date: Sun, 25 Jan 2004 03:07:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7eo25091@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



drivers/net/wan/lmc/lmc_media.c:1061: sorry, unimplemented: called from here
drivers/net/wan/lmc/lmc_debug.h:50: sorry, unimplemented: inlining failed in call to 'lmc_trace': function body not available



---

 drivers/net/wan/lmc/lmc_debug.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wan/lmc/lmc_debug.h~gcc-35-lmc drivers/net/wan/lmc/lmc_debug.h
--- 25/drivers/net/wan/lmc/lmc_debug.h~gcc-35-lmc	2004-01-23 21:40:34.000000000 -0800
+++ 25-akpm/drivers/net/wan/lmc/lmc_debug.h	2004-01-23 21:40:40.000000000 -0800
@@ -47,6 +47,6 @@ extern u_int32_t lmcEventLogBuf[LMC_EVEN
 
 void lmcConsoleLog(char *type, unsigned char *ucData, int iLen);
 void lmcEventLog (u_int32_t EventNum, u_int32_t arg2, u_int32_t arg3);
-inline void lmc_trace(struct net_device *dev, char *msg);
+void lmc_trace(struct net_device *dev, char *msg);
 
 #endif

_
