From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 03 Aug 2013 12:38:21 -0700 (PDT)
Message-ID: <20130803.123821.1572551215235763371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Don't ignore user initiated wireless regulatory settings on cards
   with custom regulatory domains, from Arik Nemtsov.

2) Fix length check of bluetooth information responses, from Jaganath
   Kanakkassery.

3) Fix misuse of PTR_ERR in btusb, from Adam Lee.

4) Handle rfkill properly while iwlwifi devices are offline,
   from Emmanuel Grumbach.

5) Fix r815x devices DMA'ing to stack buffers, from Hayes Wang.

6) Kernel info leak in ATM packet scheduler, from Dan Carpenter.

7) 8139cp doesn't check for DMA mapping errors, from Neil Horman.

8) Fix bridge multicast code to not snoop when no querier exists,
   otherwise mutlicast traffic is lost.  From Linus L=FCssing.

9) Avoid soft lockups in fib6_run_gc(), from Michal Kubecek.

10) Fix races in automatic address asignment on ipv6, which can
    result in incorrect lifetime assignments.  From Jiri Benc.

11) Cure build bustage when CONFIG_NET_LL_RX_POLL is not set and
    rename it CONFIG_NET_RX_BUSY_POLL to eliminate the last reference
    to the original naming of this feature.  From Cong Wang.

12) Fix crash in TIPC when server socket creation fails, from Ying
    Xue.

13) macvlan_changelink() silently succeeds when it shouldn't, from
    Michael S. Tsirkin.

14) HTB packet scheduler can crash due to sign extension, fix from
    Stephen Hemminger.

15) With the cable unplugged, r8169 prints out a message every 10
    seconds, make it netif_dbg() instead of netif_warn().  From
    Peter Wu.

16) Fix memory leak in rtm_to_ifaddr(), from Daniel Borkmann.

17) sis900 gets spurious TX queue timeouts due to mismanagement of
    link carrier state, from Denis Kirjanov.

18) Validate somaxconn sysctl to make sure it fits inside of a
    u16.  From Roman Gushchin.

19) Fix MAC address filtering on qlcnic, from Shahed Shaikh.

Please pull, thanks a lot!

The following changes since commit 06693f305e60202d2795a10bee7fb7da23bc=
2acc:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2013-0=
7-31 12:56:18 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to 4bd8e7385961932d863ea976a67f384c3a8302cb=
:

  qlcnic: Fix for flash update failure on 83xx adapter (2013-08-03 12:0=
3:04 -0700)

----------------------------------------------------------------
AceLan Kao (2):
      Bluetooth: Add support for Atheros [0cf3:3121]
      Bluetooth: Add support for Atheros [0cf3:e003]

Adam Lee (1):
      Bluetooth: fix wrong use of PTR_ERR() in btusb

Arend van Spriel (1):
      brcmfmac: inform cfg80211 about disconnect when device is unplugg=
ed

Arik Nemtsov (1):
      regulatory: use correct regulatory initiator on wiphy register

Avinash Patil (2):
      mwifiex: check for bss_role instead of bss_mode for STA operation=
s
      mwifiex: fix wrong data rates in P2P client

Chun-Yeow Yeoh (1):
      mac80211: prevent the buffering or frame transmission to non-asso=
c mesh STA

Cong Wang (2):
      net: fix a compile error when CONFIG_NET_LL_RX_POLL is not set
      net: rename CONFIG_NET_LL_RX_POLL to CONFIG_NET_RX_BUSY_POLL

Dan Carpenter (1):
      net_sched: info leak in atm_tc_dump_class()

Daniel Borkmann (1):
      net: rtm_to_ifaddr: free ifa if ifa_cacheinfo processing fails

David S. Miller (1):
      Merge branch 'for-davem' of git://git.kernel.org/.../linville/wir=
eless

David Spinadel (1):
      iwlwifi: mvm: set SSID bits for passive channels

Denis Kirjanov (1):
      sis900: Fix the tx queue timeout issue

Emmanuel Grumbach (3):
      iwlwifi: add DELL SKU for 5150 HMC
      iwlwifi: pcie: reset the NIC before the bring up
      iwlwifi: pcie: clear RFKILL interrupt in AMPG

=46elipe Balbi (1):
      net: ethernet: cpsw: drop IRQF_DISABLED

=46rederic Danis (1):
      NFC: Fix NCI over SPI build

Geert Uytterhoeven (1):
      ath10k: ATH10K should depend on HAS_DMA

Gustavo Padovan (1):
      Bluetooth: Fix race between hci_register_dev() and hci_dev_open()

Himanshu Madhani (2):
      qlcnic: Free up memory in error path.
      qlcnic: Fix for flash update failure on 83xx adapter

Ilan Peer (1):
      iwlwifi: mvm: Disable managed PS when GO is added

