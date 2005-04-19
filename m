From: Adrian Bunk <bunk@stusta.de>
Subject: [2,6 patch] drivers/net/arcnet/capmode.c: make a struct static
Date: Tue, 19 Apr 2005 04:38:40 +0200
Message-ID: <20050419023840.GT5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.12-rc2-mm3-full/drivers/net/arcnet/capmode.c.old	2005-04-19 03:03:23.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/arcnet/capmode.c	2005-04-19 03:03:53.000000000 +0200
@@ -48,7 +48,7 @@
 static int ack_tx(struct net_device *dev, int acked);
 
 
-struct ArcProto capmode_proto =
+static struct ArcProto capmode_proto =
 {
 	'r',
 	XMTU,
