From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211-next 2017-10-13
Date: Fri, 13 Oct 2017 17:53:31 +0200
Message-ID: <20171013155332.4310-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.63.242]:53600 "EHLO
        sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758379AbdJMPxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 11:53:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Sorry for the quick succession - there were a few issues with
the last pull request that only got noticed now, so I'm fixing
those here.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 90a53e4432b12288316efaa5f308adafb8d304b0:

  cfg80211: implement regdb signature checking (2017-10-11 14:24:24 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2017-10-13

for you to fetch changes up to b1b1ae2c1c150f8db5d3523c74e81eaf8cae5cbb:

  mac80211: don't track HT capability changes (2017-10-13 14:29:02 +0200)

----------------------------------------------------------------
Three fixes for the recently added new code:
 * make "make -s" silent for the certs file (Arnd)
 * fix missing CONFIG_ in extra certs symbol (Arnd)
 * use crypto_aead_authsize() to use the proper API
and two other changes:
 * remove a set-but-unused variable
 * don't track HT *capability* changes, capabilities
   are supposed to be constant (HT operation changes)

----------------------------------------------------------------
Arnd Bergmann (2):
      cfg80211: don't print log output for building shipped-certs
      cfg80211: fix CFG80211_EXTRA_REGDB_KEYDIR typo

Johannes Berg (3):
      mac80211: use crypto_aead_authsize()
      cfg80211: remove set but never used variable cf_offset
      mac80211: don't track HT capability changes

 net/mac80211/aead_api.c |  4 ++--
 net/mac80211/mlme.c     | 14 +++-----------
 net/wireless/Makefile   |  4 ++--
 net/wireless/chan.c     |  4 +---
 net/wireless/reg.c      |  2 +-
 5 files changed, 9 insertions(+), 19 deletions(-)
