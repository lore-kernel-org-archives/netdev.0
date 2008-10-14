From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 14 Oct 2008 02:18:10 -0700 (PDT)
Message-ID: <20081014.021810.168711446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755301AbYJNJSe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2008 05:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More bug fixes and tidy-ups, highlights:

1) pktgen leaks packets, fix from Ilpo J=E4rvinen

2) Build failure and other fixes from Adrian Bunk

3) s390 build fixes from Alexey Dobriyan and Heiko Carstens

4) Fix of the build of several drivers due to missing
   net/ip6_checksum.h include, from Kamalesh Babulal

5) tulip de2104x MAC address fetching fix from Martin Langer

6) Alan Cox email address update, this is what touches most of
   the files in the diffstat below

Please pull, thanks a lot!

The following changes since commit bf94e17bc8d35fc339945a42990a2f2b5e9b=
5a40:
  Ingo Molnar (1):
        net/mac80211/rx.c: fix build error

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (2):
      mISDN/dsp_cmx.c: fix size checks
      net: export genphy_restart_aneg

Alan Cox (1):
      net: Rationalise email address: Network Specific Parts

Alexey Dobriyan (2):
      s390: claw compile fixlet
      netns: mib6 section fixlet

Andrew Morton (1):
      misdn: use nonseekable_open()

Divy Le Ray (2):
      cxgb3: update driver version
      cxgb3: extend copyrights to 2008

Heiko Carstens (1):
      dsa: fix compile bug on s390

Ilpo J=E4rvinen (1):
      pktgen: fix skb leak in case of failure

Kamalesh Babulal (1):
      net: fix driver build errors due to missing net/ip6_checksum.h in=
clude

Martin Langer (1):
      de2104x: wrong MAC address fix

Randy Dunlap (1):
      net/phy: add missing kernel-doc

Roland Dreier (1):
      enic: Fix Kconfig headline description

Ron Mercer (1):
      qlge: Fix page size ifdef test.

 drivers/isdn/mISDN/dsp_cmx.c         |    4 ++--
 drivers/isdn/mISDN/timerdev.c        |    2 +-
 drivers/net/3c501.c                  |   12 ++++++------
 drivers/net/3c515.c                  |    2 +-
 drivers/net/Kconfig                  |    2 +-
 drivers/net/appletalk/cops.c         |    2 +-
 drivers/net/cxgb3/adapter.h          |    2 +-
 drivers/net/cxgb3/ael1002.c          |    2 +-
 drivers/net/cxgb3/common.h           |    2 +-
 drivers/net/cxgb3/cxgb3_ctl_defs.h   |    2 +-
 drivers/net/cxgb3/cxgb3_defs.h       |    2 +-
 drivers/net/cxgb3/cxgb3_ioctl.h      |    2 +-
 drivers/net/cxgb3/cxgb3_main.c       |    2 +-
 drivers/net/cxgb3/cxgb3_offload.c    |    2 +-
 drivers/net/cxgb3/cxgb3_offload.h    |    2 +-
 drivers/net/cxgb3/firmware_exports.h |    2 +-
 drivers/net/cxgb3/l2t.c              |    2 +-
 drivers/net/cxgb3/l2t.h              |    2 +-
 drivers/net/cxgb3/mc5.c              |    2 +-
 drivers/net/cxgb3/sge.c              |    2 +-
 drivers/net/cxgb3/t3_cpl.h           |    2 +-
 drivers/net/cxgb3/t3_hw.c            |    2 +-
 drivers/net/cxgb3/t3cdev.h           |    2 +-
 drivers/net/cxgb3/version.h          |    4 ++--
 drivers/net/cxgb3/vsc8211.c          |    2 +-
 drivers/net/cxgb3/xgmac.c            |    2 +-
 drivers/net/eexpress.c               |    2 +-
 drivers/net/enic/enic_main.c         |    1 +
 drivers/net/ibmlana.c                |    2 +-
 drivers/net/jme.c                    |    1 +
 drivers/net/macmace.c                |    2 +-
 drivers/net/pcmcia/3c589_cs.c        |    2 +-
 drivers/net/pcmcia/nmclan_cs.c       |    2 +-
 drivers/net/phy/mdio_bus.c           |    1 +
 drivers/net/phy/phy_device.c         |    1 +
 drivers/net/qlge/qlge.h              |    2 +-
 drivers/net/qlge/qlge_main.c         |    1 +
 drivers/net/tlan.c                   |    3 ++-
 drivers/net/tokenring/smctr.c        |    2 +-
 drivers/net/tulip/de2104x.c          |    1 +
 drivers/net/tulip/dmfe.c             |    4 ++--
 drivers/net/via-velocity.c           |    2 +-
 drivers/net/wan/z85230.c             |    3 ++-
 drivers/net/wan/z85230.h             |    2 +-
 drivers/net/wireless/wavelan.c       |    2 +-
 drivers/net/wireless/wavelan.p.h     |    2 +-
 drivers/s390/net/claw.c              |    2 +-
 include/linux/if_ether.h             |    2 +-
 include/linux/if_fddi.h              |    2 +-
 include/linux/if_hippi.h             |    2 +-
 include/linux/igmp.h                 |    2 +-
 include/linux/netdevice.h            |    2 +-
 net/802/psnap.c                      |    2 +-
 net/appletalk/ddp.c                  |    4 ++--
 net/core/datagram.c                  |    2 +-
 net/core/dev_mcast.c                 |    2 +-
 net/core/pktgen.c                    |    8 +++++---
 net/core/skbuff.c                    |    2 +-
 net/core/stream.c                    |    2 +-
 net/dsa/Kconfig                      |    2 +-
 net/ipv4/icmp.c                      |    2 +-
 net/ipv4/igmp.c                      |    2 +-
 net/ipv4/ip_fragment.c               |    2 +-
 net/ipv4/ip_input.c                  |    2 +-
 net/ipv4/ipip.c                      |    2 +-
 net/ipv4/ipmr.c                      |    2 +-
 net/ipv4/udp.c                       |    2 +-
 net/ipv6/af_inet6.c                  |    2 +-
 net/netlink/af_netlink.c             |    2 +-
 net/sunrpc/xprtsock.c                |    4 ++--
 net/unix/af_unix.c                   |    2 +-
 71 files changed, 87 insertions(+), 77 deletions(-)
