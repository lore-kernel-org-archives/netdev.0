From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: pull-request: mac80211 2017-02-06
Date: Mon,  6 Feb 2017 09:36:36 +0100
Message-ID: <20170206083637.31792-1-johannes@sipsolutions.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I know it's super late, but I was travelling last week and the
whole FILS AEAD thing only played out over the weekend anyway.
Since the FILS code is all new in this cycle, it'd be good to
have the fixes, and the others are a bit older but still would
be good to fix sooner rather than later, I think.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 7892032cfe67f4bde6fc2ee967e45a8fbaf33756:

  ip6_gre: fix ip6gre_err() invalid reads (2017-02-05 17:23:04 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-02-06

for you to fetch changes up to fd551bac4795854adaa87bad7e5136083719802b:

  nl80211: Fix mesh HT operation check (2017-02-06 07:59:07 +0100)

----------------------------------------------------------------
A few simple fixes:
 * fix FILS AEAD cipher usage to use the correct AAD vectors
   and to use synchronous algorithms
 * fix using mesh HT operation data from userspace
 * fix adding mesh vendor elements to beacons & plink frames

----------------------------------------------------------------
Jouni Malinen (2):
      mac80211: Fix FILS AEAD protection in Association Request frame
      mac80211: Allocate a sync skcipher explicitly for FILS AEAD

Masashi Honma (1):
      nl80211: Fix mesh HT operation check

Thorsten Horstmann (1):
      mac80211: Fix adding of mesh vendor IEs

 net/mac80211/fils_aead.c | 6 +++---
 net/mac80211/mesh.c      | 2 +-
 net/wireless/nl80211.c   | 1 +
 3 files changed, 5 insertions(+), 4 deletions(-)
