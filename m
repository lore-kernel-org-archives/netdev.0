From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-01-24
Date: Tue, 24 Jan 2017 16:34:52 +0100
Message-ID: <20170124153453.15776-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

LTP found a problem last week, but I couldn't fix it since I
was travelling, so here's the fix now.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 4078b76cac68e50ccf1f76a74e7d3d5788aec3fe:

  net: dsa: Check return value of phy_connect_direct() (2017-01-23 15:43:35 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-01-24

for you to fetch changes up to 115865fa0826ed18ca04717cf72d0fe874c0fe7f:

  mac80211: don't try to sleep in rate_control_rate_init() (2017-01-24 16:31:54 +0100)

----------------------------------------------------------------
A single fix, for a sleeping context problem found by LTP.

----------------------------------------------------------------
Johannes Berg (1):
      mac80211: don't try to sleep in rate_control_rate_init()

 net/mac80211/rate.c | 2 --
 1 file changed, 2 deletions(-)
