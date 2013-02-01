From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-02-01
Date: Fri,  1 Feb 2013 10:25:13 +0100
Message-ID: <1359710714-1565-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51237 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211Ab3BAJZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 04:25:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here's a patch for net for the v3.8 release cycle. Alexander Stein noticed that
the c_can hardware has a fixed bit in the IFx_MASK2 register. His patch fixes
writing of this register by always setting this bit.

regards,
Marc

---

The following changes since commit 66555e92fb7a619188c02cceae4bbc414f15f96d:

  tcp: detect SYN/data drop when F-RTO is disabled (2013-01-31 14:20:07 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.8

for you to fetch changes up to 2bd3bc4e8472424f1a6009825397639a8968920a:

  can: c_can: Set reserved bit in IFx_MASK2 to 1 on write (2013-02-01 10:20:22 +0100)

----------------------------------------------------------------
Alexander Stein (1):
      can: c_can: Set reserved bit in IFx_MASK2 to 1 on write

 drivers/net/can/c_can/c_can.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)
