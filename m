From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH v2 10/10] nl80211: Prefer kcalloc over kzalloc
Date: Sun, 29 May 2016 19:54:52 -0700
Message-ID: <ca13e9bde679512a872e5136c177676d0238dc25.1464576022.git.kirtika.ruchandani@gmail.com>
References: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org, Julian.Calaby@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35998 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423AbcE3CzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 22:55:02 -0400
Content-Disposition: inline
In-Reply-To: <cover.1464576022.git.kirtika.ruchandani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the checkpatch.pl warning -
"prefer kcalloc over kzalloc with multiply"

Signed-off-by: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
---
 net/wireless/nl80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 46757af..2964406 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -9482,7 +9482,7 @@ static int nl80211_parse_wowlan_nd(struct cfg80211_registered_device *rdev,
 	struct nlattr **tb;
 	int err;

-	tb = kzalloc(NUM_NL80211_ATTR * sizeof(*tb), GFP_KERNEL);
+	tb = kcalloc(NUM_NL80211_ATTR, sizeof(*tb), GFP_KERNEL);
 	if (!tb)
 		return -ENOMEM;
