From: Joe Perches <joe@perches.com>
Subject: request-pull: Use static const
Date: Tue, 21 Dec 2010 02:26:13 -0800
Message-ID: <1292927173.1779.27.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2797 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933625Ab0LUK0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 05:26:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmitting the remnants of an earlier discrete patchset.
https://lkml.org/lkml/2010/11/20/209
Consolidated into smaller patches.

The following changes since commit d9993be65a77f500ae926176baa264816bfe3816:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6 (2010-12-20 13:24:14 -0800)

are available in the git repository at:

  git://repo.or.cz/linux-2.6/trivial-mods.git 20101221_static_const

Joe Perches (5):
      tg3: Use DEFINE_PCI_DEVICE_TABLE
      drivers/net/*.c: Use static const
      usb: Use static const, consolidate code
      tulip: Use DEFINE_PCI_DEVICE_TABLE and static const
      drivers/net/*/: Use static const

 drivers/net/3c501.c                |    4 +-
 drivers/net/3c503.c                |    4 +-
 drivers/net/3c507.c                |    4 +-
 drivers/net/3c527.c                |    6 ++--
 drivers/net/at1700.c               |    6 ++--
 drivers/net/benet/be_ethtool.c     |    4 ++-
 drivers/net/benet/be_main.c        |   10 ++++----
 drivers/net/bnx2.c                 |   46 ++++++++++++++++++-----------------
 drivers/net/bnx2x/bnx2x_main.c     |    6 +++-
 drivers/net/can/sja1000/plx_pci.c  |    2 +-
 drivers/net/chelsio/sge.c          |   10 +++----
 drivers/net/cxgb3/ael1002.c        |   24 +++++++++---------
 drivers/net/cxgb3/t3_hw.c          |    2 +-
 drivers/net/cxgb4vf/t4vf_hw.c      |    2 +-
 drivers/net/e2100.c                |    2 +-
 drivers/net/eepro.c                |    9 ++++---
 drivers/net/eexpress.c             |    2 +-
 drivers/net/gianfar.c              |   10 ++++---
 drivers/net/hp.c                   |    6 ++--
 drivers/net/irda/act200l-sir.c     |    2 +-
 drivers/net/irda/donauboe.c        |    4 +-
 drivers/net/jme.c                  |    4 +-
 drivers/net/ksz884x.c              |   20 ++++++++--------
 drivers/net/netxen/netxen_nic_hw.c |   16 ++++++++----
 drivers/net/ni52.c                 |    4 +-
 drivers/net/ni65.c                 |    4 +-
 drivers/net/pcmcia/nmclan_cs.c     |    2 +-
 drivers/net/qlcnic/qlcnic_hw.c     |   15 +++++++----
 drivers/net/qlge/qlge_main.c       |   13 +++++----
 drivers/net/r8169.c                |    2 +-
 drivers/net/skfp/smt.c             |    4 +-
 drivers/net/skge.c                 |    4 +-
 drivers/net/smc-ultra.c            |    8 ++++-
 drivers/net/tg3.c                  |   26 +++++++++-----------
 drivers/net/tokenring/ibmtr.c      |    5 ++-
 drivers/net/tulip/de2104x.c        |   18 +++++++++----
 drivers/net/tulip/tulip_core.c     |   15 +++++++----
 drivers/net/usb/hso.c              |   39 ++++++++++++------------------
 drivers/net/vmxnet3/vmxnet3_drv.c  |    4 ++-
 drivers/net/wan/dscc4.c            |    6 ++--
 drivers/net/wd.c                   |    2 +-
 41 files changed, 199 insertions(+), 177 deletions(-)


