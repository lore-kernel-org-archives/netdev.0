From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/23) sk98: add module version
Date: Thu, 11 Nov 2004 15:57:44 -0800
Message-ID: <20041111155744.3119f256@zqx3.pdx.osdl.net>
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

Add MODULE_VERSION to build process

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-03 15:35:02 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-03 15:35:02 -08:00
@@ -350,6 +350,7 @@
 MODULE_AUTHOR("Mirko Lindner <mlindner@syskonnect.de>");
 MODULE_DESCRIPTION("SysKonnect SK-NET Gigabit Ethernet SK-98xx driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(VER_STRING);
 
 #ifdef LINK_SPEED_A
 static char *Speed_A[SK_MAX_CARD_PARAM] = LINK_SPEED;
