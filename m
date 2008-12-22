From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 00/27] drivers/net: fix sparse warnings
Date: Mon, 22 Dec 2008 20:14:49 +0100
Message-ID: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:31874 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbYLVTO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:14:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series fixes about 100 sparse warnings in drivers/net.

---

Hannes Eder (27):
      drivers/net/wireless/prism54: fix sparse warnings: make symbols static
      drivers/net/wireless/ipw2x00: fix sparse warnings: make symbols static
      drivers/net/wireless/b43: fix sparse warnings: make symbols static
      drivers/net/wireless/ath9k: fix sparse warnings: make symbols static
      drivers/net/wireless: fix sparse warnings: make symbols static
      drivers/net/wan/z85230.c: fix sparse warnings: un-EXPORT symbols
      drivers/net/wan: fix sparse warning: make symbol static
      drivers/net/wan: fix sparse warnings: make do-while a compound statement
      drivers/net/usb: fix sparse warnings: make symbols static
      drivers/net/tulip: fix sparse warnings: make do-while a compound statement
      drivers/net/tokenring: fix sparse warnings: make symbols static
      drivers/net/skfp: fix sparse warnings: make symbols static
      drivers/net/qlge: fix sparse warnings: make symbols static
      drivers/net/netxen: fix sparse warnings: use NULL pointer instead of plain integer
      drivers/net/ixgbe: fix sparse warnings: make symbols static
      drivers/net/irda: fix sparse warnings: make symbols static
      drivers/net/igb: remove dead code (function 'igb_read_pci_cfg')
      drivers/net/enic: fix sparse warning: make symbol static
      drivers/net/e1000e: fix sparse warnings: make symbols static
      drivers/net/cxgb3: comment out dead code
      drivers/net/bonding: fix sparse warnings: move decls to header file
      drivers/net/atlx: fix sparse warnings: make symbols static
      drivers/net/arcnet: fix sparse warnings: make symbols static
      drivers/net: fix sparse warnings: make symbols static
      drivers/net: fix sparse warning: returning void-valued expression
      drivers/net: fix sparse warnings: make do-while a compound statement
      drivers/net: fix sparse warning: use ANSI-style function declaration


 drivers/net/3c523.c                           |    2 -
 drivers/net/arcnet/capmode.c                  |    2 -
 drivers/net/arcnet/com90xx.c                  |    2 -
 drivers/net/atlx/atl1.c                       |    4 +-
 drivers/net/atp.c                             |   19 ++++----
 drivers/net/bonding/bond_main.c               |    1 
 drivers/net/bonding/bond_sysfs.c              |    3 -
 drivers/net/bonding/bonding.h                 |    5 ++
 drivers/net/cs89x0.c                          |    2 -
 drivers/net/cxgb3/vsc8211.c                   |    2 +
 drivers/net/e1000e/es2lan.c                   |    6 ++
 drivers/net/eepro.c                           |    2 -
 drivers/net/enic/vnic_dev.c                   |    2 -
 drivers/net/igb/e1000_mac.c                   |    7 ---
 drivers/net/irda/ma600-sir.c                  |    2 -
 drivers/net/irda/smsc-ircc2.c                 |    6 +-
 drivers/net/irda/w83977af_ir.c                |   14 +++---
 drivers/net/ixgbe/ixgbe_82598.c               |   24 +++++-----
 drivers/net/ixgbe/ixgbe_dcb_82598.c           |    4 +-
 drivers/net/ne.c                              |    2 -
 drivers/net/netxen/netxen_nic_hw.c            |    4 +-
 drivers/net/niu.c                             |    2 -
 drivers/net/plip.c                            |   20 ++++----
 drivers/net/qlge/qlge_ethtool.c               |    2 -
 drivers/net/qlge/qlge_mpi.c                   |    2 -
 drivers/net/s2io.c                            |    2 -
 drivers/net/skfp/skfddi.c                     |    6 +-
 drivers/net/smc9194.c                         |    2 -
 drivers/net/starfire.c                        |    4 +-
 drivers/net/tokenring/ibmtr.c                 |    4 +-
 drivers/net/tokenring/madgemc.c               |    2 -
 drivers/net/tokenring/proteon.c               |    2 -
 drivers/net/tokenring/skisa.c                 |    2 -
 drivers/net/tulip/de2104x.c                   |    4 +-
 drivers/net/tulip/tulip_core.c                |    4 +-
 drivers/net/usb/hso.c                         |   10 ++--
 drivers/net/usb/smsc95xx.c                    |    2 -
 drivers/net/wan/wanxl.c                       |    8 ++-
 drivers/net/wan/x25_asy.c                     |    2 -
 drivers/net/wan/z85230.c                      |   10 +---
 drivers/net/wireless/airo.c                   |    2 -
 drivers/net/wireless/ath9k/eeprom.c           |   62 +++++++++++++------------
 drivers/net/wireless/atmel.c                  |    2 -
 drivers/net/wireless/b43/phy_a.c              |    4 +-
 drivers/net/wireless/b43/phy_g.c              |   20 ++++----
 drivers/net/wireless/ipw2x00/ipw2100.c        |    6 +-
 drivers/net/wireless/prism54/islpci_hotplug.c |    8 ++-
 drivers/net/wireless/ray_cs.c                 |    2 -
 48 files changed, 153 insertions(+), 158 deletions(-)
