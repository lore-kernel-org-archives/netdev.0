From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth update for 2.6
Date: Tue, 18 Jul 2006 19:08:44 +0200
Message-ID: <1153242524.21024.14.camel@localhost>
References: <1152887911.25660.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:3808 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S932312AbWGRRIT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:08:19 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1152887911.25660.32.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> here are two more bug fixes for the Bluetooth subsystem. Both are
> workarounds for either broken implementations or broken hardware.

we've seen a bunch of buggy USB Bluetooth devices lately and I have
three more patches to workaround various issues. I also re-based the
tree to 2.6.18-rc2 and pushed the additional changes. Please pull and
forward to Linus as soon as possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

through these ChangeSets:

Marcel Holtmann <marcel@holtmann.org> Tue, 18 Jul 2006 18:32:33 +0200 

    [Bluetooth] Enable SCO support for Broadcom HID proxy dongle
    
    The Broadcom dongles with HID proxy support actually support SCO over
    HCI if the SCO buffer size values are corrected. So instead of disabling
    the SCO support, mark this dongle with the quirk for the Bluetooth core
    to correct the wrong buffer size values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Tue, 18 Jul 2006 18:04:59 +0200 

    [Bluetooth] Add quirk for another broken RTX Telecom based dongle
    
    This patch disables the ISOC transfers for another broken RTX Telecom
    based USB dongle. Starting the USB ISOC transfers only ends in a burst
    of error messages for invalid SCO packets on connection handle 0.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Marcel Holtmann <marcel@holtmann.org> Tue, 18 Jul 2006 17:47:40 +0200 

    [Bluetooth] Correct SCO buffer size for Belkin devices
    
    The Belkin F8T012 and F8T013 devices are both based on a Bluetooth chip
    from Broadcom and their SCO buffer size values are wrong. The Bluetooth
    core should correct these values.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



