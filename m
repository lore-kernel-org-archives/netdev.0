From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2016-08-12
Date: Fri, 12 Aug 2016 11:20:45 +0200
Message-ID: <1470993646-14778-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This first pull request is pretty small, but there's no point
in hanging on to it for long, so here it goes anyway. Nothing
all that interesting, I think.

We might have a bunch of new APIs that were promised to me
coming up soon, for new features, but I don't know how quickly
that's actually going to happen.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6cdaf03f8c23fcbfe7d4fa6876e114193bb6b632:

  RDS: add __printf format attribute to error reporting functions (2016-08-08 16:16:21 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-08-12

for you to fetch changes up to ff9a71afc948f609c4eaba47cd6788926e7cc105:

  nl80211: explicitly check enum nl80211_mesh_power_mode (2016-08-11 20:00:37 +0200)

----------------------------------------------------------------
Not much for -next so far, but here it goes:
 * send more nl80211 events for interfaces
 * remove useless network/transport offset mangling code
 * validate beacon intervals identically for all interface types
 * use driver rate estimates for mesh
 * fix a compiler type/signedness warning

----------------------------------------------------------------
Denis Kenzior (2):
      cfg80211: always notify userspace of new wireless netdevs
      cfg80211: always notify userspace when wireless netdev is removed

Felix Fietkau (1):
      mac80211: remove skb header offset mangling in ieee80211_build_hdr

Johannes Berg (1):
      nl80211: explicitly check enum nl80211_mesh_power_mode

Maxim Altshul (2):
      mac80211: mesh: Add support for HW RC implementation
      mac80211: call get_expected_throughput only after adding station

Purushottam Kushwaha (1):
      cfg80211: identically validate beacon interval for AP/MESH/IBSS

 net/mac80211/driver-ops.h |  8 ++--
 net/mac80211/mesh_hwmp.c  | 27 ++++++++++----
 net/mac80211/sta_info.c   | 25 ++++++++++---
 net/mac80211/sta_info.h   |  2 +
 net/mac80211/tx.c         | 28 +-------------
 net/wireless/core.c       |  6 +++
 net/wireless/nl80211.c    | 94 +++++++++++++++++++++++++++--------------------
 net/wireless/nl80211.h    |  3 ++
 net/wireless/util.c       |  2 +-
 9 files changed, 112 insertions(+), 83 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
