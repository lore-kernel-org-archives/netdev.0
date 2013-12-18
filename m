From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 5/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 15:44:16 +0800
Message-ID: <1387352656-860-6-git-send-email-chenweilong@huawei.com>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:15729 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab3LRHyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:54:25 -0500
In-Reply-To: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Space prohibited next to the parenthesis

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac80211/rc80211_minstrel_ht.c | 2 +-
 net/mac80211/sta_info.h            | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index 4096ff6..1c47bf4 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -63,7 +63,7 @@
 
 #define CCK_DURATION(_bitrate, _short, _len)		\
 	(1000 * (10 /* SIFS */ +			\
-	 (_short ? 72 + 24 : 144 + 48 ) +		\
+	 (_short ? 72 + 24 : 144 + 48) +		\
 	 (8 * (_len + 4) * 10) / (_bitrate)))
 
 #define CCK_ACK_DURATION(_bitrate, _short)			\
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index 3ef06a2..698eca7 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -528,7 +528,7 @@ void for_each_sta_info_type_check(struct ieee80211_local *local,
 }
 
 #define for_each_sta_info(local, _addr, _sta, nxt)			\
-	for (	/* initialise loop */					\
+	for (/* initialise loop */					\
 		_sta = rcu_dereference(local->sta_hash[STA_HASH(_addr)]),\
 		nxt = _sta ? rcu_dereference(_sta->hnext) : NULL;	\
 		/* typecheck */						\
-- 
1.7.12
