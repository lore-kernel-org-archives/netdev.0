From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-05-23
Date: Tue, 23 May 2017 14:42:55 +0200
Message-ID: <20170523124256.23463-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38972 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932348AbdEWMnC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 08:43:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have just two fixes here, one of the scheduled scan issue that
Sander Eikelenboom found, and the other properly makes mesh more
strictly check its extension headers.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 29cee56c0be46ad01e78af104a06223c65ee0c67:

  Merge tag 'mac80211-for-davem-2017-05-08' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2017-05-08 16:02:23 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-05-23

for you to fetch changes up to 1b57b6210f4e52904393be97c62122aae69bc8aa:

  cfg80211: make cfg80211_sched_scan_results() work from atomic context (2017-05-23 14:36:46 +0200)

----------------------------------------------------------------
Just two fixes this time:
 * fix the scheduled scan "BUG: scheduling while atomic"
 * check mesh address extension flags more strictly

----------------------------------------------------------------
Arend Van Spriel (1):
      cfg80211: make cfg80211_sched_scan_results() work from atomic context

Rajkumar Manoharan (1):
      mac80211: strictly check mesh address extension mode

 net/mac80211/rx.c   |  3 ++-
 net/wireless/scan.c |  8 ++++----
 net/wireless/util.c | 10 ++++++----
 3 files changed, 12 insertions(+), 9 deletions(-)
