From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/3] pull request for net: batman-adv
	2016-10-26
Date: Wed, 26 Oct 2016 17:55:12 +0200
Message-ID: <20161026155515.18075-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
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

here are some bugfix patches which we would like to have integrated
into net.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 29fbff8698fc0ac1a1d74584b258e0bf18b469f9:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-10-13 21:40:23 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20161026

for you to fetch changes up to 9799c50372b23ed774791bdb87d700f1286ee8a9:

  batman-adv: fix splat on disabling an interface (2016-10-21 14:47:02 +0200)

----------------------------------------------------------------
Here are three batman-adv bugfix patches:

 - Fix RCU usage for neighbor list, by Sven Eckelmann

 - Fix BATADV_DBG_ALL loglevel to include TP Meter messages, by Sven Eckelmann

 - Fix possible splat when disabling an interface, by Linus Luessing

----------------------------------------------------------------
Linus Lüssing (1):
      batman-adv: fix splat on disabling an interface

Sven Eckelmann (2):
      batman-adv: Modify neigh_list only with rcu-list functions
      batman-adv: Add BATADV_DBG_TP_METER to BATADV_DBG_ALL

 net/batman-adv/hard-interface.c | 1 -
 net/batman-adv/log.h            | 2 +-
 net/batman-adv/originator.c     | 2 +-
 3 files changed, 2 insertions(+), 3 deletions(-)
