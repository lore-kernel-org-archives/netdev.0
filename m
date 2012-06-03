From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-06-03
Date: Mon,  4 Jun 2012 00:21:56 +0200
Message-ID: <1338762120-12695-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55214 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754846Ab2FCWWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2012 18:22:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here is a series of patches intended for v3.5, targeting net/master.

The first three patches are by AnilKumar Ch and fix problems in the c_can
driver. While extending the c_can driver for the Bosch's d_can hardware
he found three problems in the existing driver: first a race condition in
the open() function, second a interrupt thrashing issue and third a
off-by-one when looking for transmitted packets.

The fourth patch is by Joe Perches, it fixes a misuse of | for & in the
cc770 driver.

regards, Marc

---

The following changes since commit 9ca3cc6f3026946ba655e863ca2096339e667639:

  fec_mpc52xx: fix timestamp filtering (2012-06-02 17:09:08 -0400)

are available in the git repository at:
  git@gitorious.org:linux-can/linux-can.git master

AnilKumar Ch (3):
      can: c_can: fix "BUG! echo_skb is occupied!" during transmit
      can: c_can: fix an interrupt thrash issue with c_can driver
      can: c_can: fix race condition in c_can_open()

Joe Perches (1):
      can: cc770: Fix likely misuse of | for &

 drivers/net/can/c_can/c_can.c          |   16 +++++++++-------
 drivers/net/can/c_can/c_can.h          |    1 +
 drivers/net/can/cc770/cc770_platform.c |    2 +-
 3 files changed, 11 insertions(+), 8 deletions(-)
