From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 0/6] pull request for net-next: batman-adv
 2017-08-02
Date: Wed,  2 Aug 2017 16:23:16 +0200
Message-ID: <20170802142322.13376-1-sw@simonwunderlich.de>
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

here is a small feature/cleanup pull request of batman-adv to go into net-next.

Please pull or let me know of any problem!

Thank you,
      Simon

The following changes since commit 5771a8c08880cdca3bfb4a3fc6d309d6bba20877:

  Linux v4.13-rc1 (2017-07-15 15:22:10 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batadv-next-for-davem-20170802

for you to fetch changes up to e45eba2467bd64fd196dc6f8b50ff5e59c0058da:

  batman-adv: Convert batman-adv.txt to reStructuredText (2017-07-29 09:51:28 +0200)

----------------------------------------------------------------
This feature/cleanup patchset includes the following patches:

 - bump version strings, by Simon Wunderlich

 - Remove unnecessary length qualifier, by Joe Perches

 - Remove too short %pM field width, by Sven Eckelmann

 - Remove return value handling from skb_put_data, by Sven Eckelmann

 - Spelling fixes, by Colin Ian King

 - Convert batman-adv.txt to reStructuredText, by Sven Eckelmann

----------------------------------------------------------------
Colin Ian King (1):
      batman-adv: fix various spelling mistakes

Joe Perches (1):
      batman-adv: Remove unnecessary length qualifier in %14pM

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (3):
      batman-adv: Remove too short %pM printk field width
      batman-adv: Remove variable deprecated by skb_put_data
      batman-adv: Convert batman-adv.txt to reStructuredText

 Documentation/networking/00-INDEX       |   2 -
 Documentation/networking/batman-adv.rst | 220 ++++++++++++++++++++++++++++++++
 Documentation/networking/batman-adv.txt | 215 -------------------------------
 Documentation/networking/index.rst      |   1 +
 MAINTAINERS                             |   2 +-
 net/batman-adv/bat_iv_ogm.c             |   6 +-
 net/batman-adv/bat_v_ogm.c              |  16 +--
 net/batman-adv/distributed-arp-table.c  |   2 +-
 net/batman-adv/main.h                   |   2 +-
 net/batman-adv/send.c                   |   2 +-
 10 files changed, 235 insertions(+), 233 deletions(-)
 create mode 100644 Documentation/networking/batman-adv.rst
 delete mode 100644 Documentation/networking/batman-adv.txt
