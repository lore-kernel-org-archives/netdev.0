From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 07 Sep 2014 16:41:09 -0700 (PDT)
Message-ID: <20140907.164109.1944849896872238507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbaIGXlL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:41:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix skb leak in mac802154, from Martin Townsend.

2) Use select not depends on NF_NAT for NFT_NAT, from Pablo Neira Ayuso=
=2E

3) Fix union initializer bogosity in vxlan, from Gerhard Stenzel.

4) Fix RX checksum configuration in stmmac driver, from Giuseppe
   CAVALLARO.

5) Fix TSO with non-accelerated VLANs in e1000, e1000e, bna, ehea, i40e=
,
   i40evf, mvneta, and qlge, from Vlad Yasevich.

6) Fix capability checks in phy_init_eee(), from Giuseppe CAVALLARO.

7) Try high order allocations more sanely for SKBs, specifically if a h=
igh
   order allocation fails, fall back directly to zero order pages rathe=
r than
   iterating down one order at a time.  From Eric Dumazet.

8) Fix a memory leak in openvswitch, from Li RongQing.

9) amd-xgbe initializes wrong spinlock, from Thomas Lendacky.

10) RTNL locking was busted in setsockopt for anycast and multicast, fi=
x
    from Sabrina Dubroca.

11) Fix peer address refcount leak in ipv6, from Nicolas Dichtel.

12) DocBook typo fixes, from Masanari Iida.

Please pull, thanks a lot!

The following changes since commit 451fd72219dd6f3355e2d036c598544c760e=
e532:

  Merge tag 'pwm/for-3.17-rc2' of git://git.kernel.org/pub/scm/linux/ke=
