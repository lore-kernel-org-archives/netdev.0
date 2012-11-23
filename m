From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] net: sched: enable CAN Identifier to be build into kernel
Date: Fri, 23 Nov 2012 11:44:57 +0100
Message-ID: <1353667497-25676-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes it possible to build the CAN Identifier into the kernel, even
if the CAN support is build as a module.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
Hello,

is there a nicer solution to this problem? Or remove the "&& CAN" at all?

Marc

 net/sched/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 62fb51f..235e01a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -509,7 +509,7 @@ config NET_EMATCH_TEXT
 
 config NET_EMATCH_CANID
 	tristate "CAN Identifier"
-	depends on NET_EMATCH && CAN
+	depends on NET_EMATCH && (CAN=y || CAN=m)
 	---help---
 	  Say Y here if you want to be able to classify CAN frames based
 	  on CAN Identifier.
-- 
1.7.10.4

