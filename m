From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 10 Apr 2011 21:31:17 -0700 (PDT)
Message-ID: <20110410.213117.35049775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is going to be a merge conflict to resolve, due to the tree
wide spelling fixes that went in last week, but it's trivial to
resolve.

1) ipset bug fixes from Jozsef Kadlecsik.

2) Fix regression in rt_iif management in ipv4 routes, reported
   and fixed by OGAWA Hirofumi.

3) Link sensing and RX ring buffer corruption fixes in mlx4 driver,
   from Yevgeny Petrilin.

4) Add some IDs to smsc95xx driver, from Steve Glendinning.

5) Add some IDs to mv88e6131 driver, from Peter Korsgaard.

6) Fix dead loop in pppoe driver, from Ulrich Weber.

7) Fix suspend/resume in be2net driver, from Padmanabh Ratnakar and
   Sarveswara Rao Mygapula.

8) B43 wireless doesn't allocate large enough RX buffers, from John
   W. Linville.

9) Array missing entry for 9485 revisions in ath9k driver, fix from
   Senthil Balasubramanian.

10) Fix duplicate wireless frames on cooked monitor, from Helmut
    Schaa.

11) Validate NVS file struct descriptor length given by the user,
    fix from Luciano Coelho.

12) Add IDs to p54usb driver, from Christian Lamparter.

13) Don't try to cancel work that never was created in rt2x00 driver,
    from Stanislaw Gruszka.

14) Fix mac_lock handling in smsc911x driver, from Enric Balletbo i Serra.

15) Handle firmware heartbeat failure properly in bnx driver, from
    Rasesh Mody and Debashis Dutt.

16) Fix shutdown crash in be2net driver, from Ajit Khaparde.

17) Missed setting rxhash of socket in ipv6 code, from Neil Horman.

Please pull, thanks a lot!

