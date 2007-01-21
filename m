From: Marcus Better <marcus@better.se>
Subject: [PATCH] cfg80211: Correct conditional compile of wext-common.c.
Date: Sun, 21 Jan 2007 18:19:07 +0100
Message-ID: <200701211819.07947.marcus@better.se>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from iggypop2.siwnet.net ([81.216.65.12]:60482 "EHLO
	iggypop2.siwnet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbXAURTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 12:19:16 -0500
Received: from localhost (localhost [127.0.0.1])
	by iggypop2.siwnet.net (Postfix) with SMTP id AC1E92058E6
	for <netdev@vger.kernel.org>; Sun, 21 Jan 2007 18:19:11 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wext-common.o is required if CONFIG_WIRELESS_EXT is set. Looks like `CONFIG_NET_WIRELESS' is a typo.

Signed-off-by: Marcus Better <marcus@better.se>

--- a/net/wireless/Makefile
+++ b/net/wireless/Makefile
@@ -12,5 +12,5 @@ obj-ny :=
 
 # this needs to be compiled in...
 obj-$(CONFIG_CFG80211_WEXT_COMPAT) += wext-compat.o
-obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_NET_WIRELESS) += wext-common.o
+obj-$(CONFIG_CFG80211_WEXT_COMPAT)$(CONFIG_WIRELESS_EXT) += wext-common.o
 obj-y += $(obj-yy) $(obj-yn) $(obj-ny)
-- 

