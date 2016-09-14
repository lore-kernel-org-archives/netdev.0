From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] pull request for net: batman-adv
	2016-09-14
Date: Wed, 14 Sep 2016 14:37:33 +0200
Message-ID: <20160914123735.9411-1-sw@simonwunderlich.de>
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

here are some more bugfix patches which we would like to have integrated
into net.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 1fe323aa1b2390a0c57fb0b06a782f128d49094c:

  sctp: use event->chunk when it's valid (2016-08-08 14:31:23 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20160914

for you to fetch changes up to 1e5d343b8f23770e8ac5d31f5c439826bdb35148:

  batman-adv: fix elp packet data reservation (2016-08-26 15:22:31 +0200)

----------------------------------------------------------------
Here are two batman-adv bugfix patches:

 - Fix reference counting for last_bonding_candidate, by Sven Eckelmann

 - Fix head room reservation for ELP packets, by Linus Luessing

----------------------------------------------------------------
Linus Lüssing (1):
      batman-adv: fix elp packet data reservation

Sven Eckelmann (1):
      batman-adv: Add missing refcnt for last_candidate

 net/batman-adv/bat_v_elp.c |  2 +-
 net/batman-adv/routing.c   | 28 +++++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 2 deletions(-)
