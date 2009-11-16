From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-11-16
Date: Mon, 16 Nov 2009 01:48:20 +0100
Message-ID: <cover.1258331614.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46536 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbZKPAsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2009 19:48:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are three additional patches that should go into 2.6.32 before its
final release.

The first one fixes a regression with Secure Simple Pairing support. I
had that patch for a while, but it took some time to verify that it
doesn't break the Bluetooth qualification. The Bluetooth 2.1 GAP testing
is a major pain and always surprises you.

The second and third patches are fixing two regression from the L2CAP
ERTM support. When ERTM is not supported or not configured we have to
use Basic Mode and really stick to it. Other Bluetooth stacks are not
capable of handling unknown options properly.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_conn.c |    1 +
 net/bluetooth/l2cap.c    |   13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

through these ChangeSets:

Andrei Emeltchenko (1):
    Bluetooth: Set general bonding security for ACL by default

Gustavo F. Padovan (2):
    Bluetooth: Select Basic Mode as default for SOCK_SEQPACKET
    Bluetooth: Fix regression with L2CAP configuration in Basic Mode

