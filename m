From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] networking: NET_CLS_ROUTE4 depends on INET
Date: Thu, 19 May 2011 16:22:18 -0700
Message-ID: <20110519162218.b0344392.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <hadi@cyberus.ca>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:32134 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181Ab1ESXWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 19:22:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

IP_ROUTE_CLASSID depends on INET and NET_CLS_ROUTE4 selects
IP_ROUTE_CLASSID, but when INET is not enabled, this kconfig warning
is produced, so fix it by making NET_CLS_ROUTE4 depend on INET.

warning: (NET_CLS_ROUTE4) selects IP_ROUTE_CLASSID which has unmet direct dependencies (NET && INET)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/sched/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- lnx-2639.orig/net/sched/Kconfig
+++ lnx-2639/net/sched/Kconfig
@@ -277,6 +277,7 @@ config NET_CLS_TCINDEX
 
 config NET_CLS_ROUTE4
 	tristate "Routing decision (ROUTE)"
+	depends on INET
 	select IP_ROUTE_CLASSID
 	select NET_CLS
 	---help---
