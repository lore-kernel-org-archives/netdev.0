From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk] 2.4.x net driver queue snapshot
Date: Tue, 26 Aug 2003 16:50:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826205042.GA31910@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is just a snapshot of my 2.4 net driver queue.  Marcelo pulled
yesterday, including some bonding bits.  No GNU patch for snapshots, as
the queue is still being grown...


BK users:

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.4
		or
	bk pull http://gkernel.bkbits.net/net-drivers-2.4

This will update the following files:

 drivers/net/3c501.c  |   93 ++--------
 drivers/net/3c503.c  |   71 +------
 drivers/net/3c505.c  |   92 +--------
 drivers/net/3c507.c  |   97 ++--------
 drivers/net/3c515.c  |   94 ++--------
 drivers/net/3c523.c  |   73 +------
 drivers/net/3c527.c  |   94 ++--------
 drivers/net/3c59x.c  |   50 ++---
 drivers/net/8139cp.c |  472 ++++++++++++++++++++-------------------------------
 drivers/net/dmfe.c   |   61 +-----
 drivers/net/sis900.c |   53 ++---
 11 files changed, 362 insertions(+), 888 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/08/26 1.1085)
   [netdrvr] ethtool_ops support for 3c515, 3c523, 3c527, and dmfe

<jgarzik@redhat.com> (03/08/26 1.1084)
   [netdrvr] ethtool_ops support in 3c503, 3c505, 3c507

<jgarzik@redhat.com> (03/08/26 1.1083)
   [netdrvr 3c501] ethtool_ops support

<jgarzik@redhat.com> (03/08/26 1.1082)
   [netdrvr 3c59x] add a piece missed in previous ethtool_ops patch
   
   Contributed by Matthew Wilcox.

<jgarzik@redhat.com> (03/08/26 1.1081)
   [netdrvr 8139cp] ethtool_ops support

<jgarzik@redhat.com> (03/08/26 1.1080)
   [netdrvr 8139cp] minor bits from 2.6

<jgarzik@redhat.com> (03/08/26 1.1079)
   [netdrvr sis900] minor bits from 2.6

<jgarzik@redhat.com> (03/08/26 1.1078)
   [netdrvr sis900] ethtool_ops support

<willy@debian.org> (03/08/26 1.1077)
   [netdrvr 3c59x] ethtool_ops support
