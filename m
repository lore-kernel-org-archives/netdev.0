From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2010-02-27
Date: Sat, 27 Feb 2010 23:38:29 +0100
Message-ID: <cover.1267276098.git.marcel@holtmann.org>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:54686 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936345Ab0B0WkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:40:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was hoping to get the Enhanced L2CAP updates ready for this merge window,
but in the end they were not stable enough. So I removed all the L2CAP
changes out of this merge request.

The leftovers are small updates and bug fixes. The only bigger change is
a patch that adds per controller debugfs. That way drivers don't have to
deal with it on their own. This avoids clashes with multiple controllers
attached to the same system. The Marvell driver is one of the examples
where this is needed. Their debugfs support and multiple controllers was
not done properly.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/ath3k.c          |    2 +
 drivers/bluetooth/bcm203x.c        |    2 +-
 drivers/bluetooth/bfusb.c          |    2 +-
 drivers/bluetooth/bluecard_cs.c    |    2 +-
 drivers/bluetooth/bpa10x.c         |    2 +-
 drivers/bluetooth/bt3c_cs.c        |    2 +-
 drivers/bluetooth/btmrvl_debugfs.c |   14 ++--
 drivers/bluetooth/btmrvl_main.c    |    2 +-
 drivers/bluetooth/btmrvl_sdio.c    |    4 +-
 drivers/bluetooth/btsdio.c         |    2 +-
 drivers/bluetooth/btuart_cs.c      |    2 +-
 drivers/bluetooth/btusb.c          |    2 +-
 drivers/bluetooth/dtl1_cs.c        |    2 +-
 drivers/bluetooth/hci_ldisc.c      |    2 +-
 drivers/bluetooth/hci_vhci.c       |    2 +-
 include/net/bluetooth/hci.h        |    6 ++-
 include/net/bluetooth/hci_core.h   |    5 +-
 net/bluetooth/hci_core.c           |   12 +++-
 net/bluetooth/hci_event.c          |    1 +
 net/bluetooth/hci_sock.c           |    2 +-
 net/bluetooth/hci_sysfs.c          |  122 +++++++++++++++++++++++++----------
 21 files changed, 129 insertions(+), 63 deletions(-)

through these ChangeSets:

Dan Carpenter (1):
    Bluetooth: Add missing kfree() on error path in Atheros driver

Johann Felix Soden (1):
    Bluetooth: Fix out of scope variable access in hci_sock_cmsg()

Marcel Holtmann (4):
    Bluetooth: Convert controller hdev->type to hdev->bus
    Bluetooth: Convert inquiry cache to use debugfs instead of sysfs
    Bluetooth: Convert Marvell driver to use per adapter debugfs
    Bluetooth: Add controller types for BR/EDR and 802.11 AMP

Márton Németh (1):
    Bluetooth: Make USB device id constant

Peter Huewe (1):
    Bluetooth: Add __init/__exit macros to Marvell SDIO driver

Stephen Coe (1):
    Bluetooth: Add SCO fallback for unsupported feature error

