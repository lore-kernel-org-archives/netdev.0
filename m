From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [PATCH v2] Documentation: add a guideline for hard_start_xmit method
Date: Sat, 12 Jan 2008 21:33:26 -0800 (PST)
Message-ID: <13447.65555.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52011.mail.re2.yahoo.com ([206.190.48.27]:47651 "HELO
	web52011.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751090AbYAMFdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:33:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
 
Add a guideline for hard_start_xmit method not to
modify SKB.
 
Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
---
--- a/Documentation/networking/driver.txt 2008-01-13 07:14:01.608291500 +0200
+++ b/Documentation/networking/driver.txt 2008-01-13 07:13:40.535421500 +0200
@@ -61,7 +61,9 @@
 2) Do not forget to update netdev->trans_start to jiffies after
    each new tx packet is given to the hardware.
 
-3) Do not forget that once you return 0 from your hard_start_xmit
+3) A hard_start_xmit method must not modify the shared parts of the SKB.
+
+4) Do not forget that once you return 0 from your hard_start_xmit
    method, it is your driver's responsibility to free up the SKB
    and in some finite amount of time.


      ____________________________________________________________________________________
Looking for last minute shopping deals?  
Find them fast with Yahoo! Search.  http://tools.search.yahoo.com/newsearch/category.php?category=shopping
