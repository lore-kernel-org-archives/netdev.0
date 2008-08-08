From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth driver updates for 2.6.27
Date: Fri, 08 Aug 2008 02:15:32 +0200
Message-ID: <1218154532.7819.52.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36568 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbYHHALd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 20:11:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are some pending driver updates for the 2.6.27 kernel. The BNEP
update is adding parameters to control the header compression. This is
required to pass the Bluetooth qualification since otherwise Linux is
too smart (yes qualification requires to disable it). The other two
update the Bluetooth driver parameters and brings the quirk list of the
btusb driver in sync with the hci_usb.

Oliver is working on the SCO support for the btusb driver and once he
finishes it and we were able to test it, then it is time to actually
remove the hci_usb in favor of btusb.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/bcm203x.c |    9 +--
 drivers/bluetooth/bfusb.c   |   10 +---
 drivers/bluetooth/bpa10x.c  |   10 +---
 drivers/bluetooth/btusb.c   |  163 ++++++++++++++++++++++++++++++++++++++++++-
 drivers/bluetooth/hci_usb.c |    8 +--
 net/bluetooth/bnep/core.c   |   15 +++-
 6 files changed, 179 insertions(+), 36 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Add parameters to control BNEP header compression
    [Bluetooth] Removal of unnecessary ignore module parameter
    [Bluetooth] Add full quirk implementation for btusb driver



