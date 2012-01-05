From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Thu, 5 Jan 2012 14:45:53 +1100
Message-ID: <20120105144553.f2fe4345bf1ea33f24c0c821@canb.auug.org.au>
References: <20120105140405.92816482d364abfcf3854d74@canb.auug.org.au>
	<4F05151D.5070401@lwfinger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Jan_2012_14_45_53_+1100_frmboMLfvAcS8i6Y"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4F05151D.5070401@lwfinger.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Jan_2012_14_45_53_+1100_frmboMLfvAcS8i6Y
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Larry,

On Wed, 04 Jan 2012 21:12:29 -0600 Larry Finger <Larry.Finger@lwfinger.net>=
 wrote:
>
> On 01/04/2012 09:04 PM, Stephen Rothwell wrote:
> >
> > Today's linux-next merge of the wireless-next tree got a conflict in
> > drivers/net/wireless/b43legacy/dma.c between commit 3db1cd5c05f3 ("net:
> > fix assignment of 0/1 to bool variables") from the net-next tree and
> > commit 5d07a3d62f63 ("b43legacy: Avoid packet losses in the dma worker
> > code") from the wireless-next tree.
> >
> > Just context changes.  I fixed it up (see below) and can carry the fix =
as
> > necessary.
>=20
> Is there a good explanation why changes in wireless drivers are sent to=20
> net-next, and not wireless-testing? If that were stopped, this kind of co=
nflict=20
> would be avoided.

In this particular case, I think Dave asked Rusty to just do a net wide
sweep - see the commit message:

commit 3db1cd5c05f35fb43eb134df6f321de4e63141f2
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Dec 19 13:56:45 2011 +0000

    net: fix assignment of 0/1 to bool variables.
   =20
    DaveM said:
       Please, this kind of stuff rots forever and not using bool properly
       drives me crazy.

These conflicts are trivial in any case ...
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__5_Jan_2012_14_45_53_+1100_frmboMLfvAcS8i6Y
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPBRzxAAoJEECxmPOUX5FEfPEQAJwOUdxRT67NOzfkWZ1Hxw9F
RqtrslXk4gsu5X4ZnNkELH2wp+0YbR0mx40hl+qnHZc9CmfZQFrt6RiZlXedzoAZ
uLYcaIq0QNFkhfQRWIlaCjUtIl4efpkfPfQyG4HtUBOtFK+lFEHrVzx+UA5giR+a
qzos3FstUg93TaVO7ol21FV1y1la/0KPktXqUoFZPgqrB0LHzrH3yY6xTfYjHZRz
foaU9nEdtpBT7QyCXkDkiq2FZ9izFi4swIhk+UPCPF+AYrUPnNE2BlUNiJo0Z9Ir
9RmBalM2zkJuuySAD6Cu6DGA1lh4Dp8DJ6oICyEKBjh2AUOVu8vOrxUO8zLdIBtv
Oi+mELPgYsocYCHZ+gINBZwM7Q1trkB2wggJYJfAQLNzjfzD3XGltwNGvIHrUt0g
sW2OnbGpVPwomMxyrf+ftEFXrD7xiXIX+qvF5hiLP63Wvd2DSFrXh/Px97S3+kHK
keuxgixNn8PeF6n58OvoVWZ4TT4Lqa1fhwvwuL7qrH3YxundPZkxjJq9eGXiO9kX
7NFVkRvPDKvOKHOYQfkQkVyKdNKLyMsS3Yrj9ej3joI15B3JFOIv+JJlWoUhcxi3
8CYDv6GLDRghYCGENy95m+poybg0HtixHukaD/uBhhAdzub8osBc7yg66mA0LRMN
5W+lTWU0ILeaoBhTWRV9
=A5W5
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Jan_2012_14_45_53_+1100_frmboMLfvAcS8i6Y--
