From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2011-07-05
Date: Tue,  5 Jul 2011 15:43:54 +0200
Message-ID: <1309873440-11704-1-git-send-email-lindner_marek@yahoo.de>
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

Hi,
   
I'd like to get the following patches pulled into net-next-2.6/3.1.          
This patchset contains a mix of cleanup code (patch 1-3) for the protocol
changes we sent you with our last pull request, 2 bug fixes and an
improved version handling patch.

Thanks,
Marek

PS: This is my first pull request - have mercy on my soul and let me know
if does not meet your expectations.

The following changes since commit 43676ab590c3f8686fd047d34c3e33803eef71f0:

  batman-adv: improved gateway tq-based selection (2011-06-20 11:37:41 +0200)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/next

Antonio Quartulli (3):
      batman-adv: unify flags for tt_change/tt_local_entry/tt_global_entry
      batman-adv: add_bcast_packet_to_list() takes the sending delay as parameter
      batman-adv: pass a unique flag arg instead of a sequence of bool ones

Marek Lindner (2):
      batman-adv: broadcast primary OGM on all active hard-interfaces
      batman-adv: aggregation checks should use the primary_if pointer

Sven Eckelmann (1):
      batman-adv: Replace version info instead of appending them

 net/batman-adv/aggregation.c       |   25 ++++++++++++++++++++-----
 net/batman-adv/gateway_client.c    |    5 ++---
 net/batman-adv/main.c              |    9 ++-------
 net/batman-adv/main.h              |   11 +++--------
 net/batman-adv/originator.c        |    5 ++---
 net/batman-adv/packet.h            |   11 +++++++----
 net/batman-adv/routing.c           |    2 +-
 net/batman-adv/send.c              |   21 +++++++++++++++------
 net/batman-adv/send.h              |    2 +-
 net/batman-adv/soft-interface.c    |    2 +-
 net/batman-adv/translation-table.c |   30 ++++++++++++++----------------
 net/batman-adv/translation-table.h |    3 +--
 net/batman-adv/types.h             |    4 ++--
 13 files changed, 71 insertions(+), 59 deletions(-)
 