rnel/git/thierry.reding/linux-pwm (2014-08-22 14:50:21 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 45ce829dd010668c3839a61b25843590eb4677dc=
:

  Merge tag 'master-2014-09-04' of git://git.kernel.org/pub/scm/linux/k=
ernel/git/linville/wireless (2014-09-07 16:11:10 -0700)

----------------------------------------------------------------

Alexander Aring (2):
      ieee802154: 6lowpan_rtnl: fix correct errno value
      ieee802154: 6lowpan: ensure of sending 1280 packets

Alexander Y. Fomichev (1):
      net: prevent of emerging cross-namespace symlinks

Alexey Khoroshilov (1):
      at76c50x-usb: fix use after free on failure path in at76_probe()

Andy King (1):
      VMXNET3: Check for map error in vmxnet3_set_mc

Anish Bhatt (1):
      cnic : Cleanup CONFIG_IPV6 & VLAN check

Bartlomiej Zolnierkiewicz (2):
      net: sh_eth: fix driver dependencies
      net: calxedaxgmac: fix driver dependencies

Bob Copeland (1):
      mac80211: mesh_plink: handle confirm frames with new plid

Chen Gang (1):
      drivers/net/fddi/skfp/h/skfbi.h: Remove useless PCI_BASE_2ND macr=
os

Daniel Borkmann (2):
      netfilter: x_tables: allow to use default cgroup match
      net: sctp: fix ABI mismatch through sctp_assoc_to_state helper

Daniel Hellstrom (1):
      greth: moved TX ring cleaning to NAPI rx poll func

David S. Miller (10):
      Merge branch 'tso_fix'
      mvneta: Add missing if_vlan.h include.
      Merge branch 'mlx4-net'
      Merge branch 'stmmac-eee'
      Merge tag 'master-2014-08-25' of git://git.kernel.org/.../linvill=
e/wireless
      Merge branch 'amd-xgbe-net'
      Merge branch 'cxgb4'
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'amd-xgbe-net'
      Merge tag 'master-2014-09-04' of git://git.kernel.org/.../linvill=
e/wireless

Denton Gentry (1):
      mac80211: fix start_seq_num in Rx reorder offload

Eliad Peller (1):
      regulatory: add NUL to alpha2

Emmanuel Grumbach (2):
      Revert "iwlwifi: dvm: don't enable CTS to self"
      iwlwifi: bump firmware API version to 10 for 7000 and 8000

Eric Dumazet (1):
      net: attempt a single high order allocation

Eugene Crosser (1):
      qeth: don't query for info if hardware not ready.

=46elix Fietkau (2):
      mac80211: ignore AP_VLAN in ieee80211_recalc_chanctx_chantype
      mac80211: fix smps mode check for AP_VLAN

Geert Uytterhoeven (1):
      drivers: net: NET_XGENE should depend on HAS_DMA

Gerhard Stenzel (1):
      vxlan: fix incorrect initializer in union vxlan_addr

Giuseppe CAVALLARO (11):
      stmmac: fix rx checksum programming
      stmmac: set ptp_clock to NULL while unregister
      phy: fix EEE checks inside the phy_init_eee.
      stmmac: prevent false carrier sense detection
      stmmac: fix tipo on mmc crc error
      stmmac: ptp: fix the reference clock
      stmmac: fix dma api misuse
      stmmac: never check EEE in case of a switch is attached
      stmmac: fix PLS bit setting when EEE is active
      stmmac: fix the rx csum feature
      stmmac: only remove RXCSUM feature if no rx coe is available

Guillaume Nault (1):
      l2tp: fix race while getting PMTU on PPP pseudo-wire

Hariprasad Shenai (6):
      cxgb4: Fix for handling 1Gb/s SFP+ Transceiver Modules
      cxgb4: Fixed the code to use correct length for part number
      cxgb4: Fix T5 adapter accessing T4 adapter registers
      cxgb4: Detect and display firmware reported errors
      cxgb4: Avoid dumping Write-only registers in register dump
      cxgb4: Issue mbox commands on correct mbox

Hauke Mehrtens (1):
      bcma: add PCI ID for spromless BCM43217

Himangi Saraogi (1):
      rtlwifi: btcoexist: adjust double test

Ivan Vecera (1):
      tg3: prevent ifup/ifdown during PCI error recovery

Johan Hedberg (1):
      Bluetooth: Fix hci_conn reference counting for auto-connections

Johannes Berg (2):
      Revert "mac80211: disable uAPSD if all ACs are under ACM"
      mac80211: fix agg_status debugfs file alignment

John W. Linville (3):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge tag 'mac80211-for-john-2014-08-29' of git://git.kernel.org/=
=2E../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes

Jonas Jensen (4):
      net: moxa: clear DESC1 on ndo_start_xmit()
      net: moxa: replace build_skb() with netdev_alloc_skb_ip_align() /=
 memcpy()
      net: moxa: synchronize DMA memory
      net: moxa: continue loop on skb allocation failure

Julian Anastasov (2):
      ipvs: properly declare tunnel encapsulation
      ipvs: fix ipv6 hook registration for local replies

Larry Finger (1):
      rtlwifi: rtl8192cu: Add new ID

Lendacky, Thomas (7):
      amd-xgbe: Check for Tx hardware queue flushing support
      amd-xgbe: Reported fifo size from hardware is not correct
      amd-xgbe: Fix the xpcs mmd debugfs support
      amd-xgbe: Use the Tx queue count for Tx flow control support
      amd-xgbe: Fix initialization of the wrong spin lock
      amd-xgbe: Treat certain counter registers as 64 bit
      amd-xgbe: Enable interrupts for all management counters

Li RongQing (2):
      openvswitch: fix a memory leak
      openvswitch: distinguish between the dropped and consumed skb

Maks Naumov (1):
      ath9k: fix wrong string size for strncmp in write_file_spec_scan_=
ctl()

Manish Chopra (1):
      bnx2x: Configure device endianity on driver load and reset endian=
ity on removal.

Marcel Holtmann (1):
      iwlwifi: Remove module build requirement for Intel Wireless WiFi

Martin Townsend (3):
      mac802154: fixed potential skb leak with mac802154_parse_frame_st=
art
      ieee802154: mac802154: handle the reserved dest mode by dropping =
the packet
      ieee802154: 6lowpan: ensure MTU of 1280 for 6lowpan

Masanari Iida (1):
      net: treewide: Fix typo found in DocBook/networking.xml

Michal Kube=E8ek (1):
      net: fix checksum features handling in netif_skb_features()

Mika Westerberg (1):
      net: rfkill: gpio: Add more Broadcom bluetooth ACPI IDs

Neil Horman (1):
      3c59x: avoid panic in boomerang_start_xmit when finding page addr=
ess:

Nicolas Dichtel (2):
      ipv6: fix a refcnt leak with peer addr
      ipv6: use addrconf_get_prefix_route() to remove peer addr

Or Gerlitz (2):
      net/mlx4: Move the tunnel steering helper function to mlx4_core
      mlx4: Set user-space raw Ethernet QPs to properly handle VXLAN tr=
affic

Pablo Neira (1):
      netfilter: fix missing dependencies in NETFILTER_XT_TARGET_LOG

Pablo Neira Ayuso (4):
      netfilter: move NAT Kconfig switches out of the iptables scope
      netfilter: nf_tables: nat expression must select CONFIG_NF_NAT
      netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_*
      netfilter: add explicit Kconfig for NETFILTER_XT_NAT

Roland Stigge (1):
      net: lpc_eth: Fix crash on ip link up

Sabrina Dubroca (1):
      ipv6: fix rtnl locking in setsockopt for anycast and multicast

Vlad Yasevich (8):
      e1000e: Fix TSO with non-accelerated vlans
      e1000: Fix TSO for non-accelerated vlan traffic
      bna: Support TSO and partial checksum with non-accelerated vlans.
      ehea: Fix TSO and hw checksums with non-accelerated vlan packets.
      i40e: Fix TSO and hw checksums for non-accelerated vlan packets.
      i40evf: Fix TSO and hw checksums for non-accelerated vlan packets=
=2E
      mvneta: Fix TSO and checksum for non-acceleration vlan traffic
      qlge: Fix TSO for non-accelerated vlan traffic

WANG Cong (1):
      ipv6: restore the behavior of ipv6_sock_ac_drop()

Wei Liu (1):
      xen-netback: move netif_napi_add before binding interrupt

Willem de Bruijn (1):
      net-timestamp: only report sw timestamp if reporting bit is set

Yaniv Rosner (1):
      bnx2x: Fix link problems for 1G SFP RJ45 module

Zhouyi Zhou (1):
      netfilter: HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL

nandini sharma (2):
      stmmac: fix the EEE LPI Macro definitions.
      stmmac: fix LPI TW timer value to 20.5us.

=C1lvaro Fern=E1ndez Rojas (1):
      ssb: add PCI ID 0x4351

 Documentation/devicetree/bindings/net/stmmac.txt      |   4 ++
 drivers/bcma/host_pci.c                               |   1 +
 drivers/infiniband/hw/mlx4/main.c                     |  30 +++++++++
 drivers/infiniband/hw/mlx4/qp.c                       |   8 ++-
 drivers/net/ethernet/3com/3c59x.c                     |   8 +--
 drivers/net/ethernet/aeroflex/greth.c                 |  86 ++++++++++=
+++-----------
 drivers/net/ethernet/aeroflex/greth.h                 |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c          |   8 +--
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c              | 209 ++++++++++=
+++++++++++++++++++++++------------------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c              |   2 +
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c          |   7 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c             |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h                  |   4 ++
 drivers/net/ethernet/apm/xgene/Kconfig                |   1 +
 drivers/net/ethernet/broadcom/Kconfig                 |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h       |   7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c      |  74 ++++++++++=
+---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h      |   5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c      |  57 ++++++++++=
+-----
 drivers/net/ethernet/broadcom/cnic.c                  |   4 +-
 drivers/net/ethernet/broadcom/tg3.c                   |  16 +++++
 drivers/net/ethernet/broadcom/tg3.h                   |   1 +
 drivers/net/ethernet/brocade/bna/bnad.c               |   7 +-
 drivers/net/ethernet/calxeda/Kconfig                  |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c       |  16 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c            |  79 ++++++++++=
++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h          |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h         |   4 ++
 drivers/net/ethernet/ibm/ehea/ehea_main.c             |   2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c         |  19 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c            |  21 +++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c           |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c         |   2 +-
 drivers/net/ethernet/marvell/mvneta.c                 |   8 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  31 +--------
 drivers/net/ethernet/mellanox/mlx4/mcg.c              |  38 ++++++++++=
+
 drivers/net/ethernet/moxa/moxart_ether.c              |  34 +++++-----
 drivers/net/ethernet/nxp/lpc_eth.c                    |   3 +
 drivers/net/ethernet/qlogic/qlge/qlge_main.c          |   5 +-
 drivers/net/ethernet/renesas/Kconfig                  |   1 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c      |  14 ++--
 drivers/net/ethernet/stmicro/stmmac/common.h          |  13 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h       |   2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c  |   6 +-
 drivers/net/ethernet/stmicro/stmmac/mmc.h             |   2 +-
 drivers/net/ethernet/stmicro/stmmac/mmc_core.c        |   2 +-
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c       |  15 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |   9 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c  |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 142 ++++++++++=
+++++++++++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c      |   1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h      |   2 -
 drivers/net/fddi/skfp/h/skfbi.h                       |   5 --
 drivers/net/phy/phy.c                                 |  18 ++---
 drivers/net/vmxnet3/vmxnet3_drv.c                     |  15 +++--
 drivers/net/vmxnet3/vmxnet3_int.h                     |   4 +-
 drivers/net/vxlan.c                                   |   8 +--
 drivers/net/wireless/at76c50x-usb.c                   |   3 +-
 drivers/net/wireless/ath/ath9k/spectral.c             |   2 +-
 drivers/net/wireless/iwlwifi/Kconfig                  |   2 -
 drivers/net/wireless/iwlwifi/dvm/rxon.c               |  12 ++++
 drivers/net/wireless/iwlwifi/iwl-7000.c               |   4 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c               |   2 +-
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c           |   1 +
 drivers/net/xen-netback/interface.c                   |   6 +-
 drivers/s390/net/qeth_core.h                          |   1 +
 drivers/s390/net/qeth_core_main.c                     |  16 ++++-
 drivers/s390/net/qeth_l2_sys.c                        |   7 +-
 drivers/ssb/b43_pci_bridge.c                          |   1 +
 include/linux/mlx4/device.h                           |   3 +
 include/linux/netdevice.h                             |   4 +-
 include/linux/netfilter.h                             |   5 +-
 include/net/bluetooth/hci_core.h                      |   2 +
 include/net/netns/ieee802154_6lowpan.h                |   1 -
 include/net/regulatory.h                              |   2 +-
 include/net/sctp/sctp.h                               |  13 ++++
 include/net/sock.h                                    |   4 +-
 include/net/wimax.h                                   |   2 +-
 include/trace/events/irq.h                            |   4 +-
 net/bluetooth/hci_conn.c                              |   8 +++
 net/bluetooth/hci_core.c                              |  14 +++-
 net/bluetooth/hci_event.c                             |  17 ++++-
 net/core/datagram.c                                   |   2 +-
 net/core/dev.c                                        |  77 ++++++++++=
+++++++++--
 net/core/gen_estimator.c                              |   2 +-
 net/core/gen_stats.c                                  |   2 +-
 net/core/skbuff.c                                     |   4 +-
 net/core/sock.c                                       |  34 +++++-----
 net/ieee802154/6lowpan_rtnl.c                         |   4 +-
 net/ieee802154/reassembly.c                           |  15 +----
 net/ipv4/netfilter/Kconfig                            | 102 ++++++++++=
+++++-------------
 net/ipv4/netfilter/Makefile                           |   2 +-
 net/ipv6/addrconf.c                                   |  29 +++-----
 net/ipv6/anycast.c                                    |  10 +++
 net/ipv6/mcast.c                                      |  14 ++++
 net/ipv6/netfilter/Kconfig                            |  28 +++++---
 net/ipv6/netfilter/Makefile                           |   2 +-
 net/l2tp/l2tp_ppp.c                                   |   3 +-
 net/mac80211/chan.c                                   |   2 +
 net/mac80211/debugfs_sta.c                            |   2 +-
 net/mac80211/iface.c                                  |   4 +-
 net/mac80211/mesh_plink.c                             |   7 +-
 net/mac80211/mlme.c                                   |   3 +-
 net/mac80211/sta_info.c                               |   7 +-
 net/mac802154/wpan.c                                  |   6 +-
 net/netfilter/Kconfig                                 |  14 +++-
 net/netfilter/Makefile                                |   2 +-
 net/netfilter/core.c                                  |   6 +-
 net/netfilter/ipvs/ip_vs_core.c                       |   2 +-
 net/netfilter/ipvs/ip_vs_xmit.c                       |  20 ++++--
 net/netfilter/xt_cgroup.c                             |   2 +-
 net/openvswitch/datapath.c                            |  11 ++-
 net/rfkill/rfkill-gpio.c                              |   1 +
 net/sctp/socket.c                                     |   2 +-
 net/socket.c                                          |   5 +-
 116 files changed, 1082 insertions(+), 555 deletions(-)
