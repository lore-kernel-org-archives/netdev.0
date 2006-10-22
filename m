From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] net: correct-Traffic-shaper-Kconfig
Date: Sun, 22 Oct 2006 17:40:06 +0200 (CEST)
Message-ID: <43123154321532@wsc.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cacti.profiwh.com ([85.93.165.66]:64734 "EHLO cacti.profiwh.com")
	by vger.kernel.org with ESMTP id S1750928AbWJVPj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2006 11:39:59 -0400
To: Andrew Morton <akpm@osdl.org>
Cc: <netdev@vger.kernel.org>, <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kconfig, correct traffic shaper

CBQ is no longer experimental and is located in other subtree.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 5ee1f6ff7e1f03ed8edb2461612346e9964b745d
tree debfe70d8c8338adb5ef1d860b07e4a00e760081
parent a3d771ef92954ce81363af9e0252490e2741fc21
author Jiri Slaby <ku@bellona.localdomain> Sun, 22 Oct 2006 17:34:59 +0159
committer Jiri Slaby <ku@bellona.localdomain> Sun, 22 Oct 2006 17:34:59 +0159

 drivers/net/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0a999a8..e845df9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2842,9 +2842,9 @@ config SHAPER
 	  these virtual devices. See
 	  <file:Documentation/networking/shaper.txt> for more information.
 
-	  An alternative to this traffic shaper is the experimental
-	  Class-Based Queuing (CBQ) scheduling support which you get if you
-	  say Y to "QoS and/or fair queuing" above.
+	  An alternative to this traffic shaper is the Class-Based Queuing
+	  (CBQ) scheduling support which you get if you say Y to
+	  "QoS and/or fair queuing" in "Networking options".
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called shaper.  If unsure, say N.
