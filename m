From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.3] pcnet32.c fix compile error
Date: Fri, 20 Feb 2004 16:43:54 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402210043.i1L0hsL07547@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arrgh.  I sent the wrong diff file.  This one fixes the compile error I
introduced ;-(

--- linux-2.6.3/drivers/net/arrgh.pcnet32.c	Fri Feb 20 16:39:22 2004
+++ linux-2.6.3/drivers/net/pcnet32.c	Fri Feb 20 15:52:32 2004
@@ -1518,7 +1518,7 @@
 
     rap = lp->a.read_rap(ioaddr);
     while ((csr0 = lp->a.read_csr (ioaddr, 0)) & 0x8600 && --boguscnt >= 0) {
-	if (csr == 0xffff) {
+	if (csr0 == 0xffff) {
 	    break;			/* PCMCIA remove happened */
 	}
 	/* Acknowledge all of the current interrupt sources ASAP. */

-- 
Don Fry
brazilnut@us.ibm.com
