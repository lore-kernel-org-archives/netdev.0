From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-12-17
Date: Thu, 17 Dec 2009 12:22:42 -0800
Message-ID: <cover.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33948 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765255AbZLQUXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are a few fixes for inclusion into 2.6.33 kernel. They are all small
and mostly one-liners.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/btusb.c |    1 +
 net/bluetooth/hidp/core.c |    2 +-
 net/bluetooth/l2cap.c     |    5 +++--
 3 files changed, 5 insertions(+), 3 deletions(-)

through these ChangeSets:

Andrei Emeltchenko (1):
    Bluetooth: Fix L2CAP locking scheme regression

Gustavo F. Padovan (2):
    Bluetooth: Fix unset of RemoteBusy flag for L2CAP
    Bluetooth: Ack L2CAP I-frames before retransmit missing packet

Oliver Neukum (1):
    Bluetooth: Prevent ill-timed autosuspend in USB driver

Roel Kluin (1):
    Bluetooth: Fix PTR_ERR return of wrong pointer in hidp_setup_hid()

