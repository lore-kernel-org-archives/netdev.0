From: Don Fry <brazilnut@us.ibm.com>
Subject: re-send [PATCH 2/8 2.4.26-bk1] pcnet32 add 79C976 support
Date: Wed, 21 Apr 2004 11:21:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404211821.i3LILoQ02135@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please include this patch to add support for the 79C976 device to the
pcnet32 driver.  Tested ia32.

--- linux-2.6.5/drivers/net/orig.pcnet32.c	Sat Apr  3 19:36:53 2004
+++ linux-2.6.5/drivers/net/pcnet32.c	Mon Apr  5 11:40:57 2004
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
