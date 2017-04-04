From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2017-04-04
Date: Tue,  4 Apr 2017 17:59:47 +0200
Message-ID: <20170404155949.30965-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47393 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754232AbdDDP7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 11:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of two patches for net/master.

The first patch by Markus Marb fixes a register read access in the ifi driver.
The second patch by Geert Uytterhoeven for the rcar driver remove the printing
of a kernel virtual address.

regards,
Marc

---

The following changes since commit 0b9aefea860063bb39e36bd7fe6c7087fed0ba87:

  tcp: minimize false-positives on TCP/GRO check (2017-04-03 18:43:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git 

for you to fetch changes up to ca257b9e2d807ab6cb2678ecc7b74aaf4651f597:

  can: rcar_can: Do not print virtual addresses (2017-04-04 17:49:59 +0200)

----------------------------------------------------------------
Geert Uytterhoeven (1):
      can: rcar_can: Do not print virtual addresses

Markus Marb (1):
      can: ifi: use correct register to read rx status

 drivers/net/can/ifi_canfd/ifi_canfd.c | 2 +-
 drivers/net/can/rcar/rcar_can.c       | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)
