From: Marcos Paulo de Souza <marcos.mage@gmail.com>
Subject: [PATCH 1/2] include/net/cfg80211.h: Fix issue of make htmldocs
Date: Wed,  9 Nov 2011 18:46:12 -0200
Message-ID: <1320871572-3430-1-git-send-email-marcos.mage@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, rdunlap@xenotime.net,
	Marcos Paulo de Souza <marcos.mage@gmail.com>
To: johannes@supsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:40996 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754874Ab1KIUsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 15:48:35 -0500
Received: by yenr9 with SMTP id r9so1096035yen.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 12:48:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make documentation of member sta_modify_mask of struct
station_parameters and sta_flags of struct station_info.

Signed-off-by: Marcos Paulo de Souza <marcos.mage@gmail.com>
---
 include/net/cfg80211.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 92cf1c2..bbf6bf7 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -447,6 +447,7 @@ enum station_parameters_apply_mask {
  *	(bitmask of BIT(NL80211_STA_FLAG_...))
  * @sta_flags_set: station flags values
  *	(bitmask of BIT(NL80211_STA_FLAG_...))
+ * @sta_modify_mask: apply new uAPSD parameters
  * @listen_interval: listen interval or -1 for no change
  * @aid: AID or zero for no change
  * @plink_action: plink action to take
@@ -606,6 +607,7 @@ struct sta_bss_parameters {
  * @tx_failed: number of failed transmissions (retries exceeded, no ACK)
  * @rx_dropped_misc:  Dropped for un-specified reason.
  * @bss_param: current BSS parameters
+ * @sta_flags: Station flags mask/set
  * @generation: generation number for nl80211 dumps.
  *	This number should increase every time the list of stations
  *	changes, i.e. when a station is added or removed, so that
-- 
1.7.4.4
