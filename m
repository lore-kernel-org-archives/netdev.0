From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-05-14
Date: Mon, 14 May 2012 09:17:30 +0200
Message-ID: <1336979858-13928-1-git-send-email-ordex@autistici.org>
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

Hello David,

here is our last set of changes intended for net-next/linux-3.5.
In this patchset there are:

1) several minor cleanups and fixes
2) an optimisation that avoid to linearise the whole packet when not needed
3) an optimisation for client traffic rerouting after a roaming event.

Patches that modify the whole naming schema will be sent later for merging
with linux-3.6.

Thank you,
	Antonio

The following changes since commit f96a8a0b78548c0ec06b0b4b438db6ee895d67e9:

  igb: Add Support for new i210/i211 devices. (2012-05-12 13:17:13 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 521251f2f5fa16747cc21e71580e404af855d140:

  batman-adv: unset the TT_CLIENT_PENDING flag if the new local entry already exists (2012-05-14 09:05:08 +0200)

----------------------------------------------------------------
Included changes:

* an improvement to avoid to linearise the whole received packet when not needed
* an improvement for client traffic rerouting after roaming
* a fix for the local translation table state-machine
* minor cleanups and fixes

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: avoid skb_linearise() if not needed
      batman-adv: improve unicast packet (re)routing
      batman-adv: unset the TT_CLIENT_PENDING flag if the new local entry already exists

Marek Lindner (2):
      batman-adv: prepare lq_update_lock to be shared among different protocols
      batman-adv: refactor window_protected to avoid unnecessary return statement

Sven Eckelmann (3):
      batman-adv: use shorter pr_warn instead of pr_warning
      batman-adv: Start new development cycle
      batman-adv: README cleanups

 Documentation/networking/batman-adv.txt |   11 +++++------
 net/batman-adv/bat_iv_ogm.c             |    9 ++++-----
 net/batman-adv/hard-interface.c         |    6 +++---
 net/batman-adv/main.h                   |    2 +-
 net/batman-adv/originator.c             |    1 +
 net/batman-adv/routing.c                |   27 ++++++++++++++++-----------
 net/batman-adv/send.c                   |    4 ++--
 net/batman-adv/translation-table.c      |   21 +++++++++++++++++++++
 net/batman-adv/translation-table.h      |    2 ++
 net/batman-adv/types.h                  |    2 +-
 net/batman-adv/unicast.c                |    8 ++++++++
 11 files changed, 64 insertions(+), 29 deletions(-)
