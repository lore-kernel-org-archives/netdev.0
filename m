From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth fixes for 2.6.20-rc5
Date: Mon, 22 Jan 2007 22:42:14 +0100
Message-ID: <1169502134.27023.24.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:54670 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbXAVVmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 16:42:24 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are two additional fixes for the Bluetooth subsystem that should go
in before the final 2.6.20 release. It was possible that the well known
PSM could be bound by anybody. That should not be possible like TCP/IP
ports below 1024 are also restricted. The other one is a simple endian
fix. Please forward them to Linus as soon as possible.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 net/bluetooth/l2cap.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

through these ChangeSets:

Commit: 847641d7db15ac3f18b3d4aa05479812abdf397a 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 22 Jan 2007 22:00:45 +0100 

    [Bluetooth] Restrict well known PSM to privileged users
    
    The PSM values below 0x1001 of L2CAP are reserved for well known
    services. Restrict the possibility to bind them to privileged
    users.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 7386397636d49cd5f03da29432467d3e98cbad35 
Author: Marcel Holtmann <marcel@holtmann.org> Mon, 22 Jan 2007 22:00:40 +0100 

    [Bluetooth] Missing endian swapping for L2CAP socket list
    
    The PSM value in the L2CAP socket list must be converted to host
    order before printing it.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



