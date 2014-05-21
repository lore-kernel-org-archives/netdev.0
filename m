From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2014-05-21
Date: Wed, 21 May 2014 13:15:58 +0200
Message-ID: <1400670959-14211-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52745 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaEULQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 07:16:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master, for the v3.15 release cycle, with a
single patch. Christopher R. Baker found a use after free during unloading of
the peak_pci driver. This is fixes in a patch by Stephane Grosjean.

Marc

---

The following changes since commit 78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb:

  ip_tunnel: Initialize the fallback device properly (2014-05-21 02:08:32 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git tags/linux-can-fixes-for-3.15-20140521

for you to fetch changes up to 0b5a958cf4df3a5cd578b861471e62138f55c85e:

  can: peak_pci: prevent use after free at netdev removal (2014-05-21 08:17:03 +0200)

----------------------------------------------------------------
linux-can-fixes-for-3.15-20140521

----------------------------------------------------------------
Stephane Grosjean (1):
      can: peak_pci: prevent use after free at netdev removal

 drivers/net/can/sja1000/peak_pci.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)
