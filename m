From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/arcnet/capmode.c: make a struct static
Date: Mon, 2 May 2005 03:46:34 +0200
Message-ID: <20050502014634.GP3592@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261841AbVEBCgi@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 19 Apr 2005

--- linux-2.6.12-rc2-mm3-full/drivers/net/arcnet/capmode.c.old	2005-04-19 03:03:23.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/arcnet/capmode.c	2005-04-19 03:03:53.000000000 +0200
@@ -48,7 +48,7 @@
 static int ack_tx(struct net_device *dev, int acked);
 
 
-struct ArcProto capmode_proto =
+static struct ArcProto capmode_proto =
 {
 	'r',
 	XMTU,
