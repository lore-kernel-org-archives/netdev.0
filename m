From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 3/5] 2.6.6-bk8 pcnet32 correct 79C976 variant string.
Date: Fri, 21 May 2004 13:29:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212029.i4LKTTM10187@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch correctly identifies the 79C976 as a PCnet/PRO not a FAST III.

--- linux-2.6.6-bk8/drivers/net/dead.pcnet32.c	Fri May 21 09:58:58 2004
+++ linux-2.6.6-bk8/drivers/net/pcnet32.c	Fri May 21 09:59:18 2004
@@ -1082,7 +1082,7 @@
 	fdx = 1; mii = 1;
 	break;
     case 0x2628:
-	chipname = "PCnet/FAST III 79C976";
+	chipname = "PCnet/PRO 79C976";
 	fdx = 1; mii = 1;
 	break;
     default:

-- 
Don Fry
brazilnut@us.ibm.com
