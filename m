From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-12-16
Date: Fri, 16 Dec 2016 13:39:56 +0100
Message-ID: <20161216123957.16744-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57308 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757615AbcLPMkB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 07:40:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Since you seem to be updating net, I thought I'd send you a few fixes.
These aren't really all that important though, so if you want to let
them wait for a bit I can live with that.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 8fa3b6f9392bf6d90cb7b908e07bd90166639f0a:

  Merge tag 'cris-for-4.10' of git://git.kernel.org/pub/scm/linux/kernel/git/jesper/cris (2016-12-12 09:06:38 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-12-16

for you to fetch changes up to a17d93ff3a950fefaea40e4a4bf3669b9137c533:

  mac80211: fix legacy and invalid rx-rate report (2016-12-15 10:54:48 +0100)

----------------------------------------------------------------
Three fixes:
 * avoid a WARN_ON() when trying to use WEP with AP_VLANs
 * ensure enough headroom on mesh forwarding packets
 * don't report unknown/invalid rates to userspace

----------------------------------------------------------------
Ben Greear (1):
      mac80211: fix legacy and invalid rx-rate report

Cedric Izoard (1):
      mac80211: Ensure enough headroom when forwarding mesh pkt

Johannes Berg (1):
      mac80211: don't call drv_set_default_unicast_key() for VLANs

 net/mac80211/key.c      |  3 ++-
 net/mac80211/rx.c       |  2 +-
 net/mac80211/sta_info.c | 14 ++++++++------
 3 files changed, 11 insertions(+), 8 deletions(-)
