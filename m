From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-04-28
Date: Tue, 28 Apr 2009 09:58:36 -0700
Message-ID: <1240937916.997.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:46334 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473AbZD1Q6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 12:58:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are three additional patches that should go into the 2.6.30 kernel
release. The first one fixes a NULL pointer dereference when adding and
removing sysfs devices for ACL connections. The other two are fixes for
interoperability regression we introduced when adding full Simple
Pairing support. A big thank you here goes to the Nokia guys and their
QA team for testing the crap out of this. There is actually nothing
simple about Simple Pairing :)

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 include/net/bluetooth/hci.h      |    1 +
 include/net/bluetooth/hci_core.h |    8 +++++---
 net/bluetooth/hci_conn.c         |   10 ++++------
 net/bluetooth/hci_event.c        |   36 +++++++++++++++++++++++++++++++++++-
 net/bluetooth/hci_sysfs.c        |   37 ++++++++++++++++---------------------
 5 files changed, 61 insertions(+), 31 deletions(-)

through these ChangeSets:

Marcel Holtmann (2):
    Bluetooth: Add different pairing timeout for Legacy Pairing
    Bluetooth: Fix connection establishment with low security requirement

Roger Quadros (1):
    Bluetooth: Ensure that HCI sysfs add/del is preempt safe



