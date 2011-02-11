From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: pull request: batman-adv 2011-02-12
Date: Sat, 12 Feb 2011 00:21:39 +0100
Message-ID: <1297466503-13246-1-git-send-email-sven@narfation.org>
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

I would like propose following changes for net-next-2.6.git. Two of them =
are
minor code style changes and the other two change minor issues in the
routing/fragmentation code.

thanks,
	Sven

The following changes since commit 091b948306d2628320e77977eb7ae4a757b121=
80:

  batman-adv: Merge README of v2011.0.0 release (2011-01-31 14:57:13 +010=
0)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Linus L=C3=BCssing (2):
      batman-adv: Remove duplicate types.h inclusions
      batman-adv: Disallow originator addressing within mesh layer

Marek Lindner (1):
      batman-adv: Split combined variable declarations

Sven Eckelmann (1):
      batman-adv: Use successive sequence numbers for fragments

 net/batman-adv/icmp_socket.c       |    1 -
 net/batman-adv/icmp_socket.h       |    2 --
 net/batman-adv/main.c              |    1 -
 net/batman-adv/routing.c           |    1 -
 net/batman-adv/routing.h           |    2 --
 net/batman-adv/send.c              |    1 -
 net/batman-adv/send.h              |    2 --
 net/batman-adv/soft-interface.c    |    1 -
 net/batman-adv/translation-table.c |    1 -
 net/batman-adv/translation-table.h |    2 --
 net/batman-adv/unicast.c           |   19 +++++++------------
 11 files changed, 7 insertions(+), 26 deletions(-)
