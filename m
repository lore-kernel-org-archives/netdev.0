From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 18 Oct 2015 23:56:44 -0700 (PDT)
Message-ID: <20151018.235644.1006391218810005395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Account for extra headroom in ath9k driver, from Felix Fietkau.

2) Fix OOPS in pppoe driver due to incorrect socket state transition,
   from Guillaume Nault.

3) Kill memory leak in amd-xgbe debugfx, from Geliang Tang.

4) Power management fixes for iwlwifi, from Johannes Berg.

5) Fix races in reqsk_queue_unlink(), from Eric Dumazet.

6) Fix dst_entry usage in ARP replies, from Jiri Benc.

7) Cure OOPSes with SO_GET_FILTER, from Daniel Borkmann.

8) Missing allocation failure check in amd-xgbe, from Tom
   Lendacky.

9) Various resource allocation/freeing cures in DSA< from
   Neil Armstrong.

10) A series of bug fixes in the openvswitch conntrack support,
    from Joe Stringer.

11) Fix two cases (BPF and act_mirred) where we have to clean the
    sender cpu stored in the SKB before transmitting.  From WANG
    Cong and Alexei Starovoitov.

12) Disable VLAN filtering in promiscuous mode in mlx5 driver, from
    Achiad Shochat.

13) Older bnx2x chips cannot do 4-tuple UDP hashing, so prevent
    this configuration via ethtool.  From Yuval Mintz.

14) Don't call rt6_uncached_list_flush_dev() from rt6_ifdown()
    when 'dev' is NULL, from Eric Biederman.

15) Prevent stalled link synchronization in tipc, from Jon
    Paul Maloy.

16) kcalloc() gstrings ethtool buffer before having driver fill
    it in, in order to prevent kernel memory leaking.  From
    Joe Perches.

17) Fix mixxing rt6_info initialization for blackhole routes, from
    Martin KaFai Lau.

18) Kill VLAN regression in via-rhine, from Andrej Ota.

19) Missing pfmemalloc check in sk_add_backlog(), from Eric Dumazet.

20) Fix spurious MSG_TRUNC signalling in netlink dumps, from Ronen
    Arad.

21) Scrube SKBs when pushing them between namespaces in openvswitch,
    from Joe Stringer.

22) bcmgenet enables link interrupts too early, fix from Florian
    Fainelli.

Please pull, thanks a lot!

The following changes since commit 36f8dafe52b0d0726edd5102900e37192f1d=
3c65:

  Merge tag 'mmc-v4.3-rc3' of git://git.linaro.org/people/ulf.hansson/m=
