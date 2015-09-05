From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/2] ethtool: changes of emac_regs structure
 accordingly within driver emac_regs structure.
Date: Sat, 05 Sep 2015 11:41:13 +0100
Message-ID: <1441449673.14803.4.camel@decadent.org.uk>
References: <20150805150153.10f054ed@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yycs0oMdotBAdp6x2Vd5"
To: Ivan Mikhaylov <ivan@ru.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805150153.10f054ed@fr-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yycs0oMdotBAdp6x2Vd5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-08-05 at 15:01 +0400, Ivan Mikhaylov wrote:
> * do the redefinition of emac_regs struct from driver structure perspecti=
ve
>   and passing size from actual struct size, not from memory area variable
>   which set in dts file.
>=20
> * passing variable from dts option may cause a problem with output below=
=20
>   MII's section which we're fixing with this and 5369c71 commit in kernel=
.
[...]

But you still aren't handling the case where only one of the driver and
ethtool is upgraded, even by reporting an error.

I'm never going to apply patches to ethtool that obviously break binary
compatibility, so you are wasting your time sending me new versions
that do that.

At this point you should probably just bump the dump version numbers in
both places.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.


--=-yycs0oMdotBAdp6x2Vd5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVerGyee/yOyVhhEJAQrKjg//UjkwmEF2Ardp8d6soFrL9LFCUntDMOTL
MhOio9ohRIvNyV+uEKMfkDjxjqNlgPNHoFpk2gQBqpkqqjpZXLMVZKst80Nu6uy1
WunUZSBlCkOLBcjDaOlDeLH8UjL9ZsgiVpQkpWUsG6KhU2ks54WYk9yNG2QXhgKA
6pQTE/381GRKwI3rn91EonCYGUNLMoMiH0tuxYmkwcPMCwR0ZI0oJFTgl3Tc+csd
m4m7XP5lC+JfVsgzx4CjDW+LnoJ8Y2H3ztJMQIELP8Yhj1V4Y5ysIvcR2Csn8BWw
x0MsQlwzblzaz/qsHnO0tyoJV/r1dqtieo0+fQvEqk0dGIx1VniTI5nYQ7YSxV8k
vg83az7qp6FnppX8EPdtdRlCBONcyRdA3h+aIlrIlmLqypV5nQD//ebDQSCMivX9
w3RHkJwph94UK/bZLUvuBSOEuoTbw1Has39QIGawcw6KQ4r60/pmYo3Vpvb2LGwk
4DgOr9j4bWZHUr+4+65Dx96xFYUPe6vhfrPxA9og5TfSJyySQ4TyEAbp9l0QrDht
6qmXXDom8lN1SQlnAuKAxD08NEUgYLifhY2usxjhXU+GeGCU5qgV7dbH8Rkuf+mt
+dT8HCDPZA+3C0/OqrD6TLyaX/z+UcwykzA6GvFQQTtWU+Tp5rFyvD9zwDR2VLlq
b0CHiKBGRl0=
=y1zg
-----END PGP SIGNATURE-----

--=-yycs0oMdotBAdp6x2Vd5--
