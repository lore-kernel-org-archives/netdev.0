From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) baycom c99 initializers
Date: Fri, 19 Sep 2003 13:38:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919133802.63528be2.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Sailer <t.sailer@alumni.ethz.ch>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/hamradio/baycom_par.c b/drivers/net/hamradio/baycom_par.c
--- a/drivers/net/hamradio/baycom_par.c	Fri Sep 19 13:31:27 2003
+++ b/drivers/net/hamradio/baycom_par.c	Fri Sep 19 13:31:27 2003
@@ -388,11 +388,11 @@
 /* --------------------------------------------------------------------- */
 
 static struct hdlcdrv_ops par96_ops = {
-	bc_drvname,
-	bc_drvinfo,
-	par96_open,
-	par96_close,
-	baycom_ioctl
+	.drvname = bc_drvname,
+	.drvinfo = bc_drvinfo,
+	.open    = par96_open,
+	.close   = par96_close,
+	.ioctl   = baycom_ioctl
 };
 
 /* --------------------------------------------------------------------- */
diff -Nru a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
--- a/drivers/net/hamradio/baycom_ser_fdx.c	Fri Sep 19 13:31:27 2003
+++ b/drivers/net/hamradio/baycom_ser_fdx.c	Fri Sep 19 13:31:27 2003
@@ -496,11 +496,11 @@
 /* --------------------------------------------------------------------- */
 
 static struct hdlcdrv_ops ser12_ops = {
-	bc_drvname,
-	bc_drvinfo,
-	ser12_open,
-	ser12_close,
-	baycom_ioctl
+	.drvname = bc_drvname,
+	.drvinfo = bc_drvinfo,
+	.open    = ser12_open,
+	.close   = ser12_close,
+	.ioctl   = baycom_ioctl,
 };
 
 /* --------------------------------------------------------------------- */
diff -Nru a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
--- a/drivers/net/hamradio/baycom_ser_hdx.c	Fri Sep 19 13:31:27 2003
+++ b/drivers/net/hamradio/baycom_ser_hdx.c	Fri Sep 19 13:31:27 2003
@@ -541,11 +541,11 @@
 /* --------------------------------------------------------------------- */
 
 static struct hdlcdrv_ops ser12_ops = {
-	bc_drvname,
-	bc_drvinfo,
-	ser12_open,
-	ser12_close,
-	baycom_ioctl
+	.drvname = bc_drvname,
+	.drvinfo = bc_drvinfo,
+	.open    = ser12_open,
+	.close   = ser12_close,
+	.ioctl   = baycom_ioctl,
 };
 
 /* --------------------------------------------------------------------- */
