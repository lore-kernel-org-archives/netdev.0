From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 0/7] pull request for net-next: batman-adv 2017-01-25
Date: Wed, 25 Jan 2017 17:42:56 +0100
Message-ID: <20170125164303.14268-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49208 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdAYQnL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:43:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David,

here is a small feature/cleanup pull request of batman-adv to go into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 7ce7d89f48834cefece7804d38fc5d85382edf77:

  Linux 4.10-rc1 (2016-12-25 16:13:08 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170125

for you to fetch changes up to 03d17903cbfdc3bdf6e08c9fb6603936135bba5b:

  batman-adv: Remove unused variable in batadv_tt_local_set_flags (2017-01-04 08:20:21 +0100)

----------------------------------------------------------------
This feature/cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - Handle NET_XMIT_CN like NET_XMIT_SUCCESS, and a follow up code clean up,
   by Gao Feng (2 patches)

 - ignore self-generated loop detect MAC addresses in translation table,
   by Simon Wunderlich

 - install uapi batman_adv.h header, by Sven Eckelmann

 - bump copyright years, by Sven Eckelmann

 - Remove an unused variable in translation table code, by Sven Eckelmann

----------------------------------------------------------------
Gao Feng (2):
      batman-adv: Treat NET_XMIT_CN as transmit successfully
      batman-adv: Remove one condition check in batadv_route_unicast_packet

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
 net/batman-adv/distributed-arp-table.c |  5 +++--
 net/batman-adv/distributed-arp-table.h |  2 +-
 net/batman-adv/fragmentation.c         |  4 ++--
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
 net/batman-adv/routing.c               | 20 +++++++++-----------
 net/batman-adv/routing.h               |  2 +-
 net/batman-adv/send.c                  |  2 +-
 net/batman-adv/send.h                  |  2 +-
 net/batman-adv/soft-interface.c        |  7 ++++---
 net/batman-adv/soft-interface.h        |  2 +-
 net/batman-adv/sysfs.c                 |  2 +-
 net/batman-adv/sysfs.h                 |  2 +-
 net/batman-adv/tp_meter.c              |  4 ++--
 net/batman-adv/tp_meter.h              |  2 +-
 net/batman-adv/translation-table.c     |  4 +---
 net/batman-adv/translation-table.h     |  2 +-
 net/batman-adv/tvlv.c                  |  2 +-
 net/batman-adv/tvlv.h                  |  2 +-
 net/batman-adv/types.h                 |  2 +-
 61 files changed, 95 insertions(+), 78 deletions(-)
