From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-05-19
Date: Mon, 19 May 2014 09:33:01 +0200
Message-ID: <1400484782-16521-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34386 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbaESHdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 03:33:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master, for the v3.15 release cycle, with a
single patch.

Oliver Hartkopp's patch removes a Kconfig option in the c_can driver, which was
added as a workaround during the v3.15 development. With all cleanup patches
this workaround is not needed anymore.

regards,
Marc

---

The following changes since commit 4f337ed5c014752b000f593182fdcfa3ecf0d166:

  MAINTAINERS: Pravin Shelar is Open vSwitch maintainer. (2014-05-18 21:04:39 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.15-20140519

for you to fetch changes up to 524369e2391f4b422d0efdd11d526a373a11a43a:

  can: c_can: remove obsolete STRICT_FRAME_ORDERING Kconfig option (2014-05-19 09:03:06 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.15-20140519

----------------------------------------------------------------
Oliver Hartkopp (1):
      can: c_can: remove obsolete STRICT_FRAME_ORDERING Kconfig option

 drivers/net/can/c_can/Kconfig |  7 -------
 drivers/net/can/c_can/c_can.c | 36 ------------------------------------
 2 files changed, 43 deletions(-)
