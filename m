From: Roger Luethi <rl@hellgate.ch>
Subject: [3/9][PATCH 2.6] Nuke HasESIPhy and related code
Date: Wed, 2 Jun 2004 13:58:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115818.GA17462@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This has been dead code forever.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -375,7 +375,7 @@
 
 
 enum chip_capability_flags {
-	HasESIPhy=2, HasDavicomPhy=4,
+	HasDavicomPhy=4,
 	ReqTxAlign=0x10, HasWOL=0x20,
 };
 
@@ -1085,9 +1085,8 @@
 
 	/* The LED outputs of various MII xcvrs should be configured. */
 	/* For NS or Mison phys, turn on bit 1 in register 0x17 */
-	/* For ESI phys, turn on bit 7 in register 0x17. */
 	mdio_write(dev, rp->phys[0], 0x17, mdio_read(dev, rp->phys[0], 0x17) |
-		   (rp->drv_flags & HasESIPhy) ? 0x0080 : 0x0001);
+		   0x0001);
 }
 
 /* Read and write over the MII Management Data I/O (MDIO) interface. */
