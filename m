From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 17 Dec 2016 21:55:27 -0500 (EST)
Message-ID: <20161217.215527.1091437858488390835.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Revert bogus nla_ok() change, from Alexey Dobriyan.

2) Various bpf validator fixes from Daniel Borkmann.

3) Add some necessary SET_NETDEV_DEV() calls to hsis_femac and hip04
   drivers, from Dongpo Li.

4) Several ethtool ksettings conversions from Philippe Reynes.

5) Fix bugs in inet port management wrt. soreuseport, from Tom
   Herbert.

6) XDP support for virtio_net, from John Fastabend.

7) Fix NAT handling within a vrf, from David Ahern.

8) Endianness fixes in dpaa_eth driver, from Claudiu Manoil.

Please pull, thanks a lot!

The following changes since commit 8fa3b6f9392bf6d90cb7b908e07bd90166639f0a:

  Merge tag 'cris-for-4.10' of git://git.kernel.org/pub/scm/linux/kernel/git/jesper/cris (2016-12-12 09:06:38 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 3e3397e7b11ce1b9526975ddfbe8dd569fc1f316:

  net: mv643xx_eth: fix build failure (2016-12-17 21:47:26 -0500)

----------------------------------------------------------------
Alexey Dobriyan (1):
      netlink: revert broken, broken "2-clause nla_ok()"

Andrew Lunn (1):
      net: dsa: mv88e6xxx: Fix opps when adding vlan bridge

Andy Lutomirski (1):
      cgroup: Fix CGROUP_BPF config

Arnd Bergmann (1):
      qed: fix old-style function definition

Bartosz Folta (1):
      net: macb: Added PCI wrapper for Platform Driver.

Ben Greear (1):
      mac80211: fix legacy and invalid rx-rate report

Cedric Izoard (1):
      mac80211: Ensure enough headroom when forwarding mesh pkt

Claudiu Manoil (1):
      dpaa_eth: use big endian accessors

Dan Carpenter (1):
      irda: w83977af_ir: cleanup an indent issue

Daniel Borkmann (5):
      bpf: fix regression on verifier pruning wrt map lookups
      bpf, test_verifier: fix a test case error result on unprivileged
      bpf: dynamically allocate digest scratch buffer
      bpf: fix overflow in prog accounting
      bpf: fix mark_reg_unknown_value for spilled regs on map value marking

Daniel Mack (1):
      bpf: cgroup: annotate pointers in struct cgroup_bpf with __rcu

David Ahern (2):
      net: vrf: Fix NAT within a VRF
      net: vrf: Drop conntrack data after pass through VRF device on Tx

David S. Miller (8):
      Merge branch 'hisilicon-netdev-dev'
      Merge branch 'cls_flower-mask'
      Merge branch 'inet_csk_get_port-and-soreusport-fixes'
      Merge branch 'dpaa_eth-fixes'
      Merge branch 'virtio_net-XDP'
      Merge branch 'gtp-fixes'
      Merge branch 'bpf-fixes'
      Merge tag 'mac80211-for-davem-2016-12-16' of git://git.kernel.org/.../jberg/mac80211

Dongpo Li (2):
      net: ethernet: hisi_femac: Call SET_NETDEV_DEV()
      net: ethernet: hip04: Call SET_NETDEV_DEV()

Emese Revfy (1):
      isdn: Constify some function parameters

Harald Welte (1):
      gtp: Fix initialization of Flags octet in GTPv1 header

Ido Schimmel (1):
      mlxsw: spectrum: Mark split ports as such

Jason Wang (1):
      virtio-net: correctly enable multiqueue

Jeroen De Wachter (2):
      encx24j600: bugfix - always move ERXTAIL to next packet in encx24j600_rx_packets
      encx24j600: Fix some checkstyle warnings

Johannes Berg (1):
      mac80211: don't call drv_set_default_unicast_key() for VLANs

John Fastabend (5):
      net: xdp: add invalid buffer warning
      virtio_net: Add XDP support
      virtio_net: add dedicated XDP transmit queues
      virtio_net: add XDP_TX support
      virtio_net: xdp, add slowpath case for non contiguous buffers

Kees Cook (7):
      isdn/gigaset: use designated initializers
      ATM: use designated initializers
      net: use designated initializers
      WAN: use designated initializers
      bna: use designated initializers
      isdn: use designated initializers
      net/x25: use designated initializers

LABBE Corentin (5):
      irda: irproc.c: Remove unneeded linux/miscdevice.h include
      irda: irnet: Move linux/miscdevice.h include
      irnet: ppp: move IRNET_MINOR to include/linux/miscdevice.h
      irda: irnet: Remove unused IRNET_MAJOR define
      irda: irnet: add member name to the miscdevice declaration

Lionel Gauthier (1):
      gtp: gtp_check_src_ms_ipv4() always return success

Madalin Bucur (2):
      dpaa_eth: remove redundant dependency on FSL_SOC
      MAINTAINERS: net: add entry for Freescale QorIQ DPAA Ethernet driver

Mantas M (1):
      net: ipv6: check route protocol when deleting routes

Manuel Bessler (1):
      r6040: move spinlock in r6040_close as SOFTIRQ-unsafe lock order detected

Paul Blakey (2):
      net/sched: cls_flower: Use mask for addr_type
      net/sched: cls_flower: Use masked key when calling HW offloads

