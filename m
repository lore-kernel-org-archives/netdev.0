From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: pull request: batman-adv 2012-06-28
Date: Thu, 28 Jun 2012 11:34:09 +0200
Message-ID: <1340876067-28333-1-git-send-email-ordex@autistici.org>
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

this is another set of patches I'd like to see included in net-next/linux-3.6.
Here you have some more patches aimed to clean our namespace, a minor cleanup
for the vis code that eliminates a useless intermediate buffer used to
provide the output and two other minor cleanups for the TranslationTable code.


Tell me if there is any problem!

Thank you,
	Antonio



The following changes since commit 160eb5a6b14ca2eab5c598bdbbb24c24624bad34:

  ipv4: Kill early demux method return value. (2012-06-27 22:01:22 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 42d0b044b7c9e5821f1bf3e2b4ea7861417c11c2:

  batman-adv: Prefix main defines with BATADV_ (2012-06-28 08:45:05 +0200)

----------------------------------------------------------------
Included changes:
- another batch of patches meant to clean batman-adv namespace
- deletion of an obsolete intermediate buffer used in the visualization code to
  print the output
- TT code cleanups

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: clear ADD+DEL (and viceversa) events in the same orig-interval
      batman-adv: beautify tt_global_add() argument list

Sven Eckelmann (16):
      batman-adv: Prefix unicast local static functions with batadv_
      batman-adv: Prefix vis local static functions with batadv_
      batman-adv: Prefix main local static functions with batadv_
      batman-adv: Prefix remaining function like macros with batadv_
      batman-adv: Directly print to seq_file in vis
      batman-adv: Prefix local defines with BATADV_
      batman-adv: Prefix debugfs defines with BATADV_
      batman-adv: Prefix sysfs defines with BATADV_
      batman-adv: Prefix bridge_loop_avoidance defines with BATADV_
      batman-adv: Prefix gateway defines with BATADV_
      batman-adv: Prefix icmp_socket defines with BATADV_
      batman-adv: Prefix packet defines with BATADV_
      batman-adv: Prefix types defines with BATADV_
      batman-adv: Prefix unicast defines with BATADV_
      batman-adv: Prefix vis defines with BATADV_
      batman-adv: Prefix main defines with BATADV_

 net/batman-adv/bat_debugfs.c           |   34 +--
 net/batman-adv/bat_debugfs.h           |    2 +-
 net/batman-adv/bat_iv_ogm.c            |  125 ++++++----
 net/batman-adv/bat_sysfs.c             |  228 +++++++++--------
 net/batman-adv/bat_sysfs.h             |    4 +-
 net/batman-adv/bitarray.c              |   20 +-
 net/batman-adv/bitarray.h              |    4 +-
 net/batman-adv/bridge_loop_avoidance.c |   24 +-
 net/batman-adv/bridge_loop_avoidance.h |    2 +-
 net/batman-adv/gateway_client.c        |   32 +--
 net/batman-adv/gateway_common.c        |   26 +-
 net/batman-adv/gateway_common.h        |    6 +-
 net/batman-adv/hard-interface.c        |   50 ++--
 net/batman-adv/icmp_socket.c           |    6 +-
 net/batman-adv/icmp_socket.h           |    2 +-
 net/batman-adv/main.c                  |   91 +++----
 net/batman-adv/main.h                  |  101 ++++----
 net/batman-adv/originator.c            |   34 +--
 net/batman-adv/packet.h                |   12 +-
 net/batman-adv/ring_buffer.c           |    4 +-
 net/batman-adv/routing.c               |   32 +--
 net/batman-adv/send.c                  |    6 +-
 net/batman-adv/soft-interface.c        |   24 +-
 net/batman-adv/translation-table.c     |  163 +++++++-----
 net/batman-adv/translation-table.h     |    4 +-
 net/batman-adv/types.h                 |   19 +-
 net/batman-adv/unicast.c               |   37 +--
 net/batman-adv/unicast.h               |    4 +-
 net/batman-adv/vis.c                   |  422 ++++++++++++++------------------
 net/batman-adv/vis.h                   |    2 +-
 30 files changed, 780 insertions(+), 740 deletions(-)
