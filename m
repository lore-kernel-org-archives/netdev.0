From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 04 Jun 2008 17:01:23 -0700 (PDT)
Message-ID: <20080604.170123.234927220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756230AbYFEABY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 20:01:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A lot of little things in here, a large chunk of it is
backlog that accumulated while I've been (still) travelling.
I should be done changing timezones every other day next
week.

Highlights:

1) Wired driver fixes from Jeff Garzik and co.

2) Wireless driver fixes from John Linville and co.

3) IPV6 bug fixes from HIDEAKI Yoshifuji et al.

4) IPSEC algorithm string name fix from Adrian-Ken Rueegsegger

5) Bluetooth rfcomm deadlock fix from Dave Young

6) Netfilter bug fixes via Patrick McHardy.

7) SCTP bug fixes from Gui Jianfeng and Vlad Yasevich

8) Two TCP state handling fixes from Ilpo.  There is a third
   on the way which Ingo is testing which should fix the
   distcc loopback socket hangs he reported.

9) AX25 NULL deref fix from Jarek Poplawski

10) TCP splice race fix from Octavian Purdila and Evgeniy Polyakov.

11) IRDA socket leak fix from Pavel Emelyanov

Please pull, thanks a lot!

The following changes since commit c3b25b32e8bef526cca748e1ba023c6bdd70=
5a99:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../herbert/crypto-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Adrian Bunk (1):
      bridge: update URL

Adrian-Ken Rueegsegger (1):
      xfrm: xfrm_algo: correct usage of RIPEMD-160

Alexey Dobriyan (1):
      atl1: fix 4G memory corruption bug

Andrew Morton (1):
      airo warning fix

Ben Hutchings (1):
      [netdrvr] sfc: Report XAUI link down at default log level

Brice Goglin (2):
      myri10ge: update driver version
      net_dma: remove duplicate assignment in dma_skb_copy_datagram_iov=
ec

Cesar Eduardo Barros (1):
      sc92031: remove bogus unlikely()

Colin (1):
      [IPV6] TUNNEL6: Fix incoming packet length check for inter-protoc=
ol tunnel.

Dan Williams (1):
      ipw2200: expire and use oldest BSS on adhoc create

Dave Young (1):
      bluetooth: rfcomm_dev_state_change deadlock fix

David S. Miller (3):
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netd=
ev-2.6
      Merge branch 'net-2.6-misc-20080605a' of git://git.linux-ipv6.org=
/gitroot/yoshfuji/linux-2.6-fix
      Merge branch 'master' of master.kernel.org:/.../linville/wireless=
-2.6

Denis V. Lunev (4):
      [IPV6]: Do not change protocol for raw IPv6 sockets.
      [IPV6]: inet_sk(sk)->cork.opt leak
      [IPV6]: Do not change protocol for UDPv6 sockets with pending sen=
t data.
      raw: Raw socket leak.

Dong Wei (1):
      netfilter: xt_connlimit: fix accouning when receive RST packet in=
 ESTABLISHED state

=46elix Homann (1):
      USB ID for Philips CPWUA054/00 Wireless USB Adapter 11g

Grant Grundler (1):
      [netdrvr] tulip: oops in tulip_interrupt when hibernating with sw=
susp/suspend2

Gui Jianfeng (2):
      sctp: retran_path update bug fix
      sctp: Move sctp_v4_dst_saddr out of loop

Holger Schurig (1):
      libertas: fix command size for CMD_802_11_SUBSCRIBE_EVENT

Ilpo J=C3=A4rvinen (2):
      tcp: Fix inconsistency source (CA_Open only when !tcp_left_out(tp=
))
      tcp: fix skb vs fack_count out-of-sync condition

James Chapman (2):
      lt2p: Fix possible WARN_ON from socket code when UDP socket is cl=
osed
      l2tp: Fix possible oops if transmitting or receiving when tunnel =
goes down

Jarek Poplawski (2):
      ax25: Fix NULL pointer dereference and lockup.
      netfilter: nf_conntrack_ipv6: fix inconsistent lock state in nf_c=
t_frag6_gather()

Joakim Tjernlund (1):
      ucc_geth_ethtool: Fix typo

Li Yang (1):
      ucc_geth_ethtool: Add a missing HW stats counter

Mark Asselstine (1):
      sunhme: Cleanup use of deprecated calls to save_and_cli and resto=
re_flags.

Michael Buesch (2):
      b43legacy: Fix controller restart crash
      ssb: Fix context assertion in ssb_pcicore_dev_irqvecs_enable

Octavian Purdila (1):
      tcp: Fix for race due to temporary drop of the socket lock in skb=
_splice_bits.

Pavel Emelyanov (1):
      irda: Sock leak on error path in irda_create.

Rusty Russell (2):
      virtio: fix virtio_net xmit of freed skb bug
      virtio: fix delayed xmit of packet and freeing of old packets.

Sridhar Samudrala (1):
      tcp: Increment OUTRSTS in tcp_send_active_reset()

Stephen Hemminger (1):
      net: neighbour table ABI problem

