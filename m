From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.22
Date: Wed, 09 May 2007 14:24:50 +0200
Message-ID: <1178713490.8628.90.camel@aeonflux.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:42655 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926AbXEIMZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 08:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are some minor additional fixes that should go into 2.6.22 before
Linus closes the merge window.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_ldisc.c |   10 +++++++++-
 drivers/bluetooth/hci_uart.h  |    5 +++--
 net/bluetooth/hidp/core.c     |   10 +++++-----
 3 files changed, 17 insertions(+), 8 deletions(-)

through these ChangeSets:

Commit: 19242490ea04586d581113dd8895ba2ebed75c9b 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 09 May 2007 09:15:45 +0200 

    [Bluetooth] Fix unintentional fall-through in HCI line discipline
    
    A trivial fix to (what looks like) an unintentional fall-through in the
    HCI line discipline.
    
    Signed-off-by: Ohad Ben-Cohen <ohad@bencohen.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: d4c2c832c4a2247a9e9a320d4da4532a6ebfebb3 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 09 May 2007 09:15:40 +0200 

    [Bluetooth] Fix NULL pointer dereference in HCI line discipline
    
    Normally a serial Bluetooth device is opened, TIOSETD'ed to N_HCI line
    discipline, HCIUARTSETPROTO'ed and finally closed. In case the device
    fails to HCIUARTSETPROTO, closing it produces a NULL pointer dereference.
    
    Signed-off-by: Ohad Ben-Cohen <ohad@bencohen.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: ecbe531f666e08d41eb6f0ef8e2eb8dca5aa99d5 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 09 May 2007 09:15:35 +0200 

    [Bluetooth] Add HCIUARTGETDEVICE support for HCI line discipline
    
    Adding HCIUARTGETDEVICE makes it possible to get the HCI device number
    that is attached to a given serial device. This is required during the
    initialization process of some Bluetooth chips.
    
    Signed-off-by: Ohad Ben-Cohen <ohad@bencohen.org>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 30168f98fb48b3cce14900c153781cef41eea363 
Author: Marcel Holtmann <marcel@holtmann.org> Wed, 09 May 2007 09:15:30 +0200 

    [Bluetooth] Switch to using input_dev->dev.parent
    
    In preparation for struct class_device -> struct device input core
    conversion, switch to using input_dev->dev.parent when specifying
    device position in sysfs tree.
    
    Also, do not access input_dev->private directly, use helpers and
    do not use kfree() on input device, use input_free_device() instead.
    
    Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



