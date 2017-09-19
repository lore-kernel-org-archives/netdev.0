From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-11-19
Date: Tue, 19 Sep 2017 09:20:47 +0200
Message-ID: <20170919072048.8484-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51274 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750747AbdISHUx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 03:20:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a new set of two small changes to prevent null pointer
dereferences on malformed netlink messages.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit 126f760ca94dae77425695f9f9238b731de86e32:

  rds: Fix incorrect statistics counting (2017-09-07 20:07:13 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-11-19

for you to fetch changes up to 265698d7e6132a2d41471135534f4f36ad15b09c:

  nl80211: fix null-ptr dereference on invalid mesh configuration (2017-09-18 22:51:07 +0200)

----------------------------------------------------------------
Just two netlink fixes, both allowing privileged users
to crash the kernel with malformed netlink messages.

----------------------------------------------------------------
Johannes Berg (1):
      nl80211: fix null-ptr dereference on invalid mesh configuration

Vladis Dronov (1):
      nl80211: check for the required netlink attributes presence

 net/wireless/nl80211.c | 6 ++++++
 1 file changed, 6 insertions(+)
