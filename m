From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-11-23
Date: Wed, 23 Nov 2016 15:34:29 +0100
Message-ID: <20161123143430.24985-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60403 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964963AbcKWOee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master.

The patch by Oliver Hartkopp for the broadcast manager (bcm) fixes the CAN-FD
support, which may cause an out-of-bounds access otherwise.

regards,
Marc
---

The following changes since commit c9b8af1330198ae241cd545e1f040019010d44d9:

  flow_dissect: call init_default_flow_dissectors() earlier (2016-11-22 14:44:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.9-20161123

for you to fetch changes up to 5499a6b22e5508b921c447757685b0a5e40a07ed:

  can: bcm: fix support for CAN FD frames (2016-11-23 15:22:18 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.9-20161123

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: bcm: fix support for CAN FD frames

 net/can/bcm.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)
