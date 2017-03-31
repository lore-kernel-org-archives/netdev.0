From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-03-31
Date: Fri, 31 Mar 2017 08:14:34 +0200
Message-ID: <20170331061435.24667-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Before netconf, I figured I'd get these two fixes to you, at least
I wanted to have them out of the way.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit b768b16de58d5e0b1d7c3f936825b25327ced20c:

  openvswitch: Fix refcount leak on force commit. (2017-03-28 21:56:11 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-03-31

for you to fetch changes up to 7d65f82954dadbbe7b6e1aec7e07ad17bc6d958b:

  mac80211: unconditionally start new netdev queues with iTXQ support (2017-03-29 14:20:40 +0200)

----------------------------------------------------------------
Two fixes:
 * don't block netdev queues (indefinitely!) if mac80211
   manages traffic queueing itself
 * check wiphy registration before checking for ops
   on resume, to avoid crash

----------------------------------------------------------------
Arend Van Spriel (1):
      cfg80211: check rdev resume callback only for registered wiphy

Johannes Berg (1):
      mac80211: unconditionally start new netdev queues with iTXQ support

 net/mac80211/iface.c |  3 ++-
 net/wireless/sysfs.c | 10 ++++------
 2 files changed, 6 insertions(+), 7 deletions(-)
