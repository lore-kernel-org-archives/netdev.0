From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] mark CSZ scheduler as broken
Date: Wed, 7 Jul 2004 11:19:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707111936.760586b0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since the configuration help for CSZ is broken, and other documentation
says it just doesn't work.  Why not mark it as broken to make it obvious?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/Kconfig b/net/sched/Kconfig
--- a/net/sched/Kconfig	2004-07-07 11:18:01 -07:00
+++ b/net/sched/Kconfig	2004-07-07 11:18:01 -07:00
@@ -51,7 +51,7 @@
 
 config NET_SCH_CSZ
 	tristate "CSZ packet scheduler"
-	depends on NET_SCHED
+	depends on NET_SCHED && BROKEN
 	---help---
 	  Say Y here if you want to use the Clark-Shenker-Zhang (CSZ) packet
 	  scheduling algorithm for some of your network devices.  At the
