From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 0/4] pull request for net-next: batman-adv 2017-10-06
Date: Fri,  6 Oct 2017 15:54:33 +0200
Message-ID: <20171006135437.26736-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:38960 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751921AbdJFOAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 10:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here is a small cleanup pull request of batman-adv to go into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 242c1a28eb61cb34974e8aa05235d84355940a8a:

  net: Remove useless function skb_header_release (2017-09-22 20:43:13 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20171006

for you to fetch changes up to 706cc9f51d9a22528af18d4b3ffbd17b30a1d3b0:

  batman-adv: Add argument names for function ptr definitions (2017-09-30 09:31:34 +0200)

----------------------------------------------------------------
This cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - Cleanup patches to make checkpatch happy, by Sven Eckelmann (3 patches)

----------------------------------------------------------------
Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (3):
      batman-adv: Remove unnecessary parentheses
      batman-adv: Fix "line over 80 characters" checkpatch warning
      batman-adv: Add argument names for function ptr definitions

 net/batman-adv/bat_iv_ogm.c            | 24 ++++++++++++------------
 net/batman-adv/bat_v.c                 |  2 +-
 net/batman-adv/bat_v_elp.c             |  6 +++---
 net/batman-adv/bat_v_ogm.c             | 12 ++++++------
 net/batman-adv/distributed-arp-table.c |  4 ++--
 net/batman-adv/gateway_client.c        |  8 ++++----
 net/batman-adv/gateway_common.c        | 18 +++++++++---------
 net/batman-adv/hard-interface.c        | 12 ++++++------
 net/batman-adv/icmp_socket.c           |  4 ++--
 net/batman-adv/main.c                  | 12 ++++++------
 net/batman-adv/main.h                  |  2 +-
 net/batman-adv/multicast.c             |  2 +-
 net/batman-adv/originator.c            | 26 +++++++++++++-------------
 net/batman-adv/routing.c               |  6 +++---
 net/batman-adv/send.c                  |  6 +++---
 net/batman-adv/soft-interface.c        |  6 +++---
 net/batman-adv/sysfs.c                 |  4 ++--
 net/batman-adv/tp_meter.c              |  2 +-
 18 files changed, 78 insertions(+), 78 deletions(-)
