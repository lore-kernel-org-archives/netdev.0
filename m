From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] pull request for net: batman-adv
 2017-06-13
Date: Tue, 13 Jun 2017 13:15:29 +0200
Message-ID: <20170613111531.29082-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
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

here are two batman-adv bugfixes for net.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 2ea659a9ef488125eb46da6eb571de5eae5c43f6:

  Linux 4.12-rc1 (2017-05-13 13:19:49 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20170613

for you to fetch changes up to a1a745ef980a1b48299ead4ea7990e62c0516f6e:

  batman-adv: fix memory leak when dropping packet from other gateway (2017-05-19 12:20:28 +0200)

----------------------------------------------------------------
Here are two batman-adv bugfixes:

 - fix rx packet counters for local ARP replies, by Sven Eckelmann

 - fix memory leaks for unicast packetes received from another gateway
   in bridge loop avoidance, by Andreas Pape

----------------------------------------------------------------
Andreas Pape (1):
      batman-adv: fix memory leak when dropping packet from other gateway

Sven Eckelmann (1):
      batman-adv: Fix rx packet/bytes stats on local ARP reply

 net/batman-adv/distributed-arp-table.c | 5 +++--
 net/batman-adv/routing.c               | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)
