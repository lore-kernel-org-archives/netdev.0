From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: Move e1000e_disable_aspm_locked() inside
 CONFIG_PM
Date: Thu, 23 Jul 2015 07:07:26 -0700
Message-ID: <1437660446.23223.3.camel@intel.com>
References: <1436846075-29366-1-git-send-email-mpe@ellerman.id.au>
	 <1436956216.13597.8.camel@intel.com>
	 <1437529280.16792.9.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+0vIDSnTgBeQWLf+v2FN"
Cc: "Avargil, Raanan" <raanan.avargil@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, aaron.f.brown@intel.com,
	yanirx.lubetkin@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437529280.16792.9.camel@ellerman.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+0vIDSnTgBeQWLf+v2FN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-07-22 at 11:41 +1000, Michael Ellerman wrote:
> On Wed, 2015-07-15 at 03:30 -0700, Jeff Kirsher wrote:
> > On Tue, 2015-07-14 at 13:54 +1000, Michael Ellerman wrote:
> > > e1000e_disable_aspm_locked() is only used in __e1000_resume()
> which is
> > > inside CONFIG_PM. So when CONFIG_PM=3Dn we get a "defined but not
> used"
> > > warning for e1000e_disable_aspm_locked().
> > >=20
> > > Move it inside the existing CONFIG_PM block to avoid the warning.
> > >=20
> > > Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
> > > ---
> > >  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > NACK, this is already fixed in my next-queue tree.  Raanan submitted
> a
> > patch back on July 6th to resolve this issue, see commit id
> > a75787d2246a93d256061db602f252703559af65 in my dev-queue branch of
> my
> > next-queue tree.
>=20
> OK. I take it your next-queue is destined for 4.3, so we'll just have
> to suck
> on the warning until then?

Yes, but I can queue Raanan's patch up for 4.2 (and possibly stable) if
necessary.  I have no issue with doing that.

--=-+0vIDSnTgBeQWLf+v2FN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVsPUeAAoJEOVv75VaS+3OM6UP+wSn4BKgC9gOiEaarNpIJ8fx
Jbe+K3eTZEsajKxpX8jFYAAkB7p/eHYH4wHenBenaB6BsmMygCk19wa5wAWrY6Ue
VzKaUodqbGJ0zCmMappZH8+LU98uW5UFwPGKuDlIanKBtditPBDDxAyVkNKj+1ZX
BbMwi/J5Q2hIgE6wzl6DC9jG7zDfYx33RYgcGg5eHiScE+wEMxkOcx/WH6b9dCjI
DYMfDxx3KoWh657qFuM/CHSxU0LuAshm+fCSjvj4OypRl5cQvx2pCHEzv4Lujx/V
erzyrS7ITwDyInfoP5OAnjj3EGyieIMIIFNU1YYApp6TaiviMqqynUxMXaaEmbli
hXvUso4m8qaZdjEK/W20X9mRSVuUMp5OJh5NF32Y+ovfocWweIA1vIIFxAcMq2fy
16jWE794367dcvD9bTtqortQbV3OfC9xJAYlWPPX+Epi32AesGOqfsjTSbbFiLcR
hkeObsX3PmzxYbnZJd3lyaRKIKcUasoQf6azFi4Fqe3b+rBZsFrdaoaunTuNI2ih
wi1nfccNUpwxl/m5GhB+mLdw/fitUfe7e/9f2hld+xrKP1KQjyM/D2/y6tlbHAa8
NCfwTuD+blRN0lXTmYoDhQ1RSsoSKfjramwHMJX3tlCnJGj9/wr9s3siwCAfS/lc
PI5+kGT2+lKgU3Xjc1pF
=2dAZ
-----END PGP SIGNATURE-----

--=-+0vIDSnTgBeQWLf+v2FN--
