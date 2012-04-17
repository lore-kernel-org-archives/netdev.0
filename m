From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-04-17
Date: Tue, 17 Apr 2012 13:58:16 +0200
Message-ID: <1334663907-22725-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

here are a set of changes I would like to propose for next-next/3.5.
Most of the patches are simple cleanups and small fixes. The only important
change is patch 3 which changes the Originator Message sequence number starting
value from 0 to a random generated value.

Thank you,
	Antonio

The following changes since commit ecffe75f934b4e3c5301fe5db278068e0efb0d6b:

  hippi: fix printk format in rrunner.c (2012-04-16 23:48:38 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 520ada6df73ab595f7d51378b9df937371f13460:

  batman-adv: skip the window protection test when the originator has no neighbours (2012-04-17 13:29:19 +0200)

----------------------------------------------------------------
Included changes:
* several cleanups and fixes
* OriGinator Message seqno initial value is now random

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: use ETH_HLEN instead of sizeof(struct ethhdr)
      batman-adv: print OGM seq numbers as unsigned long
      batman-adv: skip the window protection test when the originator has no neighbours

Marek Lindner (8):
      batman-adv: move ogm initialization into the proper function
      batman-adv: refactoring API: find generalized name for bat_ogm_init callback
      batman-adv: randomize initial seqno to avoid collision
      batman-adv: add iface_disable() callback to routing API
      batman-adv: handle routing code initialization properly
      batman-adv: refactoring API: find generalized name for bat_ogm_init_primary callback
      batman-adv: rename BATMAN_OGM_LEN to BATMAN_OGM_HLEN
      batman-adv: mark existing ogm variables as batman iv

 net/batman-adv/bat_iv_ogm.c            |   63 +++++++++++++++++++++-----------
 net/batman-adv/bridge_loop_avoidance.c |   10 ++---
 net/batman-adv/hard-interface.c        |   33 +++++++++--------
 net/batman-adv/icmp_socket.c           |    4 +-
 net/batman-adv/main.c                  |    5 ++-
 net/batman-adv/packet.h                |    6 +--
 net/batman-adv/routing.c               |   10 ++---
 net/batman-adv/send.c                  |   14 +++----
 net/batman-adv/soft-interface.c        |    2 +-
 net/batman-adv/types.h                 |   12 +++---
 net/batman-adv/vis.c                   |    8 ++--
 11 files changed, 95 insertions(+), 72 deletions(-)
