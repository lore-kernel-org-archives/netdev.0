From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] asm/unaligned.h doesn't work well as the very first include
Date: Sun, 27 Apr 2008 06:19:18 +0100
Message-ID: <20080427051918.GO5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49599 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754825AbYD0FTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 01:19:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/mac80211/mesh.h      |    1 +
 net/mac80211/mesh_hwmp.c |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 742003d..9ee3aff 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -13,6 +13,7 @@
 
 #include <linux/types.h>
 #include <linux/jhash.h>
+#include <asm/unaligned.h>
 #include "ieee80211_i.h"
 
 
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 02de8f1..3df8092 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -7,7 +7,6 @@
  * published by the Free Software Foundation.
  */
 
-#include <asm/unaligned.h>
 #include "mesh.h"
 
 #define TEST_FRAME_LEN	8192
-- 
1.5.3.GIT

