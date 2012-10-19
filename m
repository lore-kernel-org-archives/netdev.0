From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#690845: ethtool: incorrect WoL detection on Broadcom NX II
 rev < 12
Date: Fri, 19 Oct 2012 02:30:09 +0100
Message-ID: <1350610209.22276.6.camel@deadeye.wl.decadent.org.uk>
References: <20121018134717.9579.22997.reportbug@palomino.museglobal.com>
	 <1350570748.26833.102.camel@deadeye.wl.decadent.org.uk>
	 <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9tLu57m2uO2MG2bYneGT"
Cc: 690845@bugs.debian.org, Teodor MICU <mteodor@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32935 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791Ab2JSBaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 21:30:24 -0400
In-Reply-To: <CAG2Wgfee=qsiUhAk5reYTypcOZL0kM5A58J+LjB1wuQ_k9FrfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9tLu57m2uO2MG2bYneGT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Teodor MICU reported that:
> On Broadcom NX II rev < 12 network interfaces it's not possible to activa=
te
> WoL using 'ethtool' (it can only be done from the MBA Configuration Menu)=
.
>=20
> However, even if "Pre-boot Wake On LAN" was enabled 'ethtool' doesn't
> see this change:
> 	Supports Wake-on: d
> 	Wake-on: d
>=20
> I've just tested that WoL works for this system.

He's been using Linux 2.6.32 and Linux 3.2, but there don't seem to have
been any later changes to WoL support in bnx2.

Is there any possibility that this could be fixed?

Ben.

--=20
Ben Hutchings
Anthony's Law of Force: Don't force it, get a larger hammer.

--=-9tLu57m2uO2MG2bYneGT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUICtIee/yOyVhhEJAQpHWRAAorAtMm6e3XMWj1QLvEfcolbPNnr3B1id
limeu4eX813WpxkAXVC8+aHQk9OYRbpbj5vOa81cRp4ldADg1D2PRrRFHSHA0kYe
EfHTfD9rOwUQnyQP7XGr9Y6UREAxIm65MCRykn2fVHCFy25q3sAvXaed70Lqnilg
m6zkFEhGavXO5n0ciR0Z0FbGOdLzo/AlTXOUPGmF1Qd+MHc+UtgSFVx37zoRNRl/
GXOSG947PgQkM3ZtpXLS9649nPvEtt0PcJXFyu+DXf6aQObn01hw23EwZ2czcTuW
XUCxD+e+IVIQ9BiE7DUN4X2LakMSmepVamIpLEcTeVHqVkscI+VeS38cZ4Rt6Spl
TzRLrEfgszHvfCitkj1dI+wmxHsnl1oY3e+lBjqNs7i4t9hwOJof3h1BskGYdfRQ
obNPLmkoYnZ+l77AxtI2IyqM+Z4tO+wNV/C+gpMZHO58oBtLw/9hMKxqjaNt/wTB
VATvEN+BX7MzmFpGKWMx5SGDGgWoYPhY/1ZGpp6py5MpEiVrj8Nm95oQ3cCry2Gj
tdO2DRRGJeTO7lw97ea07UkksT7LJqFgvbROZArVWZK2ZjvRcCP0vcg1MWxf30lQ
F2s0nOLDyZ4ng0vQpHc+iaPbbJM7YJMnb9socNJ4FL3cWEYBJxliEIDYcKz0XPPw
iXgNKqQ2VGY=
=x5Wo
-----END PGP SIGNATURE-----

--=-9tLu57m2uO2MG2bYneGT--
