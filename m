From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net 1/2] isdn_ppp: Add checks for allocation failure in
 isdn_ppp_open()
Date: Sun, 01 Nov 2015 16:23:28 +0000
Message-ID: <1446395008.25466.0.camel@decadent.org.uk>
References: <1444845074.31451.21.camel@decadent.org.uk>
	 <20151016.004606.1112196816016985692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-s4xORFF3kKdE4tIZ0+aU"
Cc: isdn@linux-pingi.de, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:48114 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbbKAQXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 11:23:40 -0500
In-Reply-To: <20151016.004606.1112196816016985692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s4xORFF3kKdE4tIZ0+aU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-10-16 at 00:46 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 14 Oct 2015 18:51:14 +0100
>=20
> > Compile-tested only.
> >=20
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > =C2=A0drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
> > =C2=A01 file changed, 6 insertions(+)
> >=20
> > diff --git a/drivers/isdn/i4l/isdn_ppp.c
> b/drivers/isdn/i4l/isdn_ppp.c
> > index c4198fa..86f9abe 100644
> > --- a/drivers/isdn/i4l/isdn_ppp.c
> > +++ b/drivers/isdn/i4l/isdn_ppp.c
> > @@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0is->compflags =3D 0;
> > =C2=A0
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0is->reset =3D isdn_ppp_ccp_reset_al=
loc(is);
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is->reset)
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0return -ENOMEM;
>=20
> Ben, your email client has corrupted both of these patches.
>=20
> Please fix this up and resubmit, thanks.

Sorry about that; it is a regression in Evolution 3.18.

Ben.

--=20
Ben Hutchings
Nothing is ever a complete failure; it can always serve as a bad example.

--=-s4xORFF3kKdE4tIZ0+aU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVjY8gOe/yOyVhhEJAQpGNRAAsvBma3n/jlMKeMrGhwz+O/HkOz36xlOA
pQtdiVNmNBUfJhpwaverJ8OpIqktnFwLeXtpV0dJEP9QxvaROEVOtlF8tgFOIPyc
l2vMgpyG+vLuN9t1JVbfqqhjAvzk3D6mXVLbuakfqSddDoaf1LL4nj/WSgAeZ59Q
F9prWMD3+RXSR7Mv3CFh3vmj1l2MXM5myC3ycb9xpZv/lvpQtdS+7XTNIhWZAxcR
mJW6WUpwXgqYGA4kMsmlgeSZjpUTqtX+/m7X+Xcc/oqqlNrv10KfBhLwmdCvYlcD
iHfIaEwLjaPGymk+uWiVLBr5cQNBa4336lpJ5GniilNHEr0taIoAY/DKHQO+LuUc
UQSTCoAKLDzB/jus2FY4VA9NCcK7eiedfxuPhT/6Us75apXu7y+Bmw1BlqStSYav
A89ErTxKFfIQ0/SKSGqHRYxvX64544jjVZxUvvNi0TZNtNC7KYAmf0nvOt37auTX
HyKXSujI5wWDZExuuGWs0C6AlMNbRlQoDC+AcbVOy9ewg879W5kLLxCbWAAKhU53
QeIP4iYWN4Ltf0G1nRB86ziUOeP0uPQypGjrDVHt5a4QBctpLVCm9xFWup7K/2a5
G8jRKuQuUkAVJtW2ms1Jn6sADNrJCzvGnsdwzQUOkzYQXoMEPDbPaJ8TKumcenCm
NT29tnopzCU=
=i/Tb
-----END PGP SIGNATURE-----

--=-s4xORFF3kKdE4tIZ0+aU--
