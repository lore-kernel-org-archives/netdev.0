From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.6-rc1-bk5] remove duplicate pcnet32 patch
Date: Tue, 20 Apr 2004 09:17:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404201617.i3KGHcB13213@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch to 2.6.6-rc1-bk5 to remove a duplicate patch
that added 79C976 support (twice).  As is, it will not compile.

--- linux-2.6.6-rc1-bk5/drivers/net/bad.pcnet32.c	Tue Apr 20 09:11:01 2004
+++ linux-2.6.6-rc1-bk5/drivers/net/pcnet32.c	Tue Apr 20 09:11:06 2004
@@ -1010,10 +1010,6 @@
 	chipname = "PCnet/FAST III 79C976";
 	fdx = 1; mii = 1;
 	break;
-    case 0x2628:
-	chipname = "PCnet/FAST III 79C976";
-	fdx = 1; mii = 1;
-	break; 
     default:
 	if (pcnet32_debug & NETIF_MSG_PROBE)
 	    printk(KERN_INFO PFX "PCnet version %#x, no PCnet32 chip.\n",

-- 
Don Fry
brazilnut@us.ibm.com
