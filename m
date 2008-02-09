From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>
Subject: [patch] Documentation: fix tcp.txt
Date: Sat, 9 Feb 2008 06:25:18 -0800 (PST)
Message-ID: <366589.16312.qm@web52010.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52010.mail.re2.yahoo.com ([206.190.48.26]:47368 "HELO
	web52010.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752415AbYBIOZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 09:25:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

Replace BIC with CUBIC as default congestion control. Fix grammar.

Signed-off-by: Matti Linnanvuori <mattilinnanvuori@yahoo.com>

---

--- a/Documentation/networking/tcp.txt 2008-02-09 16:07:39.547357400 +0200
+++ b/Documentation/networking/tcp.txt 2008-02-09 16:12:49.497245900 +0200
@@ -1,7 +1,7 @@
 TCP protocol
 ============
 
-Last updated: 21 June 2005
+Last updated: 9 February 2008
 
 Contents
 ========
@@ -52,9 +52,9 @@
 The method that is used to determine which congestion control mechanism is
 determined by the setting of the sysctl net.ipv4.tcp_congestion_control.
 The default congestion control will be the last one registered (LIFO);
-so if you built everything as modules. the default will be reno. If you
-build with the default's from Kconfig, then BIC will be builtin (not a module)
-and it will end up the default.
+so if you built everything as modules, the default will be reno. If you
+build with the defaults from Kconfig, then CUBIC will be builtin (not a
+module) and it will end up the default.
 
 If you really want a particular default value then you will need
 to set it with the sysctl.  If you use a sysctl, the module will be autoloaded


      ____________________________________________________________________________________
Be a better friend, newshound, and 
know-it-all with Yahoo! Mobile.  Try it now.  http://mobile.yahoo.com/;_ylt=Ahu06i62sR8HDtDypao8Wcj9tAcJ 

