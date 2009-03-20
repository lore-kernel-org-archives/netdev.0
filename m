From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] atm: fix non-const printk argument
Date: Fri, 20 Mar 2009 09:44:02 -0700
Message-ID: <20090320094402.5bf234b3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42405 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757663AbZCTQoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 12:44:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change printk() argument to fix compiler warning.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/atm/iphase.c	2009-03-20 09:27:01.892901660 -0700
+++ b/drivers/atm/iphase.c	2009-03-20 09:27:26.415839648 -0700
@@ -977,9 +977,7 @@ static void xdump( u_char*  cp, int  len
             else
                 pBuf += sprintf( pBuf, "." );
                 }
-        sprintf( pBuf, "\n" );
-        // SPrint(prntBuf);
-        printk(prntBuf);
+        printk("%s\n", prntBuf);
         count += col;
         pBuf = prntBuf;
     }
