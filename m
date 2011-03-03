From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Thu, 03 Mar 2011 14:34:37 -0800 (PST)
Message-ID: <20110303.143437.193729693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I have one ipv6 regression I'm still working on, but other
than that I think we look reasonably good.

1) skge carrier link state fix from Stephen Hemminger.

2) ipv6 sysctls operate on incorrect namespace sometimes, fix from
   Lucian Adrian Grijincu.

3) Add ID to carl9170 USB driver.

4) __hw_addr_del_multiple() passed wrong type into __hw_addr_del(), fix
   from Hagen Paul Pfeifer.

5) bnx2x fix to parity error blocking, from Vladislav Zolotarov.

6) netlink_dump() errors ignored and not properly propagated.  Fix from
   Andrey Vagin.

7) dnet and macb use platform_set_drvdata() on wrong object type, fixes
   from Jamie Iles and Ilya Yanok.

8) FEC driver platform_device_id table not terminated properly.

9) f_phonet get OOPS with highmem, fix from R=E9mi Denis-Courmont.

10) nla_policy_len() forgets to actually iterate policy pointer in loop=
,
    fix from Lars Ellenberg.

11) Missing checks in RX handling result in warnings from davinci_emac
    driver, fix from Vinay Hegde.

12) IPVS locking fix from Julian Anastasov.

13) DCCP gets oops on reset after close, fix from Gerrit Renker.

14) nf_log oops on bind with invalid nfproto value, fix from Jan
    Engelhardt.

15) Fix e1000e PHY wakeup for ICH10, from Bruce Allan.

16) dcbnl checks wrong OPS for NULL, fix from John Fastabend.

17) CNIC status block race and lost interrupt fix from Michael Chan.

18) RXRPC fixes from David Howells and Anton Blanchard, handle ACKALL
    packets which OpenAFS now emits, and fix regression in rxrpc_key
    layout.

19) Disable ASPM in r8169, causes lots of problems.

20) The usual peppering of small fixes via John Linville and the
    wireless crew.

Please pull, thanks a lot!

The following changes since commit cbdbb4c1d22e26f9d5314fefe6f2c7e5ed7f=
6a0f:

  Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel=
/git/airlied/drm-2.6 (2011-03-02 20:02:32 -0800)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrey Vagin (1):
      netlink: handle errors from netlink_dump()

Anton Blanchard (1):
      RxRPC: Fix v1 keys

Arnaldo Carvalho de Melo (1):
      dccp: Change maintainer

Axel Lin (1):
      net/fec: fix unterminated platform_device_id table

Bruce Allan (1):
      e1000e: disable broken PHY wakeup for ICH10 LOMs, use MAC wakeup =
instead

Christian Lamparter (1):
      p54usb: add Senao NUB-350 usbid

David Howells (1):
      AF_RXRPC: Handle receiving ACKALL packets

David S. Miller (3):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6
      Merge branch 'master' of master.kernel.org:/.../jkirsher/net-2.6

Dmitry Kravkov (5):
      bnx2x: (NPAR mode) Fix FW initialization
      bnx2x: Fix nvram test for single port devices.
      bnx2x: Fix ethtool -t link test for MF (non-pmf) devices.
      bnx2x: properly configure coefficients for MinBW algorithm (NPAR =
mode).
      bnx2x: update driver version to 1.62.00-6

=46ry, Donald H (1):
      iwlagn: Support new 5000 microcode.

Gerrit Renker (1):
      dccp: fix oops on Reset after close

Hagen Paul Pfeifer (1):
      net: handle addr_type of 0 properly

Hegde, Vinay (1):
      davinci_emac: Add Carrier Link OK check in Davinci RX Handler

Ilya Yanok (1):
      dnet: fix wrong use of platform_set_drvdata()

Jamie Iles (1):
      macb: don't use platform_set_drvdata() on a net_device

Jan Engelhardt (1):
      netfilter: nf_log: avoid oops in (un)bind with invalid nfproto va=
lues

Jan Puk (1):
      carl9170: add Airlive X.USB a/b/g/n USBID

Jay Vosburgh (1):
      MAINTAINERS: Add Andy Gospodarek as co-maintainer.

Jeff Kirsher (1):
      igb: fix sparse warning

