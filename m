From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 06 Jun 2017 16:57:26 -0400 (EDT)
Message-ID: <20170606.165726.1859112874773873862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Made TCP congestion control documentation match current reality,
   from Anmol Sarma.

2) Various build warning and failure fixes from Arnd Bergmann.

3) Fix SKB list leak in ipv6_gso_segment().

4) Use after free in ravb driver, from Eugeniu Rosca.

5) Don't use udp_poll() in ping protocol driver, from Eric Dumazet.

6) Don't crash in PCI error recovery of cxgb4 driver, from Guilherme
   G. Piccoli.

7) _SRC_NAT_DONE_BIT needs to be cleared using atomics, from Liping Zhang.

8) Use after free in vxlan deletion, from Mark Bloch.

9) Fix ordering of NAPI poll enabled in ethoc driver, from Max Filippov.

10) Fix stmmac hangs with TSO, from Niklas Cassel.

11) Fix crash in CALIPSO ipv6, from Richard Haines.

12) Clear nh_flags properly on mpls link up.  From Roopa Prabhu.

13) Fix regression in sk_err socket error queue handling, noticed by
    ping applications.  From Soheil Hassas Yeganeh.

14) Update mlx4/mlx5 MAINTAINERS information.

Please pull, thanks a lot!

The following changes since commit e2a9aa5ab2a4d1fb05fcdfa9661d54e437093297:

  Merge tag 'led_fixes_for_4-12-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/j.anaszewski/linux-leds (2017-05-26 14:02:30 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 1d3028f4c16487d63861ab6c68451768a7a109df:

  net: stmmac: fix a broken u32 less than zero check (2017-06-06 16:26:28 -0400)

----------------------------------------------------------------
Andrew Lunn (2):
      net: dsa: mv88e6xxx: Add eeprom-length to binding
      net: dsa: mv88e6xxx: Add missing static to stub functions

Anmol Sarma (1):
      net: Update TCP congestion control documentation

Arend Van Spriel (1):
      brcmfmac: fix alignment configuration on host using 64-bit DMA

Arnd Bergmann (2):
      net: dsa: mv88e6xxx: Add missing static to stub functions
      net/mlx5: avoid build warning for uniprocessor

Ben Hutchings (1):
      ipv6: xfrm: Handle errors reported by xfrm6_find_1stfragopt()

Bjorn Andersson (1):
      wcn36xx: Close SMD channel on device removal

Björn Töpel (1):
      i40e/i40evf: proper update of the page_offset field

Chopra, Manish (1):
      qlcnic: Fix tunnel offload for 82xx adapters

Colin Ian King (2):
      net: stmmac: ensure jumbo_frm error return is correctly checked for -ve value
      net: stmmac: fix a broken u32 less than zero check

David S. Miller (8):
      Merge git://git.kernel.org/.../pablo/nf
      Merge branch 'mlx4-mlx5-MAINTAINERS-update'
      Merge branch 'ARM-imx6ul-14x14-evk-Fix-suspend-over-nfs-by-phy'
      Merge tag 'mac80211-for-davem-2017-06-02' of git://git.kernel.org/.../jberg/mac80211
      ipv6: Fix leak in ipv6_gso_segment().
      Revert "sit: reload iphdr in ipip6_rcv"
      Merge branch '40GbE' of git://git.kernel.org/.../jkirsher/net-queue
      Merge tag 'wireless-drivers-for-davem-2017-06-06' of git://git.kernel.org/.../kvalo/wireless-drivers

Davide Caratti (1):
      netfilter: conntrack: fix false CRC32c mismatch using paged skb

Douglas Caetano dos Santos (1):
      tcp: reinitialize MTU probing when setting MSS in a TCP repair

Emmanuel Grumbach (1):
      iwlwifi: mvm: fix firmware debug restart recording

Eric Dumazet (1):
      net: ping: do not abuse udp_poll()

Eric Garver (1):
      geneve: fix needed_headroom and max_mtu for collect_metadata

Eugeniu Rosca (1):
      ravb: Fix use-after-free on `ifconfig eth0 down`

Firo Yang (1):
      hdlcdrv: Fix divide by zero in hdlcdrv_ioctl

Florian Fainelli (3):
      net: systemport: Fix missing Wake-on-LAN interrupt for SYSTEMPORT Lite
      net: dsa: Move dsa_switch_{suspend,resume} out of legacy.c
      net: dsa: Fix stale cpu_switch reference after unbind then bind

Ganesh Goudar (2):
      cxgb4: update latest firmware version supported
      cxgb4: avoid enabling napi twice to the same queue

Gregory Greenman (1):
      iwlwifi: mvm: rs: start using LQ command color

Guilherme G. Piccoli (1):
      cxgb4: avoid crash on PCI error recovery path

