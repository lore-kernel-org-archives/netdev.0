From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/3] ser_gigaset: fix up NULL checks
Date: Wed, 9 Dec 2015 11:45:57 +0100
Message-ID: <56680665.4000301@imap.cc>
References: <cover.1449570042.git.tilman@imap.cc>
 <ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
 <1449603913.2384.16.camel@tiscali.nl>
 <20151208221657.71fd0d71@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="IdaXhx0NKDSUP9gF7tqh9VosiNJ1enoRr"
Cc: netdev@vger.kernel.org, Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208221657.71fd0d71@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IdaXhx0NKDSUP9gF7tqh9VosiNJ1enoRr
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 08.12.2015 um 23:16 schrieb One Thousand Gnomes:
> The right fix as far as I can see is to remove the tests although
> WARN_ON() combined with your tty->ops change might be safer.

Feel free to submit a patch.

>> It's pretty obvious that this should have been part of commit
>>  f34d7a5b7010 ("tty: The big operations rework"). That being said, the=
se
>=20
> It ahould probably have been fixed around the same time or in one of th=
e
> tty locking reviews, but drivers/isdn and net/irda weren't traditionall=
y
> part of the general tty maintenance but handled separately/

Or just ignored.

>> test puzzle me. It's not obvious why they're needed. Ie, can the null
>> dereferences they try to catch really happen? But I can try to figure
>> out that in the future, if I ever feel the urge to do so. Anyhow:
>>
>> Acked-by: Paul Bolle <pebolle@tiscali.nl>
>=20
> Nacked-by: Alan Cox <alan@linux.intel.com>

So you feel it's better to maintain the current inconsistent state
created by commit f34d7a5b? Please elaborate.


--IdaXhx0NKDSUP9gF7tqh9VosiNJ1enoRr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWaAZ0AAoJEFPuqx0v+F+qsKcH/jc4tXNXZG3abCSIrODfIoNP
JKNYPvtNZFnGwzijOkMsBYeu34PCNFpNZhYPo36hi/X2rZCsmCUmg8yfOgwsGhVV
9d9KSK3l+WTkwnm4jaA15dP8VHEYrZaZF/CK5tBYCKbkF/qi4FqA8BsJ0CY067WK
Qg8rS2vcZlmbYMNWgC5fGLk84B5Uy0GjoMOjexWMdf+gYMoMMxhtuSXL3vmgJtIk
c2R2PdLWYVKBSBD/W06qZWualJMlrrfSHxsQVo6OHueOm64v1xYLAn/HLbVsJnhu
HnJJZXGekHV6iEMWbSuVQqTYXLO/ZvwRfbvnTxrWvRcxhRPBxqUHGzS2b7D9yv0=
=l5J4
-----END PGP SIGNATURE-----

--IdaXhx0NKDSUP9gF7tqh9VosiNJ1enoRr--
