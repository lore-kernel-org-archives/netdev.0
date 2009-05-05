From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-05-05
Date: Tue, 05 May 2009 13:48:59 -0700
Message-ID: <1241556539.2987.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39730 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625AbZEEUtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 16:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this is kinda embarrassing since I did ack the initial dev_set_name()
change for 2.6.28, but at that point it was not allocating any memory
and so nobody ran into any problems with it. However with 2.6.30 it is
allocating memory with GFP_KERNEL and so we have to move it. The change
is simple and straight forward.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_sysfs.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

through these ChangeSets:

Marcel Holtmann (1):
    Bluetooth: Move dev_set_name() to a context that can sleep



