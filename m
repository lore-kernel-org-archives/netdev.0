From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove broken bitfield use from via-rhine
Date: Sun, 23 May 2004 01:11:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040522231117.GA3416@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Debian kernel package, author probably Herbert Xu


we're using it to assign if_port to it only anyway so it should have the
same type.



 * Fixed size of default_port in drivers/net/via-rhine.c

diff -urN kernel-source-2.6.6/drivers/net/via-rhine.c kernel-source-2.6.6-1/drivers/net/via-rhine.c
--- kernel-source-2.6.6/drivers/net/via-rhine.c	2004-05-10 19:47:56.000000000 +1000
+++ kernel-source-2.6.6-1/drivers/net/via-rhine.c	2004-05-10 22:21:34.000000000 +1000
@@ -523,8 +523,8 @@
 	u16 chip_cmd;						/* Current setting for ChipCmd */
 
 	/* These values are keep track of the transceiver/media in use. */
-	unsigned int default_port:4;		/* Last dev->if_port value. */
 	u8 tx_thresh, rx_thresh;
+	unsigned int default_port;		/* Last dev->if_port value. */
 
 	/* MII transceiver section. */
 	unsigned char phys[MAX_MII_CNT];			/* MII device addresses. */
