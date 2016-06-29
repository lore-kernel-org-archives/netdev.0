From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2016-06-29-v2
Date: Wed, 29 Jun 2016 12:02:46 +0200
Message-ID: <1467194567-19602-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51273 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbcF2KCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 06:02:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Sorry to be sending a new pull request, but Felix had just submitted a
fairly important fix and I decided I should send it on quickly.

Now thus we have two fixes, one for the mesh refcounting issue and one
for an issue with the ethertype/length field being too long when it's
used as a length, during A-MSDU decapsulation.

Let me know if there's any problem.

Thanks,
johannes



The following changes since commit 3d5fdff46c4b2b9534fa2f9fc78e90a48e0ff724:

  wext: Fix 32 bit iwpriv compatibility issue with 64 bit Kernel (2016-06-09 09:56:11 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2016-06-29-v2

for you to fetch changes up to c041778c966c92c964033f1cdfee60a9f2b5e465:

  cfg80211: fix proto in ieee80211_data_to_8023 for frames without LLC header (2016-06-29 11:50:33 +0200)

----------------------------------------------------------------
Just two small fixes
 * fix mesh peer link counter, decrement wasn't always done at all
 * fix ethertype (length) for packets without RFC 1042 or bridge
   tunnel header

----------------------------------------------------------------
Felix Fietkau (1):
      cfg80211: fix proto in ieee80211_data_to_8023 for frames without LLC header

Jouni Malinen (1):
      mac80211: Fix mesh estab_plinks counting in STA removal case

 net/mac80211/mesh.c | 7 +++++--
 net/wireless/util.c | 2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)
