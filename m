From: greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
Subject: [PATCH 0/5] Add ethtool stats support for Wireless Devices.
Date: Thu, 12 Apr 2012 09:32:50 -0700
Message-ID: <1334248375-22967-1-git-send-email-greearb@candelatech.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>

This enables ethtool stats for mac80211 devices.  It also
adds hooks to call down into mac80211 drivers for additional
stats.  Patches to enable this hook in ath9k will be posted
in a different series.

There was a review question about how to make the ethtool
strings line up with the data in a less error prone manner.
This patch series does NOT address that.  I think it may
be more work than it's worth to try to do this, but we
can always retro-fit such behaviour later if desired.
Many drivers have this issue, so perhaps some support
code in the ethtool core is the way to go.

Ben Greear (5):
  cfg80211: Add framework to support ethtool stats.
  mac80211: Support getting sta_info stats via ethtool.
  mac80211: Framework to get wifi-driver stats via ethtool.
  mac80211: Add more ethtools stats: survey, rates, etc
  mac80211: Add sta_state to ethtool stats.

 include/net/cfg80211.h      |   17 +++++
 include/net/mac80211.h      |   17 +++++
 net/mac80211/cfg.c          |  159 +++++++++++++++++++++++++++++++++++++++++++
 net/mac80211/driver-ops.h   |   37 ++++++++++
 net/mac80211/driver-trace.h |   15 ++++
 net/wireless/ethtool.c      |   29 ++++++++
 6 files changed, 274 insertions(+), 0 deletions(-)

-- 
1.7.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
