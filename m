From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sk_g16 missing declaration
Date: Tue, 11 Nov 2003 14:47:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111144704.1d6910de.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The new probe code in net-drivers-2.5-exp lost a declaration for the
module case (thanks al).

diff -Nru a/drivers/net/sk_g16.c b/drivers/net/sk_g16.c
--- a/drivers/net/sk_g16.c	Tue Nov 11 09:36:10 2003
+++ b/drivers/net/sk_g16.c	Tue Nov 11 09:36:10 2003
@@ -604,6 +604,9 @@
 
 
 #ifdef MODULE
+
+static struct net_device *SK_dev;
+
 static int __init SK_init_module (void)
 {
  	SK_dev = SK_init(-1);
