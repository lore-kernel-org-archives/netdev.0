From: Antonio Quartulli <a@unstable.cc>
Subject: pull request: batman-adv 20160203
Date: Wed,  3 Feb 2016 10:18:21 +0800
Message-ID: <1454465917-13332-1-git-send-email-a__31393.0814656944$1454467349$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:17733 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932232AbcBCCmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:42:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Here you have our first pull request intended for net-next.

This batch of patches includes a number of corrections and
improvements for our kernel-doc. These changes also make sure
that our doc is now properly processed by the kernel-doc
parsing tool.

Other than that you have a patch updating all the copyright
lines to 2016 and another patch switching the URLs in our
readme, Kconfig and MAINTAINERS file from "http" to "https".
Both by Sven Eckelmann.


Please pull or let me know of any problem!
Thanks a lot,
	Antonio



P.S. as you requested I wrote the message above also in the
git tag so that you get it when pulling from our tree.



this is our first pull request intended for net-next.

The following changes since commit b45efa30a626e915192a6c548cd8642379cd47cc:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-02-01 18:44:07 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 7b5e73961915438d623cb80eea97868b3a66cc48:

  batman-adv: Switch to HTTPS version of links (2016-02-03 09:54:39 +0800)

----------------------------------------------------------------
This batch of patches includes a number of corrections and
improvements for our kernel-doc. These changes also make sure
that our doc is now properly processed by the kernel-doc
parsing tool.

Other than that you have a patch updating all the copyright
lines to 2016 and another patch switching the URLs in our
readme, Kconfig and MAINTAINERS file from "http" to "https".
Both by Sven Eckelmann.

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: fix kerneldoc for DAT functions
      batman-adv: fix kerneldoc for TT functions
      batman-adv: add kernel doc for AP isolation attributes in bat_priv

Marek Lindner (1):
      batman-adv: kernel doc readability updates

Simon Wunderlich (2):
      batman-adv: Update/repair bridge loop avoidance kerneldoc
      batman-adv: add kerneldoc for batadv_iv_ogm_aggr_packet

Sven Eckelmann (10):
      batman-adv: Fix kerneldoc parsing of structs/enums
      batman-adv: Remove kerneldoc for missing parameters
      batman-adv: Fix names in kerneldoc of functions
      batman-adv: Drop invalid kerneldoc for variable batadv_vlan_attrs
      batman-adv: Fix kerneldoc parsing of return description
      batman-adv: Fix kerneldoc of main functions
      batman-adv: Fix kerneldoc of network-coding functions
      batman-adv: Fix kernel-doc for batadv_claim_free_ref
      batman-adv: update copyright years for 2016
      batman-adv: Switch to HTTPS version of links

 Documentation/networking/batman-adv.txt |   2 +-
 MAINTAINERS                             |   2 +-
 net/batman-adv/Kconfig                  |   2 +-
 net/batman-adv/Makefile                 |   2 +-
 net/batman-adv/bat_algo.h               |   2 +-
 net/batman-adv/bat_iv_ogm.c             |  29 ++--
 net/batman-adv/bitarray.c               |  14 +-
 net/batman-adv/bitarray.h               |  14 +-
 net/batman-adv/bridge_loop_avoidance.c  | 231 +++++++++++++++++++++++---------
 net/batman-adv/bridge_loop_avoidance.h  |   2 +-
 net/batman-adv/debugfs.c                |   8 +-
 net/batman-adv/debugfs.h                |   2 +-
 net/batman-adv/distributed-arp-table.c  |  43 +++---
 net/batman-adv/distributed-arp-table.h  |   2 +-
 net/batman-adv/fragmentation.c          |  20 +--
 net/batman-adv/fragmentation.h          |   4 +-
 net/batman-adv/gateway_client.c         |  16 +--
 net/batman-adv/gateway_client.h         |   2 +-
 net/batman-adv/gateway_common.c         |   4 +-
 net/batman-adv/gateway_common.h         |   2 +-
 net/batman-adv/hard-interface.c         |   9 +-
 net/batman-adv/hard-interface.h         |   2 +-
 net/batman-adv/hash.c                   |   2 +-
 net/batman-adv/hash.h                   |  24 ++--
 net/batman-adv/icmp_socket.c            |   2 +-
 net/batman-adv/icmp_socket.h            |   2 +-
 net/batman-adv/main.c                   |  30 +++--
 net/batman-adv/main.h                   |  19 ++-
 net/batman-adv/multicast.c              |  37 +++--
 net/batman-adv/multicast.h              |   4 +-
 net/batman-adv/network-coding.c         |  57 +++++---
 net/batman-adv/network-coding.h         |   2 +-
 net/batman-adv/originator.c             |  56 ++++----
 net/batman-adv/originator.h             |   2 +-
 net/batman-adv/packet.h                 |  19 ++-
 net/batman-adv/routing.c                |  38 +++---
 net/batman-adv/routing.h                |   2 +-
 net/batman-adv/send.c                   |  31 +++--
 net/batman-adv/send.h                   |   6 +-
 net/batman-adv/soft-interface.c         |  20 +--
 net/batman-adv/soft-interface.h         |   2 +-
 net/batman-adv/sysfs.c                  |  17 ++-
 net/batman-adv/sysfs.h                  |   2 +-
 net/batman-adv/translation-table.c      | 119 +++++++++-------
 net/batman-adv/translation-table.h      |   2 +-
 net/batman-adv/types.h                  |  30 +++--
 46 files changed, 584 insertions(+), 355 deletions(-)
