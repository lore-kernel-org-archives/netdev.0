From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Fri, 20 Oct 2006 09:49:48 +0200
Message-ID: <1161330589.27585.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:12471 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S2992553AbWJTHti
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:49:38 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are another three bugfixes for the 2.6.19 kernel. Please forward
them to Linus as soon as possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/dtl1_cs.c |    1 +
 drivers/bluetooth/hci_usb.c |    3 +++
 net/bluetooth/hidp/core.c   |    6 ++----
 3 files changed, 6 insertions(+), 4 deletions(-)

through these ChangeSets:

Commit: 26cd6d320a0c757e26a529fce3b561ff18a14a57 
Author: Marcel Holtmann <marcel@holtmann.org> Fri, 20 Oct 2006 08:55:48 +0200 

    [Bluetooth] Fix HID disconnect NULL pointer dereference
    
    The latest HID disconnect sequence change introduced a NULL pointer
    dereference. For the quirk to handle buggy remote HID implementations,
    it is enough to wait for a potential control channel disconnect from
    the remote side and it is also enough to wait only 500 msecs.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 7817d1d21393737dddacafa9d229b8431b25e3c3 
Author: Marcel Holtmann <marcel@holtmann.org> Fri, 20 Oct 2006 08:55:34 +0200 

    [Bluetooth] Add missing entry for Nokia DTL-4 PCMCIA card
    
    The device id for the Nokia DTL-4 PCMCIA card was missing. This patch
    adds it back to the list of supported devices.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: f57be46de356456b6eb2d8fb7af1143b4ec7f3cb 
Author: Marcel Holtmann <marcel@holtmann.org> Fri, 20 Oct 2006 08:55:29 +0200 

    [Bluetooth] Add support for newer ANYCOM USB dongles
    
    This patch adds the vendor and product id of the ANYCOM Bluetooth
    USB-200 and USB-250 dongles and sets a flag to send HCI_Reset as
    the first command.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org