Gustavo A. R. Silva (1):
      net: freescale: fix potential null pointer dereference

Haim Dreyfuss (1):
      iwlwifi: mvm: Fix command queue number on d0i3 flow

Haishuang Yan (2):
      sit: reload iphdr in ipip6_rcv
      devlink: fix potential memort leak

Ido Shamay (1):
      net/mlx4: Check if Granular QoS per VF has been enabled before updating QP qos_vport

Jia-Ju Bai (3):
      isdn: Fix a sleep-in-atomic bug
      qlcnic: Fix a sleep-in-atomic bug in qlcnic_82xx_hw_write_wx_2M and qlcnic_82xx_hw_read_wx_2M
      mISDN: Fix a sleep-in-atomic bug

Johannes Berg (4):
      mac80211: fix TX aggregation start/stop callback race
      mac80211: fix dropped counter in multiqueue RX
      iwlwifi: tt: move ucode_loaded check under mutex
      iwlwifi: mvm: clear new beacon command template struct

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2017-06-05' of git://git.kernel.org/.../iwlwifi/iwlwifi-fixes

Lance Richardson (1):
      vxlan: eliminate cached dst leak

Leonard Crestez (2):
      ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
      net: phy: micrel: Restore led_mode and clk_sel on resume

Liad Kaufman (1):
      iwlwifi: mvm: support ibss in dqa mode

Liam McBirnie (1):
      ip6_tunnel: fix traffic class routing for tunnels

Liping Zhang (2):
      netfilter: nat: use atomic bit op to clear the _SRC_NAT_DONE_BIT
      netfilter: ctnetlink: fix incorrect nf_ct_put during hash resize

Luca Coelho (3):
      iwlwifi: pcie: only use d0i3 in suspend/resume if system_pm is set to d0i3
      iwlwifi: mvm: don't fail when removing a key from an inexisting sta
      iwlwifi: fix min API version for 7265D, 3168, 8000 and 8265

Madalin Bucur (1):
      Documentation: networking: add DPAA Ethernet document

Mark Bloch (1):
      vxlan: fix use-after-free on deletion

Mauro S. M. Rodrigues (1):
      i40e: Fix state flags for bit set and clean operations of PF

Max Filippov (1):
      net: ethoc: enable NAPI before poll may be scheduled

Michael S. Tsirkin (1):
      virtio_net: lower limit on buffer size

Michal Hocko (1):
      amd-xgbe: use PAGE_ALLOC_COSTLY_ORDER in xgbe_map_rx_buffer

Mintz, Yuval (2):
      qed: Don't log missing periodic stats by default
      bnx2x: Fix Multi-Cos

Nicolas Dichtel (1):
      netlink: don't send unknown nsid

Niklas Cassel (1):
      net: stmmac: fix completely hung TX when using TSO

Nikolay Aleksandrov (2):
      net: bridge: start hello timer only if device is up
      net: bridge: fix a null pointer dereference in br_afspec

Pablo Neira Ayuso (1):
      netfilter: nft_set_rbtree: handle element re-addition after deletion

Randy Dunlap (1):
      net: phy: fix kernel-doc warnings

Richard Haines (1):
      net/ipv6: Fix CALIPSO causing GPF with datagram support

Roopa Prabhu (1):
      mpls: fix clearing of dead nh_flags on link up

Russell King (2):
      net: phy: fix marvell phy status reading
      net: fix auto-loading of Marvell DSA driver

Shahar S Matityahu (1):
      iwlwifi: fix host command memory leaks

Soheil Hassas Yeganeh (1):
      sock: reset sk_err when the error queue is empty

Talat Batheesh (1):
      net/mlx4: Fix the check in attaching steering rules

Tariq Toukan (3):
      MAINTAINERS: Update MELLANOX MLX4 core VPI driver maintainer
      MAINTAINERS: Move mlx4 rdma header file to IB driver charge
      MAINTAINERS: Move mlx5 rdma header file to IB driver charge

Thomas Falcon (1):
      ibmvnic: Remove module author mailing address

Thor Thayer (1):
      net: ethernet: stmmac: Fix altr_tse_pcs SGMII Initialization

Timur Tabi (1):
      net: qcom/emac: do not use hardware mdio automatic polling

