From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 3/4] mac80211: always set carrier status on open
Date: Wed, 30 May 2007 14:29:46 -0400
Message-ID: <20070530182946.GF3610@tuxdriver.com>
References: <20070530182538.GB3610@tuxdriver.com> <20070530182807.GD3610@tuxdriver.com> <20070530182858.GE3610@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070530182858.GE3610-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>

ieee80211_open should always set the carrier status since we may have set
it to off before.

Signed-off-by: Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/mac80211/ieee80211.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 145604a..4e84f24 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -2474,6 +2474,8 @@ static int ieee80211_open(struct net_device *dev)
 	if (sdata->type == IEEE80211_IF_TYPE_STA &&
 	    !local->user_space_mlme)
 		netif_carrier_off(dev);
+	else
+		netif_carrier_on(dev);
 
 	netif_start_queue(dev);
 	return 0;
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
