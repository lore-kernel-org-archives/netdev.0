From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-06-21
Date: Thu, 21 Jun 2012 18:57:36 +0200
Message-ID: <1340297876-29923-1-git-send-email-ordex@autistici.org>
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

here is another set of changes intended for net-next/linux-3.6.
>From 1/20 to 19/20 you have our first set of changes aiming to rename the
exported symbols, as you suggested some time ago.

Patch 20/20 restyles all the comments in our code in order to follow the new
guidelines.

Thank you,
	Antonio



The following changes since commit 41063e9dd11956f2d285e12e4342e1d232ba0ea2:

  ipv4: Early TCP socket demux. (2012-06-19 21:22:05 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 9cfc7bd608b97463993b4f3e4775d99022253f8d:

  batman-adv: Reformat multiline comments to consistent style (2012-06-20 22:15:33 +0200)

----------------------------------------------------------------
Included changes:
- first set of patches that add the batadv_ prefix to all the exported symbols
- restyling of comments

----------------------------------------------------------------
Sven Eckelmann (20):
      batman-adv: Prefix bat_algo non-static functions with batadv_
      batman-adv: Prefix bat_debugfs non-static functions with batadv_
      batman-adv: Prefix bat_sysfs non-static functions with batadv_
      batman-adv: Prefix bitarray non-static functions with batadv_
      batman-adv: Prefix bridge_loop_avoidance non-static functions with batadv_
      batman-adv: Prefix gateway-client non-static functions with batadv_
      batman-adv: Prefix gateway-common non-static functions with batadv_
      batman-adv: Prefix hard-interface non-static functions with batadv_
      batman-adv: Prefix hash non-static functions with batadv_
      batman-adv: Prefix icmp-socket non-static functions with batadv_
      batman-adv: Prefix originator non-static functions with batadv_
      batman-adv: Prefix ring_buffer non-static functions with batadv_
      batman-adv: Prefix routing non-static functions with batadv_
      batman-adv: Prefix send non-static functions with batadv_
      batman-adv: Prefix soft-interface non-static functions with batadv_
      batman-adv: Prefix translation-table non-static functions with batadv_
      batman-adv: Prefix unicast non-static functions with batadv_
      batman-adv: Prefix vis non-static functions with batadv_
      batman-adv: Prefix main non-static functions with batadv_
      batman-adv: Reformat multiline comments to consistent style

 net/batman-adv/bat_algo.h              |    6 +-
 net/batman-adv/bat_debugfs.c           |   35 ++--
 net/batman-adv/bat_debugfs.h           |   13 +-
 net/batman-adv/bat_iv_ogm.c            |  205 ++++++++++++-----------
 net/batman-adv/bat_sysfs.c             |   53 +++---
 net/batman-adv/bat_sysfs.h             |   18 +-
 net/batman-adv/bitarray.c              |   25 ++-
 net/batman-adv/bitarray.h              |   14 +-
 net/batman-adv/bridge_loop_avoidance.c |  113 +++++--------
 net/batman-adv/bridge_loop_avoidance.h |   71 ++++----
 net/batman-adv/gateway_client.c        |  134 +++++++--------
 net/batman-adv/gateway_client.h        |   30 ++--
 net/batman-adv/gateway_common.c        |   18 +-
 net/batman-adv/gateway_common.h        |    9 +-
 net/batman-adv/hard-interface.c        |   93 +++++------
 net/batman-adv/hard-interface.h        |   26 ++-
 net/batman-adv/hash.c                  |    8 +-
 net/batman-adv/hash.h                  |   30 ++--
 net/batman-adv/icmp_socket.c           |   27 ++-
 net/batman-adv/icmp_socket.h           |   12 +-
 net/batman-adv/main.c                  |  117 ++++++-------
 net/batman-adv/main.h                  |   84 +++++-----
 net/batman-adv/originator.c            |   76 +++++----
 net/batman-adv/originator.h            |   30 ++--
 net/batman-adv/packet.h                |   21 ++-
 net/batman-adv/ring_buffer.c           |    9 +-
 net/batman-adv/ring_buffer.h           |    9 +-
 net/batman-adv/routing.c               |  282 +++++++++++++++++---------------
 net/batman-adv/routing.h               |   56 +++----
 net/batman-adv/send.c                  |   60 ++++---
 net/batman-adv/send.h                  |   21 ++-
 net/batman-adv/soft-interface.c        |   87 +++++-----
 net/batman-adv/soft-interface.h        |   17 +-
 net/batman-adv/translation-table.c     |  222 ++++++++++++++-----------
 net/batman-adv/translation-table.h     |   67 ++++----
 net/batman-adv/types.h                 |   29 ++--
 net/batman-adv/unicast.c               |   59 ++++---
 net/batman-adv/unicast.h               |   17 +-
 net/batman-adv/vis.c                   |   96 ++++++-----
 net/batman-adv/vis.h                   |   26 ++-
 40 files changed, 1171 insertions(+), 1154 deletions(-)
