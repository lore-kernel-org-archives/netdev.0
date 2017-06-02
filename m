From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-06-02
Date: Fri,  2 Jun 2017 15:47:44 +0200
Message-ID: <20170602134745.15366-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43072 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751128AbdFBNsS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 09:48:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here I just have two fixes for issues that folks reported to me recently.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 029c58178b9aa0a293a86ee0da3355611ac99d07:

  Merge tag 'mac80211-for-davem-2017-05-23' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211 (2017-05-24 15:31:39 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-06-02

for you to fetch changes up to e165bc02a02c70e40d5c811c705ba269aeca0497:

  mac80211: fix dropped counter in multiqueue RX (2017-06-01 21:26:03 +0200)

----------------------------------------------------------------
Just two fixes:
 * fix the per-CPU drop counters to not be added to the
   rx_packets counter, but really the drop counter
 * fix TX aggregation start/stop callback races by setting
   bits instead of allocating and queueing an skb

----------------------------------------------------------------
Johannes Berg (2):
      mac80211: fix TX aggregation start/stop callback race
      mac80211: fix dropped counter in multiqueue RX

 net/mac80211/agg-tx.c      | 128 ++++++++++++++++++---------------------------
 net/mac80211/ht.c          |  16 ++++--
 net/mac80211/ieee80211_i.h |  14 ++---
 net/mac80211/iface.c       |  11 +---
 net/mac80211/sta_info.c    |   2 +-
 net/mac80211/sta_info.h    |   2 +
 6 files changed, 72 insertions(+), 101 deletions(-)
