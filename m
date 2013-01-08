From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 08 Jan 2013 00:10:22 -0800 (PST)
Message-ID: <20130108.001022.21353544093948597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) New sysctl ndisc_notify needs some documentation, from Hanns Frederi=
c
   Sowa.

2) Netfilter REJECT target doesn't set transport header of SKB
   correctly, from Mukund Jampala.

3) Forcedeth driver needs to check for DMA mapping failures, from
   Larry Finger.

4) brcmsmac driver can't use usleep_range while holding locks,
   use udelay instead.  From Niels Ole Salscheider.

5) Fix unregister of netlink bridge multicast database handlers,
   from Vlad Yasevich and Rami Rosen.

6) Fix checksum calculations in netfilter's ipv6 network prefix
   translation module.

7) Fix high order page allocation failures in netfilter xt_recent,
   from Eric Dumazet.

8) mac802154 needs to use netif_rx_ni() instead of netif_rx() because
   mac802154_process_data() can execute in process rather than
   interrupt context.  From Alexander Aring.

9) Fix splice handling of MSG_SENDPAGE_NOTLAST, otherwise we elide
   one tcp_push() too many.  From Eric Dumazet and Willy Tarreau.

10) Fix skb->truesize tracking in XEN netfront driver, from Ian
    Campbell.

Please pull, thanks a lot!

The following changes since commit 101e5c7470eb7f77ae87f966b9155f0dbb5b=
4698:

  Merge tag 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linux/ker=
