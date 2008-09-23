From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth btusb fixes for 2.6.27-rc7
Date: Tue, 23 Sep 2008 02:10:50 +0200
Message-ID: <1222128650.13064.16.camel@californication>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:34430 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbYIWAJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 20:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these patches are fixing the typos in the btusb driver and as reported
by Rafael, it fixes the btusb suspend regression. I included a quirk for
David's new MacBook Pro to make it work. Without the quirk it gets I/O
errors all the time.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 drivers/bluetooth/btusb.c |   28 ++++++++++++++++++++++------
 1 files changed, 22 insertions(+), 6 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Fix I/O errors on MacBooks with Broadcom chips
    [Bluetooth] Fix wrong URB handling of btusb driver
    [Bluetooth] Fix USB disconnect handling of btusb driver



