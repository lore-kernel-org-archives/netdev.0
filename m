From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-01-29
Date: Wed, 29 Jan 2014 22:11:00 +0100
Message-ID: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49887 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbaA2VLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 16:11:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request with three fixes for net/master, for the current release
cycle.

Arnd Bergmann provides a fix for the flexcan driver, enabling compilation on
all combinations of big and little endian on ARM and PowerPc. A patch by Ira W.
Snyder fixes uninitialized variable warnings in the janz-ican3 driver.
Rostislav Lisovy contributes a patch to propagate the SO_PRIORITY of raw
sockets to skbs.

Marc

---

The following changes since commit c044dc2132d19d8c643cdd340f21afcec177c046:

  qeth: fix build of s390 allmodconfig (2014-01-29 00:43:33 -0800)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.14-20140129

for you to fetch changes up to 73615c8669ef1c497c942cae0d5079b95824332a:

  can: janz-ican3: fix uninitialized variable warnings (2014-01-29 20:23:23 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.14-20140129

----------------------------------------------------------------
Arnd Bergmann (1):
      can: flexcan: fix flexcan driver build for big endian on ARM and little endian on PowerPc

Ira W. Snyder (1):
      can: janz-ican3: fix uninitialized variable warnings

Rostislav Lisovy (1):
      can: Propagate SO_PRIORITY of raw sockets to skbs

 drivers/net/can/Kconfig      | 2 +-
 drivers/net/can/flexcan.c    | 7 +++++--
 drivers/net/can/janz-ican3.c | 2 +-
 net/can/raw.c                | 1 +
 4 files changed, 8 insertions(+), 4 deletions(-)