Jack Morgenstein (1):
      net/mlx4_core: VFs must ignore the enable_64b_cqe_eqe module para=
m

Jaganath Kanakkassery (1):
      Bluetooth: Fix invalid length check in l2cap_information_rsp()

Jiri Benc (1):
      ipv6: prevent race between address creation and removal

Jiri Pirko (1):
      ipv6: move peer_addr init into ipv6_add_addr()

Joe Perches (1):
      ndisc: Add missing inline to ndisc_addr_option_pad

Johan Hedberg (2):
      Bluetooth: Fix HCI init for BlueFRITZ! devices
      Bluetooth: Fix calling request callback more than once

Johannes Berg (2):
      iwlwifi: mvm: use only a single GTK in D3
      iwlwifi: mvm: fix flushing not started aggregation sessions

John W. Linville (6):
      Merge branch 'for-linville-current' of git://github.com/kvalo/ath
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwi=
fi-fixes
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac8021=
1
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluet=
ooth
      Merge tag 'nfc-fixes-3.11-2' of git://git.kernel.org/.../sameo/nf=
c-fixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Kalle Valo (2):
      MAINTAINERS: add ath10k
      MAINTAINERS: update ath6kl git location

Lekensteyn (1):
      r8169: remove "PHY reset until link up" log spam

Linus L=FCssing (1):
      bridge: disable snooping if there is no querier

Luciano Coelho (1):
      MAINTAINERS: change email of TI WiLink drivers' maintainer

Michael S. Tsirkin (2):
      macvlan: better mode validation
      macvlan: handle set_promiscuity failures

Michal Kube=E8ek (2):
      ipv6: prevent fib6_run_gc() contention
      ipv6: update ip6_rt_last_gc every time GC is run

Mugunthan V N (1):
      net: ethernet: davinci_emac: drop IRQF_DISABLED

Neil Horman (1):
      8139cp: Add dma_mapping_error checking

Or Gerlitz (1):
      net/mlx4_core: Don't give VFs MAC addresses which are derived fro=
m the PF MAC

Paul Moore (1):
      netlabel: use domain based selectors when address based selectors=
 are not available

Pratik Pujar (1):
      qlcnic: Removed adapter series name from warning messages.

Rajesh Borundia (2):
      qlcnic: Fix link speed display for 82xx adapter
      qlcnic: Fix link speed and duplex display for 83xx adapter

Roman Gushchin (1):
      net: check net.core.somaxconn sysctl values

Samuel Ortiz (1):
      NFC: netlink: Rename CMD_FW_UPLOAD to CMD_FW_DOWNLOAD

Shahed Shaikh (3):
      qlcnic: Fix MAC address filter issue on 82xx adapter
      qlcnic: Fix ingress MAC learning
      qlcnic: Fix external loopback test.

Stanislaw Gruszka (3):
      mac80211: fix monitor interface suspend crash regression
      Bluetooth: ath3k: don't use stack memory for DMA
      rt2x00: fix stop queue

Stone Piao (1):
      mwifiex: fix command 0x2c timeout during p2p_find or p2p_connect

Sujith Manoharan (1):
      Bluetooth: ath3k: Add support for ID 0x13d3/0x3402

Thomas Loo (1):
      Bluetooth: ath3k: Add support for Fujitsu Lifebook UH5x2 [04c5:13=
30]

Tomasz Mo=F1 (1):
      mwifiex: Add missing endian conversion.

Ying Xue (1):
      tipc: fix oops when creating server socket fails

hayeswang (5):
      net/usb/r815x: replace USB buffer from stack to DMA-able
      net/usb/r815x: avoid to call mdio functions for runtime-suspended=
 device
      net/usb/r815x: change the return value for bind functions
      net/usb/r8152: make sure the USB buffer is DMA-able
      net/usb/r8152: adjust relative ocp function

stephen hemminger (1):
      htb: fix sign extension bug

 Documentation/sysctl/net.txt                             |   4 +-
 MAINTAINERS                                              |  12 +++++-
 drivers/bluetooth/ath3k.c                                |  46 +++++++=
++++++++++-----
 drivers/bluetooth/btusb.c                                |  18 +++++--=
--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h              |   8 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c          |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c         |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h                 |  12 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c            |   6 +--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c          |   6 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c           |   6 +--
 drivers/net/ethernet/mellanox/mlx4/fw.c                  |  11 +-----
 drivers/net/ethernet/mellanox/mlx4/main.c                |   2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h             |  10 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |  12 ++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      | 126 +++++++=
