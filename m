From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: pull request: batman-adv 2011-01-29
Date: Sat, 29 Jan 2011 22:47:27 +0100
Message-ID: <1296337660-12376-1-git-send-email-sven@narfation.org>
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
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I would like to propose following changes for net-2.6.git/2.6.38 which fi=
xes
some bugs in the fragmentation and vis code. There are also some minor cl=
eanup
patches available. If you don't want to merge those cleanup patches then =
please
look bellow the first diffstat for an alternative way to get only the bug=
fixes.

thanks,
	Sven

The following changes since commit aa0adb1a85e159cf57f0e11282bc6c9e3606a5=
f3:

  batman-adv: Use "__attribute__" shortcut macros (2011-01-16 03:25:19 +0=
100)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/merge

Linus L=C3=BCssing (1):
      batman-adv: Fix kernel panic when fetching vis data on a vis server

Simon Wunderlich (1):
      batman-adv: remove unused parameters

Sven Eckelmann (11):
      batman-adv: Create roughly equal sized fragments
      batman-adv: Calculate correct size for merged packets
      batman-adv: Remove vis info on hashing errors
      batman-adv: Remove vis info element in free_info
      batman-adv: Make vis info stack traversal threadsafe
      batman-adv: Remove dangling declaration of hash_remove_element
      batman-adv: Remove unused definitions
      batman-adv: Remove declaration of batman_skb_recv
      batman-adv: Remove unused variables
      batman-adv: Update copyright years
      batman-adv: Merge README of v2011.0.0 release

 Documentation/networking/batman-adv.txt |   16 ++++++++--------
 net/batman-adv/Makefile                 |    2 +-
 net/batman-adv/aggregation.c            |    2 +-
 net/batman-adv/aggregation.h            |    2 +-
 net/batman-adv/bat_debugfs.c            |    6 ++----
 net/batman-adv/bat_debugfs.h            |    2 +-
 net/batman-adv/bat_sysfs.c              |    2 +-
 net/batman-adv/bat_sysfs.h              |    2 +-
 net/batman-adv/bitarray.c               |    2 +-
 net/batman-adv/bitarray.h               |    2 +-
 net/batman-adv/gateway_client.c         |    2 +-
 net/batman-adv/gateway_client.h         |    2 +-
 net/batman-adv/gateway_common.c         |    2 +-
 net/batman-adv/gateway_common.h         |    2 +-
 net/batman-adv/hard-interface.c         |   13 ++++++++++---
 net/batman-adv/hard-interface.h         |    6 +-----
 net/batman-adv/hash.c                   |    2 +-
 net/batman-adv/hash.h                   |    7 +------
 net/batman-adv/icmp_socket.c            |    2 +-
 net/batman-adv/icmp_socket.h            |    2 +-
 net/batman-adv/main.c                   |    2 +-
 net/batman-adv/main.h                   |   17 +----------------
 net/batman-adv/originator.c             |    4 ++--
 net/batman-adv/originator.h             |    2 +-
 net/batman-adv/packet.h                 |    3 ++-
 net/batman-adv/ring_buffer.c            |    2 +-
 net/batman-adv/ring_buffer.h            |    2 +-
 net/batman-adv/routing.c                |   26 ++++++++-----------------=
-
 net/batman-adv/routing.h                |    5 ++---
 net/batman-adv/send.c                   |    6 +++---
 net/batman-adv/send.h                   |    2 +-
 net/batman-adv/soft-interface.c         |    2 +-
 net/batman-adv/soft-interface.h         |    2 +-
 net/batman-adv/translation-table.c      |    2 +-
 net/batman-adv/translation-table.h      |    2 +-
 net/batman-adv/types.h                  |    2 +-
 net/batman-adv/unicast.c                |   15 ++++++++++-----
 net/batman-adv/unicast.h                |   25 ++++++++++++++++++++++++-
 net/batman-adv/vis.c                    |   16 +++++++++-------
 net/batman-adv/vis.h                    |    2 +-
 40 files changed, 109 insertions(+), 108 deletions(-)



If you don't want to merge those cleanup patches, please merge only the
bugfixes. They can be found in the branch batman-adv/merge-bugfixonly.

The following changes since commit aa0adb1a85e159cf57f0e11282bc6c9e3606a5=
f3:

  batman-adv: Use "__attribute__" shortcut macros (2011-01-16 03:25:19 +0=
100)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/merge-bugfixonl=
y

Linus L=C3=BCssing (1):
      batman-adv: Fix kernel panic when fetching vis data on a vis server

Sven Eckelmann (5):
      batman-adv: Create roughly equal sized fragments
      batman-adv: Calculate correct size for merged packets
      batman-adv: Remove vis info on hashing errors
      batman-adv: Remove vis info element in free_info
      batman-adv: Make vis info stack traversal threadsafe

 net/batman-adv/packet.h  |    1 +
 net/batman-adv/routing.c |    2 +-
 net/batman-adv/unicast.c |   13 +++++++++----
 net/batman-adv/unicast.h |   23 +++++++++++++++++++++++
 net/batman-adv/vis.c     |   14 ++++++++------
 5 files changed, 42 insertions(+), 11 deletions(-)
