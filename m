From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: linux-next: manual merge of the net tree with the
 wireless-current tree
Date: Thu, 26 Nov 2009 10:33:09 +0100
Message-ID: <1259227989.32372.32.camel@johannes.local>
References: <20091126141055.d8c67798.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-VjD91kvNcXdG13szySEv"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758752AbZKZJdt@vger.kernel.org>
In-Reply-To: <20091126141055.d8c67798.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VjD91kvNcXdG13szySEv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-11-26 at 14:10 +1100, Stephen Rothwell wrote:
> Hi all,
>=20
> Today's linux-next merge of the net tree got a conflict in
> net/wireless/wext.c between commit
> 9fed059667d35fca9288460106e92dbb8ba35ea1 ("WE: Fix set events not
> propagated") from the  tree and commit
> 3d23e349d807177eaf519d444677cee86b1a04cf ("wext: refactor") from the net
> tree.
>=20
> The latter deleted the file that the former modified.  I just ignored the
> wireless-current change and removed the file (which seems to have been
> done in the latter change anyway).

The fix should probably have gone to wext-core.c instead?

johannes

--=-VjD91kvNcXdG13szySEv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLDktSAAoJEODzc/N7+QmaqaAP/1io+IIIl1t6jXWPEldK8GbH
T/AVLIHGqyDfX3HAGzC3hYcr+Ge12jTVB9B54OGq43Drvu0wE9JhIgcXhgVEEb+H
KRN8LF/ECBy5k7xET6lDQXVQKViFbCQ4Y1Tbifc3H8oDm9pptAC5bOrIhDrNyyec
rC2XJR3OSAz4fY6FkRWlNGLaciJs+o68/gAfGwlk6m70B+mXSPM4oKnmOYG5pHfL
nYgbPEesJ4MfCowPEVPKTOAaoOYmAXrjQXdZNIFLXttpsusMt3R9tMJ2t+TZoMMz
GN3cJUFSVV74WczhmSOX+Bfilqa446h+fzkoCMHrduFo2y3TBKsFp0Y+RxJDfwKF
PXnhJnj2VFluBnOvewQyj5twSyrELX+RuBu14md15eObiGVejSsm7oT1E18aZJUc
KX23r7wl/SyD1B5ZiZ8ABoU4ro5CTpsHATrc3K1OR11s349zEgcGWyoRh1eXy76u
6LMs4Fm1c379tnLzI098i4rgS8vZJMRL+FE/c4zgt4iZgdmP4ngQq/r/zXXjUPR8
FmJGFZH/ShdITys7SoszwIfq6PrJaJGp7/Ks63XZdTAucdlo9T1kGHJXqcdA2jJ4
JfHrNzm+9RbKBe/ul9xBI+nEdH0M5a5pLdWVKGSTOLmYMImlfnl2bVY9U5C6Jknj
O84Z733cwki11ozCty+1
=aiyu
-----END PGP SIGNATURE-----

--=-VjD91kvNcXdG13szySEv--
