From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/9] PKT_SCHED: Actions are now available for all classifiers
Date: Thu, 30 Dec 2004 13:36:17 +0100
Message-ID: <20041230123617.GV32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041230122652.GM32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/net/sched/Kconfig	2004-12-27 14:32:33.000000000 +0100
+++ linux-2.6.10-bk1/net/sched/Kconfig	2004-12-27 22:47:22.000000000 +0100
@@ -381,7 +381,6 @@
 	---help---
 	This option requires you have a new iproute2. It enables
 	tc extensions which can be used with tc classifiers.
-	Only the u32 and fw classifiers are supported at the moment.
 	  You MUST NOT turn this on if you dont have an update iproute2.
 
 config NET_ACT_POLICE
