From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/23) sk98: board counter incremented twice
Date: Thu, 11 Nov 2004 15:57:53 -0800
Message-ID: <20041111155753.080b7161@zqx3.pdx.osdl.net>
References: <4192C60A.1050205@designassembly.de>
	<20041111154225.5cf85567@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner
 <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041111154225.5cf85567@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor bug, bourd found incremented twice. Also don't need to
initialize fields already zerod.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 15:09:28 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 15:09:28 -08:00
@@ -4972,11 +4972,6 @@
 	}
 #endif
 
-	pNet->PortNr = 0;
-	pNet->NetNr  = 0;
-
-	boards_found++;
-
 	/* More then one port found */
 	if ((pAC->GIni.GIMacsFound == 2 ) && (pAC->RlmtNets == 2)) {
 		if ((dev = alloc_etherdev(sizeof(DEV_NET))) == 0) {
