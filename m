From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2012-02-28
Date: Tue, 28 Feb 2012 19:32:20 +0800
Message-ID: <1330428748-23137-1-git-send-email-lindner_marek@yahoo.de>
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

Hi David,

here comes the second set of patches I'd like to see pulled into
net-next-2.6/3.4. It mostly contains code cleanups, some code
refactoring work and a minor fix. Let me know if there any problems.

Thanks,
Marek

The following changes since commit ea3d2fd1b11fb3ef8706a48ece0a49a61bcd08bc:

  batman-adv: export used routing algorithm via sysfs (2012-02-17 02:50:20 +0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git batman-adv-for-davem

or older git versions:

 git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 7c64fd98ce512de6c6dae0452dc026446bd368d5:

  batman-adv: Fix indentation of multiline statements (2012-02-28 19:14:31 +0800)

----------------------------------------------------------------
code cleanups and code refactoring

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: set TT_CLIENT_NEW flag before invoking hash_add()
      batman-adv: code refactoring - move debug print into tt_local_set_pending
      batman-adv: TT_CLIENT_PENDING is never set in struct tt_global_entry

Marek Lindner (1):
      batman-adv: convert time_after instances to has_timed_out

Sven Eckelmann (4):
      batman-adv: refactor tt_global_del() to avoid misalignment
      batman-adv: Update copyright years
      batman-adv: Start new development cycle
      batman-adv: Fix indentation of multiline statements

 net/batman-adv/Makefile            |    2 +-
 net/batman-adv/bat_algo.h          |    2 +-
 net/batman-adv/bat_debugfs.c       |    2 +-
 net/batman-adv/bat_debugfs.h       |    2 +-
 net/batman-adv/bat_iv_ogm.c        |    2 +-
 net/batman-adv/bat_sysfs.c         |    6 +-
 net/batman-adv/bat_sysfs.h         |    2 +-
 net/batman-adv/bitarray.c          |   10 ++--
 net/batman-adv/bitarray.h          |    2 +-
 net/batman-adv/gateway_client.c    |    6 +-
 net/batman-adv/gateway_client.h    |    2 +-
 net/batman-adv/gateway_common.c    |    6 +-
 net/batman-adv/gateway_common.h    |    2 +-
 net/batman-adv/hard-interface.c    |   32 +++++-----
 net/batman-adv/hard-interface.h    |    2 +-
 net/batman-adv/hash.c              |    2 +-
 net/batman-adv/hash.h              |    2 +-
 net/batman-adv/icmp_socket.c       |    2 +-
 net/batman-adv/icmp_socket.h       |    2 +-
 net/batman-adv/main.c              |    2 +-
 net/batman-adv/main.h              |   17 +++---
 net/batman-adv/originator.c        |   18 ++---
 net/batman-adv/originator.h        |    2 +-
 net/batman-adv/packet.h            |    2 +-
 net/batman-adv/ring_buffer.c       |    2 +-
 net/batman-adv/ring_buffer.h       |    2 +-
 net/batman-adv/routing.c           |   13 ++--
 net/batman-adv/routing.h           |    2 +-
 net/batman-adv/send.c              |    2 +-
 net/batman-adv/send.h              |    2 +-
 net/batman-adv/soft-interface.c    |    6 +-
 net/batman-adv/soft-interface.h    |    2 +-
 net/batman-adv/translation-table.c |  119 ++++++++++++++++-------------------
 net/batman-adv/translation-table.h |    2 +-
 net/batman-adv/types.h             |    2 +-
 net/batman-adv/unicast.c           |    2 +-
 net/batman-adv/unicast.h           |    2 +-
 net/batman-adv/vis.c               |    5 +-
 net/batman-adv/vis.h               |    5 +-
 39 files changed, 141 insertions(+), 156 deletions(-)
