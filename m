From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2009-06-14
Date: Sun, 14 Jun 2009 15:39:09 +0200
Message-ID: <cover.1244986258.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55474 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343AbZFNNjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 09:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have two more patches that should go into your networking merge. The
first is fixing a build fallout from missing dependencies on the RFKILL
subsystem. The second is fixing a build warning that is potentially
dangerous with DTL-1 hardware when using unknown packet types.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/dtl1_cs.c |    2 ++
 net/bluetooth/Kconfig       |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

through these ChangeSets:

Marcel Holtmann (2):
    Bluetooth: Fix Kconfig issue with RFKILL integration
    Bluetooth: Fix issue with uninitialized nsh.type in DTL-1 driver

