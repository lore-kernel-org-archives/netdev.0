From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [PATCH] Documentation: add a guideline for hard_start_xmit method not to modify SKB
Date: Sat, 22 Dec 2007 18:22:09 +0100 (CET)
Message-ID: <110604.81450.qm@web52011.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52011.mail.re2.yahoo.com ([206.190.48.27]:28951 "HELO
	web52011.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752178AbXLVRWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 12:22:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Add a guideline for hard_start_xmit method not to
modify SKB.

Signed-off-by: Matti Linnanvuori
<mattilinnanvuori@yahoo.com>

---


--- a/Documentation/networking/driver.txt	2007-12-22
18:50:28.062169500 +0200
+++ b/Documentation/networking/driver.txt	2007-12-22
19:10:58.726566000 +0200

@@ -74,6 +74,9 @@ Transmit path guidelines:
    If you return 1 from the hard_start_xmit method,
you must not keep
    any reference to that SKB and you must not attempt
to free it up.
 
+4) A hard_start_xmit method must not modify the
cloned parts of the
+   SKB.
+
 Probing guidelines:
 
 1) Any hardware layer address you obtain for your
device should



      Machen Sie Yahoo! zu Ihrer Startseite. Los geht's: 
http://de.yahoo.com/set
