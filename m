From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-01-27
Date: Fri, 27 Jan 2017 21:46:26 +0100
Message-ID: <20170127204627.11735-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:52249 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751073AbdA0Uqd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:46:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master.

It consists of a single patch by Eric Dumazet, it fixes a kernel panic at
security_sock_rcv_skb.

regards,
Marc

---

The following changes since commit 950eabbd6ddedc1b08350b9169a6a51b130ebaaf:

  ISDN: eicon: silence misleading array-bounds warning (2017-01-27 11:27:34 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.10-20170127

for you to fetch changes up to f30dc84e2d5ef45a715de546529e7693733b11fb:

  can: Fix kernel panic at security_sock_rcv_skb (2017-01-27 21:37:51 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.10-20170127

----------------------------------------------------------------
Eric Dumazet (1):
      can: Fix kernel panic at security_sock_rcv_skb

 include/linux/can/core.h |  7 +++----
 net/can/af_can.c         | 12 ++++++++++--
 net/can/af_can.h         |  3 ++-
 net/can/bcm.c            |  4 ++--
 net/can/gw.c             |  2 +-
 net/can/raw.c            |  4 ++--
 6 files changed, 20 insertions(+), 12 deletions(-)
