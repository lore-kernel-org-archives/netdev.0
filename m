From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2016-12-09
Date: Fri,  9 Dec 2016 13:00:13 +0100
Message-ID: <20161209120014.20292-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Closing net-next caught me by surprise, so I had to rebase a bit,
but these three patches really should go in soon. I'm not sending
them for 4.9 this late though.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit f81a8a02bb3b3e882ba6aa580230c13b5be64849:

  Merge branch 'mV88e6xxx-interrupt-fixes' (2016-11-20 21:16:14 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-12-09

for you to fetch changes up to e6f462df9acd2a3295e5d34eb29e2823220cf129:

  cfg80211/mac80211: fix BSS leaks when abandoning assoc attempts (2016-12-09 12:57:49 +0100)

----------------------------------------------------------------
Three fixes:
 * fix a logic bug introduced by a previous cleanup
 * fix nl80211 attribute confusing (trying to use
   a single attribute for two purposes)
 * fix a long-standing BSS leak that happens when an
   association attempt is abandoned

----------------------------------------------------------------
Johannes Berg (2):
      nl80211: fix logic inversion in start_nan()
      cfg80211/mac80211: fix BSS leaks when abandoning assoc attempts

Vamsi Krishna (1):
      nl80211: Use different attrs for BSSID and random MAC addr in scan req

 include/net/cfg80211.h       | 11 +++++++++++
 include/uapi/linux/nl80211.h |  7 ++++++-
 net/mac80211/mlme.c          | 21 ++++++++++++---------
 net/wireless/core.h          |  1 +
 net/wireless/mlme.c          | 12 ++++++++++++
 net/wireless/nl80211.c       | 18 ++++++++++++++++--
 net/wireless/sme.c           | 14 ++++++++++++++
 7 files changed, 72 insertions(+), 12 deletions(-)
