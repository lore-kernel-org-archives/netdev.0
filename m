From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-10-16
Date: Mon, 16 Oct 2017 15:46:17 +0200
Message-ID: <20171016134618.30810-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's a fix, for a small part of the "KRACK" announced today
(krackattacks.com).

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit c0576e3975084d4699b7bfef578613fb8e1144f6:

  net: call cgroup_sk_alloc() earlier in sk_clone_lock() (2017-10-10 20:24:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-10-16

for you to fetch changes up to fdf7cb4185b60c68e1a75e61691c4afdc15dea0e:

  mac80211: accept key reinstall without changing anything (2017-10-16 13:02:03 +0200)

----------------------------------------------------------------
Just a single fix, for a WoWLAN-related part of CVE-2017-13080.

----------------------------------------------------------------
Johannes Berg (1):
      mac80211: accept key reinstall without changing anything

 net/mac80211/key.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)
