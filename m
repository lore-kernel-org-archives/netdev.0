From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] r8169: rx_copybreak description
Date: Wed, 9 Mar 2005 11:37:00 -0800
Message-ID: <20050309113700.21a31d84@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add module parameter description for copybreak.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2005-03-09 11:24:43 -08:00
+++ b/drivers/net/r8169.c	2005-03-09 11:24:43 -08:00
@@ -424,6 +424,7 @@
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param_array(media, int, &num_media, 0);
 module_param(rx_copybreak, int, 0);
+MODULE_PARM_DESC(rx_copybreak, "copy breakpoint for copy-only-tiny-frames");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(RTL8169_VERSION);
 
