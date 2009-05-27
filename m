From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/6]: nl80211: Eliminate reference to BUS_ID_SIZE.
Date: Tue, 26 May 2009 21:39:59 -0700 (PDT)
Message-ID: <20090526.213959.50107146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kay.sievers@vrfy.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753406AbZE0EkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 00:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's going away.  Just leave the constant "20" here so that
behavior doesn't change.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/wireless/nl80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 56d729c..4b4d3c8 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -57,7 +57,7 @@ static int get_drv_dev_by_info_ifindex(struct nlattr **attrs,
 static struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] __read_mostly = {
 	[NL80211_ATTR_WIPHY] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_NAME] = { .type = NLA_NUL_STRING,
-				      .len = BUS_ID_SIZE-1 },
+				      .len = 20-1 },
 	[NL80211_ATTR_WIPHY_TXQ_PARAMS] = { .type = NLA_NESTED },
 	[NL80211_ATTR_WIPHY_FREQ] = { .type = NLA_U32 },
 	[NL80211_ATTR_WIPHY_CHANNEL_TYPE] = { .type = NLA_U32 },
-- 
1.6.3

