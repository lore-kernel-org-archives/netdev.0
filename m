From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/5] 2.4.27-pre3 pcnet32 add static to two routines.
Date: Fri, 21 May 2004 13:56:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212056.i4LKuhB10255@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds 'static' to two routines.  The prototype has static but
the instantiation did not.

--- linux-2.4.27-pre3/drivers/net/orig.pcnet32.c	Fri May 21 12:34:04 2004
+++ linux-2.4.27-pre3/drivers/net/pcnet32.c	Fri May 21 12:36:44 2004
@@ -844,12 +844,12 @@
     return 0;
 }
 
-int pcnet32_get_regs_len(struct net_device *dev)
+static int pcnet32_get_regs_len(struct net_device *dev)
 {
     return(PCNET32_NUM_REGS * sizeof(u16));
 }
 
-void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	void *ptr)
 {
     int i, csr0;

-- 
Don Fry
brazilnut@us.ibm.com
