From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] pcnet32.c add support for 79C976
Date: Mon, 29 Mar 2004 13:12:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403292112.i2TLCGD10901@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patch to 2.6.5-rc2-bk9 and 2.4.26-rc1 to
include support for the 79C976. Tested on IA32.

--- linux-2.6.5-rc2-bk9/drivers/net/orig.pcnet32.c	Mon Mar 29 11:34:13 2004
+++ linux-2.6.5-rc2-bk9/drivers/net/pcnet32.c	Mon Mar 29 11:39:57 2004
@@ -909,6 +909,10 @@
 	chipname = "PCnet/FAST III 79C975"; /* PCI */
 	fdx = 1; mii = 1;
 	break;
+    case 0x2628:
+	chipname = "PCnet/FAST III 79C976";
+	fdx = 1; mii = 1;
+	break; 
     default:
 	printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",
 		chip_version);

-- 
Don Fry
brazilnut@us.ibm.com