Thomas Graf (5):
      route: Mark unused route cache flags as such.
      route: Mark unused routing attributes as such
      netlink: Improve returned error codes
      route: Remove unused ifa_anycast field
      [IPV6] ADDRCONF: Check range of prefix length

Vlad Yasevich (4):
      sctp: Correctly implement Fast Recovery cwnd manipulations.
      sctp: Start T3-RTX timer when fast retransmitting lowest TSN
      sctp: Flush the queue only once during fast retransmit.
      sctp: Fix ECN markings for IPv6

Wang Chen (1):
      [netdrvr] CS89X0: Add cleanup for dma after fail

YOSHIFUJI Hideaki (6):
      [SCTP]: Fix NULL dereference of asoc.
      [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
      [IPV4] TUNNEL4: Fix incoming packet length check for inter-protoc=
ol tunnel.
      [IPV6] ADDRCONF: Allow longer lifetime on 64bit archs.
      [IPV6]: Check outgoing interface even if source address is unspec=
ified.
      [IPV6] NETNS: Handle ancillary data in appropriate namespace.

Yang Hongyang (2):
      [IPV6]: Fix the return value of get destination options with NULL=
 data pointer
      [IPV6]: Fix the data length of get destination options with short=
 length

 Documentation/networking/bridge.txt     |    2 +-
 MAINTAINERS                             |    2 +-
 drivers/net/atlx/atl1.c                 |    1 +
 drivers/net/cs89x0.c                    |   10 ++-
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/pppol2tp.c                  |  111 ++++++++++++++++++++++-=
-----
 drivers/net/sc92031.c                   |    2 +-
 drivers/net/sfc/falcon_xmac.c           |    2 +-
 drivers/net/sunhme.c                    |    4 +-
 drivers/net/tulip/tulip_core.c          |   10 ++-
 drivers/net/ucc_geth_ethtool.c          |    3 +-
 drivers/net/virtio_net.c                |   36 ++++++++--
 drivers/net/wireless/airo.c             |    2 +-
 drivers/net/wireless/b43legacy/main.c   |   17 +++--
 drivers/net/wireless/ipw2200.c          |   27 +++++++-
 drivers/net/wireless/libertas/debugfs.c |    4 +-
 drivers/net/wireless/p54/p54usb.c       |    1 +
 drivers/ssb/driver_pcicore.c            |    4 +-
 include/linux/in_route.h                |   12 ++--
 include/linux/inetdevice.h              |    1 -
 include/linux/rtnetlink.h               |    4 +-
 include/net/addrconf.h                  |   22 ++++++
 include/net/genetlink.h                 |    4 +-
 include/net/netlink.h                   |   20 +++---
 include/net/sctp/structs.h              |   17 ++++-
 include/net/transp_v6.h                 |    3 +-
 include/net/udp.h                       |    1 +
 net/ax25/ax25_subr.c                    |   11 +--
 net/bluetooth/rfcomm/tty.c              |   13 +++-
 net/core/neighbour.c                    |    9 ++-
 net/core/rtnetlink.c                    |    3 +-
 net/core/skbuff.c                       |    5 +-
 net/core/user_dma.c                     |    2 +-
 net/ipv4/devinet.c                      |    9 ---
 net/ipv4/fib_frontend.c                 |    1 -
 net/ipv4/raw.c                          |    9 +++
 net/ipv4/route.c                        |    2 +-
 net/ipv4/tcp.c                          |    9 ++-
 net/ipv4/tcp_input.c                    |   35 ++++++----
 net/ipv4/tcp_output.c                   |    2 +
 net/ipv4/tunnel4.c                      |    2 +-
 net/ipv4/udp.c                          |    3 +-
 net/ipv6/addrconf.c                     |  107 +++++++++++++++--------=
-----
 net/ipv6/datagram.c                     |   45 ++++++------
 net/ipv6/ip6_flowlabel.c                |    2 +-
 net/ipv6/ipv6_sockglue.c                |   21 ++++--
 net/ipv6/netfilter/nf_conntrack_reasm.c |    8 ++-
 net/ipv6/raw.c                          |   11 +++-
 net/ipv6/route.c                        |   12 +---
 net/ipv6/tunnel6.c                      |    2 +-
 net/ipv6/udp.c                          |    8 ++-
 net/irda/af_irda.c                      |   12 ++--
 net/netfilter/xt_connlimit.c            |    3 +-
 net/netlink/attr.c                      |   12 ++--
 net/netlink/genetlink.c                 |    6 +-
 net/sched/sch_dsmark.c                  |    6 +-
 net/sched/sch_gred.c                    |    3 +-
 net/sched/sch_hfsc.c                    |    2 +-
 net/sched/sch_red.c                     |    3 +-
 net/sctp/associola.c                    |   21 +++---
 net/sctp/ipv6.c                         |   11 +++-
 net/sctp/output.c                       |    2 +-
 net/sctp/outqueue.c                     |  120 ++++++++++++++++++++---=
--------
 net/sctp/protocol.c                     |   11 +++-
 net/sctp/transport.c                    |   50 +++++++++----
 net/wireless/nl80211.c                  |   12 ++-
 net/xfrm/xfrm_algo.c                    |    4 +-
 67 files changed, 618 insertions(+), 315 deletions(-)
