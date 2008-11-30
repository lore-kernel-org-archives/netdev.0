From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2008-11-30
Date: Sun, 30 Nov 2008 16:58:29 +0100
Message-ID: <1228060709.9176.26.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45573 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbYK3P6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 10:58:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is the first batch of pending patches for the 2.6.29 kernel
release. The biggest one is the switch to use dynamic_printk for
debugging and the removal of the hci_usb driver. I also made the HCI
Reset quirk default so that all future hardware just works and we only
have to add quirks for old hardware.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/Kconfig         |   20 -
 drivers/bluetooth/Makefile        |    1 -
 drivers/bluetooth/bcm203x.c       |    9 +-
 drivers/bluetooth/bfusb.c         |   11 +-
 drivers/bluetooth/bpa10x.c        |    7 +-
 drivers/bluetooth/bt3c_cs.c       |    8 +-
 drivers/bluetooth/btsdio.c        |    6 +-
 drivers/bluetooth/btusb.c         |  229 +++++---
 drivers/bluetooth/hci_bcsp.c      |    5 -
 drivers/bluetooth/hci_h4.c        |    5 -
 drivers/bluetooth/hci_ldisc.c     |    9 +-
 drivers/bluetooth/hci_usb.c       | 1136 -------------------------------------
 drivers/bluetooth/hci_usb.h       |  129 -----
 drivers/bluetooth/hci_vhci.c      |    5 -
 include/net/bluetooth/bluetooth.h |    4 +-
 include/net/bluetooth/hci.h       |    2 +-
 net/bluetooth/af_bluetooth.c      |   50 +-
 net/bluetooth/bnep/bnep.h         |    2 +-
 net/bluetooth/bnep/core.c         |    5 -
 net/bluetooth/bnep/netdev.c       |    5 -
 net/bluetooth/bnep/sock.c         |    5 -
 net/bluetooth/cmtp/capi.c         |    5 -
 net/bluetooth/cmtp/core.c         |    5 -
 net/bluetooth/cmtp/sock.c         |    5 -
 net/bluetooth/hci_conn.c          |    5 -
 net/bluetooth/hci_core.c          |   11 +-
 net/bluetooth/hci_event.c         |    5 -
 net/bluetooth/hci_sock.c          |    5 -
 net/bluetooth/hci_sysfs.c         |    7 +-
 net/bluetooth/hidp/core.c         |    5 -
 net/bluetooth/hidp/sock.c         |    5 -
 net/bluetooth/l2cap.c             |    5 -
 net/bluetooth/rfcomm/core.c       |    5 -
 net/bluetooth/rfcomm/sock.c       |    7 +-
 net/bluetooth/rfcomm/tty.c        |   35 +-
 net/bluetooth/sco.c               |    5 -
 36 files changed, 209 insertions(+), 1559 deletions(-)
 delete mode 100644 drivers/bluetooth/hci_usb.c
 delete mode 100644 drivers/bluetooth/hci_usb.h

through these ChangeSets:

Julia Lawall (1):
    Bluetooth: Change simple_strtol to simple_strtoul

Marcel Holtmann (10):
    Bluetooth: Add fine grained mem_flags usage to btusb driver
    Bluetooth: Handle bulk URBs in btusb driver from notify callback
    Bluetooth: Add suspend/resume support to btusb driver
    Bluetooth: Fix warnings for bt_key_strings and bt_slock_key_strings
    Bluetooth: Remove deprecated hci_usb driver
    Bluetooth: Send HCI Reset command by default on device initialization
    Bluetooth: Allow SCO audio with Asus WL-BTD202 dongle
    Bluetooth: Enable per-module dynamic debug messages
    Bluetooth: Fix format arguments warning
    Bluetooth: Fix RFCOMM release oops when device is still in use

Nick Pelly (1):
    Bluetooth: Respect HCI_UART_DEBUG config in hci_ll.c

Tomas Winkler (1):
    Bluetooth: Fix TX error path in btsdio driver

Vegard Nossum (1):
    Bluetooth: Fix leak of uninitialized data to userspace



