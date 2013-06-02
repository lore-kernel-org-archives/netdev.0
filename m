From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 3/3] Kconfig: remove dangling references to the deleted file
Date: Sat,  1 Jun 2013 20:23:17 -0600
Message-ID: <1370139797-8912-3-git-send-email-sakiwit@gmail.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:50822 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab3FBCYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:24:51 -0400
Received: by mail-ie0-f180.google.com with SMTP id b11so7547090iee.11
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 19:24:51 -0700 (PDT)
In-Reply-To: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 202dc3fc599c1dded235d3b448d9ca924252e354 (Documentation: remove
obsolete networking/multicast.txt file) deleted the obsolete file. After
the file has been removed, clean up a couple of places where references
to the deleted file were made so that users wouldn't be confused when
they consult the Help menu.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/ipv4/Kconfig | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 8603ca8..37cf1a6 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -9,10 +9,7 @@ config IP_MULTICAST
 	  intend to participate in the MBONE, a high bandwidth network on top
 	  of the Internet which carries audio and video broadcasts. More
 	  information about the MBONE is on the WWW at
-	  <http://www.savetz.com/mbone/>. Information about the multicast
-	  capabilities of the various network cards is contained in
-	  <file:Documentation/networking/multicast.txt>. For most people, it's
-	  safe to say N.
+	  <http://www.savetz.com/mbone/>. For most people, it's safe to say N.
 
 config IP_ADVANCED_ROUTER
 	bool "IP: advanced router"
@@ -223,10 +220,8 @@ config IP_MROUTE
 	  packets that have several destination addresses. It is needed on the
 	  MBONE, a high bandwidth network on top of the Internet which carries
 	  audio and video broadcasts. In order to do that, you would most
-	  likely run the program mrouted. Information about the multicast
-	  capabilities of the various network cards is contained in
-	  <file:Documentation/networking/multicast.txt>. If you haven't heard
-	  about it, you don't need it.
+	  likely run the program mrouted. If you haven't heard about it, you
+	  don't need it.
 
 config IP_MROUTE_MULTIPLE_TABLES
 	bool "IP: multicast policy routing"
