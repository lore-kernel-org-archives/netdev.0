From: Val Henson <val@nmt.edu>
Subject: Re: [bk patches] add ethtool_ops to net drivers
Date: Mon, 18 Aug 2003 00:15:11 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818061511.GA1255@speare5-1-14>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I needed the following patch to compile netsyms.c - just a missing
include.

Thanks,

-VAL

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1214  -> 1.1215 
#	       net/netsyms.c	1.93    -> 1.94   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/17	val@host4.sbcglobal.net	1.1215
# Add missing include for ethtool ops
# --------------------------------------------
#
diff -Nru a/net/netsyms.c b/net/netsyms.c
--- a/net/netsyms.c	Sun Aug 17 20:26:07 2003
+++ b/net/netsyms.c	Sun Aug 17 20:26:07 2003
@@ -626,6 +626,7 @@
 EXPORT_SYMBOL(linkwatch_fire_event);
 
 /* ethtool.c */
+#include <linux/ethtool.h>
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_tx_csum);
 EXPORT_SYMBOL(ethtool_op_get_sg);
