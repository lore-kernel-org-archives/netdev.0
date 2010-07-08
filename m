From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2010-07-08
Date: Thu,  8 Jul 2010 20:40:50 -0300
Message-ID: <cover.1278632276.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:34264 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757184Ab0GHXlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 19:41:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

so I took the two security fixes and the interoperability fix for basic
mode L2CAP connections and combined them here.

All the other patches where bug fixes with L2CAP ERTM support and I will
send them separately.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_conn.c  |    5 +++++
 net/bluetooth/hci_event.c |    2 ++
 net/bluetooth/l2cap.c     |   14 +++++++++++---
 3 files changed, 18 insertions(+), 3 deletions(-)

through these ChangeSets:

Andrei Emeltchenko (1):
    Bluetooth: Check L2CAP pending status before sending connect request

Johan Hedberg (1):
    Bluetooth: Reset the security level after an authentication failure

Ville Tervo (1):
    Bluetooth: Update sec_level/auth_type for already existing connections

