From: Marcel Holtmann <marcel@holtmann.org>
Subject: =?UTF-8?q?Pull=20request=3A=20bluetooth-2=2E6=202010-07-08?=
Date: Thu,  8 Jul 2010 16:59:49 -0300
Message-ID: <cover.1278619047.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36208 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758540Ab0GHUAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:19 -0400
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these patches fix a few bugs and crashes and also two security related
issues with the authentication procedure.

This will also be my last pull request for you. From now on all future
patches will be submitted towards John's wireless trees. That way we
can coordindate the development of Bluetooth 3.0 (Bluetooth over WiFi)
and avoid any kind of conflicts.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.=
6.git master

This will update the following files:

 net/bluetooth/Kconfig     |   13 ----
 net/bluetooth/hci_conn.c  |    5 ++
 net/bluetooth/hci_event.c |    2 +
 net/bluetooth/l2cap.c     |  138 +++++++++++++++++++++++++++----------=
--------
 4 files changed, 90 insertions(+), 68 deletions(-)

through these ChangeSets:

Andrei Emeltchenko (1):
    Bluetooth: Check L2CAP pending status before sending connect reques=
t

Gustavo F. Padovan (8):
    Bluetooth: Remove max_tx and tx_window module paramenters from L2CA=
P
    Bluetooth: Remove L2CAP Extended Features from Kconfig
    Bluetooth: Fix drop of packets with invalid req_seq/tx_seq
    Bluetooth: Fix bug with ERTM vars increment
    Bluetooth: Only check SAR bits if frame is an I-frame
    Bluetooth: Fix bug in l2cap_ertm_send() behavior
    Bluetooth: Proper shutdown ERTM when closing the channel
    Bluetooth: Fix L2CAP control bit field corruption

Johan Hedberg (1):
    Bluetooth: Reset the security level after an authentication failure

Jo=C3=A3o Paulo Rechi Vita (1):
    Bluetooth: Fix SREJ_QUEUE corruption in L2CAP

Nathan Holstein (1):
    Bluetooth: Fix bug with ERTM minimum packet length

Ville Tervo (1):
    Bluetooth: Update sec_level/auth_type for already existing connecti=
ons

