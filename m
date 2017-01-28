From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] pull request for net-next: batman-adv
	2017-01-28
Date: Sat, 28 Jan 2017 11:56:49 +0100
Message-ID: <20170128105651.3061-1-sw@simonwunderlich.de>
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

here is another pull request for batman-adv in net-next. One of them fixes
a regression introduced by a patch in the previous pull request two days ago.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit c33705188c493b7de3b8dc2956d67de91b444727:

  batman-adv: Treat NET_XMIT_CN as transmit successfully (2017-01-26 08:41:18 +0100)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170128

for you to fetch changes up to 3e7514afc7d728dd47c5fe9d7a1f5216fe659cda:

  batman-adv: Fix includes for IS_ERR/ERR_PTR (2017-01-28 10:40:35 +0100)

----------------------------------------------------------------
Here are two fixes for batman-adv for net-next:

 - fix double call of dev_queue_xmit(), caused by the recent introduction
   of net_xmit_eval(), by Sven Eckelmann

 - Fix includes for IS_ERR/ERR_PTR, by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (2):
      batman-adv: Fix double call of dev_queue_xmit
      batman-adv: Fix includes for IS_ERR/ERR_PTR

 net/batman-adv/debugfs.c  | 2 +-
 net/batman-adv/send.c     | 4 +++-
 net/batman-adv/tp_meter.c | 2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)
