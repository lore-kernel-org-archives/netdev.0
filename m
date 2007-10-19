From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: QoS/Sched as menuconfig
Date: Thu, 18 Oct 2007 19:28:22 -0700
Message-ID: <20071018192822.89e1ffbd.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:59171 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761767AbXJSCaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:30:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Convert "QoS and/or fair queueing" to menuconfig.
This makes it easy for someone to disable all sub-options with
one config symbol.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sched/Kconfig |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

--- linux-2.6.23-git13.orig/net/sched/Kconfig
+++ linux-2.6.23-git13/net/sched/Kconfig
@@ -2,9 +2,7 @@
 # Traffic control configuration.
 # 
 
-menu "QoS and/or fair queueing"
-
-config NET_SCHED
+menuconfig NET_SCHED
 	bool "QoS and/or fair queueing"
 	select NET_SCH_FIFO
 	---help---
@@ -41,9 +39,6 @@ config NET_SCHED
 	  The available schedulers are listed in the following questions; you
 	  can say Y to as many as you like. If unsure, say N now.
 
-config NET_SCH_FIFO
-	bool
-
 if NET_SCHED
 
 comment "Queueing/Scheduling"
@@ -500,4 +495,5 @@ config NET_CLS_IND
 
 endif # NET_SCHED
 
-endmenu
+config NET_SCH_FIFO
+	bool
