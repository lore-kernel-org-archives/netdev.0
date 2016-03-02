From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-03-02
Date: Wed,  2 Mar 2016 14:48:02 +0100
Message-ID: <1456926483-9420-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45116 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbcCBNsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 08:48:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are a few more fixes for the current cycle; the MAINTAINERS patch
isn't really a fix for the tree, but helps the kbuild robot and clearly
can't be causing any regressions :)

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit b86071528f3261ab592fad5b9b1a02aea3dcabf3:

  cfg80211: stop critical protocol session upon disconnect event (2016-02-23 10:41:24 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-03-02

for you to fetch changes up to 2af8c4dc2e9c7038aefe9a822aa1df62e2b106b7:

  mac80211_hwsim: treat as part of mac80211 for MAINTAINERS (2016-03-02 14:16:48 +0100)

----------------------------------------------------------------
Here are a few more fixes for the current cycle:
 * check GCMP encryption vs. fragmentation properly; we'd found
   this problem quite a while ago but waited for the 802.11 spec
   to be updated
 * fix RTS/CTS logic in minstrel_ht
 * fix RX of certain public action frames in AP mode
 * add mac80211_hwsim to MAC80211 in MAINTAINERS, this helps
   the kbuild robot pick up the right tree for it

----------------------------------------------------------------
Felix Fietkau (1):
      mac80211: minstrel_ht: fix a logic error in RTS/CTS handling

Johannes Berg (2):
      mac80211: check PN correctly for GCMP-encrypted fragmented MPDUs
      mac80211_hwsim: treat as part of mac80211 for MAINTAINERS

Jouni Malinen (1):
      mac80211: Fix Public Action frame RX in AP mode

 MAINTAINERS                        |  1 +
 net/mac80211/ieee80211_i.h         |  2 +-
 net/mac80211/rc80211_minstrel_ht.c |  2 +-
 net/mac80211/rx.c                  | 37 ++++++++++++++++++++++++++++---------
 4 files changed, 31 insertions(+), 11 deletions(-)
