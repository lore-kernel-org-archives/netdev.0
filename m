From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-05-11
Date: Fri, 11 May 2012 14:21:17 +0200
Message-ID: <1336738892-7401-1-git-send-email-ordex@autistici.org>
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

this is a fixed version of the pull request issued on 2012-05-09.

Comments introduced in this patchset are not following the net-tree
guidelines. Another patch changing all the already existing comments will follow
later. 

New exported functions follow the new name convention we discussed so far.
A patch renaming all the existing exported functions will follow.



Please let me know if there is any problem.
Thank you,
	Antonio


The following changes since commit 06a4c1c55dbe5d9f7a708e8f1a52fd2ac8e5874f:

  6lowpan: IPv6 link local address (2012-05-10 23:38:22 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 35c133a000d54b7e3fe81e8c8e4b8af5878ad6dd:

  batman-adv: add contributor name (2012-05-11 13:56:08 +0200)

----------------------------------------------------------------
Included changes:

* fix a little bug in the DHCP packet snooping introduced so far
* minor fixes and cleanups
* minor routing protocol API cleanups
* add a new contributor name to translation-table.{c,h}
* update copyright years in file headers
* minor improvement for the routing algorithm

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: fix wrong dhcp option list browsing
      batman-adv: update copyright years
      batman-adv: add contributor name

Linus Luessing (1):
      batman-adv: Adding hard_iface specific sysfs wrapper macros for UINT

Marek Lindner (11):
      batman-adv: introduce is_single_hop_neigh variable to increase readability
      batman-adv: introduce packet type handler array for incoming packets
      batman-adv: register batman ogm receive function during protocol init
      batman-adv: rename last_valid to last_seen
      batman-adv: replace HZ calculations with jiffies_to_msecs()
      batman-adv: split neigh_new function into generic and batman iv specific parts
      batman-adv: ignore protocol packets if the interface did not enable this protocol
      batman-adv: refactoring API: find generalized name for bat_ogm_update_mac callback
      batman-adv: rename sysfs macros to reflect the soft-interface dependency
      batman-adv: avoid temporary routing loops by being strict on forwarded OGMs
      batman-adv: fix checkpatch string complaint

 net/batman-adv/bat_debugfs.c           |    4 +-
 net/batman-adv/bat_iv_ogm.c            |  176 +++++++++++++++++++++-----------
 net/batman-adv/bat_sysfs.c             |  100 +++++++++++++-----
 net/batman-adv/bridge_loop_avoidance.c |    2 +-
 net/batman-adv/bridge_loop_avoidance.h |    2 +-
 net/batman-adv/gateway_client.c        |    6 +-
 net/batman-adv/hard-interface.c        |  117 +--------------------
 net/batman-adv/main.c                  |  124 +++++++++++++++++++++-
 net/batman-adv/main.h                  |    6 ++
 net/batman-adv/originator.c            |   51 +++++----
 net/batman-adv/originator.h            |    7 +-
 net/batman-adv/packet.h                |    1 +
 net/batman-adv/routing.c               |   22 ++--
 net/batman-adv/routing.h               |    4 +-
 net/batman-adv/send.c                  |    2 +-
 net/batman-adv/translation-table.c     |    2 +-
 net/batman-adv/translation-table.h     |    2 +-
 net/batman-adv/types.h                 |   17 ++-
 18 files changed, 380 insertions(+), 265 deletions(-)