Philippe Reynes (5):
      net: chelsio: cxgb2: use new api ethtool_{get|set}_link_ksettings
      net: chelsio: cxgb3: use new api ethtool_{get|set}_link_ksettings
      net: cirrus: ep93xx: use new api ethtool_{get|set}_link_ksettings
      net: davicom: dm9000: use new api ethtool_{get|set}_link_ksettings
      net: sfc: use new api ethtool_{get|set}_link_ksettings

Sudip Mukherjee (1):
      net: mv643xx_eth: fix build failure

Thomas Falcon (1):
      ibmveth: calculate gso_segs for large packets

Thomas Gleixner (1):
      net/3com/3c515: Fix timer handling, prevent leaks and crashes

Timur Tabi (1):
      net: qcom/emac: don't try to claim clocks on ACPI systems

Tom Herbert (2):
      inet: Don't go into port scan when looking for specific bind port
      inet: Fix get port to handle zero port number with soreuseport set

Xin Long (2):
      sctp: sctp_epaddr_lookup_transport should be protected by rcu_read_lock
      sctp: sctp_transport_lookup_process should rcu_read_unlock when transport is null

 MAINTAINERS                                        |   6 ++
 drivers/isdn/gigaset/bas-gigaset.c                 |  32 +++---
 drivers/isdn/gigaset/ser-gigaset.c                 |  32 +++---
 drivers/isdn/gigaset/usb-gigaset.c                 |  32 +++---
 drivers/isdn/hisax/config.c                        |  16 +--
 drivers/isdn/hisax/hisax.h                         |   4 +-
 drivers/isdn/i4l/isdn_concap.c                     |   6 +-
 drivers/isdn/i4l/isdn_x25iface.c                   |  16 +--
 drivers/net/dsa/mv88e6xxx/chip.c                   |   6 ++
 drivers/net/ethernet/3com/3c515.c                  |  15 +--
 drivers/net/ethernet/brocade/bna/bna_enet.c        |   8 +-
 drivers/net/ethernet/cadence/Kconfig               |   9 ++
 drivers/net/ethernet/cadence/Makefile              |   1 +
 drivers/net/ethernet/cadence/macb.c                |  31 +++++-
 drivers/net/ethernet/cadence/macb_pci.c            | 153 ++++++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |  64 +++++++-----
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |  65 ++++++------
 drivers/net/ethernet/cirrus/ep93xx_eth.c           |  14 +--
 drivers/net/ethernet/davicom/dm9000.c              |  14 +--
 drivers/net/ethernet/freescale/dpaa/Kconfig        |   2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  71 ++++++-------
 drivers/net/ethernet/hisilicon/hip04_eth.c         |   2 +-
 drivers/net/ethernet/hisilicon/hisi_femac.c        |   2 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |  12 ++-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +-
 drivers/net/ethernet/microchip/encx24j600-regmap.c |  17 ++--
 drivers/net/ethernet/microchip/encx24j600.c        |  19 +++-
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c        |   2 +-
 drivers/net/ethernet/qualcomm/emac/emac.c          |   9 ++
 drivers/net/ethernet/rdc/r6040.c                   |  10 +-
 drivers/net/ethernet/sfc/ethtool.c                 |  35 ++++---
 drivers/net/ethernet/sfc/mcdi_port.c               |  60 ++++++-----
 drivers/net/ethernet/sfc/net_driver.h              |  12 +--
 drivers/net/gtp.c                                  |   8 +-
 drivers/net/irda/w83977af_ir.c                     |   6 +-
 drivers/net/virtio_net.c                           | 369 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/vrf.c                                  |   6 +-
 drivers/net/wan/lmc/lmc_media.c                    |  97 +++++++++---------
 include/linux/bpf-cgroup.h                         |   2 +-
 include/linux/bpf.h                                |  13 ++-
 include/linux/filter.h                             |  15 ++-
 include/linux/miscdevice.h                         |   1 +
 include/linux/platform_data/macb.h                 |   6 ++
 include/net/inet6_connection_sock.h                |   3 +-
 include/net/inet_connection_sock.h                 |   6 +-
 include/net/netlink.h                              |   3 +-
 init/Kconfig                                       |   3 +-
 kernel/bpf/core.c                                  |  43 +++++---
 kernel/bpf/syscall.c                               |  38 +++++--
 kernel/bpf/verifier.c                              |  28 ++++--
 net/atm/lec.c                                      |   6 +-
 net/atm/mpoa_caches.c                              |  43 ++++----
 net/core/filter.c                                  |   6 ++
 net/decnet/dn_dev.c                                |   2 +-
 net/ipv4/inet_connection_sock.c                    |  16 +--
 net/ipv6/inet6_connection_sock.c                   |   7 +-
 net/ipv6/route.c                                   |   2 +
 net/irda/irnet/irnet.h                             |   1 -
 net/irda/irnet/irnet_ppp.h                         |  11 +-
 net/irda/irproc.c                                  |   1 -
 net/mac80211/key.c                                 |   3 +-
 net/mac80211/rx.c                                  |   2 +-
 net/mac80211/sta_info.c                            |  14 +--
 net/sched/cls_flower.c                             |   6 +-
 net/sctp/endpointola.c                             |   5 +-
 net/sctp/socket.c                                  |   7 +-
 net/vmw_vsock/vmci_transport_notify.c              |  30 +++---
 net/vmw_vsock/vmci_transport_notify_qstate.c       |  30 +++---
 net/x25/sysctl_net_x25.c                           |   2 +-
 tools/testing/selftests/bpf/test_verifier.c        |  30 +++++-
 71 files changed, 1206 insertions(+), 446 deletions(-)
 create mode 100644 drivers/net/ethernet/cadence/macb_pci.c
