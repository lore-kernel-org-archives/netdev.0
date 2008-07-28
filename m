From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] NETWORKING:  Make "networking" one-click deselectable.
Date: Mon, 28 Jul 2008 15:14:03 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0807281511540.15186@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from astoria.ccjclearline.com ([64.235.106.9]:37078 "EHLO
	astoria.ccjclearline.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbYG1TPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 15:15:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use a menuconfig directive to make all of networking support one-click
deselectable from the top-level menu.

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

  not sure if i already sent this in, but it effectively duplicates
what you can already do from the submenu anyway, so might as well move
it up one level.

diff --git a/net/Kconfig b/net/Kconfig
index b986687..7612cc8 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -2,9 +2,7 @@
 # Network configuration
 #

-menu "Networking"
-
-config NET
+menuconfig NET
 	bool "Networking support"
 	---help---
 	  Unless you really know what you are doing, you should say Y here.
@@ -22,7 +20,6 @@ config NET
 	  recommended to read the NET-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.

-# Make sure that all config symbols are dependent on NET
 if NET

 menu "Networking options"
@@ -252,5 +249,3 @@ source "net/rfkill/Kconfig"
 source "net/9p/Kconfig"

 endif   # if NET
-endmenu # Networking
-

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
