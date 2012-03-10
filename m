From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: pull request: batman-adv 2012-03-11
Date: Sun, 11 Mar 2012 06:44:47 +0800
Message-ID: <1331419491-21333-1-git-send-email-lindner_marek@yahoo.de>
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

here are a few late coming patches intended to be merged into net-next-2.6/3.4
if possible. This is nothing fancy: They make peace with the recently 
introduced checkpatch changes. Let me know if there any problems.

Thanks,
Marek

The following changes since commit 7c64fd98ce512de6c6dae0452dc026446bd368d5:

  batman-adv: Fix indentation of multiline statements (2012-02-28 19:14:31 +0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

or older git versions:

 git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 40e0c4f51d3fc3fd54edc797adae314fbe2b96a6:

  batman-adv: Remove spaces after a cast (2012-03-11 06:29:44 +0800)

----------------------------------------------------------------
checkpatch updates for batman-adv

----------------------------------------------------------------
Sven Eckelmann (4):
      batman-adv: Ignore 80-chars per line limits for strings
      batman-adv: Don't begin block comments with only a /* line
      batman-adv: Use {} braces consistent on the arms of a statement
      batman-adv: Remove spaces after a cast

 net/batman-adv/bat_iv_ogm.c        |   57 +++++++++--------------
 net/batman-adv/bat_sysfs.c         |   16 +++---
 net/batman-adv/gateway_client.c    |   31 +++++-------
 net/batman-adv/gateway_common.c    |    8 ++--
 net/batman-adv/hard-interface.c    |   36 +++++----------
 net/batman-adv/icmp_socket.c       |   12 ++---
 net/batman-adv/main.c              |    8 ++--
 net/batman-adv/main.h              |   13 +----
 net/batman-adv/originator.c        |   14 ++---
 net/batman-adv/routing.c           |   30 ++++++------
 net/batman-adv/send.c              |    6 +-
 net/batman-adv/soft-interface.c    |   15 +++---
 net/batman-adv/translation-table.c |   89 +++++++++++++++++------------------
 net/batman-adv/unicast.c           |    4 +-
 14 files changed, 145 insertions(+), 194 deletions(-)
