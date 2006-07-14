From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Fri, 14 Jul 2006 16:38:31 +0200
Message-ID: <1152887911.25660.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:32209 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1161114AbWGNOiM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 10:38:12 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are two more bug fixes for the Bluetooth subsystem. Both are
workarounds for either broken implementations or broken hardware.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c |   17 +++++++++++++++--
 net/bluetooth/rfcomm/core.c |   19 +++++++++++++++++--
 2 files changed, 32 insertions(+), 4 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Fri, 14 Jul 2006 16:01:52 +0200 

    [Bluetooth] Correct SCO buffer size for another Broadcom chip
    
    The SCO buffer size values on IBM/Lenovo ThinkPad laptops with a
    Bluetooth chip from Broadcom are wrong. The USB Bluetooth driver
    has to set a quirk to correct the SCO buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Fri, 14 Jul 2006 11:42:12 +0200 

    [Bluetooth] Correct RFCOMM channel MTU for broken implementations
    
    Some Bluetooth RFCOMM implementations try to negotiate a bigger channel
    MTU than we can support for a particular session. The maximum MTU for
    a RFCOMM session is limited through the L2CAP layer. So if the other
    side proposes a channel MTU that is bigger than the underlying L2CAP
    MTU, we should reduce it to the L2CAP MTU of the session minus five
    bytes for the RFCOMM headers.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



