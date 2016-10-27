From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-10-27
Date: Thu, 27 Oct 2016 10:05:49 +0200
Message-ID: <20161027080550.31309-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Before I go off for LPC and the workshop and everything, I have
two fixes. Neither is very important, but I figured I'd get them
out since I won't have any others soon.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit b4f0fd4baa90ecce798e0d26d1cce8f4457f2028:

  qed: Use list_move_tail instead of list_del/list_add_tail (2016-10-18 16:40:41 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-10-27

for you to fetch changes up to b4f7f4ad425a84fd5d40da21aff8681997b25ff9:

  mac80211: fix some sphinx warnings (2016-10-26 08:01:07 +0200)

----------------------------------------------------------------
Just two fixes:
 * a fix to process all events while suspending, so any
   potential calls into the driver are done before it is
   suspended
 * small markup fixes for the sphinx documentation conversion
   that's coming into the tree via the doc tree

----------------------------------------------------------------
Jani Nikula (1):
      mac80211: fix some sphinx warnings

Johannes Berg (1):
      cfg80211: process events caused by suspend before suspending

 include/net/mac80211.h | 21 +++++++++++++--------
 net/wireless/sysfs.c   |  5 ++++-
 2 files changed, 17 insertions(+), 9 deletions(-)
