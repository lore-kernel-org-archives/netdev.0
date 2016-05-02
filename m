From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 02 May 2016 01:11:18 -0400 (EDT)
Message-ID: <20160502.011118.1650054764004895647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) MODULE_FIRMWARE firmware string not correct for iwlwifi 8000 chips,
   from Sara Sharon.

2) Fix SKB size checks in batman-adv stack on receive, from Sven
   Eckelmann.

3) Leak fix on mac80211 interface add error paths, from Johannes Berg.

4) Cannot invoke napi_disable() with BH disabled in myri10ge driver, fi=
x
   from Stanislaw Gruszka.

5) Fix sign extension problem when computing feature masks in
   net_gso_ok(), from Marcelo Ricardo Leitner.

6) lan78xx driver doesn't count packets and packet lengths in it's
   statistics properly, fix from Woojung Huh.

7) Fix the buffer allocation sizes in pegasus USB driver, from
   Petko Manolov.

8) Fix refcount overflows in bpf, from Alexei Starovoitov.

9) Unified dst cache handling introduced a preempt warning in
   ip_tunnel, fix by resetting rather then setting the cached
   route.  From Paolo Abeni.

10) Listener hash collision test fix in soreuseport, from Craig
    Gallak.

Please pull, thanks a lot!

The following changes since commit f28f20da704d399fb1e4d8838ffd697a357d=
9cc8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-0=
4-26 16:25:51 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git=20

for you to fetch changes up to b7f8fe251e4609e2a437bd2c2dea01e61db6849c=
:

  gre: do not pull header in ICMP error processing (2016-05-02 00:19:58=
 -0400)

----------------------------------------------------------------
Alexei Starovoitov (3):
      bpf: fix refcnt overflow
      bpf: fix check_map_func_compatibility logic
      samples/bpf: fix trace_output example

Andreas Larsson (1):
      MAINTAINERS: net: Change maintainer for GRETH 10/100/1G Ethernet =
MAC device driver

Arnd Bergmann (1):
      net/smscx5xx: use the device tree for mac address

Ayala Beker (1):
      iwlwifi: mvm: avoid to WARN about gscan capabilities

Bert Kenward (1):
      MAINTAINERS: net: update sfc maintainers

Christophe Jaillet (1):
      ps3_gelic: fix memcpy parameter

Colin Ian King (1):
      net: dsa: mv88e6xxx: fix uninitialized error return

Craig Gallek (1):
      soreuseport: Fix TCP listener hash collision

David Rivshin (5):
      drivers: net: cpsw: fix parsing of phy-handle DT property in dual=
_emac config
      drivers: net: cpsw: fix segfault in case of bad phy-handle
      drivers: net: cpsw: don't ignore phy-mode if phy-handle is used
      dt: cpsw: phy-handle, phy_id, and fixed-link are mutually exclusi=
ve
      drivers: net: cpsw: use of_phy_connect() in fixed-link case

David S. Miller (8):
      Merge branch 'bnxt_en-fixes'
      Merge tag 'wireless-drivers-for-davem-2016-04-25' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge tag 'batman-adv-fix-for-davem' of git://git.open-mesh.org/l=
inux-merge
      Merge tag 'mac80211-for-davem-2016-04-27' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'gre-lwt-fixes'
      Merge branch 'pegasus-sizes'
      Merge branch 'cpsw-phy-handle-fixes'
      Merge branch 'bpf-fixes'

Eric Engestrom (1):
      Documentation: networking: fix spelling mistakes

Hamish Martin (1):
      tipc: only process unicast on intended node

Jiri Benc (4):
      gre: do not assign header_ops in collect metadata mode
      gre: build header correctly for collect metadata tunnels
      gre: reject GUE and FOU in collect metadata mode
      gre: do not pull header in ICMP error processing

Johannes Berg (1):
      mac80211: fix statistics leak if dev_alloc_name() fails

Jon Cooper (1):
      sfc: disable RSS when unsupported

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2016-04-12_2' of https://git.kernel.=
org/.../iwlwifi/iwlwifi-fixes

Linus L=FCssing (1):
      batman-adv: Fix broadcast/ogm queue limit on a removed interface

Marcelo Ricardo Leitner (1):
      net: fix net_gso_ok for new GSO types.

Marek Lindner (1):
      batman-adv: init neigh node last seen field

Matti Gottlieb (1):
      iwlwifi: mvm: fix accessing Null pointer during fw dump collectio=
n

Michael Chan (3):
      bnxt_en: Don't fallback to INTA on VF.
      bnxt_en: Limit RX BD pages to be no bigger than 32K.
      bnxt_en: Divide a page into 32K buffers for the aggregation ring =
