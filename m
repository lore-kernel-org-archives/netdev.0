From: Marcel Holtmann <marcel@holtmann.org>
Subject: Pull request: bluetooth-2.6 2009-05-27
Date: Wed, 27 May 2009 09:33:44 +0200
Message-ID: <1243409624.20399.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40485 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762327AbZE0HeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 03:34:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the current 2.6.30-rc6 kernel has a lockdep issue with the work queue
handling for adding/removing connections. We are calling flush_work()
where it is not needed at all, because of the nature of the single
thread work queue. So this patch just removes these calls.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 net/bluetooth/hci_sysfs.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

through these ChangeSets:

Dave Young (1):
    Bluetooth: Remove useless flush_work() causing lockdep warnings



