From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bluetooth update for 2.6
Date: Sun, 19 Nov 2006 01:34:33 +0100
Message-ID: <1163896473.4413.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:19940 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S1755451AbWKSAe0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 19:34:26 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here are some additional fixes that should go into 2.6.19 before its
final release. Please forward them to Linus as soon as possible.

Linus, I put you on CC, because Dave might be cross-country driving and
I have no idea when he will be back online.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 net/bluetooth/hci_event.c  |   19 +++++++++++++++++++
 net/bluetooth/hci_sysfs.c  |    4 +++-
 net/bluetooth/l2cap.c      |   11 +++++++----
 net/bluetooth/rfcomm/tty.c |    2 +-
 4 files changed, 30 insertions(+), 6 deletions(-)

through these ChangeSets:

Commit: 0e040f1bba0ed4421fa5ed7973601b0ec3ce73d1 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 18 Nov 2006 22:15:20 +0100 

    [Bluetooth] Ignore L2CAP config requests on disconnect
    
    Any L2CAP connection in disconnecting state shall not response
    to any further config requests from the remote side. So in case
    such a request is received, ignore it.
    
    Signed-off-by: Ville Tervo <ville.tervo@nokia.com>
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: e723297071994c1b96c1d7ec5493812a4be14556 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 18 Nov 2006 22:15:00 +0100 

    [Bluetooth] Always include MTU in L2CAP config responses
    
    When sending a positive config response it shall include the actual
    MTU to be used on this channel. This differs from the Bluetooth 1.1
    specification where it was enough to acknowledge the config request.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 0fc8b237987d3b7a42813a3ae9ec0fbed9be7a92 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 18 Nov 2006 22:14:42 +0100 

    [Bluetooth] Check if RFCOMM session is still attached to the TTY
    
    If the RFCOMM session is no longer attached to the TTY device, then it
    makes no sense to go through with changing the termios settings.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 61f52b9abd9b49770c9b05676fdd36e00999355f 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 18 Nov 2006 22:14:22 +0100 

    [Bluetooth] Handling pending connect attempts after inquiry
    
    After an inquiry completed or got canceled the Bluetooth core should
    check for any pending connect attempts.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Commit: 3195125e559295126ad21a8552df7328e5c4f507 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 18 Nov 2006 22:14:05 +0100 

    [Bluetooth] Attach low-level connections to the Bluetooth bus
    
    To receive uvents for the low-level ACL and SCO links, they must be
    assigned to a subsystem. It is enough to attach them to the already
    established Bluetooth bus.
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



