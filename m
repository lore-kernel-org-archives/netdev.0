From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth patches for 2.6.23-rc5
Date: Sun, 09 Sep 2007 11:37:43 +0200
Message-ID: <1189330664.687.21.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:43457 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756158AbXIIKJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 06:09:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are four additional patches that should go into 2.6.23 before its
final release. Please pull and send them to Linus.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 drivers/bluetooth/hci_usb.c |    5 ++++-
 net/bluetooth/hci_core.c    |    8 +++-----
 net/bluetooth/hci_sock.c    |   27 +++++++++++++++++++++------
 3 files changed, 28 insertions(+), 12 deletions(-)

through these ChangeSets:

Commit: 89f2783ded0a4fc98852cb9552bb27a80cd6a41a 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 09 Sep 2007 08:39:49 +0200 

    [Bluetooth] Fix parameter list for event filter command
    
    On device initialization the event filters are cleared. In case of
    clearing the filters the extra condition type shall be omitted.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 7c631a67601f116d303cfb98a3d964a150090e38 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 09 Sep 2007 08:39:43 +0200 

    [Bluetooth] Update security filter for Bluetooth 2.1
    
    This patch updates the HCI security filter with support for the
    Bluetooth 2.1 commands and events.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 767c5eb5d35aeb85987143f0a730bc21d3ecfb3d 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 09 Sep 2007 08:39:34 +0200 

    [Bluetooth] Add compat handling for timestamp structure
    
    The timestamp structure needs special handling in case of compat
    programs. Use the same wrapping method the network core uses.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 26a4a06e7ff2874154eb3f4b4ba0514dc563b100 
Author: Marcel Holtmann <marcel@holtmann.org> Sun, 09 Sep 2007 08:39:27 +0200 

    [Bluetooth] Add missing stat.byte_rx counter modification
    
    With the support for hci_recv_fragment() the call to increase the
    stat.byte_rx counter got accidentally removed. This patch fixes it.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



