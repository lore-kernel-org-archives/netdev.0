From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: pull request for net-next: batman-adv 2016-07-01
Date: Fri,  1 Jul 2016 15:08:52 +0200
Message-ID: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
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

Hi David,

we are a bit late to submit our feature patches, but I hope we make it in=
 time.
Antonio is taking a pause in his upstream work, so I'll be submitting our
batman-adv patches for now. It is my first time, so please bear with me. =
:)

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 99860208bc62d8ebd5c57495b84856506fe075=
bc:

  sched: remove NET_XMIT_POLICED (2016-06-12 22:02:11 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-2016=
0701

for you to fetch changes up to 4e3e823b5a503235630921287f130e1d8d22d200:

  batman-adv: Add debugfs table for mcast flags (2016-06-30 10:29:43 +020=
0)

----------------------------------------------------------------
This feature patchset includes the following changes:

 - two patches with minimal clean up work by Antonio Quartulli and
   Simon Wunderlich

 - eight patches of B.A.T.M.A.N. V, API and documentation clean
   up work, by Antonio Quartulli and Marek Lindner

 - Andrew Lunn fixed the skb priority adoption when forwarding
   fragmented packets (two patches)

 - Multicast optimization support is now enabled for bridges which
   comes with some protocol updates, by Linus Luessing

----------------------------------------------------------------
Andrew Lunn (2):
  batman-adv: Set skb priority in fragments
  batman-adv: Include frame priority in fragment header

Antonio Quartulli (4):
  batman-adv: statically print gateway table header
  batman-adv: remove ogm_emit and ogm_schedule API calls
  batman-adv: remove useless inline attribute for sysfs helper function
  batman-adv: move GW mode and selection class to private data structure

Linus L=C3=BCssing (4):
  batman-adv: Always flood IGMP/MLD reports
  batman-adv: Add multicast optimization support for bridged setups
  batman-adv: Adding logging of mcast flag changes
  batman-adv: Add debugfs table for mcast flags

Marek Lindner (5):
  batman-adv: document sysfs files in alphabetical order
  batman-adv: update elp interval documentation
  batman-adv: refactor batadv_neigh_node_* functions to follow common
    style
  batman-adv: remove unused callback from batadv_algo_ops struct
  batman-adv: init ELP tweaking options only once

Simon Wunderlich (2):
  batman-adv: Start new development cycle
  batman-adv: remove unused vid local variable in tt seq print

 .../ABI/testing/sysfs-class-net-batman-adv         |  20 +-
 net/batman-adv/Kconfig                             |   2 +-
 net/batman-adv/bat_algo.h                          |   7 +-
 net/batman-adv/bat_iv_ogm.c                        |  72 ++-
 net/batman-adv/bat_v.c                             |  29 +-
 net/batman-adv/bat_v_elp.c                         |   4 +-
 net/batman-adv/bat_v_ogm.c                         |   4 +-
 net/batman-adv/debugfs.c                           |  23 +
 net/batman-adv/fragmentation.c                     |  12 +-
 net/batman-adv/gateway_client.c                    |  15 +-
 net/batman-adv/gateway_common.c                    |   6 +-
 net/batman-adv/hard-interface.c                    |   6 +-
 net/batman-adv/main.c                              |   2 -
 net/batman-adv/main.h                              |   6 +-
 net/batman-adv/multicast.c                         | 499 +++++++++++++++=
++++--
 net/batman-adv/multicast.h                         |   3 +
 net/batman-adv/originator.c                        |  40 +-
 net/batman-adv/originator.h                        |   6 +-
 net/batman-adv/packet.h                            |   7 +-
 net/batman-adv/routing.c                           |   2 +
 net/batman-adv/send.c                              |  61 +--
 net/batman-adv/send.h                              |   4 +-
 net/batman-adv/soft-interface.c                    |  10 +-
 net/batman-adv/sysfs.c                             |  22 +-
 net/batman-adv/translation-table.c                 |   2 -
 net/batman-adv/types.h                             |  32 +-
 26 files changed, 704 insertions(+), 192 deletions(-)

--=20
2.8.1
