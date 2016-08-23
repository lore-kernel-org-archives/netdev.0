From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: CVE-2014-9900 fix is not upstream
Date: Tue, 23 Aug 2016 18:35:27 +0100
Message-ID: <1471973727.13300.162.camel@decadent.org.uk>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <20160823.094029.1244944495918162255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-/pl5VJ3pMeeCQqWbUB4t"
Cc: avijitnsec@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, luis.henriques@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823.094029.1244944495918162255.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/pl5VJ3pMeeCQqWbUB4t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-23 at 09:40 -0700, David Miller wrote:
> From: Luis Henriques <luis.henriques@canonical.com>
> Date: Tue, 23 Aug 2016 14:41:07 +0100
>=20
> > Digging through some old CVEs I came across this one that doesn't
> seem be
> > in mainline.=C2=A0 Was there a good reason for not being sent upstream?=
=C2=A0
> Maybe it was
> > rejected for some reason and I failed to find the discussion.
>=20
> Because the patch is completely bogus, and thus so is the CVE.
>=20
> The variable initializer clears out the entire structure.
>=20
> Until you can show compiler output from gcc that shows it not
> initializing the structure I will not apply this patch because I know
> that it faithfully does.

On some versions and architectures. =C2=A0Can you guarantee that you will
notice when an exception appears?

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.

--=-/pl5VJ3pMeeCQqWbUB4t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJXvIlfAAoJEOe/yOyVhhEJwwMP+wZkSbVzg0jbw11qBSMxduR+
Cx2aQqdLA51o7M9TrrN51knKjuNje/A3NUsfFYPV6g+Q8PYA85Y9LE6pFD+62EBH
Xeg5GIusqKfIp2iqxDLFAiiBVSH06hsVyYwrg7MQeNUOd8yTCI0YXL/bM3JhKmD0
LzCOIv/F4hOKBD8dPLI0wNmugSU1ZKco6FYaWabIJJX3cVdr8cWmXPVcjr/gOG0p
caNH0d0njI1o4Hww2OyoIP0xVN7qV/LAlaIw0zfUqJhX1R9E8dhRcZWTkYYyhnXS
2r0pFFFqXPpI1fEoP6w6ajj4+LWI96umS/RlHYP6j2wruKpRp7wU2oIl7qAq+reG
vbGB0OWcITrCj40NxAKGRdq8nngGx8E+N1cU3A+QH9BddWZdtfPWQAJ6AwPvboXt
YeUblbAhHyxAKyv9HD4VPjD2yrzKdGTv6EsnFyv8pGtkPLWB7ghViw3hMiOoIa6G
hdpHyjmhUQ/EakNipEK2T8Nn9k8xOeriVAJk+Qn0ypiJhJVB+6AisuOBNUvOyXf+
urjmnfLrUEXwpGbLeJIDe5aiu1pSz9X3hABrrTjc9bZvlQu/dd9MrmlBVrF4FHv+
/cJa0gNm6att4IVTcKS9EW3EZjyoJ7074DSaKE5fuBKGebWKI/7BP6XEzPp9dNps
nXHY43TYJisB0rYtblne
=MQbp
-----END PGP SIGNATURE-----

--=-/pl5VJ3pMeeCQqWbUB4t--
