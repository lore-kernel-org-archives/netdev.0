From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Tue, 09 Sep 2008 08:08:24 +0200
Message-ID: <1220940504.13336.6.camel@californication>
References: <1220934481.11655.32.camel@californication>
	 <20080908.213050.176981752.davem@davemloft.net>
	 <1220935561.13336.2.camel@californication>
	 <20080908.214802.259552790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40018 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbYIIGID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 02:08:03 -0400
In-Reply-To: <20080908.214802.259552790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > it was the "... L2CAP PSM 1 (used by SDP) the just-works model ..." and
> > I admit, after you pointing my nose on it, that it is not clear to
> > anybody not deeply into this Bluetooth 2.1 stuff.
> > 
> > Let me fix up the tree and have this commit with a better explanation
> > what it is all about.
> 
> Thanks a lot.

I re-pushed the three patches and made sure that the second one has a
more detailed description on what is going on. Let me know what you
think.

Regards

Marcel


Please pull from

    git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git master

This will update the following files:

 include/net/bluetooth/hci_core.h |    3 ++-
 net/bluetooth/af_bluetooth.c     |    2 +-
 net/bluetooth/hci_conn.c         |   21 ++++++++++++++++++---
 net/bluetooth/hci_event.c        |   11 ++++-------
 net/bluetooth/l2cap.c            |   34 ++++++++++++++++++++++++++++------
 net/bluetooth/sco.c              |    2 +-
 6 files changed, 54 insertions(+), 19 deletions(-)

through these ChangeSets:

Marcel Holtmann (3):
    [Bluetooth] Fix reference counting during ACL config stage
    [Bluetooth] Enforce correct authentication requirements
    [Bluetooth] Reject L2CAP connections on an insecure ACL link