nel/git/groeck/linux-staging (2012-12-27 10:46:47 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net master

for you to fetch changes up to d9a58a782e396a0f04e8445b7ba3763c8a48c7fe=
:

  xen/netfront: improve truesize tracking (2013-01-07 19:51:19 -0800)

----------------------------------------------------------------
Alexander Aring (1):
      mac802154: fix NOHZ local_softirq_pending 08 warning

Andrew Collins (1):
      netfilter: nf_nat: Also handle non-ESTABLISHED routing changes in=
 MASQUERADE

Arend van Spriel (1):
      brcmsmac: add copyright information for Canonical

Bj=A9=AArn Mork (1):
      net: qmi_wwan: add Telekom Speedstick LTE II

Bob Hockney (1):
      netfilter: nfnetlink_log: fix mac address for 6in4 tunnels

Christian Lamparter (2):
      carl9170: fix -EINVAL bailout during init with !CONFIG_MAC80211_M=
ESH
      p54usb: add USBIDs for two more p54usb devices

David S. Miller (2):
      Merge branch 'master' of git://1984.lsi.us.es/nf
      Merge branch 'master' of git://1984.lsi.us.es/nf

Eric Dumazet (2):
      netfilter: xt_recent: avoid high order page allocations
      tcp: fix MSG_SENDPAGE_NOTLAST logic

=46lorent Fourcot (1):
      netfilter: nf_conntrack_ipv6: fix comment for packets without dat=
a

Geert Uytterhoeven (2):
      bcma: BCMA_DRIVER_GPIO should depend on GPIOLIB instead of select=
ing it
      ssb: SSB_DRIVER_GPIO should depend on GPIOLIB instead of selectin=
g it

Haibo Xi (1):
      netfilter: nf_ct_reasm: fix conntrack reassembly expire code

Hannes Frederic Sowa (1):
      ipv6: document ndisc_notify in networking/ip-sysctl.txt

Hante Meuleman (1):
      brcmfmac: fix parsing rsn ie for ap mode.

Ian Campbell (1):
      xen/netfront: improve truesize tracking

Jesper Juhl (2):
      netfilter: ctnetlink: fix leak in error path of ctnetlink_create_=
expect
      rtlwifi: Don't leak on error in _rtl_usb_receive()

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss into for-davem

Jussi Kivilinna (1):
      rtlwifi: fix incorrect use of usb_alloc_coherent with usb_control=
_msg

Larry Finger (6):
      forcedeth: Fix WARNINGS that result when DMA mapping is not check=
ed
      rtlwifi: Fix warning for unchecked pci_map_single() call
      rtlwifi: rtl8192ce: Fix warning for unchecked pci_map_single() ca=
ll
      rtlwifi: rtl8192de: Fix warning for unchecked pci_map_single() ca=
ll
      rtlwifi: rtl8192se: Fix warning for unchecked pci_map_single() ca=
ll
      rtlwifi: rtl8723ae: Fix warning for unchecked pci_map_single() ca=
ll

Mukund Jampala (1):
      netfilter: ip[6]t_REJECT: fix wrong transport header pointer in T=
CP reset

Niels Ole Salscheider (1):
      brcmsmac: Use udelay instead of usleep_range

Pablo Neira Ayuso (5):
      netfilter: xt_CT: fix crash while destroy ct templates
      netfilter: nfnetlink_log: fix possible compilation issue due to m=
issing include
      netfilter: xt_CT: recover NOTRACK target support
      netfilter: xt_hashlimit: fix race that results in duplicated entr=
ies
      netfilter: fix missing dependencies for the NOTRACK target

Philippe De Muyter (1):
      net/ipv4/ipconfig: really display the BOOTP/DHCP server's address=
=2E

Rafa=A9=A9 Mi=A9=A9ecki (1):
      bcma: correct M25P32 serial flash ID

Rami Rosen (1):
      bridge: add empty br_mdb_init() and br_mdb_uninit() definitions.

Sujith Manoharan (2):
      ath9k: Fix compilation breakage
      ath9k_hw: Fix RX gain initvals for AR9485

Tomasz Guszkowski (1):
      p54usb: add USB ID for T-Com Sinus 154 data II

Ulrich Weber (1):
      netfilter: ip6t_NPT: fix IPv6 NTP checksum calculation

Vitaly E. Lavrov (2):
      netfilter: xt_recent: fix namespace destroy path
      netfilter: xt_hashlimit: fix namespace destroy path

Vlad Yasevich (1):
      bridge: Correctly unregister MDB rtnetlink handlers

Vladimir Kondratiev (1):
      ath9k: Fix Kconfig for ATH9K_HTC

Xi Wang (1):
      ipv4: fix NULL checking in devinet_ioctl()

stephen hemminger (2):
      vxlan: allow live mac address change
      ip-sysctl: fix spelling errors

 Documentation/networking/ip-sysctl.txt                | 16 ++++++++++-=
----
 drivers/bcma/Kconfig                                  |  3 +--
 drivers/bcma/driver_chipcommon_sflash.c               |  2 +-
 drivers/net/ethernet/nvidia/forcedeth.c               | 35 +++++++++++=
+++++++++++++++++++++
 drivers/net/usb/qmi_wwan.c                            |  1 +
 drivers/net/vxlan.c                                   |  1 +
 drivers/net/wireless/ath/ath9k/Kconfig                |  5 +++--
 drivers/net/wireless/ath/ath9k/ar9003_hw.c            |  2 +-
 drivers/net/wireless/ath/carl9170/fw.c                |  6 +++++-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  5 +++--
 drivers/net/wireless/brcm80211/brcmsmac/debug.h       |  1 +
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c |  4 ++--
 drivers/net/wireless/p54/p54usb.c                     |  4 ++++
 drivers/net/wireless/rtlwifi/pci.c                    |  6 ++++++
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c          | 11 ++++++++++
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c          | 10 +++++++++
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c          | 13 +++++++++++=
-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c          | 10 +++++++++
 drivers/net/wireless/rtlwifi/usb.c                    |  8 ++++----
 drivers/net/xen-netfront.c                            | 27 ++++-------=
--------------
 drivers/ssb/Kconfig                                   |  3 +--
 fs/splice.c                                           |  4 +++-
 include/net/netns/conntrack.h                         |  1 +
 include/net/netns/x_tables.h                          |  1 +
 net/bridge/br_multicast.c                             |  2 --
 net/bridge/br_netlink.c                               | 13 +++++++++++=
-
 net/bridge/br_private.h                               |  6 ++++++
 net/ipv4/devinet.c                                    |  2 +-
 net/ipv4/ipconfig.c                                   |  8 ++++++--
 net/ipv4/netfilter/ipt_REJECT.c                       |  1 +
 net/ipv4/netfilter/iptable_nat.c                      | 15 +++++++++--=
---
 net/ipv6/netfilter/ip6t_NPT.c                         | 33 +++++++----=
-------------------
 net/ipv6/netfilter/ip6t_REJECT.c                      |  1 +
 net/ipv6/netfilter/ip6table_nat.c                     | 15 +++++++++--=
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c        |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c               |  5 ++++-
 net/mac802154/wpan.c                                  |  2 +-
 net/netfilter/Kconfig                                 |  7 +++++++
 net/netfilter/nf_conntrack_core.c                     |  2 ++
 net/netfilter/nf_conntrack_netlink.c                  |  2 +-
 net/netfilter/nfnetlink_log.c                         | 16 +++++++++++=
+---
 net/netfilter/xt_CT.c                                 | 58 +++++++++++=
+++++++++++++++++++++++++++++++++++++++++-
 net/netfilter/xt_hashlimit.c                          | 54 +++++++++++=
++++++++++++++++++++++++++++++--------
 net/netfilter/xt_recent.c                             | 43 +++++++++++=
+++++++++++++++++++---------
 44 files changed, 353 insertions(+), 115 deletions(-)