The following changes since commit 4263a2f1dad8c8e7ce2352a0cbc882c2b0c044a9:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6 (2011-04-10 09:56:10 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      be2net: Fix a potential crash during shutdown.

Christian Lamparter (1):
      p54usb: IDs for two new devices

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

David Sterba (1):
      netfilter: h323: bug in parsing of ASN1 SEQOF field

Enric Balletbo i Serra (2):
      smsc911x: fix mac_lock acquision before calling smsc911x_mac_read
      can: mcp251x: Allow pass IRQ flags through platform data.

Florian Westphal (4):
      netfilter: af_info: add network namespace parameter to route hook
      netfilter: af_info: add 'strict' parameter to limit lookup to .oif
      netfilter: xt_addrtype: replace rt6_lookup with nf_afinfo->route
      netfilter: xt_conntrack: fix inverted conntrack direction test

Hans Schillstrom (1):
      IPVS: fix NULL ptr dereference in ip_vs_ctl.c ip_vs_genl_dump_daemons()

Helmut Schaa (1):
      mac80211: Fix duplicate frames on cooked monitor

Ian Campbell (1):
      MAINTAINERS: add entry for Xen network backend

Johannes Berg (1):
      mac80211: fix comment regarding aggregation buf_size

John W. Linville (2):
      b43: allocate receive buffers big enough for max frame len + offset
      iwlwifi: accept EEPROM version 0x423 for iwl6000

Jozsef Kadlecsik (2):
      netfilter: ipset: list:set timeout variant fixes
      netfilter: ipset: references are protected by rwlock instead of mutex

Jussi Kivilinna (2):
      zd1211rw: remove URB_SHORT_NOT_OK flag in zd_usb_iowrite16v_async()
      zd1211rw: reset rx idle timer from tasklet

Larry Finger (1):
      rtlwifi: Fix some warnings/bugs

Luciano Coelho (2):
      wl12xx: fix module author's email address in the spi and sdio modules
      wl12xx: fix potential buffer overflow in testmode nvs push

Neil Horman (1):
      ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets (v2)

OGAWA Hirofumi (1):
      ipv4: Fix "Set rt->rt_iif more sanely on output routes."

Padmanabh Ratnakar (2):
      be2net: Rename some struct members for clarity
      be2net: Fix suspend/resume operation

Peter Korsgaard (1):
      dsa/mv88e6131: add support for mv88e6085 switch

Rasesh Mody (1):
      bna: Fix for handling firmware heartbeat failure

Senthil Balasubramanian (1):
      ath9k: Fix phy info print message with AR9485 chipset.

Stanislaw Gruszka (1):
      rt2x00: fix cancelling uninitialized work

Steve Glendinning (1):
      net: Add support for SMSC LAN9530, LAN9730 and LAN89530

Ulrich Weber (1):
      pppoe: drop PPPOX_ZOMBIEs in pppoe_flush_dev

Yevgeny Petrilin (2):
      mlx4: Sensing link type at device initialization
      mlx4_en: Restoring RX buffer pointer in case of failure

 MAINTAINERS                                       |    7 ++
 drivers/net/benet/be.h                            |    4 +-
 drivers/net/benet/be_main.c                       |   19 ++--
 drivers/net/bna/bfa_ioc.c                         |   10 +--
 drivers/net/can/mcp251x.c                         |    3 +-
 drivers/net/mlx4/en_rx.c                          |    4 +
 drivers/net/mlx4/main.c                           |    5 +
 drivers/net/mlx4/mlx4.h                           |    2 +
 drivers/net/mlx4/sense.c                          |    4 +-
 drivers/net/pppoe.c                               |    2 +-
 drivers/net/smsc911x.c                            |    8 +-
 drivers/net/usb/smsc95xx.c                        |   15 +++
 drivers/net/wireless/ath/ath9k/hw.c               |    1 +
 drivers/net/wireless/b43/dma.c                    |    2 +-
 drivers/net/wireless/b43/dma.h                    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |    2 +-
 drivers/net/wireless/p54/p54usb.c                 |    2 +
 drivers/net/wireless/rt2x00/rt2x00dev.c           |    6 +-
 drivers/net/wireless/rtlwifi/efuse.c              |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                |    2 +-
 drivers/net/wireless/wl12xx/sdio.c                |    2 +-
 drivers/net/wireless/wl12xx/spi.c                 |    2 +-
 drivers/net/wireless/wl12xx/testmode.c            |    5 +-
 drivers/net/wireless/zd1211rw/zd_usb.c            |   20 ++++-
 drivers/net/wireless/zd1211rw/zd_usb.h            |    1 +
 include/linux/can/platform/mcp251x.h              |    2 +
 include/linux/netfilter.h                         |    3 +-
 include/linux/netfilter/ipset/ip_set.h            |    2 +-
 include/linux/netfilter/ipset/ip_set_ahash.h      |    3 +-
 include/net/ip_vs.h                               |    2 +-
 include/net/mac80211.h                            |   15 +++-
 include/net/route.h                               |    5 +-
 net/dsa/mv88e6131.c                               |   23 ++++-
 net/dsa/mv88e6xxx.h                               |    2 +
 net/ipv4/netfilter.c                              |    5 +-
 net/ipv4/route.c                                  |    8 +-
 net/ipv4/xfrm4_policy.c                           |    1 +
 net/ipv6/netfilter.c                              |   13 ++-
 net/ipv6/tcp_ipv6.c                               |    4 +-
 net/ipv6/udp.c                                    |    3 +
 net/mac80211/rx.c                                 |    2 +-
 net/netfilter/Kconfig                             |    1 -
 net/netfilter/ipset/ip_set_bitmap_ip.c            |    3 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c         |    3 +-
 net/netfilter/ipset/ip_set_bitmap_port.c          |    3 +-
 net/netfilter/ipset/ip_set_core.c                 |  109 +++++++++++++--------
 net/netfilter/ipset/ip_set_list_set.c             |   53 +++++------
 net/netfilter/ipvs/ip_vs_ctl.c                    |    2 +-
 net/netfilter/nf_conntrack_h323_asn1.c            |    2 +-
 net/netfilter/nf_conntrack_h323_main.c            |   16 ++--
 net/netfilter/xt_TCPMSS.c                         |    2 +-
 net/netfilter/xt_addrtype.c                       |   42 ++++++---
 net/netfilter/xt_conntrack.c                      |    2 +-
 54 files changed, 301 insertions(+), 164 deletions(-)
