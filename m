From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 2/5] tlan: get rid of unneeded global vars (rev 2)
Date: Tue, 19 Oct 2004 11:19:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019111950.546a5c26@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The global variable media_map is never used. And the media table media
can be static.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	2004-10-19 11:05:01 -07:00
+++ b/drivers/net/tlan.c	2004-10-19 11:05:01 -07:00
@@ -223,12 +223,10 @@
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
 
-const char *media[] = {
+static const char *media[] = {
 	"10BaseT-HD ", "10BaseT-FD ","100baseTx-HD ", 
 	"100baseTx-FD", "100baseT4", NULL
 };
-
-int media_map[] = { 0x0020, 0x0040, 0x0080, 0x0100, 0x0200,};
 
 static struct board {
 	const char	*deviceLabel;
