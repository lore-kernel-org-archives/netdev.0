From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 00/10] pull request for net-next: batman-adv 2017-06-13
Date: Tue, 13 Jun 2017 13:36:50 +0200
Message-ID: <20170613113700.31220-1-sw@simonwunderlich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:43784 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752294AbdFMLhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 07:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

here is our feature/cleanup pull request of batman-adv to go into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6:

  Linux 4.12-rc1 (2017-05-13 13:19:49 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170613

for you to fetch changes up to d62890885efbc48acea46964ea3af69b61c8c5eb:

  batman-adv: Accept only filled wifi station info (2017-06-13 12:25:43 +0200)

----------------------------------------------------------------
This feature/cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - decrease maximum fragment size, by Matthias Schiffer

 - Clean up seqfile writing, by Markus Elfring (2 patches)

 - use __func__ in debug messages, by Sven Eckelmann

 - Mark tpmeter initializers with __init, by Antonio Quartulli

 - ignore loop detection MAC addresses, by Simon Wunderlich

 - clean up some return handling, by Simon Wunderlich

 - improve ELP throughput value handling for WiFi neighbors
   in BATMAN V/ELP, by Sven Eckelmann (2 patches)

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: tp_meter: mark init function with __init

Markus Elfring (2):
      batman-adv: Replace a seq_puts() call by seq_putc() in two functions
      batman-adv: Combine two seq_puts() calls into one call in batadv_nc_nodes_seq_print_text()

Matthias Schiffer (1):
      batman-adv: decrease maximum fragment size

Simon Wunderlich (3):
      batman-adv: Start new development cycle
      batman-adv: do not add loop detection mac addresses to global tt
      batman-adv: simplify return handling in some TT functions

Sven Eckelmann (3):
      batman-adv: Print correct function names in dbg messages
      batman-adv: Use default throughput value on cfg80211 error
      batman-adv: Accept only filled wifi station info

 net/batman-adv/bat_iv_ogm.c            |  5 ++-
 net/batman-adv/bat_v.c                 |  2 +-
 net/batman-adv/bat_v_elp.c             | 10 ++++-
 net/batman-adv/bridge_loop_avoidance.c | 73 ++++++++++++++++++----------------
 net/batman-adv/distributed-arp-table.c |  2 +-
 net/batman-adv/main.h                  |  4 +-
 net/batman-adv/network-coding.c        |  4 +-
 net/batman-adv/routing.c               |  4 +-
 net/batman-adv/send.c                  |  6 +--
 net/batman-adv/tp_meter.c              |  3 +-
 net/batman-adv/translation-table.c     | 21 +++++-----
 11 files changed, 72 insertions(+), 62 deletions(-)
