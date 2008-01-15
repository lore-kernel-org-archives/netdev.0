From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [patch v3] Documentation: add a guideline for hard_start_xmit method
Date: Tue, 15 Jan 2008 06:25:27 -0800 (PST)
Message-ID: <492102.15643.qm@web52012.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52012.mail.re2.yahoo.com ([206.190.48.28]:29745 "HELO
	web52012.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750733AbYAOOZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 09:25:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Add a guideline not to modify SKBs.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---

--- a/Documentation/networking/driver.txt 2008-01-13 07:14:01.608291500 +0200
+++ b/Documentation/networking/driver.txt 2008-01-15 16:16:14.636054000 +0200
@@ -61,7 +61,10 @@ Transmit path guidelines:
 2) Do not forget to update netdev->trans_start to jiffies after
    each new tx packet is given to the hardware.
 
-3) Do not forget that once you return 0 from your hard_start_xmit
+3) A hard_start_xmit method must not modify the shared parts of a
+   cloned SKB.
+
+4) Do not forget that once you return 0 from your hard_start_xmit
    method, it is your driver's responsibility to free up the SKB
    and in some finite amount of time.


      ____________________________________________________________________________________
Never miss a thing.  Make Yahoo your home page. 
http://www.yahoo.com/r/hs