John Fastabend (1):
      net: dcbnl: check correct ops in dcbnl_ieee_set()

John W. Linville (1):
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/i=
wlwifi-2.6

Julian Anastasov (1):
      ipvs: fix dst_lock locking on dest update

Jussi Kivilinna (1):
      rndis_wlan: use power save only for BCM4320b

Justin Mattock (1):
      drivers:isdn:istream.c Fix typo pice to piece

Ken Kawasaki (1):
      fmvj18x_cs: add new id

Kurt Van Dijck (1):
      CAN: add controller hardware name for Softing cards

Lars Ellenberg (1):
      net: fix nla_policy_len to actually _iterate_ over the policy

Lucian Adrian Grijincu (1):
      sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush

Michael Chan (2):
      cnic: Prevent status block race conditions with hardware
      cnic: Fix lost interrupt on bnx2x

Randy Dunlap (1):
      net: update Documentation/networking/00-INDEX

R=E9mi Denis-Courmont (1):
      f_phonet: avoid pskb_pull(), fix OOPS with CONFIG_HIGHMEM

Stanislaw Gruszka (2):
      ath9k: correct ath9k_hw_set_interrupts
      r8169: disable ASPM

Stephen Hemminger (2):
      skge: don't mark carrier down at start
      e1000: fix sparse warning

Sujith Manoharan (1):
      ath9k_htc: Fix an endian issue

Vladislav Zolotarov (3):
      bnx2x: Add a missing bit for PXP parity register of 57712.
      bnx2x: perform statistics "action" before state transition.
      bnx2x: properly calculate lro_mss

 Documentation/networking/00-INDEX        |    6 ---
 MAINTAINERS                              |    3 +-
 drivers/isdn/hardware/eicon/istream.c    |    2 +-
 drivers/net/bnx2x/bnx2x.h                |   28 +++++++-----
 drivers/net/bnx2x/bnx2x_cmn.c            |   65 ++++++++++++++++++++++=
+------
 drivers/net/bnx2x/bnx2x_cmn.h            |   20 +++++++++
 drivers/net/bnx2x/bnx2x_ethtool.c        |   25 +++++------
 drivers/net/bnx2x/bnx2x_init.h           |    2 +-
 drivers/net/bnx2x/bnx2x_main.c           |   18 ++++++--
 drivers/net/bnx2x/bnx2x_stats.c          |    4 +-
 drivers/net/can/softing/softing_main.c   |    1 +
 drivers/net/cnic.c                       |   33 +++++++++++----
 drivers/net/davinci_emac.c               |    2 +-
 drivers/net/dnet.c                       |    3 +-
 drivers/net/e1000/e1000_osdep.h          |    3 +-
 drivers/net/e1000e/netdev.c              |    3 +-
 drivers/net/fec.c                        |    3 +-
 drivers/net/igbvf/vf.c                   |    2 +-
 drivers/net/macb.c                       |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c          |    1 +
 drivers/net/r8169.c                      |    6 +++
 drivers/net/skge.c                       |    3 -
 drivers/net/wireless/ath/ath9k/hif_usb.c |    9 ++--
 drivers/net/wireless/ath/ath9k/mac.c     |    5 +-
 drivers/net/wireless/ath/carl9170/usb.c  |    2 +
 drivers/net/wireless/iwlwifi/iwl-5000.c  |    2 +-
 drivers/net/wireless/p54/p54usb.c        |    1 +
 drivers/net/wireless/rndis_wlan.c        |    3 +
 drivers/tty/serial/serial_cs.c           |    1 +
 drivers/usb/gadget/f_phonet.c            |   15 +++++--
 include/keys/rxrpc-type.h                |    1 -
 lib/nlattr.c                             |    2 +-
 net/core/dev_addr_lists.c                |    2 +-
 net/dcb/dcbnl.c                          |    2 +-
 net/dccp/input.c                         |    7 +--
 net/ipv6/route.c                         |   17 +++++---
 net/netfilter/ipvs/ip_vs_ctl.c           |    4 +-
 net/netfilter/nf_log.c                   |    4 ++
 net/netlink/af_netlink.c                 |   18 ++++++--
 net/rxrpc/ar-input.c                     |    1 +
 40 files changed, 225 insertions(+), 106 deletions(-)
