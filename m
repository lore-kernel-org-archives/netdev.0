From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove Documentation/networking/routing.txt
Date: Mon, 5 Nov 2007 18:06:01 +0100
Message-ID: <20071105170601.GU12045@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59465 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757145AbXKERGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 12:06:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This file is so outdated that I can't see any value in keeping it.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/networking/00-INDEX    |    2 -
 Documentation/networking/routing.txt |   46 ---------------------------
 2 files changed, 48 deletions(-)

54b248bbff6345016e060136cfb5c09d43b26b69 
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 5e21f37..563e442 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -82,6 +82,4 @@ policy-routing.txt
 ray_cs.txt
 	- Raylink Wireless LAN card driver info.
-routing.txt
-	- the new routing mechanism
 shaper.txt
 	- info on the module that can shape/limit transmitted traffic.
diff --git a/Documentation/networking/routing.txt b/Documentation/networking/routing.txt
deleted file mode 100644
index a26838b..0000000
--- a/Documentation/networking/routing.txt
+++ /dev/null
@@ -1,46 +0,0 @@
-The directory ftp.inr.ac.ru:/ip-routing contains:
-
-- iproute.c - "professional" routing table maintenance utility.
-
-- rdisc.tar.gz - rdisc daemon, ported from Sun.
-	STRONGLY RECOMMENDED FOR ALL HOSTS.
-
-- routing.tgz - original Mike McLagan's route by source patch.
-		Currently it is obsolete.
-
-- gated.dif-ss<NEWEST>.gz - gated-R3_6Alpha_2 fixes.
-	        Look at README.gated
-
-- mrouted-3.8.dif.gz - mrouted-3.8 fixes.
-
-- rtmon.c - trivial debugging utility: reads and stores netlink.
-
-
-NEWS for user.
-
-- Policy based routing. Routing decisions are made on the basis
-  not only of destination address, but also source address,
-  TOS and incoming interface.
-- Complete set of IP level control messages.
-  Now Linux is the only OS in the world complying to RFC requirements.
-  Great win 8)
-- New interface addressing paradigm.
-  Assignment of address ranges to interface,
-  multiple prefixes etc. etc.
-  Do not bother, it is compatible with the old one. Moreover:
-- You don't need to do "route add aaa.bbb.ccc... eth0" anymore,
-  it is done automatically.
-- "Abstract" UNIX sockets and security enhancements.
-  This is necessary to use TIRPC and TLI emulation library.
-
-NEWS for hacker.
-
-- New destination cache. Flexible, robust and just beautiful.
-- Network stack is reordered, simplified, optimized, a lot of bugs fixed.
-  (well, and new bugs were introduced, but I haven't seen them yet 8))
-  It is difficult to describe all the changes, look into source.
-
-If you see this file, then this patch works 8)
-
-Alexey Kuznetsov.
-kuznet@ms2.inr.ac.ru

