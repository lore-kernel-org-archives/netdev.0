From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (14/25) sk98: add module version
Date: Mon, 15 Nov 2004 15:44:32 -0800
Message-ID: <20041115154432.751cac27@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Mirko Lindner <demon@pro-linux.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add module version

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 13:37:00 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 13:37:00 -08:00
@@ -334,6 +334,7 @@
 MODULE_AUTHOR("Mirko Lindner <mlindner@syskonnect.de>");
 MODULE_DESCRIPTION("SysKonnect SK-NET Gigabit Ethernet SK-98xx driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(VER_STRING);
 
 #ifdef LINK_SPEED_A
 static char *Speed_A[SK_MAX_CARD_PARAM] = LINK_SPEED;
