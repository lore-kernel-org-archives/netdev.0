From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 0/4] e1000e: ethtool setfeatures fixes +
 loopback
Date: Tue, 22 Nov 2011 12:46:51 -0800
Message-ID: <1321994813.2304.90.camel@jtkirshe-mobl>
References: <cover.1321989502.git.david.decotigny@google.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O17x5uXbiJiXmrJ2pfor"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Decotigny <david.decotigny@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321989502.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-O17x5uXbiJiXmrJ2pfor
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-11-22 at 11:23 -0800, David Decotigny wrote:
> This series fixes a bug in ethtool setfeatures and adds loopback
> support through ethtool setfeatures.
>=20
> I believe these patches could easily be adapted to e1000, but I don't
> have the hardware to test.
>=20
> Changes since v1:
>   - simplification in patch 1/4 (from Micha=C5=82 Miros=C5=82aw)
>=20
> ############################################
> # Patch Set Summary:
>=20
> David Decotigny (2):
>   net-e1000e: fix ethtool set_features taking new features into account
>     too late
>   net-e1000e: ethtool loopback support
>=20
> Maciej =C5=BBenczykowski (2):
>   net-e1000e: reworked carrier detection logic
>   net-e1000e: Report carrier in loopback mode
>=20
>  drivers/net/ethernet/intel/e1000e/e1000.h   |    2 +
>  drivers/net/ethernet/intel/e1000e/ethtool.c |    6 +-
>  drivers/net/ethernet/intel/e1000e/netdev.c  |   32 +++++++++++-
>  drivers/net/ethernet/intel/e1000e/phy.c     |   69 +++++++++++++++++----=
------
>  4 files changed, 78 insertions(+), 31 deletions(-)
>=20

Thanks David for the patch set.  I have added the e1000e patches to my
queue.  As an fyi, I want Bruce Allan to look over these patches and he
is out this week on vacation.

--=-O17x5uXbiJiXmrJ2pfor
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOzAo7AAoJEOVv75VaS+3O3uUQAJWine0Qlv2iNgjjZtIGPVnt
1uxmT/0tZvyMDDqWRK2uboo5EkCVWNV5IVRlv+190oA34+i8SSEs6VzZiy4IZ73m
ALZAedNHfm3KJ2jZKrE7nNZc+zg+kzIDaOXiUarFMcbxpdBlWVlmEnz+iZERBHf6
3+qrVHUyvuJJliuAXGhoC/WFoglG5FGlp5IYqdPiOhm9GunGFt7sVTbqQJuRREjs
AmPYEnrMRHtv/0R0FDwXBO4czF8QqnvsyCa8zTFVvVsZHWAwHWjurGtpgrxUIZDE
xGXONZ80F1wMmia9m4HBC648/nifgizf8L8pca1DrsBJg/tJiTKMXX6bnVM4Q4SY
XGrThQMRsaa8kFp7ZHKAbum0yQqvCT3g10PeuElKY1iRTvO/2b0o04NLC/4ocjJS
EzQ9ac6oqDrAGZDLor1T3uedID9KPqQgD6ABbvoeDmkgou8nWdlEq0l2Y9jVqrTS
RkMtLXNYBoOgkpQ6xiwjl5GzAEqHAE6lVylXtkQJjZKYeq7Nz6mZr6v7lGUF6wM+
pJ+3TH8fp88ERQvK6wLTiH+6SDXZCmMh2cO7R4Y7gLPSWbDKemc6nxMKGIBd7gcU
BMy5uc7iisvlHDEoUlosiN+1tl8Vd8L9U2XLh+zrnz1RV5UmdYDHFy73CMlo3Zaz
2WZ8gzp5WDvstFXfK666
=H90V
-----END PGP SIGNATURE-----

--=-O17x5uXbiJiXmrJ2pfor--
