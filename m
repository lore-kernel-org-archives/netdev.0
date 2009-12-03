From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2009-12-03
Date: Thu,  3 Dec 2009 19:45:37 +0100
Message-ID: <cover.1259865279.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37640 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755555AbZLCSpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are the patches for the 2.6.33 merge window. Sorry for being a bit
late, but I got dragged into some other work. Besides the ongoing work on
the L2CAP ERTM support it is only bug fixes and cleanups.

I did base this against your net-next tree. If you want me to rebase it,
then let me know.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/btmrvl_debugfs.c |    1 -
 drivers/bluetooth/btmrvl_drv.h     |    1 +
 drivers/bluetooth/btmrvl_main.c    |   55 +++++++++++-------
 drivers/bluetooth/btmrvl_sdio.c    |    4 +
 drivers/bluetooth/hci_vhci.c       |   20 +------
 include/net/bluetooth/hci_core.h   |   39 +------------
 include/net/bluetooth/l2cap.h      |    2 +-
 net/bluetooth/bnep/core.c          |    5 +-
 net/bluetooth/hci_core.c           |   39 +++++++++++--
 net/bluetooth/hci_event.c          |    6 +-
 net/bluetooth/hci_sock.c           |   11 +++-
 net/bluetooth/hidp/core.c          |    9 +++
 net/bluetooth/l2cap.c              |  110 +++++++++++++++++++++++++++--------
 net/bluetooth/rfcomm/core.c        |    6 ++
 14 files changed, 192 insertions(+), 116 deletions(-)

through these ChangeSets:

Amitkumar Karwar (1):
    Bluetooth: Enable auto sleep mode for btmrvl driver

Ben Hutchings (1):
    Bluetooth: Declare MODULE_FIRMWARE for Marvell SDIO driver

Gustavo F. Padovan (5):
    Bluetooth: Initialize variables and timers for both channel's sides
    Bluetooth: Fix unset of SrejActioned flag
    Bluetooth: Fix sending ReqSeq on I-frames
    Bluetooth: Implement RejActioned flag
    Bluetooth: Fix 'SendRRorRNR' to send the ReqSeq value

Jiri Kosina (1):
    Bluetooth: Implement raw output support for HIDP layer

Marcel Holtmann (7):
    Bluetooth: Remove unused global minor variable
    Bluetooth: Fix miscdev ops owner for virtual driver
    Bluetooth: Return ENETDOWN when interface is down
    Bluetooth: Turn hci_recv_frame into an exported function
    Bluetooth: Unobfuscate tasklet_schedule usage
    Bluetooth: Add L2CAP option for max transmit value
    Bluetooth: Add RFCOMM option to use L2CAP ERTM mode

Rahul Tank (1):
    Bluetooth: Removal of unused variable in btmrvl driver

Thomas Gleixner (1):
    Bluetooth: Remove stub ioctl in hci_vhci

Vikram Kandukuri (1):
    Bluetooth: Fix handling of BNEP setup connection requests

