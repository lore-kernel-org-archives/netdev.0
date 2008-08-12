From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: ath9k build failure
Date: Tue, 12 Aug 2008 13:33:54 +1000
Message-ID: <20080812133354.2eadf82d.sfr@canb.auug.org.au>
References: <20080811162040.ed7b8ab7.sfr@canb.auug.org.au>
	<20080811164657.GE6128@tesla>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__12_Aug_2008_13_33_54_+1000_sXfP.3fTI1mnT3M3"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@Atheros.com>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080811164657.GE6128@tesla>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Aug_2008_13_33_54_+1000_sXfP.3fTI1mnT3M3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Luis,

On Mon, 11 Aug 2008 09:46:57 -0700 "Luis R. Rodriguez" <lrodriguez@atheros.=
com> wrote:
>
> On Sun, Aug 10, 2008 at 11:20:40PM -0700, Stephen Rothwell wrote:
> >=20
> > Today's linux-next build (powerpc allyesconfig) failed like this:
> >=20
> > drivers/net/wireless/ath9k/hw.c: In function 'ath9k_hw_spur_mitigate':
> > drivers/net/wireless/ath9k/hw.c:4925: internal compiler error: in expan=
d_expr_real_1, at expr.c:9199
> >=20
> > This is a driver that is in Linus' tree and has no patches in the
> > linux-next tree.
> >=20
> > The original work around talked about applying the patch twice, so I
> > applied the below patch.
>=20
> this is also in wireless-testing. I also see this in linux-2.6
> under b08cbcd4546445740c2a04291204b56f8baf7be2. Not sure how this didn't
> get through linux-next.

That is only the first application of the patch, my patch is a fix of a
second instance of the same code.  See Adrian's post.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__12_Aug_2008_13_33_54_+1000_sXfP.3fTI1mnT3M3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkihBKIACgkQjjKRsyhoI8wPmwCgkSAWadUWxee3sNXBYDWqYac8
0HcAni83vmUeEzDjl2w0BQHIc24pA4tn
=H0sY
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Aug_2008_13_33_54_+1000_sXfP.3fTI1mnT3M3--
