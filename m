From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH v2 07/10] nl80211: Avoid multiple assignments on same line
Date: Sun, 29 May 2016 19:53:22 -0700
Message-ID: <637c25b980379d1a98d7c57cc247d49ef295cbc5.1464576022.git.kirtika.ruchandani@gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org, Julian.Calaby@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36572 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbcE3Cxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 22:53:30 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the checkpatch.pl warning "multiple assignments
should be avoided."

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index ad7cdce..6f8e2a7 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2603,7 +2603,8 @@ static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)

 	memset(&params, 0, sizeof(params));

-	otype = ntype = dev->ieee80211_ptr->iftype;
+	otype = dev->ieee80211_ptr->iftype;
+	ntype = dev->ieee80211_ptr->iftype;

 	if (info->attrs[NL80211_ATTR_IFTYPE]) {
 		ntype = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
