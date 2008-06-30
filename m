From: "Samuel Ortiz" <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/4] irda: Remove useless pm_dev references
Date: Mon, 30 Jun 2008 21:23:53 +0200
Message-ID: <20080630192754.068509474@sortiz.org>
References: <20080630192351.765611690@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=irda_pm.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

Some IRDA headers contain references to 'struct pm_dev' that are not
necessary any more and may be removed.

Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>
Acked-by: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 drivers/net/irda/ali-ircc.h    |    2 --
 drivers/net/irda/au1000_ircc.h |    1 -
 drivers/net/irda/via-ircc.h    |    1 -
 3 files changed, 4 deletions(-)

Index: net-next-2.6/drivers/net/irda/au1000_ircc.h
===================================================================
--- net-next-2.6.orig/drivers/net/irda/au1000_ircc.h	2008-06-14 13:20:23.000000000 +0200
+++ net-next-2.6/drivers/net/irda/au1000_ircc.h	2008-06-14 13:25:18.000000000 +0200
@@ -122,6 +122,5 @@ struct au1k_private {
 	struct timer_list timer;
 
 	spinlock_t lock;           /* For serializing operations */
-        struct pm_dev *dev;
 };
 #endif /* AU1000_IRCC_H */
Index: net-next-2.6/drivers/net/irda/ali-ircc.h
===================================================================
--- net-next-2.6.orig/drivers/net/irda/ali-ircc.h	2008-06-14 13:20:23.000000000 +0200
+++ net-next-2.6/drivers/net/irda/ali-ircc.h	2008-06-14 13:25:18.000000000 +0200
@@ -219,8 +219,6 @@ struct ali_ircc_cb {
 	int index;                 /* Instance index */
 	
 	unsigned char fifo_opti_buf;
-
-        struct pm_dev *dev;
 };
 
 static inline void switch_bank(int iobase, int bank)
Index: net-next-2.6/drivers/net/irda/via-ircc.h
===================================================================
--- net-next-2.6.orig/drivers/net/irda/via-ircc.h	2008-06-14 13:20:23.000000000 +0200
+++ net-next-2.6/drivers/net/irda/via-ircc.h	2008-06-14 13:25:18.000000000 +0200
@@ -118,7 +118,6 @@ struct via_ircc_cb {
 	int index;		/* Instance index */
 
 	struct eventflag EventFlag;
-	struct pm_dev *dev;
 	unsigned int chip_id;	/* to remember chip id */
 	unsigned int RetryCount;
 	unsigned int RxDataReady;

-- 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
