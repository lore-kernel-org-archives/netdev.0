From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 3/3] tlan: get rid of unneeded global
Date: Mon, 18 Oct 2004 14:07:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018140716.3555a203@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More unnecessary globals.
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	2004-10-18 14:03:05 -07:00
+++ b/drivers/net/tlan.c	2004-10-18 14:03:05 -07:00
@@ -224,12 +224,12 @@
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
 
-const char *media[] = {
+static const char *media[] = {
 	"10BaseT-HD ", "10BaseT-FD ","100baseTx-HD ", 
 	"100baseTx-FD", "100baseT4", NULL
 };
 
-int media_map[] = { 0x0020, 0x0040, 0x0080, 0x0100, 0x0200,};
+static int media_map[] = { 0x0020, 0x0040, 0x0080, 0x0100, 0x0200,};
 
 static struct board {
 	const char	*deviceLabel;
