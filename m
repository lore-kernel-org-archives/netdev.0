From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] minstrel: don't complain about feedback for unrequested rates
Date: Thu, 22 Jul 2010 15:46:06 -0400
Message-ID: <1279827966-25085-1-git-send-email-linville@tuxdriver.com>
References: <4C4896D5.8010802@openwrt.org>
Cc: Felix Fietkau <nbd@openwrt.org>, Sven Geggus <sven@gegg.us>,
	netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48010 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573Ab0GVUAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 16:00:19 -0400
In-Reply-To: <4C4896D5.8010802@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"It's not problematic if minstrel gets feedback for rates that it
doesn't have in its list, it should just ignore it. - Felix"

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Cc: Felix Fietkau <nbd@openwrt.org>
---
 net/mac80211/rc80211_minstrel.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index f65ce6d..778c604 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -67,7 +67,6 @@ rix_to_ndx(struct minstrel_sta_info *mi, int rix)
 	for (i = rix; i >= 0; i--)
 		if (mi->r[i].rix == rix)
 			break;
-	WARN_ON(i < 0);
 	return i;
 }
 
-- 
1.7.1.1

