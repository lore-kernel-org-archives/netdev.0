From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [GIT] Networking
Date: Fri, 4 Sep 2015 17:38:41 +0000
Message-ID: <8BC0F5D8-5872-4387-BACA-BE7EAF479928@intel.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
 <CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
 <20150903.104032.767889134756094076.davem@davemloft.net>
 <CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
 <CA+55aFzZe2buU-LxAktxYNojuvMbUNt64QiKDpGsfFwtrbf+Qg@mail.gmail.com>
 <62408D76-2E53-4914-97A9-32B65B167F9B@holtmann.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB8D542@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_447D6358-56B9-4C5F-80FD-2BB019DB81F7";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB8D542@AcuExch.aculab.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_447D6358-56B9-4C5F-80FD-2BB019DB81F7
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On Sep 4, 2015, at 2:07 AM, David Laight <David.Laight@ACULAB.COM> =
wrote:
>=20
>> I find them useful as syntactic sugar. We have not used them a lot, =
but there are cases in our crypto
>> handling code where we have fixed size array inputs/outputs and there =
we opted to use them. They make
>> it easy to remember what the expected sizes of input and output are =
without having to read through the
>> implementation (of course we never even tried to use sizeof on these =
pointers).
>>=20
>> static int smp_ah(struct crypto_blkcipher *tfm, const u8 irk[16],
>>                  const u8 r[3], u8 res[3])
>=20
> Expect that it looks like you are passing arrays by value,
> but instead you are passing by reference.
>=20
> Explicitly pass by reference and sizeof works.

It depends on what you mean by works. It at least doesn't look so =
misleading when passing by reference and so works more as expected. The =
sizeof in either case will never return the size of the array. To have =
sizeof return the size of the array would require a typedef of the array =
to pass by reference. In some cases that could be the right thing to do.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_447D6358-56B9-4C5F-80FD-2BB019DB81F7
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJV6dchAAoJEDwO/+eO4+5udkcQAL7Bg+OzBOStiwdBZch1S8BG
6GF4XDSZBz4+/H7ywxqNXZfMl6K63ceZCA7K0Y/HJNvWG/YQAzKPSjmlISb+aFv/
uN3CX5P8/2Ul3f9VisXTZX+7wZ2khF5kyEkRubpWz8VRtAIzTCkk5TgOWPWU/oJ/
ISEFnJNbWmTHpGvY4yIckAH94ZUCXTf+aZ3CG9+aS47bPgjrBp+h5B4Xl+HvkgJ3
LQIG8rfRgbYSJ616AyI6SQz/F2n8FSDQC/6OaWmI2Ko1+0hGUT7myESFw/k8+XOK
5wvjVnxGdtYfW2zXq0KlVvqVEGM9n66zRerqVA3JVohazVaebuTWxyriKC2ccZ0H
m0VpWk5OVkrTIGwNcx1YaVWHxG+ks0C27aprW4OqvofYObp0MJc2OC6fxbuEV/XI
1In0baIRFlo9CsHPK7Orl7KciuQS0yQxIgvpzrbXH8qgXAlscjLGb35WZBqFRPLC
nsztDe6qtVRdsV4XhJXo0Ubo4fUqJXMCOvBSd/QUV8EhqsI+DSLbi+r+uDOBGBwO
zSETrbt3gRatWdnQVHCvOn0gQIywAKE/Zc8ggUyeazHyM3G4PgXl89LbYCt4ZPD+
dVa0FGVlJuU7VRJlyRzQc0W5H4uxw05O6fb51SvKZM1c1Iy9HGLN5ZjenJxgw7Vc
3yF4UdE+ugU+8uqjxspU
=Pwd4
-----END PGP SIGNATURE-----

--Apple-Mail=_447D6358-56B9-4C5F-80FD-2BB019DB81F7--
