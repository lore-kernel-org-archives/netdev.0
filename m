From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] minor #if complaint
Date: Mon, 12 Jul 2004 15:44:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040712154444.46ae6922@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor sparse warning fix. it doesn't like #if when #ifdef is intended.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
--- a/drivers/net/pcmcia/nmclan_cs.c	2004-07-12 15:07:19 -07:00
+++ b/drivers/net/pcmcia/nmclan_cs.c	2004-07-12 15:07:19 -07:00
@@ -1472,7 +1472,7 @@
 	Modified from Am79C90 data sheet.
 ---------------------------------------------------------------------------- */
 
-#if BROKEN_MULTICAST
+#ifdef BROKEN_MULTICAST
 
 static void updateCRC(int *CRC, int bit)
 {
