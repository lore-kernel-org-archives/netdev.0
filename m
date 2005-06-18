From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/9] orinoco: include <net/ieee80211.h>
Date: Sun, 19 Jun 2005 01:27:28 +0200
Message-ID: <20050618232728.GC9918@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We need constants from this header in the next patches.


Index: linux-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/orinoco.c	2005-06-19 00:59:34.000000000 +0200
+++ linux-2.6/drivers/net/wireless/orinoco.c	2005-06-19 01:02:24.000000000 +0200
@@ -463,6 +463,7 @@
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
+#include <net/ieee80211.h>
 
 #include <asm/uaccess.h>
 #include <asm/io.h>
