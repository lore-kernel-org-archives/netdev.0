From: Jeff Garzik <jgarzik@pobox.com>
Subject: netdev-2.6 queue updated
Date: Sat, 28 Aug 2004 21:00:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829010013.GA16237@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: mcgrof@studorgs.rutgers.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Still got a huge set of patches from Al Viro (ethtool_ops conversions
for most remaining drivers), and prism54 patches from Luis and Margit
to apply, so expect another update tomorrow.

BK users:

	bk pull bk://gkernel.bkbits.net/netdev-2.6

Patch:
http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.9=
-rc1-bk4-netdev1.patch.bz2

This will update the following files:

 drivers/net/8139too.c               |   14=20
 drivers/net/Kconfig                 |    9=20
 drivers/net/defxx.c                 |  144 ++++-----
 drivers/net/defxx.h                 |    2=20
 drivers/net/mac8390.c               |    4=20
 drivers/net/r8169.c                 |  564 ++++++++++++++++++++++++++---=
-------
 drivers/net/tulip/de4x5.c           |    2=20
 drivers/net/wireless/airo.c         |   45 +-
 drivers/net/wireless/wavelan.c      |   19 -
 drivers/net/wireless/wavelan.p.h    |    3=20
 drivers/net/wireless/wavelan_cs.c   |   23 -
 drivers/net/wireless/wavelan_cs.p.h |    3=20
 include/linux/netdevice.h           |    4=20
 include/linux/wireless.h            |   64 +++-
 include/net/iw_handler.h            |   60 ++-
 net/core/dev.c                      |    2=20
 net/core/wireless.c                 |  212 +++++++++----
 net/irda/irlan/irlan_client.c       |    2=20
 18 files changed, 816 insertions(+), 360 deletions(-)

through these ChangeSets:

Andrew Morton:
  o de4x5 warning fix

Fran=E7ois Romieu:
  o r8169: vlan support
  o r8169: Rx checksum support
  o r8169: advertise DMA to high memory
  o r8169: Tx checksum offload
  o r8169: comment a gcc 2.95.x bug
  o r8169: sync the names of a few bits with the 8139cp driver
  o r8169: bump version number
  o r8169: enable MWI
  o r8169: code cleanup
  o r8169: per device receive buffer size
  o r8169: add ethtool_ops.{get_regs_len/get_regs}

Jean Tourrilhes:
  o wireless-drivers-update-for-we-17.patch
  o wireless-extension-v17-for-linus.patch

Maciej W. Rozycki:
  o defxx device name fixes
  o defxx trivial updates

Mika Kukkonen:
  o sparse: fix warnings in net/irda/*

Olaf Hering:
  o remove old version check from mac8390

Rene Herman:
  o 8139too Interframe Gap Time
