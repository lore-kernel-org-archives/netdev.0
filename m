From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] d80211: Fix errorcode in ieee80211_update_hw
Date: Sat, 9 Dec 2006 23:09:43 +0100
Message-ID: <200612092309.44166.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49721
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758682AbWLIWKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 17:10:47 -0500
To: Jiri Benc <jbenc@suse.cz>, linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_update_hw should return a proper error code
instead of hardcoded -1.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-12-07 17:25:19.000000000 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-12-09 23:07:43.000000000 +0100
@@ -4644,7 +4644,7 @@ int ieee80211_update_hw(struct ieee80211
 
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
-		return -1;
+		return -EINVAL;
 
 	ieee80211_precalc_modes(local);
 	local->hw.conf.phymode = hw->modes[0].mode;


-- 
Greetings Michael.
