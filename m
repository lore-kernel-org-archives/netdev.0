From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2016-06-09
Date: Thu,  9 Jun 2016 14:47:57 +0200
Message-ID: <1465476478-23080-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here are two more fixes for the current cycle, please pull.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 6fe04128f158c5ad27e7504bfdf1b12e63331bc9:

  mac80211: fix fast_tx header alignment (2016-05-31 12:14:04 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-06-09

for you to fetch changes up to 3d5fdff46c4b2b9534fa2f9fc78e90a48e0ff724:

  wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel (2016-06-09 09:56:11 +0200)

----------------------------------------------------------------
Two more fixes for now:
 * a fix for a long-standing iwpriv 32/64 compat issue
 * two fairly recently introduced (4.6) warning asking for
   symmetric operations are erroneous and I remove them

----------------------------------------------------------------
Johannes Berg (1):
      cfg80211: remove get/set antenna and tx power warnings

Prasun Maiti (1):
      wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel

 net/wireless/core.c      |  2 --
 net/wireless/wext-core.c | 25 +++++++++++++++++++++++--
 2 files changed, 23 insertions(+), 4 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