++++++++++++++++++++++++++++------------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h      |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    |  91 +++++++=
+++++++++++++++++++++--------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c          |  16 ++++---=
-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c      |  83 +++++++=
++++++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c           |  40 +++++++=
++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h           |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c         |  25 +++++++=
+----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c           | 101 +++++++=
++++++++++++++++++++++++----------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c         |  19 +++++--=
--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |   2 +-
 drivers/net/ethernet/realtek/8139cp.c                    |  48 +++++++=
++++++++++++++--
 drivers/net/ethernet/realtek/r8169.c                     |   2 +-
 drivers/net/ethernet/sis/sis900.c                        |  12 +-----
 drivers/net/ethernet/ti/cpsw.c                           |   2 +-
 drivers/net/ethernet/ti/davinci_emac.c                   |   3 +-
 drivers/net/macvlan.c                                    |  23 +++++++=
++--
 drivers/net/usb/r8152.c                                  | 126 +++++++=
++++++++++++++++++++--------------------------------
 drivers/net/usb/r815x.c                                  |  62 +++++++=
++++++++++++----------
 drivers/net/wireless/ath/ath10k/Kconfig                  |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c    |   5 ++-
 drivers/net/wireless/iwlwifi/iwl-prph.h                  |   2 +
 drivers/net/wireless/iwlwifi/mvm/d3.c                    |  15 ++++---
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h           |   1 -
 drivers/net/wireless/iwlwifi/mvm/mac80211.c              |  42 +++++++=
+++----------
 drivers/net/wireless/iwlwifi/mvm/scan.c                  |  11 +-----
 drivers/net/wireless/iwlwifi/mvm/sta.c                   |  11 ++++--
 drivers/net/wireless/iwlwifi/pcie/drv.c                  |   1 +
 drivers/net/wireless/iwlwifi/pcie/rx.c                   |   8 ++++
 drivers/net/wireless/iwlwifi/pcie/trans.c                |   5 +++
 drivers/net/wireless/mwifiex/cfg80211.c                  |   4 +-
 drivers/net/wireless/mwifiex/cfp.c                       |   3 +-
 drivers/net/wireless/mwifiex/join.c                      |   6 ++-
 drivers/net/wireless/mwifiex/sdio.c                      |   4 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c                 |   4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c                |  18 +++++--=
--
 include/linux/netdevice.h                                |   2 +-
 include/linux/skbuff.h                                   |   2 +-
 include/net/busy_poll.h                                  |  11 ++++--
 include/net/ip6_fib.h                                    |   2 +-
 include/net/ndisc.h                                      |   2 +-
 include/net/nfc/hci.h                                    |   2 +-
 include/net/nfc/nfc.h                                    |   4 +-
 include/net/sock.h                                       |   2 +-
 include/uapi/linux/nfc.h                                 |   6 +--
 net/Kconfig                                              |   2 +-
 net/bluetooth/hci_core.c                                 |  26 +++++++=
-----
 net/bridge/br_device.c                                   |   3 +-
 net/bridge/br_input.c                                    |   3 +-
 net/bridge/br_multicast.c                                |  39 +++++++=
++++++-----
 net/bridge/br_private.h                                  |  12 ++++++
 net/core/skbuff.c                                        |   2 +-
 net/core/sock.c                                          |   6 +--
 net/core/sysctl_net_core.c                               |   8 +++-
 net/ipv4/devinet.c                                       |   4 +-
 net/ipv6/addrconf.c                                      |  43 +++++++=
+++----------
 net/ipv6/ip6_fib.c                                       |  25 ++++++-=
-----
 net/ipv6/ndisc.c                                         |   4 +-
 net/ipv6/route.c                                         |   8 ++--
 net/mac80211/mesh_ps.c                                   |   4 ++
 net/mac80211/pm.c                                        |   7 +++-
 net/netlabel/netlabel_cipso_v4.c                         |   4 +-
 net/netlabel/netlabel_domainhash.c                       | 104 +++++++=
++++++++++++++++-------------------------
 net/netlabel/netlabel_domainhash.h                       |  46 +++++++=
++++-----------
 net/netlabel/netlabel_kapi.c                             |  88 +++++++=
++++++++++------------------------
 net/netlabel/netlabel_mgmt.c                             |  44 +++++++=
+++-----------
 net/netlabel/netlabel_unlabeled.c                        |   2 +-
 net/nfc/core.c                                           |  20 +++++--=
---
 net/nfc/hci/core.c                                       |   8 ++--
 net/nfc/nci/Kconfig                                      |   1 +
 net/nfc/netlink.c                                        |  12 +++---
 net/nfc/nfc.h                                            |   6 +--
 net/sched/sch_atm.c                                      |   1 +
 net/sched/sch_htb.c                                      |   2 +-
 net/socket.c                                             |   2 +-
 net/tipc/server.c                                        |  15 +++++--
 net/wireless/reg.c                                       |   5 ++-
 92 files changed, 995 insertions(+), 678 deletions(-)