if necessary.

Michal Schmidt (1):
      cxgb3: fix out of bounds read

Neil Armstrong (1):
      net: ethernet: davinci_emac: Fix devioctl while in fixed link

Oleksij Rempel (1):
      ath9k: ar5008_hw_cmn_spur_mitigate: add missing mask_m & mask_p i=
nitialisation

Oren Givon (1):
      iwlwifi: add device IDs for the 8265 device

Paolo Abeni (1):
      ip_tunnel: fix preempt warning in ip tunnel creation/updating

Petko Manolov (2):
      pegasus: fixes URB buffer allocation size;
      pegasus: fixes reported packet length

Sara Sharon (1):
      iwlwifi: 8000: fix MODULE_FIRMWARE input

Stanislaw Gruszka (1):
      myri10ge: fix sleeping with bh disabled

Sven Eckelmann (3):
      batman-adv: Check skb size before using encapsulated ETH+VLAN hea=
der
      batman-adv: Deactivate TO_BE_ACTIVATED hardif on shutdown
      batman-adv: Reduce refcnt of removed router when updating route

Tim Bingham (1):
      net: Implement net_dbg_ratelimited() for CONFIG_DYNAMIC_DEBUG cas=
e

Timur Tabi (1):
      net: phy: at803x: only the AT8030 needs a hardware reset on link =
change

Wang Shanker (1):
      net: l2tp: fix reversed udp6 checksum flags

Woojung Huh (2):
      lan78xx: fix statistics counter error
      lan78xx: workaround of forced 100 Full/Half duplex mode error

 Documentation/devicetree/bindings/net/cpsw.txt    |  6 +++---
 Documentation/networking/altera_tse.txt           |  6 +++---
 Documentation/networking/ipvlan.txt               |  6 +++---
 Documentation/networking/pktgen.txt               |  6 +++---
 Documentation/networking/vrf.txt                  |  2 +-
 Documentation/networking/xfrm_sync.txt            |  6 +++---
 MAINTAINERS                                       |  5 +++--
 drivers/net/dsa/mv88e6xxx.c                       |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 53 +++++++++++++++=
+++++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 13 ++++++++++++
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c   |  3 ++-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c  |  4 ++--
 drivers/net/ethernet/sfc/ef10.c                   | 15 ++++++++++++--
 drivers/net/ethernet/ti/cpsw.c                    | 67 +++++++++++++++=
+++++++++++++++++----------------------------
 drivers/net/ethernet/ti/cpsw.h                    |  1 +
 drivers/net/ethernet/ti/davinci_emac.c            |  5 ++++-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c |  2 +-
 drivers/net/phy/at803x.c                          | 40 +++++++++++++++=
+--------------------
 drivers/net/usb/lan78xx.c                         | 44 +++++++++++++++=
++++++++++++++++++------
 drivers/net/usb/pegasus.c                         | 10 ++++-----
 drivers/net/usb/smsc75xx.c                        | 12 ++++++++++-
 drivers/net/usb/smsc95xx.c                        | 12 ++++++++++-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c       |  8 +++-----
 drivers/net/wireless/ath/ath9k/ar9002_phy.c       |  5 -----
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c     |  2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c      | 26 +++++++++------=
--------
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c   |  6 ++++--
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c       |  2 ++
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c     | 10 +++++++++
 include/linux/bpf.h                               |  3 ++-
 include/linux/net.h                               | 10 ++++++++-
 include/linux/netdevice.h                         |  2 +-
 kernel/bpf/inode.c                                |  7 ++++---
 kernel/bpf/syscall.c                              | 24 +++++++++++++++=
+++----
 kernel/bpf/verifier.c                             | 76 +++++++++++++++=
+++++++++++++++++++++++++++--------------------------
 net/batman-adv/hard-interface.c                   |  3 +--
 net/batman-adv/originator.c                       |  1 +
 net/batman-adv/routing.c                          |  9 ++++++++
 net/batman-adv/send.c                             |  6 ++++++
 net/batman-adv/soft-interface.c                   |  8 ++++++--
 net/ipv4/inet_hashtables.c                        |  2 ++
 net/ipv4/ip_gre.c                                 | 30 +++++++++++++++=
++++--------
 net/ipv4/ip_tunnel.c                              |  4 ++--
 net/l2tp/l2tp_core.c                              |  4 ++--
 net/mac80211/iface.c                              |  4 ++--
 net/tipc/node.c                                   |  5 +++++
 samples/bpf/trace_output_kern.c                   |  1 -
 47 files changed, 384 insertions(+), 194 deletions(-)
