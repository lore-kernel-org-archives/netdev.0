From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/3) skfp -- sparse __user annotation
Date: Tue, 22 Jun 2004 14:21:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622142148.287d402d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add __user annotation to the device specific ioctl.
 
diff -Nru a/drivers/net/skfp/h/targetos.h b/drivers/net/skfp/h/targetos.h
--- a/drivers/net/skfp/h/targetos.h	2004-06-22 13:57:04 -07:00
+++ b/drivers/net/skfp/h/targetos.h	2004-06-22 13:57:04 -07:00
@@ -110,7 +110,7 @@
 struct s_skfp_ioctl {
 	unsigned short cmd;                /* Command to run */
 	unsigned short len;                /* Length of the data buffer */
-	unsigned char  *data;              /* Pointer to the data buffer */
+	unsigned char __user *data;        /* Pointer to the data buffer */
 };
 
 /* 
