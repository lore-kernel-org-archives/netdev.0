From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20150108
Date: Thu,  8 Jan 2015 16:15:05 +0100
Message-ID: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4490 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761AbbAHPQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:16:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a batch of patches intended for net-next.

In this patchset you have mostly cleanups and small corrections to issu=
es
reported by checkpatch.

One notable change is the addition of the DEBUG_FS dependency to the
BATMAN_ADV_DEBUG symbol by Markus Pargmann. We add this dependency beca=
use all
the information provided by the DEBUG feature is accessible only throug=
h
debugfs.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio



The following changes since commit 44d84d7272e5848878a96029b8a8b6e86854=
f146:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-0=
1-06 22:29:20 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 9535395640edb23ba5cec2abb026c4ee51899722=
:

  batman-adv: Kconfig, Add missing DEBUG_FS dependency (2015-01-07 22:1=
7:11 +0100)

----------------------------------------------------------------
Included changes:
- remove useless return in void functions
- remove unused member 'primary_iface' from 'struct orig_node'
- improve existing kernel doc
- fix several checkpatch complaints
- ensure socket's control block is cleared for received skbs
- add missing DEBUG_FS dependency to BATMAN_ADV_DEBUG symbol

----------------------------------------------------------------
Antonio Quartulli (7):
      batman-adv: avoid useless return in void functions
      batman-adv: checkpatch - else is not generally useful after a bre=
ak or return
      batman-adv: checkpatch - No space is necessary after a cast
      batman-adv: checkpatch - Please use a blank line after declaratio=
ns
      batman-adv: checkpatch - Please don't use multiple blank lines
      batman-adv: checkpatch - remove unnecessary parentheses
      batman-adv: fix misspelled words

Markus Pargmann (1):
      batman-adv: Kconfig, Add missing DEBUG_FS dependency

Martin Hundeb=C3=B8ll (5):
      batman-adv: kernel doc fixes for bat_iv_ogm.c
      batman-adv: kernel doc fixes for bridge_loop_avoidance.c
      batman-adv: kernel doc fix for distributed-arp-table.h
      batman-adv: kernel doc fixes for main.{c, h}
      batman-adv: clear control block of received socket buffers

Simon Wunderlich (2):
      batman-adv: remove obsolete variable primary_iface from orig_node
      batman-adv: Start new development cycle

 net/batman-adv/Kconfig                 |  1 +
 net/batman-adv/bat_iv_ogm.c            | 15 +++++++--------
 net/batman-adv/bitarray.c              |  1 -
 net/batman-adv/bitarray.h              |  3 +--
 net/batman-adv/bridge_loop_avoidance.c | 17 +++++++----------
 net/batman-adv/debugfs.c               |  2 +-
 net/batman-adv/distributed-arp-table.c |  1 +
 net/batman-adv/distributed-arp-table.h |  4 +---
 net/batman-adv/fragmentation.c         |  1 -
 net/batman-adv/fragmentation.h         |  3 +--
 net/batman-adv/gateway_client.c        |  1 +
 net/batman-adv/main.c                  | 10 ++++++----
 net/batman-adv/main.h                  | 15 +++++++--------
 net/batman-adv/multicast.h             |  3 ---
 net/batman-adv/network-coding.c        |  3 +--
 net/batman-adv/originator.c            |  1 -
 net/batman-adv/originator.h            |  1 -
 net/batman-adv/packet.h                |  5 +++--
 net/batman-adv/routing.c               |  3 +--
 net/batman-adv/soft-interface.c        |  1 -
 net/batman-adv/sysfs.c                 |  1 -
 net/batman-adv/translation-table.c     |  8 +++-----
 net/batman-adv/types.h                 |  4 +---
 23 files changed, 43 insertions(+), 61 deletions(-)
