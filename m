From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2015-05-29
Date: Fri, 29 May 2015 11:05:12 +0200
Message-ID: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:44263 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098AbbE2Jci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:32:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

after quite some time of silence (mostly due to me being rather busy and not
because we did not have any active development) here you have my first batch
intended for net-next/linux-4.1.

In this patchset you have quite some code cleanup and style fixes. A big chunk
of the cleanup work has been performed by Markus Pargmann, followed by a couple
of checkpatch fixes brought by Marek Lindner.

Then we have a patch by Sven Eckelmann that disables some of the features we had
enabled by default, because not all the users having them enabled at compile
time are aware of those.
For example distributions like debian enables any compile-time option
without asking the user, thus having him using all these features without his
explicit consent with potentially unexpected behaviours. Therefore the decision
to disable by default not-so-user-safe options.


This is all for now.

Please pull or let me know of any problem!


Thanks a lot!


The following changes since commit a74eab639ec502eb744528ef7c271576d670aa7a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next (2015-05-28 20:23:01 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 8ea64e27080eb66dc26f64f28485c0bc9fc06b36:

  batman-adv: Use common declaration order in *_send_skb_(packet|unicast) (2015-05-29 10:13:37 +0200)

----------------------------------------------------------------
Included changes:
- checkpatch fixes
- code cleanup
- debugfs component is now compiled only if DEBUG_FS is selected
- update copyright years
- disable by default not-so-user-safe features

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: Use common declaration order in *_send_skb_(packet|unicast)

Marek Lindner (2):
      batman-adv: checkpatch - comparison to NULL could be rewritten
      batman-adv: checkpatch - spaces preferred around that '*'

Markus Pargmann (8):
      batman-adv: debugfs, avoid compiling for !DEBUG_FS
      batman-adv: tvlv realloc, move error handling into if block
      batman-adv: Makefile, Sort alphabetically
      batman-adv: iv_ogm_iface_enable, direct return values
      batman-adv: iv_ogm_aggr_packet, bool return value
      batman-adv: iv_ogm_send_to_if, declare char* as const
      batman-adv: iv_ogm_can_aggregate, code readability
      batman-adv: iv_ogm_orig_update, remove unnecessary brackets

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (4):
      batman-adv: update copyright years for 2015
      batman-adv: Check total_size when queueing fragments
      batman-adv: Use only queued fragments when merging
      batman-adv: Use safer default config for optional features

 net/batman-adv/Makefile                |   6 +-
 net/batman-adv/bat_algo.h              |   2 +-
 net/batman-adv/bat_iv_ogm.c            | 120 ++++++++++++++++-----------------
 net/batman-adv/bitarray.c              |   2 +-
 net/batman-adv/bitarray.h              |   2 +-
 net/batman-adv/bridge_loop_avoidance.c |   2 +-
 net/batman-adv/bridge_loop_avoidance.h |   2 +-
 net/batman-adv/debugfs.c               |  10 +--
 net/batman-adv/debugfs.h               |  36 +++++++++-
 net/batman-adv/distributed-arp-table.c |   2 +-
 net/batman-adv/distributed-arp-table.h |   2 +-
 net/batman-adv/fragmentation.c         |  22 +++---
 net/batman-adv/fragmentation.h         |   2 +-
 net/batman-adv/gateway_client.c        |   2 +-
 net/batman-adv/gateway_client.h        |   2 +-
 net/batman-adv/gateway_common.c        |   2 +-
 net/batman-adv/gateway_common.h        |   2 +-
 net/batman-adv/hard-interface.c        |   2 +-
 net/batman-adv/hard-interface.h        |   2 +-
 net/batman-adv/hash.c                  |   2 +-
 net/batman-adv/hash.h                  |   2 +-
 net/batman-adv/icmp_socket.c           |   2 +-
 net/batman-adv/icmp_socket.h           |   2 +-
 net/batman-adv/main.c                  |  18 ++---
 net/batman-adv/main.h                  |   6 +-
 net/batman-adv/multicast.c             |   2 +-
 net/batman-adv/multicast.h             |   2 +-
 net/batman-adv/network-coding.c        |   6 +-
 net/batman-adv/network-coding.h        |   2 +-
 net/batman-adv/originator.c            |   2 +-
 net/batman-adv/originator.h            |   2 +-
 net/batman-adv/packet.h                |   2 +-
 net/batman-adv/routing.c               |   2 +-
 net/batman-adv/routing.h               |   2 +-
 net/batman-adv/send.c                  |   4 +-
 net/batman-adv/send.h                  |   2 +-
 net/batman-adv/soft-interface.c        |   6 +-
 net/batman-adv/soft-interface.h        |   2 +-
 net/batman-adv/sysfs.c                 |   2 +-
 net/batman-adv/sysfs.h                 |   2 +-
 net/batman-adv/translation-table.c     |   2 +-
 net/batman-adv/translation-table.h     |   2 +-
 net/batman-adv/types.h                 |   4 +-
 43 files changed, 165 insertions(+), 137 deletions(-)
