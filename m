From: Don Fry <brazilnut@us.ibm.com>
Subject: [patch 2.6.3] pcnet32 another debug fix
Date: Tue, 24 Feb 2004 16:57:45 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402250057.i1P0vjs20486@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

As requested, another fix for pcnet32_debug to have a bunch of bits in
increasing order of verbosity, not just one bit.

--- linux-2.6.3/drivers/net/almost.pcnet32.c	Tue Feb 24 16:40:22 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Tue Feb 24 16:39:18 2004
@@ -2009,7 +2009,7 @@
     printk(KERN_INFO "%s", version);
 
     if (debug >= 0 && debug < (sizeof(int) - 1))
-	pcnet32_debug = 1 << debug;
+	pcnet32_debug = (1 << debug) - 1;
 
     if ((tx_start_pt >= 0) && (tx_start_pt <= 3))
 	tx_start = tx_start_pt;

-- 
Don Fry
brazilnut@us.ibm.com
