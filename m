From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/7] pull request for net-next: batman-adv
	2017-01-26
Date: Thu, 26 Jan 2017 17:43:57 +0100
Message-ID: <20170126164404.16074-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi David,

this is the updated version of yesterdays feature/cleanup pull request for
batman-adv which should go into net-next. We've followed your suggestion
regarding the NET_XMIT_CN handling and modified Gaos patch accordingly.

The remaining patches are untouched.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 7ce7d89f48834cefece7804d38fc5d85382edf77:

  Linux 4.10-rc1 (2016-12-25 16:13:08 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170126

for you to fetch changes up to c33705188c493b7de3b8dc2956d67de91b444727:

  batman-adv: Treat NET_XMIT_CN as transmit successfully (2017-01-26 08:41:18 +0100)

----------------------------------------------------------------
This feature/cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - ignore self-generated loop detect MAC addresses in translation table,
   by Simon Wunderlich

 - install uapi batman_adv.h header, by Sven Eckelmann

 - bump copyright years, by Sven Eckelmann

 - Remove an unused variable in translation table code, by Sven Eckelmann

 - Handle NET_XMIT_CN like NET_XMIT_SUCCESS (revised according to Davids
   suggestion), and a follow up code clean up, by Gao Feng (2 patches)

----------------------------------------------------------------
Gao Feng (2):
      batman-adv: Remove one condition check in batadv_route_unicast_packet
      batman-adv: Treat NET_XMIT_CN as transmit successfully

Simon Wunderlich (2):
      batman-adv: Start new development cycle
      batman-adv: don't add loop detect macs to TT

Sven Eckelmann (3):
      uapi: install batman_adv.h header
      batman-adv: update copyright years for 2017
      batman-adv: Remove unused variable in batadv_tt_local_set_flags

 include/uapi/linux/Kbuild              |  1 +
 include/uapi/linux/batman_adv.h        |  2 +-
 net/batman-adv/Makefile                |  2 +-
 net/batman-adv/bat_algo.c              |  2 +-
 net/batman-adv/bat_algo.h              |  2 +-
 net/batman-adv/bat_iv_ogm.c            |  2 +-
 net/batman-adv/bat_iv_ogm.h            |  2 +-
 net/batman-adv/bat_v.c                 |  2 +-
 net/batman-adv/bat_v.h                 |  2 +-
 net/batman-adv/bat_v_elp.c             |  2 +-
 net/batman-adv/bat_v_elp.h             |  2 +-
 net/batman-adv/bat_v_ogm.c             |  2 +-
 net/batman-adv/bat_v_ogm.h             |  2 +-
 net/batman-adv/bitarray.c              |  2 +-
 net/batman-adv/bitarray.h              |  2 +-
 net/batman-adv/bridge_loop_avoidance.c |  2 +-
 net/batman-adv/bridge_loop_avoidance.h | 20 +++++++++++++++++++-
 net/batman-adv/debugfs.c               |  2 +-
 net/batman-adv/debugfs.h               |  2 +-
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/distributed-arp-table.h |  2 +-
 net/batman-adv/fragmentation.c         |  2 +-
 net/batman-adv/fragmentation.h         |  2 +-
 net/batman-adv/gateway_client.c        |  2 +-
 net/batman-adv/gateway_client.h        |  2 +-
 net/batman-adv/gateway_common.c        |  2 +-
 net/batman-adv/gateway_common.h        |  2 +-
 net/batman-adv/hard-interface.c        |  2 +-
 net/batman-adv/hard-interface.h        |  2 +-
 net/batman-adv/hash.c                  |  2 +-
 net/batman-adv/hash.h                  |  2 +-
 net/batman-adv/icmp_socket.c           |  2 +-
 net/batman-adv/icmp_socket.h           |  2 +-
 net/batman-adv/log.c                   |  2 +-
 net/batman-adv/log.h                   |  2 +-
 net/batman-adv/main.c                  |  2 +-
 net/batman-adv/main.h                  |  4 ++--
 net/batman-adv/multicast.c             |  2 +-
 net/batman-adv/multicast.h             |  2 +-
 net/batman-adv/netlink.c               |  2 +-
 net/batman-adv/netlink.h               |  2 +-
 net/batman-adv/network-coding.c        |  2 +-
 net/batman-adv/network-coding.h        |  2 +-
 net/batman-adv/originator.c            |  2 +-
 net/batman-adv/originator.h            |  2 +-
 net/batman-adv/packet.h                |  2 +-
 net/batman-adv/routing.c               | 11 +++++------
 net/batman-adv/routing.h               |  2 +-
 net/batman-adv/send.c                  |  4 ++--
 net/batman-adv/send.h                  |  2 +-
 net/batman-adv/soft-interface.c        |  5 +++--
 net/batman-adv/soft-interface.h        |  2 +-
 net/batman-adv/sysfs.c                 |  2 +-
 net/batman-adv/sysfs.h                 |  2 +-
 net/batman-adv/tp_meter.c              |  2 +-
 net/batman-adv/tp_meter.h              |  2 +-
 net/batman-adv/translation-table.c     |  4 +---
 net/batman-adv/translation-table.h     |  2 +-
 net/batman-adv/tvlv.c                  |  2 +-
 net/batman-adv/tvlv.h                  |  2 +-
 net/batman-adv/types.h                 |  2 +-
 61 files changed, 87 insertions(+), 70 deletions(-)
