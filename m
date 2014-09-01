From: Shakil A Khan <shakilk1729@gmail.com>
Subject: [PATCH 2/2] nl80211.c: Fixed the wdev_id being used uninitialized.
Date: Mon,  1 Sep 2014 07:54:27 -0400
Message-ID: <1409572467-50908-1-git-send-email-shakilk1729@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, linville@tuxdriver.com,
	johannes@sipsolutions.net, Shakil A Khan <shakilk1729@gmail.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:47723 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbaIALyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 07:54:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Shakil A Khan <shakilk1729@gmail.com>
---
 net/wireless/nl80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index df7b133..6cd7df2 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -76,7 +76,7 @@ __cfg80211_wdev_from_attrs(struct net *netns, struct nlattr **attrs)
 	struct wireless_dev *result = NULL;
 	bool have_ifidx = attrs[NL80211_ATTR_IFINDEX];
 	bool have_wdev_id = attrs[NL80211_ATTR_WDEV];
-	u64 wdev_id;
+	u64 wdev_id = 0;
 	int wiphy_idx = -1;
 	int ifidx = -1;
 
-- 
1.7.1
