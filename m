From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-04-11
Date: Wed, 11 Apr 2012 15:03:03 +0200
Message-ID: <20120411130301.GD19365@ritirata.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1334148649-25443-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

On Wed, Apr 11, 2012 at 02:50:33 +0200, Antonio Quartulli wrote:
> Hello,
>=20
> this is our new set of patches (actually there has been no modification f=
rom the
> last pull request issued on 2011-04-07) which is now based on top of the =
current
> net-next/master branch (commit id: 06eb4eafbdc0796d741d139a44f1253278da86=
11).
>=20
> Let me know if there is something else wrong.


Sorry David,

I forgot to attach the "real" pull-request description. Here it is:



The following changes since commit 06eb4eafbdc0796d741d139a44f1253278da8611:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-04-10=
 14:30:45 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 7a5cc24277b57ce38eb0afa6634b71d4d5cc671e:

  batman-adv: add bridge loop avoidance compile option (2012-04-11 14:29:00=
 +0200)

----------------------------------------------------------------
Included=C2=A0changes:
*=C2=A0add=C2=A0my=C2=A0name=C2=A0to=C2=A0the=C2=A0maintainers=C2=A0list=C2=
=A0of=C2=A0batman-adv
*=C2=A0some=C2=A0clean=C2=A0up=C2=A0fixes
*=C2=A0increases=C2=A0the=C2=A0default=C2=A0hop-penalty=C2=A0in=C2=A0order=
=C2=A0to=C2=A0encourage=C2=A0the=C2=A0routing=C2=A0protocol
=C2=A0=C2=A0to=C2=A0choose=C2=A0shorter=C2=A0routes
*=C2=A0renew=C2=A0the=C2=A0bridge=C2=A0loop=C2=A0avoidance=C2=A0mechanism

The=C2=A0latter=C2=A0mechanism=C2=A0was=C2=A0already=C2=A0present=C2=A0in=
=C2=A0batman-adv=C2=A0but=C2=A0recently=C2=A0the=C2=A0concept
has=C2=A0been=C2=A0discussed=C2=A0again=C2=A0and=C2=A0here=C2=A0comes=C2=A0=
the=C2=A0new=C2=A0implementation.=C2=A0Moreover=C2=A0we
added=C2=A0a=C2=A0compile=C2=A0option=C2=A0in=C2=A0order=C2=A0to=C2=A0let=
=C2=A0expert=C2=A0people,=C2=A0which=C2=A0think=C2=A0that=C2=A0this
mechanism=C2=A0is=C2=A0not=C2=A0helpful=C2=A0at=C2=A0all,=C2=A0disable=C2=
=A0it=C2=A0and=C2=A0save=C2=A0some=C2=A0space.

----------------------------------------------------------------
Antonio Quartulli (3):
      MAINTAINERS: add additional maintainer for net/batman-adv
      batman-adv: clean up Kconfig
      batman-adv: use ETH_ALEN instead of hardcoded numeric constants

Marek Lindner (1):
      batman-adv: encourage batman to take shorter routes by changing the d=
efault hop penalty

Simon Wunderlich (10):
      batman-adv: remove old bridge loop avoidance code
      batman-adv: add basic bridge loop avoidance code
      batman-adv: make bridge loop avoidance switchable
      batman-adv: export claim tables through debugfs
      batman-adv: allow multiple entries in tt_global_entries
      batman-adv: don't let backbone gateways exchange tt entries
      batman-adv: add broadcast duplicate check
      batman-adv: drop STP over batman
      batman-adv: form groups in the bridge loop avoidance
      batman-adv: add bridge loop avoidance compile option

Sven Eckelmann (2):
      batman-adv: Replace bitarray operations with bitmap
      batman-adv: Remove declaration of only locally used functions

 Documentation/ABI/testing/sysfs-class-net-mesh |    9 +
 Documentation/networking/batman-adv.txt        |   19 +-
 MAINTAINERS                                    |    1 +
 net/batman-adv/Kconfig                         |   27 +-
 net/batman-adv/Makefile                        |    1 +
 net/batman-adv/bat_debugfs.c                   |   19 +-
 net/batman-adv/bat_iv_ogm.c                    |   15 +-
 net/batman-adv/bat_sysfs.c                     |    8 +-
 net/batman-adv/bitarray.c                      |  118 +-
 net/batman-adv/bitarray.h                      |   26 +-
 net/batman-adv/bridge_loop_avoidance.c         | 1583 ++++++++++++++++++++=
++++
 net/batman-adv/bridge_loop_avoidance.h         |   98 ++
 net/batman-adv/hard-interface.c                |   18 +-
 net/batman-adv/main.c                          |    9 +-
 net/batman-adv/main.h                          |   11 +-
 net/batman-adv/originator.c                    |    3 +-
 net/batman-adv/packet.h                        |   43 +-
 net/batman-adv/routing.c                       |   29 +-
 net/batman-adv/routing.h                       |    1 -
 net/batman-adv/soft-interface.c                |  498 +-------
 net/batman-adv/soft-interface.h                |    2 -
 net/batman-adv/translation-table.c             |  435 +++++--
 net/batman-adv/translation-table.h             |    8 -
 net/batman-adv/types.h                         |   77 +-
 24 files changed, 2263 insertions(+), 795 deletions(-)
 create mode 100644 net/batman-adv/bridge_loop_avoidance.c
 create mode 100644 net/batman-adv/bridge_loop_avoidance.h
