From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/25) sk98: change #define to typedef
Date: Mon, 15 Nov 2004 15:22:03 -0800
Message-ID: <20041115152203.24adb0ea@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change #define of to a typedef.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:28 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:28 -08:00
@@ -106,7 +106,7 @@
 #define SK_MAX_MACS		2
 #define SK_MAX_NETS		2
 
-#define SK_IOC			char __iomem *
+typedef void __iomem *SK_IOC;
 
 typedef struct s_DrvRlmtMbuf SK_MBUF;
 
