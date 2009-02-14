From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 00/43] drivers/net: fix (sparse) warnings
Date: Sat, 14 Feb 2009 22:11:36 +0100
Message-ID: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:39014 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbZBNVLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:11:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series fixes a couple of (sparse) warnings.

---

Hannes Eder (43):
      drivers/net/wireless/prism54: fix sparse warning: fix signedness
      drivers/net/wireless/ipw2x00: fix sparse warnings: fix signedness
      drivers/net/wireless/b43: fix warning: format not a string literal and no ...
      drivers/net/wireless/ath9k: fix sparse warnings: Should it be static?
      drivers/net/wireless: fix sparse warnings: fix signedness
      drivers/net/wireless: fix sparse warnings: symbol shadows an earlier one
      drivers/net/wireless: fix sparse warning: context imbalance
      drivers/net/wan: fix sparse warning: symbol shadows an earlier one
      drivers/net/wan: fix warning: format not a string literal and no ...
      drivers/net/usb: fix sparse warnings: Should it be static?
      drivers/net/tulip: fix sparse warning: symbol shadows an earlier one
      drivers/net/tulip: fix warning: format not a string literal and no ...
      drivers/net/tokenring: fix sparse warning: cast truncates bits from const value
      drivers/net/tokenring: fix sparse warning: symbol shadows an earlier one
      drivers/net/tokenring: fix warning: format not a string literal and no ...
      drivers/net/skfp: fix sparse warning: move decls to header file
      drivers/net/sfc: fix sparse warnings: Should it be static?
      drivers/net/sfc: fix sparse warning: symbol shadows an earlier one
      drivers/net/pcmcia: fix warning: format not a string literal and no ...
      drivers/net/ixgbe: fix sparse warning: Should it be static?
      drivers/net/igb: fix sparse warning: symbol shadows an earlier one
      drivers/net/hamradio: fix sparse warnings: fix signedness
      drivers/net/hamradio: fix sparse warning: symbol shadows an earlier one
      drivers/net/hamradio: fix sparse warning: context imbalance
      drivers/net/hamradio: fix warning: format not a string literal and no ...
      drivers/net/e1000e: fix sparse warning: Should it be static?
      drivers/net/cxgb3: fix sparse warnings: fix signedness
      drivers/net/cxgb3: fix sparse warning: symbol shadows an earlier one
      drivers/net/bonding: fix sparse warning: symbol shadows an earlier one
      drivers/net/bonding: fix sparse warnings: context imbalance
      drivers/net/atlx: fix sparse warnings: fix signedness
      drivers/net/atl1e: fix sparse warnings: fix signedness
      drivers/net/arcnet: fix sparse warning:  symbol shadows an earlier one
      drivers/net/s2io.c: fix sparse warning: symbol shadows an earlier one
      drivers/net/r6040.c: fix sparse warning: Using plain integer as NULL pointer
      drivers/net/ppp*.c: fix sparse warnings: fix signedness
      drivers/net/ni65.c: fix sparse warnings: fix signedness
      drivers/net/lance.c: fix sparse warnings: fix signedness
      drivers/net/niu.c: fix sparse warning: symbol shadows an earlier one
      drivers/net/ns83820.c: fix sparse warnings: fix signedness
      drivers/net/ni65.c: fix sparse warnings: symbol shadows an earlier one
      drivers/net/e2100.c: fix sparse warning: symbol shadows an earlier one
      drivers/net/at1700.c: fix sparse warning: symbol shadows an earlier one


 drivers/net/arcnet/arcnet.c              |    1 -
 drivers/net/at1700.c                     |    2 +-
 drivers/net/atl1e/atl1e.h                |    2 +-
 drivers/net/atl1e/atl1e_param.c          |    2 +-
 drivers/net/atlx/atl1.c                  |    2 +-
 drivers/net/atlx/atl2.c                  |    2 +-
 drivers/net/bonding/bond_alb.c           |    8 ++++++++
 drivers/net/bonding/bond_main.c          |   14 +++++++++++---
 drivers/net/cxgb3/ael1002.c              |    3 ++-
 drivers/net/cxgb3/cxgb3_main.c           |    3 +--
 drivers/net/e1000e/82571.c               |    2 +-
 drivers/net/e2100.c                      |    6 +++---
 drivers/net/hamradio/6pack.c             |    4 ++--
 drivers/net/hamradio/bpqether.c          |    5 ++++-
 drivers/net/hamradio/mkiss.c             |    9 +++++----
 drivers/net/hamradio/scc.c               |    3 ++-
 drivers/net/hamradio/yam.c               |    9 +++++----
 drivers/net/igb/igb_main.c               |    4 ++--
 drivers/net/ixgbe/ixgbe_82598.c          |    2 +-
 drivers/net/lance.c                      |   11 ++++++-----
 drivers/net/ni65.c                       |   11 +++++------
 drivers/net/niu.c                        |    2 +-
 drivers/net/ns83820.c                    |    2 +-
 drivers/net/pcmcia/axnet_cs.c            |    2 +-
 drivers/net/ppp_generic.c                |    2 +-
 drivers/net/pppoe.c                      |    2 +-
 drivers/net/pppol2tp.c                   |    2 +-
 drivers/net/r6040.c                      |    4 ++--
 drivers/net/s2io.c                       |    1 -
 drivers/net/sfc/mtd.c                    |    3 +++
 drivers/net/sfc/tenxpress.c              |    7 +++----
 drivers/net/skfp/h/smc.h                 |   17 +++++++++++++++++
 drivers/net/skfp/hwmtm.c                 |    9 ---------
 drivers/net/skfp/pcmplc.c                |    3 ---
 drivers/net/skfp/skfddi.c                |    3 ---
 drivers/net/skfp/smt.c                   |   10 ----------
 drivers/net/tokenring/lanstreamer.c      |    2 --
 drivers/net/tokenring/madgemc.c          |    2 --
 drivers/net/tokenring/olympic.c          |    1 -
 drivers/net/tokenring/smctr.c            |    3 ++-
 drivers/net/tokenring/smctr.h            |    2 +-
 drivers/net/tulip/de4x5.c                |    7 ++++---
 drivers/net/tulip/media.c                |    8 +++-----
 drivers/net/tulip/winbond-840.c          |    2 +-
 drivers/net/usb/hso.c                    |   10 +++++-----
 drivers/net/usb/smsc95xx.c               |    2 +-
 drivers/net/wan/lapbether.c              |    3 ++-
 drivers/net/wan/sbni.c                   |   17 +++++++++--------
 drivers/net/wan/z85230.c                 |    3 ++-
 drivers/net/wireless/airo.c              |    6 ++----
 drivers/net/wireless/ath9k/eeprom.c      |    8 ++++----
 drivers/net/wireless/b43/main.c          |   10 +++++-----
 drivers/net/wireless/ipw2x00/ipw2100.c   |    9 +++++----
 drivers/net/wireless/prism54/isl_ioctl.c |    3 ++-
 drivers/net/wireless/prism54/oid_mgt.c   |    2 +-
 drivers/net/wireless/strip.c             |    2 ++
 drivers/net/wireless/wavelan.c           |    8 ++++----
 include/linux/hdlcdrv.h                  |    2 +-
 58 files changed, 150 insertions(+), 136 deletions(-)
