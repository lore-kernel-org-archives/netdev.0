From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-04
Date: Tue, 5 Aug 2008 23:28:39 +1000
Message-ID: <20080805232839.95235680.sfr@canb.auug.org.au>
References: <20080804193753.GA30345@tuxdriver.com>
	<20080804.150147.78586437.davem@davemloft.net>
	<20080805021710.GA21731@tuxdriver.com>
	<20080805.012814.215633850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__5_Aug_2008_23_28_39_+1000_GoHZK0.xw2FNjiVO"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080805.012814.215633850.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__5_Aug_2008_23_28_39_+1000_GoHZK0.xw2FNjiVO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

On Tue, 05 Aug 2008 01:28:14 -0700 (PDT) David Miller
<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>
> From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Date: Mon, 4 Aug 2008 22:17:10 -0400
>=20
> > On Mon, Aug 04, 2008 at 03:01:47PM -0700, David Miller wrote:
> > > I'm holding off on this pull until the list.h changes get so me lkml
> > > ACKs.
> >=20
> > Sure, np.  I created a "no-ath9k" branch in case you are feeling
> > frisky -- it is the same except for omitting the list.h changes,
> > the ath5k pci table change, and the new ath9k driver.
> >=20
> > 	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.gi=
t no-ath9k
> >=20
> > Hth!
>=20
> Due to the powerpc build failures the list.h stuff causes, I'm going
             ^^^^^^^
It was a sparc64 defconfig that failed due to the list.h changes.  The
powerpc build only failed when I added an include of <linux/bug.h> to
list.h.

The powerpc compiler got an internal error trying to compile the ath9k
code - but I don't know if there is anything we can to do to the source
to work around that.

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__5_Aug_2008_23_28_39_+1000_GoHZK0.xw2FNjiVO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiYVYcACgkQjjKRsyhoI8wnmgCcDp5xDwUw81MpySveKaTHWRrN
Vj4AoJTltUPIFSTYDpV0mYSgP0pmHINU
=b/De
-----END PGP SIGNATURE-----

--Signature=_Tue__5_Aug_2008_23_28_39_+1000_GoHZK0.xw2FNjiVO--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
