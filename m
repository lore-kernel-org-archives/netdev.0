From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 2/5] skge: eliminate a global variable
Date: Mon, 18 Oct 2004 15:19:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018151957.7c7f8059@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This variable is only defined and used in one file

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/skaddr.c b/drivers/net/sk98lin/skaddr.c
--- a/drivers/net/sk98lin/skaddr.c	2004-10-18 15:08:52 -07:00
+++ b/drivers/net/sk98lin/skaddr.c	2004-10-18 15:08:52 -07:00
@@ -79,7 +79,7 @@
 
 /* 64-bit hash values with all bits set. */
 
-SK_U16	OnesHash[4] = {0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};
+static SK_U16	OnesHash[4] = {0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};
 
 /* local variables ************************************************************/
 
