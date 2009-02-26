From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/15] acenic: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:28 -0800
Message-ID: <20090226201949.776756976@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38660 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755317AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=acenic-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/acenic.c	2009-02-26 09:50:53.000000000 -0800
+++ b/drivers/net/acenic.c	2009-02-26 09:51:09.000000000 -0800
@@ -437,7 +437,7 @@ MODULE_PARM_DESC(max_rx_desc, "AceNIC/3C
 MODULE_PARM_DESC(tx_ratio, "AceNIC/3C985/GA620 ratio of NIC memory used for TX/RX descriptors (range 0-63)");
 
 
-static char version[] __devinitdata =
+static const char version[] __devinitconst =
   "acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk\n"
   "                            http://home.cern.ch/~jes/gige/acenic.html\n";
 

-- 

