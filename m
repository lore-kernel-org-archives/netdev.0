From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] pull request for net: batman-adv
	2016-11-19
Date: Sat, 19 Nov 2016 12:06:12 +0100
Message-ID: <20161119110614.23325-1-sw@simonwunderlich.de>
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

The following changes since commit 9799c50372b23ed774791bdb87d700f1286ee8a9:

  batman-adv: fix splat on disabling an interface (2016-10-21 14:47:02 +0200)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20161119

for you to fetch changes up to e13258f38e927b61cdb5f4ad25309450d3b127d1:

  batman-adv: Detect missing primaryif during tp_send as error (2016-11-04 12:27:39 +0100)

----------------------------------------------------------------
Here are two batman-adv bugfix patches:

 - Revert a splat on disabling interface which created another problem,
   by Sven Eckelmann

 - Fix error handling when the primary interface disappears during a
   throughput meter test, by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (2):
      batman-adv: Revert "fix splat on disabling an interface"
      batman-adv: Detect missing primaryif during tp_send as error

 net/batman-adv/hard-interface.c | 1 +
 net/batman-adv/tp_meter.c       | 1 +
 2 files changed, 2 insertions(+)