Yuchung Cheng (1):
      tcp: disallow cwnd undo when switching congestion control

 Documentation/devicetree/bindings/net/dsa/marvell.txt    |   4 +++
 Documentation/networking/dpaa.txt                        | 194 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Documentation/networking/tcp.txt                         |  31 +++++++---------
 MAINTAINERS                                              |   6 ++--
 arch/arm/boot/dts/imx6ul-14x14-evk.dts                   |   6 ++++
 drivers/isdn/i4l/isdn_ppp.c                              |   2 +-
 drivers/isdn/mISDN/stack.c                               |   2 +-
 drivers/net/dsa/mv88e6xxx/global2.h                      |   6 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c                |   5 ++-
 drivers/net/ethernet/broadcom/bcmsysport.c               |   7 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c          |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c          |  25 ++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c               |   9 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h        |   6 ++--
 drivers/net/ethernet/ethoc.c                             |   3 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c             |   9 ++++-
 drivers/net/ethernet/ibm/ibmvnic.c                       |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c              |  36 +++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c              |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c            |   3 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c          |   5 ---
 drivers/net/ethernet/mellanox/mlx4/mcg.c                 |  15 +++++---
 drivers/net/ethernet/mellanox/mlx4/qp.c                  |  19 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c    |  16 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c           |   5 ++-
 drivers/net/ethernet/qlogic/qed/qed_main.c               |   3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |  26 ++++++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |   2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c           |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |   2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   2 ++
 drivers/net/ethernet/qualcomm/emac/emac-mac.c            |   2 +-
 drivers/net/ethernet/qualcomm/emac/emac-phy.c            |  75 +++-----------------------------------
 drivers/net/ethernet/qualcomm/emac/emac.c                |  22 +-----------
 drivers/net/ethernet/renesas/ravb_main.c                 |  24 ++++++-------
 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c       |   6 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c        |   7 ++--
 drivers/net/geneve.c                                     |   2 +-
 drivers/net/hamradio/hdlcdrv.c                           |   2 ++
 drivers/net/phy/marvell.c                                |   2 --
 drivers/net/phy/mdio_bus.c                               |  13 +++++++
 drivers/net/phy/micrel.c                                 |  42 ++++++++++++++--------
 drivers/net/phy/phy.c                                    |   2 +-
 drivers/net/virtio_net.c                                 |   5 +--
 drivers/net/vxlan.c                                      |  39 +++++++++++++++-----
 drivers/net/wireless/ath/wcn36xx/main.c                  |   2 ++
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c  |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c            |   4 +--
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c            |   4 +--
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h            |   1 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rs.h       |   5 +++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h       |   3 ++
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c          |  12 +------
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c        |   2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h             |   6 +++-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c             |  32 ++++++++++++-----
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c              |  46 ++++++------------------
 drivers/net/wireless/intel/iwlwifi/mvm/rs.h              |  15 ++++++++
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c             |  26 +++++++++-----
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h             |   2 ++
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c              |   8 +++--
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c              |  12 ++++++-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c          |   6 ++--
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c        |   9 +++--
 include/linux/mlx4/qp.h                                  |   1 +
 include/net/ipv6.h                                       |   1 +
 include/net/tcp.h                                        |   2 +-
 net/bridge/br_netlink.c                                  |   2 +-
 net/bridge/br_stp_if.c                                   |   3 +-
 net/core/devlink.c                                       |   8 +++--
 net/core/skbuff.c                                        |   5 ++-
 net/dsa/dsa.c                                            |  47 ++++++++++++++++++++++++
 net/dsa/dsa2.c                                           |   4 ++-
 net/dsa/legacy.c                                         |  47 ------------------------
 net/ipv4/af_inet.c                                       |   2 +-
 net/ipv4/tcp.c                                           |   6 ++--
 net/ipv4/tcp_cong.c                                      |   1 +
 net/ipv6/calipso.c                                       |   6 +++-
 net/ipv6/ip6_offload.c                                   |   4 ++-
 net/ipv6/ip6_tunnel.c                                    |   3 ++
 net/ipv6/ping.c                                          |   2 +-
 net/ipv6/raw.c                                           |   2 +-
 net/ipv6/xfrm6_mode_ro.c                                 |   2 ++
 net/ipv6/xfrm6_mode_transport.c                          |   2 ++
 net/mac80211/agg-tx.c                                    | 128 +++++++++++++++++++++++++++--------------------------------------
 net/mac80211/ht.c                                        |  16 ++++++---
 net/mac80211/ieee80211_i.h                               |  14 +++-----
 net/mac80211/iface.c                                     |  11 +-----
 net/mac80211/sta_info.c                                  |   2 +-
 net/mac80211/sta_info.h                                  |   2 ++
 net/mpls/af_mpls.c                                       |   2 +-
 net/netfilter/nf_conntrack_netlink.c                     |   7 +++-
 net/netfilter/nf_conntrack_proto_sctp.c                  |   9 +++--
 net/netfilter/nf_nat_core.c                              |   2 +-
 net/netfilter/nft_set_rbtree.c                           |  22 ++++++------
 net/netlink/af_netlink.c                                 |   4 ++-
 96 files changed, 781 insertions(+), 486 deletions(-)
 create mode 100644 Documentation/networking/dpaa.txt
