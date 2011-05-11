From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/2] wireless: Make and use const struct ieee80211_channel
Date: Wed, 11 May 2011 12:57:42 -0400
Message-ID: <20110511165742.GE2490@tuxdriver.com>
References: <cover.1304054543.git.joe@perches.com>
 <20110505184934.GB3005@tuxdriver.com>
 <1304634107.1788.171.camel@Joe-Laptop>
 <20110506131922.GA2252@tuxdriver.com>
 <1304698221.11874.6.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourceforge.net,
	orinoco-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304698221.11874.6.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2011 at 09:10:21AM -0700, Joe Perches wrote:
> On Fri, 2011-05-06 at 09:19 -0400, John W. Linville wrote:
> > On Thu, May 05, 2011 at 03:21:47PM -0700, Joe Perches wrote:
> > > On Thu, 2011-05-05 at 14:49 -0400, John W. Linville wrote:
> > > > These patches generated a lot of warnings in net/mac80211.  Did=
 you
> > > > actually build them?
> > > Yes.
> > > Did you apply patch 1/2 first?
> > > It's a dependent patch.
> > That's the one that cause most of the warnings...
>=20
> Consider the 2 patches as a single patch.
> Do you have new build warnings after applying both
> patches 1 and 2?

Yes, of course.

  CC [M]  net/mac80211/scan.o
net/mac80211/scan.c: In function =E2=80=98ieee80211_scan_state_decision=
=E2=80=99:
net/mac80211/scan.c:509:12: warning: assignment discards qualifiers fro=
m pointer target type
net/mac80211/scan.c: In function =E2=80=98ieee80211_scan_state_set_chan=
nel=E2=80=99:
net/mac80211/scan.c:610:7: warning: assignment discards qualifiers from=
 pointer target type
  CC [M]  net/mac80211/offchannel.o
  CC [M]  net/mac80211/ht.o
  CC [M]  net/mac80211/agg-tx.o
  CC [M]  net/mac80211/agg-rx.o
  CC [M]  net/mac80211/ibss.o
net/mac80211/ibss.c: In function =E2=80=98ieee80211_sta_join_ibss=E2=80=
=99:
net/mac80211/ibss.c:250:7: warning: passing argument 4 of =E2=80=98__ie=
ee80211_sta_join_ibss=E2=80=99 discards qualifiers from pointer target =
type
net/mac80211/ibss.c:64:13: note: expected =E2=80=98struct ieee80211_cha=
nnel *=E2=80=99 but argument is of type =E2=80=98const struct ieee80211=
_channel *=E2=80=99
net/mac80211/ibss.c: In function =E2=80=98ieee80211_ibss_join=E2=80=99:
net/mac80211/ibss.c:918:24: warning: assignment discards qualifiers fro=
m pointer target type
net/mac80211/ibss.c:923:30: warning: assignment discards qualifiers fro=
m pointer target type
  CC [M]  net/mac80211/mlme.o
net/mac80211/mlme.c: In function =E2=80=98ieee80211_mgd_auth=E2=80=99:
net/mac80211/mlme.c:2350:11: warning: assignment discards qualifiers fr=
om pointer target type
net/mac80211/mlme.c: In function =E2=80=98ieee80211_mgd_assoc=E2=80=99:
net/mac80211/mlme.c:2500:11: warning: assignment discards qualifiers fr=
om pointer target type
  CC [M]  net/mac80211/work.o
  CC [M]  net/mac80211/iface.o
  CC [M]  net/mac80211/rate.o
  CC [M]  net/mac80211/tkip.o
  CC [M]  net/mac80211/aes_ccm.o
  CC [M]  net/mac80211/aes_cmac.o
  CC [M]  net/mac80211/cfg.o
net/mac80211/cfg.c:2083:2: warning: initialization from incompatible po=
inter type
net/mac80211/cfg.c:2101:2: warning: initialization from incompatible po=
inter type
net/mac80211/cfg.c:2103:2: warning: initialization from incompatible po=
inter type
  CC [M]  net/mac80211/rx.o

commit 07daa458f14226deff1e464f594a44111168e7ee
Author: Joe Perches <joe@perches.com>
Date:   Thu Apr 28 22:25:08 2011 -0700

    wireless: Use const struct ieee80211_channel where possible
   =20
    Make some structure uses const.
   =20
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

commit 5c9adfae8855fc744f77b24df322060a7117c521
Author: Joe Perches <joe@perches.com>
Date:   Thu Apr 28 22:25:07 2011 -0700

    wireless: Make struct ieee80211_channel const where possible
   =20
    Useful for declarations of static const.
   =20
    Signed-off-by: Joe Perches <joe@perches.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

<commits were temporary, not applied now>

I'm dropping these patches -- feel free to repost if/when the warnings
disappear.

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
