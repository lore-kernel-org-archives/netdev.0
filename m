From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/7] [bmac]: Remove obsolete usage of IFF_RUNING
Date: Mon, 28 Mar 2005 02:07:25 +0200
Message-ID: <20050328000725.GP3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:10:11+02:00 tgraf@suug.ch 
#   [bmac]: Remove obsolete usage of IFF_RUNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/bmac.c
#   2005/03/28 00:09:27+02:00 tgraf@suug.ch +0 -2
#   [bmac]: Remove obsolete usage of IFF_RUNING
# 
diff -Nru a/drivers/net/bmac.c b/drivers/net/bmac.c
--- a/drivers/net/bmac.c	2005-03-28 01:08:09 +02:00
+++ b/drivers/net/bmac.c	2005-03-28 01:08:09 +02:00
@@ -1412,7 +1412,6 @@
 	bp->opened = 1;
 	bmac_reset_and_enable(dev);
 	enable_irq(dev->irq);
-	dev->flags |= IFF_RUNNING;
 	return 0;
 }
 
@@ -1425,7 +1424,6 @@
 	int i;
 
 	bp->sleeping = 1;
-	dev->flags &= ~(IFF_UP | IFF_RUNNING);
 
 	/* disable rx and tx */
 	config = bmread(dev, RXCFG);
