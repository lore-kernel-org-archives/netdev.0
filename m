From: Tino Reichardt <milky-kernel@mcmilk.de>
Subject: [PATCHSET v1 00/07] Support for byte queue limits on various network interfaces
Date: Mon, 14 Oct 2013 20:26:16 +0200
Message-ID: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lotte.svc-box.de ([80.252.109.10]:35470 "EHLO lotte.svc-box.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756152Ab3JNSfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Oct 2013 14:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this patchset adds support for byte queue limits for various network drivers.

These drivers are used as WAN interface on servers that I am managing. So
it would be nice, if support for BQL / codel for these drivers will make it
into the mainline... @ some time ;)


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
 drivers/net/ethernet/3com/3c59x.c           | 37 ++++++++++++++++++++++++-----
 drivers/net/ethernet/dec/tulip/interrupt.c  |  3 +++
 drivers/net/ethernet/dec/tulip/tulip_core.c |  2 ++
 drivers/net/ethernet/natsemi/natsemi.c      | 10 ++++++++
 drivers/net/ethernet/realtek/8139too.c      |  8 +++++++
 drivers/net/ethernet/realtek/r8169.c        |  7 ++++++
 drivers/net/ethernet/via/via-rhine.c        | 10 ++++++++
 drivers/net/ethernet/via/via-velocity.c     |  9 +++++++
 8 files changed, 80 insertions(+), 6 deletions(-)
