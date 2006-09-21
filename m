From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Thu, 21 Sep 2006 21:47:20 +0200
Message-ID: <1158868040.11194.56.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:20117 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1751444AbWIUTq5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 15:46:57 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are the pending patches that didn't make it into the 2.6.18 kernel
release. I have some additional fixes, but all of them need some more
additional testing from my side.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/bfusb.c        |  316 +++++++++++++++++++--------------------
 drivers/bluetooth/hci_ldisc.c    |   13 -
 drivers/bluetooth/hci_usb.c      |    3 
 drivers/bluetooth/hci_vhci.c     |   99 ++++++------
 include/net/bluetooth/hci.h      |    5 
 include/net/bluetooth/hci_core.h |    6 
 net/bluetooth/bnep/core.c        |   26 ++-
 net/bluetooth/hci_conn.c         |    8 
 net/bluetooth/hci_event.c        |    1 
 net/bluetooth/hci_sysfs.c        |  117 ++++++++++++--
 net/bluetooth/hidp/core.c        |   23 ++
 net/bluetooth/rfcomm/tty.c       |   21 ++
 12 files changed, 400 insertions(+), 238 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Thu, 21 Sep 2006 16:23:19 +0200 

    [Bluetooth] Code cleanup for the HCI UART driver
    
    This patch cleans up the Bluetooth HCI UART driver a bit.
    
    Signed-off-by: Pavel Machek <pavel@suse.cz>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 21 Sep 2006 16:19:55 +0200 

    [Bluetooth] Add support for Canyon CN-BTU1 dongle
    
    This patch adds the vendor and product id of the Canycon CN-BTU1
    dongle and sets a flag to send HCI_Reset as the first command.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 21 Sep 2006 16:04:00 +0200 

    [Bluetooth] Handle command complete event for exit periodic inquiry
    
    The command complete event of the exit periodic inquiry command must
    clear the HCI_INQUIRY flag and finish the HCI request.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Sat, 08 Jul 2006 13:57:15 +0200 

    [Bluetooth] Add HCI device identifier for SDIO cards
    
    This patch assigns the next free HCI device identifier to Bluetooth
    devices based on the SDIO interface.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 15:45:23 +0200 

    [Bluetooth] Code cleanup of the drivers source code
    
    This patch is an attempt to cleanup the drivers source code to make all
    Bluetooth drivers look more unique.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 13:09:02 +0200 

    [Bluetooth] Integrate services into the driver model
    
    This patch integrates the services of the Bluetooth protocols RFCOMM,
    BNEP and HIDP into the driver model. This makes it possible to assign
    the virtual TTY, network and input devices to a specific Bluetooth
    connection.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 12:38:46 +0200 

    [Bluetooth] Integrate low-level connections into the driver model
    
    This patch integrates the low-level connections (ACL and SCO) into the
    driver model. Every connection is presented as device with the parent
    set to its host controller device.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Thu, 06 Jul 2006 12:34:41 +0200 

    [Bluetooth] Remove unused host controller attributes
    
    This patch removes the unused device attribute entries for the Bluetooth
    host controllers.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



