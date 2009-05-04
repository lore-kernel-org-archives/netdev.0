From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-05-04
Date: Mon, 04 May 2009 14:42:53 -0700
Message-ID: <1241473373.2903.59.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:49884 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344AbZEDVnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 17:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the previous NULL pointer fix was doing more harm than good. It broke on
a couple of systems. Unfortunately mine was running fine for no real
apparent reason. I guess just pure luck.

Problem was really that we tried to work around an issue that was no
longer the original issue since that got fixed. However it revealed
clearly our broken thinking and it should be now fixed for good.

The patch looks bigger than it actually is since I had to move some
functions around. We have three testers that confirmed that this patch
fixes the actual problems.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 include/net/bluetooth/hci_core.h |    1 +
 net/bluetooth/hci_conn.c         |    2 +
 net/bluetooth/hci_sysfs.c        |   74 ++++++++++++++++++++-----------------
 3 files changed, 43 insertions(+), 34 deletions(-)

through these ChangeSets:

Marcel Holtmann (1):
    Bluetooth: Fix issue with sysfs handling for connections



