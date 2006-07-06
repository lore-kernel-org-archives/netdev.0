From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Thu, 06 Jul 2006 22:09:20 +0200
Message-ID: <1152216560.20938.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:24484 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1750800AbWGFUJU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 16:09:20 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

this is the second part of pending updates of the Bluetooth subsystem
for the upcoming 2.6.18 kernel. A couple of them are only coding style
cleanups which I failed to submit for the previous kernel release. They
slipped somehow. The rest is driver model integration stuff. Please push
them to Linus as soon as possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/bfusb.c        |  322 +++++++++++++++++++--------------------
 drivers/bluetooth/hci_ldisc.c    |    4
 drivers/bluetooth/hci_vhci.c     |   97 +++++------
 include/net/bluetooth/hci_core.h |    6
 net/bluetooth/bnep/core.c        |   26 ++-
 net/bluetooth/cmtp/capi.c        |    4
 net/bluetooth/cmtp/core.c        |    3
 net/bluetooth/hci_conn.c         |    8
 net/bluetooth/hci_core.c         |    7
 net/bluetooth/hci_sysfs.c        |  115 +++++++++++--
 net/bluetooth/hidp/core.c        |   26 ++-
 net/bluetooth/rfcomm/core.c      |    9 -
 net/bluetooth/rfcomm/tty.c       |   24 ++
 net/bluetooth/sco.c              |   12 -
 14 files changed, 405 insertions(+), 258 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:59:00 +0200

    [Bluetooth] Avoid NULL pointer dereference with tty->driver

    This patch checks for tty->driver before trying to call flush_buffer().

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:58:55 +0200

    [Bluetooth] Code cleanup of the drivers source code

    This patch is an attempt to cleanup the drivers source code to make all
    Bluetooth drivers look more unique.

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:58:50 +0200

    [Bluetooth] Remaining transitions to use kzalloc()

    This patch makes the remaining transitions to use kzalloc().

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:58:45 +0200

    [Bluetooth] Integrate services into the driver model

    This patch integrates the services of the Bluetooth protocols RFCOMM,
    BNEP and HIDP into the driver model. This makes it possible to assign
    the virtual TTY, network and input devices to a specific Bluetooth
    connection.

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:58:40 +0200

    [Bluetooth] Integrate low-level connections into the driver model

    This patch integrates the low-level connections (ACL and SCO) into the
    driver model. Every connection is presented as device with the parent
    set to its host controller device.

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 21:58:35 +0200

    [Bluetooth] Remove unused host controller attributes

    This patch removes the unused device attribute entries for the Bluetooth
    host controllers.

    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