mc (2015-10-02 08:03:04 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 37850e37fcfb4dd831bc9e33221e8c49a732956f=
:

  net: bcmgenet: Fix early link interrupt enabling (2015-10-18 23:07:12=
 -0700)

----------------------------------------------------------------
Achiad Shochat (1):
      net/mlx5e: Disable VLAN filter in promiscuous mode

Alexei Starovoitov (1):
      bpf: clear sender_cpu before xmit

Andrei Otcheretianski (1):
      iwlwifi: mvm: flush fw_dump_wk when mvm fails to start

Andrej Ota (1):
      via-rhine: fix VLAN receive handling regression.

Andrey Vagin (1):
      net/unix: fix logic about sk_peek_offset

Arad, Ronen (2):
      rtnetlink: fix gcc -Wconversion warning
      netlink: Trim skb to alloc size to avoid MSG_TRUNC

Arik Nemtsov (1):
      iwlwifi: mvm: init card correctly on ctkill exit check

Arnd Bergmann (1):
      mlxsw: fix warnings for big-endian 32-bit dma_addr_t

Avraham Stern (1):
      iwlwifi: mvm: clear csa countdown when AP is stopped

Carol L Soto (2):
      net/mlx4: Remove shared_ports variable at mlx4_enable_msi_x
      net/mlx4_core: Avoid failing the interrupts test

Chia-Sheng Chang (1):
      net: asix: add support for the Billionton GUSB2AM-1G-B USB adapte=
r

Daniel Borkmann (1):
      bpf: fix panic in SO_GET_FILTER with native ebpf programs

David Ahern (1):
      net: Fix vti use case with oif in dst lookups for IPv6

David B. Robins (1):
      net: usb: asix: Fix crash on skb alloc failure

David S. Miller (11):
      Merge tag 'linux-can-fixes-for-4.3-20150930' of git://git.kernel.=
org/.../mkl/linux-can
      Merge tag 'wireless-drivers-for-davem-2015-10-01' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers
      Merge branch 'dsa-unbind'
      Merge branch 'ovs-ct-fixes'
      Merge branch 'mlx'
      Merge branch 'mlxsw-fixes'
      Merge branch 'be2net-fixes'
      Merge tag 'mac80211-for-davem-2015-10-13' of git://git.kernel.org=
/.../jberg/mac80211
      Merge branch 'ipv6-blackhole-route-fix'
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth=
/bluetooth
      Merge tag 'wireless-drivers-for-davem-2015-10-17' of git://git.ke=
rnel.org/.../kvalo/wireless-drivers

Elad Raz (1):
      mlxsw: switchx2: changing order of exit fallbacks

Eric Dumazet (2):
      inet: fix race in reqsk_queue_unlink()
      net: add pfmemalloc check in sk_add_backlog()

Eric W. Biederman (1):
      ipv6: Don't call with rt6_uncached_list_flush_dev

=46elix Fietkau (3):
      mac80211: fix handling of PS filtering with fast-xmit
      ath9k: declare required extra tx headroom
      ath10k: fix DMA related firmware crashes on multiple devices

=46lorian Fainelli (1):
      net: bcmgenet: Fix early link interrupt enabling

Geliang Tang (1):
      amd-xgbe: fix potential memory leak in xgbe-debugfs

Gerlando Falauto (2):
      net/fsl_pq_mdio: check TBI address for consistency with mapped ra=
nge
      net/fsl_pq_mdio: fix computed address for the TBI register

Guillaume Nault (1):
      ppp: don't override sk->sk_state in pppoe_flush_dev()

Hannes Frederic Sowa (2):
      ipv6: gre: setup default multicast routes over PtP links
      ipv6: drop frames with attached skb->sk in forwarding

Ido Schimmel (2):
      mlxsw: Fix bug in __mlxsw_item_bit_array_offset
      mlxsw: core: Fix race condition in __mlxsw_emad_transmit

Ido Shamay (1):
      MAINTAINERS: Update mlx4_en driver entry

Insu Yun (1):
      xen-netback: correctly check failed allocation

Jakub Pawlowski (2):
      Bluetooth: Fix double scan updates
      Bluetooth: Fix initializing conn_params in scan phase

Jean Delvare (1):
      net: mdio-octeon: Drop obsolete Kconfig advice

Jesse Brandeburg (1):
      i40e: fix offload of GRE tunnels

Jesse Gross (1):
      tunnels: Don't require remote endpoint or ID during creation.

Jiri Benc (1):
      ipv4: fix reply_dst leakage on arp reply

Jiri Pirko (1):
      net/mlx5: Fix typo in mlx5_query_port_pvlc

Joe Perches (1):
      ethtool: Use kcalloc instead of kmalloc for ethtool_get_strings

Joe Stringer (8):
      openvswitch: Rename LABEL->LABELS
      openvswitch: Fix typos in CT headers
      openvswitch: Fix skb leak in ovs_fragment()
      openvswitch: Ensure flow is valid before executing ct
      openvswitch: Reject ct_state unsupported bits
      openvswitch: Extend ct_state match field to 32 bits
      openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT
      openvswitch: Scrub skb between namespaces

Johan Hedberg (4):
      Bluetooth: Fix reference counting for LE-scan based connections
      Bluetooth: Fix LE reconnection logic
      Bluetooth: Fix remove_device behavior for explicit connects
      Bluetooth: Fix conn_params list update in hci_connect_le_scan_cle=
anup

Johannes Berg (4):
      iwlwifi: mvm: fix D3 CCMP TX PN assignment
      iwlwifi: dvm: fix D3 firmware PN programming
      iwlwifi: mvm: fix D3 firmware PN programming
      iwlwifi: fix firmware filename for 3160

Jon Paul Maloy (2):
      tipc: eliminate risk of stalled link synchronization
      tipc: move fragment importance field to new header position

Kalesh AP (2):
      be2net: fix BE3-R FW download compatibility check
      be2net: remove vlan promisc capability from VF's profile descript=
ors

Kalle Valo (1):
      Merge tag 'iwlwifi-for-kalle-2015-10-05' of git://git.kernel.org/=
=2E../iwlwifi/iwlwifi-fixes

Konstantin Khlebnikov (1):
      ovs: do not allocate memory from offline numa node

Larry Finger (1):
      rtlwifi: rtl8821ae: Fix system lockups on boot

Luca Coelho (1):
      iwlwifi: pci: add a few more PCI subvendor IDs for the 7265 serie=
s

Martin KaFai Lau (2):
      ipv6: Move common init code for rt6_info to a new function rt6_in=
fo_init()
      ipv6: Initialize rt6_info properly in ip6_blackhole_route()

Mitch Williams (1):
      i40e/i40evf: set AQ count after memory allocation

Mohammed Shafi Shajakhan (1):
      mac80211: Fix hwflags debugfs file format

Neil Armstrong (5):
      net: dsa: add missing kfree on remove
      net: dsa: add missing dsa_switch mdiobus remove
      net: dsa: complete dsa_switch_destroy
      net: dsa: switch to devm_ calls and remove kfree calls
      net: dsa: exit probe if no switch were found

Nicolas Schichan (1):
      ARM: net: make BPF_LD | BPF_IND instruction trigger r_X initialis=
ation to 0.

Nikolay Aleksandrov (1):
      switchdev: check if the vlan id is in the proper vlan range

Paul Moore (1):
      af_unix: constify the sock parameter in unix_sk()

Pravin B Shelar (1):
      openvswitch: Fix ovs_vport_get_stats()

Raanan Avargil (1):
      tcp/dccp: fix old style declarations

Rafa=A9=A9 Mi=A9=A9ecki (1):
      b43: probe bcma core (device) rev 0x15

Somnath Kotur (1):
      be2net: set pci_func_num while issuing GET_PROFILE_CONFIG cmd

Stanislaw Gruszka (1):
      rt2800usb: add usb ID 1b75:3070 for Airlive WT-2000USB

Stephane Grosjean (1):
      can: peak_pci: add unused device id. in devices table

Suresh Reddy (2):
      be2net: release mcc-lock in a failure case in be_cmd_notify_wait(=
)
      be2net: pad skb to meet minimum TX pkt size in BE3

Tom Lendacky (1):
      amd-xgbe: Check for successful buffer allocation before use

Vladimir Zapolskiy (1):
      net: lpc_eth: fix warnings caused by enabling unprepared clock

WANG Cong (4):
      act_mirred: fix a race condition on mirred_list
      act_mirred: always release tcf hash
      act_mirred: clear sender cpu before sending to tx
      sch_hhf: fix return value of hhf_drop()

Yuval Mintz (1):
      bnx2x: Prevent UDP 4-tuple configurations on older adapters

 MAINTAINERS                                             |    1 -
 arch/arm/net/bpf_jit_32.c                               |    1 +
 drivers/net/can/sja1000/peak_pci.c                      |    1 +
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c            |    4 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c     |    7 ++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.c          |   32 +++++++=
+++++++++-------
 drivers/net/ethernet/emulex/benet/be.h                  |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c             |   31 +++++++=
++++++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.h             |   10 ++++++-=
-
 drivers/net/ethernet/emulex/benet/be_main.c             |   28 +++++++=
+++++++-------
 drivers/net/ethernet/freescale/fsl_pq_mdio.c            |   34 +++++++=
+++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_adminq.c           |    4 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c             |    2 ++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c         |    4 +--
 drivers/net/ethernet/mellanox/mlx4/eq.c                 |    4 +++
 drivers/net/ethernet/mellanox/mlx4/main.c               |   10 ++-----=
-
 drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c |   16 +++++++=
+++--
 drivers/net/ethernet/mellanox/mlx5/core/port.c          |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c              |   13 +++++++=
---
 drivers/net/ethernet/mellanox/mlxsw/item.h              |    4 ++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c               |    8 +++---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c          |    2 +-
 drivers/net/ethernet/nxp/lpc_eth.c                      |   13 +++++--=
---
 drivers/net/ethernet/via/via-rhine.c                    |    3 ++-
 drivers/net/geneve.c                                    |   12 ++++---=
--
 drivers/net/phy/Kconfig                                 |    2 --
 drivers/net/ppp/pppoe.c                                 |    1 -
 drivers/net/usb/Kconfig                                 |    1 +
 drivers/net/usb/asix_common.c                           |    4 ++-
 drivers/net/usb/asix_devices.c                          |    4 +++
 drivers/net/vxlan.c                                     |    7 +++---
 drivers/net/wireless/ath/ath10k/hw.h                    |    4 +--
 drivers/net/wireless/ath/ath9k/init.c                   |    1 +
 drivers/net/wireless/b43/main.c                         |    1 +
 drivers/net/wireless/iwlwifi/dvm/lib.c                  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c                 |    2 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c                   |   27 +++++++=
+------------
 drivers/net/wireless/iwlwifi/mvm/fw.c                   |    4 +--
 drivers/net/wireless/iwlwifi/mvm/mac80211.c             |    1 +
 drivers/net/wireless/iwlwifi/mvm/mvm.h                  |    5 ++++
 drivers/net/wireless/iwlwifi/mvm/ops.c                  |    1 +
 drivers/net/wireless/iwlwifi/pcie/drv.c                 |    5 ++++
 drivers/net/wireless/rt2x00/rt2800usb.c                 |    1 +
 drivers/net/wireless/rtlwifi/pci.h                      |    2 ++
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c             |   17 +++++++=
++++++
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c             |    5 ++++
 drivers/net/wireless/rtlwifi/wifi.h                     |    3 +++
 drivers/net/xen-netback/xenbus.c                        |    6 +++++
 include/net/af_unix.h                                   |    2 +-
 include/net/inet_timewait_sock.h                        |    4 +--
 include/net/sock.h                                      |    8 ++++++
 include/uapi/linux/openvswitch.h                        |   36 +++++++=
++++---------------
 include/uapi/linux/rtnetlink.h                          |    2 +-
 net/bluetooth/hci_conn.c                                |   99 +++++++=
++++++++++++++++++++++++++++++++++++++++++++---------------------
 net/bluetooth/hci_core.c                                |    7 ------
 net/bluetooth/hci_event.c                               |   11 +++++--=
-
 net/bluetooth/mgmt.c                                    |   24 +++++++=
++++++++---
 net/core/ethtool.c                                      |    2 +-
 net/core/filter.c                                       |    7 +++++-
 net/dsa/dsa.c                                           |   70 +++++++=
++++++++++++++++++++++++++++++++++++--------
 net/ipv4/arp.c                                          |    8 +++---
 net/ipv4/inet_connection_sock.c                         |   19 +++++++=
-------
 net/ipv6/addrconf.c                                     |    2 ++
 net/ipv6/ip6_output.c                                   |    3 +++
 net/ipv6/route.c                                        |   49 +++++++=
++++++++++-------------------
 net/ipv6/xfrm6_policy.c                                 |    1 +
 net/mac80211/debugfs.c                                  |    2 +-
 net/mac80211/status.c                                   |    1 +
 net/mac80211/tx.c                                       |    7 ++++--
 net/netlink/af_netlink.c                                |   34 +++++++=
+++++++++---------
 net/openvswitch/actions.c                               |   19 +++++++=
+++----
 net/openvswitch/conntrack.c                             |   89 +++++++=
+++++++++++++++++++++++++--------------------------------
 net/openvswitch/conntrack.h                             |   14 +++++++=
+++-
 net/openvswitch/flow.h                                  |    2 +-
 net/openvswitch/flow_netlink.c                          |   30 +++++++=
++++++---------
 net/openvswitch/flow_table.c                            |    3 ++-
 net/openvswitch/vport.c                                 |   51 +++++++=
+++++++++---------------------
 net/sched/act_mirred.c                                  |   18 +++++++=
+++---
 net/sched/sch_hhf.c                                     |   11 +++++++=
-
 net/switchdev/switchdev.c                               |    3 +++
 net/tipc/msg.h                                          |    4 +--
 net/tipc/node.c                                         |    6 ++---
 net/unix/af_unix.c                                      |   12 +++++--=
--
 83 files changed, 668 insertions(+), 345 deletions(-)
