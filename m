From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2013-10-09b
Date: Wed,  9 Oct 2013 21:32:38 +0200
Message-ID: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:31676 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab3JITd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:33:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have my fixed pull request intended for net-next.

The previous build error was due to an accidental remotion of the beginning of a
batadv_dbg() statement during a merge conflict resolution.
Sorry for that.


Please pull or let me know of any problem.

Thanks a lot,
	Antonio



The following changes since commit 3d7d562ca4a884089344eb13451b5903a18d3817:

  bnx2x: Add ndo_get_phys_port_id support (2013-10-09 14:55:13 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 18c68d5960c8dfeb2db113f4b871bab259cfd565:

  batman-adv: reorder batadv_iv_flags (2013-10-09 21:22:35 +0200)

----------------------------------------------------------------
Included changes:
- update emails for A. Quartulli and M. Lindner in MAINTAINERS
- switch to the next on-the-wire protocol version
- introduce the T(ype) V(ersion) L(ength) V(alue) framework
- adjust the existing components to make them use the new TVLV code
- make the TT component use CRC32 instead of CRC16
- totally remove the VIS functionality (has been moved to userspace)
- reorder packet types and flags
- add static checks on packet format
- remove __packed from batadv_ogm_packet

----------------------------------------------------------------
Antonio Quartulli (4):
      MAINTAINERS: batman-adv - update emails
      batman-adv: switch to a new packet compatibility version
      batman-adv: use CRC32C instead of CRC16 in TT code
      batman-adv: move BATADV_TT_CLIENT_TEMP to higher bit

Marek Lindner (7):
      batman-adv: tvlv - basic infrastructure
      batman-adv: tvlv - gateway download/upload bandwidth container
      batman-adv: tvlv - add distributed arp table container
      batman-adv: tvlv - add network coding container
      batman-adv: tvlv - convert tt data sent within OGMs
      batman-adv: tvlv - convert tt query packet to use tvlv unicast packets
      batman-adv: tvlv - convert roaming adv packet to use tvlv unicast packets

Simon Wunderlich (5):
      batman-adv: remove vis functionality
      batman-adv: add build check macros for packet member offset
      batman-adv: reorder packet types
      batman-adv: remove packed from batadv_ogm_packet
      batman-adv: reorder batadv_iv_flags

 Documentation/ABI/testing/sysfs-class-net-mesh |  11 -
 Documentation/networking/batman-adv.txt        |  50 +-
 MAINTAINERS                                    |   4 +-
 net/batman-adv/Makefile                        |   1 -
 net/batman-adv/bat_iv_ogm.c                    | 111 +--
 net/batman-adv/debugfs.c                       |   9 -
 net/batman-adv/distributed-arp-table.c         |  64 ++
 net/batman-adv/distributed-arp-table.h         |   5 +
 net/batman-adv/gateway_client.c                | 187 +++--
 net/batman-adv/gateway_client.h                |   2 +-
 net/batman-adv/gateway_common.c                | 230 +++---
 net/batman-adv/gateway_common.h                |  14 +-
 net/batman-adv/hard-interface.c                |   9 -
 net/batman-adv/main.c                          | 623 +++++++++++++++-
 net/batman-adv/main.h                          |  37 +-
 net/batman-adv/network-coding.c                |  63 ++
 net/batman-adv/network-coding.h                |   5 +
 net/batman-adv/originator.c                    |   4 +-
 net/batman-adv/packet.h                        | 248 ++++---
 net/batman-adv/routing.c                       | 247 ++-----
 net/batman-adv/routing.h                       |   6 +-
 net/batman-adv/send.c                          |   1 -
 net/batman-adv/soft-interface.c                |   4 +-
 net/batman-adv/sysfs.c                         |  96 +--
 net/batman-adv/translation-table.c             | 905 ++++++++++++++----------
 net/batman-adv/translation-table.h             |  13 +-
 net/batman-adv/types.h                         | 178 ++---
 net/batman-adv/vis.c                           | 938 -------------------------
 net/batman-adv/vis.h                           |  36 -
 29 files changed, 1968 insertions(+), 2133 deletions(-)
 delete mode 100644 net/batman-adv/vis.c
 delete mode 100644 net/batman-adv/vis.h
