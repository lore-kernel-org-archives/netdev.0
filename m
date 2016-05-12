From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211-next 2016-05-12
Date: Thu, 12 May 2016 13:06:01 +0200
Message-ID: <1463051162-30128-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

A few more patches for 4.7 - I listed the notable ones below in the tag
message.

Note that this isn't the tip of my tree - I merged the namespace work
for nl80211 and hwsim there, but at least the hwsim one needs some more
follow-up work which I don't want to send in after the merge window.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 557fc4a098039cf296fe33f118bab99a925fd881:

  fq: add fair queuing framework (2016-04-25 16:45:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2016-05-12

for you to fetch changes up to 46fa38e84b656f80edf83d21144221b0cad18d61:

  mac80211: allow software PS-Poll/U-APSD with AP_LINK_PS (2016-05-12 11:16:55 +0200)

----------------------------------------------------------------
Some more work for 4.7, notably:
 * completion and fixups of nla_put_64_64bit() work
 * remove a/b/g/n from wext nickname to avoid confusion
   with 11ac (which wouldn't even fit fully there due to
   string length restrictions)

along with some other minor changes/cleanups.

----------------------------------------------------------------
David Spinadel (1):
      mac80211: remove disconnected APs from BSS table

Emmanuel Grumbach (1):
      cfg80211: allow finding vendor with OUI without specifying the OUI type

Johannes Berg (6):
      nl80211: add missing kerneldoc for new *_PAD attributes
      nl80211: use nla_put_u64_64bit() for the remaining u64 attributes
      wext: remove a/b/g/n from SIOCGIWNAME
      cfg80211: remove erroneous comment
      cfg80211: make wdev_list accessible to drivers
      mac80211: allow software PS-Poll/U-APSD with AP_LINK_PS

Kanchanapally, Vidyullatha (1):
      cfg80211: Add option to report the bss entry in connect result

Mohammed Shafi Shajakhan (1):
      cfg80211/nl80211: Add support for NL80211_STA_INFO_RX_DURATION

Sara Sharon (1):
      mac80211: allow same PN for AMSDU sub-frames

 Documentation/DocBook/80211.tmpl |  1 +
 include/net/cfg80211.h           | 52 +++++++++++++++++++++++++----
 include/net/mac80211.h           | 33 ++++++++++++++++++-
 include/uapi/linux/nl80211.h     | 11 +++++++
 net/mac80211/mlme.c              |  5 +++
 net/mac80211/rx.c                | 70 +++++++++++++++++++++++++---------------
 net/mac80211/wpa.c               | 16 ++++++---
 net/wireless/chan.c              |  2 +-
 net/wireless/core.c              | 17 ++++++----
 net/wireless/core.h              |  6 ++--
 net/wireless/nl80211.c           | 53 +++++++++++++++++-------------
 net/wireless/reg.c               |  2 +-
 net/wireless/scan.c              |  8 +++--
 net/wireless/sme.c               | 32 +++++++++++++-----
 net/wireless/sysfs.c             |  2 +-
 net/wireless/util.c              |  6 ++--
 net/wireless/wext-compat.c       | 35 --------------------
 17 files changed, 230 insertions(+), 121 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
