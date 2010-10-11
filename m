From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] atl1c: Add support for Atheros AR8152 and AR8152
Date: Mon, 11 Oct 2010 23:28:21 +0100
Message-ID: <1286836101.2955.293.camel@localhost>
References: <1286759930.2955.285.camel@localhost>
	 <20101010.210304.71107535.davem@davemloft.net> <20101011184835.GA10049@tux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-lYbZfGWx2ePVt3uLExZ5"
Cc: David Miller <davem@davemloft.net>,
	Luis Rodriguez <Luis.Rodriguez@Atheros.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jie Yang <Jie.Yang@atheros.com>, linux-team@atheros.com
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52154 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756824Ab0JKW21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 18:28:27 -0400
In-Reply-To: <20101011184835.GA10049@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lYbZfGWx2ePVt3uLExZ5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-10-11 at 11:48 -0700, Luis R. Rodriguez wrote:
> On Sun, Oct 10, 2010 at 09:03:04PM -0700, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Mon, 11 Oct 2010 02:18:50 +0100
> >=20
> > > Your commit 496c185c9495629ef1c65387cb2594578393cfe0 "atl1c: Add supp=
ort
> > > for Atheros AR8152 and AR8152" included the following changes:
> >  ...
> > >> +		if (hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c_=
b) {
> >  ...
> > >> +	if ((hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c)=
) {
> >  ...
> > > Shouldn't the first if-statement use the same condition as the second
> > > i.e. matching the previously-defined hardware types athr_l1c and
> > > athr_l2c?
> >=20
> > Yeah that definitely looks like a bug to me.
>=20
> Good catch, unfortunatley I don't have the source code I used to port
> this work the day I did this anymore locally, so adding=20
> Jie Yang who is actually our maintainer for this driver.
>=20
> Jie, can you please confirm if this patch is correct?

I was suggesting that the first condition was wrong and the second was
right.

Ben.

> diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/atl1c/atl1c_hw.c
> index d8501f0..0a7b786 100644
> --- a/drivers/net/atl1c/atl1c_hw.c
> +++ b/drivers/net/atl1c/atl1c_hw.c
> @@ -132,7 +132,7 @@ static int atl1c_get_permanent_address(struct atl1c_h=
w *hw)
>  			return -1;
>  	}
>  	/* Disable OTP_CLK */
> -	if ((hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c)) {
> +	if ((hw->nic_type =3D=3D athr_l1c || hw->nic_type =3D=3D athr_l2c_b)) {
>  		otp_ctrl_data &=3D ~OTP_CTRL_CLK_EN;
>  		AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
>  		msleep(1);
>=20
>   Luis
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-lYbZfGWx2ePVt3uLExZ5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATLOPgOe/yOyVhhEJAQLlHBAA093Dc5EYMFxAyqS8bI8fLHhR3OcsSS4D
WJmc0+lJjsjPHDmZaoOdG2b59/9XqQH5/Zt90OHYKOq3eOGywwoHmZmkGy0ZeJcU
bs4foQAvkideg1pJAKa5JksgJRBQM9z33fkRba6rRsW3ScTUBPnbTTy1u64WGqtQ
pwzUFH7pfSuM9VoKYlbmW7SCEC9pguOMJNwhEd+gEwrX5E5k7+z2PS929FwBfX7k
loSh7JmuQ5aXkVMqIeYhJ9OlyEjOSGqq9EDDnu05KqFga+N+wvmJZwtLtzldjR2T
fbcx/us+ECi7q9OnUJqv/K/aeqnzVtJ3qt5DklSGeCq+iGLRN/vKtfqW+H+OcGY7
E5ZX1K5bTUP4hGitplV3UDCu9erotHkD3PBHUP6o089eeBr4uc3hsmdILR39qbr6
C8YFrGIyHwYa/c/z+7J0QCqo1BFJqqun/Gx8CXw6xfnAvDdmASdSQuxEf+SVwAVA
TGedNPS3xTS+q5PmZ+cAqg14hRZFtoiyln+/WR5A1zD+USvsWrqtstwMsTWgTtAu
z9TDBQScnGQHDOhd2nPn00NI9Ob4q6jkLg4mNFKOrJrlGu92mG/GwmSSAu+Ah3pk
e7MFQN9cRh0F5adV78Gg3TjOYETOL1Zk7xJfovrqpPvQY4S/bIwk3vpNOVBvC0cC
2ipHhQ9K1zs=
=ijSh
-----END PGP SIGNATURE-----

--=-lYbZfGWx2ePVt3uLExZ5--
