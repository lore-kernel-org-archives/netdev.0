From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-next-2.6 2009-06-08
Date: Mon, 08 Jun 2009 15:05:04 +0200
Message-ID: <1244466304.24950.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:38072 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbZFHNFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 09:05:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are the Bluetooth patches for the 2.6.31 kernel release. They are
mostly cleanups and removal of dead/unused code. However we do integrate
with the re-written RFKILL subsystem now. This gives us proper soft-kill
support for internal and external devices.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-next-2.6.git master

This will update the following files:

 drivers/bluetooth/hci_vhci.c      |   90 ++++++----------------------
 include/net/bluetooth/bluetooth.h |    6 --
 include/net/bluetooth/hci_core.h  |    2 +
 include/net/bluetooth/l2cap.h     |   71 ++++++++++++++++-------
 net/bluetooth/hci_core.c          |   41 +++++++++++++-
 net/bluetooth/l2cap.c             |  117 +++++++++++++++++++++----------------
 net/bluetooth/rfcomm/core.c       |   12 ++--
 7 files changed, 184 insertions(+), 155 deletions(-)

through these ChangeSets:

Gustavo F. Padovan (3):
    Bluetooth: Use macros for L2CAP channel identifiers
    Bluetooth: Use macro for L2CAP hint mask on receiving config request
    Bluetooth: Fix errors and warnings in L2CAP reported by checkpatch.pl

Marcel Holtmann (8):
    Bluetooth: Remove unnecessary variable initialization
    Bluetooth: Add basic constants for L2CAP ERTM support and use them
    Bluetooth: Remove pointless endian conversion helpers
    Bluetooth: Use only MISC_DYNAMIC_MINOR for virtual driver
    Bluetooth: Use wait_event_interruptible for virtual driver
    Bluetooth: Remove BKL from open callback of virtual driver
    Bluetooth: Remove unused and unneeded support in virtual driver
    Bluetooth: Add native RFKILL soft-switch support for all devices


