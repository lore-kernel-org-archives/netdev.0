From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/2] pull request for net: batman-adv
	2017-03-16
Date: Thu, 16 Mar 2017 13:55:10 +0100
Message-ID: <20170316125512.30364-1-sw@simonwunderlich.de>
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

here are two bugfixes for batman-adv which we would like to see integrated into net.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 51c6b429c0c95e67edd1cb0b548c5cf6a6604763:

  batman-adv: Fix transmission of final, 16th fragment (2017-02-21 18:33:35 +0100)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-net-for-davem-20170316

for you to fetch changes up to 1a9070ec91b37234fe915849b767c61584c64a44:

  batman-adv: Initialize gw sel_class via batadv_algo (2017-03-04 17:32:06 +0100)

----------------------------------------------------------------
Here are two batman-adv bugfixes:

 - Keep fragments equally sized, avoids some problems with too small fragments,
   by Sven Eckelmann

 - Initialize gateway class correctly when BATMAN V is compiled in,
   by Sven Eckelmann

----------------------------------------------------------------
Sven Eckelmann (2):
      batman-adv: Keep fragments equally sized
      batman-adv: Initialize gw sel_class via batadv_algo

 net/batman-adv/bat_iv_ogm.c     | 11 +++++++++++
 net/batman-adv/bat_v.c          | 14 +++++++++++---
 net/batman-adv/fragmentation.c  | 20 +++++++++++++-------
 net/batman-adv/gateway_common.c |  5 +++++
 net/batman-adv/soft-interface.c |  1 -
 net/batman-adv/types.h          |  2 ++
 6 files changed, 42 insertions(+), 11 deletions(-)
