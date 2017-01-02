From: Johannes Berg <johannes@sipsolutions.net>
Subject: pull-request: mac80211 2017-01-02
Date: Mon,  2 Jan 2017 15:39:03 +0100
Message-ID: <20170102143904.20851-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40112 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbdABOjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Jan 2017 09:39:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Happy New Year :-)

Even though I was out for around two weeks, only a single fix came in,
I guess everyone else was also out. But if people were out, then they
won't be sending fixes soon again I suppose, and if they weren't out
they haven't sent more fixes, so I decided to send this one to you now.

Please pull and let me know if there's any problem.

Thanks,
johannes



The following changes since commit eb7903bb83cc1db31a9124d4cc8a1bddebe26e33:

  Merge branch 'l2tp-socket-lookup-fixes' (2017-01-01 22:07:25 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2017-01-02

for you to fetch changes up to 35f432a03e41d3bf08c51ede917f94e2288fbe8c:

  mac80211: initialize fast-xmit 'info' later (2017-01-02 11:28:25 +0100)

----------------------------------------------------------------
A single fix to avoid loading an skb->cb pointer too early.

----------------------------------------------------------------
Johannes Berg (1):
      mac80211: initialize fast-xmit 'info' later

 net/mac80211/tx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
