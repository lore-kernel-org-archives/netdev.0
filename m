From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 00/19] pull request for net-next: batman-adv 2017-04-06
Date: Thu,  6 Apr 2017 16:07:22 +0200
Message-ID: <20170406140741.30745-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32890 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755214AbdDFOHp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here is our feature/cleanup pull request of batman-adv to go into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 4495c08e84729385774601b5146d51d9e5849f81:

  Linux 4.11-rc2 (2017-03-12 14:47:08 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170406

for you to fetch changes up to ab044f8e3eaf84c4cc95d7606fadfdfa006dc8ec:

  batman-adv: Use net_device_stats from struct net_device (2017-04-05 15:41:24 +0200)

----------------------------------------------------------------
This feature/cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - Code and Style cleanups, by Sven Eckelmann (5 patches)

 - Remove an unneccessary memset, by Tobias Klauser

 - DAT and BLA optimizations for various corner cases, by Andreas Pape
   (5 patches)

 - forward/rebroadcast packet restructuring, by Linus Luessing
   (2 patches)

 - ethtool cleanup and remove unncessary code, by Sven Eckelmann
   (4 patches)

 - use net_device_stats from net_device instead of private copy,
   by Tobias Klauser

----------------------------------------------------------------
Andreas Pape (5):
      batman-adv: prevent multiple ARP replies sent by gateways if dat enabled
      batman-adv: prevent duplication of ARP replies when DAT is used
      batman-adv: drop unicast packets from other backbone gw
      batman-adv: changed debug messages for easier bla debugging
      batman-adv: handle race condition for claims between gateways

Linus Lüssing (2):
      batman-adv: privatize forw_packet skb assignment
      batman-adv: restructure rebroadcast counter into forw_packet API

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (9):
      batman-adv: Reduce preprocessor checks in multicast.c
      batman-adv: Fix unbalanced braces around else statement
      batman-adv: Fix possible side-effects in _batadv_dbg
      batman-adv: Convert BATADV_PRINT_VID macro to function
      batman-adv: Use __func__ to add function names to messages
      batman-adv: Use ethtool helper to get link status
      batman-adv: Remove ethtool msglevel functions
      batman-adv: Remove ethtool .get_settings stub
      batman-adv: Group ethtool related code together

Tobias Klauser (2):
      batman-adv: Omit unnecessary memset of netdev private data
      batman-adv: Use net_device_stats from struct net_device

 net/batman-adv/bat_iv_ogm.c            |  17 +--
 net/batman-adv/bridge_loop_avoidance.c | 123 +++++++++++++----
 net/batman-adv/bridge_loop_avoidance.h |  11 ++
 net/batman-adv/distributed-arp-table.c |  64 +++++++--
 net/batman-adv/log.h                   |   5 +-
 net/batman-adv/main.c                  |   3 +
 net/batman-adv/main.h                  |  18 ++-
 net/batman-adv/multicast.c             |  12 +-
 net/batman-adv/routing.c               |  25 +++-
 net/batman-adv/send.c                  |  76 +++++++++--
 net/batman-adv/send.h                  |   4 +-
 net/batman-adv/soft-interface.c        | 238 +++++++++++++--------------------
 net/batman-adv/tp_meter.c              |   7 +-
 net/batman-adv/translation-table.c     |  42 +++---
 net/batman-adv/types.h                 |   6 +-
 15 files changed, 413 insertions(+), 238 deletions(-)
