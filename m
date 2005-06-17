From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 1/9] ixgb: Set RXDCTL:PTHRESH/HTHRESH to zero
Date: Fri, 17 Jun 2005 16:55:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0506131233320.24260@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Set RXDCTL:PTHRESH/HTHRESH to zero 

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
 
diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2005-05-25 12:26:48.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-05-25 12:27:01.000000000 -0700
@@ -142,10 +142,12 @@ static void ixgb_netpoll(struct net_devi
 MODULE_LICENSE("GPL");
 
 /* some defines for controlling descriptor fetches in h/w */
-#define RXDCTL_PTHRESH_DEFAULT 128	/* chip considers prefech below this */
-#define RXDCTL_HTHRESH_DEFAULT 16	/* chip will only prefetch if tail is 
-					   pushed this many descriptors from head */
 #define RXDCTL_WTHRESH_DEFAULT 16	/* chip writes back at this many or RXT0 */
+#define RXDCTL_PTHRESH_DEFAULT 0		/* chip considers prefech below
+						 * this */
+#define RXDCTL_HTHRESH_DEFAULT 0		/* chip will only prefetch if tail
+						 * is pushed this many descriptors
+						 * from head */
 
 /**
  * ixgb_init_module - Driver Registration Routine
