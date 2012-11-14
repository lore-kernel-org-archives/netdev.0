From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-11-14
Date: Wed, 14 Nov 2012 21:16:18 +0100
Message-ID: <1352924189-18843-1-git-send-email-ordex@autistici.org>
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

Hello David,

here is again our new patchset intended for net-next/linux-3.8.
Patch 1/11 has been modified to address the problems you pointed out last time;
however hash_bytes has kept its inline tag and it has been moved to hash.h (in
this way it becomes usable by the rest of the batman-adv code for new changes).

Let me know if there is any problem!

Thanks a lot!
	Antonio

The following changes since commit bf0098f22ca7b59e8844ac6882bbae230d34b98d:

  ARM: net: bpf_jit_32: add VLAN instructions for BPF JIT (2012-11-13 18:21:10 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 170173bf37342dab486daaa2a0381d802c10fb21:

  batman-adv: Remove instant overwritten variable initialization (2012-11-14 21:00:37 +0100)

----------------------------------------------------------------
Included changes:
- hash computation improvements
- Bridge Loop Avoidance set-up phase optimisations
- Roaming handling code redesign
- some code cleanups

----------------------------------------------------------------
Antonio Quartulli (6):
      batman-adv: fix wrong spinlock inline comment
      batman-adv: prevent using any virtual device created on batman-adv as hard-interface
      batman-adv: substitute tt_poss_change with a per-tt_entry flag
      batman-adv: refactor code to simplify long lines
      batman-adv: refactor tt_global_del_struct()
      batman-adv: roaming handling mechanism redesign

Simon Wunderlich (4):
      batman-adv: don't rely on positions in struct for hashing
      batman-adv: send announcement when backbone gw is registered
      batman-adv: allow bla traffic only after first worker period
      batman-adv: wait multiple periods before activating bla

Sven Eckelmann (1):
      batman-adv: Remove instant overwritten variable initialization

 net/batman-adv/bridge_loop_avoidance.c |  59 ++++---
 net/batman-adv/hard-interface.c        |  41 ++++-
 net/batman-adv/hash.h                  |  22 +++
 net/batman-adv/main.h                  |   1 +
 net/batman-adv/originator.c            |   1 -
 net/batman-adv/routing.c               | 173 +++++++++++++++------
 net/batman-adv/soft-interface.c        |   1 -
 net/batman-adv/sysfs.c                 |   2 +-
 net/batman-adv/translation-table.c     | 276 ++++++++++++++++++++++-----------
 net/batman-adv/translation-table.h     |   2 +
 net/batman-adv/types.h                 |  11 +-
 11 files changed, 416 insertions(+), 173 deletions(-)
