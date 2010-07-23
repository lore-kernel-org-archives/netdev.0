From: Sven Eckelmann <sven.eckelmann@gmx.de>
Subject: Re: linux-next: manual merge of the staging-next tree with the net tree
Date: Fri, 23 Jul 2010 09:09:31 +0200
Message-ID: <201007230909.32763.sven.eckelmann@gmx.de>
References: <20100723150323.daa04d5f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2161160.qE1jM2RogY";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100723150323.daa04d5f.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2161160.qE1jM2RogY
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Stephen Rothwell wrote:
> Hi Greg,
>=20
> Today's linux-next merge of the staging-next tree got a conflict in
> drivers/staging/batman-adv/hard-interface.c between commit
> 28172739f0a276eb8d6ca917b3974c2edb036da3 ("net: fix 64 bit counters on 32
> bit arches") from the net tree and commit
> a1a38cad4c71bc08403b204fbe0ba98b4447f8bf ("Staging: batman-adv: Don't
> increment stats of foreign device") from the staging-next tree.
>=20
> The latter just removes the code fixed by the former, so I did that.

That is absolutely correct. The netdev guys noticed that the commits around=
=20
"net: fix 64 bit counters on 32 bit arches" made those lines a real bug=20
(casting stuff around, writing on memory it should only read, probably writ=
ing=20
on unrelated memory). We reviewed those lines again and noticed that they m=
ake=20
no sense at all and removed them to fix that bug and another minor bug.

I am sorry that this created a merge conflict for you, but only those commi=
ts=20
by the netdev guys made us aware that there is something going wrong in the=
=20
batman-adv receive code.

Thanks a lot for your linux-next repository and your work on it. It is a bi=
g=20
help to see what is going on elsewhere and how it may affect our code.

Best regards,
	Sven

--nextPart2161160.qE1jM2RogY
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMSUAsAAoJEF2HCgfBJntG7t0QAM1hMVp1TEf7i9xr11wTgO/N
ck+ALLNL5X9OSIblPwAWwwDtrPKPfImgg2U00CQbvsw4p3we3Ap/7oa31+778LJt
4QwfVxX5WrwXwAF/mKerm1y1kyhJ6W2eMsrwF/HvKYoP7zvz2xZVMjxg8H8kO7Jk
ZXpzssjscbKkNGkBnAm0dbICzfEtL41NlmUNHz9NBp5SMJEBe+d7O5T1/D0BtmN4
TAQcjLEYZdn340YkzbhBLLXowI3ytkiLETfYBqWfKUpedBfXGrHraL+SRQjQ4PHS
aTrQescsDykWhyAOq+X7BxxO01q8mhRZBpOOP7z9oEprdJ3DcilARN8Oz/sl9rH3
mMJuMt7xljiAGZqo2fpXWWMEt2SiRoMhwc16OWL1tIlIe7OXLMQr9ONkuDiJHWVL
yC8WuprrJOTHZLYun+nBfrJaWwEvSn/k+atZx8zxNkOqt/z9N/aFjXzqQxGFqflR
Wh3Cs6ZxmdXXgwDV5CrhCS/zvM8eTiBTOUZb5W9MuvZf9MFyyFBzBGCHPjjg7c8m
y+nHFWvCoUbYoGGnY1ZNa8nSKoxTSGJ5+yofUQz+0JIRWh08iLFBabNgYkzyMtiS
hjLFKAjHfOIMeVy2xMEgDiwWtAQFFSU8xbptm3usuAUMIXygo+kFfVhrfASYykov
p2mgLN5jfr5BHq5q2O1b
=30hq
-----END PGP SIGNATURE-----

--nextPart2161160.qE1jM2RogY--
