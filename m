From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCHSET net-next v2 00/07] Support for byte queue limits on various drivers
Date: Sun, 20 Oct 2013 20:13:16 +0200
Message-ID: <1382292803-18875-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:45354 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab3JTSN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 14:13:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this patchset is intended for net-next/linux-3.13.

It adds support for byte queue limits on various network drivers.

Since not all of them are fully tested by now, I added an bql_disable
module parameter, which can be used to disable the BQL code.


Any comments are welcome, thanks.
Tino Reichardt


This BQL patchset contains the following patches by now:
0001-8139too-Support-for-byte-queue-limits.patch
0002-r8169-Support-for-byte-queue-limits.patch
0003-tulip-Support-for-byte-queue-limits.patch
0004-via-rhine-Support-for-byte-queue-limits.patch
0005-via-velocity-Support-for-byte-queue-limits.patch
0006-3c59x-Support-for-byte-queue-limits.patch
0007-natsemi-Support-for-byte-queue-limits.patch

---
 drivers/net/ethernet/3com/3c59x.c           | 47 +++++++++++++++++++++++++----
 drivers/net/ethernet/dec/tulip/interrupt.c  |  4 +++
 drivers/net/ethernet/dec/tulip/tulip.h      |  1 +
 drivers/net/ethernet/dec/tulip/tulip_core.c |  9 +++++-
 drivers/net/ethernet/natsemi/natsemi.c      | 21 +++++++++++++
 drivers/net/ethernet/realtek/8139too.c      | 28 ++++++++++++++---
 drivers/net/ethernet/realtek/r8169.c        | 14 +++++++++
 drivers/net/ethernet/via/via-rhine.c        | 17 +++++++++++
 drivers/net/ethernet/via/via-velocity.c     | 18 +++++++++++
 9 files changed, 147 insertions(+), 12 deletions(-)
