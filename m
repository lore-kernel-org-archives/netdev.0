From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-06-01
Date: Wed,  1 Jun 2016 12:11:14 +0200
Message-ID: <1464775875-10494-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

For now, I have just three fixes for the current cycle.

One of them, the hwsim one, becomes interesting with some pending
work to make hwsim work for unprivileged users in namespaces, and
I don't want to allow them to crash the system ... I'll thus wait
with that patch until you pull this into net-next also, so I can
pull it back for mac80211-next.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 0e6b5259824e97a0f7e7b450421ff12865d3b0e2:

  net: l2tp: Make l2tp_ip6 namespace aware (2016-05-30 00:03:53 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-06-01

for you to fetch changes up to 6fe04128f158c5ad27e7504bfdf1b12e63331bc9:

  mac80211: fix fast_tx header alignment (2016-05-31 12:14:04 +0200)

----------------------------------------------------------------
Three small fixes for the current cycle:
 * missing netlink attribute check in hwsim wmediumd (Martin)
 * fast xmit structure alignment fix (Felix)
 * mesh path flush/synchronisation fix (Bob)

----------------------------------------------------------------
Bob Copeland (1):
      mac80211: mesh: flush mesh paths unconditionally

Felix Fietkau (1):
      mac80211: fix fast_tx header alignment

Martin Willi (1):
      mac80211_hwsim: Add missing check for HWSIM_ATTR_SIGNAL

 drivers/net/wireless/mac80211_hwsim.c | 1 +
 net/mac80211/mesh.c                   | 4 ++++
 net/mac80211/sta_info.h               | 2 +-
 3 files changed, 6 insertions(+), 1 deletion(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
