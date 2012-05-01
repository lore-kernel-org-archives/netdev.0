From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-05-01
Date: Tue,  1 May 2012 10:00:59 +0200
Message-ID: <1335859266-7546-1-git-send-email-ordex@autistici.org>
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

this is the new version of my previous pull request (issued on 2012-04-29).
I'd like to see this changesin net-next/linux-3.5.

In this pull request I entirely removed the D.A.T. code, that as we were
discussing in the previous thread, needs some rewriting to avoid directly
dealing with the neigh table.

This patchset only contains fixes and cleanups.

Letme know if there is any problem!

Thank you,
	Antonio

The following changes since commit 7a2a66a0ac1cf93d30869c4ecbfc71a2fda19397:

  Add linux-next specific files for 20120423 (2012-04-23 16:58:43 +1000)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 969e62ad00763fed9ea28700ef7a7d97fdbfddf3:

  batman-adv: split neigh_new function into generic and batman iv specific parts (2012-05-01 00:37:58 +0200)

----------------------------------------------------------------
Included changes:

* minor fixes and cleanups
* minor routing protocol API cleanups

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: fix wrong dhcp option list browsing

Marek Lindner (6):
      batman-adv: introduce is_single_hop_neigh variable to increase readability
      batman-adv: introduce packet type handler array for incoming packets
      batman-adv: register batman ogm receive function during protocol init
      batman-adv: rename last_valid to last_seen
      batman-adv: replace HZ calculations with jiffies_to_msecs()
      batman-adv: split neigh_new function into generic and batman iv specific parts

 net/batman-adv/bat_debugfs.c    |    4 +-
 net/batman-adv/bat_iv_ogm.c     |   95 +++++++++++++++++++++++-------
 net/batman-adv/gateway_client.c |    6 +-
 net/batman-adv/hard-interface.c |  113 ------------------------------------
 net/batman-adv/main.c           |  122 ++++++++++++++++++++++++++++++++++++++-
 net/batman-adv/main.h           |    6 ++
 net/batman-adv/originator.c     |   50 ++++++++--------
 net/batman-adv/originator.h     |    6 +-
 net/batman-adv/routing.c        |   22 ++++---
 net/batman-adv/routing.h        |    4 +-
 net/batman-adv/send.c           |    2 +-
 net/batman-adv/types.h          |   11 ++--
 12 files changed, 249 insertions(+), 192 deletions(-)
