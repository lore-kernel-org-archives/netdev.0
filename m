From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.22-rc2
Date: Thu, 24 May 2007 18:47:24 +0200
Message-ID: <1180025244.21432.16.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:37264 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbXEXQsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 12:48:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are two more bug fixes that should go into 2.6.22 before its final
release. The USB driver change is minor and the L2CAP change has been
verified with Bluetooth compliance tester and also the L2CAP robustness
testing.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c   |   16 ++--
 include/net/bluetooth/l2cap.h |    8 +-
 net/bluetooth/l2cap.c         |  144 +++++++++++++++++++++++-------------------
 3 files changed, 94 insertions(+), 74 deletions(-)

through these ChangeSets:

Commit: 8e6b1e14d817ae7c43c51b8707a22bdc123157fb 
Author: Marcel Holtmann <marcel@holtmann.org> Thu, 24 May 2007 13:58:55 +0200 

    [Bluetooth] Fix L2CAP configuration parameter handling
    
    The L2CAP configuration parameter handling was missing the support
    for rejecting unknown options. The capability to reject unknown
    options is mandatory since the Bluetooth 1.2 specification. This
    patch implements its and also simplifies the parameter parsing.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 82cff022f83fd4c979d3b51c8c40e0e9650bc244 
Author: Marcel Holtmann <marcel@holtmann.org> Thu, 24 May 2007 13:43:29 +0200 

    [Bluetooth] Always send HCI_Reset for Broadcom devices
    
    In case of Broadcom based Bluetooth devices, it is safe to always
    send HCI_Reset as first command. This gives the advantage that
    all HID Proxy versions will automatically work and don't need any
    additional quirks anymore.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



