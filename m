From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Fri, 9 Jul 2004 16:14:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709201430.GA22656@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just emailed this to Andrew and Linus...




Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/epic100.c                  |  426 ++++++++-----
 drivers/net/forcedeth.c                |  848 +++++++++++++++++++-------
 drivers/net/natsemi.c                  | 1064 +++++++++++++++++++++++++-=
-------
 drivers/net/pci-skeleton.c             |   27=20
 drivers/net/sis900.c                   |   21=20
 drivers/net/sk98lin/h/skdrv1st.h       |    1=20
 drivers/net/wireless/prism54/oid_mgt.c |   10=20
 include/linux/pci_ids.h                |   13=20
 8 files changed, 1761 insertions(+), 649 deletions(-)

through these ChangeSets:

Daniele Venzano:
  o sis900-fix-phy-transceiver-detection.patch

Fran=E7ois Romieu:
  o epic100: code removal in irq handler
  o epic100: spin_unlock_irqrestore avoidance
  o [netdrvr epic100] napi fixes
  o [netdrvr epic100] napi 3/3 - transmit path
  o [netdrvr epic100] napi 2/3 - receive path
  o [netdrvr epic100] napi 1/3 - just shuffle some code around
  o [netdrvr epic100] minor cleanups

Manfred Spraul:
  o Gigabit Ethernet support for forcedeth
  o natsemi 2: support packets > 1518 bytes
  o natsemi 1: switch to netdev_priv()
  o natsemi updates

Margit Schubert-While:
  o prism54 freq to channel incorrect for 5GHz

Pavel Roskin:
  o [netdrvr pci-skeleton] refresh

Rusty Russell:
  o [TRIVIAL 2.6] sk98lin: kill dup include
